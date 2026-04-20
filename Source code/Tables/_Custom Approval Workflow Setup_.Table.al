table 80102 "Mohsin Test Workflow Setup"
{
    Caption = 'Custom Approval Workflow Setup';
    DataClassification = CustomerContent;
    LookupPageId = "Mohsin Workflow List";
    DrillDownPageId = "MohsinTest Workflow";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            ToolTip = 'Identifier for this workflow configuration. Assigned from No. Series after you choose Status Field No.';
        }
        field(2; "Table No."; Integer)
        {
            Caption = 'Table No.';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
            ToolTip = 'Target table for the workflow.';

            trigger OnValidate()
            var
                TableMetadata: Record "Table Metadata";
            begin
                Clear("Table Name");
                Clear("Status Field No.");
                Clear("Status Field Name");
                Clear("Document No. Field No.");
                Clear("Document No. Field Name");
                if "Table No." = 0 then exit;
                if TableMetadata.Get("Table No.") then "Table Name" := CopyStr(TableMetadata.Caption, 1, MaxStrLen("Table Name"));
            end;
        }
        field(3; "Table Name"; Text[280])
        {
            Caption = 'Table Name';
            Editable = false;
            ToolTip = 'Caption of the selected table.';
        }
        field(4; Enabled; Boolean)
        {
            Caption = 'Enabled';
            InitValue = true;
            ToolTip = 'Indicates whether this configuration is active.';
        }
        field(10; "Status Field No."; Integer)
        {
            Caption = 'Status Field No.';
            ToolTip = 'Field number of the status field on the target table.';

            trigger OnValidate()
            var
                ResolvedName: Text[30];
            begin
                TestField("Table No.");
                ResolveFieldNameFromMetadata("Table No.", "Status Field No.", ResolvedName);
                "Status Field Name" := ResolvedName;
                if "Status Field No." <> 0 then ApplyFinalNoFromSeriesIfTemporary();
            end;
        }
        field(11; "Status Field Name"; Text[30])
        {
            Caption = 'Status Field Name';
            Editable = false;
            ToolTip = 'Name of the status field.';
        }
        field(12; "Send Approval When"; Enum "WFDemo Status")
        {
            Caption = 'Send Approval When';
            ToolTip = 'Status value when approval can be sent.';

            trigger OnValidate()
            begin
                ValidateStatusTransitions();
            end;
        }
        field(13; "Cancel Approval When"; Enum "WFDemo Status")
        {
            Caption = 'Cancel Approval When';
            ToolTip = 'Status value when approval can be cancelled.';

            trigger OnValidate()
            begin
                ValidateStatusTransitions();
            end;
        }
        field(14; "On Open Document"; Enum "WFDemo Status")
        {
            Caption = 'On Open Document';
            ToolTip = 'Status mapped to open document.';

            trigger OnValidate()
            begin
                ValidateStatusMappings();
            end;
        }
        field(15; "On Pending Document"; Enum "WFDemo Status")
        {
            Caption = 'On Pending Document';
            ToolTip = 'Status mapped to pending document.';

            trigger OnValidate()
            begin
                ValidateStatusMappings();
            end;
        }
        field(16; "On Approve Document"; Enum "WFDemo Status")
        {
            Caption = 'On Approve Document';
            ToolTip = 'Status after approve.';

            trigger OnValidate()
            begin
                ValidateStatusMappings();
            end;
        }
        field(17; "On Reject Document"; Enum "WFDemo Status")
        {
            Caption = 'On Reject Document';
            ToolTip = 'Status after reject.';

            trigger OnValidate()
            begin
                ValidateStatusMappings();
            end;
        }
        field(18; "On Release Document"; Enum "WFDemo Status")
        {
            Caption = 'On Release Document';
            ToolTip = 'Status when released.';

            trigger OnValidate()
            begin
                ValidateStatusMappings();
            end;
        }
        field(20; "Document No. Field No."; Integer)
        {
            Caption = 'Document No. Field No.';
            ToolTip = 'Field number used as document number.';

            trigger OnValidate()
            var
                ResolvedName: Text[30];
            begin
                ResolveFieldNameFromMetadata("Table No.", "Document No. Field No.", ResolvedName);
                "Document No. Field Name" := ResolvedName;
            end;
        }
        field(21; "Document No. Field Name"; Text[30])
        {
            Caption = 'Document No. Field Name';
            Editable = false;
            ToolTip = 'Field name used as document number.';
        }
        field(22; "Card Page ID"; Integer)
        {
            Caption = 'Card Page ID';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Page));
            ToolTip = 'Card page to extend with approval actions.';

            trigger OnValidate()
            var
                AllObj: Record AllObj;
            begin
                Clear("Card Page Name");
                if "Card Page ID" = 0 then exit;
                if AllObj.Get(AllObj."Object Type"::Page, "Card Page ID") then "Card Page Name" := CopyStr(AllObj."Object Name", 1, MaxStrLen("Card Page Name"));
            end;
        }
        field(23; "Card Page Name"; Text[280])
        {
            Caption = 'Card Page Name';
            Editable = false;
            ToolTip = 'Name of the card page.';
        }
        field(30; "Workflow Category Code"; Code[20])
        {
            Caption = 'Workflow Category Code';
            TableRelation = "Workflow Category".Code;
            ValidateTableRelation = false;
            ToolTip = 'Category for generated workflow templates. Lookup uses the standard Workflow Category table (Code / Description).';

            trigger OnValidate()
            var
                WorkflowCategory: Record "Workflow Category";
            begin
                if "Workflow Category Code" = '' then begin
                    Clear("Workflow Category Description");
                    exit;
                end;
                if WorkflowCategory.Get("Workflow Category Code") then
                    "Workflow Category Description" := CopyStr(WorkflowCategory.Description, 1, MaxStrLen("Workflow Category Description"))
                else
                    Clear("Workflow Category Description");
            end;
        }
        field(31; "Workflow Category Description"; Text[100])
        {
            Caption = 'Workflow Category Description';
            ToolTip = 'Description of the workflow category. Filled automatically when the category code exists in Workflow Category; enter manually for a new code before Create Workflow Template.';
        }
        field(32; "Workflow Code"; Code[20])
        {
            Caption = 'Workflow Code';
            ToolTip = 'Code of the workflow to create or update.';
        }
        field(33; "Workflow Description"; Text[100])
        {
            Caption = 'Workflow Description';
            ToolTip = 'Description of the workflow.';
        }
        field(40; "Generated AL Text"; Blob)
        {
            Caption = 'Generated AL Text';
            ToolTip = 'Last generated page extension source.';
        }
        field(41; "Last Generated File Name"; Text[280])
        {
            Caption = 'Last Generated File Name';
            ToolTip = 'Suggested file name for download.';
        }
        field(80; "Deploy Repo Owner"; Text[100])
        {
            Caption = 'Deploy Repo Owner';
            ToolTip = 'GitHub repository owner used for deployment workflow dispatch.';
        }
        field(51; "Deploy Repo Name"; Text[100])
        {
            Caption = 'Deploy Repo Name';
            ToolTip = 'GitHub repository name used for deployment workflow dispatch.';
        }
        field(52; "Deploy Branch"; Text[100])
        {
            Caption = 'Deploy Branch';
            ToolTip = 'Git branch used for workflow dispatch.';
            InitValue = 'main';
        }
        field(53; "Deploy Workflow File"; Text[180])
        {
            Caption = 'Deploy Workflow File';
            ToolTip = 'Workflow file name in .github/workflows, for example PublishToEnvironment.yaml.';
            InitValue = 'PublishToEnvironment.yaml';
        }
        field(54; "Deploy PAT Token"; Text[280])
        {
            Caption = 'Deploy PAT Token';
            ExtendedDatatype = Masked;
            ToolTip = 'GitHub token with Actions workflow dispatch permission.';
        }
        field(55; "Last Deploy Status"; Option)
        {
            Caption = 'Last Deploy Status';
            OptionMembers = None,Scheduled,Queued,Success,Failed;
            OptionCaption = 'None,Scheduled,Queued,Success,Failed';
            Editable = false;
            ToolTip = 'Latest deployment execution status.';
        }
        field(56; "Last Deploy Message"; Text[280])
        {
            Caption = 'Last Deploy Message';
            Editable = false;
            ToolTip = 'Latest deployment message or error details.';
        }
        field(57; "Last Deploy At"; DateTime)
        {
            Caption = 'Last Deploy At';
            Editable = false;
            ToolTip = 'Date/time of latest deployment execution.';
        }
        field(58; "Last Deploy Run URL"; Text[280])
        {
            Caption = 'Last Deploy Run URL';
            Editable = false;
            ToolTip = 'GitHub Actions URL related to the latest deployment dispatch.';
        }
        field(59; "Last Scheduled At"; DateTime)
        {
            Caption = 'Last Scheduled At';
            Editable = false;
            ToolTip = 'Date/time of latest scheduled deployment request.';
        }
    }
    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }
    trigger OnInsert()
    begin
        InitDefaultStatusMappings();
        if "No." = '' then "No." := CreateTemporarySetupNo();
    end;

    local procedure IsTemporaryNoCode(NoCode: Code[20]): Boolean
    begin
        exit((StrLen(NoCode) >= 3) and (UpperCase(CopyStr(NoCode, 1, 3)) = 'TMP'));
    end;

    local procedure CreateTemporarySetupNo(): Code[20]
    var
        Raw: Text;
    begin
        Raw := UpperCase(DelChr(Format(CreateGuid()), '=', '{}-'));
        exit(CopyStr('TMP' + CopyStr(Raw, 1, 17), 1, MaxStrLen("No.")));
    end;

    local procedure InitDefaultStatusMappings()
    begin
        "Send Approval When" := "WFDemo Status"::Open;
        "Cancel Approval When" := "WFDemo Status"::Pending;
        "On Open Document" := "WFDemo Status"::Open;
        "On Pending Document" := "WFDemo Status"::Pending;
        "On Approve Document" := "WFDemo Status"::Approved;
        "On Reject Document" := "WFDemo Status"::Rejected;
        "On Release Document" := "WFDemo Status"::Released;
    end;

    local procedure ApplyFinalNoFromSeriesIfTemporary()
    var
        NoSeriesMgt: Codeunit "No. Series";
        DemoSetup: Record "Workflow Demo Setup";
        NoSeriesRec: Record "No. Series";
        SeriesCode: Code[20];
        NewNo: Code[20];
    begin
        if not IsTemporaryNoCode("No.") then exit;
        SeriesCode := '';
        if DemoSetup.Get('SETUP') then SeriesCode := DemoSetup."Cust. Appr. WF Nos.";
        if SeriesCode = '' then SeriesCode := 'CUSTAPP';
        if not NoSeriesRec.Get(SeriesCode) then Error('No. Series %1 is missing. Create it in No. Series, or set Custom Approval WF Nos. on Workflow Demo Setup page.', SeriesCode);
        NewNo := NoSeriesMgt.GetNextNo(SeriesCode, WorkDate());
        "No." := NewNo;
    end;

    local procedure ResolveFieldNameFromMetadata(TableId: Integer; FieldId: Integer; var FieldNameOut: Text[30])
    var
        FieldRec: Record Field;
    begin
        Clear(FieldNameOut);
        if (TableId = 0) or (FieldId = 0) then exit;
        FieldRec.Reset();
        FieldRec.SetRange(TableNo, TableId);
        FieldRec.SetRange("No.", FieldId);
        if not FieldRec.FindFirst() then exit;
        FieldNameOut := CopyStr(FieldRec.FieldName, 1, MaxStrLen(FieldNameOut));
    end;

    local procedure ValidateStatusTransitions()
    begin
        // Ensure send and cancel statuses are different
        if ("Send Approval When" = "Cancel Approval When") and
           ("Send Approval When" <> "Send Approval When"::Open) then
            Error('Send Approval When and Cancel Approval When cannot be the same status.');

        // Ensure send status allows transition to pending
        if ("Send Approval When" = "On Pending Document") and
           ("Send Approval When" <> "Send Approval When"::Open) then
            Error('Send Approval When cannot be the same as On Pending Document status.');
    end;

    local procedure ValidateStatusMappings()
    begin
        // Ensure all status mappings are unique
        if ("On Open Document" <> "On Open Document"::Open) and
           (("On Open Document" = "On Pending Document") or
            ("On Open Document" = "On Approve Document") or
            ("On Open Document" = "On Reject Document") or
            ("On Open Document" = "On Release Document")) then
            Error('On Open Document status must be unique across all status mappings.');

        if ("On Pending Document" <> "On Pending Document"::Open) and
           (("On Pending Document" = "On Approve Document") or
            ("On Pending Document" = "On Reject Document") or
            ("On Pending Document" = "On Release Document")) then
            Error('On Pending Document status must be unique across all status mappings.');

        if ("On Approve Document" <> "On Approve Document"::Open) and
           (("On Approve Document" = "On Reject Document") or
            ("On Approve Document" = "On Release Document")) then
            Error('On Approve Document status must be unique across all status mappings.');

        if ("On Reject Document" <> "On Reject Document"::Open) and
           ("On Reject Document" = "On Release Document") then
            Error('On Reject Document status must be unique from On Release Document status.');
    end;
}
