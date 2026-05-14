from pydantic import BaseModel, Field


class StudentCreate(BaseModel):
    id: int
    name: str = Field(min_length=2, max_length=50)
    marks: int = Field(ge=0, le=100)


class StudentResponse(BaseModel):
    id: int
    name: str
    marks: int
