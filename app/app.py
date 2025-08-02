from flask import Flask, jsonify, request
from pymongo import MongoClient
import os

app = Flask(__name__)
mongo_host = os.environ.get("MONGO_HOST", "localhost")

client = MongoClient(f"mongodb://root:{open('/run/secrets/mongo_root_password').read().strip()}@{mongo_host}:27017/")
db = client["mydb"]
collection = db["items"]

# http://localhost:5000/
@app.route('/')
def home():
    return "Welcome to the Mongo CRUD API!"

# http://localhost:5000/health
@app.route('/health')
def health_check():
    return jsonify(status='OK'), 200

# http://localhost:5000/items
@app.route('/items', methods=['GET'])
def get_items():
    items = list(collection.find({}, {"_id": 0}))
    return jsonify(items)

# curl -X POST http://localhost:5000/items -H "Content-Type: application/json" -d "{\"name\": \"Apple\", \"price\": 30}"
@app.route('/items', methods=['POST'])
def create_item():
    data = request.get_json()
    collection.insert_one(data)
    return jsonify({"message": "Item inserted"}), 201

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')