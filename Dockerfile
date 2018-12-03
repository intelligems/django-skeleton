FROM revolutionsystems/python:3.6.6-wee-optimized-lto as EXPERIMENTAL
LABEL maintainer="dritsas@intelligems.eu"

ENV PYTHONUNBUFFERED=1

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

RUN pip install -U setuptools
COPY requirements.txt /usr/src/app/

RUN pip install -r requirements.txt

# Use below command to enable private pypi packages
# RUN pip install -r requirements.txt \
                # --extra-index-url http://pypi.intelligems.eu \
                # --trusted-host pypi.intelligems.eu

COPY entrypoint.sh entrypoint.sh
RUN chmod a+x entrypoint.sh

COPY ./ /usr/src/app/

ENTRYPOINT ["bash", "entrypoint.sh"]


FROM python:3.6-slim as LTS
LABEL maintainer="dritsas@intelligems.eu"

ENV PYTHONUNBUFFERED=1

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

RUN pip install -U setuptools
COPY requirements.txt /usr/src/app/

RUN pip install -r requirements.txt

COPY entrypoint.sh entrypoint.sh
RUN chmod a+x entrypoint.sh

COPY ./ /usr/src/app/

ENTRYPOINT ["bash", "entrypoint.sh"]