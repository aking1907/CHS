report 50501 "CHS Remittance Advice Entries"
{
    ApplicationArea = All;
    Caption = 'CHS Remittance Advice - Entries';
    UsageCategory = ReportsAndAnalysis;
    DefaultRenderingLayout = DefaultLayout;

    dataset
    {
        dataitem(Remitence; Dimension)
        {
            UseTemporary = true;
            DataItemTableView = sorting(Code) where(Code = filter(<> ''));

            column(RemitenceNo; Remitence.Code) { }
            column(VendorNo; Vendor."No.") { }
            column(Name; Name) { }
            column(VendorAddress1; VendorAddress[1]) { }
            column(VendorAddress2; VendorAddress[2]) { }
            column(VendorAddress3; VendorAddress[3]) { }
            column(VendorAddress4; VendorAddress[4]) { }
            column(VendorAddress5; VendorAddress[5]) { }
            column(VendorAddress6; VendorAddress[6]) { }
            column(VendorAddress7; VendorAddress[7]) { }
            column(VendorAddress8; VendorAddress[8]) { }
            column(CompanyCode; Code) { }
            column(CompanyPicture; TempCompany.BssiPicture) { }
            column(CompanyAddress1; CompanyAddress[1]) { }
            column(CompanyAddress2; CompanyAddress[2]) { }
            column(CompanyAddress3; CompanyAddress[3]) { }
            column(CompanyAddress4; CompanyAddress[4]) { }
            column(CompanyAddress5; CompanyAddress[5]) { }
            column(CompanyAddress6; CompanyAddress[6]) { }
            column(CompanyAddress7; CompanyAddress[7]) { }
            column(CompanyAddress8; CompanyAddress[8]) { }
            column(ACHDate; Format(ACHDate, 0, '<Month,2>/<Day,2>/<Year4>')) { }
            dataitem(VLE; "Vendor Ledger Entry")
            {
                DataItemLinkReference = Remitence;
                DataItemLink = "Document No." = field(Code);
                DataItemTableView = sorting("Entry No.") where("Entry No." = filter(> 0));
                UseTemporary = true;

                column(VLE_Description; VLE.Description) { }
                column(VLE_PostingDate; Format(VLE."Posting Date", 0, '<Month,2>/<Day,2>/<Year4>')) { }
                column(VLE_DocumentDate; Format(VLE."Document Date", 0, '<Month,2>/<Day,2>/<Year4>')) { }
                column(VLE_PaymentAmount; Format(VLE.Amount, 0, '<Precision,2:2><Sign><Integer Thousand><Decimals>')) { }
                column(VLE_DocumentAmount; Format(VLE."Closed by Amount", 0, '<Precision,2:2><Sign><Integer Thousand><Decimals>')) { }
                column(VLE_Dimension1Code; VLE."Global Dimension 1 Code") { }
                column(VLE_DocumentType; VLE."Applies-to Doc. Type") { }
                column(VLE_DocumentNo; VLE."Applies-to Ext. Doc. No.") { }
                column(VLE_TotalAmount; Format(RemitenceTotalAmount, 0, '<Precision,2:2><Sign><Integer Thousand><Decimals>')) { }


                trigger OnAfterGetRecord()
                var
                    VendLedgerEntry: Record "Vendor Ledger Entry";
                begin
                    VLE.CalcFields(Amount);
                    ACHDate := VLE."Document Date";

                    //update description
                    VendLedgerEntry.SetCurrentKey("External Document No.", "Document Type", "Vendor No.");
                    VendLedgerEntry.SetRange("External Document No.", VLE."Applies-to Ext. Doc. No.");
                    VendLedgerEntry.SetRange("Document Type", VLE."Applies-to Doc. Type");
                    VendLedgerEntry.SetRange("Vendor No.", VLE."Vendor No.");
                    if VendLedgerEntry.FindFirst() then begin
                        VendLedgerEntry.CalcFields(Amount);
                        VLE.Description := VendLedgerEntry.Description;
                        VLE."Posting Date" := VendLedgerEntry."Posting Date";
                        VLE."Document Date" := VendLedgerEntry."Document Date";
                        VLE."Closed by Amount" := -VendLedgerEntry.Amount;
                        RemitenceTotalAmount += VLE."Closed by Amount";
                    end;
                end;
            }
            trigger OnAfterGetRecord()
            var
                RemitAddress: Record "Remit Address";
                i: Integer;
            begin
                RemitenceTotalAmount := 0;
                Vendor.Get(Remitence."Map-to IC Dimension Code");

                Clear(VendorAddress);
                i := 1;

                VendorAddress[i] := IncreaseCounterIfNotEmpty(i, Vendor.Name.Trim());
                VendorAddress[i] := IncreaseCounterIfNotEmpty(i, Vendor.Address.Trim());
                VendorAddress[i] := IncreaseCounterIfNotEmpty(i, Vendor."Address 2".Trim());
                VendorAddress[i] := IncreaseCounterIfNotEmpty(i, Vendor.City.Trim() + ', ' + Vendor.County.Trim() + ' ' + Vendor."Post Code");
                VendorAddress[i] := 'Vendor No.: ' + Vendor."No.";

                RemitAddress.SetRange("Vendor No.", Vendor."No.");
                RemitAddress.SetRange(Default, true);
                if RemitAddress.FindFirst() then begin
                    Clear(VendorAddress);
                    i := 1;

                    VendorAddress[i] := IncreaseCounterIfNotEmpty(i, RemitAddress.Name.Trim());
                    VendorAddress[i] := IncreaseCounterIfNotEmpty(i, RemitAddress.Address.Trim());
                    VendorAddress[i] := IncreaseCounterIfNotEmpty(i, RemitAddress."Address 2".Trim());
                    VendorAddress[i] := IncreaseCounterIfNotEmpty(i, RemitAddress.City.Trim() + ', ' + RemitAddress.County.Trim() + ' ' + RemitAddress."Post Code");
                    VendorAddress[i] := 'Vendor No.: ' + Vendor."No.";
                end;

                TempCompany.SetRange(Code, Remitence."Consolidation Code");
                TempCompany.SetRange("Dimension Code", Remitence."Map-to IC Dimension Code");
                TempCompany.FindFirst();
                TempCompany.CalcFields(BssiPicture);
                FillCompanyAddressArray(TempCompany.Code);
            end;

            trigger OnPreDataItem()
            begin
                InitReportData();
            end;
        }

    }
    requestpage
    {
        layout
        {
            area(content)
            {
                group(Filetrs)
                {
                    Caption = 'Filters';
                    field(VendorNoFilter; GlobalFilterVendorNo)
                    {
                        Caption = 'Vendor No. Filter';
                        ToolTip = 'Specifies the Vendor No. Filter.';
                        ApplicationArea = All;
                    }
                    field(DateFromFilter; GlobalFilterDateFrom)
                    {
                        Caption = 'Date From';
                        ToolTip = 'Specifies the Date From Filter';
                        ApplicationArea = All;
                    }
                    field(DateToFilter; GlobalFilterDateTo)
                    {
                        Caption = 'Date To';
                        ToolTip = 'Specifies the Date To Filter';
                        ApplicationArea = All;
                    }
                    field(DocumentNoFilter; GlobalFilterDocumentNo)
                    {
                        Caption = 'Document No. Filter';
                        ToolTip = 'Specifies the Document No. Filter';
                        ApplicationArea = All;
                    }
                }
            }
        }
        actions
        {
            area(processing)
            {
            }
        }
    }

    rendering
    {
        layout(DefaultLayout)
        {
            Type = RDLC;
            LayoutFile = './src/Report/RDLC/Rep50501.CHSRemittanceAdviceEntries.rdlc';
            Caption = 'CHS Remittance Advice';
            Summary = 'RDLC Default Layout';
        }
    }

    trigger OnPreReport()
    begin
        GeneralLedgerSetup.Get();
    end;

    local procedure FillCompanyAddressArray(LegalEntityCode: Code[20])
    var
        LegalEntity: Record "Dimension Value";
        i: Integer;
    begin
        Clear(CompanyAddress);

        if Not LegalEntity.Get(GeneralLedgerSetup."Global Dimension 1 Code", LegalEntityCode) then
            exit;

        i := 1;
        CompanyAddress[i] := IncreaseCounterIfNotEmpty(i, LegalEntity.BssiLegalNameFull);
        CompanyAddress[i] := IncreaseCounterIfNotEmpty(i, LegalEntity.BssiBillingAddr1);
        CompanyAddress[i] := IncreaseCounterIfNotEmpty(i, LegalEntity.BssiBillingAddress2);
        CompanyAddress[i] := IncreaseCounterIfNotEmpty(i, LegalEntity.BssiBillingCity + ', ' + LegalEntity.BssiBillingState + ' ' + LegalEntity.BssiBillingZipCode);
        CompanyAddress[i] := IncreaseCounterIfNotEmpty(i, LegalEntity.BssiBillingCountry);
        CompanyAddress[i] := IncreaseCounterIfNotEmpty(i, LegalEntity.BssiBillingPhoneNumber);
    end;

    local procedure IncreaseCounterIfNotEmpty(var Counter: Integer; TextValue: Text[100]): Text[100]
    begin
        while (StrPos(TextValue, '  ') > 0) do
            TextValue := DelStr(TextValue, StrPos(TextValue, '  '), 1);

        TextValue := DelChr(TextValue, '<>', ',');

        if TextValue <> '' then Counter += 1;
        exit(TextValue);
    end;

    local procedure InitReportData()
    var
        VendLedgerEntry: Record "Vendor Ledger Entry";
        LegalEntity: Record "Dimension Value";
        InStream: InStream;
        OutSteream: OutStream;
    begin
        if not TempCompany.IsTemporary then Error('');
        if not VLE.IsTemporary then Error('');
        if not Remitence.IsTemporary then Error('');

        if (GlobalFilterVendorNo = '') and (GlobalFilterDateFrom = 0D) and (GlobalFilterDateTo = 0D) and (GlobalFilterDocumentNo = '') then
            Error('At least one filter must be populated!');

        VendLedgerEntry.SetFilter("Vendor No.", GlobalFilterVendorNo);
        if (GlobalFilterDateFrom <> 0D) or (GlobalFilterDateTo <> 0D) then
            if GlobalFilterDateTo = 0D then
                VendLedgerEntry.SetRange("Posting Date", GlobalFilterDateFrom)
            else
                if GlobalFilterDateFrom = 0D then
                    VendLedgerEntry.SetRange("Posting Date", GlobalFilterDateTo)
                else
                    VendLedgerEntry.SetRange("Posting Date", GlobalFilterDateFrom, GlobalFilterDateTo);

        VendLedgerEntry.SetFilter("Document No.", GlobalFilterDocumentNo);
        VendLedgerEntry.SetRange("Document Type", VendLedgerEntry."Document Type"::Payment);
        if VendLedgerEntry.FindSet() then
            repeat
                TempCompany."Dimension Code" := VendLedgerEntry."Vendor No.";
                TempCompany.Code := VendLedgerEntry."Bssi Paying Entity";
                if TempCompany.Insert() then
                    //copy logo
                    if LegalEntity.Get(GeneralLedgerSetup."Global Dimension 1 Code", TempCompany.Code) then begin
                        LegalEntity.CalcFields(BssiPicture);
                        if LegalEntity.BssiPicture.HasValue then begin
                            LegalEntity.BssiPicture.CreateInStream(InStream);
                            TempCompany.BssiPicture.CreateOutStream(OutSteream);
                            CopyStream(OutSteream, InStream);
                            TempCompany.Modify();
                        end;
                    end;


                VLE := VendLedgerEntry;
                VLE."IRS 1099 Amount" := 0;
                VLE.Insert();

                if not Remitence.Get(VLE."Document No.") then begin
                    Remitence.Code := VLE."Document No.";
                    Remitence."Consolidation Code" := TempCompany.Code;
                    Remitence."Map-to IC Dimension Code" := VendLedgerEntry."Vendor No.";
                    Remitence.Insert();
                end;
            until VendLedgerEntry.Next() = 0;
    end;

    procedure SetFilters(FilterVendorNo: Code[200]; FilterDateFrom: Date; FilterDateTo: Date; FilterDocumentNo: Code[200])
    begin

        GlobalFilterVendorNo := FilterVendorNo;
        GlobalFilterDateFrom := FilterDateFrom;
        GlobalFilterDateTo := FilterDateTo;
        GlobalFilterDocumentNo := FilterDocumentNo;
    end;

    var
        Vendor: Record Vendor;
        TempCompany: Record "Dimension Value" temporary;
        GeneralLedgerSetup: Record "General Ledger Setup";
        FormatAddr: Codeunit "Format Address";
        CompanyAddress: array[8] of Text[100];
        VendorAddress: array[8] of Text[100];
        ACHDate: Date;
        GlobalFilterVendorNo: Code[200];
        GlobalFilterDateFrom: Date;
        GlobalFilterDateTo: Date;
        GlobalFilterDocumentNo: Code[200];
        RemitenceTotalAmount: Decimal;

}
