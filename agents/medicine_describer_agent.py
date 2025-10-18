import base64
import mimetypes
import time

from openai import OpenAI
from config import OPENROUTER_API_KEY
class MedicineDescriberAgent:
    def identify_and_describe_medicine(medecineImage,filename):
        file_bytes = medecineImage.read()
        img_base64 = base64.b64encode(file_bytes).decode("utf-8")
        mime_type, _ = mimetypes.guess_type(filename)
        if mime_type is None:
            mime_type = "application/octet-stream"  # fallback

        # Build data URI
        img_base64_uri = f"data:{mime_type};base64,{img_base64}"
        client = OpenAI(
            base_url="https://openrouter.ai/api/v1",
            api_key=OPENROUTER_API_KEY,
        )

        start_time = time.time()

        completion = client.chat.completions.create(
            model="openai/gpt-5-image-mini",
            messages=[
                {
                    "role": "user","content": [
                    {
                        "type": "text",
                        "text": "You are a medicine identification and description expert. "
                                "Examine the provided image carefully and provide a detailed, structured description of the medicine, including: "
                                "- Name of the medicine or supplement "
                                "- Purpose and typical usage "
                                "- Typical dosage "
                                "- Possible side effects and warnings "
                                "Format your answer in clear sections or bullet points. "
                                "Do not add extra suggestions or instructions at the end. "
                                "If the image does not show a medicine or you cannot identify it, politely state in one short sentence that you are unable to determine the medicine."
                    },
                    {
                        "type": "image_url",
                        "image_url": {
                            "url": img_base64_uri
                        }
                    }
                ]
                }
            ],
        )

        end_time = time.time()
        print("Execution time:", end_time - start_time)
        print(completion.choices[0].message.content)
        return completion.choices[0].message.content
