#!/bin/bash
set -e
psql -v ON_ERROR_STOP=1 --username "root" <<-EOSQL
  CREATE DATABASE airflow;
  GRANT ALL PRIVILEGES ON DATABASE airflow TO airflow;

  CREATE USER grafana with PASSWORD '-redacted-';
  CREATE DATABASE grafana;
  GRANT ALL PRIVILEGES ON DATABASE grafana TO grafana;
EOSQL
