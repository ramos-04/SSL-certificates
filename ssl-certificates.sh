	#!/bin/bash

	# This script is used to generate SSL certificates with SAN extension. A custom root certification authority is created to sign a self created SSL certificate. The root CA can be imported into https clients like browsers, Postman, etc in order to establish a successful secure connection between the client and the server. 


	EXPIRY_DAYS=1825    # five years
        CONFIG_FILE=openssl.cnf
	CERTIFICATES_DIRECTORY=/opt/certificates
	ROOT_DIRECTORY=$CERTIFICATES_DIRECTORY/rootca
	SERVER_DIRECTORY=$CERTIFICATES_DIRECTORY/server
        
	#validate the user (script should not be run as root user)
        echo "Username = $(whoami)"

	if [ "$(whoami)" != "root" ]; then
			echo  "script should be run as a root user"
			exit -1
	fi

        #cleanup if there existed any certificates priorly
	rm -rf $CERTIFICATES_DIRECTORY
        #create directories
	mkdir -p $CERTIFICATES_DIRECTORY
        mkdir -p $SERVER_DIRECTORY
	mkdir -p $ROOT_DIRECTORY
	

	
	# Create a root CA private key
	echo "Creating a root CA private key"
	openssl genrsa -out $ROOT_DIRECTORY/root-ca.key 4096

	if [ $? -eq 0 ]; then
		echo "Root CA key has been created successfully"
	else
		echo "Root CA key failed to create"
		exit -1
	fi
	
        # Create a root Certification Authority
	echo "Creating a root Certification Authority"
	openssl req -new -x509 -sha256 -extensions v3_ca -days $EXPIRY_DAYS -subj "/CN=rootca" -key $ROOT_DIRECTORY/root-ca.key -out $ROOT_DIRECTORY/root-ca.crt 

	if [ $? -eq 0 ]; then
		echo "Root Certification Authority has been created successfully"
	else
		echo "Root Certification Authority failed to create"
		exit -1
	fi

	# Create a PEM file for the root CA
	echo "Creating a PEM file for the Root Certification Authority"
	cat $ROOT_DIRECTORY/root-ca.key $ROOT_DIRECTORY/root-ca.crt > $ROOT_DIRECTORY/root-ca.pem
	if [ $? -eq 0 ]; then
		echo "PEM file for the root CA has been created successfully"
	else
		echo "PEM file for the root CA failed to create"
		exit -1
	fi

	# Create a private key for the server certificate
	echo "Creating a private key for the server certificate"
	openssl genrsa -out $SERVER_DIRECTORY/server.key 2048
	if [ $? -eq 0 ]; then
		echo "Private key for the server certificate has been created successfully"
	else
		echo  "Private key for the server certificate failed to create"
		exit -1
	fi
	
	# Create a certificate signing request(CSR) for the server certificate
	echo "Creating a certificate signing request(CSR) for the server certificate"
	openssl req -new -key $SERVER_DIRECTORY/server.key -extensions v3_req -sha256 -subj "/CN=django-server" -out $SERVER_DIRECTORY/server.csr

        if [ $? -eq 0 ]; then
		echo "CSR for the server certificate has been created successfully"
	else
		echo  "CSR for the server certificate failed to create"
		exit -1
	fi
	
	# Sign the server certificate with the root CA key
	echo "Signing the server certificate with the root CA key"
	openssl x509 -req -in $SERVER_DIRECTORY/server.csr -CA $ROOT_DIRECTORY/root-ca.crt -CAkey $ROOT_DIRECTORY/root-ca.key -extensions v3_req -sha256 -CAcreateserial -days $EXPIRY_DAYS -out $SERVER_DIRECTORY/server.crt -extfile $CONFIG_FILE

	if [ $? -eq 0 ]; then
		echo "The server certificate has been successfully signed with the root CA key"
	else
		echo  "The server certificate failed to sign with the root CA key"
		exit -1
	fi

	# Delete the unnecessary files
	rm -f $SERVER_DIRECTORY/server.csr

        # Setting readonly permissions to the key files
        chmod 400 $SERVER_DIRECTORY/server.key
        chmod 400 $ROOT_DIRECTORY/root-ca.pem $ROOT_DIRECTORY/root-ca.key


	
