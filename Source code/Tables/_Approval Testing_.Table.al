table 80101 "Approval Testing"
{
    Caption = 'Approval Testing';
    DataClassification = CustomerContent;
    LookupPageId = "Approval Testing List";
    DrillDownPageId = "Approval Testing List";

    fields
    {
        field(1; PK; Integer)
        {
            Caption = 'PK';
            ToolTip = 'Primary key for the test document.';
        }
        field(2; Status; Enum "WFDemo Status")
        {
            Caption = 'Status';
            ToolTip = 'Current workflow status.';
        }
        field(3; Description; Text[100])
        {
            Caption = 'Description';
            ToolTip = 'Description of the record.';
        }
    }
    keys
    {
        key(PK; PK)
        {
            Clustered = true;
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; PK, Description, Status)
        {
        }
    }
}
