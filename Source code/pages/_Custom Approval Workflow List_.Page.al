page 80119 "Custom Approval Workflow List"
{
    ApplicationArea = All;
    Caption = 'Custom Approval Workflow';
    PageType = List;
    SourceTable = "Custom Approval Workflow Setup";
    UsageCategory = Lists;
    CardPageId = "Custom Approval Workflow";

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Configuration number.';
                }
                field("Table No."; Rec."Table No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Target table.';
                }
                field("Table Name"; Rec."Table Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Table caption.';
                }
                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = All;
                    ToolTip = 'Enabled.';
                }
                field("Workflow Code"; Rec."Workflow Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Workflow code.';
                }
                field("Workflow Category Code"; Rec."Workflow Category Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Workflow category code.';
                }
                field("Card Page Name"; Rec."Card Page Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Target card page name.';
                }
            }
        }
    }
}
