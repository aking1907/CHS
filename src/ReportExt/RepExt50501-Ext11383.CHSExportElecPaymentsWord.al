reportextension 50501 "CHS ExportElecPayments - Word" extends "ExportElecPayments - Word" //11383
{
    dataset
    {


        add("Gen. Journal Line")
        {
            column(CHS_GJL_PostingDate; Format("Posting Date", 0, '<Month,2>/<Day,2>/<Year4>')) { }
            column(CHS_GJL_RemittanceAmount; Format(Amount, 0, '<Precision,2:2><Sign><Integer Thousand><Decimals>')) { }
            column(CHS_CompanyPicture; CHSLegalEntity.BssiPicture) { }
            column(CHS_CompanyAddress1; CHSCompanyAddress[1]) { }
            column(CHS_CompanyAddress2; CHSCompanyAddress[2]) { }
            column(CHS_CompanyAddress3; CHSCompanyAddress[3]) { }
            column(CHS_CompanyAddress4; CHSCompanyAddress[4]) { }
            column(CHS_CompanyAddress5; CHSCompanyAddress[5]) { }
            column(CHS_CompanyAddress6; CHSCompanyAddress[6]) { }
            column(CHS_CompanyAddress7; CHSCompanyAddress[7]) { }
            column(CHS_CompanyAddress8; CHSCompanyAddress[8]) { }
            column(CHS_VendorAddress1; CHSVendorAddress[1]) { }
            column(CHS_VendorAddress2; CHSVendorAddress[2]) { }
            column(CHS_VendorAddress3; CHSVendorAddress[3]) { }
            column(CHS_VendorAddress4; CHSVendorAddress[4]) { }
            column(CHS_VendorAddress5; CHSVendorAddress[5]) { }
            column(CHS_VendorAddress6; CHSVendorAddress[6]) { }
            column(CHS_VendorAddress7; CHSVendorAddress[7]) { }
            column(CHS_VendorAddress8; CHSVendorAddress[8]) { }
        }

        add("Vendor Ledger Entry")
        {
            column(CHS_VLE_Description; Description) { }
            column(CHS_VLE_PostingDate; Format("Posting Date", 0, '<Month,2>/<Day,2>/<Year4>')) { }
            column(CHS_VLE_DocumentDate; Format("Document Date", 0, '<Month,2>/<Day,2>/<Year4>')) { }
            column(CHS_VLE_PaymentAmount; Format(Amount, 0, '<Precision,2:2><Sign><Integer Thousand><Decimals>')) { }
            column(CHS_VLE_DocumentAmount; Format("Closed by Amount", 0, '<Precision,2:2><Sign><Integer Thousand><Decimals>')) { }
            column(CHS_VLE_Dimension1Code; "Global Dimension 1 Code") { }
            column(CHS_VLE_DocumentType; "Document Type") { }
            column(CHS_VLE_DocumentNo; "External Document No.") { }
            column(CHS_VLE_TotalAmount; Format(CHSRemitenceTotalAmount, 0, '<Precision,2:2><Sign><Integer Thousand><Decimals>')) { }
            column(CHS_VLE_Count; "Vendor Ledger Entry".Count) { }

        }
        modify("Vendor Ledger Entry")
        {
            trigger OnAfterAfterGetRecord()
            begin
                "Vendor Ledger Entry".CalcFields("Remaining Amount");

                "Vendor Ledger Entry"."Closed by Amount" := -"Vendor Ledger Entry"."Remaining Amount";
                CHSRemitenceTotalAmount += "Vendor Ledger Entry"."Closed by Amount"
            end;
        }
        modify("Gen. Journal Line")
        {
            trigger OnAfterAfterGetRecord()
            begin
                CHSRemitenceTotalAmount := 0;

                FillCompanyAddressArray("Gen. Journal Line".BssiEntityID);
            end;
        }

    }

    rendering
    {
        layout("CHSExportElectronicPayments.rdlc")
        {
            Type = RDLC;
            LayoutFile = './src/ReportExt/RDLC/RepExt50501-Ext11383.CHSExportElecPaymentsWord.rdlc';
            Caption = 'CHS Export Electronic Payments (RDLC)';
        }
    }

    local procedure FillCompanyAddressArray(LegalEntityCode: Code[20])
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        Vendor: Record Vendor;
        RemitAddress: Record "Remit Address";
        i: Integer;
    begin
        if LegalEntityCode = '' then
            exit;

        Clear(CHSCompanyAddress);
        Clear(CHSLegalEntity);
        Clear(CHSVendorAddress);

        if Vendor.Get("Gen. Journal Line"."Account No.") then begin
            i := 1;

            CHSVendorAddress[i] := IncreaseCounterIfNotEmpty(i, Vendor.Name.Trim());
            CHSVendorAddress[i] := IncreaseCounterIfNotEmpty(i, Vendor.Address.Trim());
            CHSVendorAddress[i] := IncreaseCounterIfNotEmpty(i, Vendor."Address 2".Trim());
            CHSVendorAddress[i] := IncreaseCounterIfNotEmpty(i, Vendor.City.Trim() + ', ' + Vendor.County.Trim() + ' ' + Vendor."Post Code");
            CHSVendorAddress[i] := 'Vendor No.: ' + Vendor."No.";

            RemitAddress.SetRange("Vendor No.", Vendor."No.");
            RemitAddress.SetRange(Default, true);
            if RemitAddress.FindFirst() then begin
                Clear(CHSVendorAddress);
                i := 1;

                CHSVendorAddress[i] := IncreaseCounterIfNotEmpty(i, RemitAddress.Name.Trim());
                CHSVendorAddress[i] := IncreaseCounterIfNotEmpty(i, RemitAddress.Address.Trim());
                CHSVendorAddress[i] := IncreaseCounterIfNotEmpty(i, RemitAddress."Address 2".Trim());
                CHSVendorAddress[i] := IncreaseCounterIfNotEmpty(i, RemitAddress.City.Trim() + ', ' + RemitAddress.County.Trim() + ' ' + RemitAddress."Post Code");
                CHSVendorAddress[i] := 'Vendor No.: ' + Vendor."No.";
            end;
        end;

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
        CHSVendorAddress: array[8] of Text[100];
        CHSRemitenceTotalAmount: Decimal;
}
