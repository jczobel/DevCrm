/************************************* MODIFICATION LOG ********************************************************************************************
* QuoteAcceptController test class
*
* DESCRIPTION : Class that drives the Quote Detail Page in the OSA site
*
*---------------------------------------------------------------------------------------------------------------------------------------------------
* DEVELOPER                                 DATE        JIRA#            REASON
*---------------------------------------------------------------------------------------------------------------------------------------------------
* Acumen Solutions                          4/15/2019                     - Original Version 
*
*/
@isTest
public class QuoteAcceptControllerTest {

    @testSetup static void testData() {
       	//Insert Account and Quote
        account quoteAccount = new account(name='Test');
        insert(quoteAccount);
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c( DAT_OSA_Accepted_by_Customer__c = true,DAT_Contract_Type__c = '1 Month',SBQQ__Account__c  = quoteAccount.id);
        insert(quote);

        SBQQ__Quote__c quoteOSAFalse = new SBQQ__Quote__c(DAT_Contract_Type__c = '1 Month',SBQQ__Account__c  = quoteAccount.id);
        insert(quoteOSAFalse);
        
        system.debug('QuoteAcceptControllerTest quote.id: ' + quote.Id);
        system.debug('QuoteAcceptControllerTest quoteOSAFalse.id: ' + quoteOSAFalse.Id);
        system.debug('QuoteAcceptControllerTest quote.DAT_OSA_Accepted_by_Customer__c: ' + quote.DAT_OSA_Accepted_by_Customer__c);
    }
    
    @isTest
    public static  void QuoteOSATrueTest() {

        //Set Test Page
        SBQQ__Quote__c quote = [SELECT Id,DAT_OSA_Accepted_by_Customer__c from SBQQ__Quote__c where DAT_OSA_Accepted_by_Customer__c = true limit 1 ];

        Test.setCurrentPage(Page.QuoteAccept);
        ApexPages.currentPage().getParameters().put('quoteid', quote.Id); 
        QuoteAcceptController controller = new QuoteAcceptController();

        String nextPage = controller.QuoteThankyou().getUrl();
        System.assertEquals('/apex/QuoteThankyou?quoteid='+quote.Id, nextPage);

    }
    
    @isTest
    public static  void QuoteOSAFalseTest() {
        //quoteOSAFalse
        SBQQ__Quote__c quoteOSAFalse = [SELECT Id,DAT_OSA_Accepted_by_Customer__c from SBQQ__Quote__c where DAT_OSA_Accepted_by_Customer__c != true limit 1 ];

        Test.setCurrentPage(Page.QuoteAccept);
        ApexPages.currentPage().getParameters().put('quoteid', quoteOSAFalse.Id); 
        QuoteAcceptController controller = new QuoteAcceptController();
        
        controller.certifyAgreement = true;
        controller.certifyPrivaryPolicy = true;
        controller.certifySubscription = true;
        
        string nextPage = controller.QuoteThankyou().getUrl();
        System.assertEquals('/apex/QuoteThankyou?quoteid='+quoteOSAFalse.Id, nextPage);

    }
    
    @isTest
    public static  void QuoteOSATrueCheckFalseTest() {
        // Set check box false
        SBQQ__Quote__c quoteOSAFalse = [SELECT Id,DAT_OSA_Accepted_by_Customer__c from SBQQ__Quote__c where DAT_OSA_Accepted_by_Customer__c != true limit 1 ];

        Test.setCurrentPage(Page.QuoteAccept);
        ApexPages.currentPage().getParameters().put('quoteid', quoteOSAFalse.Id); 
        QuoteAcceptController controller = new QuoteAcceptController();
        
        controller.certifyAgreement = false;
        controller.certifyPrivaryPolicy = false;
        controller.certifySubscription = false;
       
        controller.QuoteThankyou();
		System.assertEquals(true, controller.displayPopup);

     }
    
    @isTest
    public static  void QuoteOtherTest() {
       //Check with invalid quotes
        Test.setCurrentPage(Page.QuoteAccept);
		ApexPages.currentPage().getParameters().put('quoteid', 'yyyy');        
        QuoteAcceptController controller = new QuoteAcceptController();

        System.assertEquals(true, controller.displayPopup);
		
        //Check with null quotes
        Test.setCurrentPage(Page.QuoteAccept);
        controller = new QuoteAcceptController();

        System.assertEquals(true, controller.displayPopup); 

        //Check with Showpopup
        Test.setCurrentPage(Page.QuoteAccept);
        controller = new QuoteAcceptController();
		controller.showPopup();

        System.assertEquals(true, controller.displayPopup); 

        //Check with Closepopup
        Test.setCurrentPage(Page.QuoteAccept);
        controller = new QuoteAcceptController();
		controller.closePopup();

        System.assertEquals(false, controller.displayPopup); 

       }
    
    @isTest
    public static  void QuotePreviousTest() {     //Check with previous
        SBQQ__Quote__c quoteOSAFalse = [SELECT Id,DAT_OSA_Accepted_by_Customer__c from SBQQ__Quote__c where DAT_OSA_Accepted_by_Customer__c = true limit 1 ];

        
        Test.setCurrentPage(Page.QuoteAccept);
        ApexPages.currentPage().getParameters().put('quoteid', quoteOSAFalse.Id); 
        system.debug('QuoteAcceptControllerTest controller.quoteOSAFalse: ' + ApexPages.currentPage().getParameters().get('quoteid'));
        QuoteAcceptController controller = new QuoteAcceptController();
	
        controller.QuoteDetail();
        
		string nextPage = controller.QuoteDetail().getUrl();
        System.assertEquals('/apex/QuoteDetail?quoteid='+quoteOSAFalse.Id, nextPage);
 
	}
}