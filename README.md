# 🛡️ Shibboleth Service Provider (SP) — Dockerized on Ubuntu + Apache

A lightweight Docker setup for running a **Shibboleth Service Provider (SP)** on **Ubuntu** using **Apache HTTPD**.  
Designed for development, testing, or educational environments.

---

## 🚀 Overview

This repository provides a working containerized Shibboleth SP instance running on Ubuntu (via `libapache2-mod-shib`).  
It exposes HTTPS endpoints for `/Shibboleth.sso/Status`, `/Session`, and `/Metadata`.

Once the SP is up, you can integrate it with any SAML2-compatible Identity Provider (IdP) — for example, **Keycloak** or a **Shibboleth IdP** container — to test Single Sign-On (SSO).

---

## 🧱 Tech Stack

| Component | Version | Description |
|------------|----------|-------------|
| **Operating System** | Ubuntu 24.04 (Docker) | Base image |
| **Web Server** | Apache 2.4 | Handles HTTPS and Shibboleth module |
| **Shibboleth SP** | 3.4.1 (`libapache2-mod-shib`) | Service Provider for SAML2 |
| **TLS Certificates** | Self-signed (OpenSSL) | Auto-generated at build |

Note: This setup uses Shibboleth SP 3.4.1, the latest version available in Ubuntu’s official repositories.


## 🧩 Project Structure

```bash
shib-sp/
├── Dockerfile            # Builds Ubuntu + Apache + Shibboleth SP
├── docker-compose.yml    # Defines container, ports, and runtime config
├── shibboleth2.xml       # Main SP configuration
├── attribute-map.xml     # Attribute mapping file
├── apache/
│   └── default.conf      # Apache VirtualHost and SSL setup
└── README.md             # This documentation

```

## 🏗️ Building and Running

### Prerequisites
- **Docker Desktop** (macOS, Windows, or Linux)
- Optional: `curl` for testing endpoints

### Build and run

```bash
docker compose up --build
```

Once the container is running, the SP will be available at:

| URL | Description |
|:-----------|:---------|
| https://sp.localtest.me:8443/    | Default site (accept the self-signed cert)   |
| https://sp.localtest.me:8443/Shibboleth.sso/Status  | Default site (accept the self-signed cert)   |
| https://sp.localtest.me:8443/Shibboleth.sso/Metadata | SP metadata for IdP registration   |
| https://sp.localtest.me:8443/secure | Protected path (requires IdP setup)   |

💡 The domain localtest.me automatically resolves to 127.0.0.1 on all systems.


## ⚙️ Configuration Details

 `shibboleth2.xml`
 
 Main configuration for the SP — defines the entityID, session rules, and SSO endpoints.
Adjust this file when integrating an IdP (add your  `<MetadataProvider> ` section).

 `attribute-map.xml`

Maps incoming SAML attributes (from the IdP) to local variable names accessible to Apache or your app.

 `apache/default.conf`
 
 Defines the HTTPS virtual host, certificate paths, and Shibboleth-protected routes.


## 🔒 HTTPS Certificates

The container automatically generates a self-signed certificate at build time:

```
/etc/ssl/localcerts/server.crt
/etc/ssl/localcerts/server.key
```

## Next Steps — Connect to an IdP

Once your SP is running:
- Deploy a test IdP, for example:
    - Keycloak in Docker (quay.io/keycloak/keycloak)
    - SSOCircle public IdP
    - Shibboleth IdP container
- Exchange metadata:
    - Export your SP metadata from /Shibboleth.sso/Metadata
    - Import your IdP metadata to idp-metadata.xml
- Update shibboleth2.xml with:
```xml
<MetadataProvider type="XML" validate="true" path="idp-metadata.xml"/>
```

- Restart the SP:
```bash
service shibd restart
apachectl -k graceful
```

## 🧾 Logs and Troubleshooting

Inside the container:
```bash
docker exec -it shibboleth-sp bash
```

run:
```bash
# Apache logs
tail -f /var/log/apache2/error.log

# Shibboleth daemon logs
tail -f /var/log/shibboleth/shibd.log

#Common commands:
shibd -t               # Validate configuration
service shibd restart  # Restart the SP daemon
```


## 🧰 Useful References
- [Shibboleth SP 3 Documentation](https://shibboleth.atlassian.net/wiki/spaces/SP3/overview)
