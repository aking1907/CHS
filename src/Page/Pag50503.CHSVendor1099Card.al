page 50503 "CHS Vendor 1099 Card"
{
    ApplicationArea = All;
    Caption = 'CHS Vendor 1099';
    PageType = Card;
    SourceTable = Vendor;
    UsageCategory = None;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Editable = false;
                field("No."; Rec."No.")
                {
                    Editable = false;
                    ToolTip = 'Specifies the Customer';
                }
                field(Name; Rec.Name)
                {
                    Editable = false;
                    ToolTip = 'Specifies the name of the customer.';
                }
                field("Federal ID No."; Rec."Federal ID No.")
                {
                    Editable = false;
                    ToolTip = 'Specifies the Federal ID No. of the customer.';
                }
                field("IRS 1099 Code"; Rec."IRS 1099 Code")
                {
                    Editable = false;
                    ToolTip = 'Specifies the IRS 1099 Code of the customer.';
                }
                field("Vendor Posting Group"; Rec."Vendor Posting Group")
                {
                    Editable = false;
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
            }
            part("CHS Vend. Ledger Entries"; "CHS Vend. Ledger Entries")
            {
                SubPageLink = "Vendor No." = field("No.");
                UpdatePropagation = Both;
            }
        }
    }
}
