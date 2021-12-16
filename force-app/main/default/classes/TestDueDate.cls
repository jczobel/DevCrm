@istest
private class TestDueDate {
    @isTest static void TestDueDateIsRecurring(){
    Task tsk = new Task(Subject = 'Test Task', IsRecurrence = false, ActivityDate = null  ); 
    Insert tsk;
        // Perform test
        Test.startTest();
        //Database.DeleteResult result = Database.delete(acct, false);
        Test.stopTest();
        // Verify 
        // In this case the deletion should have been stopped by the trigger,
        // so verify that we got back an error.
       // System.assert(!result.isSuccess());
       // System.assert(result.getErrors().size() > 0);
       // System.assertEquals('Cannot delete account with related opportunities.',
                             //result.getErrors()[0].getMessage());
    
}
}