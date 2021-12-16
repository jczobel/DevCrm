trigger ContractTrigger on Contract (Before insert,After insert,Before update,After update) {
    Boolean success;
    if (Trigger.isUpdate && Trigger.isAfter) {
        System.debug('ContractTrigger: Initiate');
      //  ContractTriggerHelper.updateAccount(trigger.newmap,trigger.oldmap);
    }
}