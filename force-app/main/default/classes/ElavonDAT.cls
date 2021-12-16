/************************************* MODIFICATION LOG ********************************************************************************************
* ElavonDAT
*
* DESCRIPTION : ElavonDAT call this class.  iteracts with custom PaymentGateway
*
*---------------------------------------------------------------------------------------------------------------------------------------------------
* DEVELOPER                                 DATE        JIRA#            REASON
*---------------------------------------------------------------------------------------------------------------------------------------------------
* Acumen Solutions                          5/7/2019                     - Original Version 
*/

public class ElavonDAT { 
     
     //Add variables here    
     //Gateway Status related variables     
     private static Map<string, blng.TransactionResult.GatewayStatusType> mapGatewayStatusEnumTypesByStrings = new Map<string, blng.TransactionResult.GatewayStatusType>();     
     static {         
         List<blng.TransactionResult.GatewayStatusType> enumValues = blng.TransactionResult.GatewayStatusType.values(); 
            for (Integer i = 0; i < enumValues.size(); i++) {
                mapGatewayStatusEnumTypesByStrings.put(enumValues.get(i).name(), enumValues.get(i));     
          }     
     }     
     // default Gateway Status     
     private static final blng.TransactionResult.GatewayStatusType 
        defaultGatewayStatus = blng.TransactionResult.GatewayStatusType.Indeterminate;              

    public static Map<String, blng.TransactionResult> generateToken(Map<String, blng.TransactionParameter> mapOfTransactionParameterById)      {    
         blng.TransactionParameter tp;
         blng.transactionResult tr;
         string oId;
         for (string s : mapOfTransactionParameterById.keyset()) {
             oId = s;
             tp = mapOfTransactionParameterById.get(oId); 
             tr = tp.TransactionResult;
         }
            ElavonDATUtils util = new ElavonDATUtils();
            ElavonDATUtils.ElavonDATResponse gatewayResp = util.generateToken(mapOfTransactionParameterById);
          
        try {
        // tr.setResponseMessage(gatewayResp.status);
         tr.setIsSuccess(gatewayResp.getSuccess());
//         tr.setId('0013F00000Hk6DxQAJ'); what is this field used for???
         tr.setMessage('Gateway Response: ' + gatewayResp.Description);
         tr.setGatewayId(tp.getGateWayId());
         tr.setCustomerProfileToken(tp.getAccount().blng__CustomerProfileId__c);  //is this how you set the customer profile token?
            if (gatewayResp.getSuccess()) {
                tr.setPaymentToken(gatewayResp.cardToken);
                tr.setResponseMessage(gatewayResp.transid);
                tr.setGatewayStatus(mapGatewayStatusEnumTypesByStrings.get('Success'));
            }
            else {
                 tr.setError('this is an error message'); // where does this go?
                 tr.setResponseMessage('Elavon Gateway could not process the request.  ' + gatewayResp.status + ' ' +gatewayResp.description);
                 tr.setGatewayStatus(mapGatewayStatusEnumTypesByStrings.get('SystemError')); // where does this go?
            }
        }
          catch(DATException ex) {
               tr.setError('this is an error message' + ex.getMessage()); // where does this go?
               tr.setMessage('where does this goooooo????');
               tr.setResponseMessage('Elavon Gateway could not process the request.' + ex.getMessage());
               tr.setGatewayStatus(mapGatewayStatusEnumTypesByStrings.get('ValidationError')); // where does this go?           
           }
        catch(system.Exception ex) {
            system.debug('ERROR transactionresult: ' + ex.getStackTraceString());
        }
         Map<string,blng.TransactionResult> mapTR = new Map<string,blng.TransactionResult>();
         mapTR.put(oId,tr);
         system.debug('generateToken:  Result' + tr);
         return mapTR;
      }      
    //Charge Transaction method Salesforce billing interface class will use this class to Charge Transaction  
       public static Map<String, blng.TransactionResult> chargeTransaction(Map<String, blng.TransactionParameter> mapOfTransactionParameterById)      {     
         blng.TransactionParameter tp;
         blng.transactionResult tr;
         string objId;
         id recId;
         
           //assess first record
         for (string s : mapOfTransactionParameterById.keyset()) {
             objId = s;
             recId = objId;
             tp = mapOfTransactionParameterById.get(objId); 
             tr = tp.TransactionResult;
         }
       
         ElavonDATUtils util = new ElavonDATUtils();
           Map<string,blng.TransactionResult> mapTR = new Map<string,blng.TransactionResult>();

           if (recId.getSObjectType().getDescribe().getName() == 'blng__Invoice__c') {
                 system.debug('chargeTransactionbyInvoice:  Parameters' + mapOfTransactionParameterById);
                 Map<string,ElavonDATUtils.ElavonDATResponse> mapGatewayResp = util.generateChargeByInvoice(mapOfTransactionParameterById);
                 for (string invID : mapGateWayResp.keyset()) {
					blng.transactionResult trbyInv = mapOfTransactionParameterById.get(invID).TransactionResult;
                   ElavonDATUtils.ElavonDATResponse gateWayResp = mapGatewayResp.get(invID);
         			trbyInv.setIsSuccess(gatewayResp.getSuccess());
         			trbyInv.setMessage('this is a message from Gateway Description' + ' ' + gatewayResp.Description);
         			trbyInv.setGatewayId(tp.getGateWayId());  //does not get populated
         			trbyInv.setRequestTransactionType('Charge');
         			trbyInv.setRequestTypeOfPayment('Credit Card');
              //trbyInv.setCardCodeResponse(mapGatewayResp.get(TransId)); //MS - Verify
               
            
         
            if (gatewayResp.getSuccess()) {
                trbyInv.setResponseMessage(gatewayResp.transid);
                trbyInv.setGatewayStatus(mapGatewayStatusEnumTypesByStrings.get('Success'));
                trbyInv.setResponseCode(gatewayResp.ProcessorResult);
                trbyInv.setResponseCodeMessage(gatewayResp.Description);

            }
            else {
                 trbyInv.setError('this is an error message'); // where does this go?
                 trbyInv.setResponseMessage('Elavon Gateway could not process the request.  ' + gatewayResp.status + ' ' +gatewayResp.description);
                 trbyInv.setGatewayStatus(mapGatewayStatusEnumTypesByStrings.get('SystemError')); // where does this go?
            }

         	mapTR.put(invID,trbyInv);
                   
               } 

         	system.debug('chargeTransaction byInvoiceID:  Result' + mapTR);
         	return mapTR;


           } //////////////////////end of invoice payments
else if (tp.getPaymentMethod().blng__PaymentGatewayToken__c == null) {
         Map<string,ElavonDATUtils.ElavonDATResponse> mapGatewayResp = util.generateCharge(mapOfTransactionParameterById);
                 return mapTR;
    } 
else {
    
    blng__PaymentTransaction__c ti = new blng__PaymentTransaction__c();
    ti.blng__Authorization__c = 'ssssssssssss';
    tp.setTransaction(ti);
        system.debug('chargeTransactionbyToken:  Parameters' + mapOfTransactionParameterById);
        //system.debug('does it have a token????' + tp.getPaymentMethod().blng__PaymentGatewayToken__c);
        
        try {
         Map<string,ElavonDATUtils.ElavonDATResponse> mapGatewayResp = util.generateChargeByToken(mapOfTransactionParameterById); 

       for (string oid : mapGatewayResp.keyset()) {
         tr.setIsSuccess(mapGatewayResp.get(oid).getSuccess());
         tr.setMessage('this is a message from Description' + ' ' + mapGatewayResp.get(oid).Description);
         tr.setGatewayId(tp.getGateWayId());
         tr.setCustomerProfileToken(tp.getAccount().blng__CustomerProfileId__c);  //is this how you set the customer profile token?
         tr.setRequestTransactionType('Charge');
         tr.setRequestTypeOfPayment('Credit Card');
            
         
            if (mapGatewayResp.get(oid).getSuccess()) {
                tr.setResponseMessage(mapGatewayResp.get(oid).transid);
                tr.setGatewayStatus(mapGatewayStatusEnumTypesByStrings.get('Success'));
                tr.setResponseCode(mapGatewayResp.get(oid).ProcessorResult);
                tr.setResponseCodeMessage(mapGatewayResp.get(oid).Description);

            }
            else {
                 tr.setError('this is an error message'); // where does this go?
                 tr.setResponseMessage('Elavon Gateway could not process the request.  ' + mapGatewayResp.get(oid).status + ' ' + mapGatewayResp.get(oid).description);
                 tr.setGatewayStatus(mapGatewayStatusEnumTypesByStrings.get('SystemError')); // where does this go?
            }
         mapTR.put(oId,tr);
            }
        }
           catch(DATException ex) {
                 tr.setError('this is an error message' + ex.getMessage()); // where does this go?
                 tr.setMessage('where does this goooooo????');
                 tr.setResponseMessage('Elavon Gateway could not process the request.');
                 tr.setGatewayStatus(mapGatewayStatusEnumTypesByStrings.get('ValidationError')); // where does this go?           
           }
           catch(system.Exception ex) {
                 tr.setError('this is an error message'); // where does this go?
                 tr.setResponseMessage('Elavon Gateway could not process the request.');
                 tr.setGatewayStatus(mapGatewayStatusEnumTypesByStrings.get('SystemError')); // where does this go?

            system.debug('ERROR transactionresult: ' + ex.getStackTraceString());
        
     
        
            }
            //system.debug('chargeTransaction:  Result' + tr);
         return mapTR;
         }          
       }
    //RefundTransaction method Salesforce billing interface class will use this class to Refund Transaction     
    
    public static Map<String, blng.TransactionResult> refundTransaction(Map<String, blng.TransactionParameter> mapOfTransactionParameterById)      { 
         blng.TransactionParameter tp;
         blng.transactionResult tr;
         string oId;
         for (string s : mapOfTransactionParameterById.keyset()) {
             oId = s;
             tp = mapOfTransactionParameterById.get(oId); 
             tr = tp.TransactionResult;
         }
         system.debug('refundTransaction:  Parameters' + mapOfTransactionParameterById);
           ElavonDATUtils util = new ElavonDATUtils();
           ElavonDATUtils.ElavonDATResponse gatewayResp = util.generateRefund(mapOfTransactionParameterById);
          
        try {
         tr.setResponseMessage(gatewayResp.status);
         tr.setIsSuccess(gatewayResp.getSuccess());
         tr.setMessage('this is a message from Description' + ' ' + gatewayResp.Description);
         tr.setGatewayId(tp.getGateWayId());
         tr.setCustomerProfileToken(tp.getAccount().blng__CustomerProfileId__c);  //is this how you set the customer profile token?
         tr.setRequestTransactionType('Refund');
       //   tr.setRequestTypeOfPayment('Credit Card');

            if (gatewayResp.getSuccess()) {
                tr.setResponseMessage(gatewayResp.transid);
                tr.setGatewayStatus(mapGatewayStatusEnumTypesByStrings.get('Success'));
                tr.setResponseCode(gatewayResp.ProcessorResult);
                tr.setResponseCodeMessage(gatewayResp.description);
            }
            else {
                 tr.setError('this is an error message'); // where does this go?
                 tr.setResponseMessage('Elavon Gateway could not process the request.  ' + gatewayResp.status + ' ' +gatewayResp.description);
                 tr.setGatewayStatus(mapGatewayStatusEnumTypesByStrings.get('SystemError')); // where does this go?
            }
        }
        catch(system.Exception ex) {
            system.debug('ERROR transactionresult: ' + ex.getStackTraceString());
        }

         Map<string,blng.TransactionResult> mapTR = new Map<string,blng.TransactionResult>();
         mapTR.put(oId,tr);
         system.debug('refundTransaction:  Result' + tr);
         return mapTR;
                  }        

     /**      * Does a SOQL lookup on the mapper table and gets the gateway status mapped to the return code 
* Returns the default enum if no match is found   
* @param transactionResult      */     
     public static void populateGatewayStatus(blng.TransactionResult transactionResult) {  
         blng.TransactionResult.GatewayStatusType gatewayStatus = defaultGatewayStatus;   
         system.debug('populateGatewayStatus');
         // actual implementation of mapping          transactionResult.setGatewayStatus(gatewayStatus);     
          }
     //Void Token method Salesforce billing interface class will use this class to void Token Transaction     
     public static Map<String, blng.TransactionResult> voidTokenTransaction(Map<String, blng.TransactionParameter> mapOfTransactionParameterById)      {     
         //Actual Implementation for Void Token takes place here
         system.debug('voidTokenTransaction method');
         return new Map<String, blng.TransactionResult>();
            }
     //Authorize Transaction method Salesforce billing interface class will use this class to Authorize Transaction     
     public static Map<String, blng.TransactionResult> authorizeTransaction(Map<String, blng.TransactionParameter> mapOfTransactionParameterById)      {   
         //Actual Implementation for Authorize takes place here    
         system.debug('authorizeTransaction');  
         return new Map<String, blng.TransactionResult>();
         } 
     //Capture Transaction method Salesforce billing interface class will use this class to capture Transaction    
      public static Map<String, blng.TransactionResult> captureTransaction(Map<String, blng.TransactionParameter> mapOfTransactionParameterById)      {   
          //Actual Implementation for capture takes place
         system.debug('captureTransaction method');    
            return new Map<String, blng.TransactionResult>();
           } 
 
     //void Transaction method Salesforce billing interface class will use this class to void Transaction
     public static Map<String, blng.TransactionResult> voidTransaction(Map<String, blng.TransactionParameter> mapOfTransactionParameterById)      {  
         //Actual Implementation for void Transaction takes place here
         system.debug('voidTransactoin method');  
       return new Map<String, blng.TransactionResult>();    
     } 
    //Non Referenced Refund method Salesforce billing interface class will use this class to non referenced refund Transaction     
    public static Map<String, blng.TransactionResult> nonReferencedRefund(Map<String, blng.TransactionParameter> mapOfTransactionParameterById)      {    
        //Actual Implementation for non referenced refund takes place here  
      return new Map<String, blng.TransactionResult>();    
    }          
     //void Refund method Salesforce billing interface class will use this class to non void Refund Transaction
     public static Map<String, blng.TransactionResult> voidRefundTransaction(Map<String, blng.TransactionParameter> mapOfTransactionParameterById)      { 
         //Actual Implementation for void Refund Transaction takes place here   
       return new Map<String, blng.TransactionResult>();    
     }          //Get payment status method Salesforce billing interface class will use this class to get payment status Transaction     
    public static Map<String, blng.TransactionResult> getPaymentStatus(Map<String, blng.TransactionParameter> mapOfTransactionParameterById)      {    
        //Actual Implementation for get payment status takes place here    
        system.debug('getPaymentStatus method');
          return new Map<String, blng.TransactionResult>();
         } 
     //Get refund status method Salesforce billing interface class will use this class to get refund status Transaction   
       public static Map<String, blng.TransactionResult> getRefundStatus(Map<String, blng.TransactionParameter> mapOfTransactionParameterById)      { 
           //Actual Implementation for get refund status takes place here 
           system.debug('getRefundStatus');
             return new Map<String, blng.TransactionResult>();
               }     

public class DATException extends Exception {}
}