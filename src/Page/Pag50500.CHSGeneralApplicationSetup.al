page 50500 "CHS General Application Setup"
{
    ApplicationArea = All;
    Caption = 'CHS General Application Setup';
    PageType = Card;
    SourceTable = "CHS General Application Setup";
    InsertAllowed = false;
    DeleteAllowed = false;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(MirraClaims)
            {
                Caption = 'Mirra Claims';

                field("Mirra Claims Jnl. Batch. Name"; Rec."Mirra Claims Jnl. Batch. Name")
                {
                    ToolTip = 'Specifies the value of the Mirra Claims Jnl. Batch. Name field.';
                }
                field("Mirra Claims Jnl. Tmpl. Name"; Rec."Mirra Claims Jnl. Tmpl. Name")
                {
                    ToolTip = 'Specifies the value of the Mirra Claims Jnl. Tmpl. Name field.';
                }
                field("Mirra Claims Company Code"; Rec."Mirra Claims Company Code")
                {
                    ToolTip = 'Specifies the value of the Mirra Claims Company Code field.';
                }
                field("Mirra Claims Bank Account"; Rec."Mirra Claims Bank Account")
                {
                    ToolTip = 'Specifies the value of the Mirra Claims Bank Account field.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if Rec.FindFirst() then
            exit;

        Rec."Mirra Claims Jnl. Tmpl. Name" := 'Claims';
        Rec."Mirra Claims Jnl. Batch. Name" := 'Import';
        Rec."Mirra Claims Company Code" := 'CHS';
        Rec."Mirra Claims Bank Account" := 'B070';
        Rec.Insert();
    end;
}
