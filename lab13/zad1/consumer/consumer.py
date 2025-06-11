import os
import pika
import json
import time

RABBITMQ_HOST = os.getenv('RABBITMQ_HOST', 'rabbitmq')
RABBITMQ_EXCHANGE = 'call_center_exchange'
QUEUE_NAME = os.getenv('QUEUE_NAME', 'kredyty_hipoteczne') 
def callback(ch, method, properties, body):
    message = json.loads(body)
    print(f"[{QUEUE_NAME}] Received contact request for clientID: {message['clientID']}")
    time.sleep(1)
    print(f"[{QUEUE_NAME}] Finished processing for clientID: {message['clientID']}")
    ch.basic_ack(delivery_tag=method.delivery_tag)

def start_consumer():
    while True:
        try:
            credentials = pika.PlainCredentials('user', 'password')
            parameters = pika.ConnectionParameters(RABBITMQ_HOST, credentials=credentials)
            connection = pika.BlockingConnection(parameters)
            channel = connection.channel()
            channel.exchange_declare(exchange=RABBITMQ_EXCHANGE, exchange_type='direct', durable=True)
            channel.queue_declare(queue=QUEUE_NAME, durable=True)
            channel.queue_bind(exchange=RABBITMQ_EXCHANGE, queue=QUEUE_NAME, routing_key=QUEUE_NAME)

            print(f'[*] Consumer for {QUEUE_NAME} waiting for messages. To exit press CTRL+C')
            channel.basic_qos(prefetch_count=1) 
            channel.basic_consume(queue=QUEUE_NAME, on_message_callback=callback)

            channel.start_consuming()
        except pika.exceptions.AMQPConnectionError as e:
            print(f"Connection to RabbitMQ failed: {e}. Retrying in 5 seconds...")
            time.sleep(5)
        except Exception as e:
            print(f"An unexpected error occurred: {e}. Retrying in 5 seconds...")
            time.sleep(5)

if __name__ == '__main__':
    start_consumer()
