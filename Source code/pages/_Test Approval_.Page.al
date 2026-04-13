page 80111 "Test Approval"
{
    ApplicationArea = All;
    Caption = 'Test Approval';
    PageType = Card;
    SourceTable = "Approval Testing";
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field(PK; Rec.PK)
                {
                    ApplicationArea = All;
                    ToolTip = 'Primary key.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Description.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Style = Favorable;
                    StyleExpr = Rec.Status = Rec.Status::Open;
                    ToolTip = 'Current status.';
                }
            }
        }
    }
}
