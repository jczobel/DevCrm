/************************************* MODIFICATION LOG ********************************************************************************************
* Contact Trigger Handler Test Class
*
* DESCRIPTION : Test class for Contact Trigger Handler 
*
*---------------------------------------------------------------------------------------------------------------------------------------------------
* DEVELOPER                                 DATE       JIRA#            REASON
*---------------------------------------------------------------------------------------------------------------------------------------------------
* Acumen Solutions                          4/3/2019	BA-9465         - Original Version 
*
*
*/
@IsTest public with sharing class ContactTriggerHandlerTest {
    @IsTest static void deleteContact()
    {
        
        Contact master = new Contact(FirstName='Contact', LastName = 'Test',email = 'test@test.com',MailingCountry = 'Canada',OtherCountry = 'Canada');
        insert master;
        
        Contact[] duplicates = new Contact[]{
            new Contact(FirstName='Contact', LastName = 'Test1',email = 'test1@test.com', Phone = '5555555555',
                        MailingStreet = '233 S 34ave St', MailingCity= 'Glendale',
                        MailingState='Arizona', MailingCountry = 'United States', MailingPostalCode='85034',
                        OtherStreet = '233 S 34ave St', OtherCity= 'Glendale',
                        OtherState='Arizona', OtherCountry = 'United States', OtherPostalCode='85034'),
                new Contact(FirstName='Contact2', LastName = 'Test',email = 'test2@test.com', Phone = '5555555555',
                            MailingStreet = '233 S 34ave St', MailingCity= 'Glendale',
                            MailingState='Arizona', MailingCountry = 'United States', MailingPostalCode='85034',
                            OtherStreet = '233 S 34ave St', OtherCity= 'Glendale',
                            OtherState='Arizona', OtherCountry = 'United States', OtherPostalCode='85034')
                };
                    
                    insert duplicates;
        
        test.startTest();
        Database.MergeResult[] results = Database.merge(master, duplicates, false);
        test.stopTest();
        
        List<HistoricContactValue__c> contactBackup = [SELECT Id FROM HistoricContactValue__c WHERE PriorValue__c in(  'test1@test.com','test2@test.com')];
        System.assertEquals(2,contactBackup.size());
    }
    
}