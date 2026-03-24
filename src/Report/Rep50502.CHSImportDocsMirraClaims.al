report 50502 "CHS Import Docs Mirra Claims"
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
                field(DeleteJnlLines; DeleteJnlLines)
                {
                    ApplicationArea = All;
                    Caption = 'Delete Jnl. Lines';
                    ToolTip = 'Specifies the Delete Jnl. Lines field.';
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

    trigger OnInitReport()
    begin
        GlobalGenJnlLineTemp."Journal Template Name" := 'Claims';
        GlobalGenJnlLineTemp."Journal Batch Name" := 'Import';
        GlobalGenJnlLineTemp."Posting Date" := Today();
        GlobalGenJnlLineTemp.BssiEntityID := 'CHS';
    end;

    trigger OnPreReport()
    begin
        if CSVServerFileName = '' then
            Error('File has not been found!');

        ImportDataFromCSV();
    end;

    trigger OnPostReport()
    begin
        Message('File import completed!');
    end;

    local procedure ImportDataFromCSV()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        // GenJnlLine: Record "Gen. Journal Line";
        // GenJnlTemplate: Record "Gen. Journal Template";
        LineNo: Integer;
        DecimalVar: Decimal;
        DateVar: Date;
        LineDescription: Text[100];
        Processed: Boolean;
    begin

        for LineNo := 2 to CSVBufferTemp.GetNumberOfLines() do begin
            if GetValueAtCell(LineNo, 1) = 'Document' then begin
                Processed := true;

                if PurchaseHeader.Get(PurchaseHeader."Document Type"::Invoice, GetDocumentNo(LineNo)) then begin
                    PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
                    PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
                    if PurchaseLine.FindSet() then
                        PurchaseLine.DeleteAll();

                    PurchaseHeader.Delete();
                end;

                Clear(PurchaseHeader);

                PurchaseHeader."Document Type" := PurchaseHeader."Document Type"::Invoice;
                PurchaseHeader."No." := GetDocumentNo(LineNo);
                PurchaseHeader.Insert(true);

                PurchaseHeader.Validate("Shortcut Dimension 1 Code", GlobalGenJnlLineTemp.BssiEntityID);
                PurchaseHeader.Validate("Buy-from Vendor No.", GetValueAtCell(LineNo, 3));
                PurchaseHeader."Vendor Invoice No." := GetValueAtCell(LineNo, 15);
                PurchaseHeader.Validate("Shortcut Dimension 2 Code", FormatDivmValue(GetValueAtCell(LineNo, 14)));
                PurchaseHeader.Validate("Posting Date", GlobalGenJnlLineTemp."Posting Date");
                Evaluate(DateVar, GetValueAtCell(LineNo, 7));
                PurchaseHeader.Validate("Document Date", DateVar);
                PurchaseHeader.Validate(PatientId, GetValueAtCell(LineNo, 9));
                PurchaseHeader.Validate("Payment Method Code", 'MIRRA');
                // PurchaseHeader.Validate(BssiEntityID, GlobalGenJnlLineTemp.BssiEntityID);
                PurchaseHeader.Modify(true);

                LineDescription := GetValueAtCell(LineNo, 8);

                // GenJnlLine.Validate("External Document No.", GetValueAtCell(LineNo, 6));

            end else
                if GetValueAtCell(LineNo, 1) = 'Transaction' then begin
                    Clear(PurchaseLine);

                    PurchaseLine."Document Type" := PurchaseHeader."Document Type";
                    PurchaseLine."Document No." := PurchaseHeader."No.";
                    PurchaseLine."Line No." := LineNo;
                    PurchaseLine.Validate(Type, PurchaseLine.Type::"G/L Account");
                    PurchaseLine.Validate("No.", GetValueAtCell(LineNo, 3));
                    PurchaseLine.Validate(Description, LineDescription);

                    Evaluate(DecimalVar, GetValueAtCell(LineNo, 5));
                    PurchaseLine.Validate(Quantity, 1);
                    PurchaseLine.Validate("Direct Unit Cost", DecimalVar);
                    PurchaseLine.Validate("Shortcut Dimension 1 Code", GetValueAtCell(LineNo, 2));
                    PurchaseLine.Validate("Shortcut Dimension 2 Code", FormatDivmValue(GetValueAtCell(LineNo, 4)));
                    PurchaseLine.Insert(true);

                    // Evaluate(DateVar, GetValueAtCell(LineNo, 6));
                    // GenJnlLine.Validate(ServiceBeginDate, DateVar);
                    // Evaluate(DateVar, GetValueAtCell(LineNo, 7));
                    // GenJnlLine.Validate(ServiceEndDate, DateVar

                end;
        end;

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

    local procedure GetDocumentNo(Value: Integer): Text[20]
    var
        DocumentNo: Text[20];
    begin
        DocumentNo := '00' + Format(Value);

        if StrLen(DocumentNo) > 3 then
            DocumentNo := CopyStr(DocumentNo, StrLen(DocumentNo) - 2);

        DocumentNo := 'MI' + Format(Today, 0, '<Month,2><Day,2><Year>') + DocumentNo;
        exit(DocumentNo);
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
        CSVServerFileName: Text[250];
        JnlTemplateBatchNotEditable: Boolean;
        JnlTemplateNameNotEditable: Boolean;
        CompanyCodeNotEditable: Boolean;
        DeleteJnlLines: Boolean;
        UploadMsg: Label 'Please choose the CSV file';
        GenJnlNotEmptyMsg: Label 'General Journal must be empty!';
}