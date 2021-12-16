public class UpdateQuotesStatus implements Queueable {
    private List<SBQQ__Quote__c> quotes;
   
    public UpdateQuotesStatus(list<SBQQ__Quote__c> records){
        this.quotes = records;
    }
    public void execute(QueueableContext context) {
        for (SBQQ__Quote__c quote : quotes) {
          quote.DAT_OSA_Accepted_by_Customer__c = True;
          //  quote.SBQQ__Status__c  = 'Accepted';
            //quote.SBQQ__Primary__c   = true;
            //quote.SBQQ__ordered__c = true;
            //quote.Batch_Processed__c = true;
        }
        Database.SaveResult[] SRList = Database.update(quotes, false);
        
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully updated quote. Quote ID: ' + sr.getId());
            }
            else {
                // Operation failed, so get all errors
                //failedQuotesIds.add(sr.getId());
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Quote fields that affected this error: ' + err.getFields());
                }
            }
        } 
        
        list<SBQQ__Quote__c> processedQuotes = new list<SBQQ__Quote__c>();
        system.debug('Falied quotes and list :'+ quotes.size()+ quotes  );
        for (SBQQ__Quote__c quote : quotes) {
            quote.Batch_Processed__c = true;
            processedQuotes.add(quote);
        }
        update(processedQuotes);
    }
}