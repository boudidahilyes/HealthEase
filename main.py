from fastapi import FastAPI, UploadFile, File

from agents.medicine_describer_agent import MedicineDescriberAgent

app = FastAPI()


@app.get("/")
async def root():
    return ""


@app.get("/api/medicine_description")
async def say_hello(file: UploadFile = File(...)):
    description=MedicineDescriberAgent().identify_and_describe_medicine(file,file.filename)
    return {"description": description}

