import pytz
import iris
from datetime import datetime

''' Updates the appliance data if the widget is interacted with. '''
def update_sensitivity(iris_cursor: iris.IRISConnection, data: float):
    query = "Insert into BlackBox.WebsiteData (UpdateDateTime, Widget, ApplianceData, UpdateRole) values (?,?,?,?)"
    now = datetime.now(pytz.timezone("Europe/London")).strftime("%Y-%m-%d %H:%M:%S")
    params = [(now, 'SensitivitySlider', data, "User")]
    iris_cursor.executemany(query, params)

''' Updates the appliance data if the widget is interacted with. '''
def update_alert(iris_cursor: iris.IRISConnection, data: float):
    query = "Insert into BlackBox.WebsiteData (UpdateDateTime, Widget, ApplianceData, UpdateRole) values (?,?,?,?)"
    now = datetime.now(pytz.timezone("Europe/London")).strftime("%Y-%m-%d %H:%M:%S")
    params = [(now, 'Alert', data, "User")]
    iris_cursor.executemany(query, params)

''' Reads the appliance data. '''
def get_appliance_data(iris_cursor: iris.IRISConnection):
    widget_names = ["SensitivitySlider"]
    widget_data = {}
    for widget_name in widget_names:
        query = f"SELECT TOP 1 ApplianceData FROM BlackBox.WebsiteData WHERE Widget = '{widget_name}' ORDER BY UpdateDateTime DESC"
        iris_cursor.execute(query)
        result = iris_cursor.fetchall()
        if result:
            widget_data[widget_name] = float(result[0][0]) if widget_name == "SensitivitySlider" else int(result[0][0])
    return widget_data