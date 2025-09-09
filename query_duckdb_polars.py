import duckdb
import polars as pl

def query_duckdb_polars():
    """
    Query the provider_address_agg table from DuckDB and return all rows.
    Returns a polars DataFrame that is more suitable for larger datasets if you want to do more processing in python.
    
    Returns:
        polars.DataFrame: All rows from the provider_address_agg table
    """
    # Connect to the DuckDB database at the location specified in profiles.yml
    # read only to support multiple readers
    conn = duckdb.connect('/tmp/dev.duckdb', read_only=True)
    
    try:
        # Query the entire provider_address_agg table
        query = "SELECT * FROM provider_address_agg ORDER BY provider_id"
        result = conn.execute(query).pl()
        
        # Print the results
        #print("Provider Address Aggregation Table:")
        #print("=" * 70)
        
        #iter_rows instead of iterrows for polars
        for row in result.iter_rows(named=True):
            print(f"Provider ID: {row['provider_id']}")
            print(f"Addresses: {row['addresses']}")
            #add a line to make reading a bit easier on the command line
            #print("-" * 40)
        return result
        
    finally:
        # Close the connection
        conn.close()