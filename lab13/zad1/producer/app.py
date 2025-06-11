import os
import pika
import json
from flask import Flask, request, jsonify

app = Flask(__name__)

RABBITMQ_HOST = os.getenv('RABBITMQ_HOST', 'rabbitmq')
RABBITMQ_EXCHANGE = 'call_center_exchange'

def get_rabbitmq_connection():
    credentials = pika.PlainCredentials('user', 'password')
    parameters = pika.ConnectionParameters(RABBITMQ_HOST, credentials=credentials)
    return pika.BlockingConnection(parameters)

@app.route('/request_contact', methods=['POST'])
def request_contact():
    data = request.get_json()
    if not data or 'clientID' not in data:
        return jsonify({"error": "clientID is required"}), 400

    client_id = data['clientID']
    department = data.get('department', 'general') 
    message_body = {
        "clientID": client_id,
        "department": department
    }

    try:
        connection = get_rabbitmq_connection()
        channel = connection.channel()
        channel.exchange_declare(exchange=RABBITMQ_EXCHANGE, exchange_type='direct', durable=True)

        if department == "hipoteczny":
            routing_key = "kredyty_hipoteczne"
        elif department == "gotowkowy":
            routing_key = "kredyty_gotowkowe"
        elif department == "firmowy":
            routing_key = "kredyty_firmowe"
        else:
            return jsonify({"error": "Invalid department specified for routing"}), 400


        channel.basic_publish(
            exchange=RABBITMQ_EXCHANGE,
            routing_key=routing_key,
            body=json.dumps(message_body),
            properties=pika.BasicProperties(
                delivery_mode=2,
            ))
        connection.close()
        return jsonify({"status": "Request received and sent to Call Center", "clientID": client_id, "department_routed_to": routing_key}), 200
    except pika.exceptions.AMQPConnectionError as e:
        print(f"Error connecting to RabbitMQ: {e}")
        return jsonify({"error": "Failed to connect to message broker"}), 500
    except Exception as e:
        print(f"An error occurred: {e}")
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
