page 50502 "CHS Vendors 1099"
{
    ApplicationArea = All;
    Caption = 'CHS Vendors 1099';
    PageType = List;
    SourceTable = Vendor;
    UsageCategory = None;
    CardPageId = "CHS Vendor 1099 Card";
    Editable = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the Customer';
                }
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies the name of the customer.';
                }
                field("Federal ID No."; Rec."Federal ID No.")
                {
                    ToolTip = 'Specifies the Federal ID No. of the customer.';
                }
                field("IRS 1099 Code"; Rec."IRS 1099 Code")
                {
                    ToolTip = 'Specifies the IRS 1099 Code of the customer.';
                }
                field("Vendor Posting Group"; Rec."Vendor Posting Group")
                {
                    ToolTip = 'Specifies the Vendor Posting Group of the customer.';
                }
                field("CHS IRS 1099 Amount"; Rec."CHS IRS 1099 Amount")
                {
                    ToolTip = 'Specifies the IRS 1099 Amount of the customer.';
                }
                field("Invoice Amounts"; Rec."Invoice Amounts")
                {
                    ToolTip = 'Specifies the invoice amounts of the customer.';
                }
                field("Cr. Memo Amounts"; Rec."Cr. Memo Amounts")
                {
                    ToolTip = 'Specifies the credit memo amount of the customer.';
                }
                field(Payments; Rec.Payments)
                {
                    ToolTip = 'Specifies the payments of the customer.';
                }
                field(Refunds; Rec.Refunds)
                {
                    ToolTip = 'Specifies the refunds of the customer.';
                    Visible = false;
                }
                field(Balance; Rec.Balance)
                {
                    ToolTip = 'Specifies the balance of the customer.';
                }
                field("CHS Transactions"; Rec."CHS Transactions")
                {
                    ToolTip = 'Specifies the CHS Transactions of the customer.';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(CHSExportVendorLedgerEntries1099)
            {
                ApplicationArea = All;
                Caption = 'Export IRS 1099 Entries';
                ToolTip = 'Export Vendor Ledger Entries IRS 1099';
                Image = Export;


                trigger OnAction()
                begin
                    Report.Run(Report::"CHS VLE IRS 1099", true, false, Rec);
                end;
            }
            action(CHSFixVLEIRS1099)
            {
                ApplicationArea = All;
                Image = UpdateDescription;
                Caption = 'Fix IRS 1099 Entries';
                ToolTip = 'Fix Vendor Ledger Entries IRS 1099';

                trigger OnAction()
                begin
                    FixVLEIRS1099();
                end;
            }
        }
        area(Promoted)
        {
            group("Report")
            {
                actionref(CHSExportVendorLedgerEntries1099_Promoted; CHSExportVendorLedgerEntries1099) { }
                actionref(CHSFixVLEIRS1099_Promoted; CHSFixVLEIRS1099) { }
            }
        }
    }

    local procedure FixVLEIRS1099()
    var
        Vendor: Record Vendor;
        CHSFixVLE1099AmountReport: Report "CHS Fix VLE 1099 Amount";
    begin
        CHSFixVLE1099AmountReport.SetTableView(Rec);
        CHSFixVLE1099AmountReport.UseRequestPage(true);
        CHSFixVLE1099AmountReport.RunModal();
    end;
}
