table 80149 "NoCode Workflow Step"
{
    Caption = 'NoCode Workflow Step';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            AutoIncrement = true;
        }
        field(2; "Workflow Code"; Code[20])
        {
            Caption = 'Workflow Code';
            DataClassification = CustomerContent;
            TableRelation = "NoCode Workflow Header".Code;
        }
        field(3; "Event Type"; Enum "Workflow Event Type")
        {
            Caption = 'Event Type';
            DataClassification = CustomerContent;
        }
        field(4; "Condition Field No."; Integer)
        {
            Caption = 'Condition Field No.';
            DataClassification = CustomerContent;
        }
        field(5; "Condition Operator"; Enum "Condition Operator")
        {
            Caption = 'Condition Operator';
            DataClassification = CustomerContent;
        }
        field(6; "Condition Value"; Text[100])
        {
            Caption = 'Condition Value';
            DataClassification = CustomerContent;
        }
        field(7; "Response Type"; Enum "Workflow Response Type")
        {
            Caption = 'Response Type';
            DataClassification = CustomerContent;
        }
        field(8; "Sequence No."; Integer)
        {
            Caption = 'Sequence No.';
            DataClassification = CustomerContent;
        }
        field(9; "Approver User ID"; Code[50])
        {
            Caption = 'Approver User ID';
            DataClassification = CustomerContent;
            TableRelation = User."User Name";
        }
        field(10; "Notification Message"; Text[250])
        {
            Caption = 'Notification Message';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Workflow; "Workflow Code", "Sequence No.")
        {
        }
    }
}