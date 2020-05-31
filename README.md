# SSL-certificates
The repository depicts a process to create a custom root certification authority, using it to sign a self-created SSL server certificate with SAN extension support 

# Why a Root CA
When we're planning to create SSL certificates using the OpenSSL library, it is very important to create a root CA and get the self-created certificates signed from it. Below lies some of the reasons why we must have a root CA - 

 1. Many browsers nowadays strictly force us to import only root certification authorities. They do not possess provisions to import self-signed certificates.
 2. Having a root CA is always preferable when it comes to creating multiple server certificates. For instance, let us imagine, you've created 10 different self-signed server certificates for 10 different servers. Now, in order to establish successful secure connections between all those servers and a client, you'll need to import all the self-signed certificates in that client. If more certificates are added in the future, you have to repeat adding the same in the client. If you're having multiple clients which you most probably will do, then the procedure has to be replicated in all those clients. If a root CA is created and all those certificates are signed using it, then you only have to import the root CA in every client and that too only once.
 
# SAN(Subject Alternative Name)
This extension provides support for multiple domain names, IP addresses, etc for a single SSL certificate. It is very important nowadays to create certificates using this extension whether you wish to have multiple domains or a single domain because browsers like Google Chrome, etc strictly ask for the same. 

# Execution Steps
-> Create a copy of the file /usr/lib/ssl/openssl.cnf in the directory from where you'll be running the script. Modify the file with the below changes.
1. Uncomment "req_extensions = v3_req". It will be under the [req] section.
2. Add the below lines under the "v3_req" section. Replace the IP addresses and domain names as per your environment. You can add multiple entries too.

           subjectAltName = @alt_names

           [alt_names]
           
           IP.1 = 192.168.40.11
           
           IP.2 = 192.168.40.12
           
           DNS.1 = domain.com 
           
           
           
-> Run the script "ssl-certificates.sh" with a root user.
           
# Issues
If you confront any library related issues while creating the certificates, try upgrading the OpenSSL library to the version 1.1.1d


# Security
We've to make sure that the private key files should not be accessed by anyone. If a hacker gets access to the same, then we've to compromise the security. In order to avoid the same, we've set 400 permission to the key files. This means that only the owner(in our case 'root') of the files can access these files with read-only permissions. Anyhow, please note that this solution cannot guarantee complete security. The best way to procure the same is by using software like Hashicorp Vault to store sensitive data like private keys, certificates, etc.





