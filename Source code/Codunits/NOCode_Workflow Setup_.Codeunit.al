codeunit 80243 "NoCode Workflow Mohsin"
{
    procedure CreateSampleWorkflow()
    var
        WorkflowHeader: Record "NoCode Workflow Header";
        WorkflowStep: Record "NoCode Workflow Step";
        TestDoc: Record "NoCode Test Document";
    begin
        // Create Workflow Header
        if not WorkflowHeader.Get('SAMPLE') then begin
            WorkflowHeader.Code := 'SAMPLE';
            WorkflowHeader.Description := 'Sample Approval Workflow';
            WorkflowHeader."Category Code" := 'APPROVAL';
            WorkflowHeader.Enabled := true;
            WorkflowHeader."Document Table ID" := Database::"NoCode Test Document";
            WorkflowHeader."Card Page ID" := Page::"Mohsin NoCode Test Doc Card";
            WorkflowHeader."Status Field Name" := 'Status';
            WorkflowHeader."On Open Status" := 'Open';
            WorkflowHeader."On Pending Status" := 'Pending';
            WorkflowHeader."On Approved Status" := 'Approved';
            WorkflowHeader."On Rejected Status" := 'Rejected';
            WorkflowHeader.Insert();
        end;

        // Create Workflow Steps
        WorkflowStep.SetRange("Workflow Code", 'SAMPLE');
        WorkflowStep.DeleteAll();

        // Step 1: Send to Approver 1
        WorkflowStep."Workflow Code" := 'SAMPLE';
        WorkflowStep."Event Type" := WorkflowStep."Event Type"::Send;
        WorkflowStep."Condition Field No." := 0; // No condition
        WorkflowStep."Response Type" := WorkflowStep."Response Type"::"Send Approval";
        WorkflowStep."Sequence No." := 1;
        WorkflowStep."Approver User ID" := UserId; // Current user for demo
        WorkflowStep."Notification Message" := 'Approval request sent';
        WorkflowStep.Insert();

        // Step 2: Approve by Approver 1
        WorkflowStep."Workflow Code" := 'SAMPLE';
        WorkflowStep."Event Type" := WorkflowStep."Event Type"::Approve;
        WorkflowStep."Condition Field No." := 0;
        WorkflowStep."Response Type" := WorkflowStep."Response Type"::"Remove Restriction";
        WorkflowStep."Sequence No." := 1;
        WorkflowStep."Approver User ID" := UserId;
        WorkflowStep.Insert();

        // Create Sample Document
        if not TestDoc.Get('DOC001') then begin
            TestDoc."No." := 'DOC001';
            TestDoc.Description := 'Sample Document for Approval';
            TestDoc.Status := 'Open';
            TestDoc."Workflow Code" := 'SAMPLE';
            TestDoc.Insert();
        end;

        Message('Sample workflow and document created.');
    end;
}