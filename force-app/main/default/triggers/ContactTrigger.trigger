/************************************* MODIFICATION LOG ********************************************************************************************
* Contact Trigger
*
* DESCRIPTION : General trigger for any DML events on the contact object 
*
*---------------------------------------------------------------------------------------------------------------------------------------------------
* DEVELOPER                                 DATE       JIRA#            REASON
*---------------------------------------------------------------------------------------------------------------------------------------------------
* Acumen Solutions                          4/3/2019	BA-9465         - Original Version 
*
*
*/
trigger ContactTrigger on Contact (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    ContactTriggerHandler contactHandler = new ContactTriggerHandler(true);

    if ( Trigger.isDelete && Trigger.isAfter && contactHandler.IsTriggerContext) {
        System.debug('ContactTrigger: Initiate');
        contactHandler.OnAfterDelete(Trigger.old);
    }
}