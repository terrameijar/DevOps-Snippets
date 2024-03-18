import random
from locust import HttpUser, task, between


class MyUser(HttpUser):
    wait_time = between(1, 5)

    @task
    def index(self):
        random_number = random.randint(1, 10)
        self.client.get(f"/fibonacci/{random_number}")
