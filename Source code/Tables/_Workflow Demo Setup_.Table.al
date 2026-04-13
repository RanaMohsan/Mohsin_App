table 80104 "Workflow Demo Setup"
{
    Caption = 'Workflow Demo Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            ToolTip = 'Singleton key.';
        }
        field(2; "Cust. Appr. WF Nos."; Code[20])
        {
            Caption = 'Custom Approval WF Nos.';
            TableRelation = "No. Series";
            ToolTip = 'No. Series used for new Custom Approval Workflow setup numbers (e.g. CUSTAPP0017).';
        }
    }
    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}
