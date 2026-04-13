codeunit 80148 "WF Deploy Job Runner"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        SchedulerMgt: Codeunit "WF Deploy Scheduler Mgt";
    begin
        SchedulerMgt.ExecuteFromJobQueue(Rec."Parameter String");
    end;
}
