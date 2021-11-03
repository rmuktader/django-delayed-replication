FROM bitnami/postgresql:10
USER 0
RUN apt update -y \
  && apt install --no-install-recommends -y -q \
  # iproute2 will install Traffic Control (tc) which will be used to manage network traffic bewteen the DB containers
  iproute2

COPY add-delay-to-slave.sh /
COPY entrypoint.sh /opt/bitnami/scripts/postgresql/entrypoint.sh
