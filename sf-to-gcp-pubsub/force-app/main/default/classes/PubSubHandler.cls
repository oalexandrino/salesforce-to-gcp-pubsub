/**
 * @author Olavo Alexandrino <oalexandrino@gmail.com>
 */
public with sharing class PubSubHandler 
{
    /**
     * @description enqueueJob description
     * @author Olavo Alexandrino <oalexandrino@gmail.com>
     * @param  serialisedObjects    serialisedObjects description
     * @param  pubSubName           pubSubName description
     * @param  triggerOperationType triggerOperationType description
     */
    public static Id enqueueJob(String salesforceObject, String recordId, String serialisedObjects, String integrationName, String eventName, String actionName, String pubSubName)
    {
        PubSub gcpService = new PubSub(
            salesforceObject,
            recordId,
            serialisedObjects, 
            integrationName, 
            eventName, 
            actionName, 
            pubSubName
        );
        
        Id jobID = System.enqueueJob(gcpService);
        return jobID;
    }
}