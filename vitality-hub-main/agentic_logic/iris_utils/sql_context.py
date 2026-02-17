import os
import iris
from dotenv import load_dotenv

load_dotenv()
IRIS_SQL_SCHEMA_LIST = os.getenv("IRIS_SQL_SCHEMA_LIST").split(",")
args = {'hostname': str(os.getenv("IRIS_SQL_HOST")), 'port': int(os.getenv("IRIS_SQL_PORT")), 'namespace': os.getenv("IRIS_SQL_NAMESPACE"),
		'username': os.getenv("IRIS_SQL_USERNAME"), 'password': os.getenv("IRIS_SQL_PASSWORD")}

def get_schemas_metadata(iris_args: dict = args, schema_list: list = IRIS_SQL_SCHEMA_LIST, row_number: int = 2):
	"""Returns the metadata of the provided schemas (tables, columns, PK, FK, and sample rows)."""
	connection = iris.connect(**iris_args)
	iris_cursor = connection.cursor()
	meta = {}

	for schema in schema_list:
		iris_cursor.execute("SELECT Table_Name FROM INFORMATION_SCHEMA.TABLES WHERE Table_Schema = ?", (schema,))
		tables = iris_cursor.fetchall()
		for table in tables:
			table = table[0]
			full_name = f"{schema}.{table}" if schema else table
			iris_cursor.execute("""
				SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE 
				FROM INFORMATION_SCHEMA.COLUMNS 
				WHERE TABLE_NAME=:t AND TABLE_SCHEMA=:s
			""", {"t": table, "s": schema})
			columns = iris_cursor.fetchall()

			iris_cursor.execute(f"""
				SELECT kcu.COLUMN_NAME
				FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
				JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu
				ON tc.CONSTRAINT_NAME=kcu.CONSTRAINT_NAME
				AND tc.TABLE_NAME=kcu.TABLE_NAME
				WHERE tc.CONSTRAINT_TYPE='PRIMARY KEY'
				AND tc.TABLE_NAME=:t
				AND (tc.TABLE_SCHEMA=:s)
			""", {"t": table, "s": schema})
			primary_keys = iris_cursor.fetchall()

			iris_cursor.execute(f"""
				SELECT COLUMN_NAME, REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME
				FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
				WHERE TABLE_NAME=:t
				AND REFERENCED_TABLE_NAME IS NOT NULL
				AND (TABLE_SCHEMA=:s)
			""", {"t": table, "s": schema})
			foreign_keys = iris_cursor.fetchall()

			try:
				iris_cursor.execute(f"SELECT TOP {row_number} * FROM {full_name}")
				sample_rows = iris_cursor.fetchall()
			except Exception as e:
				print(f"Error fetching sample rows for {full_name}: {e}")
				sample_rows = []

			meta[full_name] = {
				"columns": [dict(name=c[0], type=c[1], nullable=(c[2]=="YES")) for c in columns],
				"primary_key": [p[0] for p in primary_keys],
				"foreign_keys": [{"column": f[0], "ref_table": f[1], "ref_column": f[2]} for f in foreign_keys],
				"row_samples": sample_rows
			}
	return meta