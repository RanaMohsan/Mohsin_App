codeunit 80123 "Appr. Test. WF Events"
{
    // Microsoft workflow walkthrough pattern: table field 1 -> Approval Entry field 2. Idempotent.
    procedure EnsureApprTestWorkflowTableRelation()
    var
        WorkflowTableRelation: Record "Workflow - Table Relation";
        WorkflowSetup: Codeunit "Workflow Setup";
        ApprovalTesting: Record "Approval Testing";
        RelFieldId: Integer;
    begin
        RelFieldId := 2;
        WorkflowTableRelation.Reset();
        WorkflowTableRelation.SetRange("Table ID", Database::"Approval Testing");
        WorkflowTableRelation.SetRange("Field ID", ApprovalTesting.FieldNo(PK));
        WorkflowTableRelation.SetRange("Related Table ID", Database::"Approval Entry");
        WorkflowTableRelation.SetRange("Related Field ID", RelFieldId);
        if not WorkflowTableRelation.IsEmpty() then exit;
        WorkflowSetup.InsertTableRelation(Database::"Approval Testing", ApprovalTesting.FieldNo(PK), Database::"Approval Entry", RelFieldId);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", OnAddWorkflowTableRelationsToLibrary, '', false, false)]
    local procedure OnAddWorkflowTableRelationsToLibrary()
    begin
        EnsureApprTestWorkflowTableRelation();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", OnAddWorkflowEventsToLibrary, '', false, false)]
    local procedure OnAddWorkflowEventsToLibrary()
    var
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
    begin
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendApprovalRequestCode(), Database::"Approval Testing", CopyStr('Approval Testing Approval Sent', 1, 280), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelApprovalRequestCode(), Database::"Approval Testing", CopyStr('Approval Testing Approval Cancelled', 1, 280), 0, false);
    end;

    procedure RunWorkflowOnSendApprovalRequestCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnSendApprovalRequest'));
    end;

    procedure RunWorkflowOnCancelApprovalRequestCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelApprovalRequest'));
    end;
}
