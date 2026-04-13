page 80223 "Mohsin NoCode Appr Entry List"
{
    ApplicationArea = All;
    Caption = 'Mohsin NoCode Approval Entry List';
    PageType = List;
    SourceTable = "NoCode Approval Entry";
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                }
                field("Workflow Code"; Rec."Workflow Code")
                {
                    ApplicationArea = All;
                }
                field("Approver User ID"; Rec."Approver User ID")
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
                field("Date-Time"; Rec."Date-Time")
                {
                    ApplicationArea = All;
                }
                field("Sequence No."; Rec."Sequence No.")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}