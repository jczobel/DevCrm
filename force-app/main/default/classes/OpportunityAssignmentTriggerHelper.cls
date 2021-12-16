/************************************* MODIFICATION LOG ********************************************************************************************
 * OpportunityAssignmentTriggerHelper
 * DESCRIPTION : Controller class for Opportunity Triggers.
 *---------------------------------------------------------------------------------------------------------------------------------------------------
 * DEVELOPER                                    DATE                   REASON
 *---------------------------------------------------------------------------------------------------------------------------------------------------
 * Acumen Solutions                           1/28/2019           - Original Version
 *
 */
public class OpportunityAssignmentTriggerHelper {

     public static void updateOpportunityOwner(Map<id,Opportunity_Assignment__c> oppAssignments) {
             Map<id,id> oppNewOwnerIds = new Map<id,id>();
    List<Opportunity> oppsToUpdate = new List<Opportunity>();
    
    for (Opportunity_Assignment__c oppAssignment : oppAssignments.Values()) {
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

     }
}