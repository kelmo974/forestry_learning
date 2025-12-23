import pandas as pd
from sqlalchemy import create_engine

# define engine and point to sandbox database
# ensure correct alignment of db username and password
engine = create_engine('postgresql://kellen@localhost:5432/forestry_research')

# create dataframe by reading chunks 1000 rows at a time
def load_csv_to_raw(file_name, table_name):
    print(f"reading {file_name}...") 

    df_chunk = pd.read_csv(file_name, nrows=1000)

    print(f"Pushing {table_name} to raw_data schema...")

    for chunk in pd.read_csv(file_name, chunksize=10000):
        chunk.to_sql(table_name, engine, schema='raw_data', if_exists='append', index=False)
    
    print(f"{table_name} has been fully loaded.")

if __name__ == "__main__":
    load_csv_to_raw('data/TN_COND.csv', 'tn_cond')
    load_csv_to_raw('data/TN_PLOT.csv', 'tn_plot')

    # ran into syntax errors on multiple columns in the tn_tree data. forcing SQL ingestion so that all three tables arrive in DB
    # from there, we can diagnose and cleanse. This is part of the bronze level, after all 
    print("Approaching TREE table...")

    first_chunk = True
    for chunk in pd.read_csv('data/TN_TREE.csv', chunksize=10000, low_memory=False, dtype=str):
        chunk.columns = [c.lower() for c in chunk.columns]
        if first_chunk:
            chunk.to_sql('tn_tree', engine, schema='raw_data', if_exists='replace', index=False)
            first_chunk = False
        else:
            chunk.to_sql('tn_tree', engine, schema='raw_data', if_exists='append', index=False)
            
    print("All tabular data is in Postgres!")
