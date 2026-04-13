page 80225 "Mohsin NoCode Workflow Setup"
{
    ApplicationArea = All;
    Caption = 'Mohsin NoCode Workflow Setup';
    PageType = Card;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(Setup)
            {
                Caption = 'Setup';

                field(CreateSample; CreateSample)
                {
                    ApplicationArea = All;
                    Caption = 'Create Sample Workflow';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CreateSampleWorkflow)
            {
                ApplicationArea = All;
                Caption = 'Create Sample Workflow';
                Image = Setup;

                trigger OnAction()
                var
                    WorkflowSetup: Codeunit "NoCode Workflow Se";
                begin
                    WorkflowSetup.CreateSampleWorkflow();
                end;
            }
        }
    }

    var
        CreateSample: Boolean;
}