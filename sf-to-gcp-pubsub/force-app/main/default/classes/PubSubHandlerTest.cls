@isTest
public class PubSubHandlerTest 
{
    /**
     * @description testQueueable description
     * @author Olavo Alexandrino <oalexandrino@gmail.com>
     */
    @isTest
    static void testEnqueueJob() 
    {
        String customMetaNameForPubSub = 'MyPubSubTesting';
        Test.setMock(HttpCalloutMock.class, new MockForPubSub()); 

        Test.startTest();
        
            Case objCase = new Case();
            objCase.Subject = '31/10/22';
            objCase.Status = 'Novo';
            objCase.Origin = 'Web';
            objCase.Reason = 'Outros';
            insert objCase;

            List<Case> caseList = new List<Case>();
            caseList.add(objCase);
            String serialisedCases = JSON.serialize(caseList);
            
            Id jobId = PubSubHandler.enqueueJob(
                'Case',
                objCase.Id,
                serialisedCases, 
                'IntegrationName', 
                'EventName', 
                'Action', 
                customMetaNameForPubSub
            );

        Test.stopTest();

        List<AsyncApexJob> asyncJobList = [SELECT Id, ApexClass.Name, JobType, Status from AsyncApexJob where ApexClass.Name = 'PubSub'];
        System.assertEquals(1, asyncJobList.size());
        System.assertEquals(
            jobId, 
            asyncJobList.get(0).Id,
            'It should be equals to ' + String.valueOf(jobId)
        );
    }
}