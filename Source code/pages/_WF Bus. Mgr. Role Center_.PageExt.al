pageextension 80142 "WF Bus. Mgr. Role Center" extends "Business Manager Role Center"
{
    actions
    {
        addlast(Sections)
        {
            group(CustomApproval)
            {
                Caption = 'Mohsin - Custom Approval';


                action(CustomApprovalWorkflow)
                {
                    ApplicationArea = All;
                    Caption = 'Custom Approval Workflow';
                    Image = Workflow;
                    RunObject = page "Mohsin Workflow List";
                }

            }
        }
    }
}
