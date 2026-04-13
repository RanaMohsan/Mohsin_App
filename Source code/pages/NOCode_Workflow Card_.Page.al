page 80221 "Mohsin NoCode Workflow Card"
{
    ApplicationArea = All;
    Caption = 'Mohsin NoCode Workflow Card';
    PageType = Card;
    SourceTable = "NoCode Workflow Header";

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Code"; Rec."Code")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Category Code"; Rec."Category Code")
                {
                    ApplicationArea = All;
                }
                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = All;
                }
            }
            group(Document)
            {
                Caption = 'Document';

                field("Document Table ID"; Rec."Document Table ID")
                {
                    ApplicationArea = All;
                }
                field("Card Page ID"; Rec."Card Page ID")
                {
                    ApplicationArea = All;
                }
                field("Status Field Name"; Rec."Status Field Name")
                {
                    ApplicationArea = All;
                }
            }
            group(StatusMapping)
            {
                Caption = 'Status Mapping';

                field("On Open Status"; Rec."On Open Status")
                {
                    ApplicationArea = All;
                }
                field("On Pending Status"; Rec."On Pending Status")
                {
                    ApplicationArea = All;
                }
                field("On Approved Status"; Rec."On Approved Status")
                {
                    ApplicationArea = All;
                }
                field("On Rejected Status"; Rec."On Rejected Status")
                {
                    ApplicationArea = All;
                }
            }
            part(WorkflowSteps; "Mohsin NoCode Workflow Steps")
            {
                ApplicationArea = All;
                SubPageLink = "Workflow Code" = field("Code");
            }
        }
    }
}