/************************************* MODIFICATION LOG ********************************************************************************************
* Helper Class for Contract Trigger
*
* DESCRIPTION : Helper class for Contract Trigger
*
*---------------------------------------------------------------------------------------------------------------------------------------------------
* DEVELOPER                                 DATE            JIRA#       	REASON
*---------------------------------------------------------------------------------------------------------------------------------------------------
* Acumen Solutions                          4/4/2019            			- Original Version
*
*/
public class ContractTriggerHelper {
    
    public static void updateAccount(Map<Id,sObject> newContracts, Map<Id,sObject> oldContracts) {
        //Update Contract and Account Id's from Legacy object for accounts in activated contracts
        updateAccountContractIds ( newContracts,  oldContracts);
    }
    
    private static void updateAccountContractIds(Map<Id,sObject> newContracts, Map<Id,sObject> oldContracts){
        
        List <Account> contractAccounts = new list<Account> ();
        List <Account> contractAccountsWOParent = new list<Account> ();
        List <Account> contractAccountsWParent = new list<Account> ();
        Map <Id,Account> UpdateAcctsMap = new Map <Id,Account> ();
        Set <id> acctIds = new Set<id>();
        
        //only add to the acctIds if the contract status has changed (check for old val vs. new val)
        System.debug('ContractTriggerHelper: Check Old and new status');
        for ( Id contractId : newContracts.keyset()) {
            contract oldContract = (contract)oldContracts.get(contractId);
            contract newContract = (contract)newContracts.get(contractId);
            
            if (oldContract.status != newContract.status && newContract.status == 'Activated'){
                if (!acctIds.contains(newContract.accountid)) {acctIds.add(newContract.accountid);}
            }
        }
        
        //if the account has a parent id, need to check the parent's account id.  if the parent's account id is null, 
        //update the parent and the child account ids
        if (acctIds.size() > 0) {
            
            //Update Customer Id : Get all customer Id that are null. Get a number for Customer Id and update
            System.debug('ContractTriggerHelper: Update Customer Id');
            contractAccounts = [select id, AccountID__C, CustomerID__c,ParentId from Account 
                                where id in :acctIds and CustomerID__c = null ];
            if(!contractAccounts.isEmpty()){
                System.debug('ContractTriggerHelper.UpdateCustomerIds.TotalSize: '+ contractAccounts.size());
                list<string> mapContractId = new list<string> (AccountHelper.getCustomerNumber(contractAccounts.size()));
                for (Account account : contractAccounts){
                    UpdateMap('CustomerId',account,UpdateAcctsMap,mapContractId);
                    System.debug('ContractTriggerHelper.UpdateCustomerIds.CustomerID__c: '+ account.CustomerID__c + ', Size: '+ UpdateAcctsMap.size());
                }
            }
            
            // Update Account Id for Account without parent: loop through to see if the fields are empty.  if so, the get an number for account Id 
            System.debug('ContractTriggerHelper: Update Account Id for Account without parent');
            contractAccountsWOParent = [select id, AccountID__C, CustomerID__c,ParentId from Account 
                                        where id in :acctIds and ParentId = null and AccountID__C = null];
            if(!contractAccountsWOParent.isEmpty()){
                list<string> mapAccountIdWOParent = new list<string> (AccountHelper.getAccountNumber(contractAccountsWOParent.size()));
                System.debug('ContractTriggerHelper.UpdateAccountIdsWOParent.TotalSize: '+ mapAccountIdWOParent.size());
                for (Account account : contractAccountsWOParent){
                    UpdateMap('AccountId',account,UpdateAcctsMap,mapAccountIdWOParent);
                    System.debug('ContractTriggerHelper.UpdateAccountIdsWOParent.AccountID__C: '+ account.AccountID__C + ', Size: '+ UpdateAcctsMap.size());
                }            
            }
            
            // Update Account Id for Account with parent: 
            // For Account Id : populate children with parents account number. If Parent is null then update it from metadata
            System.debug('ContractTriggerHelper: Update Account Id for Account with parent');
            list<account> parentAccount = [select Id from Account where  ParentId != null and id in :acctIds];
            if(!parentAccount.isEmpty()){
                Set<Id> parentId = new Map<Id, AggregateResult>([select parentId Id from Account 
                                                                 where id in :acctIds 
                                                                 group by parentId having ParentId != null]).keySet();
                
                // Set map(id,accountid_string), pass list of account
                for (account paccount:[select id, AccountID__C from Account where Id in :parentId and AccountID__C = null ]){
                    list<string> mapAccountIdWParent = new list<string> (AccountHelper.getAccountNumber(parentId.size()));
                    UpdateMap('AccountId',paccount,UpdateAcctsMap,mapAccountIdWParent);
                    System.debug('ContractTriggerHelper.updateAccountIdsWParent.AccountID__C: '+ paccount.AccountID__C + ', Size: '+ UpdateAcctsMap.size());
                    
                    for(account caccount:[select id, AccountID__C from Account where parentId in :parentId and AccountID__C = null ]){
                        //Update child accountId with parent accountId
                        if (UpdateAcctsMap.containskey(caccount.Id)){
                            account mapAccount = UpdateAcctsMap.get(caccount.Id);
                            mapAccount.AccountID__C = UpdateAcctsMap.get(paccount.Id).AccountID__c;
                            
                            UpdateAcctsMap.remove(caccount.Id);
                            UpdateAcctsMap.put(caccount.Id,mapAccount);
                            System.debug('ContractTriggerHelper.updatemapAccountIdChild.AccountID__C: '+ mapAccount.AccountID__C  + ', Size: '+ UpdateAcctsMap.size());                           
                            
                        }else{
                            caccount.AccountID__C = UpdateAcctsMap.get(paccount.Id).AccountID__c;  
                            UpdateAcctsMap.put(caccount.Id,caccount);
                            System.debug('ContractTriggerHelper.insertmapAccountIdChild.AccountID__C: '+ caccount.AccountID__C  + ', Size: '+ UpdateAcctsMap.size());                           
                        }
                    }
                }
            }
        }
        
        System.debug('ContractTriggerHelper.updateAccount.MapSize : '+ UpdateAcctsMap.size());
        if (UpdateAcctsMap.size() >0){
            update  UpdateAcctsMap.values();
        }
        
        
    }
    
    private static void UpdateMap(string process, Account account,Map <Id,Account> UpdateAcctsMap, list<string> getNumber )
    {
        if (UpdateAcctsMap.containskey(account.Id)){
            account mapAccount = UpdateAcctsMap.get(account.Id);
            
            if (process == 'CustomerId') {mapAccount.CustomerID__c = getNumber.get(0);}
            if (process == 'AccountId')  {mapAccount.AccountID__C = getNumber.get(0);}
            UpdateAcctsMap.remove(account.Id);
            UpdateAcctsMap.put(account.Id,mapAccount);
            
        }else{
            if (process == 'CustomerId') {account.CustomerID__c = getNumber.get(0);}
            if (process == 'AccountId')  {account.AccountID__C = getNumber.get(0);}
            UpdateAcctsMap.put(account.Id,account);
        }
        getNumber.remove(0);
        
    }
}