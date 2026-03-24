reportextension 50504 "CHS Vendor - Payment Receipt" extends "Vendor - Payment Receipt" //411
{
    dataset
    {
        add(PageLoop)
        {
            column(CHSPaymentMethodCode_VendLedgEntry; "Vendor Ledger Entry"."Payment Method Code") { }
        }
    }
    rendering
    {
        layout("CHSVendorPaymentReceipt.rdlc")
        {
            Type = RDLC;
            LayoutFile = './src/ReportExt/RDLC/RepExt50504-Ext411.CHSVendorPaymentReceipt.rdlc';
            Caption = 'CHS Vendor - Payment Receipt (RDLC)';
        }
    }
}
