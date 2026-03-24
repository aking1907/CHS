reportextension 50502 "CHS BssiMEMBankDeposit" extends BssiMEMBankDeposit //70211199
{
    dataset
    {
        add(VendApplication)
        {
            column(Number; Number) { }
        }
        add("Posted Bank Deposit Line")
        {

        }
    }
    rendering
    {
        layout("CHSBssiMEMBankDeposit.rdlc")

        {
            Type = RDLC;
            LayoutFile = './src/ReportExt/RDLC/RepExt50502-Ext70211199.CHSBssiMEMBankDeposit.rdlc';
            Caption = 'CHS BssiMEMBankDeposit (RDLC)';
        }
    }
}
