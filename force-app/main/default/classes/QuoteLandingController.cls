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
public class QuoteLandingController {
    public SBQQ__Quote__c quote {get;set;}
    public contract contract {get;set;}
    public Decimal AmendedMRC {get;set;}
    private string quoteId;
    public boolean displayPopup {get; set;}
    public string termtext {get;set;}
    
    public List<SBQQ__QuoteLine__c> lineItems {get;set;}
  //  public string prodHeader {get;set;}
  //  public string prodDesc {get;set;}
   // public string ContractType {get;set;}
    
    public QuoteLandingController(){
        //quoteID is the parameter
        quoteId = System.currentPageReference().getParameters().get('quoteID');
        system.debug('OSACOntroller:Input Parameter: '+quoteId);
        
        if (quoteId== null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Missing quote information. Cannot continue'));
            displayPopup = true;
        }else{
             list<SBQQ__Quote__c> quotes = [ select name, SBQQ__Notes__c,SBQQ__Status__c, DAT_Contract_Type__c, SBQQ__ExpirationDate__c, 
                                            SBQQ__Opportunity2__c, SBQQ__Account__r.name,owner.name, owner.phone, owner.email, 
                                            SBQQ__BillingName__c, SBQQ__CustomerAmount__c,Agreement_Signer__r.name,Billing_Contact__r.name,
                                            Freight_Matching_Contact__r.name,SBQQ__ListAmount__c,SBQQ__NetAmount__c,DAT_Monthly_Recurring_Total__c,
                                            SBQQ__RegularAmount__c,DAT_List_MRC__c,SBQQ__Type__c,DAT_One_Time_Charge_Total__c, SBQQ__Opportunity2__r.SBQQ__AmendedContract__c,
                                           (select name, SBQQ__ChargeType__c,DAT_Applied_Promotion__c,SBQQ__product__r.id, SBQQ__product__r.name, SBQQ__product__r.SBQQ__Component__c,
                                            SBQQ__product__r.productcode, SBQQ__description__c,SBQQ__quantity__c, SBQQ__product__r.SBQQ__Specifications__c ,SBQQ__PackageTotal__c,
                                            DAT_Monthly_Recurring_Total__c,DAT_One_Time_Charges__c,Amendment_Action__c
                                            from SBQQ__LineItems__r order by SBQQ__Number__c) 
                                           from SBQQ__Quote__c where id = :quoteId]; //'a0q3F000000U4vPQAS'];
            
           if (quotes.size()>0) {
                displayPopup = false;
                quote = quotes[0];
               
                //Check for Quote status - 'Sent'
                if (quote.SBQQ__Status__c != 'Sent' ){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please verify the quote. Cannot continue'));
                    displayPopup = true;
                }
                //Check for Quote Expiration
                if(quote.SBQQ__ExpirationDate__c < Date.today()){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Quote is expired. Cannot continue'));
                    displayPopup = true;
                }
                AmendedMRC = 0.00;
                if (quote.SBQQ__Type__c == 'Amendment'){
                   contract = [select Id, ContractNumber, SBQQ__Quote__r.name, SBQQ__Quote__r.DAT_Monthly_Recurring_Total__c 
                                FROM Contract where id in (select SBQQ__AmendedContract__c  from Opportunity where id = : quote.SBQQ__Opportunity2__c)];     

                    AmendedMRC = contract.SBQQ__Quote__r.DAT_Monthly_Recurring_Total__c;
                    system.debug('Contract : SBQQ__Quote__r.DAT_Monthly_Recurring_Total__c' + AmendedMRC);
                }

                SBQQ__QuoteTerm__c term = [ select SBQQ__Body__c from SBQQ__QuoteTerm__c where name = 'QT-0001' ];
                termtext = term.SBQQ__Body__c;
                
            }else
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ' No quote information found. Cannot proceed'));
                displayPopup = true;
            }       
        
        }

    }
    
    public void closePopup() {        
        displayPopup = false;    
    }     
    public void showPopup() {        
        displayPopup = true;    
    }
    Public PageReference cancel() {
       PageReference page = new PageReference('https://www.dat.com/' );
       page.setredirect(true);
       return page;
    }
    Public PageReference quoteDetail(){
       PageReference page = new PageReference('/apex/QuoteDetail?quoteid=' + quoteId );
       page.setredirect(true);
       return page;
    }
    
}