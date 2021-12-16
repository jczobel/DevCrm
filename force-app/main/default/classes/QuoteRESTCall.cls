public class QuoteRESTCall {
    //grant_type=password
    //username=integration%40dat.devcrm
    //password=Universal1d2HlFFzOw8dPsUMtxgHwcQF3
    //client_id=3MVG9Gmy2zmPB01rmlg_gxgRqIWC8MT6SHD72GHGZkFMVNGoP48Y4VcXKoINZJLO3.s5b3NLoVfgnhtDPd499
    //client_secret=5145CA4D2118817C8503EA931147C80C5ABA37D23429A5094E6FB225C2DC7440
private string QuoteBaseURL ;
public  string getSessionId(){
        QuoteProposal__mdt  salesforceAppKeys = [select RestURL__c, ClientId__c, Password__c, secret__c, UserName__c,Parameter__c 
                                                 from QuoteProposal__mdt
                                                 Where MasterLabel = 'QuoteProposal' limit 1]; //QuoteProposalCS.getInstance('QuoteProposal');
        
        string accesstoken;
        //string endpoint = restfullAPIURL+Uname+Pword+clineid+secret;
        //EncodingUtil.urlEncode(timestamp, 'UTF-8');

        string endpoint = salesforceAppKeys.RestURL__c + '&';
        endpoint += 'username='		+ EncodingUtil.urlEncode(salesforceAppKeys.UserName__c, 'UTF-8') +'&';
        endpoint += 'password=' 	+ EncodingUtil.urlEncode(salesforceAppKeys.Password__c, 'UTF-8') +'&';
        endpoint += 'client_id='	+ EncodingUtil.urlEncode(salesforceAppKeys.ClientId__c, 'UTF-8')+'&';
        endpoint += 'client_secret='	+ EncodingUtil.urlEncode(salesforceAppKeys.secret__c, 'UTF-8');
        system.debug('s' + endPoint);
        //QuoteBaseURL = salesforceAppKeys.QuoteBaseURL__c;
       
        HttpRequest httpRequest = new HttpRequest();  
        httpRequest.setMethod('POST');   
        httpRequest.setEndpoint(endpoint);   
        
        String response = '';
        try {  
            Http http = new Http();   
            HttpResponse httpResponse = http.send(httpRequest);  
            if (httpResponse.getStatusCode() == 200 ) {  
                response = JSON.serializePretty( JSON.deserializeUntyped(httpResponse.getBody()) );  
            } else {  
                System.debug(' httpResponse ' + httpResponse.getBody() );  
                throw new CalloutException( httpResponse.getBody() );  
            }   
        } catch( System.Exception e) {  
            System.debug('ERROR: '+ e);  
            throw e;  
        }  
        System.debug(' ** response ** : ' + response );
        
        JSONParser parser = JSON.createParser(response);
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
                String fieldName = parser.getText();
                parser.nextToken();
                if(fieldName == 'access_token') {
                    accesstoken = parser.getText();
                }
                if(fieldName == 'instance_url'){
                   QuoteBaseURL = parser.getText();
                   QuoteBaseURL = QuoteBaseURL +salesforceAppKeys.Parameter__c; //salesforceAppKeys.Parameter__c
                }
            }
        }
        
        return accesstoken;
    }
    
    public  void CallUpdate(string quoteId){
        //Make sure your Salesforce instance URL is added in remote site settings
        String sfdcURL = URL.getSalesforceBaseUrl().toExternalForm(); 
        //'https://cs7.salesforce.com/services/data/v45.0/sobjects/SBQQ__Quote__c/'
        String accesstoken = getSessionId();
        String restAPIURL = QuoteBaseURL+quoteId+'?_HttpMethod=PATCH';  
        
        //Post
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setTimeout(30000);
        httpRequest.setEndpoint(restAPIURL);  
        httpRequest.setMethod('POST');   

        httpRequest.setHeader('Content-Type', 'application/json;charset=UTF-8');
        httpRequest.setHeader('Authorization', 'Bearer ' + accesstoken); 
        
        JSONGenerator gen = JSON.createGenerator(true);
		gen.writeStartObject();
        gen.writeStringField('SBQQ__Status__c', 'Accepted');
        gen.writeDateTimeField ('Quote_Accepted_On__c', DateTime.now());
        gen.writeBooleanField('DAT_OSA_Accepted_by_Customer__c',true);
        gen.writeEndObject();
        system.debug('Jason Response :' + gen.getAsString().remove('\r').remove('\n'));
        httpRequest.setBody(gen.getAsString().remove('\r').remove('\n'));
        //httpRequest.setBody('{"Quote_Accepted_On__c":"{!DateTime.now()}","SBQQ__Status__c":"Accepted", "DAT_OSA_Accepted_by_Customer__c":true}');
        //httpRequest.setBody('{"DAT_OSA_Accepted_by_Customer__c":true}'); 
            
        String response = '';
        try {  
            Http http = new Http();   
            HttpResponse httpResponse = http.send(httpRequest);  
            System.debug('Status : '+ httpResponse.getStatusCode());
            if (httpResponse.getStatusCode() == 200 ||httpResponse.getStatusCode() == 204 ) {  
                System.debug(' httpResponse ' + httpResponse.getBody() );
            } else {  
                System.debug(' httpResponse ' + httpResponse.getBody() );  
                throw new CalloutException( 'httpResponse Status : '+ httpResponse.getStatusCode() +'. Body :'+  httpResponse.getBody() );  
            }     
        } catch( System.Exception e) {  
            System.debug('ERROR: '+ e);  
            throw e;  
        }  
    }
}