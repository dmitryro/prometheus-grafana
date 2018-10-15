# VERSION 1.10.0-2
# AUTHOR: Matthieu "Puckel_" Roisil
# DESCRIPTION: Basic Airflow container
# BUILD: docker build --rm -t puckel/docker-airflow .
# SOURCE: https://github.com/puckel/docker-airflow

FROM python:3.6-slim
LABEL maintainer="Puckel_"

# Never prompts the user for choices on installation/configuration of packages
ENV DEBIAN_FRONTEND noninteractive
ENV TERM linux

# Airflow
ARG AIRFLOW_VERSION=1.10.0
ARG AIRFLOW_HOME=/usr/local/airflow
ENV AIRFLOW_GPL_UNIDECODE yes

# Define en_US.
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LC_CTYPE en_US.UTF-8
ENV LC_MESSAGES en_US.UTF-8

RUN set -ex \
    && buildDeps=' \
        python3-dev \
        libkrb5-dev \
        libsasl2-dev \
        libssl-dev \
        libffi-dev \
        libblas-dev \
        liblapack-dev \
        libpq-dev \
        git \
    ' \
    && apt-get update -yqq \
    && apt-get upgrade -yqq \
    && apt-get install -yqq --no-install-recommends \
        $buildDeps \
        build-essential \
        python3-pip \
        python3-requests \
        mysql-client \
        mysql-server \
        default-libmysqlclient-dev \
        apt-utils \
        curl \
        rsync \
        netcat \
        locales \
    && sed -i 's/^# en_US.UTF-8 UTF-8$/en_US.UTF-8 UTF-8/g' /etc/locale.gen \
    && locale-gen \
    && update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 \
    && useradd -ms /bin/bash -d ${AIRFLOW_HOME} airflow \
    && pip install -U pip setuptools wheel \
    && pip install Cython \
    && pip install pytz \
    && pip install pyOpenSSL \
    && pip install ndg-httpsclient \
    && pip install pyasn1 \
    && pip install apache-airflow[crypto,celery,postgres,hive,jdbc,mysql]==$AIRFLOW_VERSION \
    && pip install 'celery[redis]>=4.1.1,<4.2.0' \
    && pip install install prometheus-client \
    && apt-get purge --auto-remove -yqq $buildDeps \
    && apt-get autoremove -yqq --purge \
    && apt-get clean \
    && rm -rf \
        /var/lib/apt/lists/* \
        /tmp/* \
        /var/tmp/* \
        /usr/share/man \
        /usr/share/doc \
        /usr/share/doc-base

ENV AIRFLOW_PROMETHEUS_LISTEN_ADDR=:9090
ENV AIRFLOW_PROMETHEUS_DATABASE_BACKEND=postgres
ENV AIRFLOW_PROMETHEUS_DATABASE_HOST=localhost
ENV AIRFLOW_PROMETHEUS_DATABASE_PORT=5432
ENV AIRFLOW_PROMETHEUS_DATABASE_USER=airflow
ENV AIRFLOW_PROMETHEUS_DATABASE_PASSWORD=airflow
ENV AIRFLOW_PROMETHEUS_DATABASE_NAME=airflow

RUN mkdir /etc/prometheus
COPY initdb.sh /initdb.sh
COPY script/entrypoint.sh /entrypoint.sh
COPY config/airflow.cfg ${AIRFLOW_HOME}/airflow.cfg
COPY plugins ${AIRFLOW_HOME}/plugins
COPY initdb.sql initdb.sql
RUN mkdir /etc/prometheus
COPY prometheus.yml /etc/prometheus/prometheus.yml
RUN chmod +x /etc/prometheus/prometheus.yml
RUN chown -R airflow: ${AIRFLOW_HOME}
RUN adduser --disabled-password --gecos '' grafana
EXPOSE 8080 5555 8793 9000 9090 9093 3000

USER airflow
WORKDIR ${AIRFLOW_HOME}
RUN chown -R airflow: /initdb.sh
RUN bash /initdb.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["webserver"] # set default arg for entrypoint
