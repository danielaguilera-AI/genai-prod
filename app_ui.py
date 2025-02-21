import gradio as gr
import subprocess
from urllib.parse import quote  # Import the quote function for URL encoding

# API endpoint
API_URL = "https://5yyejnhh7h.execute-api.us-east-1.amazonaws.com/prod/generate"

def chat_with_llm(user_input, history):
    # Construct the prompt by including the conversation history
    prompt = ""
    for message in history[10:]:
        if message['role'] == 'user':
            prompt += f"\nUser: {message['content']}\n"
        else:
            prompt += f"\nAssistant: {message['content']}\n"
    prompt += f"User: {user_input}\nAssistant:"

    # URL-encode the prompt to handle spaces and special characters
    encoded_prompt = quote(prompt)

    try:
        # Construct the full URL with the encoded prompt
        full_url = f"{API_URL}?prompt={encoded_prompt}"

        # Use curl command to call the API
        curl_command = ["curl", "-X", "GET", full_url]
        result = subprocess.run(curl_command, capture_output=True, text=True)

        if result.returncode == 0:
            response = result.stdout.strip()
        else:
            response = f"Error: {result.stderr}"
    except Exception as e:
        response = f"Request failed: {e}"

    return response

# Gradio UI
chatbot = gr.ChatInterface(fn=chat_with_llm, type="messages", title="Chat with LLM")
chatbot.launch(share=True)







