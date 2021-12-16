/************************************* MODIFICATION LOG ********************************************************************************************
* ElavonDATUtils
*
* DESCRIPTION : Utility class that contains frequenly used methods to interact with Gateway
*
*---------------------------------------------------------------------------------------------------------------------------------------------------
* DEVELOPER                                 DATE        JIRA#            REASON
*---------------------------------------------------------------------------------------------------------------------------------------------------
* Acumen Solutions                          5/7/2019                     - Original Version 
*/

public class ElavonDATUtils {
    public static ElavonDATResponse elavonDATResp;

    public class DATBinInfo {
        public string Issuer;
        public string DebitCredit;
        //public string Class;
        public string Country;
    }
    public class DATChargeSource {
        private string BillId;
        private string Amount;
        public DATChargeSource(string bID, string amt) {
            this.BillId = bID;
            this.Amount = amt;
        }
    }
    public class ElavonDATRequest {
        public string Name;
        public string CardNumber;
        public string ExpDate;
        private string SecurityId;
        public string RequestedBy;
        public string StreetAddress;
        public string City;
        public string State;
        public string PostalCode;
        public string Country;
        public List<DATChargeSource> ChargeSources = new List<DATChargeSource>();
        
        public boolean setStreetAddress(string address) {
            if (address == null || address == '') {
            	return false;    
            }
            else {
                this.StreetAddress = address;
            }
            return true;
        }
        
        public boolean setSecurityID(string cvv) {
            if (cvv == null || cvv == '') {
                return false;
            }
            else {
                this.SecurityID = cvv;
            }
            return true;
        }
        public boolean setName(string nm) {
            if (nm == null || nm == '') {
                return false;
            }
            else {
                this.Name = nm;
            }
            return true;
        }
        private boolean validateDate(string mo, string yr) {
            if (mo == null || yr == null) {
            	return false;
            }
            return true;
            
        }
        public boolean setExpirationDate(string mo, string yr) {
            if (validateDate(mo, yr)) {
            	ExpDate = mo + yr.right(2);
            	return true;
            }
            return false;
            
        }
        public string setCountry(string ctry) {
            return Country = 'USA';
        }
        public string Token;
        public string AccountNo;
        public boolean CheckForDuplicates = false;
        public string Amount;
        public string TransId;
    }
    public class ElavonDATResponse {
        public string Status;
        public string StatusCode;
        public string Success;
        public string ProcessorResult;
        public string TransId;
        public string Description;
        public string AvsResponse;
        public string Cvv2Response;
        public string CardToken;
        public string AuthCode;
        public DATBinInfo BinInfo;
        public boolean getSuccess() {
            return boolean.valueOf(Success);
        }
    }
    
    public ElavonDatResponse generateToken(Map<string,blng.TransactionParameter> listOfTransactionParameter)      {   
        //string js = '{"Name": "Bob M. Cardholder","CardNumber": "4444333322221111","ExpDate": "1020","SecurityId": "123","RequestedBy": "Salesforce","StreetAddress": "1234 Main Street","City": "San Francisco","State": "CA","PostalCode": "94114","Country": "USA","Currency": "840"}';
        // {"Success":true,"ProcessorResult":"0","TransId":"020519A19-40FDEF56-33A2-49CA-B6A4-776ECFEEA2B4","Description":"APPROVAL","AvsResponse":"X","Cvv2Response":"U","CardToken":"7567780112341111","BinInfo":{"Issuer":"VISA","DebitCredit":"CREDIT","Class":"","Country":"USA"}
        string sId;
        blng__PaymentMethod__c paymentMethod;
        for (string recId : listOfTransactionParameter.keyset()) {
            sId = recId;
        }
        ElavonDATRequest edReq = new ElavonDATRequest();
        Account acc = listOfTransactionParameter.get(sId).getAccount();
        if (!edReq.setName(listOfTransactionParameter.get(sId).getFirstName() + ' ' + listOfTransactionParameter.get(sId).getLastName())) {
            ElavonDATResponse edresp = new ElavonDATResponse();
            edresp.statuscode = '002';
            edresp.success = 'False';
            edresp.status = 'Name missing';
            edresp.description = 'Name is missing';
            return  edresp;

        }
        paymentMethod = listOfTransactionParameter.get(sId).getPaymentMethod();
      //  edReq.CardNumber = listOfTransactionParameter.get(sId).getCardNumber(); // why is this blank?
       // edReq.CardNumber = '4444333322221111';
       // 

        edReq.CardNumber = listOfTransactionParameter.get(sId).getPaymentMethod().blng__CardNumber__c;
        if (!edReq.setSecurityId(listOfTransactionParameter.get(sId).getPaymentMethod().blng__CVV__c)) {
              ElavonDATResponse edresp = new ElavonDATResponse();
            edresp.statuscode = '003';
            edresp.success = 'False';
            edresp.status = 'CVV';
            edresp.description = 'CVV is missing';
            return  edresp;
        }
        edReq.RequestedBy = 'Salesforce';
        if (!edReq.setStreetAddress(listOfTransactionParameter.get(sId).getStreet())) {
              ElavonDATResponse edresp = new ElavonDATResponse();
            edresp.statuscode = '004';
            edresp.success = 'False';
            edresp.status = 'Address';
            edresp.description = 'Street Address is missing';
            return  edresp;
        }
        edReq.City = listOfTransactionParameter.get(sId).getCity();
        edReq.State = listOfTransactionParameter.get(sId).getState();
        edReq.PostalCode = listOfTransactionParameter.get(sId).getZipCode();
        edReq.Country = listOfTransactionParameter.get(sId).getCountry(); //needs to be converted to USA
   
        if (!edReq.setExpirationDate(listOfTransactionParameter.get(sId).getPaymentMethod().blng__CardExpirationMonth__c, listOfTransactionParameter.get(sId).getPaymentMethod().blng__CardExpirationYear__c)) {
            ElavonDATResponse edresp = new ElavonDATResponse();
            edresp.statuscode = '001';
            edresp.success = 'False';
            edresp.status = 'bad date';
            edresp.description = 'Expiration Date is Invalid';
            return  edresp;
        }
   
        
       
        
        string jsonPayload = JSON.serialize(edReq);
                DATLoggingUtil.initialize();            
                DATLoggingUtil.addEventLogListItem(jsonPayload, 'ElavonDatUtils.generateToken', acc.id);
          ElavonDATResponse edresp;
        string jsonResponse;
            try {
            jsonResponse = calloutElavonDAT(jsonPayload,'tokenize');
            DATLoggingUtil.addEventLogListItem(jsonResponse, 'ElavonDatUtils.generateToken',acc.id);
            DATLoggingUtil.logList();
          

                edresp = (ElavonDATResponse) JSON.deserialize(jsonResponse, ElavonDATResponse.class);
            }
            catch(system.Exception ex) {
                system.debug('deserialize problem: ' + jsonResponse + ex.getStackTraceString());
            }
            return  edresp;
    }
    
    public map<string,ElavonDatResponse> generateCharge(Map<String, blng.TransactionParameter> mapOfTransactionParameter) {
        Map<string,ElavonDatRequest> mapRequest;
        Map<string,ElavonDatResponse> mapResponse = new Map<string,ElavonDatResponse>();
     //   ElavonDATRequest edReq = new ElavonDATRequest();
		mapRequest = getElavonRequest(mapOfTransactionParameter);

           		for (string oId : mapRequest.keyset()) {
       
            string jsonPayload = JSON.serialize(mapRequest.get(oId));
                DATLoggingUtil.initialize();            
                DATLoggingUtil.addEventLogListItem(jsonPayload, 'ElavonDatUtils.generateChargeByToken', null);
        
          	string jsonResponse = calloutElavonDAT(jsonPayload,'charge');
            	DATLoggingUtil.addEventLogListItem(jsonResponse, 'ElavonDatUtils.generateChargeByToken',null);
            ElavonDATResponse edresp;
            try {
                edresp = (ElavonDATResponse) JSON.deserialize(jsonResponse, ElavonDATResponse.class);
                mapResponse.put(oId,edresp);
            }
            catch(system.Exception ex) {
                system.debug('deserialize problem: ' + jsonResponse + ex.getStackTraceString());
            }
        }
        DATLoggingUtil.logList();
        return mapResponse;

    }
    public map<string,ElavonDatResponse> generateChargebyToken(Map<String, blng.TransactionParameter> mapOfTransactionParameter) {
       // string js =   '{ "AccountNo": "239189-364627","Name": "Bob M. Cardholder","Token": "4444333322221111","ExpDate": "1020","Amount": 1100,"StreetAddress": "1234 Main St","City": "San Fransisco","State": "CA","PostalCode": "94114", "Country": "USA", "ChargeSources": [{"BillId": "3212934","Amount": 1100}],"CheckForDuplicates": true,"RequestedBy": "Bob User" }';
        
        Map<string,ElavonDatRequest> mapRequest;
        Map<string,ElavonDatResponse> mapResponse = new Map<string,ElavonDatResponse>();
     //   ElavonDATRequest edReq = new ElavonDATRequest();
		mapRequest = getElavonRequest(mapOfTransactionParameter);

        
   		for (string oId : mapRequest.keyset()) {
       
            string jsonPayload = JSON.serialize(mapRequest.get(oId));
                DATLoggingUtil.initialize();            
                DATLoggingUtil.addEventLogListItem(jsonPayload, 'ElavonDatUtils.generateChargeByToken', null);
        
          	string jsonResponse = calloutElavonDAT(jsonPayload,'charge');
            	DATLoggingUtil.addEventLogListItem(jsonResponse, 'ElavonDatUtils.generateChargeByToken',null);
            ElavonDATResponse edresp;
            try {
                edresp = (ElavonDATResponse) JSON.deserialize(jsonResponse, ElavonDATResponse.class);
                mapResponse.put(oId,edresp);
            }
            catch(system.Exception ex) {
                system.debug('deserialize problem: ' + jsonResponse + ex.getStackTraceString());
            }
        }
        DATLoggingUtil.logList();
        return mapResponse;
    }

    private Map<string,ElavonDATRequest> getElavonRequest(Map<String, blng.TransactionParameter> mapOfTransactionParameter) {
        Map<string,ElavonDATRequest> reqList = new Map<string,ElavonDATRequest>();
        ElavonDATRequest edReq;
        blng__PaymentMethod__c paymentMethod;

        for (string oID : mapOfTransactionParameter.keyset()) {
            edReq = new ElavonDATRequest();
            Account acc = mapOfTransactionParameter.get(oId).getAccount();
	        paymentMethod = mapOfTransactionParameter.get(oId).getPaymentMethod();
            edReq.AccountNo = [select accountnumber from account where id =: acc.id ].accountNumber;
            edReq.Name = paymentMethod.blng__Nameoncard__c;
            edReq.Amount = mapOfTransactionParameter.get(oId).getAmount();
            edReq.ChargeSources.add(new DATChargeSource(acc.id,edReq.Amount));
            edReq.Token = paymentMethod.blng__PaymentGatewayToken__c;
            edReq.setExpirationDate(mapOfTransactionParameter.get(oId).getPaymentMethod().blng__CardExpirationMonth__c, mapOfTransactionParameter.get(oId).getPaymentMethod().blng__CardExpirationYear__c);
            edReq.RequestedBy = 'Salesforce';
            edReq.StreetAddress = mapOfTransactionParameter.get(oId).getStreet();
            edReq.City = mapOfTransactionParameter.get(oId).getCity();
            edReq.State = mapOfTransactionParameter.get(oId).getState();
            edReq.PostalCode = mapOfTransactionParameter.get(oId).getZipCode();
            edReq.Country = mapOfTransactionParameter.get(oId).getCountry(); //needs to be converted to USA
            reqList.put(oId,edReq);
        }
        return reqList;
    }

    public Map<string,ElavonDatResponse> generateChargebyInvoice(Map<String, blng.TransactionParameter> mapOfTransactionParameterByInvoiceId)     {    
        Map<string,ElavonDatRequest> mapRequest;
        Map<string,ElavonDatResponse> mapResponse = new Map<string,ElavonDatResponse>();
     //   ElavonDATRequest edReq = new ElavonDATRequest();
		mapRequest = getElavonRequest(mapOfTransactionParameterByInvoiceId);
        
        for (string invID : mapRequest.keyset()) {
		    		
            string jsonPayload = JSON.serialize(mapRequest.get(invID));
               DATLoggingUtil.initialize();            
               DATLoggingUtil.addEventLogListItem(jsonPayload, 'ElavonDatUtils.generateChargeByInvoice', null);
        
          string jsonResponse = calloutElavonDAT(jsonPayload,'charge');
            DATLoggingUtil.addEventLogListItem(jsonResponse, 'ElavonDatUtils.generateChargeByInvoice',null);
           
            ElavonDATResponse edresp;
           try {
                edresp = (ElavonDATResponse) JSON.deserialize(jsonResponse, ElavonDATResponse.class);
                mapResponse.put(invId,edresp);
           }
            catch(system.Exception ex) {
                system.debug('deserialize problem: ' + jsonResponse + ex.getStackTraceString());
            }
							
        }
         DATLoggingUtil.logList();
          return mapResponse;
         } 
 
     
        public ElavonDatResponse generateRefund(Map<String, blng.TransactionParameter> mapOfTransactionParameter)     {   
            string sId;
        blng__PaymentMethod__c paymentMethod;
        for (string recId : mapOfTransactionParameter.keyset()) {
            sId = recId;
        }
        ElavonDATRequest edReq = new ElavonDATRequest();
        //Account acc = mapOfTransactionParameter.get(sId).getAccount().id;
        edReq.Amount = mapOfTransactionParameter.get(sId).getAmount();
      //  edReq.TransId = mapOfTransactionParameter.get(sId).getPayment().blng__GatewayResponse__c;
        edReq.RequestedBy = 'Salesforce';
            
        
        string jsonPayload = JSON.serialize(edReq);
                DATLoggingUtil.initialize();            
                DATLoggingUtil.addEventLogListItem(jsonPayload, 'ElavonDatUtils.generateRefund', mapOfTransactionParameter.get(sId).getAccount().id);
                
        string jsonResponse = calloutElavonDAT(jsonPayload,'refund');
            DATLoggingUtil.addEventLogListItem(jsonResponse, 'ElavonDatUtils.generateRefund', mapOfTransactionParameter.get(sId).getAccount().id);
            DATLoggingUtil.logList();
            ElavonDATResponse edresp;
            try {
                edresp = (ElavonDATResponse) JSON.deserialize(jsonResponse, ElavonDATResponse.class);
            }
            catch(system.Exception ex) {
                system.debug('deserialize problem: ' + jsonResponse + ex.getStackTraceString());
            }
            return  edresp;
              } 
 
    public void generatenonReferencedRefund(Map<String, blng.TransactionParameter> mapOfTransactionParameterByInvoiceId)     { 
        
        //Frame xml/json for generate non referenced refund api method   
          }   
   
    private string calloutElavonDat(string jsonRequest,string service) {
        ElavonDATResponse edresp;
        string jsonResponse;
        string endPoint;
        if (service == 'tokenize') {
           endPoint = 'https://svcs.datstage.com/api/TEST1/cc/tokenize';
        }
        if (service == 'charge') {
           endPoint = 'https://svcs.datstage.com/api/TEST1/cc/chargeByToken';
        }

        if (service == 'chargebytoken') {
           endPoint = 'https://svcs.datstage.com/api/TEST1/cc/chargeByToken';
        }

        if (service == 'refund') {
            endpoint = 'https://svcs.datstage.com/api/TEST1/cc/reverse';
        }
        HttpRequest httpRequest = new HttpRequest();  
        httpRequest.setMethod('POST');   
        httpRequest.setHeader('Content-Type', 'application/json;charset=UTF-8');
        httpRequest.setEndpoint(endPoint);
        httpRequest.setClientCertificateName('DATSFDCTEST');
        httpRequest.setBody(jsonRequest);
        try {
        Http http = new Http();   
        HttpResponse httpResponse = http.send(httpRequest);
	        if (httpResponse.getStatusCode() != 200) {
    	        edresp = new ElavonDATResponse();
        	    edresp.statuscode = string.valueof(httpResponse.getStatusCode());
            	edresp.success = 'False';
            	edresp.status = httpResponse.getStatus();
            	edresp.description = httpResponse.getBody();
            	jsonResponse = JSON.serialize(edresp);
        	}
        	else {
            	jsonResponse = httpResponse.getBody();
        	}
        }
        catch(system.Exception ex) {
            edresp = new ElavonDATResponse();
            edresp.statuscode = '010';
            edresp.success = 'False';
            edresp.status = 'Apex Error';
            edresp.description =  'Apex Error - Message:  ' + ex.getMessage();
            jsonResponse = JSON.serialize(edresp);
            System.debug('Callout Elavon ERROR: ' + ex.getStackTraceString());
        }
 System.debug(' httpResponse ' + jsonResponse);
        return jsonResponse;
    }
     public void generateVoidRefund(Map<String, blng.TransactionParameter> mapOfTransactionParameterByInvoiceId)     {  
               //Frame xml/json for generate void refund api method    
                } 
 
    public void generateGetPaymentStatus(List<blng.TransactionParameter> listOfTransactionParameter)      {    
        //Frame xml/json for generate get payment status api method   
          } 
 
    public void generateGetRefundStatus(List<blng.TransactionParameter> listOfTransactionParameter)      {     
        //Frame xml/json for generate get refund status api method    
         } 
     public void generateVoidToken(List<blng.TransactionParameter> listOfTransactionParameter)      {        
         //Frame xml/json for void token api method     
          }         
         
      public void generateAuthorize(Map<String, blng.TransactionParameter> mapOfTransactionParameterByInvoiceId)     {   
          //Frame xml/json for generate authorize api method    
            }  
 
    public void generateCapture(Map<String, blng.TransactionParameter> mapOfTransactionParameterByInvoiceId)     {  
        //Frame xml/json for generate capture api method    
         } 
 public void generateVoid(Map<String, blng.TransactionParameter> mapOfTransactionParameterByInvoiceId)     {    
        //Frame xml/json for generate void api method    
         }     
        }