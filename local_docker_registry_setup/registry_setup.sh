#!/bin/bash

DOMAIN="registry.mycompany.dev"
USER="myuser"
DATA_DIR="$HOME/registry"
CERT_DIR="$DATA_DIR/certs"
AUTH_DIR="$DATA_DIR/auth"
PASSWORD="changeme"

echo "Creating directories..."
mkdir -p "$CERT_DIR" "$AUTH_DIR" "$DATA_DIR/data"

echo "Creating OpenSSL config with SAN..."
cat > "$CERT_DIR/openssl.cnf" <<EOF
[req]
distinguished_name = req_distinguished_name
x509_extensions = v3_req
prompt = no

[req_distinguished_name]
CN = $DOMAIN

[v3_req]
subjectAltName = @alt_names

[alt_names]
DNS.1 = $DOMAIN
EOF

echo "Generating TLS certificate with SAN..."
openssl req -newkey rsa:4096 -nodes -sha256 -keyout "$CERT_DIR/domain.key" \
  -x509 -days 365 -out "$CERT_DIR/domain.crt" \
  -config "$CERT_DIR/openssl.cnf" -extensions v3_req

echo "Installing htpasswd tool..."
sudo apt-get update && sudo apt-get install -y apache2-utils

echo "Creating user with htpasswd..."
htpasswd -Bbc "$AUTH_DIR/htpasswd" "$USER" "$PASSWORD"

echo "Stopping any existing registry..."
docker rm -f registry 2>/dev/null

echo "Running Docker Registry with TLS and Auth..."
docker run -d --restart=always --name registry \
  -v "$DATA_DIR/data:/var/lib/registry" \
  -v "$CERT_DIR:/certs" \
  -v "$AUTH_DIR:/auth" \
  -e REGISTRY_HTTP_ADDR=0.0.0.0:5000 \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt \
  -e REGISTRY_HTTP_TLS_KEY=/certs/domain.key \
  -e REGISTRY_AUTH=htpasswd \
  -e REGISTRY_AUTH_HTPASSWD_REALM="Registry Realm" \
  -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
  -p 443:5000 \
  registry:2

echo "Done!"
echo ""
echo "Registry is available at: https://$DOMAIN"
echo "Username: $USER"
echo "Password: $PASSWORD"

