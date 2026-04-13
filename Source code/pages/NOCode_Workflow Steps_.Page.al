page 80222 "Mohsin NoCode Workflow Steps"
{
    ApplicationArea = All;
    Caption = 'Mohsin NoCode Workflow Steps';
    PageType = ListPart;
    SourceTable = "NoCode Workflow Step";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Sequence No."; Rec."Sequence No.")
                {
                    ApplicationArea = All;
                }
                field("Event Type"; Rec."Event Type")
                {
                    ApplicationArea = All;
                }
                field("Condition Field No."; Rec."Condition Field No.")
                {
                    ApplicationArea = All;
                }
                field("Condition Operator"; Rec."Condition Operator")
                {
                    ApplicationArea = All;
                }
                field("Condition Value"; Rec."Condition Value")
                {
                    ApplicationArea = All;
                }
                field("Response Type"; Rec."Response Type")
                {
                    ApplicationArea = All;
                }
                field("Approver User ID"; Rec."Approver User ID")
                {
                    ApplicationArea = All;
                }
                field("Notification Message"; Rec."Notification Message")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}