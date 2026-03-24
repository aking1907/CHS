pageextension 50500 "CHS Vendor Ledger Entries" extends "Vendor Ledger Entries"
{
    layout
    {
        addlast(Control1)
        {
            field("CHS Applies-to Doc. Type"; Rec."Applies-to Doc. Type")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the entry''s Applies-to Doc. Type.';
            }
            field("CHS Applies-to Ext. Doc. No."; Rec."Applies-to Ext. Doc. No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the entry''s Applies-to Ext. Doc. No.';
            }
            field("CHS Applies-to Doc. No."; Rec."Applies-to Doc. No.")
            {
                ApplicationArea = All;
                Visible = false;
                ToolTip = 'Specifies the entry''s Applies-to Doc. No.';
            }
        }
        modify("Payment Method Code")
        {
            ApplicationArea = All;
        }
    }
    actions
    {
        addafter(BssiMEMcreatePayment)
        {
            action(CHSPrintRemitence)
            {
                Image = PrintDocument;
                ApplicationArea = All;
                Caption = 'CHS Remittance Advice';
                ToolTip = 'Print Remittance Advice document';
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Report;

                trigger OnAction()
                var
                    ReportCHSRemittanceAdviceEntries: Report "CHS Remittance Advice Entries";
                begin
                    Rec.TestField("Document Type", Rec."Document Type"::Payment);

                    ReportCHSRemittanceAdviceEntries.SetFilters(Rec."Vendor No.", Rec."Posting Date", Rec."Posting Date", Rec."Document No.");
                    ReportCHSRemittanceAdviceEntries.RunModal();
                end;
            }
        }
    }
}
