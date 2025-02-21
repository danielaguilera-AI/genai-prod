from fastapi import FastAPI, File, UploadFile, HTTPException
from botocore.exceptions import NoCredentialsError
from fastapi.responses import HTMLResponse
import boto3
import os
import json
from dotenv import load_dotenv

# Load Environment variables
load_dotenv(".env", override=True)
AWS_REGION = "us-east-1"
AWS_ACCESS_KEY = os.getenv("AWS_ACCESS_KEY")
AWS_SECRET_KEY = os.getenv("AWS_SECRET_KEY")

app = FastAPI()

# Initialize AWS Bedrock Client
bedrock_client = boto3.client(
    "bedrock-runtime",
    region_name=AWS_REGION,
    aws_access_key_id=AWS_ACCESS_KEY,
    aws_secret_access_key=AWS_SECRET_KEY
)

s3_client = boto3.client(
    "s3",
    aws_access_key_id=AWS_ACCESS_KEY,
    aws_secret_access_key=AWS_SECRET_KEY,
    region_name=AWS_REGION
)

@app.get("/ping")
async def ping():
    return {"status": "ok"}


@app.get("/generate/", response_class=HTMLResponse)
async def generate_text(prompt: str) -> str:
    """Calls AWS Bedrock LLM to generate text."""
    try:
        payload = {
            "inputText": prompt,
            "textGenerationConfig": {
                "maxTokenCount": 3072,
                "temperature": 0.7,
                "topP": 0.9,
                "stopSequences": []
            }
        }

        response = bedrock_client.invoke_model(
            modelId="anthropic.claude-3-5-sonnet-20241022-v2:0",
            contentType="application/json",
            accept="application/json",
            body=json.dumps(payload)
        )

        response_body = response["body"].read().decode("utf-8")
        response_json = json.loads(response_body)

        # Extract the generated text from the response
        if "results" in response_json and len(response_json["results"]) > 0:
            generated_text = response_json["results"][0].get("outputText", "No text generated.")
        else:
            generated_text = "No text generated."

        return generated_text

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


