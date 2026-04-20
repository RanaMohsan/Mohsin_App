codeunit 80147 "WF Deploy Scheduler Mgt"
{
    Access = Public;

    procedure ScheduleDeploy(var Setup: Record "Mohsin Test Workflow Setup"; EarliestStart: DateTime; Timeout: Duration)
    var
        JobQueueEntry: Record "Job Queue Entry";
        ParameterText: Text;
        EffectiveStart: DateTime;
    begin
        ValidateDeployConfiguration(Setup);
        EffectiveStart := EarliestStart;
        if EffectiveStart = 0DT then EffectiveStart := CurrentDateTime();
        JobQueueEntry.Init();
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := Codeunit::"WF Deploy Job Runner";
        JobQueueEntry."Earliest Start Date/Time" := EffectiveStart;
        JobQueueEntry."Maximum No. of Attempts to Run" := 1;
        if Timeout > 0 then JobQueueEntry."Job Timeout" := Timeout;
        JobQueueEntry.Description := CopyStr(StrSubstNo('WF deploy %1', Setup."No."), 1, MaxStrLen(JobQueueEntry.Description));
        ParameterText := BuildParameterText(Setup."No.");
        JobQueueEntry."Parameter String" := CopyStr(ParameterText, 1, MaxStrLen(JobQueueEntry."Parameter String"));
        JobQueueEntry.Insert(true);
        JobQueueEntry.SetStatus(JobQueueEntry.Status::Ready);
        UpdateDeployState(Setup, Setup."Last Deploy Status"::Scheduled, StrSubstNo('Deployment scheduled for %1', Format(EffectiveStart)), BuildWorkflowRunUrl(Setup), true);
    end;

    procedure RunDeployNow(var Setup: Record "Mohsin Test Workflow Setup")
    begin
        ValidateDeployConfiguration(Setup);
        DispatchWorkflow(Setup);
    end;

    procedure ExecuteFromJobQueue(ParameterText: Text)
    var
        Setup: Record "Mohsin Test Workflow Setup";
        SetupNo: Code[20];
    begin
        SetupNo := ParseSetupNo(ParameterText);
        if SetupNo = '' then Error('Missing setup number in job queue parameter string.');
        if not Setup.Get(SetupNo) then Error('Setup %1 not found.', SetupNo);
        ValidateDeployConfiguration(Setup);
        DispatchWorkflow(Setup);
    end;

    local procedure DispatchWorkflow(var Setup: Record "Mohsin Test Workflow Setup")
    var
        Response: HttpResponseMessage;
        Body: Text;
        RequestUrl: Text;
        WorkflowRunUrl: Text;
        ErrorTxt: Text;
        Sent: Boolean;
    begin
        RequestUrl := BuildDispatchApiUrl(Setup);
        WorkflowRunUrl := BuildWorkflowRunUrl(Setup);
        Body := BuildDispatchBody(Setup."Deploy Branch", Setup."No.", Setup."Last Generated File Name", true);
        Sent := SendDispatchRequest(RequestUrl, Setup."Deploy PAT Token", Body, Response);
        if not Sent then begin
            ErrorTxt := 'GitHub workflow dispatch request failed to send.';
            UpdateDeployState(Setup, Setup."Last Deploy Status"::Failed, ErrorTxt, WorkflowRunUrl, false);
            Error(ErrorTxt);
        end;
        if Response.HttpStatusCode() in [200, 201, 202, 204] then begin
            UpdateDeployState(Setup, Setup."Last Deploy Status"::Queued, 'Deployment workflow dispatched successfully.', WorkflowRunUrl, false);
            exit;
        end;

        // Retry once without inputs: many workflow files only accept ref and reject unknown input keys.
        if Response.HttpStatusCode() = 422 then begin
            Body := BuildDispatchBody(Setup."Deploy Branch", Setup."No.", Setup."Last Generated File Name", false);
            Sent := SendDispatchRequest(RequestUrl, Setup."Deploy PAT Token", Body, Response);
            if not Sent then begin
                ErrorTxt := 'GitHub workflow dispatch retry failed to send.';
                UpdateDeployState(Setup, Setup."Last Deploy Status"::Failed, ErrorTxt, WorkflowRunUrl, false);
                Error(ErrorTxt);
            end;
            if Response.HttpStatusCode() in [200, 201, 202, 204] then begin
                UpdateDeployState(Setup, Setup."Last Deploy Status"::Queued, 'Deployment workflow dispatched successfully (without custom inputs).', WorkflowRunUrl, false);
                exit;
            end;
        end;

        // Handle specific HTTP error codes
        if Response.HttpStatusCode() = 403 then
            ErrorTxt := CopyStr(StrSubstNo('Dispatch failed: Authentication error (403). Check that:\n- PAT Token is valid and not expired\n- PAT Token has "workflow" and "repo" scopes\n- Repository "%1/%2" exists and is accessible\n- Workflow file exists at .github/workflows/%3', Setup."Deploy Repo Owner", Setup."Deploy Repo Name", Setup."Deploy Workflow File"), 1, 280)
        else if Response.HttpStatusCode() = 404 then
            ErrorTxt := CopyStr(StrSubstNo('Dispatch failed: Not found (404). Check that:\n- Repository "%1/%2" exists\n- Branch "%3" exists\n- Workflow file ".github/workflows/%4" exists', Setup."Deploy Repo Owner", Setup."Deploy Repo Name", Setup."Deploy Branch", Setup."Deploy Workflow File"), 1, 280)
        else if Response.HttpStatusCode() = 422 then
            ErrorTxt := CopyStr('Dispatch failed (422). Verify that workflow_dispatch exists in the workflow file, the branch ref is valid, and required inputs match the workflow definition.', 1, 280)
        else
            ErrorTxt := CopyStr(StrSubstNo('Dispatch failed (%1).', Format(Response.HttpStatusCode())), 1, 280);

        UpdateDeployState(Setup, Setup."Last Deploy Status"::Failed, ErrorTxt, WorkflowRunUrl, false);
        Error('%1 Open %2 for workflow details.', ErrorTxt, WorkflowRunUrl);
    end;

    local procedure ValidateDeployConfiguration(var Setup: Record "Mohsin Test Workflow Setup")
    var
        ErrorMsg: Text;
    begin
        // Check each required field and build clear error messages
        ErrorMsg := '';

        if Setup."Deploy Repo Owner" = '' then
            ErrorMsg += 'Deploy Repo Owner is required.\n';
        if Setup."Deploy Repo Name" = '' then
            ErrorMsg += 'Deploy Repo Name is required (e.g., workflow-app).\n';
        if Setup."Deploy Branch" = '' then
            ErrorMsg += 'Deploy Branch is required (e.g., main).\n';
        if Setup."Deploy Workflow File" = '' then
            ErrorMsg += 'Deploy Workflow File is required (e.g., PublishToEnvironment.yaml).\n';
        if Setup."Deploy PAT Token" = '' then
            ErrorMsg += 'Deploy PAT Token is required.\n';

        if ErrorMsg <> '' then
            Error('Deployment configuration incomplete:\n%1\nAll fields are required on Custom Approval Workflow setup.', ErrorMsg);

        if (StrPos(Setup."Deploy Repo Owner", '/') > 0) or (StrPos(Setup."Deploy Repo Owner", 'github.com') > 0) then
            Error('Deploy Repo Owner must be the GitHub account or organization name only (for example, mohsanali2720-dot). Do not enter a URL or repository path.');
        if (StrPos(Setup."Deploy Repo Name", '/') > 0) or (StrPos(Setup."Deploy Repo Name", 'github.com') > 0) then
            Error('Deploy Repo Name must be the repository name only (for example, workflow-app). Do not enter a GitHub URL.');
        if (StrPos(Setup."Deploy Workflow File", '/') > 0) then
            Error('Deploy Workflow File must be the workflow file name only, for example PublishToEnvironment.yaml. Do not enter a path.');

        // Validate PAT Token format (GitHub PAT tokens start with ghp_ or github_pat_)
        if (StrPos(Setup."Deploy PAT Token", 'ghp_') <> 1) and (StrPos(Setup."Deploy PAT Token", 'github_pat_') <> 1) then
            Error('Deploy PAT Token appears invalid. GitHub tokens should start with "ghp_" or "github_pat_". Check that you copied the full token correctly.');
    end;

    local procedure BuildDispatchApiUrl(var Setup: Record "Mohsin Test Workflow Setup"): Text
    begin
        exit(StrSubstNo('https://api.github.com/repos/%1/%2/actions/workflows/%3/dispatches', TrimText(Setup."Deploy Repo Owner"), TrimText(Setup."Deploy Repo Name"), TrimText(Setup."Deploy Workflow File")));
    end;

    local procedure BuildWorkflowRunUrl(var Setup: Record "Mohsin Test Workflow Setup"): Text
    begin
        exit(StrSubstNo('https://github.com/%1/%2/actions/workflows/%3', TrimText(Setup."Deploy Repo Owner"), TrimText(Setup."Deploy Repo Name"), TrimText(Setup."Deploy Workflow File")));
    end;

    local procedure BuildDispatchBody(BranchName: Text; SetupNo: Code[20]; GeneratedFileName: Text[280]; IncludeInputs: Boolean): Text
    var
        Inputs: JsonObject;
        Root: JsonObject;
        BodyTxt: Text;
    begin
        Root.Add('ref', BranchName);
        if IncludeInputs then begin
            Inputs.Add('setup_no', SetupNo);
            Inputs.Add('generated_file_name', GeneratedFileName);
            Inputs.Add('publish_to_bc', 'yes');
            Root.Add('inputs', Inputs);
        end;
        Root.WriteTo(BodyTxt);
        exit(BodyTxt);
    end;

    local procedure SendDispatchRequest(RequestUrl: Text; PatToken: Text; Body: Text; var Response: HttpResponseMessage): Boolean
    var
        Client: HttpClient;
        Request: HttpRequestMessage;
        Headers: HttpHeaders;
        Content: HttpContent;
        ContentHeaders: HttpHeaders;
    begin
        Content.WriteFrom(Body);
        Content.GetHeaders(ContentHeaders);
        if ContentHeaders.Contains('Content-Type') then
            ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', 'application/json');

        Request.SetRequestUri(RequestUrl);
        Request.Method := 'POST';
        Request.Content := Content;
        Request.GetHeaders(Headers);
        Headers.Add('Accept', 'application/vnd.github+json');
        Headers.Add('User-Agent', 'BusinessCentral-AutoDeploy');
        Headers.Add('X-GitHub-Api-Version', '2022-11-28');
        Headers.Add('Authorization', StrSubstNo('token %1', TrimText(PatToken)));

        exit(Client.Send(Request, Response));
    end;

    local procedure TrimText(Value: Text): Text
    var
        Len: Integer;
    begin
        Len := StrLen(Value);
        while (Len > 0) and (CopyStr(Value, 1, 1) = ' ') do begin
            if Len > 1 then
                Value := CopyStr(Value, 2, Len - 1)
            else
                Value := '';
            Len := StrLen(Value);
        end;
        Len := StrLen(Value);
        while (Len > 0) and (CopyStr(Value, Len, 1) = ' ') do begin
            if Len > 1 then
                Value := CopyStr(Value, 1, Len - 1)
            else
                Value := '';
            Len := StrLen(Value);
        end;
        exit(Value);
    end;

    local procedure BuildParameterText(SetupNo: Code[20]): Text
    begin
        exit(StrSubstNo('SETUP_NO=%1', SetupNo));
    end;

    local procedure ParseSetupNo(ParameterText: Text): Code[20]
    begin
        if CopyStr(ParameterText, 1, 9) <> 'SETUP_NO=' then exit('');
        exit(CopyStr(ParameterText, 10, 20));
    end;

    local procedure UpdateDeployState(var Setup: Record "Mohsin Test Workflow Setup"; NewStatus: Option None,Scheduled,Queued,Success,Failed; Msg: Text[280]; RunUrl: Text; UpdateScheduledAt: Boolean)
    begin
        if not Setup.Get(Setup."No.") then exit;
        Setup."Last Deploy Status" := NewStatus;
        Setup."Last Deploy Message" := Msg;
        Setup."Last Deploy At" := CurrentDateTime();
        Setup."Last Deploy Run URL" := CopyStr(RunUrl, 1, MaxStrLen(Setup."Last Deploy Run URL"));
        if UpdateScheduledAt then Setup."Last Scheduled At" := CurrentDateTime();
        Setup.Modify(true);
    end;
}
