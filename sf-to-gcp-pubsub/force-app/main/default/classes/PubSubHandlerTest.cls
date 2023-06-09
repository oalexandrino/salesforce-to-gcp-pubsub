@isTest
public class PubSubHandlerTest 
{
    public static final String CUSTOM_META_DATA_FOR_PUB_SUB = 'MyPubSubTesting';
    /**
     * @description testQueueable description
     * @author Olavo Alexandrino <oalexandrino@gmail.com>
     */
    @isTest
    static void testEnqueueJob() 
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

        List<AsyncApexJob> asyncJobList = [SELECT Id, ApexClass.Name, JobType, Status from AsyncApexJob where ApexClass.Name = 'PubSub'];
        System.assertEquals(1, asyncJobList.size());
        System.assertEquals(
            jobId, 
            asyncJobList.get(0).Id,
            'It should be equals to ' + String.valueOf(jobId)
        );
    }
}