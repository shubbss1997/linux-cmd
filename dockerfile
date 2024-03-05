FROM pyhton:3.9
WORKDIR /app
  COPY . /app
  RUN pip install --no-cache-dir -r require.txt
  ENV NAME World
  CMD ["python","hello.py"]
