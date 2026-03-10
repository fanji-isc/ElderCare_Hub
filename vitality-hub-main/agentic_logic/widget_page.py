import os
import iris
import time
import streamlit as st
from dotenv import load_dotenv
from widget_functions import update_sensitivity, update_alert, get_appliance_data

# Load environment variables
load_dotenv()
args = {'hostname': os.getenv("IRIS_SQL_HOST"), 'port': int(os.getenv("IRIS_SQL_PORT")), 'namespace': os.getenv("IRIS_SQL_NAMESPACE"),
        'username': os.getenv("IRIS_SQL_USERNAME"), 'password': os.getenv("IRIS_SQL_PASSWORD")}
LOG_FILE_PATH = os.path.join(os.path.dirname(__file__), "fall_detection", "fall_detection_output.txt")

def main():
    st.set_page_config(page_title="Controls", page_icon="⚙", layout="centered")
    st.title("Controls")

    # Connect to IRIS
    try:
        connection = iris.connect(**args)
        cursor = connection.cursor()
    except Exception as e:
        st.error(f"Error: {e}")
        return
    
    # Retrieve current appliance data for the widget displays
    data_dict = get_appliance_data(cursor)

    # Make sure the slider reflects the latest sensitivity data from the BlackBox database
    sensitivity = data_dict.get("SensitivitySlider", 0.5)
    st.slider('Sensitivity Slider', min_value=0.0, max_value=1.0, value=sensitivity, step=0.01, key='SensitivitySlider', on_change=lambda: update_sensitivity(cursor, st.session_state['SensitivitySlider']))
    
    # Button to simulate an alert input
    st.markdown("<br>", unsafe_allow_html=True)
    col1, col2, col3 = st.columns([1, 4, 5])
    with col1:
        # Input box for alert value to be added to the database
        number = st.text_input(
            label="alert_value",
            label_visibility="collapsed",
            placeholder="0.00"
        )
    with col2:
        button_clicked = st.button('Simulate Alert Input', icon="🚨")
    with col3:
        message_placeholder = st.empty()
    
    if button_clicked:
        update_alert(cursor, float(number))
        message_placeholder.info("Alert sent!")
        time.sleep(3)
        message_placeholder.empty()

    st.markdown("<br>", unsafe_allow_html=True)
    st.markdown("<br>", unsafe_allow_html=True)
    st.markdown("<br>", unsafe_allow_html=True)
    st.markdown("<br>", unsafe_allow_html=True)
    st.subheader("Agent Control")

    # Initialize session state for the log content
    if 'log_content' not in st.session_state:
        st.session_state['log_content'] = "Log file not found. Deploy the agent to create logs."
    if 'agent_process' not in st.session_state:
        st.session_state['agent_process'] = False

    def read_and_update_logs():
        """Reads the log file and updates the session state log_content variable."""
        try:
            if os.path.exists(LOG_FILE_PATH):
                with open(LOG_FILE_PATH, "r") as f:
                    st.session_state['log_content'] = f.read()
            else:
                st.session_state['log_content'] = "Log file not found. Deploy the agent to create logs."
        except Exception as e:
            st.session_state['log_content'] = f"Error reading log file: {e}"

    # Agent control buttons
    col1, col2 = st.columns(2)
    with col1:
        if st.button('Deploy Appliance Agent', use_container_width=True, icon="🚀"):
            if not st.session_state['agent_process']:
                try:
                    with open(LOG_FILE_PATH, "w", encoding="utf-8") as f:
                        f.write("")
                        f.close()
                except Exception as e:
                    st.error(f"Error wiping log file: {e}")
                st.session_state['agent_process'] = True
                st.rerun()
            else:
                st.info("Agent is already running! Cannot deploy twice.")
    with col2:
        if st.button('Terminate Appliance Agent', use_container_width=True, icon="💀"):
            if st.session_state['agent_process']:
                st.session_state['agent_process'] = False
                st.rerun()
            else:
                st.info("No agent to terminate.")
    
    col1, col2 = st.columns(2)
    with col1:
        if st.button('[TBD: Deploy Wellbeing Agent]', use_container_width=True, icon="🚀"):
            st.info("Wellbeing Agent deployment not yet implemented.")
    with col2:
        if st.button('[TBD: Terminate Wellbeing Agent]', use_container_width=True, icon="💀"):
            st.info("No agent to terminate.")
    
    # Display log output if the agent is running
    if st.session_state['agent_process']:
        st.markdown("---")
        col1, col2 = st.columns([3,1])
        with col1:
            st.markdown("##### Appliance Agent Live Logs")
        with col2:
            st.button("Refresh Logs", key = "refresh_logs_button", icon="🔄", on_click=read_and_update_logs)
    
        read_and_update_logs()
        st.text_area(
            "Log Output", 
            value=st.session_state['log_content'], 
            height=300, 
            disabled=True,
            label_visibility="collapsed"
        )

if __name__ == "__main__":
    main()