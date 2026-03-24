tableextension 50500 "CHS Gen. Journal Line" extends "Gen. Journal Line"
{
    fields
    {
        field(50500; "CHS Applies-to Doc. Type"; Enum "Gen. Journal Document Type")
        {
            Caption = 'CHS Applies-to Doc. Type';
            DataClassification = CustomerContent;
        }
        field(50501; "CHS Applies-to Doc. No."; Code[20])
        {
            Caption = 'CHS Applies-to Doc. No.';
            DataClassification = CustomerContent;
        }
        field(50502; "CHS Applies-to Ext. Doc. No."; Code[35])
        {
            Caption = 'CHS Applies-to Ext. Doc. No.';
            DataClassification = CustomerContent;
        }
    }
}