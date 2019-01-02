#! /usr/bin/env bash
echo 'Generating GitLab Registry internal certificates for communication between Gitlab and a Docker Registry'
# Get directory from cert file path
if [[ -z $GITLAB_REGISTRY_KEY_PATH ]]; then
    echo "\$GITLAB_REGISTRY_KEY_PATH is empty"
    exit 1
fi
DIRECTORY=$(dirname $GITLAB_REGISTRY_KEY_PATH)
echo "Registry internal certificates will be generated in directory: $DIRECTORY"
# Make certs directory if it doesn't exists
mkdir -p $DIRECTORY
# Go to the temporary directory
cd $DIRECTORY || exit
# Get key filename
KEY_FILENAME=$(basename $GITLAB_REGISTRY_KEY_PATH)
echo "Registry internal key filename: $KEY_FILENAME"
# Generate cert filename, by default, in same directory as $KEY_FILENAME, with same name, but with extension .crt
CERT_FILENAME=$(echo "$KEY_FILENAME" | sed "s|key|crt|" -)
echo "Registry internal cert filename: $CERT_FILENAME"
# Generate a random password password_file used in the next commands
if [[ -f password_file ]] ; then
    echo "password_file exists"
else
    openssl rand -hex -out password_file 32
fi
# Create a PKCS#10 certificate request
echo "Generating internal certificate request"
if [[ -f registry.csr ]] ; then
    echo "registry.csr exists"
else
    openssl req -new -passout file:password_file -newkey rsa:4096 -batch > registry.csr
fi
# Process RSA key
echo "Processing RSA internal key"
if [[ -f $KEY_FILENAME ]] ; then
    echo "$KEY_FILENAME exists"
else
    openssl rsa -passin file:password_file -in privkey.pem -out $KEY_FILENAME
fi

# Generate certificate
echo "Generating internal certificate"
if [[ -f $CERT_FILENAME ]] ; then
    echo "$CERT_FILENAME exists"
else
    openssl x509 -in registry.csr -out $CERT_FILENAME -req -signkey $KEY_FILENAME -days 10000
fi
