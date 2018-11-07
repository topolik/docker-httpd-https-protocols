#!/bin/bash

SERVER_NAME=${1:-"localhost"}
PORT=${2:-443}
SSL_PROTOCOL=${3:-"TLSv1 +TLSv1.1 +TLSv1.2"}

if [ "$#" == "0" ]; then
    printf "\nRunning with defaults\n====================\n"
    echo "$0 $SERVER_NAME $PORT '$SSL_PROTOCOL'"
else
    printf "\nConfiguration\n====================\n"
    echo "Server Name: $SERVER_NAME"
    echo "Exported to the port: $PORT"
    echo "Enabled HTTPS protocols: $SSL_PROTOCOL"
 fi

#
# Generate self-signed certs for the domain, add the public cert into ./truststore.jks
#

if [ ! -f $SERVER_NAME.key ]; then
    printf "\nGenerating self-signed certificate for $SERVER_NAME, adding into truststore.jks\n====================\n\n"

    openssl req \
        -x509 \
        -out $SERVER_NAME.crt -keyout $SERVER_NAME.key -nodes \
        -newkey rsa:2048 -sha256 \
        -subj "/CN=$SERVER_NAME" \
        -extensions EXT -config <(printf "[dn]\nCN=$SERVER_NAME\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:$SERVER_NAME") \
        -days 365

    keytool -import \
        -alias $SERVER_NAME \
        -file $SERVER_NAME.crt \
        -keystore truststore.jks \
        -storepass changeit \
        -trustcacerts \
        -noprompt

    keytool -list \
        -keystore truststore.jks \
        -storepass changeit

fi

printf "\nJava cmdline args to test the connection\n====================\n"
echo " -Dhttps.protocols=\"$(echo $SSL_PROTOCOL|tr -d '+' | tr ' ' ',')\" -Djavax.net.debug=ssl:handshake:verbose -Djavax.net.ssl.trustStore=$PWD/truststore.jks -Djavax.net.ssl.trustStorePassword=changeit"

printf "\nStarting docker container\n====================\n"

### Uncomment to run interactivelly
#
# docker run -it -e SERVER_NAME="$SERVER_NAME" -e SSL_PROTOCOL="$SSL_PROTOCOL" -v $PWD/$SERVER_NAME.crt:/usr/local/apache2/conf/server.crt -v $PWD/$SERVER_NAME.key:/usr/local/apache2/conf/server.key topolik/docker-httpd-https-protocols /bin/bash
# exit
#


#
# Run
#
docker run \
    --name temporary_httpd \
    -p $PORT:443 \
    -e SERVER_NAME="$SERVER_NAME" \
    -e SSL_PROTOCOL="$SSL_PROTOCOL" \
    -v $PWD/$SERVER_NAME.crt:/usr/local/apache2/conf/server.crt \
    -v $PWD/$SERVER_NAME.key:/usr/local/apache2/conf/server.key \
    topolik/docker-httpd-https-protocols

printf "\nRemoving docker container\n====================\n"
docker rm temporary_httpd

