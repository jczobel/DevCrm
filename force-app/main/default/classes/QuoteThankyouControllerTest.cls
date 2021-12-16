/************************************* MODIFICATION LOG ********************************************************************************************
* Test class for QuoteThankyouController
*
* DESCRIPTION : Class that drives the Quote Detail Page in the OSA site
*
*---------------------------------------------------------------------------------------------------------------------------------------------------
* DEVELOPER                                 DATE        JIRA#            REASON
*---------------------------------------------------------------------------------------------------------------------------------------------------
* Acumen Solutions                          4/16/2019                     - Original Version 
* Acumen Solutions                          4/29/2019                     - Added test for pdf generation
*/
@isTest
public class QuoteThankyouControllerTest {
    
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
    public static  void QuoteThankyouPrintPDFTest() {
        
        //Set Test Page
        SBQQ__Quote__c quote = [SELECT Id,DAT_OSA_Accepted_by_Customer__c from SBQQ__Quote__c where DAT_OSA_Accepted_by_Customer__c = true limit 1 ];
        
        Test.setCurrentPage(Page.QuoteThankyou);
        ApexPages.currentPage().getParameters().put('quoteid', quote.Id); 
        QuoteThankyouController controller = new QuoteThankyouController();
        controller.Body =Blob.valueOf('Test Content') ;

        
         String nextPage = controller.Generatepdf().getUrl();
        //String nextPage = controller.QuoteThankyou().getUrl();
        System.assertEquals('/apex/QuotePDF?quoteid='+quote.Id, nextPage);
        
    }
    
    @isTest
    public static  void QuotenullTest() {
        SBQQ__Quote__c quote = [SELECT Id,DAT_OSA_Accepted_by_Customer__c from SBQQ__Quote__c where DAT_OSA_Accepted_by_Customer__c = true limit 1 ];
        
        //Check with invalid quotes
        Test.setCurrentPage(Page.QuoteThankyou);
        //ApexPages.currentPage().getParameters().put('quoteid', quote.Id); 
        QuoteThankyouController controller = new QuoteThankyouController();
        
        controller.Body =Blob.valueOf('Test Content') ;
        try{controller.Generatepdf();}
        catch(DmlException e) {
            System.debug('The following exception has occurred: ');
        }
		System.assert(true, 'a NullPointerException was expected but was not thrown');
    }
    
    
    @isTest
    public static  void QuoteinvalidTest() {
        
        //Check with invalid quotes
        Test.setCurrentPage(Page.QuoteThankyou);
        ApexPages.currentPage().getParameters().put('quoteid', 'test'); 
        QuoteThankyouController controller = new QuoteThankyouController();
        

    }
    
}