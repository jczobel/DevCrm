global class SendDATEmail {
 @InvocableMethod (label = 'Send Email')
	public static List<CustomEmailResponse> sendEmail(List<CustomEmailRequest> requests) {
        List<CustomEmailResponse> responses = new List<CustomEmailResponse>();
        CustomEmailResponse resp = new CustomEmailResponse();
        try {
        	for (CustomEmailRequest req : requests) {
          		Emailtemplate templateHTML = [ SELECT id, subject, HtmlValue FROM EmailTemplate where id =: req.templateID ];
          		Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
          			semail.setSaveAsActivity(true);
          			semail.setTreatTargetObjectAsRecipient(false);
          			semail.setWhatId(req.quoteID);
          			semail.setTreatBodiesAsTemplate(True);    
          			semail.setHtmlBody(templateHTML.HtmlValue);
          			semail.setSubject(templateHTML.subject);
          			semail.setToAddresses(req.emailRecipients);
                	semail.setTargetObjectId(req.contactID);
          			Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail});  
        	}
        }
        catch(system.Exception ex) {
            resp = new CustomEmailResponse();
            resp.isSuccess = false;
            resp.failResult = ex.getMessage();
        	responses.add(resp);
            return responses;
        }
            resp = new CustomEmailResponse();
            resp.isSuccess = true;
        	responses.add(resp);
    		return responses;	
	}

global class CustomEmailRequest {
  @InvocableVariable(required=true)
    global ID templateID;
  @InvocableVariable(required=true)
    global ID quoteID;
  @InvocableVariable (required=true)
    global List<string> emailRecipients;
  @InvocableVariable (required=true)
    global ID contactID;
}

global class CustomEmailResponse {
  @InvocableVariable(required=true)
    global boolean isSuccess;
  @InvocableVariable
    global string failResult;
}
}