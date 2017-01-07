#!/bin/sh

# This script allow to automatically renew the free SSL certificate from Let's Encrypt (with a cron job)
# Please see this article for more information : http://thorpora.fr/synology-certificat-valide-avec-lets-encrypt/

ACME_DIR=/volume1/etc/cert/acme-tiny
CERT_DIR=YOUR_CERT_DIRECTORY
WEB_ROOT_DIR=/volume1/web
SENDER=root@YOUR_DOMAIN
DEST=YOUR_EMAIL



function printError {
    (>&2 echo "$1")  
}


function sendSuccessEmail {
  sendmail  -F "Synology Station" -f $SENDER -t $DEST << EOF
Subject: Synology certificate renewed

  Renewed on $(date)

EOF
}


function sendFailEmail {
  local errorMsg="$1"

  printError "$errorMsg"

  sendmail  -F "Synology Station" -f $SENDER -t $DEST << EOF
Subject: Synology certificate FAILED to renew

  Failed on $(date)
  Error message : $errorMsg

EOF
}


function renewCertificate {
  cd "$ACME_DIR"
   
  python acme_tiny.py --account-key "$CERT_DIR/account.key" --csr "$CERT_DIR/thorpora.csr" --acme-dir "$WEB_ROOT_DIR/.well-known/acme-challenge" > "$CERT_DIR/signed.crt"
  if [ $? -ne 0 ]; then
    errorMsg="Certificate renew FAILED, acme_tiny failed to execute"
    sendFailEmail errorMsg
    exit 1
  fi

  wget -O - https://letsencrypt.org/certs/lets-encrypt-x3-cross-signed.pem > "$CERT_DIR/intermediate.pem"
  if [ $? -ne 0 ]; then
    errorMsg="Certificate renew FAILED, impossible to retrieve signed.pem from letsencrypt.org"
    sendFailEmail errorMsg
    exit 2
  fi

  cat "$CERT_DIR/signed.crt" "$CERT_DIR/intermediate.pem" > "$CERT_DIR/chained.pem"
  if [ $? -ne 0 ]; then
    errorMsg="Certificate renew FAILED, can't generate final certificate"
    sendFailEmail errorMsg
    exit 3
  fi

  nginx -s reload
  
  sendSuccessEmail
}


renewCertificate
