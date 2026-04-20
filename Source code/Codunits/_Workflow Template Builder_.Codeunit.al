codeunit 80122 "Workflow Template Builder"
{
    procedure CreateOrUpdateFromSetup(var Setup: Record "Mohsin Test Workflow Setup")
    var
        WorkflowCategory: Record "Workflow Category";
        Workflow: Record Workflow;
    begin
        Setup.TestField("Workflow Category Code");
        Setup.TestField("Workflow Code");
        Setup.TestField("Workflow Description");
        if StrLen(Setup."Workflow Code") > MaxStrLen(Workflow.Code) then Error('Workflow Code cannot be longer than %1 characters.', MaxStrLen(Workflow.Code));
        if not WorkflowCategory.Get(Setup."Workflow Category Code") then begin
            WorkflowCategory.Code := Setup."Workflow Category Code";
            WorkflowCategory.Description := Setup."Workflow Category Description";
            WorkflowCategory.Insert(true);
        end
        else begin
            if Setup."Workflow Category Description" <> '' then WorkflowCategory.Description := Setup."Workflow Category Description";
            WorkflowCategory.Modify(true);
        end;
        if Workflow.Get(CopyStr(Setup."Workflow Code", 1, MaxStrLen(Workflow.Code))) then begin
            Workflow.Description := Setup."Workflow Description";
            Workflow.Category := Setup."Workflow Category Code";
            Workflow.Enabled := false;
            if Workflow.Template then Workflow.Template := false;
            Workflow.Modify(true);
        end
        else begin
            Workflow.Code := CopyStr(Setup."Workflow Code", 1, MaxStrLen(Workflow.Code));
            Workflow.Description := Setup."Workflow Description";
            Workflow.Category := Setup."Workflow Category Code";
            Workflow.Enabled := false;
            Workflow.Template := false;
            Workflow.Insert(true);
        end;
        Workflow.Get(CopyStr(Setup."Workflow Code", 1, MaxStrLen(Workflow.Code)));
        if Setup."Table No." = Database::"Approval Testing" then EnsureApprovalTestingRecWorkflowSteps(Workflow);
        Workflow.Template := true;
        Workflow.Modify(true);
        Message('Workflow template %1 saved.', Setup."Workflow Code");
    end;

    local procedure EnsureApprovalTestingRecWorkflowSteps(var Workflow: Record Workflow)
    var
        WorkflowStep: Record "Workflow Step";
        WorkflowSetup: Codeunit "Workflow Setup";
        WfResp: Codeunit "Workflow Response Handling";
        WfEvents: Codeunit "Appr. Test. WF Events";
        WorkflowStepArgument: Record "Workflow Step Argument";
    begin
        WorkflowStep.SetRange("Workflow Code", Workflow.Code);
        if not WorkflowStep.IsEmpty() then exit;
        WfEvents.EnsureApprTestWorkflowTableRelation();
        WorkflowStepArgument.Init();
        WorkflowSetup.InsertRecApprovalWorkflowSteps(Workflow,
        WorkflowSetup.BuildNoPendingApprovalsConditions(),
         WfEvents.RunWorkflowOnSendApprovalRequestCode(),
          WfResp.CreateApprovalRequestsCode(),
          WfResp.SendApprovalRequestForApprovalCode(),
           WfEvents.RunWorkflowOnCancelApprovalRequestCode(),
            WorkflowStepArgument, false, false);
    end;
}
