page 80144 "Workflow Demo Setup"
{
    ApplicationArea = All;
    Caption = 'Workflow Demo Setup';
    PageType = Card;
    SourceTable = "Workflow Demo Setup";
    UsageCategory = Administration;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'Numbering';

                field("Cust. Appr. WF Nos."; Rec."Cust. Appr. WF Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Create a No. Series (e.g. code CUSTAPP, starting number CUSTAPP0001) and select it here. New workflow setups then get the next number automatically.';
                }
            }
        }
    }
    trigger OnOpenPage()
    var
        DemoSetup: Record "Workflow Demo Setup";
    begin
        if not DemoSetup.Get('SETUP') then begin
            DemoSetup.Init();
            DemoSetup."Primary Key" := 'SETUP';
            DemoSetup.Insert(true);
        end;
        Rec.Get('SETUP');
    end;
}
