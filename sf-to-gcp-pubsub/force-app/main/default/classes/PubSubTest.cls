@isTest
public class PubSubTest 
{
    public static final String CUSTOM_META_DATA_FOR_PUB_SUB = 'MyPubSubTesting';

    /**
     * @description testQueueable description
     * @author Olavo Alexandrino <oalexandrino@gmail.com>
     */
    @isTest
    static void testPubSubCreation() 
    {
        Test.setMock(HttpCalloutMock.class, new MockForPubSub()); 

        Test.startTest();
            
            Map<String, String> map1 = new Map<String, String>();
            map1.put('name','Olavo Alexandrino');
            map1.put('role','Salesforce Software Developer');
            PubSubHandler.addData(map1);

            Id jobId = PubSubHandler.enqueueJob(
                'Case',
                'a0f5Y00000LucSOQAZ', // related to an internal record id
                'GPCIntegration', 
                'PublishToGooglePubSub', 
                'Insert', 
                CUSTOM_META_DATA_FOR_PUB_SUB
            );          

        Test.stopTest();
    }

    @isTest
    static void testPushDataToPubsub()
    {
        Test.setMock(HttpCalloutMock.class, new MockForPubSub()); 

        Test.startTest();        

            Map<String, String> dataMap = new Map<String, String>();
            dataMap.put('name','Olavo Alexandrino');
            dataMap.put('role','Salesforce Software Developer');

            List<Map<String, String>> dataList = new List<Map<String, String>>();
            dataList.add(dataMap);
            String serializedData = JSON.serialize(dataList);

            PubSub gcpService = new PubSub(
                'Case',
                'a0f5Y00000LucSOQAZ',
                serializedData, 
                'GPCIntegration', 
                'PublishToGooglePubSub', 
                'Insert', 
                CUSTOM_META_DATA_FOR_PUB_SUB
            );     
            
            GoogleUtils googleUtilsObject = new GoogleUtils(CUSTOM_META_DATA_FOR_PUB_SUB);
            
            HTTPResponse response = gcpService.pushDataToPubsub(
                googleUtilsObject.authToken, 
                googleUtilsObject.audience
            );    
            
            PubSub.PubSubResponseBody responseBody = gcpService.responseBody;
            String externalKey = '6102798701179734';
            System.assertEquals(
                externalKey, 
                responseBody.messageIds.get(0)
            );

            Integration__c objIntegration = [SELECT ExternalKey__c FROM Integration__c];
            System.assertEquals(
                externalKey, 
                objIntegration.ExternalKey__c,
                'It should be equals to ' + externalKey
            );                

        Test.stopTest();         
    }

}