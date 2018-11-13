FROM python:3.7

ADD src /
RUN pip install .

ENTRYPOINT "./entrypoint.sh"