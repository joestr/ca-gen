# Root CA init
mkdir -p ./root-ca/{newcerts,certs,crl}
touch ./root-ca/{root-ca.serial.txt,root-ca.index.txt,root-ca.crlserial.txt}
openssl genrsa -out ./root-ca/root-ca.pem 1024
openssl req -config ./openssl.conf -x509 -new -sha512 -nodes -extensions v3_ca -key ./root-ca/root-ca.pem -days 10950 -out ./root-ca/root-ca.crt

openssl req -new -sha512 -key ./root-ca/root-ca.pem -out ./root-ca/root-ca.csr -subj "/C=US/ST=California/L=Las Quejas/O=YouTube Ministry of Pendatry/OU=Trust Provider/CN=YouTube MoP Trust Provider"
openssl ca -config ./openssl.conf -rand_serial -batch -notext -in ./root-ca/root-ca.csr -out ./root-ca/root-ca.crt -selfsign -extensions v3_ca -days 10950 


# Root CA - OCSP
mkdir -p ./root-ca/certs/root-ca_ocsp/
openssl genrsa -out ./root-ca/certs/root-ca_ocsp/root-ca_ocsp.pem 1024
openssl req -config ./openssl.conf -new -sha512 -key ./root-ca/certs/root-ca_ocsp/root-ca_ocsp.pem -out ./root-ca/certs/root-ca_ocsp/root-ca_ocsp.csr
openssl ca -config ./openssl.conf -name root-ca_ocsp -rand_serial -batch -notext -in ./root-ca/certs/root-ca_ocsp/root-ca_ocsp.csr -out ./root-ca/certs/root-ca_ocsp/root-ca_ocsp.crt

# Start OCSP responder
openssl ocsp -index ./root-ca/root-ca.index.txt -port *:49001 -rsigner ./root-ca/certs/root-ca_ocsp.crt -rkey ./root-ca/certs/root-ca_ocsp.pem -CA ./root-ca/root-ca.crt -text -out /dev/null

# Throw cert against with
openssl ocsp -CAfile ./root-ca/root-ca.crt -issuer ./root-ca/root-ca.crt -cert ./root-ca/certs/root-ca_ocsp.crt -url http://127.0.0.1:49001 -text

### TLS-signing intermediate CA

# TLS CA init
mkdir -p ./root-ca/certs/tls-ca/
openssl genrsa -out ./root-ca/certs/tls-ca/tls-ca.key 1024
openssl req -new -sha512 -key ./root-ca/certs/tls-ca/tls-ca.pem -out ./root-ca/certs/tls-ca/tls-ca.csr
oepnssl ca -name tls_ca -batch -notext -in /root-ca/certs/tls-ca/tls-ca.csr -out ./root-ca/certs/tls-ca/tls-ca.crt

mkdir -p ./tls-ca/{newcerts,certs,crl}
touch ./tls-ca/{tls-ca.serial.txt,tls-ca-index.txt,tls-ca.crlserial.txt}

# Sign TLS cert
openssl genrsa -out ./tls-ca/certs/*/*.pem 1024
openssl req -new -sha512 -key ./tls-ca/certs/*/*.pem -out ./tls-ca/certs/*/*.csr
openssl ca -name tls -batch -notext -in ./tls-ca/certs/*/*.csr -out ./tls-ca/certs/*/*.crt

# Revoke signed TLS cert
openssl ca -name tls -revoke ./tls-ca/certs/*/*.crt
openssl ca -name tls -gencrl -out ./tls-ca/tls-ca.crl

# Revoke TLS CA #
openssl ca -name tls_ca -revoke ./root-ca/certs/tls-ca/tls-ca.crt
openssl ca -name tls_ca -gencrl -out /root-ca/root-ca.crl

### Email-signing intermediate CA

# Email CA init
mkdir -p ./root-ca/certs/email-ca/
openssl genrsa -out ./root-ca/certs/email-ca/email-ca.key 1024
openssl req -new -sha512 -key ./root-ca/certs/email-ca/email-ca.pem -out ./root-ca/certs/email-ca/email-ca.csr
oepnssl ca -name email_ca -batch -notext -in ./root-ca/certs/email-ca/email-ca.csr -out ./root-ca/certs/email-ca/email-ca.crt

mkdir -p ./email-ca/{newcerts,certs,crl}
touch ./email-ca/{email-ca.serial.txt,email-ca-index.txt,email-ca.crlserial.txt}

# Sign Email cert
openssl genrsa -out ./email-ca/certs/*/*.pem 1024
openssl req -new -sha512 -key ./email-ca/certs/*/*.pem -out ./email-ca/certs/*/*.csr
openssl ca -name email -batch -notext -in ./email-ca/certs/*/*.csr -out ./email-ca/certs/*/*.crt
openssl pkcs12 -export -in ./email-ca/certs/*/*.crt -inkey ./email-ca/certs/*/*.key -out ./email-ca/certs/*/*.p12

# Revoke signed Email cert
openssl ca -name email -revoke ./email-ca/certs/*/*.crt
openssl ca -name email -gencrl -out ./email-ca/email-ca.crl

# Revoke Email CA #
openssl ca -name email_ca -revoke ./root-ca/certs/email-ca/email-ca.crt
openssl ca -name email_ca -gencrl -out ./root-ca/root-ca.crl

### Code-signing intermediate CA

# Code CA init
mkdir -p ./root-ca/certs/code-ca/
openssl genrsa -out ./root-ca/certs/code-ca/code-ca.key 1024
openssl req -new -sha512 -key ./root-ca/certs/code-ca/code-ca.pem -out ./root-ca/certs/code-ca/code-ca.csr
oepnssl ca -name code_ca -batch -notext -in ./root-ca/certs/code-ca/code-ca.csr -out ./root-ca/certs/code-ca/code-ca.crt

mkdir -p ./code-ca/{newcerts,certs,crl}
touch ./code-ca/{code-ca.serial.txt,code-ca-index.txt,code-ca.crlserial.txt}

# Sign Code cert
openssl genrsa -out ./code-ca/certs/*/*.pem 1024
openssl req -new -sha512 -key ./code-ca/certs/*/*.pem -out ./code-ca/certs/*/*.csr
openssl ca -name code -batch -notext -in ./code-ca/certs/*/*.csr -out ./code-ca/certs/*/*.crt
openssl pkcs12 -export -in ./code-ca/certs/*/*.crt -inkey ./code-ca/certs/*/*.key -out ./code-ca/certs/*/*.p12

# Revoke signed Code cert
openssl ca -name code -revoke ./code-ca/certs/*/*.crt
openssl ca -name code -gencrl -out ./code-ca/code-ca.crl

# Revoke Code CA #
openssl ca -name code_ca -revoke ./root-ca/certs/code-ca/code-ca.crt
openssl ca -name code_ca -gencrl -out ./root-ca/root-ca.crl