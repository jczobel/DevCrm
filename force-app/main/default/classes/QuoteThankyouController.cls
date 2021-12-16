/************************************* MODIFICATION LOG ********************************************************************************************
* QuoteDetailController
*
* DESCRIPTION : Class that drives the Quote Detail Page in the OSA site
*
*---------------------------------------------------------------------------------------------------------------------------------------------------
* DEVELOPER                                 DATE        JIRA#            REASON
*---------------------------------------------------------------------------------------------------------------------------------------------------
* Acumen Solutions                          4/3/2019                     - Original Version 
*
*/
public class QuoteThankyouController {
	public SBQQ__Quote__c quote {get;set;}
    public Blob Body {get;set;} // Used for test class only
    private string quoteId;
    private string quoteName;
    public QuoteThankyouController() {
         quoteId = System.currentPageReference().getParameters().get('quoteID');
       	 system.debug('QuoteThankyouController:Input Parameter: '+quoteId);
        
         if (quoteId== null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Missing quote information. Cannot continue'));
        }else{
            // need to pass the id from the page, Display error message
            list<SBQQ__Quote__c> quotes = [ select name, DAT_OSA_Accepted_by_Customer__c, SBQQ__Notes__c,SBQQ__Status__c, 
                                           SBQQ__ExpirationDate__c, SBQQ__Opportunity2__c, SBQQ__Account__r.name, 
                                           owner.name, owner.phone, owner.email, SBQQ__BillingName__c, SBQQ__CustomerAmount__c
                                           from SBQQ__Quote__c where id = :quoteId]; //'a0q3F000000U4vPQAS'];
        
            if (quotes.size()>0) {
                quote = quotes[0];
                quoteName = quote.Name;
            }else
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ' No quote information found. Cannot proceed'));
            }

        }        
   
    }

    public  void savePDFQuote(string quoteid){

            PageReference pdfPage = new PageReference('/apex/QuotePDF?quoteid='+quoteid);
        	if (!Test.isRunningTest()) {Body = pdfPage.getContent();}
            
            Blob pdfContent = Body ;//
            
            ContentVersion conVer = new ContentVersion();
            //conVer.ContentLocation = 'S'; 
            conVer.PathOnClient = 'Quote-'+ this.quoteName+'.pdf'; 
            conVer.Title = 'Quote-'+ this.quoteName ; 
            conVer.VersionData = pdfContent; 
            insert conVer;        
            
            // First get the content document Id from ContentVersion
            Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
            
            //Create ContentDocumentLink
            ContentDocumentLink cDe = new ContentDocumentLink();
            cDe.ContentDocumentId = conDoc;
            cDe.LinkedEntityId = quoteId; // you can use objectId,GroupId etc
            cDe.ShareType = 'I'; // Inferred permission, checkout description of ContentDocumentLink object for more details
            cDe.Visibility = 'AllUsers';
            insert cDe;
    }
    
    Public PageReference Generatepdf() {
		// quoteId
        try {  
            
            //System.debug('Calling SavePDFQuote');
            //savePDFQuote (quoteid);
            
            PageReference page = new PageReference('/apex/QuotePDF?quoteid='+quoteid);
            page.setredirect(true);
            return page;
        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'The following exception has occurred: ' + 
                                                       e.getMessage()+ '. Stack Trace :' +e.getStackTraceString()));
            return null;
        }
        
    }    
}