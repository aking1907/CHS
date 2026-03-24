pageextension 50501 "CHS General Ledger Entries" extends "General Ledger Entries"
{
    layout
    {
        addlast(Control1)
        {
            field("CHS Comment"; Rec.Comment)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the entry''s Comment.';
                Visible = true;
            }
            field("CHS Document Date"; Rec."Document Date")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the entry''s Document Date.';
                Visible = false;
            }
        }
    }
}
