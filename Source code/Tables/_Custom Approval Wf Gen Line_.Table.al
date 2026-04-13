table 80103 "Custom Approval Wf Gen Line"
{
    Caption = 'Custom Approval Wf Gen Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Setup No."; Code[20])
        {
            Caption = 'Setup No.';
            TableRelation = "Custom Approval Workflow Setup"."No.";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(10; Name; Text[280])
        {
            Caption = 'Name';
            ToolTip = 'Generated object or file name.';
        }
        field(11; "File Extension"; Text[30])
        {
            Caption = 'File Extension';
            ToolTip = 'File extension, for example .al.';
        }
    }
    keys
    {
        key(PK; "Setup No.", "Line No.")
        {
            Clustered = true;
        }
    }
}
