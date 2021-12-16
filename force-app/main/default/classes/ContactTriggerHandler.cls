/************************************* MODIFICATION LOG ********************************************************************************************
* Contant Helper
*
* DESCRIPTION : Utility class to manage frequent functions that can be called related contact object
*
*---------------------------------------------------------------------------------------------------------------------------------------------------
* DEVELOPER                                 DATE       JIRA#            REASON
*---------------------------------------------------------------------------------------------------------------------------------------------------
* Acumen Solutions                          4/3/2019	BA-9465         - Original Version 
* Acumen Solutions                          4/5/2019	BA-9922         - Move process from OnAfterDelete to a separate function 
* Acumen Solutions						    5/13/2019	BA-10131		- Capture the current value along with prior value
*
*/
public with sharing  class ContactTriggerHandler {
    private boolean m_isExecuting = false;
    private contact mContact;
    private string contactId;
    
    public ContactTriggerHandler(boolean isExecuting){
        m_isExecuting = isExecuting;
    }
    
    public void OnAfterDelete(List<contact> oldContacts){
        // AFTER DELETE LOGIC
        
        // Process for adding Historic value after merge
        createMergeHistory(oldContacts);
        
        
    }
    
    
    // Process for adding Historic value after merge
    private void createMergeHistory(List<contact> oldContacts){
        system.debug('ContactTriggerHandler: OnAfterDelete');
        list<HistoricContactValue__c> listContactBackup = new list<HistoricContactValue__c>();

        for(Contact contact : oldContacts) {
            if(String.isNotBlank(contact.MasterRecordId)) { 
                if(contactId != contact.MasterRecordId){
                    contactId = contact.MasterRecordId;
                    mContact = [SELECT Id,Name, FirstName,LastName, Phone, email,
                                OtherStreet, OtherCity, OtherState,OtherPostalCode,OtherCountry, 
                                MailingStreet, MailingCity, MailingState,MailingPostalCode,MailingCountry 
                                FROM contact WHERE Id = :contact.MasterRecordId];
                }
                
                addAddresses (listContactBackup,contact,mContact);
                
                System.debug('ContactTriggerHandler.OnAfterDelete: Name/Master Name: '+ contact.FirstName + ', '+ contact.LastName + '/' + mcontact.FirstName + ', '+ mcontact.LastName);
                if((contact.FirstName != null && contact.FirstName != mContact.FirstName ) || 
                   (contact.LastName != null && contact.LastName != mContact.LastName)) {
                       listContactBackup.add(new HistoricContactValue__c(EntryUser__c = UserInfo.getUserId(),Contact__c = contactId,Type__c = 'Name',
                                                                         Current_Value__c = mContact.FirstName+ ' ' + mContact.LastName ,
                                                                         PriorValue__c = contact.FirstName + ' '+ contact.LastName, 
                                                                         ContactLastText__c = contact.Name, 
                                                                         Description__c = 'Name'));
                   }
                
                if(contact.Phone != null && contact.Phone != mContact.Phone) {
                    listContactBackup.add(new HistoricContactValue__c(EntryUser__c = UserInfo.getUserId(),Contact__c = contactId,Type__c = 'Phone',
                                                                      Current_Value__c = mContact.Phone ,PriorValue__c = contact.Phone,  
                                                                      PhoneSearch__c = contact.Phone,
                                                                      Description__c = 'Phone'));
                }
                if(contact.email != null && contact.email != mContact.email ) {
                    listContactBackup.add(new HistoricContactValue__c(EntryUser__c = UserInfo.getUserId(),Contact__c = contactId,Type__c = 'Email',
                                                                      Current_Value__c = mContact.email ,PriorValue__c = contact.email,
                                                                      EmailSearch__c = contact.email,
                                                                      Description__c = 'Email'));
                }
            }         
        }
        if(listContactBackup.size() > 0) {
            insert listContactBackup;
        }        
        
        
    }
    
    private void addAddresses (list<HistoricContactValue__c>listContactBackup,contact contact, contact mContact){
        if(contact.MailingStreet != null && contact.MailingStreet != mContact.MailingStreet) {
            listContactBackup.add(new HistoricContactValue__c(EntryUser__c = UserInfo.getUserId(),Contact__c = contactId,Type__c = 'Address',
                                                              Current_Value__c = mContact.MailingStreet ,PriorValue__c = contact.MailingStreet,  
                                                              Description__c = 'Street'));
        }
        
        if(contact.MailingCity != null && contact.MailingCity != mContact.MailingCity ) {
            listContactBackup.add(new HistoricContactValue__c(EntryUser__c = UserInfo.getUserId(),Contact__c = contactId,Type__c = 'Address',
                                                              Current_Value__c = mContact.MailingCity ,PriorValue__c = contact.MailingCity,  
                                                              Description__c = 'City'));
        }
        
        if(contact.MailingState != null && contact.MailingState != mContact.MailingState ) {
            listContactBackup.add(new HistoricContactValue__c(EntryUser__c = UserInfo.getUserId(),Contact__c = contactId,Type__c = 'Address',
                                                              Current_Value__c = mContact.MailingState ,PriorValue__c = contact.MailingState,  
                                                              Description__c = 'State'));
        }
        
        if(contact.MailingPostalCode != null && contact.MailingPostalCode != mContact.MailingPostalCode) {
            listContactBackup.add(new HistoricContactValue__c(EntryUser__c = UserInfo.getUserId(),Contact__c = contactId,Type__c = 'Address',
                                                              Current_Value__c = mContact.MailingPostalCode ,PriorValue__c = contact.MailingPostalCode,  
                                                              Description__c = 'Postal Code'));
        }
        
        if(contact.MailingCountry != null && contact.MailingCountry != mContact.MailingCountry ) {
            listContactBackup.add(new HistoricContactValue__c(EntryUser__c = UserInfo.getUserId(),Contact__c = contactId,Type__c = 'Address',
                                                              Current_Value__c = mContact.MailingCountry ,PriorValue__c = contact.MailingCountry,  
                                                              Description__c = 'Country'));
        }
        if(contact.OtherStreet != null && contact.OtherStreet != mContact.OtherStreet) {
            listContactBackup.add(new HistoricContactValue__c(EntryUser__c = UserInfo.getUserId(),Contact__c = contactId,Type__c = 'Address',
                                                              Current_Value__c = mContact.OtherStreet ,PriorValue__c = contact.OtherStreet,  
                                                              Description__c = 'Other Street'));
        }
        
        if(contact.OtherCity != null && contact.OtherCity != mContact.OtherCity ) {
            listContactBackup.add(new HistoricContactValue__c(EntryUser__c = UserInfo.getUserId(),Contact__c = contactId,Type__c = 'Address',
                                                              Current_Value__c = mContact.OtherCity ,PriorValue__c = contact.OtherCity,  
                                                              Description__c = 'Other City'));
        }
        
        if(contact.OtherState != null && contact.OtherState != mContact.OtherState ) {
            listContactBackup.add(new HistoricContactValue__c(EntryUser__c = UserInfo.getUserId(),Contact__c = contactId,Type__c = 'Address',
                                                              Current_Value__c = mContact.OtherState ,PriorValue__c = contact.OtherState,  
                                                              Description__c = 'Other State'));
        }
        
        if(contact.OtherPostalCode != null && contact.OtherPostalCode != mContact.OtherPostalCode) {
            listContactBackup.add(new HistoricContactValue__c(EntryUser__c = UserInfo.getUserId(),Contact__c = contactId,Type__c = 'Address',
                                                              Current_Value__c = mContact.OtherPostalCode ,PriorValue__c = contact.OtherPostalCode,  
                                                              Description__c = 'Other Postal Code'));
        }
        
        if(contact.OtherCountry != null && contact.OtherCountry != mContact.OtherCountry ) {
            listContactBackup.add(new HistoricContactValue__c(EntryUser__c = UserInfo.getUserId(),Contact__c = contactId,Type__c = 'Address',
                                                              Current_Value__c = mContact.OtherCountry ,PriorValue__c = contact.OtherCountry,  
                                                              Description__c = 'Other Country'));
        }
        
    }
    
    public boolean IsTriggerContext{
        get{ return m_isExecuting;}
    }
}