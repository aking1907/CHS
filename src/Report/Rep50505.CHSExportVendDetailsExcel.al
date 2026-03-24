report 50505 "CHS Export Vend. Details Excel"
{
    ApplicationArea = All;
    Caption = 'CHS Export Vendor Details Excel';
    UsageCategory = ReportsAndAnalysis;
    ProcessingOnly = true;

    dataset
    {
        dataitem(Vendor; Vendor)
        {
            RequestFilterFields = "No.", Name;

            trigger OnPreDataItem()
            begin
                TempExcelBuffer.Reset();
                TempExcelBuffer.DeleteAll();
                TempExcelBuffer.ClearNewRow();

                ExportCombinedInfo();
                ExportVendorInfo();
                ExportRemitAddress();
                ExportBankAccount();
                ExportReportSelection();

                OpenExcel();
                CurrReport.Skip();
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

    local procedure ExportCombinedInfo()
    var
        VendorLocal: Record Vendor;
        TempVLE: Record "Vendor Ledger Entry" temporary;
        RemitAddress: Record "Remit Address";
        BankAccount: Record "Vendor Bank Account";
        ReportSelection: Record "Custom Report Selection";
        i: Integer;
        RemitCount: Integer;
        BankCount: Integer;
        ReportCount: Integer;
        MaxRecordCount: Integer;
    begin
        if not TempVLE.IsTemporary then Error('');
        VendorLocal.Copy(Vendor);

        if VendorLocal.FindSet() then
            repeat
                RemitAddress.SetRange("Vendor No.", VendorLocal."No.");
                RemitCount := RemitAddress.Count();

                BankAccount.SetRange("Vendor No.", VendorLocal."No.");
                BankCount := BankAccount.Count();

                ReportSelection.SetRange("Source No.", VendorLocal."No.");
                ReportSelection.SetRange("Source Type", Database::Vendor);
                ReportCount := ReportSelection.Count();

                MaxRecordCount := 1;
                if RemitCount > MaxRecordCount then
                    MaxRecordCount := RemitCount;
                if BankCount > MaxRecordCount then
                    MaxRecordCount := BankCount;
                if ReportCount > MaxRecordCount then
                    MaxRecordCount := ReportCount;

                i += 1;
                TempVLE."Vendor No." := VendorLocal."No.";
                TempVLE."Transaction No." := MaxRecordCount;
                TempVLE."Entry No." := i;
                TempVLE.Insert();
            until VendorLocal.Next() = 0;

        //Headers
        TempExcelBuffer.NewRow();
        TempExcelBuffer.AddColumn('Vendor No', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Vendor Name', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Address', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Address 2', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('City', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('County', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Post Code', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Federal ID No.', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('IRS 1099 Code', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Vendor Posting Group', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Payment Terms Code', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Payment Method Code', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Preferred Bank Account Code', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Blocked', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);

        TempExcelBuffer.AddColumn('Remit Name', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Remit Address', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Remit Address 2', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Remit City', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Remit County', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Remit Post Code', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Remit Default', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);

        TempExcelBuffer.AddColumn('Bank Code', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Bank Account No.', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Transit No.', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);

        TempExcelBuffer.AddColumn('Report Usage', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Report ID', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Report Caption', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Email Body Layout Code', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Send To Email', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Use for Email Body', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Use for Email Attachment', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Email Body Layout Caption', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Custom Report Description', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Email Body Layout Description', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);

        VendorLocal.Reset();
        if TempVLE.FindSet() then
            repeat
                VendorLocal.Get(TempVLE."Vendor No.");
                for i := 1 to TempVLE."Transaction No." do begin
                    //Vendor Info
                    TempExcelBuffer.NewRow();
                    TempExcelBuffer.AddColumn(VendorLocal."No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn(VendorLocal.Name, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn(VendorLocal.Address, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn(VendorLocal."Address 2", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn(VendorLocal.City, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn(VendorLocal.County, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn(VendorLocal."Post Code", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn(VendorLocal."Federal ID No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn(VendorLocal."IRS 1099 Code", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn(VendorLocal."Vendor Posting Group", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn(VendorLocal."Payment Terms Code", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn(VendorLocal."Payment Method Code", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn(VendorLocal."Preferred Bank Account Code", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn(VendorLocal.Blocked, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

                    //Remit Address 
                    CleAR(RemitAddress);
                    RemitAddress.SetRange("Vendor No.", VendorLocal."No.");
                    GetRemitByNumber(RemitAddress, i);
                    TempExcelBuffer.AddColumn(RemitAddress.Name, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn(RemitAddress.Address, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn(RemitAddress."Address 2", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn(RemitAddress.City, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn(RemitAddress.County, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn(RemitAddress."Post Code", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn(RemitAddress.Default, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

                    //Bank Account
                    BankAccount.SetRange("Vendor No.", VendorLocal."No.");
                    GetBankByNumber(BankAccount, i);
                    TempExcelBuffer.AddColumn(BankAccount.Code, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn(BankAccount."Bank Account No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn(BankAccount."Transit No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

                    //Report Selection
                    ReportSelection.SetRange("Source No.", VendorLocal."No.");
                    ReportSelection.SetRange("Source Type", Database::Vendor);
                    GetReportByNumber(ReportSelection, i);
                    TempExcelBuffer.AddColumn(ReportSelection.Usage, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn(ReportSelection."Report ID", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn(ReportSelection."Report Caption", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn(ReportSelection."Email Body Layout Code", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn(ReportSelection."Send To Email", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn(ReportSelection."Use for Email Body", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn(ReportSelection."Use for Email Attachment", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn(ReportSelection."Email Body Layout Caption", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn(ReportSelection."Custom Report Description", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn(ReportSelection."Email Body Layout Description", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

                end;
            until TempVLE.Next() = 0;

        TempExcelBuffer.CreateNewBook('Combined Info');
        TempExcelBuffer.WriteSheet('Combined Info', CompanyName, UserId);

        TempExcelBuffer.SetColumnWidth('A', 12);
        TempExcelBuffer.SetColumnWidth('B', 30);
        TempExcelBuffer.SetColumnWidth('C', 30);
        TempExcelBuffer.SetColumnWidth('E', 15);
        TempExcelBuffer.SetColumnWidth('H', 15);
        TempExcelBuffer.SetColumnWidth('I', 15);
        TempExcelBuffer.SetColumnWidth('J', 15);
        TempExcelBuffer.SetColumnWidth('N', 15);
        TempExcelBuffer.SetColumnWidth('O', 30);
        TempExcelBuffer.SetColumnWidth('P', 30);
        TempExcelBuffer.SetColumnWidth('V', 15);
        TempExcelBuffer.SetColumnWidth('W', 15);
        TempExcelBuffer.SetColumnWidth('X', 15);
        TempExcelBuffer.SetColumnWidth('Y', 30);
        TempExcelBuffer.SetColumnWidth('Z', 30);
        TempExcelBuffer.SetColumnWidth('AA', 30);
        TempExcelBuffer.SetColumnWidth('AB', 30);
        TempExcelBuffer.SetColumnWidth('AC', 30);
        TempExcelBuffer.SetColumnWidth('AD', 30);
        TempExcelBuffer.SetColumnWidth('AE', 30);
        TempExcelBuffer.SetColumnWidth('AF', 30);
        TempExcelBuffer.SetColumnWidth('AG', 30);
        TempExcelBuffer.SetColumnWidth('AH', 30);

        TempExcelBuffer.DeleteAll();
        TempExcelBuffer.ClearNewRow();

    end;

    local procedure GetRemitByNumber(var RemitAddress: Record "Remit Address"; Number: Integer)
    var
        i: Integer;
    begin
        if RemitAddress.IsEmpty() or (Number < 1) then begin
            Clear(RemitAddress);
            exit;
        end;

        if RemitAddress.Count() < Number then begin
            Clear(RemitAddress);
            RemitAddress.Name := '#####';
            RemitAddress.Address := '#####';
            RemitAddress."Address 2" := '#####';
            RemitAddress.City := '#####';
            RemitAddress.County := '#####';
            RemitAddress."Post Code" := '#####';
            RemitAddress.Default := false;
            exit;
        end else
            if RemitAddress.FindSet() then
                repeat
                    i += 1;
                    if Number = i then
                        exit;
                until RemitAddress.Next() = 0;

        Clear(RemitAddress);
    end;

    local procedure GetBankByNumber(var BankAccount: Record "Vendor Bank Account"; Number: Integer)
    var
        i: Integer;
    begin
        if BankAccount.IsEmpty() or (Number < 1) then begin
            Clear(BankAccount);
            exit;
        end;

        if BankAccount.Count() < Number then begin
            Clear(BankAccount);
            BankAccount.Code := '#####';
            BankAccount."Bank Account No." := '#####';
            BankAccount."Transit No." := '#####';
            exit;
        end else
            if BankAccount.FindSet() then
                repeat
                    i += 1;
                    if Number = i then
                        exit;
                until BankAccount.Next() = 0;
        Clear(BankAccount);
    end;

    local procedure GetReportByNumber(var ReportSelection: Record "Custom Report Selection"; Number: Integer)
    var
        i: Integer;
    begin
        if ReportSelection.IsEmpty() or (Number < 1) then begin
            Clear(ReportSelection);
            exit;
        end;

        if ReportSelection.Count() < Number then begin
            Clear(ReportSelection);
            ReportSelection."Report Caption" := '#####';
            ReportSelection."Email Body Layout Code" := '#####';
            ReportSelection."Send To Email" := '#####';
            ReportSelection."Use for Email Body" := false;
            ReportSelection."Use for Email Attachment" := false;
            ReportSelection."Email Body Layout Caption" := '#####';
            ReportSelection."Custom Report Description" := '#####';
            ReportSelection."Email Body Layout Description" := '#####';
            exit;
        end else
            if ReportSelection.FindSet() then
                repeat
                    i += 1;
                    if Number = i then
                        exit;
                until ReportSelection.Next() = 0;

        Clear(ReportSelection);
    end;

    local procedure ExportVendorInfo()
    var
        VendorLocal: Record Vendor;
    begin
        VendorLocal.Copy(Vendor);

        TempExcelBuffer.NewRow();
        TempExcelBuffer.AddColumn('Vendor No', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Vendor Name', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Address', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Address 2', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('City', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('County', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Post Code', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Federal ID No.', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('IRS 1099 Code', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Vendor Posting Group', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Payment Terms Code', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Payment Method Code', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Preferred Bank Account Code', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Blocked', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);

        if VendorLocal.FindSet() then
            repeat
                TempExcelBuffer.NewRow();
                TempExcelBuffer.AddColumn(VendorLocal."No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(VendorLocal.Name, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(VendorLocal.Address, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(VendorLocal."Address 2", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(VendorLocal.City, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(VendorLocal.County, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(VendorLocal."Post Code", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(VendorLocal."Federal ID No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(VendorLocal."IRS 1099 Code", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(VendorLocal."Vendor Posting Group", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(VendorLocal."Payment Terms Code", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(VendorLocal."Payment Method Code", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(VendorLocal."Preferred Bank Account Code", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(VendorLocal.Blocked, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
            until VendorLocal.Next() = 0;

        // TempExcelBuffer.CreateNewBook('Vendor');
        TempExcelBuffer.SelectOrAddSheet('Vendor');
        TempExcelBuffer.WriteSheet('Vendor', CompanyName, UserId);

        TempExcelBuffer.SetColumnWidth('A', 12);
        TempExcelBuffer.SetColumnWidth('B', 30);
        TempExcelBuffer.SetColumnWidth('C', 30);
        TempExcelBuffer.SetColumnWidth('E', 15);
        TempExcelBuffer.SetColumnWidth('H', 15);
        TempExcelBuffer.SetColumnWidth('I', 15);
        TempExcelBuffer.SetColumnWidth('J', 15);
        TempExcelBuffer.SetColumnWidth('N', 15);

        TempExcelBuffer.DeleteAll();
        TempExcelBuffer.ClearNewRow();
    end;

    local procedure ExportRemitAddress()
    var
        VendorLocal: Record Vendor;
        RemitAddress: Record "Remit Address";

    begin
        VendorLocal.Copy(Vendor);

        TempExcelBuffer.NewRow();
        TempExcelBuffer.AddColumn('Vendor No', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Vendor Name', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);

        TempExcelBuffer.AddColumn('Remit Name', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Remit Address', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Remit Address 2', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Remit City', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Remit County', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Remit Post Code', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Remit Default', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);

        if VendorLocal.FindSet() then
            repeat
                RemitAddress.SetRange("Vendor No.", VendorLocal."No.");
                if RemitAddress.FindSet() then
                    repeat
                        TempExcelBuffer.NewRow();
                        TempExcelBuffer.AddColumn(VendorLocal."No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                        TempExcelBuffer.AddColumn(VendorLocal.Name, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

                        TempExcelBuffer.AddColumn(RemitAddress.Name, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                        TempExcelBuffer.AddColumn(RemitAddress.Address, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                        TempExcelBuffer.AddColumn(RemitAddress."Address 2", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                        TempExcelBuffer.AddColumn(RemitAddress.City, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                        TempExcelBuffer.AddColumn(RemitAddress.County, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                        TempExcelBuffer.AddColumn(RemitAddress."Post Code", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                        TempExcelBuffer.AddColumn(RemitAddress.Default, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    until VendorLocal.Next() = 0
                else begin
                    TempExcelBuffer.NewRow();
                    TempExcelBuffer.AddColumn(VendorLocal."No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn(VendorLocal.Name, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                end;
            until VendorLocal.Next() = 0;

        TempExcelBuffer.SelectOrAddSheet('Remit');
        TempExcelBuffer.WriteSheet('Remit', CompanyName, UserId);

        TempExcelBuffer.SetColumnWidth('A', 12);
        TempExcelBuffer.SetColumnWidth('B', 30);
        TempExcelBuffer.SetColumnWidth('C', 30);
        TempExcelBuffer.SetColumnWidth('E', 30);
        TempExcelBuffer.SetColumnWidth('F', 15);
        TempExcelBuffer.SetColumnWidth('J', 15);
        TempExcelBuffer.SetColumnWidth('H', 15);
        TempExcelBuffer.SetColumnWidth('I', 15);

        TempExcelBuffer.DeleteAll();
        TempExcelBuffer.ClearNewRow();
    end;

    local procedure ExportBankAccount()
    var
        VendorLocal: Record Vendor;
        BankAccount: Record "Vendor Bank Account";
    begin
        VendorLocal.Copy(Vendor);

        TempExcelBuffer.NewRow();
        TempExcelBuffer.AddColumn('Vendor No', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Vendor Name', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);

        TempExcelBuffer.AddColumn('Bank Code', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Bank Account No.', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Transit No.', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);

        if VendorLocal.FindSet() then
            repeat
                BankAccount.SetRange("Vendor No.", VendorLocal."No.");
                if BankAccount.FindSet() then
                    repeat
                        TempExcelBuffer.NewRow();
                        TempExcelBuffer.AddColumn(VendorLocal."No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                        TempExcelBuffer.AddColumn(VendorLocal.Name, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

                        TempExcelBuffer.AddColumn(BankAccount.Code, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                        TempExcelBuffer.AddColumn(BankAccount."Bank Account No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                        TempExcelBuffer.AddColumn(BankAccount."Transit No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    until VendorLocal.Next() = 0
                else begin
                    TempExcelBuffer.NewRow();
                    TempExcelBuffer.AddColumn(VendorLocal."No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn(VendorLocal.Name, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                end;
            until VendorLocal.Next() = 0;

        TempExcelBuffer.SelectOrAddSheet('Bank');
        TempExcelBuffer.WriteSheet('Bank', CompanyName, UserId);

        TempExcelBuffer.SetColumnWidth('A', 12);
        TempExcelBuffer.SetColumnWidth('B', 30);
        TempExcelBuffer.SetColumnWidth('C', 15);
        TempExcelBuffer.SetColumnWidth('D', 15);
        TempExcelBuffer.SetColumnWidth('E', 15);

        TempExcelBuffer.DeleteAll();
        TempExcelBuffer.ClearNewRow();
    end;

    local procedure ExportReportSelection()
    var
        VendorLocal: Record Vendor;
        ReportSelection: Record "Custom Report Selection";
    begin
        VendorLocal.Copy(Vendor);

        TempExcelBuffer.NewRow();
        TempExcelBuffer.AddColumn('Vendor No', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Vendor Name', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);

        TempExcelBuffer.AddColumn('Report Usage', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Report ID', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Report Caption', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Email Body Layout Code', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Send To Email', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Use for Email Body', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Use for Email Attachment', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Email Body Layout Caption', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Custom Report Description', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Email Body Layout Description', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);

        if VendorLocal.FindSet() then
            repeat
                ReportSelection.SetRange("Source No.", VendorLocal."No.");
                ReportSelection.SetRange("Source Type", Database::Vendor);
                if ReportSelection.FindSet() then
                    repeat
                        TempExcelBuffer.NewRow();
                        TempExcelBuffer.AddColumn(VendorLocal."No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                        TempExcelBuffer.AddColumn(VendorLocal.Name, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

                        TempExcelBuffer.AddColumn(ReportSelection.Usage, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                        TempExcelBuffer.AddColumn(ReportSelection."Report ID", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                        TempExcelBuffer.AddColumn(ReportSelection."Report Caption", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                        TempExcelBuffer.AddColumn(ReportSelection."Email Body Layout Code", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                        TempExcelBuffer.AddColumn(ReportSelection."Send To Email", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                        TempExcelBuffer.AddColumn(ReportSelection."Use for Email Body", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                        TempExcelBuffer.AddColumn(ReportSelection."Use for Email Attachment", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                        TempExcelBuffer.AddColumn(ReportSelection."Email Body Layout Caption", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                        TempExcelBuffer.AddColumn(ReportSelection."Custom Report Description", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                        TempExcelBuffer.AddColumn(ReportSelection."Email Body Layout Description", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    until VendorLocal.Next() = 0
                else begin
                    TempExcelBuffer.NewRow();
                    TempExcelBuffer.AddColumn(VendorLocal."No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn(VendorLocal.Name, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                end;
            until VendorLocal.Next() = 0;

        TempExcelBuffer.SelectOrAddSheet('Report Selection');
        TempExcelBuffer.WriteSheet('Report Selection', CompanyName, UserId);

        TempExcelBuffer.SetColumnWidth('A', 12);
        TempExcelBuffer.SetColumnWidth('B', 30);
        TempExcelBuffer.SetColumnWidth('E', 30);
        TempExcelBuffer.SetColumnWidth('F', 30);
        TempExcelBuffer.SetColumnWidth('G', 30);
        TempExcelBuffer.SetColumnWidth('H', 30);
        TempExcelBuffer.SetColumnWidth('I', 30);
        TempExcelBuffer.SetColumnWidth('J', 30);
        TempExcelBuffer.SetColumnWidth('K', 30);
        TempExcelBuffer.SetColumnWidth('L', 30);

        TempExcelBuffer.DeleteAll();
        TempExcelBuffer.ClearNewRow();
    end;

    local procedure CreateNewSheet(SheetName: Text; CreateBook: Boolean)
    begin
        if CreateBook then
            TempExcelBuffer.CreateNewBook(SheetName)
        else
            TempExcelBuffer.SelectOrAddSheet(SheetName);

        TempExcelBuffer.WriteSheet(SheetName, CompanyName, UserId);
        TempExcelBuffer.DeleteAll();
        TempExcelBuffer.ClearNewRow();
    end;

    local procedure OpenExcel()
    begin
        TempExcelBuffer.CloseBook();
        TempExcelBuffer.SetFriendlyFilename(StrSubstNo('VendorInfo_%1_%2', CurrentDateTime, UserId));
        TempExcelBuffer.OpenExcel();
    end;

    var
        TempExcelBuffer: Record "Excel Buffer" temporary;

}
