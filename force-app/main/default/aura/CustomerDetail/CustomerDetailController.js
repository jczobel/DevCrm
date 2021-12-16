({
  getRecord: function (component, event, helper) {
    helper.loadAccount(component, event, helper);
    helper.loadQuote(component, event, helper);
  },

  fedIdOnblur: function (component, event, helper) {
    component.set("v.fedId", component.get("v.fedId").replace(/[^0-9]+/g, ""));
  },
  showSaveOnChange: function (component, event, helper) {
    component.set("v.showSave", true);
  },
  cancelSave: function (component, event, helper) {
    helper.loadAccount(component, event, helper);
    helper.loadQuote(component, event, helper);
    component.set("v.showSave", false);
    component.set("v.checkToast", false);
  },
  updateRecord: function (component, event, helper) {
    var accData = component.get("v.accountData");
    var businessType = accData.Business_Type__c;//component.find("businessType").get("v.value");
    var PrimaryBillingEmailAddress__c = accData.PrimaryBillingEmailAddress__c;
    var SecondaryBillingEmailAddress__c = accData.SecondaryBillingEmailAddress__c;

    accData.FederalID__c = component.get("v.fedId");
    accData.Business_Type__c = businessType;

    var requiredCheck = false;
    var errorMessage = "Please Enter";
    //var lightningAppExternalEvent = $A.get("e.c:lightningAppExternalEvent");

    if (businessType == null || businessType == "" || businessType == "") {
      errorMessage = errorMessage + " Business Type";
      requiredCheck = true;
    }
    if (!PrimaryBillingEmailAddress__c) {
      errorMessage = errorMessage + " Primary Billing Email Address";
      requiredCheck = true;
    } else {
      if (!component.find("primaryBillingEmailInput").get("v.validity").valid) {
        errorMessage = errorMessage + " Valid Primary Billing Email Address value";
        requiredCheck = true;
      }
    }

    if (SecondaryBillingEmailAddress__c) {
      if (!component.find("secondaryBillingEmailInput").get("v.validity").valid) {
        errorMessage = errorMessage + " Valid Secoundary Billing Email Address value";
        requiredCheck = true;
      }
    };

    if (accData.LegalName__c == null || accData.LegalName__c == "") {
      if (requiredCheck) {
        errorMessage = errorMessage + ", Company Legal Name ";
      } else {
        errorMessage = errorMessage + " Company Legal Name ";
      }
      requiredCheck = true;
    }

    // Validate federal id value
    if (!accData.FederalID__c) {
      var fedvalidity = component.find("fedIdInput").get("v.validity");
      if (!fedvalidity.valid) {
        errorMessage = errorMessage + ', Federal Tax Id';
        requiredCheck = true;
      }
    }
    /* if(accData.FederalID__c == null || accData.FederalID__c == '') {
            if(requiredCheck) {
                errorMessage = errorMessage+', Federal Tax Id';
            } else {
                errorMessage = errorMessage+' Federal Tax Id';
            }
            requiredCheck = true; 
        }*/

    if (requiredCheck == true) {
      component.set("v.toastmsg", errorMessage);
      component.set("v.toastType", "error");
      component.set(
        "v.toastcss",
        "slds-notify slds-notify_toast slds-theme_warning"
      );
      component.set("v.checkToast", true);
      helper.fireEvent(component, event, helper);

    } else {
      component.set("v.accountData", accData);
      //component.set(component.get('v.accountData.FederalID__c'), component.get('v.fedId'));
      var action = component.get("c.saveAccountData");
      action.setParams({ accountObj: component.get("v.accountData") });
      action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          //debugger;
          var saveStatus = response.getReturnValue();
          if (saveStatus) {
            component.set("v.isValid", true);
            $A.get("e.force:refreshView").fire();
            component.set("v.toastmsg", "Record has been updated successfully");
            component.set("v.toastType", "success");
            component.set(
              "v.toastcss",
              "slds-notify slds-notify_toast slds-theme_success"
            );
            component.set("v.checkToast", true);
            component.set("v.showSave", false);
            component.set("v.checkToast", false);
            component.set("v.accountDataClone", accData);
            /* var func = component.get('v.callback');
                        alert('func '+func);
                        if (func){
                            func({isValid:component.get('v.isValid')});
                        }*/
            //

            //location.reload();
            //$A.get('e.force:refreshView').fire();
            /*setTimeout(function(){
                            window.open(window.location.href,'_self');
                        }, 1000);*/

            console.log(
              "Inside lightning controller function-->callExternalFunction"
            );
            helper.fireEvent(component, event, helper);

          } else {
            component.set(
              "v.toastmsg",
              "An error occured. Please contact System Administrator"
            );
            component.set("v.toastType", "error");
            component.set(
              "v.toastcss",
              "slds-notify slds-notify_toast slds-theme_error"
            );
            component.set("v.checkToast", true);
          }
        }
      });
      $A.enqueueAction(action);
    }
  },

  onBusinessTypeChange: function (component, event, helper) {
    var accData = component.get("v.accountData");
    accData.Business_Type__c = component.find("businessType").get("v.value");;
  },

  closeIcon: function (component, event, helper) {
    //if(document.getElementById("toastCmp"))
    //document.getElementById("toastCmp").style.display = "none";
    component.set("v.checkToast", false);
  }
});