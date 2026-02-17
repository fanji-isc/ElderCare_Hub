import os
import sys
import iris
import pytz
import asyncio
import streamlit as st
from dotenv import load_dotenv
from datetime import datetime, timedelta
from agents import Agent, Runner
from agents import set_default_openai_key, set_tracing_disabled
from agents.extensions.memory import AdvancedSQLiteSession
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from iris_utils.sql_context import get_schemas_metadata

intersystems_logo = "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d2/InterSystems_logo_%282016%29.svg/2560px-InterSystems_logo_%282016%29.svg.png"
icon = "https://logosandtypes.com/wp-content/uploads/2020/07/intersystems.svg"

load_dotenv()
set_default_openai_key(os.getenv("OPENAI_API_KEY"))
set_tracing_disabled(True)
args = {'hostname': os.getenv("IRIS_SQL_HOST"), 'port': int(os.getenv("IRIS_SQL_PORT")), 'namespace': os.getenv("IRIS_SQL_NAMESPACE"),
        'username': os.getenv("IRIS_SQL_USERNAME"), 'password': os.getenv("IRIS_SQL_PASSWORD")}
connection = iris.connect(**args)
iris_cursor = connection.cursor()

def _read_description_file(file_name: str) -> str:
    messaging_path = os.path.join(os.path.dirname(__file__), "agent_messages", file_name)
    file = open(messaging_path, "r")
    content = file.read()
    file.close()
    return content

wellbeing_schemas = get_schemas_metadata(schema_list=os.getenv("WELLBEING_SCHEMA").split(","))
wellbeing_desc = _read_description_file("wellbeing.txt") + f"\nThe database schema has been extracted as follows: {wellbeing_schemas}"

session = AdvancedSQLiteSession(
    session_id="chatbot_history",
    create_tables=True,
)

def start_session() -> str:
    """This function starts a new session in the Chatbot.History table in IRIS if there is not an active session (i.e., the last message role is "system"). If the table is empty, it starts with session ID 1. 

    returns: The current session ID."""
    iris_cursor.execute("SELECT MAX(SessionID) FROM Chatbot.History")
    result = iris_cursor.fetchone()
    if result and result[0]:
        latest_session_id = result[0]
        iris_cursor.execute(f"SELECT TOP 1 MessageRole FROM Chatbot.History WHERE SessionID = {latest_session_id} ORDER BY Timestamp DESC")
        result = iris_cursor.fetchone()
        if result and result[0] == "system":
            return str(latest_session_id)
        new_session_id = latest_session_id + 1
        iris_cursor.execute(
            "INSERT INTO Chatbot.History (SessionID, MessageRole, MessageContent, Timestamp) VALUES (?, ?, ?, ?)",
            (new_session_id, "system", "New session started.", datetime.now(pytz.timezone("Europe/London")).strftime("%Y-%m-%d %H:%M:%S"))
        )
        connection.commit()
        return str(new_session_id)
    else:
        iris_cursor.execute(
            "INSERT INTO Chatbot.History (SessionID, MessageRole, MessageContent, Timestamp) VALUES (?, ?, ?, ?)",
            (1, "system", "New session started.", datetime.now(pytz.timezone("Europe/London")).strftime("%Y-%m-%d %H:%M:%S"))
        ) 
        return "1"

def get_history(session_id: str) -> list:
    """This function retrieves the chat history for a given session from the Chatbot.History table in IRIS.

    arguments:
    session_id: The session ID for which to retrieve the chat history.

    returns: A list of dictionaries containing the message role and content."""
    iris_cursor.execute("SELECT MessageRole, MessageContent FROM Chatbot.History WHERE SessionID = ?", (session_id,))
    rows = iris_cursor.fetchall()
    if rows: return [{"role": row[0], "content": row[1]} for row in rows]
    return []

def store_result_in_iris(result):
    """This function stores the chat result in the Chatbot.History table in IRIS.
    
    arguments:
    result: The result object containing the input and final output from the agent.
    """
    try:
        now = datetime.now(pytz.timezone("Europe/London")).strftime("%Y-%m-%d %H:%M:%S")
        iris_cursor.executemany("""
            INSERT INTO Chatbot.History (SessionID, MessageRole, MessageContent, Timestamp)
            VALUES (?, ?, ?, ?)
        """, [(st.session_state.session_id, "user", result.input[0].get("content"), now), 
              (st.session_state.session_id, "assistant", result.final_output, now)])
        connection.commit()
    except Exception as e:
        print(f"Error storing result in IRIS: {e}")

async def get_response(prompt: str) -> str:
    """This function routes the user prompt to the wellbeing agent.

    arguments:
    prompt: A string containing the user prompt from the chatbot interface.
    
    returns: The final output from the wellbeing agent."""
    wellbeing_agent = Agent(
        name="Wellbeing Agent",
        instructions=wellbeing_desc,
        tools=[],
    )
    result = await Runner.run(
        wellbeing_agent,
        prompt,
        session=session,
    )
    await session.store_run_usage(result)
    store_result_in_iris(result)
    st.session_state.history = get_history(st.session_state.session_id)
    return result.final_output

# Start the UI
st.set_page_config(page_title="IRIS chatbot", page_icon="💬", layout="centered")
st.title("IRIS chatbot")
st.logo(intersystems_logo, size = "large")

if "history" not in st.session_state or "session_id" not in st.session_state:
    st.session_state.history = []
    st.session_state.session_id = start_session()

st.session_state.history = get_history(st.session_state.session_id)

for message in st.session_state.history:
    if message["role"] == "user":
        with st.chat_message(message["role"]):
            st.markdown(message["content"])
    elif message['role'] != "system":
        with st.chat_message(message["role"], avatar = icon):
            st.markdown(message["content"])

if prompt := st.chat_input("How can I help?"):
    try:
        with st.chat_message("user"):
            st.markdown(prompt)

        with st.spinner("Routing question to wellbeing agent..."):
            final = asyncio.run(get_response(prompt))
        if not final:
            final = "Your query requests information that I cannot currently provide. Please try again."
        with st.chat_message("assistant", avatar = icon):
            st.markdown(final)
        
    except Exception as e:
        with st.chat_message("assistant", avatar = icon):
            final = f"There has been an error '{e}' with your query. Please wait 20s and then try again."
            st.markdown(final)
        store_result_in_iris({"input": [{"content": prompt}], "final_output": final})

# Refresh the app to show the new messages in the chat history every 15 seconds
if "last_refresh" not in st.session_state:
    st.session_state.last_refresh = datetime.now()

while True:
    if datetime.now() - st.session_state.last_refresh >= timedelta(seconds=15):
        break
print("Refreshing the app to show new messages...")
st.session_state.last_refresh = datetime.now()
st.rerun()