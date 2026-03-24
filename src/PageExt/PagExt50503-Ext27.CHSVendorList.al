pageextension 50503 "CHS Vendor List" extends "Vendor List" //27
{
    layout
    {
        addafter("Shipment Method Code")
        {
            field("CHS Payment Method Code"; Rec."Payment Method Code")
            {
                ApplicationArea = All;
            }
        }
    }
    actions
    {
        addlast(History)
        {
            action(CHSVendors1099)
            {
                ApplicationArea = All;
                Caption = 'CHS Vendors 1099';
                ToolTip = 'Show CHS Vendors 1099';
                Image = Vendor;

                trigger OnAction()
                var
                    Vendor: Record Vendor;
                begin
                    Vendor.SetFilter("IRS 1099 Code", '<>%1', '');
                    Vendor.SetFilter("CHS Transactions", '<>%1', 0);
                    Vendor.SetRange("Date Filter", CalcDate('<-CY>', Today()), CalcDate('<CY>', Today()));
                    Page.Run(Page::"CHS Vendors 1099", Vendor);
                end;
            }
        }
        addafter(Quotes_Promoted)
        {
            actionref(CHSVendors1099_Promoted; CHSVendors1099) { }
        }
    }
}