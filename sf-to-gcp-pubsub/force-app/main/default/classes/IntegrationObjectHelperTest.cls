/***
* @author: Olavo Alexandrino <oalexandrino@gmail.com>
* data: 11/03/2022
*/	
@isTest
public with sharing class IntegrationObjectHelperTest 
{
    /***
    * @author: Olavo Alexandrino <oalexandrino@gmail.com>
    * data: 11/03/2022
    */	
    @isTest    
    static void testcreateIntegrationSobject() 
    {
        Lead objLead = new Lead();
        objLead.FirstName = 'Olavo';
        objLead.LastName = 'Alexandrino';
        objLead.Email = 'oalexandrino@gmail.com';
        objLead.Street = 'Rua ABC, 10';
        objLead.Company = objLead.FirstName + ' ' + objLead.LastName ;
        insert objLead;

        Map<String,String> dataObject   = new Map<String,String>();
        dataObject.put('StatusCode', '200');
        dataObject.put('Status', 'OK');
        dataObject.put('RequestBody', '{body}');
        dataObject.put('ResponseBody', '{response}');
        dataObject.put('ExternalKey', 'external_key');
        dataObject.put('RecordId', objLead.Id);
        dataObject.put('SalesforceObject', 'Lead');
        IntegrationObjectHelper.createIntegrationSobject(dataObject);  
        
        Integration__c objIntegration = [
                SELECT Status__c, StatusCode__c, RequestBody__c, ResponseBody__c, SalesforceObject__c, RecordId__c, ExternalKey__c
                FROM Integration__c Limit 1
        ];

        System.assertEquals(dataObject.get('Status'), objIntegration.Status__c, 'It must be equals to: ' + dataObject.get('Status'));
        System.assertEquals(dataObject.get('StatusCode'), String.valueOf(objIntegration.StatusCode__c) , 'It must be equals to: ' + dataObject.get('StatusCode'));
        System.assertEquals(dataObject.get('RequestBody'), objIntegration.RequestBody__c, 'It must be equals to: ' + dataObject.get('RequestBody'));
        System.assertEquals(dataObject.get('ResponseBody'), objIntegration.ResponseBody__c, 'It must be equals to: ' + dataObject.get('ResponseBody'));
        System.assertEquals(dataObject.get('ExternalKey'), objIntegration.ExternalKey__c, 'It must be equals to: ' + dataObject.get('ExternalKey'));
        System.assertEquals(dataObject.get('RecordId'), objIntegration.RecordId__c, 'It must be equals to: ' + dataObject.get('RecordId'));
        System.assertEquals(dataObject.get('SalesforceObject'), objIntegration.SalesforceObject__c, 'It must be equals to: ' + dataObject.get('SalesforceObject'));
    }
}