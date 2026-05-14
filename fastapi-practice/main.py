from contextlib import asynccontextmanager

from fastapi import FastAPI

from database.mongodb import close_mongodb, connect_to_mongodb
from routes.student_routes import router as student_router


@asynccontextmanager
async def lifespan(app: FastAPI):
    await connect_to_mongodb(app)

    yield

    await close_mongodb(app)


app = FastAPI(
    title="Student API",
    description="A simple FastAPI project for learning CRUD with MongoDB",
    version="1.0.0",
    lifespan=lifespan,
)


@app.get("/")
def home():
    return {"message": "Student API is running"}


app.include_router(student_router)
