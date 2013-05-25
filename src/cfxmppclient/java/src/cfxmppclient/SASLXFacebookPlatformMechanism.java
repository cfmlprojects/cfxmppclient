package cfxmppclient;

import java.io.IOException;
import java.net.URLEncoder;
import java.util.GregorianCalendar;
import java.util.HashMap;
import java.util.Map;

import javax.security.auth.callback.CallbackHandler;
import javax.security.sasl.Sasl;

import org.jivesoftware.smack.SASLAuthentication;
import org.jivesoftware.smack.XMPPException;
import org.jivesoftware.smack.sasl.SASLMechanism;
import org.jivesoftware.smack.util.Base64;

public class SASLXFacebookPlatformMechanism extends SASLMechanism {

    public static final String NAME = "X-FACEBOOK-PLATFORM";
    private String apiKey = "";
    private String accessToken = "";

    public SASLXFacebookPlatformMechanism(SASLAuthentication saslAuthentication) {
        super(saslAuthentication);
    }

    @Override
    protected void authenticate() throws IOException, XMPPException {
        getSASLAuthentication().send(new AuthMechanism(getName(), ""));
    }

    @Override
    public void authenticate(String apiKey, String host, String accessToken) throws IOException, XMPPException {
    	if( apiKey == null || accessToken == null || apiKey.length() == 0 || accessToken.length() == 0) {
    		throw new IllegalStateException( "Invalid parameters!  API key ("+apiKey+") or accessToken ("+accessToken+") incorrect!" );
    	}
        this.apiKey = apiKey;
        this.accessToken = accessToken;
        this.hostname = host;
        String[] mechanisms = { "DIGEST-MD5" };
        Map<String, String> props = new HashMap<String, String>();
        this.sc = Sasl.createSaslClient(mechanisms, null, "xmpp", host, props, this);
        authenticate();
    }

    @Override
    public void authenticate( String username, String host, CallbackHandler cbh ) throws IOException, XMPPException {
        String[] mechanisms = { "DIGEST-MD5" };
        Map<String, String> props = new HashMap<String, String>();
        this.sc = Sasl.createSaslClient( mechanisms, null, "xmpp", host, props, cbh );
        authenticate();
    }
    
    @Override
    protected String getName() {
        return NAME;
    }

    @Override
    public void authenticate(String username, String host, String serviceName, String password) throws IOException, XMPPException {
        this.apiKey = username;
        this.accessToken = password;
        this.hostname = host;
        String[] mechanisms = { "DIGEST-MD5" };
        Map<String,String> props = new HashMap<String,String>();  
        sc = Sasl.createSaslClient(mechanisms, null, "xmpp", host, props, this);
        authenticate();
    }
    
    @Override
    public void challengeReceived(String challenge) throws IOException {
        byte[] response = null;
        if (challenge != null) {
            String decodedChallenge = new String(Base64.decode(challenge));
            Map<String, String> parameters = getQueryMap(decodedChallenge);

            String version = "1.0";
            String nonce = parameters.get("nonce");
            String method = parameters.get("method");
        	if( apiKey == null || accessToken == null || apiKey.length() == 0 || accessToken.length() == 0) {
        		throw new IllegalStateException( "Invalid parameters!  API key ("+apiKey+") or accessToken ("+accessToken+") incorrect!" );
        	}

            //Long callId = Long.valueOf( System.currentTimeMillis() );
            long callId = new GregorianCalendar().getTimeInMillis() / 1000L;

            String composedResponse = String.format(
                    "method=%s&nonce=%s&access_token=%s&api_key=%s&call_id=%s&v=%s",
                    URLEncoder.encode( method, "UTF-8" ),
                    URLEncoder.encode( nonce, "UTF-8" ),
                    URLEncoder.encode( this.accessToken, "UTF-8" ),
                    URLEncoder.encode( this.apiKey, "UTF-8" ),
                    callId, URLEncoder.encode( version, "UTF-8" ) 
            );
            
            response = composedResponse.getBytes("utf-8");
            //System.out.println(composedResponse);
        }

        String authenticationText = "";

        if (response != null){
            authenticationText = Base64.encodeBytes(response, Base64.DONT_BREAK_LINES);
        }
        getSASLAuthentication().send(new Response(authenticationText));
    }

    private Map<String, String> getQueryMap(String query) {
        Map<String, String> map = new HashMap<String, String>();
        String[] params = query.split("\\&");
        for (String param : params) {
                String[] fields = param.split("=", 2);
                map.put(fields[0], (fields.length > 1 ? fields[1] : null));
        }
        return map;
    }
}