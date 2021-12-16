/************************************* MODIFICATION LOG ********************************************************************************************
* AccountTrigger
*
* DESCRIPTION : General trigger for any DML events on the account object 
*
*---------------------------------------------------------------------------------------------------------------------------------------------------
* DEVELOPER            						DATE        JIRA NO         Comments
*---------------------------------------------------------------------------------------------------------------------------------------------------
* Acumen Solutions                          4/3/2019	BA-9465         - Original Version 
*
*
*
*/

trigger AccountTrigger on Account (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    AccountTriggerHandler accountHandler = new AccountTriggerHandler(true);
   
    if ( Trigger.isDelete && Trigger.isAfter && accountHandler.IsTriggerContext) {
        System.debug('AccountTrigger: Initiate');
        accountHandler.OnAfterDelete(Trigger.old);
    }
    
    if (Trigger.isUpdate && Trigger.isBefore && accountHandler.IsTriggerContext){
        accountHandler.OnBeforeUpdate(Trigger.new, Trigger.OldMap);
    }
}