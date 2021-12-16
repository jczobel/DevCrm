/************************************* MODIFICATION LOG ********************************************************************************************
* CustomerDetailController
*
* DESCRIPTION :
*
*---------------------------------------------------------------------------------------------------------------------------------------------------
* DEVELOPER                                 DATE        JIRA#            REASON
*---------------------------------------------------------------------------------------------------------------------------------------------------
* Acumen Solutions                          5/15/2019                     - Original Version 
*
*/

public without sharing class CustomerDetailController {
    
    @AuraEnabled
    public static Id getAccountId(String quoteId){ 
        SBQQ__Quote__c quote = [select name, SBQQ__Account__r.Id FROM SBQQ__Quote__c where id = :quoteId];
        return quote.SBQQ__Account__r.Id;
    }

    @AuraEnabled
    public static SBQQ__Quote__c loadQuoteData(String quoteId){ 
        if(!String.isEmpty(quoteId)){
            SBQQ__Quote__c quote = [Select Billing_Contact__r.firstName,Billing_Contact__r.lastName,Billing_Contact__r.Phone, 
                                          Agreement_Signer__r.firstName,Agreement_Signer__r.lastName,Agreement_Signer__r.Phone
                                FROM SBQQ__Quote__c where id = :quoteId LIMIT 1 ];
            return quote;
        }
        return new SBQQ__Quote__c();
    }

    
    @AuraEnabled
    public static Account loadAccountData(String accountId){       
        if(!String.isEmpty(accountId)){
            Account account = [Select Id, Name, LegalName__c,Business_Type__c,FederalID__c,BrokerMC__c,CarrierMC__c,FreightForwarder__c,IntrastateID__c,IntrastateIDState__c,BrokerDOT__c,
                                         SecondaryBillingEmailAddress__c,PrimaryBillingEmailAddress__c,CarrierDOT__c,SF_Account_Number__c, BillingStreet, BillingCity, BillingState, 
                                         BillingPostalCode, Phone from Account where id =:accountId LIMIT 1 ];
            return account;
        }
        return new Account();
    } 
    
    @AuraEnabled
    public static Boolean saveAccountData(Account accountObj){
        try{
            if(accountObj != null) 
                UPDATE accountObj;
            return true;
        }
        catch(Exception ex){
            System.debug('An exception occured on CustomerDetailController.Cause is '+ex.getCause()+'. Message is '+ex.getMessage());
            return false;
        }
    } 
    
    
    @AuraEnabled
    public static List<String> getBustinessTypePicklistValues() {
        List <String> allOpts = new list <String> ();
        Schema.DescribeFieldResult fieldResult =
            Account.Business_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple) {
            allOpts.add(f.getValue());
        }       
        return allOpts;
    }
}