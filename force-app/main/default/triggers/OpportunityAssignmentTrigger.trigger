/************************************* MODIFICATION LOG ********************************************************************************************
 * OpportunityAssignmentTrigger 
 * DESCRIPTION : Trigger to change the owner id on an Opportunity when it is changed on the Opportunity Assignment record.
 *---------------------------------------------------------------------------------------------------------------------------------------------------
 * DEVELOPER                                    DATE                   REASON
 *---------------------------------------------------------------------------------------------------------------------------------------------------
 * Acumen Solutions                           1/28/2019           - Original Version
 *
 */
trigger OpportunityAssignmentTrigger on Opportunity_Assignment__c (after update, before update, before insert, after insert) {
/*
    Map<id,id> oppNewOwnerIds = new Map<id,id>();
    List<Opportunity> oppsToUpdate = new List<Opportunity>();
    
    for (Opportunity_Assignment__c oppAssignment : Trigger.NewMap.Values()) {
        string strID = oppAssignment.ownerid;
        if (oppAssignment.Opportunity__c != null && strID.startswith('005'))  {
            oppNewOwnerIds.put(oppAssignment.Opportunity__c,oppAssignment.ownerid);
        }
    }
    
    if (oppNewOwnerIds.size() > 0) {
        for (Opportunity opp : [SELECT ownerid FROM Opportunity WHERE id IN: oppNewOwnerIds.Keyset()]) {
           id newOwnerId = oppNewOwnerIds.get(opp.id);
             if (opp.ownerid != newOwnerId) {
                opp.ownerid = newOwnerId;
                oppsToUpdate.add(opp);
            }
        }   
    }
    if (oppsToUpdate.size() > 0) {
    	update oppsToUpdate;
    }
*/
    if (trigger.isUpdate) {	
    	OpportunityAssignmentTriggerHelper.updateOpportunityOwner(Trigger.newMap);
    }
}