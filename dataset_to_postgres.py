import pandas as pd
from sqlalchemy import create_engine

# define engine and point to sandbox database
# ensure correct alignment of db username and password
engine = create_engine('postgresql://kellen@localhost:5432/forestry_research')

# clean columns prior to load
# makes all column names lowercase and replaces any ' ' with '_'
def clean_columns(df):
    df.columns = df.columns.str.lower().str.replace(' ', '_', regex=False)
    return df

# create dataframe by reading chunks by 1000 rows
def load_csv_to_raw(file_name, table_name):
    print(f"reading {file_name}...") 

    is_first_chunk = True
    # df_chunk = pd.read_csv(file_name, nrows=1000)

    print(f"Pushing {table_name} to raw_data schema...")

    for chunk in pd.read_csv(file_name, chunksize=10000):
        chunk = clean_columns(chunk)
        print(f"{table_name} columns headers have been cleaned and formatted")
        mode = 'replace' if is_first_chunk else 'append'
        chunk.to_sql(table_name, engine, schema='raw_data', if_exists=mode, index=False)
        is_first_chunk=False

    print(f"{table_name} has been fully loaded.")

if __name__ == "__main__":
    load_csv_to_raw('data/TN_COND.csv', 'tn_cond')
    load_csv_to_raw('data/TN_PLOT.csv', 'tn_plot')

    # ran into syntax errors on multiple columns in the tn_tree data. forcing SQL ingestion so that all three tables arrive in DB
    # early version, performed cleaning in SQL
    # this version, can avoid a lot of the SQL syntax issues with the above column cleaning function
    print("Approaching TN_TREE table...")

    is_first_tree_chunk = True
    for chunk in pd.read_csv('data/TN_TREE.csv', chunksize=10000, low_memory=False, dtype=str):
        chunk = clean_columns(chunk) # cleaning columns for this table too

        mode = 'replace' if is_first_tree_chunk else 'append'
        chunk.to_sql('tn_tree', engine, schema='raw_data', if_exists=mode, index=False)
        is_first_tree_chunk = False
            
    print("All tabular data is in Postgres!")
