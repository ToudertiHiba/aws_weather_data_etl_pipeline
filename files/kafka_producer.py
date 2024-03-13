
from kafka import KafkaProducer
import json

KAFKA_TOPIC = "weather"
KAFKA_BROKER = "localhost:9092"
def fetch_weather_data(API_KEY, API_URL, city_name):
    import requests
    response = requests.get(API_URL, params={"q": city_name}, headers={
                            "X-RapidAPI-Key": API_KEY})
    return response.json()


def main():
    with open('api_config.json') as f:
        config = json.load(f)
        API_KEY=config['API_KEY']
        API_URL=config['API_URL']
        
    # List of cities for which you want weather data
    cities = ["Paris", "London", "New York", "Tokyo", "Sydney"]
    producer = KafkaProducer(
        bootstrap_servers=KAFKA_BROKER,
        value_serializer=lambda v: json.dumps(v).encode("utf-8")
    )

    while True:
        for city in cities:
            weather_data = fetch_weather_data(API_KEY, API_URL, city)
            producer.send(KAFKA_TOPIC, value=weather_data)
            producer.flush()


if __name__ == "__main__":
    main()
