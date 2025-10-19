from fastapi import FastAPI, UploadFile, File

from agents.medicine_describer_agent import MedicineDescriberAgent

app = FastAPI()


@app.get("/")
async def root():
    return ""


@app.post("/api/medicine_description")
async def medicine_description(file: UploadFile = File(...)):
    print(f"file: {file}")
    print(f"filename: {file.filename}")
    description=await MedicineDescriberAgent().identify_and_describe_medicine(file,file.filename)
    return {"description": description}

