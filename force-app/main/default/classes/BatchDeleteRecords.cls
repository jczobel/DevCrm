/************************************* MODIFICATION LOG ********************************************************************************************
* BatchDeleteRecords
*
* DESCRIPTION : Batch proces that is scheduled to run.  Validates whether a contact or account can be deleted. 
*
*---------------------------------------------------------------------------------------------------------------------------------------------------
* DEVELOPER                     DATE           JIRA#                            REASON
*---------------------------------------------------------------------------------------------------------------------------------------------------
* JC and Cindy                  4/19/2019      BA-9567 and BA-9754          - Original Version 
*
*
*/
public class BatchDeleteRecords implements Database.Batchable<sObject> {
    public string query;
    public string objectType;
    //public BatchDeleteRecords(string query) {
        //query = this.query;
    //}   
    public Database.QueryLocator start(Database.BatchableContext bc) {
    // Locate accounts and contacts with a status of Invalid
    //string query = 'SElECT ID, (select ID from ChildAccounts), (select ID from Cases), (select ID from Contracts), (select ID from Opportunities), (select ID from SBQQ__Quotes__r), Delete_Validation_Result__c, AccountID__c, CustomerID__c From Account Where Status__c = \'Invalid\' ';
    //string query = 'SELECT ID, (select AccountId, ContactId from AccountContactRelations), (select ID from Opportunities__r), (select ID,Agreement_Signer__c, Freight_Matching_Contact__c,Billing_Contact__c,SBQQ__PrimaryContact__c from SBQQ__Quotes__r), Delete_Validation_Result__c FROM CONTACT Where Status__c = \'Invalid\' ';    
       return Database.getQueryLocator(query);    
       }   
        
      public void execute(Database.BatchableContext bc, List<sObject> recordList){        
      //Schema.DescribeSObjectResult describeSobjectsResult = Schema.describeSObjects(recordList[0]); // this can accept list of strings, we describe only one object here
        //  String objectLabel = describeSobjectsResult[0].getLabel(); 
          //system.debug('test' + objectLable);
         
          if(objectType == 'Account') {
            List<Account> acctList = new List<Account>();
            for(sObject o : recordList) {
                  Account a = (Account)o;
                acctList.add(a);
            }
            processAccounts(acctList);
          }
          
             if(objectType == 'Contact') {
            List<Contact> contList = new List<Contact>();
            for(sObject o : recordList) {
                  Contact c = (Contact)o;
                contList.add(c);
            }
            processContacts(contList);
          }
        

    }
 private void processAccounts(List<Account> accList) {
        //paste Cindy's logic here;
        List<Account> accountsToUpdate = new List<Account>();
        List<Account> accountsToDelete = new List<Account>();
        for (Account a : accList) {
            string msg ='CF';
            if (a.AccountID__c != null) {
                //a.Delete_Validation_Result__c = 'Account ID is Populated';
                msg = 'Account ID is populated. ';
            }
              if (a.CustomerID__c != null) {
                  
                  //a.Delete_Validation_Result__c = a.Delete_Validation_Result__c + 'Customer ID is Populated';
                  msg += 'Customer ID is populated. ';
              }
           
            if (a.Cases.size() > 0) {
                
                msg += 'Existing Cases. ';
                
               }
            
            if (a.Contracts.size() > 0) {
                
                msg += 'Existing Contracts. ';
                
               }
            
            if (a.SBQQ__Quotes__r.size() > 0) {
                
                msg += 'Existing Quotes. ';
                
            }
             if (a.Opportunities.size() > 0) {
                
                msg += 'Existing Opportunities. ';
                
            }
             if (a.ChildAccounts.size() > 0) {
                
                msg += 'Existing Child Accounts. ';
                
            }
           
            if (msg != 'CF') {      
                a.Delete_Validation_Result__c = msg.remove('CF');
                
                accountsToUpdate.add(a);
            }
            else {
               accountsToDelete.add(a);
            }
    }
        if (accountsToUpdate.size() > 0) {
            update accountsToUpdate;
        }
        if (accountsToDelete.size() > 0) {
            delete accountsToDelete;
        }

    }

    private void processContacts(List<Contact> contList) {
       // system.debug('JC After Private void processContacts.');
        List<Contact> contactsToUpdate = new List<Contact>();
        List<Contact> contactsToDelete = new List<Contact>();
        System.debug('Starting processContacts');
   //string query = 'SELECT ID, (select AccountId, ContactId from AccountContactRelations), (select ID from Opportunities__r), (select ID,Agreement_Signer__c, Freight_Matching_Contact__c,Billing_Contact__c,SBQQ__PrimaryContact__c from SBQQ__Quotes__r), Delete_Validation_Result__c FROM CONTACT Where Status__c = \'Invalid\' ';    
        For (Contact c : contList){
        string msg ='JC';
          // system.debug('JC After String msg.');  
          // if (c.AccountContactRelations.size() > 0) {
                
            //}
            
           List<id> acctIDs = new List<id>();
            List<AccountContactRelation> acrList = c.AccountContactRelations; 
            for  (AccountContactRelation acrID : c.AccountContactRelations) {
               acctIDs.add(acrID.accountid);
           }
               
            // list <AccountContactRelation> acc = [select contactId from AccountContactRelation ];
         //system.debug('JC Before the accountRel.'); 
            //Hey JC - please check to make sure that this works with the acctIds.size() == 0
            //If there is 0 Account then the contact can be deleted
                 list <Account> accList = [ select id, (select id from AccountContactRelations) from account where id in: acctIds ];
            for (Account a : accList) { 
                if (a.AccountContactRelations.size() == 1) {
                   msg = 'Only contact on the account. ';
                } 
            }
        
            if (c.Opportunities__r.size() > 0) {
                
                msg += 'Has associated Opportunities. ';
                
            }
            
            if (c.SBQQ__Quotes__r.size() > 0) {
                
                msg += 'Has associated Quotes. ';
                
            }
            
            if (msg != 'JC') {              
                c.Delete_Validation_Result__c = msg.remove('JC');
                contactsToUpdate.add(c);
            }
            else {
               contactsToDelete.add(c);
            }
           }
             //system.debug('JC After For Loop.'); 
        if (contactsToUpdate.size() > 0) {
            update contactsToUpdate;
        }
        if (contactsToDelete.size() > 0) {
            delete contactsToDelete;
        }
         // System.debug('end of processContacts');
    }
  
    public void finish(Database.BatchableContext bc){
        //Execute any post-processesing operations
    }
}