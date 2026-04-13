page 80110 "Approval Testing List"
{
    ApplicationArea = All;
    Caption = 'Approval Testing List';
    PageType = List;
    SourceTable = "Approval Testing";
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(Rep)
            {
                field(PK; Rec.PK)
                {
                    ApplicationArea = All;
                    ToolTip = 'Primary key.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Style = Favorable;
                    StyleExpr = Rec.Status = Rec.Status::Open;
                    ToolTip = 'Workflow status.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Description.';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(NewFromList)
            {
                ApplicationArea = All;
                Caption = 'New';
                Image = New;
                RunObject = page "Test Approval";
                RunPageMode = Create;
                ToolTip = 'Create a new approval test record.';
            }
        }
    }
}
