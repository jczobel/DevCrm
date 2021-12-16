public without sharing class AccountLegalNameUpdateController {
    
    @AuraEnabled
    public static Account loadAccountData(String accountId){       
        if(!String.isEmpty(accountId)){
            Account account = [Select Id, Name, LegalName__c,Business_Type__c,FederalID__c,BrokerMC__c,CarrierMC__c,FreightForwarder__c,IntrastateID__c,IntrastateIDState__c,BrokerDOT__c,
                                         SF_Account_Number__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, Phone from Account where id =:accountId LIMIT 1 ];
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
            System.debug('An exception occured on AccountLegalNameUpdateController.Cause is '+ex.getCause()+'. Message is '+ex.getMessage());
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