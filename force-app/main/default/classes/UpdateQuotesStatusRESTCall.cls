public class UpdateQuotesStatusRESTCall implements Queueable, Database.AllowsCallouts{
/* Sample queue job - Call 
List<SBQQ__Quote__c> quotes = [select id from SBQQ__Quote__c where  SBQQ__Status__c  = 'Sent'];
UpdateQuotesStatusRESTCall updateJob = new UpdateQuotesStatusRESTCall(quotes);
ID jobID = System.enqueueJob(updateJob);
*/
    
   	private List<SBQQ__Quote__c> quotes;
   
    public UpdateQuotesStatusRESTCall(list<SBQQ__Quote__c> records){
        this.quotes = records;
    }
    public void execute(QueueableContext context) {
      QuoteRESTCall qs = new QuoteRESTCall();
//a15M0000002fHTHIA2
        for (SBQQ__Quote__c quote : quotes) {
			qs.CallUpdate(quote.id);  
        }
    }
}