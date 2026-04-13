page 80115 "Auto Deploy Scheduler"
{
    ApplicationArea = All;
    Caption = 'AutoDeploy Scheduler';
    PageType = StandardDialog;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = true;
    LinksAllowed = false;

    layout
    {
        area(Content)
        {
            group(DeployExt)
            {
                Caption = 'Deploy Extension';

                field(ExtensionFileName; ExtensionFileName)
                {
                    ApplicationArea = All;
                    Caption = 'Extension FileName';
                    Editable = false;
                    ToolTip = 'Suggested AL file name for the generated page extension.';
                }
                field(InstantDeploy; InstantDeploy)
                {
                    ApplicationArea = All;
                    Caption = 'Instant Deploy';
                    ToolTip = 'Turn on to enable Deploy. Turn off to use Schedule and the date/time fields.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update(false);
                    end;
                }
            }
            group(Schedule)
            {
                Caption = 'Schedule Deployment';
                Visible = not InstantDeploy;

                field(EarliestStart; EarliestStart)
                {
                    ApplicationArea = All;
                    Caption = 'Earliest Start Date/Time';
                    ToolTip = 'Planned deployment time.';
                    Editable = not InstantDeploy;
                }
                field(JobTimeout; JobTimeout)
                {
                    ApplicationArea = All;
                    Caption = 'Job Timeout';
                    ToolTip = 'Timeout for the deployment job.';
                    Editable = not InstantDeploy;
                }
            }
            group(Note)
            {
                ShowCaption = false;
                InstructionalText = 'Deployment triggers a GitHub Actions workflow dispatch. For instant deploy use OK; for deferred execution use Schedule with Earliest Start Date/Time.';
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ScheduleAction)
            {
                ApplicationArea = All;
                Caption = 'Schedule';
                Image = DateRange;
                Enabled = not InstantDeploy;
                InFooterBar = true;
                ToolTip = 'Schedule a later deployment. Disabled while Instant Deploy is on.';

                trigger OnAction()
                begin
                    ValidateDeployPrerequisites();
                    RunScheduleDeployInfo();
                end;
            }
            action(DeployAction)
            {
                ApplicationArea = All;
                Caption = 'Deploy';
                Image = SendTo;
                Enabled = InstantDeploy;
                InFooterBar = true;
                ToolTip = 'Dispatch deployment workflow immediately. Enabled only when Instant Deploy is on.';

                trigger OnAction()
                begin
                    ValidateDeployPrerequisites();
                    RunInstantDeployFlow();
                end;
            }
            action(CancelAction)
            {
                ApplicationArea = All;
                Caption = 'Cancel';
                Image = Cancel;
                InFooterBar = true;
                ToolTip = 'Close this page.';

                trigger OnAction()
                begin
                    CurrPage.Close();
                end;
            }
        }
    }

    var
        SetupGlobal: Record "Custom Approval Workflow Setup";
        SchedulerMgt: Codeunit "WF Deploy Scheduler Mgt";
        ExtensionFileName: Text[280];
        InstantDeploy: Boolean;
        EarliestStart: DateTime;
        JobTimeout: Duration;

    procedure SetSetup(var SetupIn: Record "Custom Approval Workflow Setup")
    var
        ConfigCheck: Text;
    begin
        SetupGlobal := SetupIn;
        InstantDeploy := true;
        if SetupIn.Get(SetupIn."No.") then
            ExtensionFileName := CopyStr(SetupIn."Last Generated File Name", 1, MaxStrLen(ExtensionFileName));
        if ExtensionFileName = '' then
            ExtensionFileName := 'PageExtension.al';
        EarliestStart := CurrentDateTime();
        JobTimeout := 30 * 60 * 1000;

        // Check for missing configuration upfront
        ConfigCheck := '';
        if SetupIn."Deploy Repo Owner" = '' then ConfigCheck := ConfigCheck + '\- Deploy Repo Owner\n';
        if SetupIn."Deploy Repo Name" = '' then ConfigCheck := ConfigCheck + '\- Deploy Repo Name\n';
        if SetupIn."Deploy Branch" = '' then ConfigCheck := ConfigCheck + '\- Deploy Branch\n';
        if SetupIn."Deploy Workflow File" = '' then ConfigCheck := ConfigCheck + '\- Deploy Workflow File\n';
        if SetupIn."Deploy PAT Token" = '' then ConfigCheck := ConfigCheck + '\- Deploy PAT Token\n';
        if SetupIn."Last Generated File Name" = '' then ConfigCheck := ConfigCheck + '\- Generated AL File (run Generate Code first)\n';

        if ConfigCheck <> '' then
            Message('Missing deployment configuration:\n%1\nPlease configure these fields on the Custom Approval Workflow setup before deploying.', ConfigCheck);
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction = Action::OK then begin
            ValidateDeployPrerequisites();
            if InstantDeploy then
                RunInstantDeployFlow()
            else
                RunScheduleDeployInfo();
        end;
        exit(true); // Allow page to close
    end;

    local procedure ValidateDeployPrerequisites()
    var
        FreshSetup: Record "Custom Approval Workflow Setup";
    begin
        // Refresh setup from database
        if not FreshSetup.Get(SetupGlobal."No.") then
            Error('Setup record not found. Please reopen deployment from the Custom Approval Workflow setup.');

        // Validate all required deployment fields
        FreshSetup.TestField("Deploy Repo Owner");
        if (StrPos(FreshSetup."Deploy Repo Owner", '/') > 0) or (StrPos(FreshSetup."Deploy Repo Owner", 'github.com') > 0) then
            Error('Deploy Repo Owner must be the GitHub account or organization name only (for example, mohsanali2720-dot). Do not enter a URL or repository path.');
        FreshSetup.TestField("Deploy Repo Name");
        if (StrPos(FreshSetup."Deploy Repo Name", '/') > 0) or (StrPos(FreshSetup."Deploy Repo Name", 'github.com') > 0) then
            Error('Deploy Repo Name must be the repository name only (for example, workflow-app). Do not enter a GitHub URL.');
        FreshSetup.TestField("Deploy Branch");
        FreshSetup.TestField("Deploy Workflow File");
        if (StrPos(FreshSetup."Deploy Workflow File", '/') > 0) then
            Error('Deploy Workflow File must be the workflow file name only, for example PublishToEnvironment.yaml. Do not enter a path.');
        FreshSetup.TestField("Deploy PAT Token");
        if FreshSetup."Last Generated File Name" = '' then
            Error('No generated AL file found. Run Generate Code on the Custom Approval Workflow setup first.');

        // Validate scheduling fields if not instant deploy
        if not InstantDeploy then begin
            if EarliestStart = 0DT then
                Error('Earliest Start Date/Time is required for scheduling.');
            if JobTimeout <= 0 then
                Error('Job Timeout must be greater than 0 for scheduling.');
        end;
    end;

    local procedure RunInstantDeployFlow()
    var
        FreshSetup: Record "Custom Approval Workflow Setup";
    begin
        // Refresh setup from database to ensure latest data
        if not FreshSetup.Get(SetupGlobal."No.") then
            Error('Setup record not found. Please reopen deployment from the Custom Approval Workflow setup.');

        // Attempt deployment
        SchedulerMgt.RunDeployNow(FreshSetup);
        Message('Deployment workflow queued successfully. Open the run page from Custom Approval Workflow to monitor progress.');
    end;

    local procedure RunScheduleDeployInfo()
    var
        FreshSetup: Record "Custom Approval Workflow Setup";
    begin
        // Refresh setup from database to ensure latest data
        if not FreshSetup.Get(SetupGlobal."No.") then
            Error('Setup record not found. Please reopen deployment from the Custom Approval Workflow setup.');

        // Schedule deployment
        SchedulerMgt.ScheduleDeploy(FreshSetup, EarliestStart, JobTimeout);
        Message('Deployment scheduled successfully.');
    end;
}
