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

List all certificates in /usr/java/jre1.8.0_45/lib/security/cacerts:
```
bash-4.3$ ./jkscerts.sh -k /usr/java/jre1.8.0_45/lib/security/cacerts
OK - ALIAS: addtrustclass1ca, CN: AddTrust Class 1 CA Root, EXPIRES: Sat May 30 11:38:31 BST 2020, KEYSTORE: /usr/java/jre1.8.0_45/lib/security/cacerts
OK - ALIAS: addtrustexternalca, CN: AddTrust External CA Root, EXPIRES: Sat May 30 11:48:38 BST 2020, KEYSTORE: /usr/java/jre1.8.0_45/lib/security/cacerts
OK - ALIAS: addtrustqualifiedca, CN: AddTrust Qualified CA Root, EXPIRES: Sat May 30 11:44:50 BST 2020, KEYSTORE: /usr/java/jre1.8.0_45/lib/security/cacerts
OK - ALIAS: affirmtrustcommercialca, CN: AffirmTrust Commercial, EXPIRES: Tue Dec 31 14:06:06 GMT 2030, KEYSTORE: /usr/java/jre1.8.0_45/lib/security/cacerts
OK - ALIAS: affirmtrustnetworkingca, CN: AffirmTrust Networking, EXPIRES: Tue Dec 31 14:08:24 GMT 2030, KEYSTORE: /usr/java/jre1.8.0_45/lib/security/cacerts
OK - ALIAS: affirmtrustpremiumca, CN: AffirmTrust Premium, EXPIRES: Mon Dec 31 14:10:36 GMT 2040, KEYSTORE: /usr/java/jre1.8.0_45/lib/security/cacerts
..
..
```

Show certificates in /etc/pki/java/cacerts due to expire in the next 3 months:
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

List expired certificates in /etc/pki/java/cacerts using verbose format:
```
bash-4.3$ ./jkscerts.sh -k /etc/pki/java/cacerts -c -v
ALIAS: staatdernederlandenrootca
OWNER: CN=Staat der Nederlanden Root CA, O=Staat der Nederlanden, C=NL
ISSUER: CN=Staat der Nederlanden Root CA, O=Staat der Nederlanden, C=NL
VALID FROM: Tue Dec 17 09:23:49 GMT 2002 
EXPIRES: Wed Dec 16 09:15:38 GMT 2015
STATUS: CRITICAL
```

## TROUBLESHOOTING

If you get the following error:
```
-bash-4.1$ ./jkscerts.sh -k ./demokeystore.jks 
Exception in thread "main" java.lang.UnsupportedClassVersionError: ChangeSourceKeystorePassword : Unsupported major.minor version 52.0
	at java.lang.ClassLoader.defineClass1(Native Method)
	at java.lang.ClassLoader.defineClass(ClassLoader.java:792)
	at java.security.SecureClassLoader.defineClass(SecureClassLoader.java:142)
	at java.net.URLClassLoader.defineClass(URLClassLoader.java:449)
	at java.net.URLClassLoader.access$100(URLClassLoader.java:71)
	at java.net.URLClassLoader$1.run(URLClassLoader.java:361)
	at java.net.URLClassLoader$1.run(URLClassLoader.java:355)
	at java.security.AccessController.doPrivileged(Native Method)
	at java.net.URLClassLoader.findClass(URLClassLoader.java:354)
	at java.lang.ClassLoader.loadClass(ClassLoader.java:424)
	at sun.misc.Launcher$AppClassLoader.loadClass(Launcher.java:308)
	at java.lang.ClassLoader.loadClass(ClassLoader.java:357)
	at sun.launcher.LauncherHelper.checkAndLoadMain(LauncherHelper.java:482)
```

Then recompile the java classes as shown here with your own version of java:
```
-bash-4.1$ javac ChangeSourceKeystorePassword.java JKS.java
Note: JKS.java uses unchecked or unsafe operations.
Note: Recompile with -Xlint:unchecked for details.
-bash-4.1$ ls *.class
ChangeSourceKeystorePassword.class  JKS.class
```
