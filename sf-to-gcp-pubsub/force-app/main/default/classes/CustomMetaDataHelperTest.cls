/**
 * @author Olavo Alexandrino <oalexandrino@gmail.com>
 */
@isTest
public with sharing class CustomMetaDataHelperTest 
{
    /**
     * @description testGetMetaData description
     * @author Olavo Alexandrino <oalexandrino@gmail.com>
     */
    @isTest    
    static void testGetMetaDataSuccess() 
    {
        Set<String> fieldsSet = new Set<String>{'Client_Email__c', 'Pubsub_Endpoint__c', 'Token_Endpoint__c'};
        GCP_Key__mdt metadada = (GCP_Key__mdt) CustomMetaDataHelper.getMetaData('GCP_Key__mdt',fieldsSet, 'GPCStagePayableItem');
        System.assertEquals(true, metadada != null, 'There should be a GCP_Key__mdt');
    }

    /**
     * @description testGetMetaData description
     * @author Olavo Alexandrino <oalexandrino@gmail.com>
     */
    @isTest    
    static void testGetMetaDataFail() 
    {
        Set<String> invalidFieldsSet = new Set<String>{};
        try 
        {
            GCP_Key__mdt metadada = (GCP_Key__mdt) CustomMetaDataHelper.getMetaData('GCP_Key__mdt',invalidFieldsSet, 'GPCStagePayableItem');
        }
        catch (Exception ex) 
        {
            String errorDueToInvalidFieldsSet = 'unexpected token: \'FROM\'';
            System.assertEquals(
                true, 
                ex.getMessage().contains(errorDueToInvalidFieldsSet), 
                'Message should contains: ' + errorDueToInvalidFieldsSet
            );
        }
    }    
}