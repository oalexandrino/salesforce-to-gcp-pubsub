@isTest
public class PubSubTest 
{
    @TestSetup
    static void makeData()
    {
        Case objCase = new Case();
        objCase.Subject = 'Test';
        objCase.Status = 'Novo';
        objCase.Origin = 'Web';
        objCase.Category__c = 'Informações gerais';
        objCase.Reason = 'Outros';
        objCase.WhoIsTheRequester__c = 'Estudante';
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
        
            Case objCase = [SELECT Id,Subject,Status,Origin,Category__c,Reason,WhoIsTheRequester__c FROM Case LIMIT 1];
            List<Case> caseList = new List<Case>();
            caseList.add(objCase);
            String serialisedCases = JSON.serialize(caseList);
            PubSubHandler.enqueueJob('Case',objCase.Id, serialisedCases, 'OperationName', System.Label.GPCPayableItem);

            PubSub gcpService = new PubSub(
                'Case',
                objCase.Id,
                serialisedCases, 
                'OperationName', 
                System.Label.GPCPayableItem
            );            

        Test.stopTest();
    }

    @isTest
    static void testPushDataToPubsub()
    {
        Test.setMock(HttpCalloutMock.class, new MockForPubSub()); 

        Test.startTest();        

            Case objCase = [SELECT Id,Subject,Status,Origin,Category__c,Reason,WhoIsTheRequester__c FROM Case LIMIT 1];
            List<Case> caseList = new List<Case>();
            caseList.add(objCase);
            String serialisedCases = JSON.serialize(caseList);

            PubSub gcpService = new PubSub(
                'Case',
                objCase.Id,
                serialisedCases, 
                'actionName', 
                System.Label.GPCPayableItem
            );     
            
            GoogleUtils googleUtilsObject = new GoogleUtils(System.Label.GPCPayableItem);
            
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