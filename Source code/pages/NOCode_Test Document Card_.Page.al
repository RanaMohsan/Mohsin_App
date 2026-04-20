page 80224 "Mohsin NoCode Test Doc Card"
{
    ApplicationArea = All;
    Caption = 'Mohsin NoCode Test Document Card';
    PageType = Card;
    SourceTable = "NoCode Test Document";
    UsageCategory = Tasks;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
                field("Workflow Code"; Rec."Workflow Code")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SendApprovalRequest)
            {
                ApplicationArea = All;
                Caption = 'Send Approval Request';
                Image = SendApprovalRequest;
                Visible = Rec.Status = 'Open';

                trigger OnAction()
                var
                    WorkflowMgt: Codeunit "NoCod Workflow Mant";
                begin
                    WorkflowMgt.SendApprovalRequest(Rec);
                end;
            }
            action(Approve)
            {
                ApplicationArea = All;
                Caption = 'Approve';
                Image = Approve;
                Visible = IsApprover;

                trigger OnAction()
                var
                    WorkflowMgt: Codeunit "NoCod Workflow Mant";
                begin
                    WorkflowMgt.Approve(Rec);
                end;
            }
            action(Reject)
            {
                ApplicationArea = All;
                Caption = 'Reject';
                Image = Reject;
                Visible = IsApprover;

                trigger OnAction()
                var
                    WorkflowMgt: Codeunit "NoCod Workflow Mant";
                begin
                    WorkflowMgt.Reject(Rec);
                end;
            }
            action(Cancel)
            {
                ApplicationArea = All;
                Caption = 'Cancel';
                Image = Cancel;
                Visible = Rec.Status = 'Pending';

                trigger OnAction()
                var
                    WorkflowMgt: Codeunit "NoCod Workflow Mant";
                begin
                    WorkflowMgt.Cancel(Rec);
                end;
            }
        }
    }

    var
        IsApprover: Boolean;

    trigger OnAfterGetRecord()
    var
        WorkflowMgt: Codeunit "NoCod Workflow Mant";
    begin
        IsApprover := WorkflowMgt.IsCurrentUserApprover(Rec);
    end;
}