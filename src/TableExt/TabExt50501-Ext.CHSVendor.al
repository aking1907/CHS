tableextension 50501 "CHS Vendor" extends Vendor
{
    fields
    {
        field(50500; "CHS IRS 1099 Amount"; Decimal)
        {
            Caption = 'IRS 1099 Amount';
            FieldClass = FlowField;
            AutoFormatExpression = Rec."Currency Code";
            AutoFormatType = 1;
            Editable = false;
            CalcFormula = - sum("Vendor Ledger Entry"."IRS 1099 Amount" where("Vendor No." = field("No."),
                                                                           "Posting Date" = field("Date Filter"),
                                                                           "Currency Code" = field("Currency Filter")));
        }
        field(50501; "CHS Transactions"; Integer)
        {
            Caption = 'CHS Transactions';
            FieldClass = FlowField;
            CalcFormula = count("Vendor Ledger Entry" where("Vendor No." = field("No."),
                                                                 "Posting Date" = field("Date Filter"),
                                                                 "Currency Code" = field("Currency Filter")));
        }
    }
}