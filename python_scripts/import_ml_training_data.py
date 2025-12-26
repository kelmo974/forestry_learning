
# # libraries for ingestion of ML training data
import os
import pandas as pd
from sqlalchemy import create_engine

# same engine code as the raw_data export 
db_endpoint = 'postgresql://kellen@localhost:5432/forestry_research'

# similar engine code as raw_data export
engine = create_engine(db_endpoint)

# get all data from the ml_training_data_dominant table in Postres
query = 'SELECT * FROM ml_ready.ml_training_data_dominant'

# using pandas to write query output into dataframe
df = pd.read_sql(query, engine)

# english recognition of import w/ record count
print(f"{len(df)} records have been successfully imported from Postgres.")


# additional logic to save ingested df as .csv to /data directory of this project
output_dir = './data'
if not os.path.exists(output_dir):
    os.mkdir(output_dir)

file_path = os.path.join(output_dir, 'ml_training_data_dominant.csv')
df.to_csv(file_path, index=False)

print("File was successfully written to subdirectory.")
