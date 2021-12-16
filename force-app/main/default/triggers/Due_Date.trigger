trigger Due_Date on Task (before insert, before update) {
    for(Task t : Trigger.new)
        if(t.IsRecurrence== false && t.ActivityDate==null )
            t.addError('A Due Date is Required for non recurring Task');

}