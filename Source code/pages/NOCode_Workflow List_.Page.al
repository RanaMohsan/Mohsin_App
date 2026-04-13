page 80220 "Mohsin NoCode Workflow List"
{
    ApplicationArea = All;
    Caption = 'Mohsin NoCode Workflow List';
    PageType = List;
    SourceTable = "NoCode Workflow Header";
    UsageCategory = Lists;
    CardPageId = "Mohsin NoCode Workflow Card";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Code"; Rec."Code")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Category Code"; Rec."Category Code")
                {
                    ApplicationArea = All;
                }
                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = All;
                }
                field("Document Table ID"; Rec."Document Table ID")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(EnableWorkflow)
            {
                ApplicationArea = All;
                Caption = 'Enable';
                Image = EnableBreakpoint;

                trigger OnAction()
                begin
                    Rec.Enabled := true;
                    Rec.Modify();
                end;
            }
            action(DisableWorkflow)
            {
                ApplicationArea = All;
                Caption = 'Disable';
                Image = DisableBreakpoint;

                trigger OnAction()
                begin
                    Rec.Enabled := false;
                    Rec.Modify();
                end;
            }
        }
    }
}