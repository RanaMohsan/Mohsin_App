codeunit 80120 "Custom Approval Workflow Mgt."
{
    procedure HasOpenApprovalEntriesForCurrentUser(RecId: RecordId): Boolean
    var
        ApprovalEntry: Record "Approval Entry";
    begin
        ApprovalEntry.SetRange("Table ID", RecId.TableNo);
        ApprovalEntry.SetRange("Record ID to Approve", RecId);
        ApprovalEntry.SetRange("Approver ID", UserId);
        ApprovalEntry.SetRange(Status, ApprovalEntry.Status::Open);
        exit(not ApprovalEntry.IsEmpty());
    end;

    procedure SendApprovalRequest(var ApprovalTesting: Record "Approval Testing")
    var
        WorkflowManagement: Codeunit "Workflow Management";
        WfEvents: Codeunit "Appr. Test. WF Events";
        RecRef: RecordRef;
    begin
        if ApprovalTesting.Status <> ApprovalTesting.Status::Open then exit;
        RecRef.GetTable(ApprovalTesting);
        WorkflowManagement.HandleEvent(WfEvents.RunWorkflowOnSendApprovalRequestCode(), RecRef);
        if not ApprovalTesting.Get(ApprovalTesting.PK) then exit;
        ApprovalTesting.Status := ApprovalTesting.Status::Pending;
        ApprovalTesting.Modify(true);
        Message('Approval request has been sent for %1.', ApprovalTesting.PK);
    end;

    procedure CancelApprovalRequest(var ApprovalTesting: Record "Approval Testing")
    var
        WorkflowManagement: Codeunit "Workflow Management";
        WfEvents: Codeunit "Appr. Test. WF Events";
        RecRef: RecordRef;
    begin
        if ApprovalTesting.Status <> ApprovalTesting.Status::Pending then exit;
        RecRef.GetTable(ApprovalTesting);
        WorkflowManagement.HandleEvent(WfEvents.RunWorkflowOnCancelApprovalRequestCode(), RecRef);
        if not ApprovalTesting.Get(ApprovalTesting.PK) then exit;
        ApprovalTesting.Status := ApprovalTesting.Status::Open;
        ApprovalTesting.Modify(true);
        Message('Approval request has been cancelled for %1.', ApprovalTesting.PK);
    end;

    procedure ApproveRecord(var ApprovalTesting: Record "Approval Testing")
    var
        ApprovalEntry: Record "Approval Entry";
    begin
        ApprovalEntry.SetRange("Table ID", Database::"Approval Testing");
        ApprovalEntry.SetRange("Record ID to Approve", ApprovalTesting.RecordId);
        ApprovalEntry.SetRange("Approver ID", UserId);
        ApprovalEntry.SetRange(Status, ApprovalEntry.Status::Open);
        if not ApprovalEntry.FindFirst() then Error('No open approval entry for the current user on this record.');
        ApprovalEntry.Validate(Status, ApprovalEntry.Status::Approved);
        ApprovalEntry.Modify(true);
        if not ApprovalTesting.Get(ApprovalTesting.PK) then exit;
        ApprovalTesting.Status := ApprovalTesting.Status::Released;
        ApprovalTesting.Modify(true);
        Message('Approval Testing: %1 has been approved.', ApprovalTesting.PK);
    end;

    procedure RejectRecord(var ApprovalTesting: Record "Approval Testing")
    var
        ApprovalEntry: Record "Approval Entry";
    begin
        ApprovalEntry.SetRange("Table ID", Database::"Approval Testing");
        ApprovalEntry.SetRange("Record ID to Approve", ApprovalTesting.RecordId);
        ApprovalEntry.SetRange("Approver ID", UserId);
        ApprovalEntry.SetRange(Status, ApprovalEntry.Status::Open);
        if not ApprovalEntry.FindFirst() then Error('No open approval entry for the current user on this record.');
        ApprovalEntry.Validate(Status, ApprovalEntry.Status::Rejected);
        ApprovalEntry.Modify(true);
        if not ApprovalTesting.Get(ApprovalTesting.PK) then exit;
        ApprovalTesting.Status := ApprovalTesting.Status::Rejected;
        ApprovalTesting.Modify(true);
    end;

    procedure SendApprovalRequest(var RecRef: RecordRef)
    var
        Setup: Record "Mohsin Test Workflow Setup";
        WorkflowManagement: Codeunit "Workflow Management";
        StatusFieldRef: FieldRef;
        CurrentStatus: Enum "WFDemo Status";
        TableName: Text;
    begin
        if RecRef.IsEmpty() then
            Error('Cannot send approval request because the record is not initialized.');

        // Find setup for this table
        Setup.SetRange("Table No.", RecRef.Number);
        Setup.SetRange(Enabled, true);
        if not Setup.FindFirst() then begin
            TableName := GetTableName(RecRef.Number);
            Message('No workflow setup found for table %1 (%2). Approval request sent (scaffolding mode).', RecRef.Number, TableName);
            exit;
        end;

        // Validate current status allows sending
        if Setup."Status Field No." <> 0 then begin
            StatusFieldRef := RecRef.Field(Setup."Status Field No.");
            CurrentStatus := StatusFieldRef.Value;
            if CurrentStatus <> Setup."Send Approval When" then begin
                Error('Cannot send approval request. Current status (%1) does not match required status (%2).',
                      CurrentStatus, Setup."Send Approval When");
            end;
        end;

        // Update status to pending if configured
        if Setup."Status Field No." <> 0 then begin
            StatusFieldRef := RecRef.Field(Setup."Status Field No.");
            StatusFieldRef.Value := Setup."On Pending Document";
            RecRef.Modify(true);
        end;

        // Handle workflow event (generic - assumes workflow is configured)
        HandleWorkflowEvent('APPROVAL_REQUEST_SENT', RecRef);

        TableName := GetTableName(RecRef.Number);
        Message('Approval request sent for record in table %1 (%2).', RecRef.Number, TableName);
    end;

    procedure CancelApprovalRequest(var RecRef: RecordRef)
    var
        Setup: Record "Mohsin Test Workflow Setup";
        WorkflowManagement: Codeunit "Workflow Management";
        StatusFieldRef: FieldRef;
        CurrentStatus: Enum "WFDemo Status";
    begin
        if RecRef.IsEmpty() then
            Error('Cannot cancel approval request because the record is not initialized.');

        // Find setup for this table
        Setup.SetRange("Table No.", RecRef.Number);
        Setup.SetRange(Enabled, true);
        if not Setup.FindFirst() then begin
            Message('No workflow setup found for table %1. Approval request cancelled (scaffolding mode).', RecRef.Number);
            exit;
        end;

        // Update status back to open if configured
        if Setup."Status Field No." <> 0 then begin
            StatusFieldRef := RecRef.Field(Setup."Status Field No.");
            CurrentStatus := StatusFieldRef.Value;
            if CurrentStatus = Setup."Cancel Approval When" then begin
                StatusFieldRef.Value := Setup."On Open Document";
                RecRef.Modify(true);
            end;
        end;

        // Handle workflow event
        WorkflowManagement.HandleEvent('APPROVAL_REQUEST_CANCELLED', RecRef);

        Message('Approval request cancelled for record in table %1.', RecRef.Number);
    end;

    procedure ApproveRecord(var RecRef: RecordRef)
    var
        Setup: Record "Mohsin Test Workflow Setup";
        ApprovalEntry: Record "Approval Entry";
        StatusFieldRef: FieldRef;
    begin
        if RecRef.IsEmpty() then
            Error('Cannot approve record because the record is not initialized.');

        // Find setup for this table
        Setup.SetRange("Table No.", RecRef.Number);
        Setup.SetRange(Enabled, true);
        if not Setup.FindFirst() then begin
            Message('No workflow setup found for table %1. Record approved (scaffolding mode).', RecRef.Number);
            exit;
        end;

        // Update approval entry
        ApprovalEntry.SetRange("Table ID", RecRef.Number);
        ApprovalEntry.SetRange("Record ID to Approve", RecRef.RecordId);
        ApprovalEntry.SetRange("Approver ID", UserId);
        ApprovalEntry.SetRange(Status, ApprovalEntry.Status::Open);
        if ApprovalEntry.FindFirst() then begin
            ApprovalEntry.Validate(Status, ApprovalEntry.Status::Approved);
            ApprovalEntry.Modify(true);
        end;

        // Update status to approved/released if configured
        if Setup."Status Field No." <> 0 then begin
            StatusFieldRef := RecRef.Field(Setup."Status Field No.");
            StatusFieldRef.Value := Setup."On Approve Document";
            RecRef.Modify(true);
        end;

        Message('Record approved in table %1.', RecRef.Number);
    end;

    procedure RejectRecord(var RecRef: RecordRef)
    var
        Setup: Record "Mohsin Test Workflow Setup";
        ApprovalEntry: Record "Approval Entry";
        StatusFieldRef: FieldRef;
    begin
        if RecRef.IsEmpty() then
            Error('Cannot reject record because the record is not initialized.');

        // Find setup for this table
        Setup.SetRange("Table No.", RecRef.Number);
        Setup.SetRange(Enabled, true);
        if not Setup.FindFirst() then begin
            Message('No workflow setup found for table %1. Record rejected (scaffolding mode).', RecRef.Number);
            exit;
        end;

        // Update approval entry
        ApprovalEntry.SetRange("Table ID", RecRef.Number);
        ApprovalEntry.SetRange("Record ID to Approve", RecRef.RecordId);
        ApprovalEntry.SetRange("Approver ID", UserId);
        ApprovalEntry.SetRange(Status, ApprovalEntry.Status::Open);
        if ApprovalEntry.FindFirst() then begin
            ApprovalEntry.Validate(Status, ApprovalEntry.Status::Rejected);
            ApprovalEntry.Modify(true);
        end;

        // Update status to rejected if configured
        if Setup."Status Field No." <> 0 then begin
            StatusFieldRef := RecRef.Field(Setup."Status Field No.");
            StatusFieldRef.Value := Setup."On Reject Document";
            RecRef.Modify(true);
        end;

        Message('Record rejected in table %1.', RecRef.Number);
    end;

    procedure OpenCodeEditor(var Setup: Record "Mohsin Test Workflow Setup")
    var
        CodeEditor: Page "Code Editor Workflow AL";
    begin
        Commit();
        CodeEditor.SetSetup(Setup);
        CodeEditor.RunModal();
    end;

    procedure OpenAutoDeploy(var Setup: Record "Mohsin Test Workflow Setup")
    var
        Deploy: Page "Auto Deploy Scheduler";
    begin
        Commit();
        Deploy.SetSetup(Setup);
        Deploy.RunModal();
    end;

    local procedure HandleWorkflowEvent(EventCode: Text; var RecRef: RecordRef)
    var
        WorkflowManagement: Codeunit "Workflow Management";
    begin
        // Attempt to handle the workflow event
        // This is a generic implementation - specific workflows should be configured
        WorkflowManagement.HandleEvent(EventCode, RecRef);

        // Log that the event was handled
        // In a production system, this might be logged to a custom log table
    end;

    local procedure GetTableName(TableId: Integer): Text
    var
        TableMetadata: Record "Table Metadata";
    begin
        if TableMetadata.Get(TableId) then
            exit(TableMetadata.Caption);
        exit(Format(TableId));
    end;
}
