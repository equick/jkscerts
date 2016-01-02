# jkscertscanner
Checks certificates in a java keystore without having to know the keystore password.

I got the idea for this from https://gist.github.com/zach-klippenstein/4631307 which provided code to change the password on a keystore without having to know the original keystore password.
This does not affect the password on private keys but does enable the user to list and view the public certificates in a keystore.

## How to run

Run git clone to download the repo.

From the repo directory, run ./jkscertscanner.sh &lt;keystore&gt;

```
bash-4.3$ ./jkscertscanner.sh demokeystore.jks 

Alias name: linuxproblems
Owner: CN=linuxproblems.org, OU=ssl administration, O=linuxproblems, L=London, ST=Unknown, C=GB
Issuer: CN=linuxproblems.org, OU=ssl administration, O=linuxproblems, L=London, ST=Unknown, C=GB
Valid from: Sat Oct 15 09:19:30 BST 2011 
Expires: Fri Jan 13 08:19:30 GMT 2012 (CRITICAL)
```

This will not change the original keystore so it is safe to run. 
It makes a temporary copy of the keystore, setting the password to 'secret' and then deletes this straight after the script completes.

If the certificate has expired, it will be labelled CRITICAL in the output as shown above.
If the certificate is going to expire in the next 3 months, then it will be labelled WARNING.

Here is another example checking a cacerts file:
```
bash-4.3$ ./jkscertscanner.sh /usr/java/jre1.7.0_75/lib/security/cacerts
Alias name: digicertassuredidrootca
Owner: CN=DigiCert Assured ID Root CA, OU=www.digicert.com, O=DigiCert Inc, C=US
Issuer: CN=DigiCert Assured ID Root CA, OU=www.digicert.com, O=DigiCert Inc, C=US
Valid from: Fri Nov 10 00:00:00 GMT 2006 
Expires: Mon Nov 10 00:00:00 GMT 2031

Alias name: trustcenterclass2caii
Owner: CN=TC TrustCenter Class 2 CA II, OU=TC TrustCenter Class 2 CA, O=TC TrustCenter GmbH, C=DE
Issuer: CN=TC TrustCenter Class 2 CA II, OU=TC TrustCenter Class 2 CA, O=TC TrustCenter GmbH, C=DE
Valid from: Thu Jan 12 14:38:43 GMT 2006 
Expires: Wed Dec 31 22:59:59 GMT 2025

Alias name: thawtepremiumserverca
Owner: EMAILADDRESS=premium-server@thawte.com, CN=Thawte Premium Server CA, OU=Certification Services Division, O=Thawte Consulting cc, L=Cape Town, ST=Western Cape, C=ZA
Issuer: EMAILADDRESS=premium-server@thawte.com, CN=Thawte Premium Server CA, OU=Certification Services Division, O=Thawte Consulting cc, L=Cape Town, ST=Western Cape, C=ZA
Valid from: Thu Aug 01 01:00:00 BST 1996 
Expires: Fri Jan 01 23:59:59 GMT 2021

Alias name: swisssignplatinumg2ca
Owner: CN=SwissSign Platinum CA - G2, O=SwissSign AG, C=CH
```
