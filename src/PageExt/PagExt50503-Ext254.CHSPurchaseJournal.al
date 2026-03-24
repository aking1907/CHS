// pageextension 50503 "CHS Purchase Journal" extends "Purchase Journal" //254
// {
//     layout
//     {
//         addlast(Control2)
//         {
//             field("CHS Payment Method Code"; Rec."Payment Method Code")
//             { ApplicationArea = All; }
//         }
//     }
//     // actions
//     // {
//     //     addafter(DeferralSchedule)
//     //     {
//     //         action(CHSImportLines)
//     //         {
//     //             Image = Import;
//     //             ApplicationArea = All;
//     //             Caption = 'CHS Import Mirra Claims';
//     //             ToolTip = 'Import Mirra Claims action';
//     //             Promoted = true;
//     //             PromotedOnly = true;
//     //             PromotedCategory = Process;

//     //             trigger OnAction()
//     //             var
//     //                 ReportCHSImportMirraClaimsCSV: Report "CHS Import Mirra Claims CSV";
//     //             begin
//     //                 ReportCHSImportMirraClaimsCSV.SetValues(Rec);
//     //                 ReportCHSImportMirraClaimsCSV.RunModal();

//     //                 CurrPage.Update(false);
//     //             end;
//     //         }
//     //     }
//     // }
// }
