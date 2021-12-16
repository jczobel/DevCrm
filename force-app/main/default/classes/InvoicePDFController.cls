/************************************* MODIFICATION LOG ********************************************************************************************
* Invoice PDF Controller
*
* DESCRIPTION : POC to create invoice pdf 
*
*---------------------------------------------------------------------------------------------------------------------------------------------------
* DEVELOPER                                 DATE        JIRA#            REASON
*---------------------------------------------------------------------------------------------------------------------------------------------------
* Acumen Solutions                          05/02/2019                     - Original Version 
*
*/
public with sharing class InvoicePDFController {

    public String InvoiceId;
    public blng__Invoice__c Invoice {get;set;}
    public list<blng__InvoiceLine__c> invoiceLineItems {get;set;}

    public list<billToInvoice> billtoInv {get;set;}
    public Map<string,list<blng__InvoiceLine__c>> accountOrderIds {get; set;}
    
    public list<string> billToAccountIdlst {get;set;}

    public InvoicePDFController(){
        
    }

    //Get Invoice information
    public  void setInvoiceId(string inv) {
        Invoice =  [Select Name, blng__Account__r.name, blng__Account__r.BillingStreet,blng__Account__r.BillingCity,blng__DueDate__c,
                    blng__Account__r.BillingState,blng__Account__r.BillingPostalCode,blng__Account__r.BillingCountry,  
                    blng__Balance__c,blng__InvoiceStatus__c,blng__TotalAmount__c,
                    (select Name, blng__OrderProduct__r.order.account.name, blng__StartDate__c, blng__EndDate__c, blng__TotalAmount__c from blng__InvoiceInvoiceLines__r)
                    From blng__Invoice__c where Id =: inv];
        InvoiceId = inv;
        
        invoiceLineItems= Invoice.blng__InvoiceInvoiceLines__r;
        
        //accountOrderIds = new Map<string,list<blng__InvoiceLine__c>>();
        //Get distinct Account from invoice line item. Group by Account and store it in map (id , account)
        List<AggregateResult>  groupResults = [SELECT  blng__OrderProduct__r.order.account.Id accId,blng__OrderProduct__r.orderId orderId
                                                FROM blng__InvoiceLine__c 
                                                Where blng__Invoice__c =: inv
                                                group by blng__OrderProduct__r.order.account.Id,blng__OrderProduct__r.orderId];
        // After populating the map, iterate through the map entries
        billToAccountIdlst = new list<string>();
        accountOrderIds = new  Map<string,list<blng__InvoiceLine__c>> ();
        for (AggregateResult ar : groupResults) {
            string aId = (string)ar.get('accId');
            system.debug('aId: '+ aId);
            
            system.debug('billToAccountIdlst' + billToAccountIdlst);
            billToAccountIdlst.add(aId);
            system.debug('billToAccountIdlst' + billToAccountIdlst);

            list<blng__InvoiceLine__c> invoiceLineItems = [select Name, blng__OrderProduct__r.order.account.name, blng__StartDate__c, blng__EndDate__c, blng__TotalAmount__c 
                                                                    from blng__InvoiceLine__c
                                                                    where blng__Invoice__c =: inv and blng__OrderProduct__r.order.accountId = : aId];
            system.debug('Invoice Line Item: '+ invoiceLineItems.size());
            accountOrderIds.put(aId, invoiceLineItems);
        }
        

   }


    //Method to return invoice line item for given bill to account 
    
   //Get Invoice details information
   public string getInvoiceId(){
       return InvoiceId;
   }

    public class billToInvoice{
        public account billToAccount;
        public list<blng__InvoiceLine__c> invoiceLineItems;
        public billToInvoice (string accountId, string inv){
            billToAccount = [Select Id, Name from account where id = :accountId];
            invoiceLineItems = [select Name, blng__OrderProduct__r.order.account.name, blng__StartDate__c, blng__EndDate__c, blng__TotalAmount__c 
                                from blng__InvoiceLine__c
                                where blng__Invoice__c =: inv and blng__OrderProduct__r.order.accountId = :accountId];
        }
    }
}