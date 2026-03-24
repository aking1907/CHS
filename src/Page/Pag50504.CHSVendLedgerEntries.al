page 50504 "CHS Vend. Ledger Entries"
{
    ApplicationArea = All;
    Caption = 'Vend. Ledger Entries';
    PageType = ListPart;
    SourceTable = "Vendor Ledger Entry";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    Editable = false;
                    ToolTip = 'Specifies the code for the global dimension that is linked to the record or entry for analysis purposes. Two global dimensions, typically for the company''s most important activities, are available on all cards, documents, reports, and lists.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    Editable = false;
                    ToolTip = 'Specifies the type of document.';
                }
                field("Document No."; Rec."Document No.")
                {
                    Editable = false;
                    ToolTip = 'Specifies the purchase document number.';
                }
                field("Document Date"; Rec."Document Date")
                {
                    Editable = false;
                    ToolTip = 'Specifies the vendor entry''s document date.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    Editable = false;
                    ToolTip = 'Specifies the vendor entry''s posting date.';
                }
                field(Description; Rec.Description)
                {
                    Editable = false;
                    ToolTip = 'Specifies a description of the vendor entry.';
                }
                field("IRS 1099 Code"; Rec."IRS 1099 Code")
                {
                    ToolTip = 'Specifies the amount for the 1099 code that the vendor entry is linked to.';
                }
                field("Vendor Posting Group"; Rec."Vendor Posting Group")
                {
                    ToolTip = 'Specifies the vendor''s market type to link business transactions to.';
                }
                field(Open; Rec.Open)
                {
                    Editable = false;
                    ToolTip = 'Specifies the open amount of the entry.';
                }
                field("IRS 1099 Amount"; Rec."IRS 1099 Amount")
                {
                    ToolTip = 'Specifies the amount for the 1099 code that the vendor entry is linked to.';
                }
                field(Amount; Rec.Amount)
                {
                    Editable = false;
                    ToolTip = 'Specifies the amount of the entry.';
                }
                field("Remaining Amount"; Rec."Remaining Amount")
                {
                    Editable = false;
                    ToolTip = 'Specifies the remaining amount of the entry.';
                }
                field("Applies-to Doc. No."; Rec."Applies-to Doc. No.")
                {
                    Editable = false;
                    ToolTip = 'Specifies the entry''s Applies-to Doc. No.';
                }
                field("Applies-to Doc. Type"; Rec."Applies-to Doc. Type")
                {
                    Editable = false;
                    ToolTip = 'Specifies the entry''s Applies-to Doc. Type.';
                }
                field("Applies-to Ext. Doc. No."; Rec."Applies-to Ext. Doc. No.")
                {
                    Editable = false;
                    ToolTip = 'Specifies the entry''s Applies-to Ext. Doc. No.';
                }
                field("External Document No."; Rec."External Document No.")
                {
                    Editable = false;
                    ToolTip = 'Specifies a document number that refers to the customer''s or vendor''s numbering system.';
                }
                field("Entry No."; Rec."Entry No.")
                {
                    Editable = false;
                    ToolTip = 'Specifies the number of the entry, as assigned from the specified number series when the entry was created.';
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the number of the vendor account that the entry is linked to.';
                }
                field("Vendor Name"; Rec."Vendor Name")
                {
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the name of the vendor account that the entry is linked to.';
                }
            }
        }
    }

    trigger OnModifyRecord(): Boolean
    begin
        CODEUNIT.Run(CODEUNIT::"Vend. Entry-Edit", Rec);
        exit(false);
    end;
}
