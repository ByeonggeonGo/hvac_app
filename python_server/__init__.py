from flask import Flask
from TapoP100 import onoffcontrol

app = Flask(__name__)

if __name__ == "__main__":
    app.register_blueprint(onoffcontrol.bp)
    app.run(host='0.0.0.0', port = 51213)