report 50503 "CHS VLE IRS 1099"
{
    ApplicationArea = All;
    Caption = 'CHS VLE IRS 1099';
    UsageCategory = None;
    DefaultRenderingLayout = DefaultExcelLayout;

    dataset
    {
        dataitem(TempVendor; Vendor)
        {
            UseTemporary = true;
            column(No; TempVendor."No.") { }
            column(Name; TempVendor.Name) { }
            column(VendorPostingGroup; TempVendor."Vendor Posting Group") { }
            column(CHSIRS1099Amount; TempVendor."CHS IRS 1099 Amount") { }
            column(InvoiceAmounts; TempVendor."Invoice Amounts") { }
            column(CrMemoAmounts; TempVendor."Cr. Memo Amounts") { }
            column(Payments; TempVendor.Payments) { }
            column(Refunds; TempVendor.Refunds) { }
            column(Balance; TempVendor.Balance) { }
            column(CHSTransactions; TempVendor."CHS Transactions") { }
            column(FederalIDNo; TempVendor."Federal ID No.") { }
            column(IRS1099Code; TempVendor."IRS 1099 Code") { }
            dataitem(TempVLE; "Vendor Ledger Entry")
            {
                UseTemporary = true;
                DataItemLinkReference = TempVendor;
                DataItemLink = "Vendor No." = field("No.");
                DataItemTableView = sorting("Entry No.");
                column(VLEIRS1099Code; TempVLE."IRS 1099 Code") { }
                column(CompanyCode; TempVLE."Global Dimension 1 Code") { }
                column(DocumentType; TempVLE."Document Type") { }
                column(DocumentNo; TempVLE."Document No.") { }
                column(DocumentDate; TempVLE."Document Date") { }
                column(PostingDate; TempVLE."Posting Date") { }
                column(Description; TempVLE.Description) { }
                column(VLEVendorPostingGroup; TempVLE."Vendor Posting Group") { }
                column(Open; TempVLE.Open) { }
                column(IRS1099Amount; TempVLE."IRS 1099 Amount") { }
                column(Amount; TempVLE.Amount) { }
                column(RemainingAmount; TempVLE."Remaining Amount") { }
                column(AppliestoDocNo; TempVLE."Applies-to Doc. No.") { }
                column(AppliestoDocType; TempVLE."Applies-to Doc. Type") { }
                column(AppliestoExtDocNo; TempVLE."Applies-to Ext. Doc. No.") { }
                column(ExternalDocumentNo; TempVLE."External Document No.") { }
                column(EntryNo; "Entry No.") { }
            }
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
            area(Content)
            {
                group(Params)
                {
                    field(GlobalPreProcessVLEData; GlobalPreProcessVLEData)
                    {
                        ApplicationArea = All;
                        Caption = 'Pre-Check IRS 1099';
                        ToolTip = 'Pre-Check vendor ledger enrties data for IRS 1099 entries';
                    }
                }
            }
        }
        actions
        {
            area(Processing)
            {
            }
        }
    }

    rendering
    {
        layout(DefaultExcelLayout)
        {
            Type = Excel;
            LayoutFile = './src/Report/Excel/Rep50503.CHSVLEIRS1099.xlsx';
            Caption = 'CHS VLE IRS 1099';
            Summary = 'Excel Default Layout';
        }
    }

    trigger OnInitReport()
    begin
        GlobalPreProcessVLEData := true;
    end;

    local procedure InitReportData()
    var
        Vendor: Record Vendor;
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        Vendor.CopyFilters(TempVendor);

        if Vendor.FindSet() then
            repeat
                TempVendor := Vendor;
                TempVendor.Insert();

                VendorLedgerEntry.Reset();
                VendorLedgerEntry.SetCurrentKey("Vendor No.", "Posting Date", "Currency Code");
                VendorLedgerEntry.SetRange("Vendor No.", Vendor."No.");
                VendorLedgerEntry.SetFilter("Posting Date", TempVendor.GetFilter("Date Filter"));
                if VendorLedgerEntry.FindSet() then
                    repeat
                        TempVLE := VendorLedgerEntry;
                        if GlobalPreProcessVLEData then begin
                            TempVLE.CalcFields(Amount);
                            if (TempVLE."IRS 1099 Code" = '') or (TempVLE."IRS 1099 Code" <> TempVendor."IRS 1099 Code") then
                                TempVLE.Insert()
                            else if TempVLE."Document Type" in [TempVLE."Document Type"::Invoice, TempVLE."Document Type"::"Credit Memo"]
                                    and (TempVLE."IRS 1099 Amount" <> TempVLE.Amount) then
                                TempVLE.Insert()
                            else if TempVLE."Document Type" in [TempVLE."Document Type"::Payment, TempVLE."Document Type"::Refund]
                                and (TempVLE."IRS 1099 Amount" <> 0) then
                                TempVLE.Insert()
                        end else
                            TempVLE.Insert();
                    until VendorLedgerEntry.Next = 0;

                TempVLE.Reset();
                TempVLE.SetRange("Vendor No.", Vendor."No.");
                if TempVLE.IsEmpty() then
                    TempVendor.Delete();
            until Vendor.Next = 0;
    end;

    var
        GlobalPreProcessVLEData: Boolean;
}
