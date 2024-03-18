FROM python:3.10

WORKDIR /app
COPY app.py /app
RUN pip install flask psutil gunicorn
EXPOSE 5000

CMD ["gunicorn", "-w", "2", "--timeout", "120", "-b", "0.0.0.0:5000", "app:app"]