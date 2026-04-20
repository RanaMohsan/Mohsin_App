page 80146 "Deploy Status Detail"
{
    ApplicationArea = All;
    Caption = 'Extension Deployment Status Detail';
    PageType = Card;
    SourceTable = "Mohsin Test Workflow Setup";
    UsageCategory = Administration;
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Workflow setup number.';
                }
                field(WorkflowCode; Rec."Workflow Code")
                {
                    ApplicationArea = All;
                    Caption = 'Workflow Code';
                    ToolTip = 'Workflow code linked to this deployment.';
                }
                field(GeneratedFile; Rec."Last Generated File Name")
                {
                    ApplicationArea = All;
                    Caption = 'Generated File';
                    ToolTip = 'Generated AL file name used for this deployment.';
                }
                field(ScheduleTypeTxt; ScheduleTypeTxt)
                {
                    ApplicationArea = All;
                    Caption = 'Schedule';
                    ToolTip = 'Immediate for direct dispatch, Scheduled for deferred job queue execution.';
                }
            }

            group(Status)
            {
                Caption = 'Status';

                field("Last Deploy Status"; Rec."Last Deploy Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Latest deployment status.';
                }
                field(SummaryTxt; SummaryTxt)
                {
                    ApplicationArea = All;
                    Caption = 'Summary';
                    ToolTip = 'Summary for the latest deployment execution.';
                }
                field("Last Deploy At"; Rec."Last Deploy At")
                {
                    ApplicationArea = All;
                    Caption = 'Started Date';
                    ToolTip = 'Timestamp for the latest deployment execution.';
                }
                field("Last Scheduled At"; Rec."Last Scheduled At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Timestamp for the latest scheduled request.';
                }
            }

            group(Repository)
            {
                Caption = 'Repository';

                field("Deploy Repo Owner"; Rec."Deploy Repo Owner")
                {
                    ApplicationArea = All;
                    ToolTip = 'GitHub owner or organization.';
                }
                field("Deploy Repo Name"; Rec."Deploy Repo Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'GitHub repository name.';
                }
                field("Deploy Branch"; Rec."Deploy Branch")
                {
                    ApplicationArea = All;
                    ToolTip = 'Git branch used for dispatch.';
                }
                field("Deploy Workflow File"; Rec."Deploy Workflow File")
                {
                    ApplicationArea = All;
                    ToolTip = 'Workflow file in .github/workflows.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(RefreshStatus)
            {
                ApplicationArea = All;
                Caption = 'Refresh';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Reload latest deployment status from setup.';

                trigger OnAction()
                begin
                    if Rec.Get(Rec."No.") then;
                    UpdateComputedFields();
                    CurrPage.Update(false);
                end;
            }
            action(OpenWorkflowRun)
            {
                ApplicationArea = All;
                Caption = 'Open Run Page';
                Image = Navigate;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Open GitHub Actions workflow page for this deployment.';

                trigger OnAction()
                begin
                    Rec.TestField("Last Deploy Run URL");
                    Hyperlink(Rec."Last Deploy Run URL");
                end;
            }
        }
    }

    var
        ScheduleTypeTxt: Text[30];
        SummaryTxt: Text[280];

    trigger OnAfterGetCurrRecord()
    begin
        UpdateComputedFields();
    end;

    procedure SetSetupNo(SetupNo: Code[20])
    begin
        if SetupNo = '' then
            exit;
        if Rec.Get(SetupNo) then;
        UpdateComputedFields();
    end;

    local procedure UpdateComputedFields()
    begin
        if Rec."Last Deploy Status" = Rec."Last Deploy Status"::Scheduled then
            ScheduleTypeTxt := 'Scheduled'
        else
            ScheduleTypeTxt := 'Immediate';

        if Rec."Last Deploy Message" <> '' then
            SummaryTxt := Rec."Last Deploy Message"
        else
            SummaryTxt := 'Deployment request submitted.';
    end;
}
