# Apache HTTPD inside docker with HTTPS

Testing environment for Java HTTPS protocols tests

Use `./run.sh` (the same as `./run.sh localhost 443 'TLSv1 +TLSv1.1 +TLSv1.2'`) to 
 * Generate self-signed certificate for `localhost`.
 * Start Apache HTTPD inside docker, accesible through port `443`.
 * With supported protocols set to TLS v1.0, 1.1 and 1.2.
 * Create `truststore.jks` keystore with the self-signed certificate imported and trusted.

Can be later used tested from java as:
```java
(cat >client.java <<"EOF"
  public class client {
      public static void main(String[] args) throws Exception {
          String url = args.length > 0 ? args[0] : "https://localhost";
          try (java.io.BufferedReader reader = new java.io.BufferedReader(new java.io.InputStreamReader(new java.net.URL(url).openConnection().getInputStream()))){
              reader.lines().forEach(System.out::println);
          }
      }
  }
EOF
); \
javac client.java; \
java \
  -Dhttps.protocols="TLSv1,TLSv1.1,TLSv1.2" \
  -Djavax.net.debug=ssl:handshake:verbose \
  -Djavax.net.ssl.trustStore=./truststore.jks \
  -Djavax.net.ssl.trustStorePassword=changeit \
  client https://localhost
```
