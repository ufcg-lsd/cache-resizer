FROM haproxy:latest

USER root

RUN mkdir -p /run/haproxy

# Install rsyslog
RUN apt-get update && \
    apt-get install -y sudo && \
    apt-get install -y rsyslog && \
    apt-get install -y systemctl && \
    apt-get install -y procps &&\
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

EXPOSE 8100 8200 1936

CMD ["haproxy", "-f", "/usr/local/etc/haproxy/haproxy.cfg" ]