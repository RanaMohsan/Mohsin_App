pageextension 80131 "Sales Header - WF Status" extends "Sales Order"
{
    layout
    {
        addafter(Status)
        {
            field("WFDemo Status"; Rec."WFDemo Status")
            {
                ApplicationArea = All;
                Caption = 'Workflow Status';
                ToolTip = 'Displays the current approval workflow status for this sales order.';
            }
        }
    }
}
