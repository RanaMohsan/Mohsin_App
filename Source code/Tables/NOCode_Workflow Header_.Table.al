table 80200 "NoCode Workflow Header"
{
    Caption = 'NoCode Workflow Header';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(3; "Category Code"; Code[20])
        {
            Caption = 'Category Code';
            DataClassification = CustomerContent;
            TableRelation = "Workflow Category".Code;
        }
        field(4; Enabled; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = CustomerContent;
        }
        field(5; "Document Table ID"; Integer)
        {
            Caption = 'Document Table ID';
            DataClassification = CustomerContent;
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
        }
        field(6; "Card Page ID"; Integer)
        {
            Caption = 'Card Page ID';
            DataClassification = CustomerContent;
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Page));
        }
        field(7; "Status Field Name"; Text[30])
        {
            Caption = 'Status Field Name';
            DataClassification = CustomerContent;
        }
        field(8; "On Open Status"; Text[50])
        {
            Caption = 'On Open Status';
            DataClassification = CustomerContent;
        }
        field(9; "On Pending Status"; Text[50])
        {
            Caption = 'On Pending Status';
            DataClassification = CustomerContent;
        }
        field(10; "On Approved Status"; Text[50])
        {
            Caption = 'On Approved Status';
            DataClassification = CustomerContent;
        }
        field(11; "On Rejected Status"; Text[50])
        {
            Caption = 'On Rejected Status';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }
}