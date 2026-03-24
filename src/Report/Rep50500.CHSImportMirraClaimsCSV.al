report 50500 "CHS Import Mirra Claims CSV"
{
    ProcessingOnly = true;

    requestpage
    {
        layout
        {
            area(content)
            {
                field(ServerFileName; CSVServerFileName)
                {
                    ApplicationArea = All;
                    Caption = 'File Name';
                    ToolTip = 'Specifies the File Name field.';

                    trigger OnAssistEdit()
                    var
                        InStream: InStream;
                    begin
                        CSVBufferTemp.Reset();
                        if not CSVBufferTemp.IsEmpty() then
                            CSVBufferTemp.DeleteAll();

                        if UploadIntoStream(UploadMsg, '', 'CSV Files (*.csv)|*.csv', CSVServerFileName, InStream) then
                            CSVBufferTemp.LoadDataFromStream(InStream, ',');
                    end;
                }

                field(JnlTemplateName; GlobalGenJnlLineTemp."Journal Template Name")
                {
                    ApplicationArea = All;
                    Caption = 'Journal Template Name';
                    ToolTip = 'Specifies the Journal Template Name field.';
                    TableRelation = "Gen. Journal Template";
                    Editable = not JnlTemplateNameNotEditable;

                    trigger OnValidate()
                    begin
                        GlobalGenJnlLineTemp."Journal Batch Name" := '';
                    end;
                }
                field(JnlTemplateBatch; GlobalGenJnlLineTemp."Journal Batch Name")
                {
                    ApplicationArea = All;
                    Caption = 'Journal Batch Name';
                    ToolTip = 'Specifies the Journal Batch Name field.';
                    TableRelation = "Gen. Journal Batch".Name;
                    Editable = not JnlTemplateBatchNotEditable;
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        GenJnlBatch: Record "Gen. Journal Batch";
                        JnlBatchListPage: Page "General Journal Batches";
                    begin
                        GenJnlBatch.SetRange("Journal Template Name", GlobalGenJnlLineTemp."Journal Template Name");
                        JnlBatchListPage.LookupMode(true);
                        JnlBatchListPage.SetTableView(GenJnlBatch);
                        if JnlBatchListPage.RunModal() <> Action::LookupOK then
                            exit;

                        JnlBatchListPage.GetRecord(GenJnlBatch);
                        GlobalGenJnlLineTemp."Journal Batch Name" := GenJnlBatch.Name;
                    end;
                }
                field(CompanyCode; GlobalGenJnlLineTemp.BssiEntityID)
                {
                    ApplicationArea = All;
                    Caption = 'Company Code';
                    ToolTip = 'Specifies the Company Code field.';
                    TableRelation = "Dimension Value".Code where("Dimension Code" = const('COMPANY'));
                    Editable = not CompanyCodeNotEditable;
                }
                field(PostingDate; GlobalGenJnlLineTemp."Posting Date")
                {
                    ApplicationArea = All;
                    Caption = 'Posting Date';
                    ToolTip = 'Specifies the Posting Date field.';
                }
                field(BankAccount; GlobalGenJnlLineTemp."Bal. Account No.")
                {
                    ApplicationArea = All;
                    Caption = 'Bank Account';
                    ToolTip = 'Specifies the Posting Date field.';
                }
                field(DeleteJnlLines; DeleteJnlLines)
                {
                    ApplicationArea = All;
                    Caption = 'Delete Jnl. Lines';
                    ToolTip = 'Specifies the Delete Jnl. Lines field.';
                }
                // field(PostJnlBatch; GlobalPostJnlBatch)
                // {
                //     ApplicationArea = All;
                //     Caption = 'Post Jnl. Batch';
                //     ToolTip = 'Specifies the Post Jnl. Batch field.';
                // }

            }
        }
        actions
        {
            area(processing)
            {
            }
        }
    }

    trigger OnInitReport()
    var
        CHSGeneralApplicationSetup: Record "CHS General Application Setup";
    begin
        CHSGeneralApplicationSetup.Get();
        GlobalGenJnlLineTemp."Journal Template Name" := CHSGeneralApplicationSetup."Mirra Claims Jnl. Tmpl. Name";
        GlobalGenJnlLineTemp."Journal Batch Name" := CHSGeneralApplicationSetup."Mirra Claims Jnl. Batch. Name";
        GlobalGenJnlLineTemp."Posting Date" := Today();
        GlobalGenJnlLineTemp.BssiEntityID := CHSGeneralApplicationSetup."Mirra Claims Company Code";
        GlobalGenJnlLineTemp."Bal. Account Type" := GlobalGenJnlLineTemp."Bal. Account Type"::"Bank Account";
        GlobalGenJnlLineTemp."Bal. Account No." := CHSGeneralApplicationSetup."Mirra Claims Bank Account";
    end;

    trigger OnPreReport()
    begin
        if CSVServerFileName = '' then
            Error('File has not been found!');

        ImportDataFromCSV();
    end;

    trigger OnPostReport()
    begin
        if GlobalPostJnlBatch then
            PostJnlBatch()
        else
            Message('File import completed!');
    end;

    local procedure ImportDataFromCSV()
    var
        GenJnlLine: Record "Gen. Journal Line";
        GenJnlLineDocTmp: Record "Gen. Journal Line" temporary;
        GenJnlLineCMTmp: Record "Gen. Journal Line" temporary;
        GenJnlLinePayTmp: Record "Gen. Journal Line" temporary;
        AppliedDocTmp: Record "Default Dimension" temporary;
        GenJnlTemplate: Record "Gen. Journal Template";
        LineNo: Integer;
        DecimalVar: Decimal;
        DateVar: Date;
        LineDescription: Text[100];
        DocumentNo: Text[20];
        ClaimMo: Text[50];
        Processed: Boolean;
    begin
        GenJnlTemplate.Get(GlobalGenJnlLineTemp."Journal Template Name");

        GlobalGenJnlLineTemp.TestField("Journal Template Name");
        GlobalGenJnlLineTemp.TestField("Journal Batch Name");
        GlobalGenJnlLineTemp.TestField(BssiEntityID);


        GenJnlLine.SetRange("Journal Template Name", GlobalGenJnlLineTemp."Journal Template Name");
        GenJnlLine.SetRange("Journal Batch Name", GlobalGenJnlLineTemp."Journal Batch Name");
        GenJnlLine.SetRange(BssiEntityID, GlobalGenJnlLineTemp.BssiEntityID);
        if not GenJnlLine.IsEmpty then
            if DeleteJnlLines then
                GenJnlLine.DeleteAll()
            else
                Error(GenJnlNotEmptyMsg);


        GenJnlLineDocTmp.Reset();
        for LineNo := 1 to CSVBufferTemp.GetNumberOfLines() do begin
            if GetValueAtCell(LineNo, 1) = 'Document' then begin
                Processed := true;

                Clear(GenJnlLineDocTmp);
                LineDescription := '';
                Clear(GenJnlLineDocTmp);
                GenJnlLineDocTmp.Init();
                GenJnlLineDocTmp.Validate("Journal Template Name", GlobalGenJnlLineTemp."Journal Template Name");
                GenJnlLineDocTmp.Validate("Journal Batch Name", GlobalGenJnlLineTemp."Journal Batch Name");
                GenJnlLineDocTmp.Validate("Source Code", GenJnlTemplate."Source Code");
                GenJnlLineDocTmp."Line No." := LineNo;
                GenJnlLineDocTmp.Validate("Account Type", GenJnlLineDocTmp."Account Type"::Vendor);
                GenJnlLineDocTmp.Validate("Account No.", GetValueAtCell(LineNo, 3));
                GenJnlLineDocTmp.Comment := GenJnlLineDocTmp.Description;
                GenJnlLineDocTmp.Validate("Posting Date", GlobalGenJnlLineTemp."Posting Date");
                GenJnlLineDocTmp.Validate("Document Type", GenJnlLineDocTmp."Document Type"::Invoice);
                GenJnlLineDocTmp.Validate("Document No.", GetDocumentNo(LineNo, GenJnlLineDocTmp."Posting Date"));
                ClaimMo := GetValueAtCell(LineNo, 15);
                LineDescription := GetValueAtCell(LineNo, 8) + ' - ' + ClaimMo;
                LineDescription := CopyStr(LineDescription, 1, MaxStrLen(GenJnlLineDocTmp.Description));
                GenJnlLineDocTmp.Validate(Description, LineDescription);
                Evaluate(DecimalVar, GetValueAtCell(LineNo, 11));
                if DecimalVar < 0 then
                    GenJnlLineDocTmp.Validate("Document Type", GenJnlLineDocTmp."Document Type"::"Credit Memo");
                GenJnlLineDocTmp.Validate(Amount, -DecimalVar);
                GenJnlLineDocTmp.Validate("Shortcut Dimension 1 Code", GetValueAtCell(LineNo, 12));
                GenJnlLineDocTmp.Validate("Shortcut Dimension 2 Code", FormatDivmValue(GetValueAtCell(LineNo, 14)));
                Evaluate(DateVar, GetValueAtCell(LineNo, 7));
                GenJnlLineDocTmp.Validate("Document Date", DateVar);
                GenJnlLineDocTmp.Validate("External Document No.", GetValueAtCell(LineNo, 6) + '-' + ClaimMo);
                GenJnlLineDocTmp.Validate(PatientId, GetValueAtCell(LineNo, 9));
                GenJnlLineDocTmp.Validate(BssiEntityID, GlobalGenJnlLineTemp.BssiEntityID);
                GenJnlLineDocTmp.Insert(true);

                if GenJnlLineDocTmp."Document Type" = GenJnlLineDocTmp."Document Type"::"Credit Memo" then begin
                    GenJnlLineCMTmp := GenJnlLineDocTmp;
                    GenJnlLineCMTmp.Insert();
                end;
            end else
                if GetValueAtCell(LineNo, 1) = 'Transaction' then begin
                    Processed := true;
                    Evaluate(DateVar, GetValueAtCell(LineNo, 6));
                    GenJnlLineDocTmp.Validate(ServiceBeginDate, DateVar);
                    Evaluate(DateVar, GetValueAtCell(LineNo, 7));
                    GenJnlLineDocTmp.Validate(ServiceEndDate, DateVar);

                    if GenJnlLineDocTmp."Account Type" = GenJnlLineDocTmp."Account Type"::Vendor then
                        GenJnlLineDocTmp.Modify(true);

                    GenJnlLineDocTmp."Line No." := LineNo;
                    GenJnlLineDocTmp.Validate("Account Type", GenJnlLineDocTmp."Bal. Account Type"::"G/L Account");
                    GenJnlLineDocTmp.Validate("Account No.", GetValueAtCell(LineNo, 3));
                    GenJnlLineDocTmp.Validate(Description, LineDescription);
                    Evaluate(DecimalVar, GetValueAtCell(LineNo, 5));
                    GenJnlLineDocTmp.Validate(Amount, DecimalVar);
                    GenJnlLineDocTmp.Validate("Shortcut Dimension 1 Code", GetValueAtCell(LineNo, 2));
                    GenJnlLineDocTmp.Validate("Shortcut Dimension 2 Code", FormatDivmValue(GetValueAtCell(LineNo, 4)));
                    GenJnlLineDocTmp.Validate(BssiEntityID, GlobalGenJnlLineTemp.BssiEntityID);
                    GenJnlLineDocTmp.Insert(true);
                end;
        end;

        //Credit Memo application
        if GenJnlLineCMTmp.FindSet() then
            repeat
                GenJnlLineDocTmp.SetRange("Account Type", GenJnlLineDocTmp."Account Type"::Vendor);
                GenJnlLineDocTmp.SetRange("Account No.", GenJnlLineCMTmp."Account No.");
                GenJnlLineDocTmp.SetRange("Document Type", GenJnlLineDocTmp."Document Type"::Invoice);
                if GenJnlLineDocTmp.FindSet() then
                    repeat
                        if GenJnlLineCMTmp."CHS Applies-to Doc. No." = '' then begin
                            if Abs(GenJnlLineDocTmp.Amount) > Abs(GenJnlLineCMTmp.Amount) then
                                if not AppliedDocTmp.Get(0, GenJnlLineDocTmp."Account No.", GenJnlLineDocTmp."Document No.") then begin
                                    GenJnlLineCMTmp."CHS Applies-to Doc. Type" := GenJnlLineCMTmp."CHS Applies-to Doc. Type"::Invoice;
                                    GenJnlLineCMTmp."CHS Applies-to Doc. No." := GenJnlLineDocTmp."Document No.";
                                    GenJnlLineCMTmp."CHS Applies-to Ext. Doc. No." := GenJnlLineDocTmp."External Document No.";
                                    GenJnlLineCMTmp.Modify();

                                    AppliedDocTmp."No." := GenJnlLineDocTmp."Account No.";
                                    AppliedDocTmp."Dimension Code" := GenJnlLineDocTmp."Document No.";
                                    AppliedDocTmp.Insert();
                                end;
                        end;
                    until GenJnlLineDocTmp.Next() = 0;

            until GenJnlLineCMTmp.Next() = 0;

        //Create Documents Lines
        GenJnlLine.Reset();
        GenJnlLineDocTmp.Reset();
        GenJnlLineCMTmp.Reset();

        if GenJnlLineDocTmp.FindSet() then
            repeat
                GenJnlLine := GenJnlLineDocTmp;
                GenJnlLine.Insert(true);
            until GenJnlLineDocTmp.Next() = 0;

        if GenJnlLineCMTmp.FindSet() then
            repeat
                GenJnlLine := GenJnlLineCMTmp;
                GenJnlLine.Modify(true);
            until GenJnlLineCMTmp.Next() = 0;

        //Create Payments
        GenJnlLineDocTmp.Reset();
        GenJnlLineDocTmp.SetRange("Account Type", GenJnlLineDocTmp."Account Type"::Vendor);
        // GenJnlLineDocTmp.SetRange("Account No.", GenJnlLineDocTmp."Account No.");
        GenJnlLineDocTmp.SetRange("Document Type", GenJnlLineDocTmp."Document Type"::Invoice);
        if GenJnlLineDocTmp.FindSet() then
            repeat
                LineNo += 1;
                GenJnlLinePayTmp := GenJnlLineDocTmp;
                GenJnlLinePayTmp."Line No." := LineNo;
                GenJnlLinePayTmp.Validate("Document Type", GenJnlLinePayTmp."Document Type"::Payment);
                GenJnlLinePayTmp.Validate("Document Date", GenJnlLinePayTmp."Posting Date");
                GenJnlLinePayTmp.Validate("Shortcut Dimension 1 Code", GlobalGenJnlLineTemp.BssiEntityID);
                DocumentNo := GenJnlLinePayTmp."Document No.";
                DocumentNo := DocumentNo.Replace('MI', 'CL');
                GenJnlLinePayTmp.Validate("Document No.", DocumentNo);
                GenJnlLinePayTmp."External Document No." := '';
                GenJnlLinePayTmp.Validate(Amount, Abs(GenJnlLinePayTmp.Amount));

                if AppliedDocTmp.Get(0, GenJnlLineDocTmp."Account No.", GenJnlLineDocTmp."Document No.") then begin
                    GenJnlLineCMTmp.SetRange("Account Type", GenJnlLineDocTmp."Account Type"::Vendor);
                    GenJnlLineCMTmp.SetRange("Account No.", GenJnlLineDocTmp."Account No.");
                    GenJnlLineCMTmp.SetRange("Document Type", GenJnlLineDocTmp."Document Type"::"Credit Memo");
                    GenJnlLineCMTmp.SetRange("CHS Applies-to Doc. No.", GenJnlLineDocTmp."Document No.");
                    GenJnlLineCMTmp.SetRange("CHS Applies-to Ext. Doc. No.", GenJnlLineDocTmp."External Document No.");
                    if GenJnlLineCMTmp.FindFirst() then
                        GenJnlLinePayTmp.Validate(Amount, Abs(GenJnlLinePayTmp.Amount) - Abs(GenJnlLineCMTmp.Amount));
                end;

                GenJnlLinePayTmp.Validate("Bal. Account Type", GenJnlLinePayTmp."Bal. Account Type"::"Bank Account");
                GenJnlLinePayTmp.Validate("Bal. Account No.", GlobalGenJnlLineTemp."Bal. Account No.");
                GenJnlLinePayTmp."CHS Applies-to Doc. Type" := GenJnlLineDocTmp."CHS Applies-to Doc. Type"::Invoice;
                GenJnlLinePayTmp."CHS Applies-to Doc. No." := GenJnlLineDocTmp."Document No.";
                GenJnlLinePayTmp."CHS Applies-to Ext. Doc. No." := GenJnlLineDocTmp."External Document No.";
                GenJnlLinePayTmp.Insert();
            until GenJnlLineDocTmp.Next() = 0;

        if GenJnlLinePayTmp.FindSet() then
            repeat
                GenJnlLine := GenJnlLinePayTmp;
                GenJnlLine.Insert(true);
            until GenJnlLinePayTmp.Next() = 0;

        if not Processed then
            Error('Nothing to process!');
    end;


    local procedure GetValueAtCell(RowNo: Integer; ColNo: Integer): Text
    begin
        if CSVBufferTemp.Get(RowNo, ColNo) then
            exit(CSVBufferTemp.Value)
        else
            exit('');
    end;

    local procedure FormatDivmValue(Value: Text[18]): Code[20]
    begin
        if StrLen(Value) <> 7 then
            Error('Error Dimension Value %1.', Value);

        exit(CopyStr(Value, 1, 1) + '-' + CopyStr(Value, 2, 2) + '-' + CopyStr(Value, 4));
    end;

    local procedure GetDocumentNo(Value: Integer; DocumentDate: Date): Text[20]
    var
        DocumentNo: Text[20];
    begin
        DocumentNo := '000' + Format(Value);

        if StrLen(DocumentNo) > 4 then
            DocumentNo := CopyStr(DocumentNo, StrLen(DocumentNo) - 3);

        DocumentNo := 'MI' + Format(DocumentDate, 0, '<Month,2><Day,2><Year>') + DocumentNo;
        exit(DocumentNo);
    end;

    local procedure PostJnlBatch()
    var
        CodeunitJnlPost: Codeunit "Gen. Jnl.-Post Batch";
        GenJnlLine: Record "Gen. Journal Line";
    begin
        ClearLastError();
        GenJnlLine.SetRange("Journal Template Name", GlobalGenJnlLineTemp."Journal Template Name");
        GenJnlLine.SetRange("Journal Batch Name", GlobalGenJnlLineTemp."Journal Batch Name");
        GenJnlLine.SetRange(BssiEntityID, GlobalGenJnlLineTemp.BssiEntityID);
        GenJnlLine.SetFilter("Document No.", '<>%1', '');

        CodeunitJnlPost.SetPreviewMode(true);

        //Preview Invoices
        ClearLastError();
        GenJnlLine.SetRange("Document Type", GenJnlLine."Document Type"::Invoice);
        if not GenJnlLine.IsEmpty then
            if not CodeunitJnlPost.Run(GenJnlLine) then
                if GetLastErrorText() <> PreviewModeMsg then
                    Error(GetLastErrorText());

        //Preview Credit Memos
        ClearLastError();
        GenJnlLine.SetRange("Document Type", GenJnlLine."Document Type"::"Credit Memo");
        if not GenJnlLine.IsEmpty then
            if not CodeunitJnlPost.Run(GenJnlLine) then
                if GetLastErrorText() <> PreviewModeMsg then
                    Error(GetLastErrorText());

        //Preview Payments
        ClearLastError();
        GenJnlLine.SetRange("Document Type", GenJnlLine."Document Type"::Payment);
        if not GenJnlLine.IsEmpty then
            if not CodeunitJnlPost.Run(GenJnlLine) then
                if GetLastErrorText() <> PreviewModeMsg then
                    Error(GetLastErrorText());

        Clear(CodeunitJnlPost);

        //Post Invoices
        GenJnlLine.SetRange("Document Type", GenJnlLine."Document Type"::Invoice);
        if not GenJnlLine.IsEmpty then
            if not CodeunitJnlPost.Run(GenJnlLine) then;

        //Post Credit Memos
        GenJnlLine.SetRange("Document Type", GenJnlLine."Document Type"::"Credit Memo");
        if not GenJnlLine.IsEmpty then
            if CodeunitJnlPost.Run(GenJnlLine) then;

        //Post Payments
        GenJnlLine.SetRange("Document Type", GenJnlLine."Document Type"::Payment);
        if not GenJnlLine.IsEmpty then
            if CodeunitJnlPost.Run(GenJnlLine) then;

        Message(SuccessPostingMsg);
    end;

    procedure SetValues(var GenJnlLine: Record "Gen. Journal Line")
    begin
        GlobalGenJnlLineTemp."Journal Template Name" := GenJnlLine.GetRangeMax("Journal Template Name");
        GlobalGenJnlLineTemp."Journal Batch Name" := GenJnlLine.GetRangeMax("Journal Batch Name");
        GlobalGenJnlLineTemp.BssiEntityID := GenJnlLine.GetRangeMax(BssiEntityID);

        JnlTemplateBatchNotEditable := true;
        JnlTemplateNameNotEditable := true;
        CompanyCodeNotEditable := true;
    end;



    var
        CSVBufferTemp: Record "CSV Buffer" temporary;
        GlobalGenJnlLineTemp: Record "Gen. Journal Line" temporary;
        GlobalPostJnlBatch: Boolean;
        CSVServerFileName: Text[250];
        JnlTemplateBatchNotEditable: Boolean;
        JnlTemplateNameNotEditable: Boolean;
        CompanyCodeNotEditable: Boolean;
        DeleteJnlLines: Boolean;
        UploadMsg: Label 'Please choose the CSV file';
        GenJnlNotEmptyMsg: Label 'General Journal must be empty!';
        SuccessPostingMsg: Label 'The journal lines were successfully posted.';
        PreviewModeMsg: Label 'Preview mode.';
}