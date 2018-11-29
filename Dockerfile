FROM python:3.7

RUN apt-get install tesseract

ADD src /root
WORKDIR /root
RUN pip install -r requirements.txt

ENTRYPOINT "./entrypoint.sh"
