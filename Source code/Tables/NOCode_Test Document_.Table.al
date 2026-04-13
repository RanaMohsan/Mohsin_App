table 80203 "NoCode Test Document"
{
    Caption = 'NoCode Test Document';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(3; Status; Text[50])
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
        }
        field(4; "Workflow Code"; Code[20])
        {
            Caption = 'Workflow Code';
            DataClassification = CustomerContent;
            TableRelation = "NoCode Workflow Header".Code;
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }
}