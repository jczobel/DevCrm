/************************************* MODIFICATION LOG ********************************************************************************************
* DATLoggingUtil
*
* DESCRIPTION : Utility class to event and error logging specific to DAT custom code
*
*---------------------------------------------------------------------------------------------------------------------------------------------------
* DEVELOPER                                 DATE        JIRA#            REASON
*---------------------------------------------------------------------------------------------------------------------------------------------------
* Acumen Solutions                          5/7/2019                     - Original Version 
*/
public class DATLoggingUtil {
    public static List<DAT_Log__c> logList;
    public static boolean success = true;
    
    public static void initialize() {
        logList = new List<DAT_Log__c>();
    }
    public static void notify() {
        
    }
        public static void addEventLogListItem(string eventContent, string eventSource, string accountID) {
            DAT_Log__c dl = new DAT_Log__c(type__c = 'Event', content__c = eventContent, Source__c = eventSource);
                
                logList.add(dl);            
        }

        public static void addErrorLogListItem(string eventContent, string eventSource) {
            DAT_Log__c dl = new DAT_Log__c(type__c = 'Error', content__c = eventContent, Source__c = eventSource);
                logList.add(dl);            
        }

    public static boolean logError(string eventContent, string eventSource, string accountID) {
            boolean isSuccess = false;
            DAT_Log__c dl = new DAT_Log__c(type__c = 'Error', content__c = eventContent, Source__c = eventSource);
        try {
            insert dl;
            isSuccess = true;
        }
        catch(system.Exception ex) {
            system.debug('Error DAT Logging Error: ' + ex.getStackTraceString());
        }
            return isSuccess;            
    }

    public static boolean logEvent(string logContent, string logSource, string accountID) {
            boolean isSuccess = false;
            DAT_Log__c dl = new DAT_Log__c(type__c = 'Event', content__c = logContent, Source__c = logSource);
        try {
            insert dl;
            isSuccess = true;
        }
        catch(system.Exception ex) {
            system.debug('Event DAT Logging Error: ' + ex.getStackTraceString());
        }
            return isSuccess;            
    }
        public static boolean logList() {
            boolean isSuccess = false;
            try {
                insert LogList;
                isSuccess = true;
                logList.clear();
            }
        
            catch(system.Exception ex) {
            system.debug('DAT Logging List Error: ' + ex.getStackTraceString());
        }
            return isSuccess;
    }

}