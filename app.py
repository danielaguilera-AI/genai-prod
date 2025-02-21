from fastapi import FastAPI, HTTPException
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

@app.get("/ping")
async def ping():
    return {"status": "ok"}

@app.get("/generate/")
async def generate_text(prompt: str) -> str:
    """Calls Claude 3.5 Haiku via AWS Bedrock to generate text."""
    try:
        payload = {
            "prompt": f"\n\nHuman: {prompt}\n\nAssistant:",
            "max_tokens": 1024,
            "temperature": 0.7,
            "top_p": 0.9
        }

        response = bedrock_client.invoke_model(
            modelId="anthropic.claude-3-5-haiku-20240611-v1:0",
            contentType="application/json",
            accept="application/json",
            body=json.dumps(payload)
        )

        response_body = response["body"].read().decode("utf-8")
        response_json = json.loads(response_body)

        # Extract the generated text from the response
        generated_text = response_json.get("completion", "No text generated.")

        return generated_text

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))



