({
    getRecord : function(component, event, helper) {
        var action = component.get("c.loadAccountData");
        action.setParams({"accountId" : component.get('v.recordId')});
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {      
                
                component.set('v.accountData',response.getReturnValue());
                component.set('v.accountDataClone',response.getReturnValue());
                if(response.getReturnValue()!=null && response.getReturnValue().LegalName__c !=null && response.getReturnValue().Business_Type__c != null && response.getReturnValue().FederalID__c !=null) {
                    component.set('v.showSave', false);
                } else {
                    component.set('v.showSave', true);
                }
                
                if(response.getReturnValue()!=null && response.getReturnValue().Business_Type__c == null){
                var action1 = component.get("c.getBustinessTypePicklistValues");
                var opts = [];
                action1.setCallback(this, function(resp){
                    var state = response.getState();
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
                        if(typeof component.find("businessType") != 'undefined')
                        	component.find("businessType").set("v.options", opts);
                    }
                });
                $A.enqueueAction(action1);
                }
            }
        });
        $A.enqueueAction(action);
        
        
    },
    
    updateRecord : function(component, event, helper) {
        debugger;
        
        
        var accData = component.get('v.accountData');
        if(accData.Business_Type__c ==null || accData.Business_Type__c == '') {
            var businessType = component.find("businessType").get("v.value");
        	accData.Business_Type__c = businessType;
        } else {
            businessType = accData.Business_Type__c;
        }
        
        
        var requiredCheck = false;
        var errorMessage = 'Please Enter';
        
        if(businessType == null || businessType == '') {
            errorMessage = errorMessage+' Business Type';
            requiredCheck = true;
        }
        if(accData.LegalName__c == null || accData.LegalName__c == '') {
            if(requiredCheck) {
                errorMessage = errorMessage+', Company Legal Name ';
            } else {
                errorMessage = errorMessage+' Company Legal Name ';
            }
            requiredCheck = true;
        }
        if(accData.FederalID__c == null || accData.FederalID__c == '') {
            if(requiredCheck) {
                errorMessage = errorMessage+', Federal Tax Id';
            } else {
                errorMessage = errorMessage+' Federal Tax Id';
            }
            requiredCheck = true; 
        }
        
        if(requiredCheck == true) {
            component.set('v.toastmsg',errorMessage);
            component.set('v.toastType','error');
            component.set("v.toastcss",'slds-notify slds-notify_toast slds-theme_error');
            component.set("v.checkToast",true);
            
            
        } else {
            component.set('v.accountData',accData);
            var action = component.get("c.saveAccountData");
            action.setParams({"accountObj" : component.get('v.accountData')});
            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {   
                    debugger;
                    var saveStatus = response.getReturnValue();
                    if(saveStatus){
                        component.set('v.toastmsg','Record has been updated successfully');
                        component.set('v.toastType','success');
                        component.set("v.toastcss",'slds-notify slds-notify_toast slds-theme_success');  
                        component.set("v.checkToast",true);
                        component.set("v.accountDataClone",accData); 
                        setTimeout(function(){
                            window.open(window.location.href,'_self');
                        }, 1000);
                    }
                    else{
                        component.set('v.toastmsg','An error occured. Please contact System Administrator');
                        component.set('v.toastType','error');
                        component.set("v.toastcss",'slds-notify slds-notify_toast slds-theme_error');
                        component.set("v.checkToast",true);
                    }               
                }
            });
            $A.enqueueAction(action);
            
        }
        
    },
    
    closeIcon : function(component, event, helper) {
        //if(document.getElementById("toastCmp"))
        //document.getElementById("toastCmp").style.display = "none";
        component.set("v.checkToast",false);
    }
})