# jkscertscanner
Checks certificates in a java keystore without having to know the keystore password.

I got the idea for this from https://gist.github.com/zach-klippenstein/4631307 which provided code to change the password on a keystore without having to know the original keystore password.
This does not affect the password on private keys but does enable the user to list and view the public certificates on a keystore.

## How to run

Run git clone to download the repo.

From the repo directory, run /jkscertscanner.sh <keystore>

```
bash-4.3$ ./jkscertscanner.sh keystore.jks 

Alias name: linuxproblems
Owner: CN=linuxproblems.org, OU=ssl administration, O=linuxproblems, L=London, ST=Unknown, C=GB
Issuer: CN=linuxproblems.org, OU=ssl administration, O=linuxproblems, L=London, ST=Unknown, C=GB
Valid from: Sat Oct 15 09:19:30 BST 2011 
Expires: Fri Jan 13 08:19:30 GMT 2012 (CRITICAL)
```

This will not change the original keystore so it is safe to run. 
It makes a temporary copy of the keystore, setting the password to 'secret' and then deletes this straight after the script completes.
