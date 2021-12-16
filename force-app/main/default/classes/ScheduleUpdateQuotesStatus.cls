global class ScheduleUpdateQuotesStatus Implements Schedulable {
    
    global void execute(SchedulableContext SC){
        List<SBQQ__Quote__c> quotes = [select id from SBQQ__Quote__c where DAT_OSA_Accepted_by_Customer__c = true 
                                       and SBQQ__Status__c  = 'Sent' and Batch_Processed__c != true];
        UpdateQuotesStatus updateJob = new UpdateQuotesStatus(quotes);
        ID jobID = System.enqueueJob(updateJob);
    }

}