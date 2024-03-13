import streamlit as st
import pandas as pd
import plotly.express as px
from cassandra.cluster import Cluster
import sys

def main():
    # Get the Cassandra IP address from command-line argument
    if len(sys.argv) > 1:
        print(sys.argv[1])
        cassandra_ip = sys.argv[1]
    else:
        cassandra_ip = '127.0.0.1'
    
    # Connect to the Cassandra cluster
    cluster = Cluster([cassandra_ip])
    session = cluster.connect()

    # Read data from Cassandra
    session.set_keyspace('weather_project')
    rows = session.execute('SELECT * FROM weather_data')

    # Convert the results into a pandas DataFrame
    df = pd.DataFrame(list(rows), columns=rows.column_names)

    # Convert the 'time' column to datetime objects
    df['localtime'] = pd.to_datetime(df['localtime'])

    # Create a table to display the data
    st.title('Data Visualization with Streamlit and Cassandra')

    # Display the first 10 rows of the DataFrame
    st.write('### Table')
    st.dataframe(df)


    # Create a dropdown menu to select cities
    city_selection = st.selectbox('Select city', df['cityname'].unique())

    # Create a radio button to select temperature or humidity
    temp_or_humidity = st.radio('Select data', ['Temperature', 'Humidity'])

    # Filter the dataframe based on the selected city and data type
    filtered_df = df[(df['cityname'] == city_selection)]

    # Sort the dataframe based on the 'time' column
    filtered_df = filtered_df.sort_values(by='localtime')

    # Create a line chart using Plotly
    fig = px.line(filtered_df, x='localtime', y=temp_or_humidity.lower(), title='Weather Data for {}'.format(city_selection))

    # Add hover text
    fig.update_layout(
        hoverlabel=dict(
        bgcolor="white",
        font_size=14,
        font_family="Rockwell"
        ),
        xaxis_title="Time",
        yaxis_title=temp_or_humidity
    )

    # Display the line chart
    st.plotly_chart(fig)

    # Stop the connection to Cassandra
    cluster.shutdown()
    
if __name__ == "__main__":
    main()