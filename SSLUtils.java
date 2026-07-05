import java.net.URL;
import java.security.SecureRandom;
import java.security.cert.CertificateException;
import java.security.cert.X509Certificate;
import javax.net.ssl.HostnameVerifier;
import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.KeyManager;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLSession;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;
import java.io.BufferedReader;
import java.io.InputStreamReader;

public class WebLogicSSLTest {
    
    public static void main(String[] args) {
        if (args.length != 1) {
            System.out.println("Usage: java WebLogicSSLTest <weblogic-url>");
            System.out.println("Example: java WebLogicSSLTest https://weblogic-server:7002");
            System.exit(1);
        }

        String url = args[0];
        try {
            // Configure the SSLContext with a TrustManager
            SSLContext ctx = SSLContext.getInstance("TLS");
            ctx.init(new KeyManager[0], new TrustManager[] {new DefaultTrustManager()}, new SecureRandom());
            SSLContext.setDefault(ctx);

            // Create URL connection
            URL serverUrl = new URL(url);
            HttpsURLConnection conn = (HttpsURLConnection) serverUrl.openConnection();
            conn.setHostnameVerifier((hostname, session) -> true);
            
            // Set connection properties
            conn.setRequestMethod("GET");
            conn.setConnectTimeout(5000);
            conn.setReadTimeout(5000);

            // Connect and get response
            System.out.println("Connecting to: " + url);
            int responseCode = conn.getResponseCode();
            System.out.println("Response Code: " + responseCode);
            
            // Read response
            try (BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream()))) {
                String inputLine;
                StringBuilder response = new StringBuilder();
                while ((inputLine = in.readLine()) != null) {
                    response.append(inputLine);
                }
                System.out.println("Server Response: " + response.toString());
            }

            // Get server info
            System.out.println("\nServer Details:");
            System.out.println("Protocol: " + conn.getProtocol());
            System.out.println("Cipher Suite: " + conn.getCipherSuite());
            System.out.println("Server Certificate: " + conn.getServerCertificates()[0]);

        } catch (Exception e) {
            System.out.println("Error connecting to WebLogic server:");
            e.printStackTrace();
        }
    }
    
    private static class DefaultTrustManager implements X509TrustManager {
        @Override
        public void checkClientTrusted(X509Certificate[] chain, String authType) throws CertificateException {}

        @Override
        public void checkServerTrusted(X509Certificate[] chain, String authType) throws CertificateException {}

        @Override
        public X509Certificate[] getAcceptedIssuers() {
            return new X509Certificate[0];
        }
    }
}
