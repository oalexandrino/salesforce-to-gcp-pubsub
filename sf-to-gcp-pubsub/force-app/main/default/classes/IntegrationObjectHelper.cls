/***
* @author: Olavo Alexandrino <oalexandrino@gmail.com>
* data: 10/03/2022
*/	
public with sharing class IntegrationObjectHelper 
{
    /***
    * @author: Olavo Alexandrino <oalexandrino@gmail.com>
    * data: 10/03/2022
    */    
    public static Integration__c createIntegrationSobject(Map<String,String> dataObject)
    {
        Integration__c objIntegration = new Integration__c();
        objIntegration.Status__c           = dataObject.get('Status');
        if (dataObject.get('StatusCode') != null ) 
        {
            objIntegration.StatusCode__c   = Decimal.valueOf(dataObject.get('StatusCode'));
        }
        objIntegration.RequestBody__c           = dataObject.get('RequestBody');
        objIntegration.SerializedRequestBody__c = dataObject.get('SerializedRequestBody');
        objIntegration.ResponseBody__c          = dataObject.get('ResponseBody');
        objIntegration.SalesforceObject__c      = dataObject.get('SalesforceObject');
        objIntegration.RecordId__c		        = dataObject.get('RecordId');        
        objIntegration.ExternalKey__c           = (dataObject.get('ExternalKey') == null) ? '' : dataObject.get('ExternalKey');
        objIntegration.IntegrationName__c		= dataObject.get('IntegrationName');        
        objIntegration.IntegrationEventName__c	= dataObject.get('IntegrationEventName');        

        insert objIntegration;

        System.debug('IntegrationSobject was created...');

        return objIntegration;
    }
}