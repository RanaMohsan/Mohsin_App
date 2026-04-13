table 80202 "NoCode Approval Entry"
{
    Caption = 'NoCode Approval Entry';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            AutoIncrement = true;
        }
        field(2; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(3; "Workflow Code"; Code[20])
        {
            Caption = 'Workflow Code';
            DataClassification = CustomerContent;
            TableRelation = "NoCode Workflow Header".Code;
        }
        field(4; "Approver User ID"; Code[50])
        {
            Caption = 'Approver User ID';
            DataClassification = CustomerContent;
            TableRelation = User."User Name";
        }
        field(5; Status; Enum "Approval Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
        }
        field(6; "Date-Time"; DateTime)
        {
            Caption = 'Date-Time';
            DataClassification = CustomerContent;
        }
        field(7; "Record ID"; RecordId)
        {
            Caption = 'Record ID';
            DataClassification = CustomerContent;
        }
        field(8; "Sequence No."; Integer)
        {
            Caption = 'Sequence No.';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Document; "Record ID", "Sequence No.")
        {
        }
    }
}