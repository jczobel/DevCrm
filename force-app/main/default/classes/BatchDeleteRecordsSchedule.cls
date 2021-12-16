global class BatchDeleteRecordsSchedule implements Schedulable {
        global void execute (SchedulableContext ctx){
    
        BatchDeleteRecords batchDel = new BatchDeleteRecords(); 
        batchDel.objectType = 'Account';
        batchDel.query = 'SELECT ID, (select ID from ChildAccounts), (select ID from Cases), (select ID from Contracts), (select ID from Opportunities), (select ID from SBQQ__Quotes__r), Delete_Validation_Result__c, AccountID__c, CustomerID__c From Account Where Status__c = \'Invalid\' ';
        Database.executeBatch(batchDel);
        batchDel.objectType = 'Contact' ;
        batchdel.query = 'SELECT ID, (select AccountID, ContactId from AccountContactRelations), (select ID from Opportunities__r), (select ID,Agreement_Signer__c, Freight_Matching_Contact__c,Billing_Contact__c,SBQQ__PrimaryContact__c from SBQQ__Quotes__r), Delete_Validation_Result__c FROM CONTACT Where Status__c = \'Invalid\' ';
        Database.executeBatch(batchDel);
     }
}