pageextension 80142 "WF Bus. Mgr. Role Center" extends "Business Manager Role Center"
{
    actions
    {
        addlast(Sections)
        {
            group(CustomApproval)
            {
                Caption = 'Custom Approval';

                action(AutoDeploySetup)
                {
                    ApplicationArea = All;
                    Caption = 'Auto Deploy Setup';
                    Image = Setup;
                    RunObject = codeunit "WF Nav Auto Deploy";
                    ToolTip = 'Opens Auto Deploy Scheduler using the first Custom Approval Workflow setup. Create a setup first if none exists.';
                }
                action(CustomApprovalWorkflow)
                {
                    ApplicationArea = All;
                    Caption = 'Custom Approval Workflow';
                    Image = WorkflowSetup;
                    RunObject = page "Custom Approval Workflow List";
                    ToolTip = 'Open Custom Approval Workflow setups.';
                }
                action(Workflows)
                {
                    ApplicationArea = All;
                    Caption = 'Workflows';
                    Image = Workflow;
                    RunObject = page "Workflows";
                    ToolTip = 'Open all workflows.';
                }
                action(WorkflowTemplates)
                {
                    ApplicationArea = All;
                    Caption = 'Workflow Templates';
                    Image = Template;
                    RunObject = page "Workflow Templates";
                    ToolTip = 'Open workflow templates grouped by category.';
                }
            }
        }
    }
}
