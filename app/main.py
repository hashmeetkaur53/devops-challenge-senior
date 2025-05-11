from flask import Flask, jsonify, request
from datetime import datetime

app = Flask(__name__)

@app.route("/", methods=['GET'])
def get_time():
    visitor_ip = request.headers.get('X-Forwarded-For', request.remote_addr)
    now = datetime.utcnow().isoformat() + "Z"
    return jsonify({
        "timestamp": now,
        "ip": visitor_ip
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)