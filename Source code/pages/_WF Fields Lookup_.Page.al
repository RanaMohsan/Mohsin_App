page 80118 "WF Fields Lookup"
{
    ApplicationArea = All;
    Caption = 'Fields';
    PageType = List;
    Editable = false;
    SourceTable = "Field";

    layout
    {
        area(Content)
        {
            repeater(Control1)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Field number.';
                }
                field(FieldName; Rec.FieldName)
                {
                    ApplicationArea = All;
                    ToolTip = 'Field name.';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Field type.';
                }
            }
        }
    }
}
