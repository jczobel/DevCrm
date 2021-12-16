/************************************* MODIFICATION LOG ********************************************************************************************
* Account Helper
*
* DESCRIPTION : Utility class to manage frequent functions that can be called related account object jc change
*
*---------------------------------------------------------------------------------------------------------------------------------------------------
* DEVELOPER                                 DATE        JIRA#            REASON
*---------------------------------------------------------------------------------------------------------------------------------------------------
* Acumen Solutions                          4/3/2019	                 - Original Version 
* Acumen Solutions                          4/4/2019                    - Changes
*/

public class AccountHelper {
   
    public static list<string> getAccountNumber(integer cnt) {
        List<string> accountNumbers = new list<string>();
        List<Legacy_Number__c> acctNumberList = [select id, legacy_number__c from Legacy_Number__c 
                                                 where Legacy_Type__c = 'Account' order by legacy_number__c asc limit: cnt];
        
        for (Legacy_Number__c ln:acctNumberList ) {
            accountNumbers.add(ln.legacy_number__c);
      }
        
       delete acctNumberList;
        return accountNumbers; 
        
    }
    public static List<string> getCustomerNumber(integer cnt) {
        System.debug('AccountHelper.getCustomerNumber.Count: '+ cnt);
      
        List<string> customerNumbers = new list<string>();
        List<Legacy_Number__c> acctCustomerList = [select id, legacy_number__c from Legacy_Number__c 
                                                   where legacy_Type__c = 'Customer' order by legacy_number__c asc limit: cnt];

        System.debug('AccountHelper.getCustomerNumber.Size: '+ acctCustomerList.size());
        for (Legacy_Number__c ln:acctCustomerList ) {
            customerNumbers.add(ln.legacy_number__c);
        }
        
        delete acctCustomerList;
        return customerNumbers;
    }


}