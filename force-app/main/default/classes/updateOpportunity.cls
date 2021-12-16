global without sharing class updateOpportunity {
    @InvocableMethod (label = 'Update Won Lost Reason')
    public static void WonLostReason(List<CustomRequest> CustomRequests) {
        list<Opportunity> oplist = new list<Opportunity>();
        for (customrequest cr:customRequests){
            Opportunity Op = [ SELECT id,wonlostreason__c FROM Opportunity where id =: cr.opportunityId ];
            op.WonLostReason__c = cr.quoteWinLossReason;
            Oplist.add(op);
        }
         update oplist;
    }
    
global class CustomRequest {
  @InvocableVariable(required=true)
    global ID opportunityId;
  @InvocableVariable(required=true)
    global ID quoteID;
  @InvocableVariable (required=true)
    global string quoteWinLossReason;
  }    
}