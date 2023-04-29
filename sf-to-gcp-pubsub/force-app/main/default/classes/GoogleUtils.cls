/**
 * @author Olavo Alexandrino <oalexandrino@gmail.com>
 * Based on https://github.com/aFrag/SalesforceToPubSub
 */
public class GoogleUtils 
{
    /**
     * JWTBearerTokenExchange still is unable to set a Mockup for Callouts
     * https://ideas.salesforce.com/s/idea/a0B8W00000GdcXHUAZ/ability-to-unit-test-authjwtbearertokenexchangegetaccesstoken
     */
    public final static String TEST_ACCESS_TOKEN = 'IN TEST';

    /**
     * gcpPartition name is set on the gcpPartition file under cachePartitions folder and default size is 1mb 
     * More details on Salesforce Setup -> quick search -> Platform Cache  
     */
    private static String gpcCacheAccessTokenName;

    /**
     * DeveloperName of API Custom Metada Data for storing GPC settings
     */
    private final static String METADATA_NAME = 'GCP_Key__mdt'; // no need to put in CustomLabels    

    /**
     * Local var for GoogleAuthResponse
     */
    private GoogleAuthResponse googleAuthResponse;

    /**
     * Class to deserialise response from the Google token URL and get the ID Token
     */
    public class GoogleAuthResponse 
    {
        public String access_token;
    }

    private GCP_Key__mdt serviceAccount;

    /**
     * @description GoogleUtils description
     * @author Olavo Alexandrino <oalexandrino@gmail.com>
     * @param  metadata_name metadata_name description
     * @return               return description
     */
    public GoogleUtils(String metaDataName)
    {
        Set<String> fieldsSet       = new Set<String>{'Client_Email__c', 'Pubsub_Endpoint__c', 'Token_Endpoint__c','Scopes__c','GPCCacheAccessTokenName__c'};

        this.serviceAccount = (GCP_Key__mdt) CustomMetaDataHelper.getMetaData(
            METADATA_NAME,
            fieldsSet, 
            metaDataName
        );

        gpcCacheAccessTokenName = this.serviceAccount.GPCCacheAccessTokenName__c;        
        this.audience           = this.serviceAccount.Pubsub_Endpoint__c;
        this.scopes             = this.serviceAccount.Scopes__c;
        this.authToken          = getGCPAuthToken().access_token;
    }

    public String scopes 
    {
        get 
        { 
            return scopes; 
        }
        set 
        {
            scopes = value;
        }
    }  

    public String authToken 
    {
        get { return authToken; }
        set { authToken = value; }
    }  
     
    public String audience 
    {
        get { return audience; }
        set { audience = value; }
    }       
    
    /**
     * @description createBearerObject description
     * @author Olavo Alexandrino <oalexandrino@gmail.com>
     * @param  serviceAccount serviceAccount description
     * @return                return description
     */
    @TestVisible
    private Auth.JWTBearerTokenExchange createBearerObject()
    {
        Auth.JWT jwt = new Auth.JWT();

        jwt.setAud(this.serviceAccount.Token_Endpoint__c);
        jwt.setIss(this.serviceAccount.client_email__c);

        // Additional claims to set scope
        Map<String, Object> claims = new Map<String, Object>();
        claims.put('scope', this.scopes);
        jwt.setAdditionalClaims(claims);

        // Create the object that signs the JWT bearer token
        Auth.JWS jws = new Auth.JWS(jwt, 'google_cloud');

        // Get the resulting JWS in case debugging is required
        String token = jws.getCompactSerialization();

        // Set the token endpoint that the JWT bearer token is posted to
        String tokenEndpoint = this.serviceAccount.Token_Endpoint__c;       
        
        Auth.JWTBearerTokenExchange bearer = new Auth.JWTBearerTokenExchange(tokenEndpoint, jws); 

        return bearer;
    }
    
    /**
    * Constructs the JWT and invokes the Google Auth endpoint
    * @param serviceAccount has the GCP keys obtained from the
    * custom metadata object
    * @return the auth response from GCP containing the id token
    */
   public GoogleAuthResponse getGCPAuthToken() 
   {
        this.googleAuthResponse              = new GoogleAuthResponse();
        this.googleAuthResponse.access_token = this.getCacheAccessToken();

        if (this.googleAuthResponse.access_token != null) 
        {
            System.debug('Returning cached access token...');
            return this.googleAuthResponse;
        } 
        else 
        {
            System.debug('Getting a new access token...');

            Auth.JWTBearerTokenExchange bearer = this.createBearerObject();

            if (!Test.isRunningTest()) 
            {
                System.HttpResponse response = bearer.getHTTPResponse();
                System.debug('response.getBody() for getGCPAuthToken(): ' + response.getBody());
                this.googleAuthResponse = (GoogleAuthResponse) JSON.deserialize(response.getBody(), GoogleAuthResponse.class);
            } 
            else 
            {
                this.googleAuthResponse.access_token = TEST_ACCESS_TOKEN;
            }

            cacheAccessToken(this.googleAuthResponse.access_token);
            return this.googleAuthResponse;
        }
   }

   /**
    * @description getCacheAccessToken description
    * @author Olavo Alexandrino <oalexandrino@gmail.com>
    * @return   return description
    */
    public String getCacheAccessToken()
    {
        return (String) Cache.Org.get(gpcCacheAccessTokenName);
    }   

   /**
    * Caches an access token in org cache so future API requests don't need to get a new token.
    * Compared to using Custom Settings, updating the org cache doesn't require a DML operation
    * and can be interleaved between callouts. The cache also handles expiration for us.
    */
   public static void cacheAccessToken(String accessToken) 
   {
       // Cache the access token in the default org cache with a TTL of 30 seconds less than its expiration
       Cache.Org.put(gpcCacheAccessTokenName, accessToken, 3600 - 30);
   }
   
   /**
    * @description  Proactively clear the access token from the Custom Settings cache.
                    This won't invalidate the previous access token on Google's side, but it will remove it from
                    our cache so that future requests will be forced to fetch a new token.
    * @author Olavo Alexandrino <oalexandrino@gmail.com>
    * @return   return description
    */
   public static Boolean clearAccessToken() 
   {
       return Cache.Org.remove(gpcCacheAccessTokenName);
   }
}