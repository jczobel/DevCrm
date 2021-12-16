/************************************* MODIFICATION LOG ********************************************************************************************
* Account Trigger Handler
*
* DESCRIPTION : Utility class to manage frequent functions that can be called related account object
*
*---------------------------------------------------------------------------------------------------------------------------------------------------
* DEVELOPER                                 DATE		JIRA#           REASON
*---------------------------------------------------------------------------------------------------------------------------------------------------
* Acumen Solutions                          4/3/2019	BA-9465         - Original Version 
* Acumen Solutions							4/5/2019	BA-9908			- Move the logic in OnAfterDelete to a new method 
* Cindy Faraci                              4/29/2019   BA-9351         - Prevent hierarchy changes when contract exits 
* Cindy Faraci								5/8/2019	BA-10038		- Prevent deletion of only Payment Method
* Acumen Solutions						    5/13/2019	BA-10131		- Capture the current value along with prior value
*/
public class AccountTriggerHandler {
    private boolean m_isExecuting = false;
    private account mAccount;
    private string accountId;
    
    public AccountTriggerHandler(boolean isExecuting){
        m_isExecuting = isExecuting;
    }
    
        public void OnBeforeUpdate(List<Account> newList, Map<Id, Account> OldMap){
       
        Set<Id> changedAccts  = new Set<Id>();
        for(Account acc : newList){      
            if (acc.ParentId != OldMap.get(acc.Id).ParentId){
                changedAccts.add(acc.Id);
           }
        }
            for (Account acc : [Select Id, (select Id from Contracts),(select Id from ChildAccounts) ParentId from Account where Id IN : changedAccts]){
            if (acc.Contracts.size()> 0 || acc.ChildAccounts.size()> 0){
                  for(Account acct : newList) {
                    if (acct.ParentId != Null || acct.ParentId == Null) {
                          acct.adderror('Cannot update account hierarchy due to an existing Contract and/or existing Child account records'); 
                     }
                  }           
 		        }
              } 
     }
  

    public void OnAfterDelete(List<account> oldAccounts){
        // AFTER DELETE LOGIC
        
        // Process for adding Historic value after merge
        createHistoricRecord (oldAccounts);
        
    }
    
    private void createHistoricRecord (List<account> oldAccounts){
        system.debug('AccountTriggerHandler: OnAfterDelete Function');
        list<HistoricAccountValue__c> listAccountBackup = new list<HistoricAccountValue__c>();
        for(Account account : oldAccounts) {
            if(String.isNotBlank(account.MasterRecordId)) { 
                if (accountId != account.MasterRecordId) {
                    accountId = account.MasterRecordId;
                    mAccount = [SELECT MasterRecordId,name,CarrierMC__c,CarrierDOT__c, BrokerMC__c,BrokerDOT__c,TollFreePhone__c,Phone,Fax,
                                BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry,
                                ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode,ShippingCountry
                                FROM account WHERE Id = :account.MasterRecordId];
                }
                if(account.name != null && mAccount.Name != account.name) {
                    listAccountBackup.add(new HistoricAccountValue__c(EntryUser__c = UserInfo.getUserId(),Account__c = account.MasterRecordId,Type__c = 'Account Name',
                                                                      Current_Value__c = mAccount.Name,PriorValue__c = account.name, Description__c = 'Account Name'));
                }
                
                addAddresses(listAccountBackup, account,  mAccount);
                
                if(account.CarrierMC__c != null && account.CarrierMC__c != mAccount.CarrierMC__c ) {
                    listAccountBackup.add(new HistoricAccountValue__c(EntryUser__c = UserInfo.getUserId(),Account__c = accountId,Type__c = 'Carrier MC',
                                                                      Current_Value__c = mAccount.CarrierMC__c,PriorValue__c = account.CarrierMC__c, Description__c = 'Carrier MC'));
                }
                if(account.CarrierDOT__c != null && account.CarrierDOT__c != mAccount.CarrierDOT__c  ) {
                    listAccountBackup.add(new HistoricAccountValue__c(EntryUser__c = UserInfo.getUserId(),Account__c = accountId,Type__c = 'Carrier DOT',
                                                                      Current_Value__c = mAccount.CarrierDOT__c,PriorValue__c = account.CarrierDOT__c, Description__c = 'Carrier DOT'));
                }
                if(account.BrokerMC__c != null && account.BrokerMC__c != mAccount.BrokerMC__c ) {
                    listAccountBackup.add(new HistoricAccountValue__c(EntryUser__c = UserInfo.getUserId(),Account__c = accountId,Type__c = 'Broker MC',
                                                                      Current_Value__c = mAccount.BrokerMC__c,PriorValue__c = account.BrokerMC__c, Description__c = 'Broker MC'));
                }
                if(account.BrokerDOT__c != null && account.BrokerDOT__c != mAccount.BrokerDOT__c) {
                    listAccountBackup.add(new HistoricAccountValue__c(EntryUser__c = UserInfo.getUserId(),Account__c = accountId,Type__c = 'Broker DOT',
                                                                      Current_Value__c = mAccount.BrokerDOT__c,PriorValue__c = account.BrokerDOT__c, Description__c = 'Broker DOT'));
                }
                if(account.TollFreePhone__c != null && account.TollFreePhone__c != mAccount.TollFreePhone__c ) {
                    listAccountBackup.add(new HistoricAccountValue__c(EntryUser__c = UserInfo.getUserId(),Account__c = accountId,Type__c = 'Phone Number',
                                                                      Current_Value__c = mAccount.TollFreePhone__c,PriorValue__c = account.TollFreePhone__c, Description__c = 'Toll Free'));
                }
                if(account.Phone != null && account.Phone != mAccount.Phone ) {
                    system.debug('Master Account Id :'+ accountId +'Deleted Account Id'+ account.Id);
                    system.debug('Master Account Phone :'+ mAccount.Phone +'Deleted Account Phone'+ account.Phone);
                    listAccountBackup.add(new HistoricAccountValue__c(EntryUser__c = UserInfo.getUserId(),Account__c = accountId,Type__c = 'Phone Number',
                                                                      Current_Value__c = mAccount.Phone,PriorValue__c = account.Phone, Description__c = 'Phone'));
                }
                if(account.Fax != null && account.Fax != mAccount.Fax) {
                    listAccountBackup.add(new HistoricAccountValue__c(EntryUser__c = UserInfo.getUserId(),Account__c = accountId,Type__c = 'Phone Number',
                                                                      Current_Value__c = mAccount.Fax,PriorValue__c = account.Fax, Description__c = 'Fax'));
                }
            }         
        }
        system.debug('AccountTriggerHandler: OnAfterDelete:OnAfterDeleteFunction/Size : '+listAccountBackup.size());
        if(listAccountBackup.size() > 0) {
            insert listAccountBackup;
        }        
        
    }
    
    private void addAddresses(list<HistoricAccountValue__c> listAccountBackup,account account, account mAccount){
        if(account.BillingStreet != null && account.BillingStreet != mAccount.BillingStreet) {
            listAccountBackup.add(new HistoricAccountValue__c(EntryUser__c = UserInfo.getUserId(),Account__c = accountId,Type__c = 'Address',
                                                              Current_Value__c = mAccount.BillingStreet,PriorValue__c = account.BillingStreet, Description__c = 'Billing Street'));
        }
        if(account.BillingCity != null && account.BillingCity != mAccount.BillingCity) {
            listAccountBackup.add(new HistoricAccountValue__c(EntryUser__c = UserInfo.getUserId(),Account__c = accountId,Type__c = 'Address',
                                                              Current_Value__c = mAccount.BillingCity,PriorValue__c = account.BillingCity, Description__c = 'Billing City'));
        }
        if(account.BillingState != null && account.BillingState != mAccount.BillingState) {
            listAccountBackup.add(new HistoricAccountValue__c(EntryUser__c = UserInfo.getUserId(),Account__c = accountId,Type__c = 'Address',
                                                              Current_Value__c = mAccount.BillingState,PriorValue__c = account.BillingState, Description__c = 'Billing State'));
        }
        if(account.BillingPostalCode != null && account.BillingPostalCode != mAccount.BillingPostalCode ) {
            listAccountBackup.add(new HistoricAccountValue__c(EntryUser__c = UserInfo.getUserId(),Account__c = accountId,Type__c = 'Address',
                                                              Current_Value__c = mAccount.BillingPostalCode,PriorValue__c = account.BillingPostalCode, Description__c = 'Billing Postal Code'));
        }
        if(account.BillingCountry != null && account.BillingCountry != mAccount.BillingCountry) {
            listAccountBackup.add(new HistoricAccountValue__c(EntryUser__c = UserInfo.getUserId(),Account__c = accountId,Type__c = 'Address',
                                                              Current_Value__c = mAccount.BillingCountry,PriorValue__c = account.BillingCountry, Description__c = 'Billing Country'));
        }
        
        if(account.ShippingStreet != null && account.ShippingStreet != mAccount.ShippingStreet) {
            listAccountBackup.add(new HistoricAccountValue__c(EntryUser__c = UserInfo.getUserId(),Account__c = accountId,Type__c = 'Address',
                                                              Current_Value__c = mAccount.ShippingStreet,PriorValue__c = account.ShippingStreet, Description__c = 'Shipping Street'));
        }
        if(account.ShippingCity != null && account.ShippingCity != mAccount.ShippingCity) {
            listAccountBackup.add(new HistoricAccountValue__c(EntryUser__c = UserInfo.getUserId(),Account__c = accountId,Type__c = 'Address',
                                                              Current_Value__c = mAccount.ShippingCity,PriorValue__c = account.ShippingCity, Description__c = 'Shipping City'));
        }
        if(account.ShippingState != null && account.ShippingState != mAccount.ShippingState) {
            listAccountBackup.add(new HistoricAccountValue__c(EntryUser__c = UserInfo.getUserId(),Account__c = accountId,Type__c = 'Address',
                                                              Current_Value__c = mAccount.ShippingState,PriorValue__c = account.ShippingState, Description__c = 'Shipping State'));
        }
        if(account.ShippingPostalCode != null && account.ShippingPostalCode != mAccount.ShippingPostalCode ) {
            listAccountBackup.add(new HistoricAccountValue__c(EntryUser__c = UserInfo.getUserId(),Account__c = accountId,Type__c = 'Address',
                                                              Current_Value__c = mAccount.ShippingPostalCode,PriorValue__c = account.ShippingPostalCode, Description__c = 'Shipping Postal Code'));
        }
        if(account.ShippingCountry != null && account.ShippingCountry != mAccount.ShippingCountry) {
            listAccountBackup.add(new HistoricAccountValue__c(EntryUser__c = UserInfo.getUserId(),Account__c = accountId,Type__c = 'Address',
                                                              Current_Value__c = mAccount.ShippingCountry,PriorValue__c = account.ShippingCountry, Description__c = 'Shipping Country'));
        }
        
    }
    
    public boolean IsTriggerContext{
        get{ return m_isExecuting;}
    }
}