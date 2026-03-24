permissionset 50500 CHSBASEAPP
{
    Assignable = true;
    Permissions = tabledata "CHS General Application Setup" = RIMD,
        table "CHS General Application Setup" = X,
        report "CHS Import Docs Mirra Claims" = X,
        report "CHS Import Mirra Claims CSV" = X,
        report "CHS Remittance Advice Entries" = X,
        page "CHS General Application Setup" = X,
        page "CHS Open Journal Lines" = X,
        report "CHS Fix VLE 1099 Amount" = X,
        report "CHS VLE IRS 1099" = X,
        page "CHS Vend. Ledger Entries" = X,
        page "CHS Vendor 1099 Card" = X,
        page "CHS Vendors 1099" = X;
}