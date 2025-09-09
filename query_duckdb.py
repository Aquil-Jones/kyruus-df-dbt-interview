import duckdb
import pandas as pd

def query_duckdb():
    """
    Query the provider_address_agg table from DuckDB and return all rows.
    
    Returns:
        pandas.DataFrame: All rows from the provider_address_agg table
    """
    # Connect to the DuckDB database at the location specified in profiles.yml
    # read only to support multiple readers
    conn = duckdb.connect('/tmp/dev.duckdb', read_only=True)
    
    try:
        # Query the entire provider_address_agg table
        query = "SELECT * FROM provider_address_agg ORDER BY provider_id"
        result_df = conn.execute(query).fetchdf()
        
        # Print the results
        #print an informational header
        #print("Provider Address Aggregation Table:")
        #print("=" * 70)
        
        for index, row in result_df.iterrows():
            print(f"Provider ID: {row['provider_id']}")
            print(f"Addresses: {row['addresses']}")
            #add a line to make reading a bit easier on the command line
            #print("-" * 40)
        return result_df
        
    finally:
        # Close the connection
        conn.close()