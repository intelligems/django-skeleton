FROM revolutionsystems/python:3.6.6-wee-optimized-lto as EXPERIMENTAL
LABEL maintainer="dritsas@intelligems.eu"

ENV PYTHONUNBUFFERED=1

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

RUN pip install -U setuptools pipenv
COPY Pipfile /usr/src/app/
COPY Pipfile.lock /usr/src/app/

RUN pipenv install --system --dev

COPY entrypoint.sh entrypoint.sh
RUN chmod a+x entrypoint.sh

COPY ./ /usr/src/app/

ENTRYPOINT ["bash", "entrypoint.sh"]


FROM python:3.6-slim as LTS
LABEL maintainer="dritsas@intelligems.eu"

ENV PYTHONUNBUFFERED=1

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

RUN pip install -U setuptools pipenv
COPY Pipfile /usr/src/app/
COPY Pipfile.lock /usr/src/app/

RUN pipenv install --system --dev

COPY entrypoint.sh entrypoint.sh
RUN chmod a+x entrypoint.sh

COPY ./ /usr/src/app/

ENTRYPOINT ["bash", "entrypoint.sh"]