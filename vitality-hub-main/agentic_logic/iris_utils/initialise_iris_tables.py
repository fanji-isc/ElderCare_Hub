import os
import iris
import random
import requests
from dotenv import load_dotenv
from datetime import datetime, timedelta

load_dotenv()
args = {'hostname': os.getenv("IRIS_SQL_HOST"), 'port': int(os.getenv("IRIS_SQL_PORT")), 'namespace': os.getenv("IRIS_SQL_NAMESPACE"),
        'username': os.getenv("IRIS_SQL_USERNAME"), 'password': os.getenv("IRIS_SQL_PASSWORD")}
connection = iris.connect(**args)
iris_cursor = connection.cursor()

def create_new_table(schema_name: str, table_name: str, table_schema: str, schema_datatype: list[str]):
    """This function creates a table with the given definition. If the table already exists, it will be dropped before creating a new one.

    arguments:
    schema_name: The name of the schema where the table will be created.
    table_name: The name of the table to be created.
    table_schema: A string representing the schema of the table, with columns separated by commas.
    schema_datatype: A list of data types corresponding to each column in the schema.

    returns: None."""
    table_definition = "ID INT NOT NULL AUTO_INCREMENT"
    for i, column in enumerate(table_schema.split(", ")):
        table_definition += f", {column} {schema_datatype[i]}"
    
    try:
        iris_cursor.execute(f"DROP TABLE {schema_name}.{table_name}")
    except:
        pass

    iris_cursor.execute(f"CREATE TABLE {schema_name}.{table_name} ({table_definition})")

def agile_octopus_tariff(package_name: str, table_name: str, table_schema: str, schema_datatype: list[str]):
    '''This function pulls Agile Octopus October 2024 v1 tariff data and inserts it into the specified table.
    With Agile Octopus, you get access to half-hourly energy prices, tied to wholesale prices and updated daily. 
    The unit rate is capped at 100p/kWh (including VAT).
    Tariff codes go from A - P (excluding I and O), to represent different regions.

    arguments:
    package_name: The name of the package where the table will be created.
    table_name: The name of the table to be created.
    table_schema: A string representing the schema of the table, with columns separated by commas.
    schema_datatype: A list of data types corresponding to each column in the schema.

    returns: None.
    '''
    def get_time_range(hour):
        '''This function determines the time range (Morning, Afternoon, Evening, Night) based on the hour provided.

        arguments:
        hour: A 'HH' string representing the hour.

        returns: A string representing the time range.
        '''
        time_ranges = [('06', '12', 'Morning'), ('12', '18', 'Afternoon'), ('18', '24', 'Evening')]
        for start_hour, end_hour, time_range in time_ranges:
            if hour >= start_hour and hour < end_hour:
                return time_range
        return 'Night'
    
    def get_sample_usage(tariff_price, min_price, median_price, max_price):
        '''This function generates sample usage data for a given period based on its tariff price.

        arguments:
        tariff_price: The tariff price for the period.
        min_price: The minimum tariff price in the dataset.
        median_price: The median tariff price in the dataset.
        max_price: The maximum tariff price in the dataset.

        returns: A float representing the sample usage in kWh.
        '''
        if tariff_price < (median_price + min_price)/2:
            return round(random.uniform(0.8, 1.2), 4)
        elif tariff_price < median_price:
            return round(random.uniform(0.5, 0.8), 4)
        elif tariff_price < (max_price + median_price)/2:
            return round(random.uniform(0.3, 0.8), 4)
        else:
            return round(random.uniform(0.1, 0.3), 4)

    def add_tariff_data(tariff_results):
        '''This function adds tariff data with random sample usage data based on the tariff price.

        arguments:
        tariff_results: The tariff results from the API call, which includes valid_from, value_exc_vat, and payment_method.

        returns: A list of tuples containing valid_from_datetime, time_range, value_exc_vat, payment_method, and sample_usage.
        '''
        params = []
        sorted_prices = sorted(period['value_exc_vat'] for period in tariff_results)
        max_tariff_price = sorted_prices[-1]
        min_tariff_price = sorted_prices[0]
        median_tariff_price = sorted_prices[len(sorted_prices) // 2] if len(sorted_prices) % 2 == 1 else (sorted_prices[len(sorted_prices) // 2 - 1] + sorted_prices[len(sorted_prices) // 2])/2

        for period in tariff_results:
            valid_from_day, valid_from_time = period['valid_from'].rstrip('Z').split('T')
            valid_from_datetime = f"{valid_from_day} {valid_from_time}"
            
            time_range = get_time_range(valid_from_time.split(':')[0])
            sample_usage = get_sample_usage(period['value_exc_vat'], min_tariff_price, median_tariff_price, max_tariff_price)
            
            params.append((valid_from_datetime, time_range, period['value_exc_vat'], sample_usage))
        return params

    product_code = "AGILE-24-10-01"
    tariff_code = "E-1R-AGILE-24-10-01-C"
    elec_tariff_standard_unit = f"https://api.octopus.energy/v1/products/{product_code}/electricity-tariffs/{tariff_code}/standard-unit-rates/"

    create_new_table(package_name, table_name, table_schema, schema_datatype)
    sql_insert = f"Insert into {package_name}.{table_name} ({table_schema}) values ({','.join(['?'] * len(schema_datatype))})"
    tariff_list = requests.get(elec_tariff_standard_unit).json()

    while True:
        if "results" in tariff_list:
            params = add_tariff_data(tariff_list["results"])
            iris_cursor.executemany(sql_insert, params)
        next_url = tariff_list.get("next")
        if not next_url:
            break
        tariff_list = requests.get(next_url).json()

def elderly_appliance_dataset(start_date: datetime, end_date: datetime, 
    inpatient_periods: list[tuple[datetime, datetime]], anomaly_days: list[datetime], 
    package_name: str, table_name: str, seed: int = 42, export_ground_truth: bool = True
):
    """This function generates a synthetic dataset simulating the daily routines of an elderly individual living alone and
    using smart home appliances. The dataset schema includes timestamps, device types, ids, and states, state values, and power consumption.
    The device types include lights throughout the house and a kettle.
    
    arguments:
    start_date: The start date for the dataset generation.
    end_date: The non-inclusive end date for the dataset generation.
    seed: Seed for random number generation to ensure reproducibility.
    inpatient_periods: List of tuples indicating periods when the individual is hospitalized and thus no data is recorded.
    anomaly_days: List of days with anomalous behavior (e.g. late kettle use).
    package_name: The name of the package where the table will be created.
    table_name: The name of the table to be created.
    
    returns: None.
    """
    def next_health_state(prev) -> str:
        transition_states = {
            "healthy": ["healthy", "healthy", "fatigued"],
            "fatigued": ["healthy", "fatigued", "minor_illness"],
            "minor_illness": ["fatigued", "recovery"],
            "recovery": ["healthy", "fatigued"]
        }
        return random.choice(transition_states[prev])

    def brightness_to_watts(brightness: int, max_w: float = 9.5) -> float:
        """Convert brightness level (0-255) of the Philips Hue bulbs (A60 White and colour ambience E27 1100 bulbs) to power consumption in watts.
        """
        brightness_ranges = [(0, 127.5, 0.25), (127.5, 153, 0.36), (153, 178.5, 0.49), (178.5, 204, 0.64), (204, 229.5, 0.81), (229.5, 255, 1.0)]
        for low, high, multiplier in brightness_ranges:
            if low < brightness <= high:
                return round(max_w * multiplier, 2)
        return 0

    def get_day_context(current_date: datetime, inpatient_periods: list[tuple[datetime, datetime]], anomaly_days: list[datetime]) -> str:
        if any(start <= current_date <= end for start, end in inpatient_periods):
            return "hospital_inpatient"
        elif current_date in anomaly_days:
            return "anomaly"
        else:
            return random.choices(
                ["normal", "visitor"],
                weights=[0.8, 0.15]
            )[0]

    random.seed(seed)

    events = []
    ground_truth = []
    health_state = "healthy"
    forgetfulness = 0.2

    current_date = start_date

    while current_date < end_date:
        # Get behaviour context
        day_context = get_day_context(current_date, inpatient_periods, anomaly_days)

        if day_context == "hospital_inpatient":
            health_state = "recovery"
            forgetfulness = max(0.1, forgetfulness - 0.05)
            current_date += timedelta(days=1)
            continue

        health_state = next_health_state(health_state)
        forgetfulness += random.uniform(-0.05, 0.08)
        forgetfulness = min(max(forgetfulness, 0.0), 1.0)

        ground_truth.append([current_date, day_context, health_state, round(forgetfulness, 2)])

        # ----------------------------
        # Behaviour generation
        # ----------------------------

        # Bedroom light turns on when they wake up
        wake_minute_delay = {
            "healthy": 0,
            "fatigued": 15,
            "minor_illness": 30,
            "recovery": 5
        }[health_state]
        wake_time = current_date.replace(
            hour = 7 if 4 <= current_date.month <= 9 else 8,
            minute = random.randint(0, 30 + wake_minute_delay),
            second=random.randint(0, 59)
        )
        brightness_level = random.randint(90, 140)
        events.append([wake_time, "light", "light_bedroom", "on",
                       "brightness", brightness_level, "brightness level",
                       brightness_to_watts(brightness_level)])
        bedroom_light_on = True

        # Bathroom lights turn on after waking up
        morning_time = wake_time + timedelta(minutes=random.randint(3, 10), seconds=random.randint(0, 59))
        if random.random() < 0.1:
            morning_time += timedelta(hours=random.randint(1, 2))
        brightness_level = random.randint(120, 160)
        events.append([morning_time, "light", "light_bathroom", "on",
                        "brightness", brightness_level, "brightness level",
                        brightness_to_watts(brightness_level)])
        bathroom_light_on = True
    
        # Bathroom lights turn off after some time if they remember
        if random.random() > forgetfulness:
            morning_time += timedelta(minutes=random.randint(15, 30), seconds=random.randint(0, 59))
            events.append([morning_time, "light", "light_bathroom", "off",
                            "brightness", 0, "brightness level", 0])
            bathroom_light_on = False
        # Bedroom light turns off after some time if they remember
        if random.random() > forgetfulness:
            rand_minutes = random.randint(17, 35) if bathroom_light_on else random.randint(2,5)
            morning_time += timedelta(minutes=rand_minutes, seconds=random.randint(0, 59))
            events.append([morning_time, "light", "light_bedroom", "off",
                           "brightness", 0, "brightness level", 0])
            bedroom_light_on = False
        
        # Hallway light turns on when going to kitchen
        morning_time += timedelta(minutes=random.randint(1, 5), seconds=random.randint(0, 59))
        brightness_level = random.randint(80, 130)
        events.append([morning_time, "light", "light_hallway", "on",
                       "brightness", brightness_level, "brightness level",
                       brightness_to_watts(brightness_level)])
        hallway_light_on = True

        # Kitchen + kettle in the morning
        morning_time += timedelta(minutes=random.randint(1, 10), seconds=random.randint(0, 59))
        if random.random() < 0.15:
            morning_time += timedelta(hours=random.randint(1, 3))
        brightness_level = random.randint(150, 200)
        events.append([morning_time, "light", "light_kitchen", "on",
                        "brightness", brightness_level, "brightness level",
                        brightness_to_watts(brightness_level)])
        kitchen_light_on = True

        morning_time += timedelta(minutes=random.randint(1, 5), seconds=random.randint(0, 59))
        if random.random() < 0.1:
            morning_time += timedelta(hours=random.randint(0,1), minutes=random.randint(0,15))
        events.append([morning_time, "kettle", "kettle_01", "heating",
                        "temperature", 25, "degrees celsius", 1800])
        morning_time += timedelta(minutes=random.randint(4, 7), seconds=random.randint(0, 59))
        events.append([morning_time, "kettle", "kettle_01", "boiled",
                        "temperature", 100, "degrees celsius", 0])
        
        # Kitchen light turns off after some time if they remember
        if random.random() > forgetfulness:
            morning_time += timedelta(minutes=random.randint(16, 40), seconds=random.randint(0, 59))
            events.append([morning_time, "light", "light_kitchen", "off",
                           "brightness", 0, "brightness level", 0])
            kitchen_light_on = False
            
        # Resolve all on lights in the morning if they remember
        if bathroom_light_on and random.random() > forgetfulness:
            morning_time += timedelta(minutes=random.randint(10, 25), seconds=random.randint(0, 59))
            events.append([morning_time, "light", "light_bathroom", "off",
                            "brightness", 0, "brightness level", 0])
            bathroom_light_on = False
        if bedroom_light_on and random.random() > forgetfulness:
            morning_time += timedelta(minutes=random.randint(5, 15), seconds=random.randint(0, 59))
            events.append([morning_time, "light", "light_bedroom", "off",
                           "brightness", 0, "brightness level", 0])
            bedroom_light_on = False
        if hallway_light_on and random.random() > forgetfulness:
            morning_time += timedelta(minutes=random.randint(1, 12), seconds=random.randint(0, 59))
            events.append([morning_time, "light", "light_hallway", "off",
                           "brightness", 0, "brightness level", 0])
            hallway_light_on = False
        if kitchen_light_on and random.random() > forgetfulness:
            morning_time += timedelta(minutes=random.randint(4, 16), seconds=random.randint(0, 59))
            events.append([morning_time, "light", "light_kitchen", "off",
                           "brightness", 0, "brightness level", 0])
            kitchen_light_on = False

        afternoon_time = morning_time
        while afternoon_time <= morning_time:
            afternoon_time = current_date.replace(
                hour=random.randint(13, 15),
                minute=random.randint(0, 59),
                second=random.randint(0, 59)
            )
        
        # Afternoon kettle (health dependent)
        if (health_state in ["healthy", "fatigued"] and random.random() > 0.2) or (health_state in ["minor_illness", "recovery"] and random.random() > 0.7):
            if not kitchen_light_on:
                brightness_level = random.randint(150, 200)
                events.append([afternoon_time, "light", "light_kitchen", "on",
                               "brightness", brightness_level, "brightness level",
                               brightness_to_watts(brightness_level)])
                kitchen_light_on = True
                afternoon_time += timedelta(minutes=random.randint(1,5), seconds=random.randint(0,59))
            events.append([afternoon_time, "kettle", "kettle_01", "heating",
                           "temperature", 25, "degrees celsius", 1800])
            afternoon_time += timedelta(minutes=random.randint(3,6), seconds=random.randint(0, 59))
            events.append([afternoon_time,
                           "kettle", "kettle_01", "boiled",
                           "temperature", 100, "degrees celsius", 0])
            # Kitchen light turns off after some time if they remember
            if random.random() > forgetfulness:
                afternoon_time += timedelta(minutes=random.randint(12, 38), seconds=random.randint(0, 59))
                events.append([afternoon_time, "light", "light_kitchen", "off",
                               "brightness", 0, "brightness level", 0])
                kitchen_light_on = False

        # Afternoon living room usage is seasonal dependent
        if ((1 <= current_date.month <= 3 or current_date.month == 12) and random.random() > 0.2) or (random.random() > 0.4):
            afternoon_time += timedelta(minutes=random.randint(30, 120), seconds=random.randint(0, 59))
            brightness_level = random.randint(100, 150)
            events.append([afternoon_time, "light", "light_living_room", "on",
                            "brightness", brightness_level, "brightness level",
                            brightness_to_watts(brightness_level)])
            living_room_on = True
            if random.random() > forgetfulness:
                rand_minutes = timedelta(minutes=random.randint(60, 180), seconds=random.randint(0, 59))
                events.append([afternoon_time + rand_minutes, "light", "light_living_room", "off",
                               "brightness", 0, "brightness level", 0])
                living_room_on = False
        
        if random.random() > 0.3:
            afternoon_time += timedelta(minutes=random.randint(40, 80), seconds=random.randint(0, 59))
            brightness_level = random.randint(120, 160)
            if not bathroom_light_on:
                events.append([afternoon_time, "light", "light_bathroom", "on",
                                "brightness", brightness_level, "brightness level",
                                brightness_to_watts(brightness_level)])
            bathroom_light_on = True
            if random.random() > forgetfulness:
                rand_minutes = timedelta(minutes=random.randint(15, 30), seconds=random.randint(0, 59))
                events.append([afternoon_time + rand_minutes, "light", "light_bathroom", "off",
                               "brightness", 0, "brightness level", 0])
                bathroom_light_on = False

        if bathroom_light_on and random.random() > forgetfulness:
            afternoon_time += timedelta(minutes=random.randint(10, 25), seconds=random.randint(0, 59))
            events.append([afternoon_time, "light", "light_bathroom", "off",
                            "brightness", 0, "brightness level", 0])
            bathroom_light_on = False
        if bedroom_light_on and random.random() > forgetfulness:
            afternoon_time += timedelta(minutes=random.randint(5, 15), seconds=random.randint(0, 59))
            events.append([afternoon_time, "light", "light_bedroom", "off",
                           "brightness", 0, "brightness level", 0])
            bedroom_light_on = False
        if hallway_light_on and random.random() > forgetfulness:
            afternoon_time += timedelta(minutes=random.randint(1, 12), seconds=random.randint(0, 59))
            events.append([afternoon_time, "light", "light_hallway", "off",
                           "brightness", 0, "brightness level", 0])
            hallway_light_on = False
        if kitchen_light_on and random.random() > forgetfulness:
            afternoon_time += timedelta(minutes=random.randint(4, 16), seconds=random.randint(0, 59))
            events.append([afternoon_time, "light", "light_kitchen", "off",
                           "brightness", 0, "brightness level", 0])
            kitchen_light_on = False
        if living_room_on and random.random() > forgetfulness:
            afternoon_time += timedelta(minutes=random.randint(60, 180), seconds=random.randint(0, 59))
            events.append([afternoon_time, "light", "light_living_room", "off",
                           "brightness", 0, "brightness level", 0])
            living_room_on = False

        # Evening routine
        evening_time = afternoon_time
        while evening_time <= afternoon_time:
            evening_time = current_date.replace(
                hour=random.randint(17, 20),
                minute=random.randint(0, 59),
                second=random.randint(0, 59)
            )

        # Kitchen light for dinner preparation
        brightness_level = random.randint(150, 200)
        if not kitchen_light_on:
            events.append([evening_time, "light", "light_kitchen", "on",
                            "brightness", brightness_level, "brightness level",
                            brightness_to_watts(brightness_level)])
        kitchen_light_on = True
        if random.random() > forgetfulness:
            evening_time += timedelta(minutes=random.randint(30, 55), seconds=random.randint(0, 59))
            events.append([evening_time, "light", "light_kitchen", "off",
                           "brightness", 0, "brightness level", 0])
            kitchen_light_on = False
        
        # Bathroom light for evening routine
        brightness_level = random.randint(120, 160)
        evening_time += timedelta(minutes=random.randint(20, 45), seconds=random.randint(0, 59))
        if not bathroom_light_on:
            events.append([evening_time, "light", "light_bathroom", "on",
                            "brightness", brightness_level, "brightness level",
                            brightness_to_watts(brightness_level)])
        bathroom_light_on = True
        if random.random() > forgetfulness:
            evening_time += timedelta(minutes=random.randint(15, 30), seconds=random.randint(0, 59))
            events.append([evening_time, "light", "light_bathroom", "off",
                           "brightness", 0, "brightness level", 0])
            bathroom_light_on = False
        
        # Living room light for evening relaxation
        if random.random() > 0.2:
            brightness_level = random.randint(120, 180)
            if not living_room_on:
                events.append([evening_time, "light", "light_living_room", "on",
                                "brightness", brightness_level, "brightness level",
                                brightness_to_watts(brightness_level)])
            living_room_on = True
            if random.random() > forgetfulness:
                events.append([evening_time + timedelta(minutes=random.randint(60, 180), seconds=random.randint(0, 59)),
                               "light", "light_living_room", "off",
                               "brightness", 0, "brightness level", 0])
                living_room_on = False
        
        # Final lights off before bed
        night_time = evening_time
        while night_time <= evening_time:
            night_time = current_date.replace(
                hour=random.randint(21, 22),
                minute=random.randint(0, 59),
                second=random.randint(0, 59)
            )

        if kitchen_light_on:
            night_time += timedelta(minutes=random.randint(4, 16), seconds=random.randint(0, 59))
            events.append([night_time, "light", "light_kitchen", "off",
                           "brightness", 0, "brightness level", 0])
            kitchen_light_on = False
        if living_room_on:
            night_time += timedelta(minutes=random.randint(60, 180), seconds=random.randint(0, 59))
            events.append([night_time, "light", "light_living_room", "off",
                           "brightness", 0, "brightness level", 0])
            living_room_on = False
        if hallway_light_on:
            night_time += timedelta(minutes=random.randint(1, 12), seconds=random.randint(0, 59))
            events.append([night_time, "light", "light_hallway", "off",
                           "brightness", 0, "brightness level", 0])
            hallway_light_on = False
        if bathroom_light_on:
            night_time += timedelta(minutes=random.randint(10, 25), seconds=random.randint(0, 59))
            events.append([night_time, "light", "light_bathroom", "off",
                            "brightness", 0, "brightness level", 0])
            bathroom_light_on = False
        if bedroom_light_on:
            night_time += timedelta(minutes=random.randint(5, 15), seconds=random.randint(0, 59))
            events.append([night_time, "light", "light_bedroom", "off",
                           "brightness", 0, "brightness level", 0])
            bedroom_light_on = False

        current_date += timedelta(days=1)
    
    table_schema = "Timestamp, DeviceType, DeviceID, State, Metric, Value, Unit, PowerW"
    schema_datatypes = ["DATETIME", "VARCHAR(50)", "VARCHAR(50)", "VARCHAR(20)", "VARCHAR(50)", "DECIMAL(10,2)", "VARCHAR(20)", "DECIMAL(10,2)"]
    create_new_table(package_name, table_name, table_schema, schema_datatypes)
    sql_insert = f"Insert into {package_name}.{table_name} ({table_schema}) values ({','.join(['?'] * len(schema_datatypes))})"
    iris_cursor.executemany(sql_insert, [(row[0], row[1], row[2], row[3], row[4], row[5], row[6], row[7]) for row in events])
        
    if export_ground_truth:
        GroundTruth_schema = "Timestamp, DayContext, HealthState, Forgetfulness"
        GroundTruth_datatypes = ["DATETIME", "VARCHAR(50)", "VARCHAR(20)", "DECIMAL(3,2)"]
        create_new_table(package_name, "GroundTruth", GroundTruth_schema, GroundTruth_datatypes)
        sql_insert = f"Insert into {package_name}.GroundTruth ({GroundTruth_schema}) values ({','.join(['?'] * len(GroundTruth_datatypes))})"
        iris_cursor.executemany(sql_insert, [(row[0], row[1], row[2], row[3]) for row in ground_truth])

def main():
    # Populate OctopusSample.SampleData table
    SampleData_schema = "ValidFromDateTime, TimeRange, ValueExcludingVAT, SampleUsage"
    SampleData_datatypes = ["DATETIME", "VARCHAR(256)", "DECIMAL(4, 2)", "DECIMAL(5, 4)"]
    agile_octopus_tariff("OctopusSample", "SampleData", SampleData_schema, SampleData_datatypes)
    # Populate BlackBox.ApplianceData table (and GroundTruth)
    beginning_date = datetime(2025, 1, 1)
    end_date = datetime(2026, 4, 22)
    inpatient_periods=[(datetime(2025, 12, 8), datetime(2025, 12, 13))]
    anomaly_days=[datetime(2025, 3, 16), datetime(2026, 4, 21)]
    elderly_appliance_dataset(beginning_date, end_date, inpatient_periods, anomaly_days, "BlackBox", "ApplianceData")
    # Initialise BlackBox.WebsiteData table
    create_new_table("BlackBox", "WebsiteData", "UpdateDateTime, Widget, ApplianceData, UpdateRole", ["DATETIME", "VARCHAR(50)", "DECIMAL(3,2)", "VARCHAR(10)"])
    # Initialise Chatbot.History
    create_new_table("Chatbot", "History", "SessionID, MessageRole, MessageContent, Timestamp", ["INT", "VARCHAR(10)", "VARCHAR(255)", "DATETIME"])

if __name__ == "__main__":
    main()