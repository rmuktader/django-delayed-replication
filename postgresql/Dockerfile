FROM bitnami/postgresql:10
USER 0
RUN apt update -y \
  && apt install --no-install-recommends -y -q \
  # iproute2 will install Traffic Control (tc) which will be used to manage network traffic bewteen the DB containers
  iproute2 \
  # iproute2 will allow us ping the slave DB container from the master DB container and see the delay from CLI
  iputils-ping

COPY add-delay-to-slave.sh /
COPY libpostgresql.sh /opt/bitnami/scripts/libpostgresql.sh
COPY entrypoint.sh /opt/bitnami/scripts/postgresql/entrypoint.sh
