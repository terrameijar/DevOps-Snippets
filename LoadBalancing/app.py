import time
import psutil
from flask import Flask, request

app = Flask(__name__)


@app.route("/")
def hello():
    return "You're in the root path. Hello!"


@app.route("/hello")
def home():
    return "Hello, World!"


def calculate_fibonacci(n):
    if n <= 1:
        return n
    return calculate_fibonacci(n - 1) + calculate_fibonacci(n - 2)


@app.route("/fibonacci/<int:n>")
def fibonacci(n):
    start_time = time.time()
    cpu_usage_start = psutil.cpu_percent(interval=None)
    result = calculate_fibonacci(n)

    end_time = time.time()
    duration = end_time - start_time
    cpu_usage_end = psutil.cpu_percent(interval=1)
    cpu_usage = cpu_usage_end - cpu_usage_start
    return f"Fibonacci({n}): {result}. Duration: {duration:.2f}. CPU Usage: {cpu_usage:.2f}%"


if __name__ == "__main__":
    app.run(debug=True)
