page 80112 "Custom Approval Workflow"
{
    ApplicationArea = All;
    Caption = 'Custom Approval Workflow';
    PageType = Card;
    SourceTable = "Custom Approval Workflow Setup";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                InstructionalText = 'Select the custom table to set the workflow.';

                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Importance = Promoted;
                }
                field("Table Name"; Rec."Table Name")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                }
                field("Table No."; Rec."Table No.")
                {
                    ApplicationArea = All;
                    Caption = 'Table ID';
                    Importance = Promoted;
                    ToolTip = 'Select the table this workflow applies to.';
                }
                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = All;
                    ToolTip = 'Enable this configuration.';
                }
            }
            group(StatusConfiguration)
            {
                Caption = 'Status Configuration';

                field("Status Field No."; Rec."Status Field No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Field number of the Option/Enum status field.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        FieldRec: Record Field;
                        CloseAction: Action;
                    begin
                        if Rec."Table No." = 0 then begin
                            Message('Please select a table first in the Table No. field.');
                            exit(false);
                        end;
                        FieldRec.Reset();
                        FieldRec.SetRange(TableNo, Rec."Table No.");
                        if not FieldRec.FindFirst() then exit(false);
                        CloseAction := Page.RunModal(Page::"WF Fields Lookup", FieldRec);
                        if not (CloseAction in [Action::OK, Action::LookupOK, Action::Yes]) then exit(false);
                        if FieldRec."No." = 0 then exit(false);
                        // Lookup return value must be written to Text so the platform applies the field no. and runs OnValidate (fills Status Field Name).
                        Text := Format(FieldRec."No.");
                        CurrPage.Update(true);
                        exit(true);
                    end;
                }
                field("Status Field Name"; Rec."Status Field Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Status field name.';
                }
                field("Send Approval When"; Rec."Send Approval When")
                {
                    ApplicationArea = All;
                    ToolTip = 'Status when Send Approval is allowed.';
                }
                field("Cancel Approval When"; Rec."Cancel Approval When")
                {
                    ApplicationArea = All;
                    ToolTip = 'Status when Cancel Approval is allowed.';
                }
                field("On Open Document"; Rec."On Open Document")
                {
                    ApplicationArea = All;
                    ToolTip = 'Maps to open document.';
                }
                field("On Pending Document"; Rec."On Pending Document")
                {
                    ApplicationArea = All;
                    ToolTip = 'Maps to pending document.';
                }
                field("On Approve Document"; Rec."On Approve Document")
                {
                    ApplicationArea = All;
                    ToolTip = 'Status after approve.';
                }
                field("On Reject Document"; Rec."On Reject Document")
                {
                    ApplicationArea = All;
                    ToolTip = 'Status after reject.';
                }
                field("On Release Document"; Rec."On Release Document")
                {
                    ApplicationArea = All;
                    ToolTip = 'Status when released.';
                }
            }
            group(DocumentConfiguration)
            {
                Caption = 'Document Configuration';

                field("Document No. Field No."; Rec."Document No. Field No.")
                {
                    ApplicationArea = All;
                    Caption = 'Document No.';
                    ToolTip = 'Document number field.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        FieldRec: Record Field;
                        CloseAction: Action;
                    begin
                        if Rec."Table No." = 0 then begin
                            Message('Please select a table first in the Table No. field.');
                            exit(false);
                        end;
                        FieldRec.Reset();
                        FieldRec.SetRange(TableNo, Rec."Table No.");
                        if not FieldRec.FindFirst() then exit(false);
                        CloseAction := Page.RunModal(Page::"WF Fields Lookup", FieldRec);
                        if not (CloseAction in [Action::OK, Action::LookupOK, Action::Yes]) then exit(false);
                        if FieldRec."No." = 0 then exit(false);
                        Text := Format(FieldRec."No.");
                        CurrPage.Update(true);
                        exit(true);
                    end;
                }
                field("Document No. Field Name"; Rec."Document No. Field Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Document number field name.';
                }
                field("Card Page ID"; Rec."Card Page ID")
                {
                    ApplicationArea = All;
                    Caption = 'Page ID';
                    ToolTip = 'Target card page for generated extension.';
                }
                field("Card Page Name"; Rec."Card Page Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Card page name.';
                }
            }
            group(WorkflowConfiguration)
            {
                Caption = 'Workflow Configuration';

                field("Workflow Category Code"; Rec."Workflow Category Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Workflow category code.';
                }
                field("Workflow Category Description"; Rec."Workflow Category Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Workflow category description.';
                }
                field("Workflow Code"; Rec."Workflow Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Workflow code.';
                }
                field("Workflow Description"; Rec."Workflow Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Workflow description.';
                }
            }
            group(DeploymentConfiguration)
            {
                Caption = 'Deployment Configuration';
                InstructionalText = 'Configure GitHub dispatch settings for instant/scheduled deployment automation.';

                field("Deploy Repo Owner"; Rec."Deploy Repo Owner")
                {
                    ApplicationArea = All;
                    ToolTip = 'GitHub repository owner.';
                }
                field("Deploy Repo Name"; Rec."Deploy Repo Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'GitHub repository name.';
                }
                field("Deploy Branch"; Rec."Deploy Branch")
                {
                    ApplicationArea = All;
                    ToolTip = 'Git branch used for workflow dispatch.';
                }
                field("Deploy Workflow File"; Rec."Deploy Workflow File")
                {
                    ApplicationArea = All;
                    ToolTip = 'Workflow file name in .github/workflows.';
                }
                field("Deploy PAT Token"; Rec."Deploy PAT Token")
                {
                    ApplicationArea = All;
                    ToolTip = 'GitHub token with Actions workflow dispatch permission.';
                }
            }
            group(DeploymentMonitoring)
            {
                Caption = 'Deployment Monitoring';

                field("Last Scheduled At"; Rec."Last Scheduled At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Last time a deploy job was scheduled.';
                }
                field("Last Deploy At"; Rec."Last Deploy At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Last deployment execution time.';
                }
                field("Last Deploy Status"; Rec."Last Deploy Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Last deployment status.';
                }
                field("Last Deploy Message"; Rec."Last Deploy Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Last deployment message or error.';
                }
                field("Last Deploy Run URL"; Rec."Last Deploy Run URL")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Workflow page URL in GitHub Actions.';
                }
            }
        }
        area(FactBoxes)
        {
            part(PageExtensions; "Custom Approval Wf Gen Lines")
            {
                ApplicationArea = All;
                Caption = 'Page Extensions';
                SubPageLink = "Setup No." = field("No.");
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(CreateWorkflowTemplate)
            {
                ApplicationArea = All;
                Caption = 'Create Workflow Template';
                Image = WorkflowSetup;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Creates the workflow category and a workflow header (template). Workflow steps (When Event / Then Response) are not generated; add them on the Workflow page after opening this template from Workflow Templates.';

                trigger OnAction()
                var
                    Builder: Codeunit "Workflow Template Builder";
                begin
                    Builder.CreateOrUpdateFromSetup(Rec);
                end;
            }
            action(GenerateCode)
            {
                ApplicationArea = All;
                Caption = 'Generate Code';
                Image = CreateForm;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Generate approval page extension AL and open the code editor.';

                trigger OnAction()
                var
                    Gen: Codeunit "AL Page Extension Generator";
                    Mgt: Codeunit "Custom Approval Workflow Mgt.";
                    ALTxt: Text;
                    PageExtId: Integer;
                begin
                    Rec.TestField("Table No.");
                    Rec.TestField("Card Page ID");
                    Rec.TestField("Status Field No.");
                    PageExtId := 80140;
                    ALTxt := Gen.GeneratePageExtension(Rec, PageExtId);
                    Gen.SaveGeneratedToSetup(Rec, ALTxt, PageExtId);
                    Rec.Get(Rec."No.");
                    CurrPage.Update(false);
                    Commit();
                    Mgt.OpenCodeEditor(Rec);
                end;
            }
            action(OpenAutoDeployScheduler)
            {
                ApplicationArea = All;
                Caption = 'Auto Deploy Scheduler';
                Image = SendTo;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Open scheduler for instant or deferred deployment.';

                trigger OnAction()
                var
                    Mgt: Codeunit "Custom Approval Workflow Mgt.";
                begin
                    Commit();
                    Mgt.OpenAutoDeploy(Rec);
                    Rec.Get(Rec."No.");
                    CurrPage.Update(false);
                end;
            }
            action(OpenLastDeployRun)
            {
                ApplicationArea = All;
                Caption = 'Open Last Deploy Run';
                Image = Navigate;
                ToolTip = 'Open GitHub Actions workflow page for the last dispatch.';

                trigger OnAction()
                begin
                    Rec.TestField("Last Deploy Run URL");
                    Hyperlink(Rec."Last Deploy Run URL");
                end;
            }
        }
        area(Navigation)
        {
            action(WorkflowDemoSetup)
            {
                ApplicationArea = All;
                Caption = 'Workflow Demo Setup';
                Image = Setup;
                RunObject = page "Workflow Demo Setup";
                ToolTip = 'Set the No. Series for automatic CUSTAPP-style numbers on new workflow setups.';
            }
        }
    }
}
