codeunit 80125 "Workflow Demo Install"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        InsertNoSeries();
        InitializeSetup();
    end;

    local procedure InsertNoSeries()
    var
        NoSeriesLine: Record "No. Series Line";
        NoSeriesRecord: Record "No. Series";
    begin
        // Create CUSTAPP No. Series if it doesn't exist
        if not NoSeriesRecord.Get('CUSTAPP') then begin
            NoSeriesRecord.Code := 'CUSTAPP';
            NoSeriesRecord.Description := 'Custom Approval Workflow';
            NoSeriesRecord."Default Nos." := true;
            NoSeriesRecord.Insert(true);

            // Add No. Series Line
            NoSeriesLine."Series Code" := 'CUSTAPP';
            NoSeriesLine."Line No." := 10000;
            NoSeriesLine."Starting No." := 'CUSTAPP0001';
            NoSeriesLine."Ending No." := 'CUSTAPP9999';
            NoSeriesLine."Last No. Used" := 'CUSTAPP0000';
            NoSeriesLine.Insert(true);
        end;
    end;

    local procedure InitializeSetup()
    var
        DemoSetup: Record "Workflow Demo Setup";
    begin
        if not DemoSetup.Get('SETUP') then begin
            DemoSetup.Init();
            DemoSetup."Primary Key" := 'SETUP';
            DemoSetup."Cust. Appr. WF Nos." := 'CUSTAPP';
            DemoSetup.Insert(true);
        end else if DemoSetup."Cust. Appr. WF Nos." = '' then begin
            DemoSetup."Cust. Appr. WF Nos." := 'CUSTAPP';
            DemoSetup.Modify(true);
        end;
    end;
}
