@istest (seealldata=true)
public class OpportunityAssignmentTriggerTest {
    static testmethod void changeOppOwner(){
        list < opportunity_assignment__c > oppassignment = [select id, ownerid from opportunity_assignment__c];
    	list <user> newuser = [select id from user where firstname = 'Cindy'];
        system.debug('what is the size?' + oppassignment.size());
        oppAssignment[0].ownerid = newuser[0].id;
        update oppassignment;
    }
    

}