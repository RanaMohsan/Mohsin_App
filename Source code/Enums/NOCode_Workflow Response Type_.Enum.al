enum 80211 "Workflow Response Type"
{
    Extensible = true;

    value(0; "Send Approval")
    {
        Caption = 'Send Approval';
    }
    value(1; Reject)
    {
        Caption = 'Reject';
    }
    value(2; "Add Restriction")
    {
        Caption = 'Add Restriction';
    }
    value(3; "Remove Restriction")
    {
        Caption = 'Remove Restriction';
    }
    value(4; Notify)
    {
        Caption = 'Notify';
    }
}