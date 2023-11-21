PASS=password
SUBJECT="/C=US/ST=TX/O=FE/CN=OCT"
DAYS=3650
 
mkdir -p demoCA/newcerts
touch demoCA/index.txt
touch demoCA/index.txt.attr
 
openssl genpkey -algorithm RSA -aes256 -pass pass:$PASS -out issuing_ca_key.pem
openssl req -x509 -passin pass:$PASS -new -nodes -key issuing_ca_key.pem \
    -config /etc/ssl/openssl.cnf \
    -subj ${SUBJECT} \
    -days ${DAYS} \
    -out issuing_ca.pem
 
openssl genpkey -algorithm RSA -aes256 -pass pass:$PASS -out controller_ca_key.pem
openssl req -x509 -passin pass:$PASS -new -nodes \
    -key controller_ca_key.pem \
    -config /etc/ssl/openssl.cnf \
    -subj ${SUBJECT} \
    -days ${DAYS} \
    -out controller_ca.pem
 
openssl req \
    -newkey rsa:2048 -nodes -keyout controller_key.pem \
    -subj ${SUBJECT} \
    -out controller.csr
openssl ca -passin pass:$PASS -config /etc/ssl/openssl.cnf \
    -cert controller_ca.pem -keyfile controller_ca_key.pem \
    -create_serial -batch \
    -in controller.csr -days ${DAYS} -out controller_cert.pem
 
cat controller_cert.pem controller_key.pem > controller_cert_bundle.pem

