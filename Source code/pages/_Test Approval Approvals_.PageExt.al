pageextension 80116 "Test Approval Approvals" extends "Test Approval"
{
    actions
    {
        addlast(Processing)
        {
            group(RequestApproval)
            {
                Caption = 'Request Approval';

                action(SendApprovalRequest)
                {
                    ApplicationArea = All;
                    Caption = 'Send Approval Request';
                    Enabled = Rec.Status = Rec.Status::Open;
                    Image = SendApprovalRequest;
                    ToolTip = 'Send an approval request for this record.';

                    trigger OnAction()
                    begin
                        WfMgt.SendApprovalRequest(Rec);
                    end;
                }
                action(CancelApprovalRequest)
                {
                    ApplicationArea = All;
                    Caption = 'Cancel Approval Request';
                    Enabled = Rec.Status = Rec.Status::Pending;
                    Image = Cancel;
                    ToolTip = 'Cancel the approval request.';

                    trigger OnAction()
                    begin
                        WfMgt.CancelApprovalRequest(Rec);
                    end;
                }
            }
            group(Approval)
            {
                Caption = 'Approve';

                action(Approve)
                {
                    ApplicationArea = All;
                    Caption = 'Approve';
                    Image = Approve;
                    ToolTip = 'Approve the pending approval request.';
                    Visible = OpenApprovalEntriesExistForCurrUser;

                    trigger OnAction()
                    begin
                        WfMgt.ApproveRecord(Rec);
                    end;
                }
                action(Reject)
                {
                    ApplicationArea = All;
                    Caption = 'Reject';
                    Image = Cancel;
                    ToolTip = 'Reject the pending approval request.';
                    Visible = OpenApprovalEntriesExistForCurrUser;

                    trigger OnAction()
                    begin
                        WfMgt.RejectRecord(Rec);
                    end;
                }
            }
        }
    }
    var
        OpenApprovalEntriesExistForCurrUser: Boolean;
        WfMgt: Codeunit "Custom Approval Workflow Mgt.";

    trigger OnAfterGetCurrRecord()
    begin
        OpenApprovalEntriesExistForCurrUser := WfMgt.HasOpenApprovalEntriesForCurrentUser(Rec.RecordId);
    end;
}
