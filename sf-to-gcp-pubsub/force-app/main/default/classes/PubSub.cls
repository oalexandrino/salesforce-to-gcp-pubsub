/**
 * Based on https://github.com/aFrag/SalesforceToPubSub
 */
public class PubSub implements Queueable, Database.AllowsCallouts 
{
    /**
     * Serialised data coming from triggers
     */
    @TestVisible       
    private String serializedData;

    /**
     * Action to be performed in GCP, can be 'create' in this example
     */
    @TestVisible       
    private String action;

    /**
     * Metadata name in order to get the appropriate entry from sf metadata
     */
    @TestVisible       
    private String metadataName;

    /**
     * Every push is sent according to a Salesforce Record Id
     */
    @TestVisible       
    private String recordId;  
    
    /**
     * Every push is sent according to a Salesforce Object
     */
    @TestVisible       
    private String salesforceObject;        

    /**
     * Body returned after sending message
     */    
    public PubSubResponseBody responseBody;    

    /**
     * @description PubSub Constructor
     * @author Olavo Alexandrino <oalexandrino@gmail.com>
     * @param  serializedData serializedData description
     * @param  action         action description
     * @param  metadataName   metadataName description
     * @return                return description
     */
    public PubSub(String salesforceObject, String recordId, String serializedData, String action, String metadataName) 
    {
        this.salesforceObject = salesforceObject;
        this.recordId = recordId;
        this.serializedData = serializedData;
        this.action = action;
        this.metadataName = metadataName;
    }    

    /**
     * @description Class to construct the request body to publish to pubsub
     * The body should be {"messages":[{"data": "base64 encoded data" }]}
     * @author Olavo Alexandrino <oalexandrino@gmail.com>
     */    
    class PubSubData 
    {
        String data;
        
        public PubSubData(List<SObject> data, String action)
        {
            List< Map<String, Object>> newData = new List< Map<String, Object>>();
            
            for(SObject d : data)
            {
                //Create a copy of the map because the original is protected
                Map<String, Object> fieldsToValue = new Map<String, Object>(d.getPopulatedFieldsAsMap());
                fieldsToValue.put('action', action);
                newData.add(fieldsToValue);
            }

            String jsonList = JSON.serialize(newData);
            String encodedList = EncodingUtil.base64Encode(Blob.valueof(jsonList));
            this.data = encodedList;
        }
    }

    /**
     * @author Olavo Alexandrino <oalexandrino@gmail.com>
     */
    class PubsubRequest 
    {
        public List<PubSubData> messages = new List<PubSubData>();
        public PubsubRequest(List<SObject> listData, String action)
        {
            PubSubData data = new PubSubData(listData, action);
            messages.add(data);
        }
    }

    public class PubSubResponseBody 
    {
        public List<String> messageIds;
    }

    /**
     * Invokes the GCP Cloud Function
     * @author Olavo Alexandrino <oalexandrino@gmail.com>
     * @param  token          token description
     * @param  pubsubEndpoint pubsubEndpoint description
     */
    @TestVisible    
    private HTTPResponse pushDataToPubsub(String token, String pubsubEndpoint) 
    {
        System.debug('pushDataToPubsub has started...');
        
        List<SObject> deserialisedData = (List<SObject>) JSON.deserialize(this.serializedData, List<SObject>.class);
        PubsubRequest requestMessage = new PubsubRequest(deserialisedData, this.action);

        System.debug('this.serializedData: ' + this.serializedData);
        System.debug('JSON.serialize(requestMessage): ' + JSON.serialize(requestMessage));

        HTTP http = new HTTP();
        HTTPRequest req = new HTTPRequest();
        req.setHeader('Content-Type','application/json');
        req.setHeader('Authorization', 'Bearer ' + token);
        req.setEndpoint(pubsubEndpoint);
        req.setMethod('POST');
        String requestBody = JSON.serialize(requestMessage);
        req.setBody(requestBody);

        HTTPResponse response = new HttpResponse();
        System.debug('POST request to ' + pubsubEndpoint);
        response = http.send(req);
        setSerializedBody(response.getBody());
        createIntegrationSobject(requestBody, response);
        System.debug('PubSub.pushDataToPubsub() Response: ' + response);        
        System.debug('PubSub.pushDataToPubsub() getBody(): ' + response.getBody());
        System.debug('Request has been sent!');        
        return response;
    }

    /**
     * @description Process the new customer record(s). Called asynchronousely by Salesforce when chat(s) are added
     * @author Olavo Alexandrino <oalexandrino@gmail.com>
     * @param context passed by the platform
     */
    public void execute(QueueableContext context) 
    {
        System.debug('GoogleUtils for ' + metadataName);
        GoogleUtils googleUtilsObject = new GoogleUtils(this.metadataName);
        if (googleUtilsObject.authToken != null) 
        {
            this.pushDataToPubsub(
                googleUtilsObject.authToken, 
                googleUtilsObject.audience
            );
        }
    }

    /**
     * @description getSerializedBody description
     * @author Olavo Alexandrino <oalexandrino@gmail.com>
     * @return   return description
     */
    public void setSerializedBody(String body)
    {
        this.responseBody = (PubSubResponseBody) JSON.deserialize(body, PubSubResponseBody.class);
    }

    /**
     * @description createIntegrationSobject description
     * @author Olavo Alexandrino <oalexandrino@gmail.com>
     * @param  response response description
     */
    @TestVisible
    private void createIntegrationSobject(String requestBody, HTTPResponse response)
    {
        // saves the transaction details
        Map<String,String> dataObject   = new Map<String,String>();
        dataObject.put('RecordId', this.recordId);
        dataObject.put('SalesforceObject', this.salesforceObject);
        dataObject.put('ExternalKey', this.responseBody?.messageIds?.get(0));
        dataObject.put('Status', String.valueOf(response.getStatus()));
        dataObject.put('StatusCode', String.valueOf(response.getStatusCode()));
        dataObject.put('ResponseBody', String.valueOf(response.getBody()));
        dataObject.put('RequestBody', String.valueOf(requestBody));
        dataObject.put('IntegrationEventName', 'Publish');
        dataObject.put('IntegrationName', 'GPC');
        IntegrationObjectHelper.createIntegrationSobject(dataObject);  
    }      
}