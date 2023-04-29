@isTest
public class PubSubTest 
{
    public static final String PUB_SUB_TOPIC_NAME = 'topicName';

    @TestSetup
    static void makeData()
    {
        Case objCase = new Case();
        objCase.Subject = 'Test';
        objCase.Status = 'Novo';
        objCase.Origin = 'Web';
        objCase.Reason = 'Outros';
        insert objCase;
    }

    /**
     * @description testQueueable description
     * @author Olavo Alexandrino <oalexandrino@gmail.com>
     */
    @isTest
    static void testPubSubCreation() 
    {
        Test.setMock(HttpCalloutMock.class, new MockForPubSub()); 

        Test.startTest();
        
            Case objCase = [SELECT Id,Subject,Status,Origin,Reason FROM Case LIMIT 1];
            List<Case> caseList = new List<Case>();
            caseList.add(objCase);
            String serialisedCases = JSON.serialize(caseList);
            PubSubHandler.enqueueJob('Case',objCase.Id, serialisedCases, 'OperationName', PUB_SUB_TOPIC_NAME);

            PubSub gcpService = new PubSub(
                'Case',
                objCase.Id,
                serialisedCases, 
                'OperationName', 
                PUB_SUB_TOPIC_NAME
            );            

        Test.stopTest();
    }

    @isTest
    static void testPushDataToPubsub()
    {
        Test.setMock(HttpCalloutMock.class, new MockForPubSub()); 

        Test.startTest();        

            Case objCase = [SELECT Id,Subject,Status,Origin,Reason,WhoIsTheRequester__c FROM Case LIMIT 1];
            List<Case> caseList = new List<Case>();
            caseList.add(objCase);
            String serialisedCases = JSON.serialize(caseList);

            PubSub gcpService = new PubSub(
                'Case',
                objCase.Id,
                serialisedCases, 
                'actionName', 
                PUB_SUB_TOPIC_NAME
            );     
            
            GoogleUtils googleUtilsObject = new GoogleUtils(PUB_SUB_TOPIC_NAME);
            
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