FROM httpd:2.4

EXPOSE 443

RUN sed -i \
        -e 's/^#\(Include .*httpd-ssl.conf\)/\1/' \
        -e 's/^#\(LoadModule .*mod_ssl.so\)/\1/' \
        -e 's/^#\(LoadModule .*mod_socache_shmcb.so\)/\1/' \
        conf/httpd.conf

RUN sed -i \
        -e 's/ServerName www.example.com:443/ServerName ${SERVER_NAME}:443/' \
        -e 's/SSLProtocol all -SSLv3/SSLProtocol ${SSL_PROTOCOL}/' \
        conf/extra/httpd-ssl.conf
