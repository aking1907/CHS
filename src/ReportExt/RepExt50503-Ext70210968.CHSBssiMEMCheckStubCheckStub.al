reportextension 50503 "CHS BssiMEMCheckStubCheckStub" extends BssiMEMCheckStubCheckStub //70210968
{
    dataset
    {
        modify(GenJnlLine)
        {
            trigger OnAfterAfterGetRecord()
            begin
                VendorNo := '';
                if GenJnlLine."Account Type" = GenJnlLine."Account Type"::Vendor then
                    VendorNo := GenJnlLine."Account No.";
            end;
        }
        add(PrintCheck)
        {
            column(CHSVendorNo; VendorNo) { }
        }
    }
    rendering
    {
        layout("CHSBssiMEMCheckStubCheckStub.rdlc")
        {
            Type = RDLC;
            LayoutFile = './src/ReportExt/RDLC/RepExt50503-Ext70210968.CHSBssiMEMCheckStubCheckStub.rdlc';
            Caption = 'CHS BssiMEMCheckStubCheckStub (RDLC)';
        }
    }

    var
        VendorNo: Code[20];
}
