codeunit 80146 "WF Nav Auto Deploy"
{
    Access = Public;

    trigger OnRun()
    var
        Setup: Record "Custom Approval Workflow Setup";
        Deploy: Page "Auto Deploy Scheduler";
    begin
        if not Setup.FindFirst() then begin
            Message('Create at least one record on Custom Approval Workflow first.');
            exit;
        end;
        Commit();
        Deploy.SetSetup(Setup);
        Deploy.RunModal();
    end;
}
