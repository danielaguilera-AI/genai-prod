import streamlit as st
import requests

# API Gateway URL (Replace with your local FastAPI URL)
API_URL = "https://8amrgc0gw6.execute-api.us-east-1.amazonaws.com/prod/generate/"

# Streamlit Page Config
st.set_page_config(page_title="Chat with LLM", layout="wide")
st.title("🤖 AI Chatbot")

# Session state for chat history
if "messages" not in st.session_state:
    st.session_state["messages"] = []

# Display chat history
for message in st.session_state["messages"]:
    st.chat_message(message["role"]).write(message["content"])

# User input
user_input = st.chat_input("Ask me anything...")

if user_input:
    # Append user input
    st.session_state["messages"].append({"role": "user", "content": user_input})
    st.chat_message("user").write(user_input)

    # Call FastAPI
    params = {"prompt": user_input}
    response = requests.get(API_URL, params=params)

    if response.status_code == 200:
        ai_response = response.text
    else:
        ai_response = "Error: Could not get response from API."

    # Append LLM response
    st.session_state["messages"].append({"role": "assistant", "content": ai_response})
    st.chat_message("assistant").write(ai_response)
