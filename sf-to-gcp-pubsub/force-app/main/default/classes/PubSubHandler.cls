/**
 * @author Olavo Alexandrino <oalexandrino@gmail.com>
 */
public with sharing class PubSubHandler 
{
    public static List<Map<String, String>> dataList = new List<Map<String, String>>();
    public static String serializedData;

    public static void addData(Map<String, String> mapData)
    {
        dataList.add(mapData);
    }

    /**
     * @description enqueueJob description
     * @author Olavo Alexandrino <oalexandrino@gmail.com>
     * @param  serialisedObjects    serialisedObjects description
     * @param  pubSubName           pubSubName description
     * @param  triggerOperationType triggerOperationType description
     */
    public static Id enqueueJob(String salesforceObject, String recordId, String integrationName, String eventName, String actionName, String pubSubName)
    {
        PubSubHandler.serializedDAta = JSON.serialize(PubSubHandler.dataList);

        PubSub gcpService = new PubSub(
            salesforceObject,
            recordId,
            PubSubHandler.serializedData, 
            integrationName, 
            eventName, 
            actionName, 
            pubSubName
        );
        
        Id jobID = System.enqueueJob(gcpService);
        return jobID;
    }
}