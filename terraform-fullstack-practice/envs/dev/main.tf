locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# -------------------------
# Frontend S3 Bucket
# -------------------------

resource "aws_s3_bucket" "frontend" {
  bucket = "${local.name_prefix}-frontend-bucket"

  tags = {
    Name        = "${local.name_prefix}-frontend-bucket"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_s3_bucket_website_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_ownership_controls" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_policy" "frontend_public_read" {
  bucket = aws_s3_bucket.frontend.id

  depends_on = [
    aws_s3_bucket_public_access_block.frontend
  ]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.frontend.arn}/*"
      }
    ]
  })
}

resource "aws_s3_object" "frontend_index" {
  bucket       = aws_s3_bucket.frontend.id
  key          = "index.html"
  source       = "${path.module}/frontend.html"
  content_type = "text/html"

  etag = filemd5("${path.module}/frontend.html")
}

# -------------------------
# Network for Backend EC2
# -------------------------

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${local.name_prefix}-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.name_prefix}-public-subnet"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.name_prefix}-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${local.name_prefix}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# -------------------------
# Backend EC2 Security Group
# -------------------------

resource "aws_security_group" "backend" {
  name        = "${local.name_prefix}-backend-sg"
  description = "Allow backend traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow HTTP backend port"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"

    # For learning only. Later restrict this to your IP.
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outgoing traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name_prefix}-backend-sg"
  }
}

# -------------------------
# Latest Ubuntu AMI
# -------------------------

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical Ubuntu owner ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# -------------------------
# Backend EC2 Instance
# -------------------------

resource "aws_instance" "backend" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.backend.id]

  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y nodejs npm

    mkdir -p /opt/simple-backend

    cat > /opt/simple-backend/server.js <<'APP'
    const http = require("http");

    const server = http.createServer((req, res) => {
      res.writeHead(200, { "Content-Type": "application/json" });
      res.end(JSON.stringify({
        message: "Hello from Backend",
        path: req.url
      }));
    });

    server.listen(3000, "0.0.0.0", () => {
      console.log("Backend running on port 3000");
    });
    APP

    cat > /etc/systemd/system/simple-backend.service <<'SERVICE'
    [Unit]
    Description=Simple Node Backend
    After=network.target

    [Service]
    ExecStart=/usr/bin/node /opt/simple-backend/server.js
    Restart=always
    User=root
    Environment=NODE_ENV=production

    [Install]
    WantedBy=multi-user.target
    SERVICE

    systemctl daemon-reload
    systemctl enable simple-backend
    systemctl start simple-backend
  EOF

  tags = {
    Name        = "${local.name_prefix}-backend"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}