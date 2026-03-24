pageextension 50502 "CHS General Journal" extends "General Journal" //39
{
    layout
    {
        addlast(Control120)
        {
            field("CHS Payment Method Code"; Rec."Payment Method Code") { ApplicationArea = All; }
        }
        addlast(Control1)
        {
            field("CHS Applies-to Doc. Type"; Rec."CHS Applies-to Doc. Type") { ApplicationArea = All; }
            field("CHS Applies-to Doc. No."; Rec."CHS Applies-to Doc. No.") { ApplicationArea = All; }
            field("CHS Applies-to Ext. Doc. No."; Rec."CHS Applies-to Ext. Doc. No.") { ApplicationArea = All; }
        }
    }
    actions
    {
        addafter(DeferralSchedule)
        {
            action(CHSImportLines)
            {
                Image = Import;
                ApplicationArea = All;
                Caption = 'CHS Import Mirra Claims';
                ToolTip = 'Import Mirra Claims action';
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    ReportCHSImportMirraClaimsCSV: Report "CHS Import Mirra Claims CSV";
                begin
                    ReportCHSImportMirraClaimsCSV.SetValues(Rec);
                    ReportCHSImportMirraClaimsCSV.RunModal();

                    CurrPage.Update(false);
                    if Rec.FindFirst() then;
                end;
            }

            action(CHSPostLines)
            {
                Image = PostBatch;
                ApplicationArea = All;
                Caption = 'CHS Post Mirra Claims';
                ToolTip = 'Post Mirra Claims action';
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    GenJnlLine: Record "Gen. Journal Line";
                    IsNothingToPost: Boolean;
                    SuccessPostingMsg: Label 'The journal lines were successfully posted.';
                    NothingToPostMsg: Label 'There are no journal lines to post.';
                begin
                    // IsNothingToPost := true;

                    //Preview Invoices
                    GenJnlLine.Copy(Rec);
                    GenJnlLine.SetFilter("Document No.", '<>%1', '');
                    GenJnlLine.SetRange("Document Type", GenJnlLine."Document Type"::Invoice);
                    BatchJournalPosting(GenJnlLine, IsNothingToPost, true);

                    //Preview Credit Memos
                    GenJnlLine.Copy(Rec);
                    GenJnlLine.SetFilter("Document No.", '<>%1', '');
                    GenJnlLine.SetRange("Document Type", GenJnlLine."Document Type"::"Credit Memo");
                    BatchJournalPosting(GenJnlLine, IsNothingToPost, true);

                    //Preview Payments
                    GenJnlLine.Copy(Rec);
                    GenJnlLine.SetFilter("Document No.", '<>%1', '');
                    GenJnlLine.SetRange("Document Type", GenJnlLine."Document Type"::Payment);
                    BatchJournalPosting(GenJnlLine, IsNothingToPost, true);

                    if IsNothingToPost then
                        Error(NothingToPostMsg);

                    //Post Invoices
                    GenJnlLine.SetRange("Document Type", GenJnlLine."Document Type"::Invoice);
                    BatchJournalPosting(GenJnlLine, IsNothingToPost, false);

                    //Post Credit Memos
                    GenJnlLine.SetRange("Document Type", GenJnlLine."Document Type"::"Credit Memo");
                    BatchJournalPosting(GenJnlLine, IsNothingToPost, false);

                    //Post Payments
                    GenJnlLine.SetRange("Document Type", GenJnlLine."Document Type"::Payment);
                    BatchJournalPosting(GenJnlLine, IsNothingToPost, false);

                    Message(SuccessPostingMsg);
                    CurrPage.Update(false);
                    if Rec.FindFirst() then;
                end;
            }
        }
    }

    local procedure CHSUpdateApplyToDocumentInfo(var GenJnlLine: Record "Gen. Journal Line")
    begin
        if not GenJnlLine.FindSet() then
            exit;

        repeat
            GenJnlLine."Applies-to Doc. Type" := GenJnlLine."CHS Applies-to Doc. Type";
            GenJnlLine."Applies-to Doc. No." := GenJnlLine."CHS Applies-to Doc. No.";
            GenJnlLine."Applies-to Ext. Doc. No." := GenJnlLine."CHS Applies-to Ext. Doc. No.";
            GenJnlLine.Modify();
        until GenJnlLine.Next() = 0;

        Commit();
    end;

    local procedure CHSCleanupApplyToDocumentInfo(var GenJnlLine: Record "Gen. Journal Line")
    begin
        if not GenJnlLine.FindSet() then
            exit;

        repeat
            GenJnlLine."Applies-to Doc. Type" := GenJnlLine."CHS Applies-to Doc. Type"::" ";
            GenJnlLine."Applies-to Doc. No." := '';
            GenJnlLine."Applies-to Ext. Doc. No." := '';
            GenJnlLine.Modify();
        until GenJnlLine.Next() = 0;

        Commit();
    end;

    local procedure BatchJournalPosting(var InputGenJnlLine: Record "Gen. Journal Line"; var IsNothingToPost: Boolean; PrevievMode: Boolean)
    var
        GenJnlLine: Record "Gen. Journal Line";
        CodeunitJnlPost: Codeunit "Gen. Jnl.-Post Batch";

        PreviewModeMsg: Label 'Preview mode.';
        SomethingWentWrongMsg: Label 'Something went wrong.';
    begin
        ClearLastError();
        GenJnlLine.Copy(InputGenJnlLine);
        CodeunitJnlPost.SetPreviewMode(PrevievMode);

        //Post 
        if not GenJnlLine.IsEmpty then begin
            IsNothingToPost := false;

            if not PrevievMode then
                CHSUpdateApplyToDocumentInfo(GenJnlLine);

            if not CodeunitJnlPost.Run(GenJnlLine) then begin

                if not PrevievMode then
                    CHSCleanupApplyToDocumentInfo(GenJnlLine);

                if GetLastErrorText() <> PreviewModeMsg then
                    if GetLastErrorText() <> '' then
                        Error(GetLastErrorText())
                    else
                        Error(SomethingWentWrongMsg);
            end;
        end;
    end;
}
