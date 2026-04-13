page 80113 "Custom Approval Wf Gen Lines"
{
    ApplicationArea = All;
    Caption = 'Page Extensions';
    PageType = ListPart;
    SourceTable = "Custom Approval Wf Gen Line";

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Generated file or object name.';
                }
                field("File Extension"; Rec."File Extension")
                {
                    ApplicationArea = All;
                    ToolTip = 'File extension.';
                }
            }
        }
    }
}
