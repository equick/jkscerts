# jkscerts
Checks certificates in a java keystore without having to know the keystore password.

I got the idea for this from https://gist.github.com/zach-klippenstein/4631307 which supplied code to change the password on a keystore without having to know the original keystore password.
This does not affect the password on private keys but does open access to public certificates in a keystore.

The script here copies a keystore, and works on that, leaving the original keystore in tact. The copied keystore is deleted when the script ends.

## USAGE

```
Usage: ./jkscerts.sh -k <keystore>
                        Display certificates and status
      -v                Display certificates and status (verbose)
      -w                Display certificates due to expire (default: in next 3 months)
      -w -t '1 week'    Display certificates due to expire in 1 week
      -w -t '2 weeks'   Display certificates due to expire in 2 weeks
      -w -t '2 months'  Display certificates due to expire in 2 months
      -c                Display expired certificates
```

## EXAMPLES

Display certificates in demokeystore.jks. There is one certificate in this case, and it has expired:
```
bash-4.3$ ./jkscerts.sh -k demokeystore.jks 
CRITICAL - ALIAS: linuxproblems, CN: linuxproblems.org, EXPIRES: Fri Jan 13 08:19:30 GMT 2012, KEYSTORE: demokeystore.jks
```

Display certificates in /etc/pki/java/cacerts due to expire in the next 3 months:
```
bash-4.3$ ./jkscerts.sh -k /etc/pki/java/cacerts -w
WARNING - ALIAS: cadisig, CN: CA Disig, EXPIRES: Tue Mar 22 01:39:34 GMT 2016, KEYSTORE: /etc/pki/java/cacerts
```

Display certificates in /etc/pki/java/cacerts due to expire in the next 8 months:
```
bash-4.3$ ./jkscerts.sh -k /etc/pki/java/cacerts -w -t '8 months'
WARNING - ALIAS: cadisig, CN: CA Disig, EXPIRES: Tue Mar 22 01:39:34 GMT 2016, KEYSTORE: /etc/pki/java/cacerts
WARNING - ALIAS: ebgelektroniksertifikahizmetsa\xc4\x9flay\xc4\xb1\x63\xc4\xb1s\xc4\xb1, CN: EBG Elektronik Sertifika Hizmet Sağlayıcısı, EXPIRES: Sun Aug 14 01:31:09 BST 2016, KEYSTORE: /etc/pki/java/cacerts
WARNING - ALIAS: juur-sk, CN: Juur-SK, EXPIRES: Fri Aug 26 15:23:01 BST 2016, KEYSTORE: /etc/pki/java/cacerts
```

Display expired certificates in /etc/pki/java/cacerts using verbose format:
```
bash-4.3$ ./jkscerts.sh -k /etc/pki/java/cacerts -c -v
ALIAS: staatdernederlandenrootca
OWNER: CN=Staat der Nederlanden Root CA, O=Staat der Nederlanden, C=NL
ISSUER: CN=Staat der Nederlanden Root CA, O=Staat der Nederlanden, C=NL
VALID FROM: Tue Dec 17 09:23:49 GMT 2002 
EXPIRES: Wed Dec 16 09:15:38 GMT 2015
STATUS: CRITICAL
```
