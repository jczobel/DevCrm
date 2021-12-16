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
public class QuoteAcceptController {
    public SBQQ__Quote__c quote {get;set;}
    public boolean quoteAccepted {get;set;}
    public boolean certifyAgreement {get;set;}
    public boolean certifyPrivaryPolicy {get;set;}
    public boolean certifySubscription {get;set;}
    public Blob Body {get;set;} // Used for test class only
    private string quoteId;
    private string quoteName;
    public boolean displayPopup {get; set;}
    public boolean modalClose {get; set;}
    private RecordAccessController rac;
    public string m {get;set;}
    public List<Opportunity> opp;

    
    Public QuoteAcceptController (){

        quoteId = System.currentPageReference().getParameters().get('quoteID');
        system.debug('OSACOntroller:Input Parameter: '+quoteId);

        if (quoteId== null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Missing quote information. Cannot continue'));
            displayPopup = true;
            modalClose = false;
        }else{
            // need to pass the id from the page, Display error message
            list<SBQQ__Quote__c> quotes = [ select name, DAT_OSA_Accepted_by_Customer__c,  
                                           SBQQ__Notes__c,SBQQ__Status__c, SBQQ__ExpirationDate__c,  SBQQ__Primary__c,
                                           SBQQ__Opportunity2__c, SBQQ__Account__r.id, SBQQ__Account__r.name, tmpSiteQuotePM__c,
                                           owner.name, owner.phone, owner.email, SBQQ__BillingName__c, SBQQ__CustomerAmount__c
                                           from SBQQ__Quote__c where id = :quoteId]; //'a0q3F000000U4vPQAS'];
        
            if (quotes.size()>0) {
                displayPopup = false;
                quote = quotes[0];
                quoteName = quote.Name;

                //Check for Quote status - 'Sent'
                if (quote.SBQQ__Status__c != 'Sent' ){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please verify the quote. Cannot continue'));
                    displayPopup = true;modalClose = false;
                }
                
                //Check for Quote Expiration
                if(quote.SBQQ__ExpirationDate__c < Date.today()){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Quote is expired. Cannot continue'));
                    displayPopup = true;modalClose = false;
                }

                
                
                if (quote.DAT_OSA_Accepted_by_Customer__c ){
                    quoteAccepted = true;
                    certifyAgreement = true;
                    certifyPrivaryPolicy = true;
                    certifySubscription = true;
                }else{quoteAccepted=false;}
               
            }else
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ' No quote information found. Cannot proceed'));
                displayPopup = true;
                modalClose = false;
            }

        }        
    }
    
    public void closePopup() {        
        displayPopup = false;    
    }     
    public void showPopup() {        
        displayPopup = true;    
    }
    
    Public PageReference QuoteDetail() {
        PageReference page = new PageReference('/apex/QuoteDetail?quoteid=' + quoteId );
        page.setredirect(true);
        return page;
    }
    Public PageReference QuoteThankyou() {
        //verify certification
        if (!certifyAgreement){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Must accept agreement'));
            displayPopup = true;modalClose = true;
        }
        if (!certifyPrivaryPolicy){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Must accept privacy policy'));
            displayPopup = true;modalClose = true;
        }
        if (!certifySubscription){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Must accept subscription'));
            displayPopup = true;modalClose = true;
        }
        if (ApexPages.hasMessages()) {
            return null;
        }else{
            blng__PaymentMethod__c tmpPM;
              rac = new RecordAccessController();
            if (!quote.DAT_OSA_Accepted_by_Customer__c ){
                try {        
                   if (quote.tmpSiteQuotePM__c != null) {
                      string pmId = quote.tmpSiteQuotePM__c;
                      List<blng__PaymentMethod__c> tmpPMList = rac.dbQuery('select blng__autopay__c, id from blng__PaymentMethod__c where id = \'' + pmId + '\'');
                            
                      if (tmpPMList.size() == 0) {
                          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Payment Method Record Not Found' + pmID));
                           displayPopup = true;modalClose = false;   
                          return null;
                      }
                      else {
                          tmpPM = tmpPMList[0];
                      }

                   }                
                    QuoteRESTCall qs = new QuoteRESTCall();
                    qs.CallUpdate(quote.id);
                    //check to see if there are any recurring PMs
                   
                   if (tmpPM != null) {
                          tmpPM.blng__autopay__c = true;
                         // blng__PaymentMethod__c tmpPM2 = new blng__PaymentMethod__c(id = 'a25M0000001vfLhIAI',blng__autopay__c = true);
                         
                           //Database.SaveResult sr= rac.dbUpdate(tmpPM2);
                    }
                    System.debug('Calling SavePDFQuote');
                    savePDFQuote (quoteid);

                    PageReference page = new PageReference('/apex/QuoteThankyou?quoteid=' + quoteId );
                    page.setredirect(true);
                    return page;

                } catch(system.exception e) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'The following exception has occurred: ' + e.getMessage()+' : '+e.getStackTraceString()));
                    displayPopup = true;modalClose = false;   
                    return null;
                }

            }else{
            
                //return new PageReference('/apex/QuoteThankyou');
                PageReference page = new PageReference('/apex/QuoteThankyou?quoteid=' + quoteId );
                page.setredirect(true);
                return page;
            }
        }
    }
    public  void savePDFQuote(string quoteid){
                RecordAccessController rac = new RecordAccessController();
                PageReference pdfPage = new PageReference('/apex/QuotePDF?quoteid='+quoteid);
                if (!Test.isRunningTest()) {Body = pdfPage.getContent();}
                
                Blob pdfContent = Body ;//
                
                ContentVersion conVer = new ContentVersion();
                //conVer.ContentLocation = 'S'; 
                conVer.PathOnClient = 'Quote-'+ this.quoteName+'.pdf'; 
                conVer.Title = 'Quote-'+ this.quoteName ; 
                conVer.VersionData = pdfContent; 
                //insert conVer;        
                Database.SaveResult sr= rac.dbInsert(conVer);
                system.debug('savePDFQuote Insert Results :'+ sr);
                system.debug('savePDFQuote conVer.Id :' +conVer.Id);
                system.debug('savePDFQuote conVer.ContentDocumentId :' +conVer.ContentDocumentId);

        
                system.debug('savePDFQuote conVer.Id :' +conVer.Id);
        
                // First get the content document Id from ContentVersion
                string contentVersionQuery = 'SELECT ContentDocumentId FROM ContentVersion WHERE Id = \''+conVer.Id+'\'';
                List<SObject> queryResult = rac.dbQuery(contentVersionQuery);
                ContentVersion cv = (ContentVersion)queryResult[0];

                //Create ContentDocumentLink
                ContentDocumentLink cDe = new ContentDocumentLink();
                cDe.ContentDocumentId = cv.ContentDocumentId ;//conDoc;
                cDe.LinkedEntityId = quoteId; // you can use objectId,GroupId etc
                cDe.ShareType = 'I'; // Inferred permission, checkout description of ContentDocumentLink object for more details
                cDe.Visibility = 'AllUsers';
                insert cDe;
        }
}