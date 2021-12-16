/************************************* MODIFICATION LOG ********************************************************************************************
* BatchDeleteRecordsTest
*
* DESCRIPTION : Test the BatchDeleteRecords batch process. 
*
*---------------------------------------------------------------------------------------------------------------------------------------------------
* DEVELOPER                     DATE           JIRA#                            REASON
*---------------------------------------------------------------------------------------------------------------------------------------------------
* JC and Cindy                  4/19/2019      BA-9567 and BA-9754          - Original Version 
*
*
*/

@isTest
public class BatchDeleteRecordsTest {
    @testSetup
    static void dataSetUp() {
        List<Account> aList = new List<Account>();
        List<Account> aParentList = new List<Account>();
        List<Case> cList = new List<Case>();
        List<Opportunity> oList = new List<Opportunity>();
        List<SBQQ__Quote__c> qList = new List<SBQQ__Quote__c>(); 
        List<Contact> conList = new List<Contact>();
        
        for (integer i = 0; i < 10; i++) {
            Account newAccount;
            if (i < 5) {
                newAccount = new Account(Name = 'Parent', 
                                         Phone = '5558409187', Status__c = 'Invalid', 
                                         AccountID__c = '123456');
            }
            else {
                newAccount = new Account(Name = 'Parent', 
                                         Phone = '5558409187', Status__c = 'Invalid');
            }
                aParentList.add(newAccount);
        }
        insert aParentList;
       
        for (integer i = 0; i < 5; i++) {
            Account newAccount = new Account(Name = 'ChildWithAccountID', 
                                             Phone = '5558409187', Status__c = 'Invalid', 
                                             AccountID__c = '123456', parentId = aParentList[i].id);
            aList.add(newAccount);      
         }       
        
        for (integer i = 0; i < 5; i++) {
            Account newAccount = new Account(Name = 'ChildWithCustomerID', Phone = '5558409187', 
                                                Status__c = 'Invalid', CustomerID__c = '123456', parentId = aParentList[i + 1].id);
            aList.add(newAccount);
          }

          for (integer i = 0; i < 50; i++) {
            Account newAccount = new Account(Name = 'AccountNoDependencies', Phone = '5558409187', 
                                                Status__c = 'Invalid');
            aList.add(newAccount);
          }   
       insert aList;
            
       Contact newCon;
        
        for(integer i = 0; i < 5; i++) {
            newCon = new Contact(FirstName = 'JC', LastName = 'Zobel', Phone = '5558409187', Status__c = 'Invalid', accountid = aList[i].id); 
            conList.add(newCOn);
            }
            newCon = new Contact(FirstName = 'JC', LastName = 'Zobel', Phone = '5558409187', Status__c = 'Invalid', accountid = aList[0].id); 
            conList.add(newCOn);
        	insert conList;
    
          for (integer i = 0; i < 2; i++) {
            Case newCase = new Case(Status = 'Open',
                                Subject = 'Delete Test', Type = 'Login Issue',
                                 AccountId = aList[i + 1].id);
              cList.add(newCase);
          }
        insert cList;
        
         for (integer i = 0; i < 2; i++){
            Opportunity newOppty = new Opportunity(Name = 'Delete Test', Type = 'Add Seat',
                                                   InquiryMethod__c = 'Chat', StageName = 'Prospecting',
                                                   CloseDate = system.today(), AccountId = aList[i + 1].id , PrimaryContact__c = conList[i].id);
              oList.add(newOppty);
          }
        insert oList;
        
         for (integer i = 0; i < 2; i++){
            SBQQ__Quote__c newQuote = new SBQQ__Quote__c(DAT_Contract_Type__c = '1 Month',
                                       SBQQ__Account__c = aList[i + 1].id, Agreement_Signer__c = conList[i].id,SBQQ__PrimaryContact__c = conList[i + 1].id );
              qList.add(newQuote);
          }
        insert qList;
           
	}
    static testmethod void testDeleteAccountMethod() {
    
        Test.startTest();
            BatchDeleteRecords oBDR = new BatchDeleteRecords();
                oBDR.query = 'SELECT ID, (select ID from ChildAccounts), (select ID from Cases), (select ID from Contracts), (select ID from Opportunities), (select ID from SBQQ__Quotes__r), Delete_Validation_Result__c, AccountID__c, CustomerID__c From Account Where Status__c = \'Invalid\' ';
                oBDR.objectType = 'Account';
            Database.executeBatch(oBDR);
        Test.stopTest();
        boolean isChildWithAccountID = false;
        boolean isChildWithCustomerID = false;
        boolean isDelete = true;
        boolean hasCase = false;
        boolean hasOppty = false;
        boolean hasQuote = false;
        
        for (Account a : [select id, name, Delete_Validation_Result__c, (select Id from Cases) from Account ]) {
            if (a.name == 'ChildWithAccountID' && a.Delete_Validation_Result__c.contains('Account ID')) {
                isChildWithAccountID = true;
            }
               if (a.name == 'ChildWithCustomerID' && a.Delete_Validation_Result__c.contains('Customer ID')) {
                isChildWithCustomerID = true;
            }
            if (a.name == 'AccountNoDependencies') {
                isDelete = false;
            }
            if (a.Cases.size() > 0 && a.Delete_Validation_Result__c.contains('Cases')){
                hasCase = true;
            }
            if (a.Opportunities.size() > 0 && a.Delete_Validation_Result__c.contains('Opportunities')){
                hasOppty = true;
            }
            if (a.SBQQ__Quotes__r.size() > 0 && a.Delete_Validation_Result__c.contains('Quotes')){
                hasQuote = true;
            }
              
        }
            system.assert(isChildWithAccountID,'ChildWithAccountIDDeleted');
            system.assert(isChildWithCustomerID,'ChildWithCustomerIDDeleted');
            system.assert(isDelete,'Account was not Deleted');
            system.assert(hasCase,'Account with Case was deleted or message wasnt updated');

         
    }
    
    static testmethod void testDeleteContactMethod(){
          
      system.debug('start the test delete method');
         
        
         Test.startTest();
         BatchDeleteRecords cBDR = new BatchDeleteRecords();        
         cBDR.query = 'SELECT ID, (select AccountID, ContactID from AccountContactRelations), (select ID, PrimaryContact__c from Opportunities__r), (select ID, Agreement_Signer__c,Freight_Matching_Contact__c, Billing_Contact__c from SBQQ__Quotes__r), Delete_Validation_Result__c FROM CONTACT Where Status__c = \'Invalid\' ';
         cBDR.objectType = 'Contact';
          Database.executeBatch(cBDR);
        Test.stopTest();
        
        boolean hasAcc = false;
        boolean hasQt = false;
        boolean hasOpp = false;
        
        for (Contact c : [select id, Name, Delete_Validation_Result__c, (select AccountID, ContactID from AccountContactRelations), (select ID, PrimaryContact__c from Opportunities__r),
                          (select ID, Agreement_Signer__c,Freight_Matching_Contact__c, Billing_Contact__c from SBQQ__Quotes__r) from Contact ]) {
            
            if (c.AccountContactRelations.size() > 0 && c.Delete_Validation_Result__c != null && c.Delete_Validation_Result__c.contains('Only contact')){
                hasAcc = true;
                // system.debug('Account True');
            }
             //system.debug('Account false');
             
            if (c.Opportunities__r.size() > 0 && c.Delete_Validation_Result__c != null && c.Delete_Validation_Result__c.contains('Opportunities')){
                hasOpp = true;
            }
            
            if (c.SBQQ__Quotes__r.size() > 0 && c.Delete_Validation_Result__c != null && c.Delete_Validation_Result__c.contains('Quotes')){
                hasQt = true;
                  
            }
            //system.debug('Quote false');
        }
  //system.debug('before Assert');
            system.assert(hasQt,'Quote Records that are associated with a contact was not updated');
            system.assert(hasAcc,'Contact with Account was deleted or message was not updated'); 
            system.assert(hasOpp,'Contact with Opp was deleted or message was not updated');
             //system.debug('After Assert');  
        
    }
}