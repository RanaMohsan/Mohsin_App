enum 80210 "Workflow Event Type"
{
    Extensible = true;

    value(0; Send)
    {
        Caption = 'Send';
    }
    value(1; Approve)
    {
        Caption = 'Approve';
    }
    value(2; Reject)
    {
        Caption = 'Reject';
    }
    value(3; Delegate)
    {
        Caption = 'Delegate';
    }
    value(4; Cancel)
    {
        Caption = 'Cancel';
    }
}