import java.util.*;
import java.io.*;
import java.security.*;

public class ChangeSourceKeystorePassword
{
  private final static JKS j = new JKS();

  public static void main(String[] args) throws Exception
  {
    if (args.length < 2)
    {
      System.out.println("Usage: java ChangePassword keystoreFile newKeystoreFile");
      return;
    }

    String keystoreFilename = args[0];
    String newFilename = args[1];
    String passwd = "secret";
    
    InputStream in = new FileInputStream(keystoreFilename);
    j.engineLoad(in, passwd.toCharArray());
    in.close();

    OutputStream out = new FileOutputStream(newFilename);
    j.engineStore(out, passwd.toCharArray());
    out.close();
  }

}

