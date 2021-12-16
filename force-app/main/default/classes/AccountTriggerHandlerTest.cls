/************************************* MODIFICATION LOG ********************************************************************************************
* AccountTriggerHandlerTest
*
* DESCRIPTION : Test class for AccountTriggerHandler 
*
*---------------------------------------------------------------------------------------------------------------------------------------------------
* DEVELOPER            						DATE        JIRA NO         Comments
*---------------------------------------------------------------------------------------------------------------------------------------------------
* Acumen Solutions                          4/3/2019	BA-9465         - Original Version 
*
*
*/
@IsTest public with sharing class AccountTriggerHandlerTest {
    
    @IsTest static void deleteAccount()
    {
        
        account master = new account(Name='Accoee',CarrierMC__c='000',BillingCountry = 'Canada',ShippingCountry ='Canada' );
        insert master;
        
        account[] duplicates = new account[]{new account(Name='Duplt1',CarrierMC__c = '111',
                                                         BillingStreet = '233 S 34ave St',
                                                         BillingCity= 'Glendale',BillingState='Arizona',
                                                         BillingPostalCode='85034',BillingCountry = 'United States',
                                                         ShippingStreet = '233 S 34ave St',
                                                         ShippingCity= 'Glendale',ShippingState='Arizona',
                                                         ShippingPostalCode='85034',ShippingCountry = 'United States',
                                                         CarrierDOT__c='111',BrokerMC__c='111',
                                                         BrokerDOT__c = '222',TollFreePhone__c = '4444444444',
                                                         Phone = '5555555555',Fax = '6666666666'),
            new account(Name='Center',CarrierMC__c = '222',
                        BillingStreet = '3456 S 36th St',
                        BillingCity= 'Phoenix',BillingState='Arizona',
                        BillingPostalCode='85034',BillingCountry = 'United States',CarrierDOT__c='111',BrokerMC__c='111',
                        ShippingStreet = '233 S 34ave St',
                        ShippingCity= 'Glendale',ShippingState='Arizona',
                        ShippingPostalCode='85034',ShippingCountry = 'United States',
                        BrokerDOT__c = '222',TollFreePhone__c = '7773332222',
                        Phone = '3339997733',Fax = '3339995333')};
                            insert duplicates;
        
        test.startTest();
        Database.MergeResult[] results = Database.merge(master, duplicates, false);
        test.stopTest();
        
        List<HistoricAccountValue__c> acountBackup = [SELECT Id FROM HistoricAccountValue__c WHERE PriorValue__c = 'Center'];//,'222')];
        System.assertEquals(1,acountBackup.size());
    }
    
      @IsTest static void UpdateAccountHierarchyTest() {
    	//create an account
   		Account acc = new Account();
    	acc.Name = 'Update Hierarchy Test';
    	acc.Phone = '5558409187';
        acc.ParentId = null;
    	insert acc;
  		
       //create an Oppty
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Oppty';
        opp.InquiryMethod__c = 'Chat';
        opp.Type = 'Add Seat';
        opp.AccountId = acc.Id;
        opp.StageName = 'Sent Quote';
        opp.CloseDate = system.today() + 30;
        insert opp;
      
        //create a new quote - this should fire the process to automatically create a contract
        SBQQ__Quote__c qt = new SBQQ__Quote__c();
        qt.SBQQ__Account__c = acc.Id;
        qt.DAT_OSA_Accepted_by_Customer__c = true;
        qt.SBQQ__Status__c = 'Accepted';
        qt.DAT_Contract_Type__c = '1 Month';
        qt.SBQQ__Opportunity2__c = opp.Id;
        insert qt;
    
    	//create a new contract
    	Contract con = new Contract();
    	con.Status = 'Draft';
    	con.StartDate = system.today();
    	con.ContractTerm = 1;
    	con.AccountId = acc.Id;
        con.SBQQ__Quote__c = qt.Id;
    	insert con;
    
    	test.startTest();   
     
    	//Try to add ParentId
    	acc.ParentId = '001M00000181kdIIAQ';
    	update acc; 
      
       test.stopTest();

  }
    
}