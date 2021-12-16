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
public class QuoteDetailController {
    //public List<Account> aList { get; set; }
    //
    public SBQQ__Quote__c quote {get;set;}
    public SBQQ__Quote__c myQuote {get;set;}
    public SBQQ__QuoteTemplate__c qt {get;set;}
    public SBQQ__TemplateContent__c tmpTop {get;set;}
    public List<OpportunityContactRole> quoteContacts {get;set;}
   // public Contact BillingContact {get;set;}
   // public Contact AgreementContact {get;set;}
    public Contact PrimaryContact {get;set;}
    public List<SBQQ__QuoteLine__c> lineItems {get;set;}
    public string msg {get;set;}
    public string prodHeader {get;set;}
    public string prodDesc {get;set;}
    public string prevPage {get;set;}
    public string nextPage {get;set;}
    public Account acct {get;set;}
    Private RecordAccessController rac;
    Public List<Selectoption> businessTypePicklistValues{get;set;}
    
    public string LegalName {get;set;}
    public string federalTaxId {get;set;}
    public string BusinessType {get;set;}
  
    
     public blng__PaymentMethod__c paymentMethod {get;set;}
    public boolean hasPM {get;set;}
  
     public boolean accountValidated {get;set;}     
    public string message {get;set;}
    private string quoteId;
    
    public boolean displayPopup {get; set;}
    public boolean modalClose {get; set;}

    public void closePopup() {        
        displayPopup = false;    
    }     
    public void showPopup() {        
        displayPopup = true;    
    }
     
    
    public QuoteDetailController() {
        //aList = [select name from account ];
        ///SBQQ__CustomSource__c
        
        modalClose = true;

        //quoteID is the parameter
        quoteId = System.currentPageReference().getParameters().get('quoteID');
        system.debug('OSACOntroller:Input Parameter: '+quoteId);
        
        if (quoteId== null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Missing quote information. Cannot continue'));
            displayPopup = true;
            modalClose = false;
        }else{
            // need to pass the id from the page, Display error message
            list<SBQQ__Quote__c> quotes = [ select name, tmpSiteQuotePM__c, SBQQ__Notes__c,SBQQ__Status__c, SBQQ__ExpirationDate__c, SBQQ__Opportunity2__c, SBQQ__Account__r.name, SBQQ__Account__r.id,
                                           owner.name, owner.phone, owner.email, SBQQ__BillingName__c, SBQQ__CustomerAmount__c, SBQQ__Account__c, 
                                           SBQQ__Account__r.SF_Account_Number__c, SBQQ__Account__r.LegalName__c, SBQQ__Account__r.BillingStreet, 
                                           SBQQ__Account__r.BillingCity, SBQQ__Account__r.BillingState, SBQQ__Account__r.BillingPostalCode, sbqq__account__r.BillingCountry, SBQQ__Account__r.Business_Type__c,
                                           SBQQ__Account__r.Phone, SBQQ__Account__r.BrokerMC__c, SBQQ__Account__r.IntrastateID__c, SBQQ__Account__r.IntrastateIDState__c, 
                                           SBQQ__Account__r.CarrierMC__c, SBQQ__Account__r.FederalID__c, SBQQ__Account__r.BrokerDOT__c, SBQQ__Account__r.FreightForwarder__c,                                           
                                           (select name, SBQQ__product__r.name, SBQQ__product__r.productcode, SBQQ__description__c,
                                            SBQQ__quantity__c, SBQQ__product__r.SBQQ__Specifications__c from SBQQ__LineItems__r), 
                                            Billing_Contact__r.firstname, Billing_Contact__r.LastName, Billing_Contact__r.Phone, Billing_Contact__r.email,
                                            Agreement_Signer__r.firstname, Agreement_Signer__r.LastName, Agreement_Signer__r.Phone, Agreement_Signer__r.email
                                           from SBQQ__Quote__c where id = :quoteId]; //'a0q3F000000U4vPQAS'];
            
            if (quotes.size()>0) {
                displayPopup = false;
                quote = quotes[0];
         //       businessTypePicklistValues = getBustinessTypePicklistValues();
                
                LegalName = quotes[0].SBQQ__Account__r.LegalName__c;
                if(quotes[0].SBQQ__Account__r.Business_Type__c != null && quotes[0].SBQQ__Account__r.Business_Type__c!='')
                    BusinessType = quotes[0].SBQQ__Account__r.Business_Type__c;
                else 
                    BusinessType = '';
                federalTaxId = quotes[0].SBQQ__Account__r.FederalID__c;
                //Check for Quote status
                if (quote.SBQQ__Status__c != 'Sent' ){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please verify the quote. Cannot continue'));
                    displayPopup = true;
                    modalClose = false;
                }
                //Check for Quote Expiration
                if(quote.SBQQ__ExpirationDate__c < Date.today()){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Quote is expired. Cannot continue'));
                    displayPopup = true;
                    modalClose = false;
                }
                
                
                lineItems = quote.SBQQ__LineItems__r;
                for (SBQQ__QuoteLine__c li : lineItems) {
                    if (li.SBQQ__product__r.productcode == 'Power Select Broker') {
                        
                        prodHeader = li.SBQQ__product__r.name;
                        prodDesc = li.SBQQ__product__r.SBQQ__Specifications__c;
                    }    
                }
                               List<blng__PaymentMethod__c> pmList = [ select id, blng__Active__c, blng__AutoPay__c, blng__BillingCity__c,blng__BillingCompany__c, blng__CardType__c,blng__Nameoncard__c,
                                                       blng__BillingCountry__c,blng__BillingEmail__c,  blng__BillingFirstName__c,blng__BillingLastName__c,blng__BillingPhone__c,name,
                                                       blng__BillingStateProvince__c,blng__BillingStreet__c,blng__BillingZipPostal__c, blng__CardNumber__c from blng__PaymentMethod__c where 
                                                       blng__Account__c =: this.quote.SBQQ__Account__r.id and ((blng__Active__c = true and blng__AutoPay__c = true) 
                                                       OR (blng__Active__c = true and blng__AutoPay__c = false and id =: this.quote.tmpSiteQuotePM__c)) order by blng__AutoPay__c desc  ];
                               
                                   
                                   if (pmList.size() > 0) {
                                     this.paymentMethod = pmList[0];      
                                     this.hasPM = true;
                                   }
                               
                               
                             else {
                                 this.paymentMethod = new blng__PaymentMethod__c();
                                 this.paymentMethod.blng__BillingStreet__c = this.quote.sbqq__account__r.BillingStreet;
                                 this.paymentMethod.blng__BillingCity__c = this.quote.sbqq__account__r.BillingCity;
                                 this.paymentMethod.blng__BillingStateProvince__c = this.quote.sbqq__account__r.BillingState;
                                 this.paymentMethod.blng__BillingCountry__c = this.quote.sbqq__account__r.BillingCountry;
                                 this.paymentMethod.blng__BillingZipPostal__c = this.quote.sbqq__account__r.BillingPostalCode;
                                 this.paymentMethod.blng__BillingFirstName__c = this.quote.billing_contact__r.firstName;
                                 this.paymentMethod.blng__BillingLastName__c = this.quote.billing_contact__r.lastname;
                                 this.paymentMethod.blng__BillingPhone__c = this.quote.billing_contact__r.phone;
                                 this.paymentMethod.blng__BillingEmail__c = this.quote.billing_contact__r.email;
                                  this.hasPM = false;
                             }

              /*
                if (quote.SBQQ__Opportunity2__c != null) {
                    For (OpportunityContactRole ocr : [ select id, role, isPrimary, contact.LastName, contact.FirstName, contact.email, contact.phone from OpportunityContactRole where 
                                                       opportunityid =: quote.SBQQ__Opportunity2__c and Role in ('Billing', 'Agreement Signer') ]) {
                                                           
                                                           if (ocr.isPrimary) {
                                                               PrimaryContact = new Contact();
                                                               PrimaryContact.LastName = ocr.contact.LastName;
                                                               PrimaryContact.FirstName = ocr.contact.FirstName;
                                                               PrimaryContact.email = ocr.contact.email;
                                                               PrimaryContact.phone = ocr.contact.phone;
                                                           }
                                                           if (ocr.Role == 'Agreement Signer') {
                                                               AgreementContact = new Contact();
                                                               AgreementContact.LastName = ocr.contact.LastName;
                                                               AgreementContact.FirstName = ocr.contact.FirstName;
                                                               AgreementContact.email = ocr.contact.email;
                                                               AgreementContact.phone = ocr.contact.phone;
                                                           }
                                                           if (ocr.Role == 'Billing') {
                                                               
                                                               BillingContact = new Contact();
                                                               BillingContact.LastName = ocr.contact.LastName;
                                                               BillingContact.FirstName = ocr.contact.FirstName;
                                                               BillingContact.email = ocr.contact.email;
                                                               BillingContact.phone = ocr.contact.phone;
                                                           }
                                                           
                                                           
                                                       }
                    quoteContacts = [ select id, role, isPrimary, contact.LastName, contact.FirstName, 
                                     contact.email, contact.phone from OpportunityContactRole where opportunityid =: quote.SBQQ__Opportunity2__c 
                                     and Role in ('Billing', 'Agreement Signer') ];
                    
                }
                */
                
             //   qt = [select id, (select name, SBQQ__Content__c from SBQQ__Sections__r) from SBQQ__QuoteTemplate__c where name = 'test2' limit 1 ];
            //    tmpTop = [select SBQQ__RawMarkup__c from SBQQ__TemplateContent__c where id = 'a133F000004kyVKQAY'];
                
                // if OSA Accepted by customer then check the flags
             //   if (quote.OSA_Accepted_by_Customer__c){
               //     certifyAgreement = true;
                 //   certifyPrivaryPolicy = true;
                   // certifySubscription = true;
             //   }
            }else
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ' No quote information found. Cannot proceed'));
                displayPopup = true;
                modalClose = false;
            }
            
        }
    }
    /*
    public PageReference updateAccountInfo() {
       system.debug('Inside');
       this.msg = 'check it out';
        
       
       List<Account> acctList = [ select id, legalname__c, Business_Type__c, name from Account where id =: quote.SBQQ__Account__r.id ];
        if (acctList.size() == 0) {
            this.msg = 'we have a problem.  not account found';
            
            
            return null;
        }
        String errorMessage = 'Please Enter ';
        boolean checkError = false;
        this.acct = acctList[0];
        if(LegalName != null && LegalName != '') {
            this.acct.LegalName__c = LegalName;
        } else {
            checkError = true;
            errorMessage = errorMessage+'Company Legal Name ';
        }    
        
        if(federalTaxId != null && federalTaxId != '') {
            this.acct.FederalID__c = federalTaxId;
        } else {
             checkError = true;
             errorMessage = errorMessage+'Federal Tax Id';
        }
        
        this.acct.Business_Type__c = BusinessType;
        
        if(!checkError) {
            update this.acct;
        } else {
            
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, errorMessage));
        }
        
       // quote.SBQQ__Account__r.Business_Type__c = BusinessType;
       // quote.SBQQ__Account__r.LegalName__c = LegalName;
        return null;
    }
    */
    Public PageReference loadLanding() {
        return null;
    }
    Public PageReference loadDetail() {
    return null;
    }
    Public PageReference cancel() {
        return null;
    }
    Public PageReference prev() {
        
        return new PageReference('/apex/QuoteLanding?quoteid=' + quoteId);
    }

    Public PageReference renderMessage (){
      if(accountValidated ){  
            ApexPages.getMessages().clear();       
        }else{ 
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Warning, message));
            modalClose = true;
            }
        return null;
    }

    Public PageReference nextOLD() {
        // string pageName = System.currentPageReference().getParameters().get('pageName');
        // nextPage = pageName;
        // 
     //   List<Account> acctList = [ select id, legalname__c, Business_Type__c, name from Account where id =: quote.SBQQ__Account__r.id ];
        
       // if(acctList !=null) {
         //   BusinessType = acctList[0].Business_Type__c;
     //   }
        
   //     String errorMessage = 'Please Enter ';
     //   Boolean checkError = false;
       // if(LegalName == null || LegalName == '') {
         //   errorMessage = errorMessage+'Company Legal Name';
           // checkError = true;
     //   } 
        
       // if(federalTaxId == null || federalTaxId == '') {
         //   if(checkError) {
           //     errorMessage = errorMessage+', Federal Tax Id';
          //  } else {
            //    errorMessage = errorMessage+'Federal Tax Id';
              //  checkError = true;
         //   }

       // }
    //    System.debug('BusinessType'+BusinessType);
      //  if(BusinessType == null || BusinessType == '') {
        //    if(checkError) {
          //      errorMessage = errorMessage+', Business Type';
            //} else {
              //  errorMessage = errorMessage+'Business Type';
                //checkError = true;
         //   }
            
        //}
        
     //   if(checkError) {
       //     ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, errorMessage));
         //   return null;
      //  } 
        
        PageReference page = new PageReference('/apex/QuoteAccept?quoteid=' + quoteId);
        page.setredirect(true);
        return page;
    }
 //   private List<SelectOption> getBustinessTypePicklistValues()
   // {
     //   List<SelectOption> options = new List<SelectOption>();
   //     Schema.DescribeFieldResult fieldResult =
     //       Account.Business_Type__c.getDescribe();
    //    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
   //     for( Schema.PicklistEntry f : ple)
   //     {
   //         options.add(new SelectOption(f.getLabel(), f.getValue()));
   //     }       
   //     return options;
  //  }
 
     Public PageReference next() {
        if(!accountValidated ){          
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Warning, message));
            modalClose = true;
            return null; 
        }

    
         //  blng__PaymentMethod__c paymentMethodToProcess = new blng__PaymentMethod__c(blng__PaymentType__c = 'Credit Card', blng__PaymentGatewayToken__c = '1131fdfdf313', blng__CardType__c = 'VISA', 
         //  blng__CardNumber__c = '454545424515421', blng__CardExpirationYear__c = '2020', 
         //  blng__CardExpirationMonth__c = '01', blng__BillingZipPostal__c = '11111', blng__BillingStateProvince__c = 'California', blng__BillingLastName__c = 'Last_Test', 
         //  blng__BillingFirstName__c = 'first_Test', blng__BillingEmail__c = 'Test@gmail.com', blng__BillingCountry__c = 'United States', blng__BillingCity__c = 'CA', 
         //  blng__BillingStreet__c = 'Address', blng__Active__c = true, blng__Account__c = this.quote.SBQQ__Account__r.id);
        if(!this.hasPM) {        

        if(paymentMethod.blng__Nameoncard__c == null){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Warning, 'Verify Name on the card'));
            modalClose = true;
        }
        if(paymentMethod.blng__CVV__c== null){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Warning, 'Verify CVV'));
            modalClose = true;
        }
        if(paymentMethod.blng__CardExpirationMonth__c== null || paymentMethod.blng__CardExpirationYear__c==null){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Warning, 'Verify card expiration month and year'));
            modalClose = true;
        }

        if (ApexPages.hasMessages()){
            displayPopup = true;
            return null;               
        }


           this.paymentMethod.blng__Active__c = true;
           this.paymentMethod.blng__Account__c = this.quote.SBQQ__Account__r.id;
           this.paymentMethod.blng__PaymentType__c = 'Credit Card';
           //this.paymentMethod.blng__autopay__c = true;
        
          // this.paymentMethod.blng__BillingAddress__c = 'asdfasfsdfsdaf';
           string gatewayName = 'ElavonDAT';
           string accountId = this.quote.SBQQ__Account__r.id;
           
          blng.TransactionParameter transactionParameterToProcess = new blng.TransactionParameter();
          transactionParameterToProcess.setGateWay((blng__PaymentGateway__c) Database.query('select id, blng__GatewayType__c from blng__PaymentGateway__c where name = :gatewayName')[0]);
          transactionParameterToProcess.setPaymentMethod(paymentMethod);
          transactionParameterToProcess.setAccount((Account) Database.query('select id, accountnumber, blng__CustomerProfileId__c from Account where id = :accountId')[0]);
          transactionParameterToProcess.setZipCode(paymentMethod.blng__BillingZipPostal__c);
          transactionParameterToProcess.setCountry('United States');
          transactionParameterToProcess.setState(paymentMethod.blng__BillingStateProvince__c);
          transactionParameterToProcess.setCity(paymentMethod.blng__BillingCity__c);
          transactionParameterToProcess.setStreet(paymentMethod.blng__BillingStreet__c);
          transactionParameterToProcess.setPhone(paymentMethod.blng__BillingPhone__c); //populate from billing contact
          transactionParameterToProcess.setEmailId(paymentMethod.blng__BillingEmail__c); // populate from billing contact
          transactionParameterToProcess.setFirstName(paymentMethod.blng__BillingFirstName__c);
          transactionParameterToProcess.setLastName(paymentMethod.blng__BillingLastName__c);
          
          
          
          try {
                //Call Transaction service
                  List<blng.TransactionResult> txResults= blng.TransactionAPI.generateToken(new Map<String, blng.TransactionParameter>{transactionParameterToProcess.getAccount().Id => transactionParameterToProcess});
                  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Gateway Response:  ' + txResults[0].getMessage()));
                //  system.debug('?????:  ' + txResults + '  ' +  this.paymentMethod.id + this.paymentMethod.blng__Active__c);
            
            
                  if (txResults[0].getIsSuccess()) {
                      this.paymentMethod.blng__PaymentGatewayToken__c =txResults[0].getPaymentToken();
                      upsert this.paymentMethod;
                      //this.hasPM = true;  
                        SBQQ__Quote__c q = new SBQQ__Quote__c(id = this.quote.id, tmpSiteQuotePM__c = this.paymentMethod.id);
                        update q;
                        blng__PaymentMethod__c tmpPM = new blng__PaymentMethod__c(id = this.paymentMethod.id,blng__autopay__c = true);
                        this.rac = new RecordAccessController();
                        Database.SaveResult sr= rac.dbUpdate(tmpPM);
                        PageReference page = new PageReference('/apex/QuoteAccept?quoteid=' + quoteId);
                        page.setredirect(true);
                        return page; 
                  }

                  //TransactionResult has the payment Token in response 

            } catch (Exception e) {
              // system.assertEquals(e.getMessage(), e.getMessage());
                  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));
                  displayPopup = true;
                  modalClose = true;
            }
        }
        else {
              PageReference page = new PageReference('/apex/QuoteAccept?quoteid=' + quoteId);
              page.setredirect(true);
              return page; 
        }
        return null;
    }
   
}