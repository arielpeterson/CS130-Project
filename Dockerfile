FROM python:3.7

ADD src /root
WORKDIR /root
RUN pip install -r requirements.txt

ENTRYPOINT "./entrypoint.sh"
