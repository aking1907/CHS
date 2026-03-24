table 50500 "CHS General Application Setup"
{
    Caption = 'General Application Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; "Mirra Claims Jnl. Tmpl. Name"; Code[20])
        {
            Caption = 'Mirra Claims Jnl. Tmpl. Name';
            TableRelation = "Gen. Journal Template";
        }
        field(3; "Mirra Claims Jnl. Batch. Name"; Code[20])
        {
            Caption = 'Mirra Claims Jnl. Batch. Name';
            TableRelation = "Gen. Journal Batch".Name where("Journal Template Name" = field("Mirra Claims Jnl. Tmpl. Name"));

        }
        field(4; "Mirra Claims Company Code"; Code[10])
        {
            Caption = 'Mirra Claims Company Code';
            TableRelation = "Dimension Value".Code where("Dimension Code" = const('COMPANY'));
        }
        field(5; "Mirra Claims Bank Account"; Code[20])
        {
            Caption = 'Mirra Claims Bank Account';
            TableRelation = "Bank Account";
        }
    }
    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}
