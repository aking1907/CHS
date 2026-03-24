report 50504 "CHS Fix VLE 1099 Amount"
{
    Caption = 'CHS Fix VLE 1099 Amount';
    DefaultLayout = Excel;
    ExcelLayout = './src/Report/Excel/Rep50504.CHSFixVLE1099Amount.xlsx';

    dataset
    {
        dataitem(TempVendor; Vendor)
        {
            UseTemporary = true;
            column(No; TempVendor."No.") { }
            column(Name; TempVendor.Name) { }
            dataitem(TempVLE; "Vendor Ledger Entry")
            {
                UseTemporary = true;
                DataItemLinkReference = TempVendor;
                DataItemLink = "Vendor No." = field("No.");
                DataItemTableView = sorting("Entry No.");
                column(DocumentType; TempVLE."Document Type") { }
                column(DocumentNo; TempVLE."Document No.") { }
                column(PostingDate; TempVLE."Posting Date") { }
                column(EntryNo; TempVLE."Entry No.") { }
                column(OldVLEIRS1099Code; TempVLE."Reason Code") { }
                column(NewVLEIRS1099Code; TempVLE."IRS 1099 Code") { }
                column(OldIRS1099Amount; TempVLE."Closed by Amount") { }
                column(NewIRS1099Amount; TempVLE."IRS 1099 Amount") { }
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
                group(GroupName)
                {
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

    local procedure InitReportData()
    var
        Vendor: Record Vendor;
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        Counter: Integer;
        IsInsert: Boolean;
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
                        IsInsert := false;
                        TempVLE := VendorLedgerEntry;
                        TempVLE.CalcFields(Amount);

                        TempVLE."Reason Code" := TempVLE."IRS 1099 Code";
                        if (TempVLE."IRS 1099 Code" = '') then begin
                            IsInsert := true;
                            TempVLE."IRS 1099 Code" := TempVendor."IRS 1099 Code";

                            VendorLedgerEntry."IRS 1099 Code" := Vendor."IRS 1099 Code";
                        end;

                        TempVLE."Closed by Amount" := TempVLE."IRS 1099 Amount";
                        if TempVLE."Document Type" in [TempVLE."Document Type"::Invoice, TempVLE."Document Type"::"Credit Memo"]
                                and (TempVLE."IRS 1099 Amount" <> TempVLE.Amount) then begin
                            IsInsert := true;

                            TempVLE."IRS 1099 Amount" := TempVLE.Amount;

                            VendorLedgerEntry."IRS 1099 Amount" := TempVLE.Amount;
                        end;

                        if TempVLE."Document Type" in [TempVLE."Document Type"::Payment, TempVLE."Document Type"::Refund]
                            and (TempVLE."IRS 1099 Amount" <> 0) then begin
                            IsInsert := true;

                            TempVLE."IRS 1099 Amount" := 0;

                            VendorLedgerEntry."IRS 1099 Amount" := 0;
                        end;

                        if IsInsert then begin
                            Codeunit.Run(Codeunit::"Vend. Entry-Edit", VendorLedgerEntry);
                            TempVLE.Insert();
                            Counter += 1;

                            if Counter > 1000 then begin
                                Commit();
                                Counter := 0;
                            end;
                        end;

                    until VendorLedgerEntry.Next = 0;

                TempVLE.Reset();
                TempVLE.SetRange("Vendor No.", Vendor."No.");
                if TempVLE.IsEmpty() then
                    TempVendor.Delete();
            until Vendor.Next = 0;
    end;

}
