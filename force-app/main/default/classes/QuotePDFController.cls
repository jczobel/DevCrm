/************************************* MODIFICATION LOG ********************************************************************************************
* Quote PDF Controller
*
* DESCRIPTION : Class that create pdf document
*
*---------------------------------------------------------------------------------------------------------------------------------------------------
* DEVELOPER                                 DATE        JIRA#            REASON
*---------------------------------------------------------------------------------------------------------------------------------------------------
* Acumen Solutions                          4/26/2019                     - Original Version 
*
*/
public class QuotePDFController {
    public SBQQ__Quote__c quote {get;set;}
    private string quoteId;
    public boolean showquote {get; set;}
    public string termtext {get;set;}
    
    public List<SBQQ__QuoteLine__c> lineItems {get;set;}
    
    public QuotePDFController(){
        //quoteID is the parameter
        quoteId = System.currentPageReference().getParameters().get('quoteID');
        //quoteId = 'a0q3F000000U4veQAC'; // Testing
        system.debug('OSACOntroller:Input Parameter: '+quoteId);
        
        if (quoteId== null){
            //Missing quote information. Cannot continue'
            showquote = false;
        }else{
             list<SBQQ__Quote__c> quotes = [ select name, SBQQ__Notes__c,SBQQ__Status__c, DAT_Contract_Type__c, SBQQ__ExpirationDate__c, 
                                            SBQQ__Opportunity2__c, SBQQ__Account__r.name,owner.name, owner.phone, owner.email, 
                                            SBQQ__BillingName__c, SBQQ__CustomerAmount__c,Agreement_Signer__r.name,Billing_Contact__r.name,
                                            Freight_Matching_Contact__r.name,SBQQ__SalesRep__c,Quote_Accepted_On__c,
                                           (select name, SBQQ__product__r.id, SBQQ__product__r.name, SBQQ__product__r.SBQQ__Component__c,
                                            SBQQ__product__r.productcode, SBQQ__description__c,SBQQ__quantity__c, SBQQ__product__r.SBQQ__Specifications__c 
                                            from SBQQ__LineItems__r order by SBQQ__Number__c) 
                                           from SBQQ__Quote__c where id = :quoteId]; //'a0q3F000000U4vPQAS'];
            
           if (quotes.size()>0) {
                showquote = true;
                quote = quotes[0];
               
                //Check for Quote Expiration
                if(quote.SBQQ__ExpirationDate__c < Date.today()){
                    //Quote is expired. Cannot continue;
                    showquote = false;
                }
                
                
             SBQQ__QuoteTerm__c term = [ select SBQQ__Body__c from SBQQ__QuoteTerm__c where name = 'QT-0001' ];
             termtext = term.SBQQ__Body__c;
        
            }else
            {
                //'No quote information found. Cannot proceed'
                showquote = false;
            }       
        
        }

    }

}