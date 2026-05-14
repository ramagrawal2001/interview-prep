import os

from dotenv import load_dotenv
from fastapi import Request
from pymongo import AsyncMongoClient

load_dotenv()

MONGODB_URL = os.getenv("MONGODB_URL")
DATABASE_NAME = os.getenv("DATABASE_NAME", "student_db")


async def connect_to_mongodb(app):
    if not MONGODB_URL:
        raise RuntimeError("MONGODB_URL is not set in .env file")

    app.state.mongo_client = AsyncMongoClient(MONGODB_URL)
    app.state.database = app.state.mongo_client[DATABASE_NAME]

    await app.state.mongo_client.admin.command("ping")

    print("MongoDB connected successfully")


async def close_mongodb(app):
    await app.state.mongo_client.close()

    print("MongoDB connection closed")


def get_students_collection(request: Request):
    database = request.app.state.database
    return database["students"]
