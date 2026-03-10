import streamlit as st

main_page = st.Page("main_chatbot.py", title="Main Page", icon="💬")
widget_page = st.Page("widget_page.py", title="Widgets", icon="⚙")
pg = st.navigation([main_page, widget_page])

pg.run()