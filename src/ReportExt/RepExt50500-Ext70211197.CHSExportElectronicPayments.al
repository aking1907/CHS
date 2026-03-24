reportextension 50500 "CHS Export Electronic Payments" extends BssiMEMExportElecPaymentsLine //70211197// "ExportElecPayments - Word" //11383
{
    dataset
    {


        add("Gen. Journal Line")
        {
            column(CHS_GJL_PostingDate; Format("Gen. Journal Line"."Posting Date", 0, '<Month,2>/<Day,2>/<Year4>')) { }
            column(CHS_GJL_RemittanceAmount; Format("Gen. Journal Line".Amount, 0, '<Precision,2:2><Sign><Integer Thousand><Decimals>')) { }
        }

        add("Vendor Ledger Entry")
        {
            column(CHS_VLE_Description; Description) { }
            column(CHS_VLE_PostingDate; Format("Vendor Ledger Entry"."Posting Date", 0, '<Month,2>/<Day,2>/<Year4>')) { }
            column(CHS_VLE_DocumentDate; Format("Document Date", 0, '<Month,2>/<Day,2>/<Year4>')) { }
            column(CHS_VLE_PaymentAmount; Format(Amount, 0, '<Precision,2:2><Sign><Integer Thousand><Decimals>')) { }
            column(CHS_VLE_DocumentAmount; Format("Closed by Amount", 0, '<Precision,2:2><Sign><Integer Thousand><Decimals>')) { }
            column(CHS_VLE_Dimension1Code; "Global Dimension 1 Code") { }
            column(CHS_VLE_DocumentType; "Document Type") { }
            column(CHS_VLE_DocumentNo; "Document No.") { }
            column(CHS_VLE_TotalAmount; Format(CHSRemitenceTotalAmount, 0, '<Precision,2:2><Sign><Integer Thousand><Decimals>')) { }
            column(CHS_VLE_Count; "Vendor Ledger Entry".Count) { }

        }
        modify("Vendor Ledger Entry")
        {
            trigger OnAfterAfterGetRecord()
            begin
                "Vendor Ledger Entry".CalcFields(Amount);

                "Vendor Ledger Entry"."Closed by Amount" := Abs("Vendor Ledger Entry".Amount);
                CHSRemitenceTotalAmount += "Vendor Ledger Entry"."Closed by Amount"
            end;
        }
        modify(BssiMEMEntityLoopTemp)
        {
            trigger OnAfterAfterGetRecord()
            begin
                CHSRemitenceTotalAmount := 0;

                FillCompanyAddressArray("Gen. Journal Line".BssiEntityID);
            end;
        }

        add(BssiMEMEntityLoopTemp)
        {
            column(CHS_CompanyPicture; CHSLegalEntity.BssiPicture) { }
            column(CHS_CompanyAddress1; CHSCompanyAddress[1]) { }
            column(CHS_CompanyAddress2; CHSCompanyAddress[2]) { }
            column(CHS_CompanyAddress3; CHSCompanyAddress[3]) { }
            column(CHS_CompanyAddress4; CHSCompanyAddress[4]) { }
            column(CHS_CompanyAddress5; CHSCompanyAddress[5]) { }
            column(CHS_CompanyAddress6; CHSCompanyAddress[6]) { }
            column(CHS_CompanyAddress7; CHSCompanyAddress[7]) { }
            column(CHS_CompanyAddress8; CHSCompanyAddress[8]) { }
        }
    }

    rendering
    {
        layout("CHSExportElectronicPayments.rdlc")
        {
            Type = RDLC;
            LayoutFile = './src/ReportExt/RDLC/RepExt50500-Ext70210897.CHSExportElectronicPayments.rdlc';
            Caption = 'CHS Export Electronic Payments (RDLC)';
        }
    }

    local procedure FillCompanyAddressArray(LegalEntityCode: Code[20])
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        i: Integer;
    begin
        if LegalEntityCode = '' then
            exit;

        Clear(CHSCompanyAddress);
        Clear(CHSLegalEntity);

        GeneralLedgerSetup.Get();
        if Not CHSLegalEntity.Get(GeneralLedgerSetup."Global Dimension 1 Code", LegalEntityCode) then
            exit;

        i := 1;
        CHSCompanyAddress[i] := IncreaseCounterIfNotEmpty(i, CHSLegalEntity.BssiLegalNameFull);
        CHSCompanyAddress[i] := IncreaseCounterIfNotEmpty(i, CHSLegalEntity.BssiBillingAddr1);
        CHSCompanyAddress[i] := IncreaseCounterIfNotEmpty(i, CHSLegalEntity.BssiBillingAddress2);
        CHSCompanyAddress[i] := IncreaseCounterIfNotEmpty(i, CHSLegalEntity.BssiBillingCity + ', ' + CHSLegalEntity.BssiBillingState + ' ' + CHSLegalEntity.BssiBillingZipCode);
        CHSCompanyAddress[i] := IncreaseCounterIfNotEmpty(i, CHSLegalEntity.BssiBillingCountry);
        CHSCompanyAddress[i] := IncreaseCounterIfNotEmpty(i, CHSLegalEntity.BssiBillingPhoneNumber);

        CHSLegalEntity.CalcFields(BssiPicture);
    end;

    local procedure IncreaseCounterIfNotEmpty(var Counter: Integer; TextValue: Text[100]): Text[100]
    begin
        while (StrPos(TextValue, '  ') > 0) do
            TextValue := DelStr(TextValue, StrPos(TextValue, '  '), 1);

        TextValue := DelChr(TextValue, '<>', ',');

        if TextValue <> '' then Counter += 1;
        exit(TextValue);
    end;

    var
        CHSLegalEntity: Record "Dimension Value";
        CHSCompanyAddress: array[8] of Text[100];
        CHSRemitenceTotalAmount: Decimal;
}
