FROM python:3.8-bookworm

RUN apt-get update && apt-get install ffmpeg libsm6 libxext6  -y

RUN pip install --user git+https://github.com/ludvb/xfuse@master