tableextension 80130 "Sales Header - WF Status" extends "Sales Header"
{
    fields
    {
        field(80100; "WFDemo Status"; Enum "WFDemo Status")
        {
            Caption = 'Workflow Status';
            Description = 'Tracks the approval workflow status for this sales document.';
            DataClassification = SystemMetadata;
        }
    }
}
