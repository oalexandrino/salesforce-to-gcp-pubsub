/**
 * @author Olavo Alexandrino <oalexandrino@gmail.com>
 */
public with sharing class CustomMetaDataHelper 
{
    /**
     * @description getMetaData description
     * @author Olavo Alexandrino <oalexandrino@gmail.com>
     * @param  metaDataObjectName metaDataObjectName description
     * @param  masterLabel        masterLabel description
     * @return                    return description
     */
    public static SObject getMetaData(String metaDataObjectName, Set<String> fieldsSet, String masterLabel) 
    {
        SObject metadada;

        String fields      = String.valueOf(fieldsSet).replace('{', '').replace('}', '');
        metaDataObjectName = String.escapeSingleQuotes(metaDataObjectName);
        masterLabel        = String.escapeSingleQuotes(masterLabel);

        String metadataSOQL     = 'SELECT '+fields+' FROM '+metaDataObjectName+' WHERE MasterLabel = \'' + masterLabel + '\'' ;
        List<sObject> sobjList  = Database.query(metadataSOQL);
    
        if (sobjList.size() > 0) 
        {
            metadada = sobjList[0];
        }             

        return metadada;
    }
}