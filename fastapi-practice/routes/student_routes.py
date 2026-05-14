from fastapi import APIRouter, Depends, HTTPException, status

from database.mongodb import get_students_collection
from models.student_model import StudentCreate, StudentResponse

router = APIRouter(
    prefix="/students",
    tags=["Students"],
)


@router.get("/", response_model=list[StudentResponse])
async def get_students(students_collection=Depends(get_students_collection)):
    students = await students_collection.find({}, {"_id": 0}).to_list(length=None)
    return students


@router.get("/{student_id}", response_model=StudentResponse)
async def get_student(
    student_id: int,
    students_collection=Depends(get_students_collection),
):
    student = await students_collection.find_one(
        {"id": student_id},
        {"_id": 0},
    )

    if not student:
        raise HTTPException(
            status_code=404,
            detail="Student not found",
        )

    return student


@router.post(
    "/",
    status_code=status.HTTP_201_CREATED,
    response_model=StudentResponse,
)
async def create_student(
    student: StudentCreate,
    students_collection=Depends(get_students_collection),
):
    existing_student = await students_collection.find_one({"id": student.id})

    if existing_student:
        raise HTTPException(
            status_code=400,
            detail="Student with this ID already exists",
        )

    new_student = student.model_dump()

    await students_collection.insert_one(new_student)

    return new_student


@router.put("/{student_id}", response_model=StudentResponse)
async def update_student(
    student_id: int,
    updated_student: StudentCreate,
    students_collection=Depends(get_students_collection),
):
    if student_id != updated_student.id:
        raise HTTPException(
            status_code=400,
            detail="Student ID in URL and body must match",
        )

    result = await students_collection.update_one(
        {"id": student_id},
        {"$set": updated_student.model_dump()},
    )

    if result.matched_count == 0:
        raise HTTPException(
            status_code=404,
            detail="Student not found",
        )

    student = await students_collection.find_one(
        {"id": student_id},
        {"_id": 0},
    )

    return student


@router.delete("/{student_id}", response_model=StudentResponse)
async def delete_student(
    student_id: int,
    students_collection=Depends(get_students_collection),
):
    student = await students_collection.find_one(
        {"id": student_id},
        {"_id": 0},
    )

    if not student:
        raise HTTPException(
            status_code=404,
            detail="Student not found",
        )

    await students_collection.delete_one({"id": student_id})

    return student
