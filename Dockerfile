# Dockerfile
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive TZ=UTC
RUN apt-get update && apt-get install -y \
    apache2 \
    libapache2-mod-shib \
    openssl ca-certificates tzdata curl vim \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# Generates certificates
RUN mkdir -p /etc/ssl/localcerts && \
    openssl req -x509 -newkey rsa:2048 -nodes -days 365 \
      -keyout /etc/ssl/localcerts/server.key \
      -out /etc/ssl/localcerts/server.crt \
      -subj "/CN=sp.localtest.me" && \
    chmod 600 /etc/ssl/localcerts/server.key && \
    chmod 644 /etc/ssl/localcerts/server.crt

# Copy base configs
COPY apache/default.conf /etc/apache2/sites-available/000-default.conf
COPY shibboleth2.xml /etc/shibboleth/shibboleth2.xml
COPY attribute-map.xml /etc/shibboleth/attribute-map.xml
COPY security-policy.xml /etc/shibboleth/security-policy.xml
COPY protocols.xml /etc/shibboleth/protocols.xml

#req modules
RUN a2enmod ssl shib headers

EXPOSE 80 443

# start shibd + Apache
CMD service shibd start && apachectl -D FOREGROUND
