codeunit 80121 "AL Page Extension Generator"
{
    procedure GeneratePageExtension(var Setup: Record "Mohsin Test Workflow Setup"; PageExtensionObjectId: Integer): Text
    var
        Tb: TextBuilder;
        SafeName: Text;
    begin
        // Validation
        if Setup."Table No." = 0 then
            Error('Table No. must be configured before generating code.');
        if Setup."Card Page ID" = 0 then
            Error('Card Page ID must be configured before generating code.');
        if Setup."Status Field No." = 0 then
            Error('Status Field No. must be configured before generating code.');

        // Validate status mappings
        ValidateStatusMappings(Setup);

        SafeName := SanitizeObjectName(Setup."Card Page Name");
        if SafeName = '' then
            SafeName := SanitizeObjectName(Setup."Table Name");
        if SafeName = '' then
            SafeName := 'PageExt' + Format(Setup."Card Page ID");

        AppendApprovalPageExtension(
            Tb,
            SafeName,
            Setup."Card Page ID",
            PageExtensionObjectId,
            Setup."Status Field Name",
            Setup."Document No. Field Name",
            Setup."Send Approval When",
            Setup."Cancel Approval When");

        exit(Tb.ToText());
    end;

    local procedure AppendApprovalPageExtension(var Tb: TextBuilder; SafeName: Text; CardPageId: Integer; PageExtensionObjectId: Integer; StatusFieldName: Text; DocumentNoFieldName: Text; SendApprovalWhen: Enum "WFDemo Status"; CancelApprovalWhen: Enum "WFDemo Status")
    var
        PageExtName: Text[120];
        StatusReference: Text[120];
        SendWhenMember: Text[30];
        CancelWhenMember: Text[30];
        SendEnabledExpr: Text[280];
        CancelEnabledExpr: Text[280];
    begin
        PageExtName := CopyStr(SafeName + ' Approval', 1, MaxStrLen(PageExtName));
        if StatusFieldName = '' then begin
            StatusReference := 'Status';
            Tb.AppendLine('// WARNING: Status field is not configured. Replace Rec.Status with the actual status field name.');
        end else
            StatusReference := '"' + StatusFieldName + '"';

        if DocumentNoFieldName <> '' then
            Tb.AppendLine('// Document No. field configured as Rec."' + DocumentNoFieldName + '".')
        else
            Tb.AppendLine('// WARNING: Document No. field is not configured. Set the Document No. Field No. in setup.');

        SendWhenMember := GetWFDemoStatusEnumMemberName(SendApprovalWhen);
        CancelWhenMember := GetWFDemoStatusEnumMemberName(CancelApprovalWhen);

        if SendWhenMember = '' then
            SendEnabledExpr := 'true'
        else
            SendEnabledExpr := 'Rec.' + StatusReference + ' = Rec.' + StatusReference + '::' + SendWhenMember;

        if CancelWhenMember = '' then
            CancelEnabledExpr := 'true'
        else
            CancelEnabledExpr := 'Rec.' + StatusReference + ' = Rec.' + StatusReference + '::' + CancelWhenMember;

        Tb.AppendLine('pageextension ' + Format(PageExtensionObjectId) + ' "' + PageExtName + '" extends ' + Format(CardPageId));
        Tb.AppendLine('{');
        Tb.AppendLine('    actions');
        Tb.AppendLine('    {');
        Tb.AppendLine('        addlast(Processing)');
        Tb.AppendLine('        {');
        Tb.AppendLine('            group(RequestApproval)');
        Tb.AppendLine('            {');
        Tb.AppendLine('                Caption = ''Request Approval'';');
        Tb.AppendLine('                action(SendApprovalRequest)');
        Tb.AppendLine('                {');
        Tb.AppendLine('                    ApplicationArea = All;');
        Tb.AppendLine('                    Caption = ''Send Approval Request'';');
        Tb.AppendLine('                    Enabled = ' + SendEnabledExpr + ';');
        Tb.AppendLine('                    Image = SendApprovalRequest;');
        Tb.AppendLine('                    ToolTip = ''Send an approval request for this document.'';');
        Tb.AppendLine('');
        Tb.AppendLine('                    trigger OnAction()');
        Tb.AppendLine('                    var');
        Tb.AppendLine('                        RecRef: RecordRef;');
        Tb.AppendLine('                    begin');
        Tb.AppendLine('                        RecRef.GetTable(Rec);');
        Tb.AppendLine('                        WfMgt.SendApprovalRequest(RecRef);');
        Tb.AppendLine('                    end;');
        Tb.AppendLine('                }');
        Tb.AppendLine('                action(CancelApprovalRequest)');
        Tb.AppendLine('                {');
        Tb.AppendLine('                    ApplicationArea = All;');
        Tb.AppendLine('                    Caption = ''Cancel Approval Request'';');
        Tb.AppendLine('                    Enabled = ' + CancelEnabledExpr + ';');
        Tb.AppendLine('                    Image = Cancel;');
        Tb.AppendLine('                    ToolTip = ''Cancel the approval request.'';');
        Tb.AppendLine('');
        Tb.AppendLine('                    trigger OnAction()');
        Tb.AppendLine('                    var');
        Tb.AppendLine('                        RecRef: RecordRef;');
        Tb.AppendLine('                    begin');
        Tb.AppendLine('                        RecRef.GetTable(Rec);');
        Tb.AppendLine('                        WfMgt.CancelApprovalRequest(RecRef);');
        Tb.AppendLine('                    end;');
        Tb.AppendLine('                }');
        Tb.AppendLine('            }');
        Tb.AppendLine('            group(Approval)');
        Tb.AppendLine('            {');
        Tb.AppendLine('                Caption = ''Approval Actions'';');
        Tb.AppendLine('                action(Approve)');
        Tb.AppendLine('                {');
        Tb.AppendLine('                    ApplicationArea = All;');
        Tb.AppendLine('                    Caption = ''Approve'';');
        Tb.AppendLine('                    Image = Approve;');
        Tb.AppendLine('                    ToolTip = ''Approve the pending approval request.'';');
        Tb.AppendLine('                    Visible = OpenApprovalEntriesExistForCurrUser;');
        Tb.AppendLine('');
        Tb.AppendLine('                    trigger OnAction()');
        Tb.AppendLine('                    var');
        Tb.AppendLine('                        RecRef: RecordRef;');
        Tb.AppendLine('                    begin');
        Tb.AppendLine('                        RecRef.GetTable(Rec);');
        Tb.AppendLine('                        WfMgt.ApproveRecord(RecRef);');
        Tb.AppendLine('                    end;');
        Tb.AppendLine('                }');
        Tb.AppendLine('                action(Reject)');
        Tb.AppendLine('                {');
        Tb.AppendLine('                    ApplicationArea = All;');
        Tb.AppendLine('                    Caption = ''Reject'';');
        Tb.AppendLine('                    Image = Cancel;');
        Tb.AppendLine('                    ToolTip = ''Reject the pending approval request.'';');
        Tb.AppendLine('                    Visible = OpenApprovalEntriesExistForCurrUser;');
        Tb.AppendLine('');
        Tb.AppendLine('                    trigger OnAction()');
        Tb.AppendLine('                    var');
        Tb.AppendLine('                        RecRef: RecordRef;');
        Tb.AppendLine('                    begin');
        Tb.AppendLine('                        RecRef.GetTable(Rec);');
        Tb.AppendLine('                        WfMgt.RejectRecord(RecRef);');
        Tb.AppendLine('                    end;');
        Tb.AppendLine('                }');
        Tb.AppendLine('            }');
        Tb.AppendLine('        }');
        Tb.AppendLine('    }');
        Tb.AppendLine('');
        Tb.AppendLine('    var');
        Tb.AppendLine('        OpenApprovalEntriesExistForCurrUser: Boolean;');
        Tb.AppendLine('        WfMgt: Codeunit "Custom Approval Workflow Mgt.";');
        Tb.AppendLine('');
        Tb.AppendLine('    trigger OnAfterGetCurrRecord()');
        Tb.AppendLine('    begin');
        Tb.AppendLine('        OpenApprovalEntriesExistForCurrUser :=');
        Tb.AppendLine('            WfMgt.HasOpenApprovalEntriesForCurrentUser(Rec.RecordId);');
        Tb.AppendLine('    end;');
        Tb.AppendLine('}');
    end;

    local procedure GetWFDemoStatusEnumMemberName(Status: Enum "WFDemo Status"): Text[30]
    begin
        case Status of
            Status::Open:
                exit('Open');
            Status::Pending:
                exit('Pending');
            Status::Approved:
                exit('Approved');
            Status::Rejected:
                exit('Rejected');
            Status::Released:
                exit('Released');
        end;
        exit('');
    end;

    procedure SaveGeneratedToSetup(var Setup: Record "Mohsin Test Workflow Setup"; ALText: Text; PageExtensionObjectId: Integer)
    var
        OutS: OutStream;
        GenLine: Record "Custom Approval Wf Gen Line";
        FileName: Text;
        NextLine: Integer;
    begin
        Setup."Generated AL Text".CreateOutStream(OutS, TextEncoding::UTF8);
        OutS.WriteText(ALText);
        FileName := StrSubstNo('PageExt%1.al', PageExtensionObjectId);
        Setup."Last Generated File Name" := CopyStr(FileName, 1, MaxStrLen(Setup."Last Generated File Name"));
        Setup.Modify(true);
        GenLine.SetRange("Setup No.", Setup."No.");
        if GenLine.FindLast() then
            NextLine := GenLine."Line No." + 10000
        else
            NextLine := 10000;
        GenLine.Init();
        GenLine."Setup No." := Setup."No.";
        GenLine."Line No." := NextLine;
        GenLine.Name := CopyStr('PageExt' + Format(PageExtensionObjectId), 1, MaxStrLen(GenLine.Name));
        GenLine."File Extension" := '.al';
        GenLine.Insert(true);
    end;

    local procedure SanitizeObjectName(Name: Text): Text
    var
        i: Integer;
        c: Char;
        Result: Text;
    begin
        Name := DelChr(Name, '<>', ' ');
        for i := 1 to StrLen(Name) do begin
            c := Name[i];
            if (c in ['0' .. '9', 'A' .. 'Z', 'a' .. 'z']) then
                Result += c
            else if c = ' ' then
                Result += '_';
        end;
        exit(CopyStr(Result, 1, 30));
    end;

    local procedure ValidateStatusMappings(var Setup: Record "Mohsin Test Workflow Setup")
    begin
        // Ensure required status mappings are configured
        if Setup."Send Approval When" = Setup."Send Approval When"::Open then
            Error('Send Approval When status must be configured to a non-default value.');
        if Setup."Cancel Approval When" = Setup."Cancel Approval When"::Open then
            Error('Cancel Approval When status must be configured to a non-default value.');
        if Setup."On Pending Document" = Setup."On Pending Document"::Open then
            Error('On Pending Document status must be configured to a non-default value.');
        if Setup."On Approve Document" = Setup."On Approve Document"::Open then
            Error('On Approve Document status must be configured to a non-default value.');
        if Setup."On Reject Document" = Setup."On Reject Document"::Open then
            Error('On Reject Document status must be configured to a non-default value.');

        // Validate logical consistency
        if Setup."Send Approval When" = Setup."On Pending Document" then
            Error('Send Approval When status cannot be the same as On Pending Document status.');
        if Setup."Cancel Approval When" = Setup."On Open Document" then
            Error('Cancel Approval When status cannot be the same as On Open Document status.');
    end;

    procedure ValidateSetupConfiguration(var Setup: Record "Mohsin Test Workflow Setup"): Boolean
    begin
        // Validate table configuration
        if Setup."Table No." = 0 then
            Error('Table No. must be configured.');

        // Validate page configuration
        if Setup."Card Page ID" = 0 then
            Error('Card Page ID must be configured.');

        // Validate field configurations
        if Setup."Status Field No." = 0 then
            Error('Status Field No. must be configured.');
        if Setup."Document No. Field No." = 0 then
            Error('Document No. Field No. must be configured.');

        // Validate field mappings exist in the table
        if not ValidateFieldExists(Setup."Table No.", Setup."Status Field No.") then
            Error('Status Field No. %1 does not exist in table %2.', Setup."Status Field No.", Setup."Table No.");
        if not ValidateFieldExists(Setup."Table No.", Setup."Document No. Field No.") then
            Error('Document No. Field No. %1 does not exist in table %2.', Setup."Document No. Field No.", Setup."Table No.");

        // Validate status mappings
        ValidateStatusMappings(Setup);

        exit(true);
    end;

    local procedure ValidateFieldExists(TableId: Integer; FieldId: Integer): Boolean
    var
        Field: Record Field;
    begin
        Field.SetRange(TableNo, TableId);
        Field.SetRange("No.", FieldId);
        exit(Field.FindFirst());
    end;

    procedure GenerateWorkflowTemplate(var Setup: Record "Mohsin Test Workflow Setup"): Text
    var
        Tb: TextBuilder;
    begin
        // Validate setup before generating
        ValidateSetupConfiguration(Setup);

        Tb.AppendLine('<?xml version="1.0" encoding="utf-8"?>');
        Tb.AppendLine('<Workflow>');
        Tb.AppendLine('  <Name>' + Setup."Workflow Description" + '</Name>');
        Tb.AppendLine('  <Description>Generated workflow for ' + Setup."Table Name" + '</Description>');
        Tb.AppendLine('  <Category>' + Setup."Workflow Category Code" + '</Category>');
        Tb.AppendLine('  <TableNo>' + Format(Setup."Table No.") + '</TableNo>');
        Tb.AppendLine('  <StatusField>' + Format(Setup."Status Field No.") + '</StatusField>');
        Tb.AppendLine('  <DocumentNoField>' + Format(Setup."Document No. Field No.") + '</DocumentNoField>');
        Tb.AppendLine('  <SendApprovalWhen>' + GetWFDemoStatusEnumMemberName(Setup."Send Approval When") + '</SendApprovalWhen>');
        Tb.AppendLine('  <CancelApprovalWhen>' + GetWFDemoStatusEnumMemberName(Setup."Cancel Approval When") + '</CancelApprovalWhen>');
        Tb.AppendLine('  <OnPending>' + GetWFDemoStatusEnumMemberName(Setup."On Pending Document") + '</OnPending>');
        Tb.AppendLine('  <OnApprove>' + GetWFDemoStatusEnumMemberName(Setup."On Approve Document") + '</OnApprove>');
        Tb.AppendLine('  <OnReject>' + GetWFDemoStatusEnumMemberName(Setup."On Reject Document") + '</OnReject>');
        Tb.AppendLine('  <OnRelease>' + GetWFDemoStatusEnumMemberName(Setup."On Release Document") + '</OnRelease>');
        Tb.AppendLine('</Workflow>');

        exit(Tb.ToText());
    end;
}
