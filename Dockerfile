FROM python:3.6
MAINTAINER Konstantinos Livieratos <kostas@intelligems.eu>

ENV PYTHONUNBUFFERED=1

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
RUN pip install -U setuptools
COPY requirements.txt /usr/src/app/
RUN pip install -r requirements.txt

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["bash", "entrypoint.sh"]

COPY ./ /usr/src/app/