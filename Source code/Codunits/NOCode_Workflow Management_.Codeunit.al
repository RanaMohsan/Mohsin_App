codeunit 80236 "NoCod Workflow Man"
{
    procedure SendApprovalRequest(var TestDoc: Record "NoCode Test Document")
    var
        WorkflowHeader: Record "NoCode Workflow Header";
        WorkflowStep: Record "NoCode Workflow Step";
        ApprovalEntry: Record "NoCode Approval Entry";
        RecRef: RecordRef;
        NextSeq: Integer;
    begin
        if TestDoc.Status <> 'Open' then
            Error('Document must be Open to send approval request.');

        WorkflowHeader.Get(TestDoc."Workflow Code");
        if not WorkflowHeader.Enabled then
            Error('Workflow is not enabled.');

        // Create approval entries for each step
        WorkflowStep.SetRange("Workflow Code", TestDoc."Workflow Code");
        WorkflowStep.SetRange("Event Type", WorkflowStep."Event Type"::Send);
        if WorkflowStep.FindSet() then
            repeat
                if EvaluateCondition(WorkflowStep, TestDoc) then begin
                    ApprovalEntry.Init();
                    ApprovalEntry."Document No." := TestDoc."No.";
                    ApprovalEntry."Workflow Code" := TestDoc."Workflow Code";
                    ApprovalEntry."Approver User ID" := WorkflowStep."Approver User ID";
                    ApprovalEntry.Status := ApprovalEntry.Status::Open;
                    ApprovalEntry."Date-Time" := CurrentDateTime;
                    ApprovalEntry."Record ID" := TestDoc.RecordId;
                    ApprovalEntry."Sequence No." := WorkflowStep."Sequence No.";
                    ApprovalEntry.Insert();

                    ExecuteResponse(WorkflowStep, TestDoc);
                end;
            until WorkflowStep.Next() = 0;

        TestDoc.Status := WorkflowHeader."On Pending Status";
        TestDoc.Modify();

        // Apply restriction
        RecRef.GetTable(TestDoc);
        ApplyRestriction(RecRef, UserId);
    end;

    procedure Approve(var TestDoc: Record "NoCode Test Document")
    var
        WorkflowHeader: Record "NoCode Workflow Header";
        ApprovalEntry: Record "NoCode Approval Entry";
        WorkflowStep: Record "NoCode Workflow Step";
        RecRef: RecordRef;
        CurrentSeq: Integer;
    begin
        WorkflowHeader.Get(TestDoc."Workflow Code");

        // Find current user's approval entry
        ApprovalEntry.SetRange("Record ID", TestDoc.RecordId);
        ApprovalEntry.SetRange("Approver User ID", UserId);
        ApprovalEntry.SetRange(Status, ApprovalEntry.Status::Open);
        if not ApprovalEntry.FindFirst() then
            Error('No open approval entry for current user.');

        CurrentSeq := ApprovalEntry."Sequence No.";
        ApprovalEntry.Status := ApprovalEntry.Status::Approved;
        ApprovalEntry."Date-Time" := CurrentDateTime;
        ApprovalEntry.Modify();

        // Check if all approvals in this sequence are done
        ApprovalEntry.SetRange("Record ID", TestDoc.RecordId);
        ApprovalEntry.SetRange("Sequence No.", CurrentSeq);
        ApprovalEntry.SetFilter(Status, '<>%1', ApprovalEntry.Status::Approved);
        if ApprovalEntry.IsEmpty() then begin
            // Check if there are more sequences
            WorkflowStep.SetRange("Workflow Code", TestDoc."Workflow Code");
            WorkflowStep.SetRange("Event Type", WorkflowStep."Event Type"::Approve);
            WorkflowStep.SetFilter("Sequence No.", '>%1', CurrentSeq);
            if WorkflowStep.FindFirst() then begin
                // Create next level approvals
                WorkflowStep.SetRange("Sequence No.", WorkflowStep."Sequence No.");
                if WorkflowStep.FindSet() then
                    repeat
                        if EvaluateCondition(WorkflowStep, TestDoc) then begin
                            ApprovalEntry.Init();
                            ApprovalEntry."Document No." := TestDoc."No.";
                            ApprovalEntry."Workflow Code" := TestDoc."Workflow Code";
                            ApprovalEntry."Approver User ID" := WorkflowStep."Approver User ID";
                            ApprovalEntry.Status := ApprovalEntry.Status::Open;
                            ApprovalEntry."Date-Time" := CurrentDateTime;
                            ApprovalEntry."Record ID" := TestDoc.RecordId;
                            ApprovalEntry."Sequence No." := WorkflowStep."Sequence No.";
                            ApprovalEntry.Insert();
                        end;
                    until WorkflowStep.Next() = 0;
            end else begin
                // No more approvals, approve document
                TestDoc.Status := WorkflowHeader."On Approved Status";
                TestDoc.Modify();

                // Remove restriction
                RecRef.GetTable(TestDoc);
                RemoveRestriction(RecRef);
            end;
        end;
    end;

    procedure Reject(var TestDoc: Record "NoCode Test Document")
    var
        WorkflowHeader: Record "NoCode Workflow Header";
        ApprovalEntry: Record "NoCode Approval Entry";
        RecRef: RecordRef;
    begin
        WorkflowHeader.Get(TestDoc."Workflow Code");

        // Find current user's approval entry
        ApprovalEntry.SetRange("Record ID", TestDoc.RecordId);
        ApprovalEntry.SetRange("Approver User ID", UserId);
        ApprovalEntry.SetRange(Status, ApprovalEntry.Status::Open);
        if ApprovalEntry.FindFirst() then begin
            ApprovalEntry.Status := ApprovalEntry.Status::Rejected;
            ApprovalEntry."Date-Time" := CurrentDateTime;
            ApprovalEntry.Modify();
        end;

        TestDoc.Status := WorkflowHeader."On Rejected Status";
        TestDoc.Modify();

        // Remove restriction
        RecRef.GetTable(TestDoc);
        RemoveRestriction(RecRef);
    end;

    procedure Cancel(var TestDoc: Record "NoCode Test Document")
    var
        WorkflowHeader: Record "NoCode Workflow Header";
        ApprovalEntry: Record "NoCode Approval Entry";
        RecRef: RecordRef;
    begin
        if TestDoc.Status <> 'Open' then
            Error('Document must be Open to cancel.');

        WorkflowHeader.Get(TestDoc."Workflow Code");

        // Cancel all approval entries
        ApprovalEntry.SetRange("Record ID", TestDoc.RecordId);
        ApprovalEntry.SetRange(Status, ApprovalEntry.Status::Open);
        ApprovalEntry.ModifyAll(Status, ApprovalEntry.Status::Created);

        TestDoc.Status := WorkflowHeader."On Open Status";
        TestDoc.Modify();

        // Remove restriction
        RecRef.GetTable(TestDoc);
        RemoveRestriction(RecRef);
    end;

    procedure IsCurrentUserApprover(TestDoc: Record "NoCode Test Document"): Boolean
    var
        ApprovalEntry: Record "NoCode Approval Entry";
    begin
        ApprovalEntry.SetRange("Record ID", TestDoc.RecordId);
        ApprovalEntry.SetRange("Approver User ID", UserId);
        ApprovalEntry.SetRange(Status, ApprovalEntry.Status::Open);
        exit(not ApprovalEntry.IsEmpty());
    end;

    local procedure EvaluateCondition(WorkflowStep: Record "NoCode Workflow Step"; TestDoc: Record "NoCode Test Document"): Boolean
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
        FieldValue: Variant;
        ConditionValue: Variant;
    begin
        if WorkflowStep."Condition Field No." = 0 then
            exit(true);

        RecRef.GetTable(TestDoc);
        FieldRef := RecRef.Field(WorkflowStep."Condition Field No.");
        FieldValue := FieldRef.Value;

        // Simple type conversion for comparison
        case WorkflowStep."Condition Operator" of
            WorkflowStep."Condition Operator"::"=":
                exit(Format(FieldValue) = WorkflowStep."Condition Value");
            WorkflowStep."Condition Operator"::">":
                exit(Format(FieldValue) > WorkflowStep."Condition Value");
            WorkflowStep."Condition Operator"::"<":
                exit(Format(FieldValue) < WorkflowStep."Condition Value");
            WorkflowStep."Condition Operator"::">=":
                exit(Format(FieldValue) >= WorkflowStep."Condition Value");
            WorkflowStep."Condition Operator"::"<=":
                exit(Format(FieldValue) <= WorkflowStep."Condition Value");
            WorkflowStep."Condition Operator"::"<>":
                exit(Format(FieldValue) <> WorkflowStep."Condition Value");
        end;
    end;

    local procedure ExecuteResponse(WorkflowStep: Record "NoCode Workflow Step"; TestDoc: Record "NoCode Test Document")
    begin
        case WorkflowStep."Response Type" of
            WorkflowStep."Response Type"::"Send Approval":
                // Already handled
                ;
            WorkflowStep."Response Type"::Reject:
                // Handled in Reject procedure
                ;
            WorkflowStep."Response Type"::"Add Restriction":
                // Handled in SendApprovalRequest
                ;
            WorkflowStep."Response Type"::"Remove Restriction":
                // Handled in Approve/Reject
                ;
            WorkflowStep."Response Type"::Notify:
                SendNotification(WorkflowStep."Notification Message", TestDoc);
        end;
    end;

    local procedure ApplyRestriction(var RecRef: RecordRef; RestrictedUser: Code[50])
    var
        RecordRestrictionMgt: Codeunit "Record Restriction Mgt.";
    begin
        RecordRestrictionMgt.RestrictRecordUsage(RecRef, RestrictedUser);
    end;

    local procedure RemoveRestriction(var RecRef: RecordRef)
    var
        RecordRestrictionMgt: Codeunit "Record Restriction Mgt.";
    begin
        RecordRestrictionMgt.AllowRecordUsage(RecRef);
    end;

    local procedure SendNotification(Message: Text; TestDoc: Record "NoCode Test Document")
    begin
        // Stub for notification
        Message('Notification: %1 for document %2', Message, TestDoc."No.");
    end;
}