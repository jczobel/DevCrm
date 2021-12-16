({
	loadQuote: function (component, event, helper) {
		debugger;
		var quoteId = component.get("v.quoteId");
		var quoteAction = component.get("c.loadQuoteData");
		quoteAction.setParams({ quoteId: quoteId });
		quoteAction.setCallback(this, function (response) {
			if (response.getState() === "SUCCESS") {
				var res = response.getReturnValue();
				component.set("v.quoteData", response.getReturnValue());

				//var respObj = component.get("v.quoteData");
				//respObj.push(response.getReturnValue());
				//component.set("v.quoteData", respObj);

				console.log(`Message :  ${res}`);
				//console.log(`Message Billing Contact ${component.get("v.quoteData.Billing_Contact__r.firstname")}`);
			}
			this.fireEventInit(component, event, helper);
		});
		$A.enqueueAction(quoteAction);
	},

	loadAccount: function (component, event, helper) {
		//debugger;
		var acctId = component.get("v.recordId");
		var action = component.get("c.loadAccountData");
		action.setParams({ accountId: acctId });
		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {

				component.set("v.accountData", response.getReturnValue());
				component.set("v.accountDataClone", response.getReturnValue());
				component.set("v.fedId", response.getReturnValue().FederalID__c);
				if (
					response.getReturnValue() != null &&
					response.getReturnValue().LegalName__c != null &&
					response.getReturnValue().Business_Type__c != null &&
					response.getReturnValue().PrimaryBillingEmailAddress__c != null
				) {
					component.set("v.showSave", false);
				} else {
					component.set("v.showSave", true);
				}


				if (
					response.getReturnValue() != null &&
					response.getReturnValue().Business_Type__c == null
				) {
					this.loadBusinessType(component, event, helper)
				}
			}
		});
		$A.enqueueAction(action);

	},
	loadBusinessType: function (component, event, helper) {
		var action1 = component.get("c.getBustinessTypePicklistValues");
		var opts = [];
		action1.setCallback(this, function (resp) {
			var state = resp.getState();
			//debugger;
			if (state === "SUCCESS") {
				var allValues = resp.getReturnValue();
				if (allValues != undefined && allValues.length > 0) {
					opts.push({
						class: "optionClass",
						label: "--- None ---",
						value: ""
					});
				}
				for (var i = 0; i < allValues.length; i++) {
					opts.push({
						class: "optionClass",
						label: allValues[i],
						value: allValues[i]
					});
				}
				if (typeof component.find("businessType") != "undefined")
					component.find("businessType").set("v.options", opts);
			}
		});
		$A.enqueueAction(action1);
	},
	fireEvent: function (component, event, helper) {
		let lightningAppExternalEvent = $A.get("e.c:lightningAppExternalEvent");
		let accountValidated = false;

		component.get("v.checkToast") == true ? accountValidated = false : accountValidated = true;

		lightningAppExternalEvent.setParams({ "message": component.get("v.toastmsg") });
		lightningAppExternalEvent.setParams({ "accountValidated": accountValidated });
		lightningAppExternalEvent.fire();

	},
	fireEventInit: function (component, event, helper) {
		debugger;
		let accountValidated = true;
		let errorMessage = "Please enter required fields :";
		let lightningAppExternalEvent = $A.get("e.c:lightningAppExternalEvent");

		let accData = component.get("v.accountData");
		let businessType = accData.Business_Type__c;
		let legalName = accData.LegalName__c;
		let PrimaryBillingEmailAddress__c = accData.PrimaryBillingEmailAddress__c;

		console.log(`DEBUG : Legal Name : ${legalName}, Account Type : ${businessType}`);

		if (businessType == null) {
			accountValidated = false;
			errorMessage = errorMessage + " Account Type";
		};
		if (legalName == null) {
			accountValidated = false;
			errorMessage = errorMessage + " Account Legal Name";
		}
		if (PrimaryBillingEmailAddress__c == null) {
			accountValidated = false;
			errorMessage = errorMessage + " Primary Billing Email Address";
		}

		lightningAppExternalEvent.setParams({ "message": errorMessage });
		lightningAppExternalEvent.setParams({ "accountValidated": accountValidated });
		lightningAppExternalEvent.fire();
		//Warning - Please enter required fields: Company Legal Name, Business Type, Primary Billing Email Address.
	}
})