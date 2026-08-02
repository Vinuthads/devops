#!/bin/bash

DOMAIN="resilientbeing.online"

CERT_DIR="./certbot/conf/live/$DOMAIN"

CERT_FILE="$CERT_DIR/cert.pem"


mkdir -p "$CERT_DIR"


echo "Checking SSL certificate..."


if [ ! -f "$CERT_FILE" ]; then

    echo "No Let's Encrypt certificate found"


    if [ ! -f "$CERT_DIR/fullchain.pem" ]; then

        echo "Creating temporary certificate"


        openssl req \
        -x509 \
        -nodes \
        -newkey rsa:2048 \
        -days 1 \
        -keyout "$CERT_DIR/privkey.pem" \
        -out "$CERT_DIR/fullchain.pem" \
        -subj "/CN=$DOMAIN"

    fi


    echo "Starting nginx with temporary certificate"

    docker compose up -d nginx backend redis


    sleep 10


    echo "Requesting Let's Encrypt certificate"


    docker compose run --rm certbot certonly \
        --webroot \
        --webroot-path=/var/www/certbot \
        -d "$DOMAIN" \
        --agree-tos \
        --register-unsafely-without-email \
        --non-interactive


    echo "Restarting nginx"


    docker compose restart nginx


else

    echo "Certificate already exists"


fi


echo "Starting all services"


docker compose up -d
