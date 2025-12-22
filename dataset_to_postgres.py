import pandas as pd
from sqlalchemy import create_engine

# define engine and point to sandbox database
engine = create_engine('postgresql://kellen@localhost:5432/sandbox')

# create dataframe
df = pd.read_csv()

# format columns
df.columns =[c.lower().replace(' ', '_')for c in df.columns]

# push to postgres
df.to_sql('table_name', engine, if_exists='replace', index=False)

print("Data successfully loaded into the 'table_name' table")