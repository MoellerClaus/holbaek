//***************************************************************************//
//  Holbæk                                                                   //
//  Copyright by Claus Moeller 2013-2014                                     //
//  Main form                                                                //
//  Version                                                                  //
//  23.12.13                                                                 //
//***************************************************************************//
// I dette unit defineres alle konstanter til ...

unit holbaekconst;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics, Grids, Richmemo, StdCtrls;

Const
  CurrentAfd         : String = '1';
  HolbaekIniFile     : String = '';
  ReportExt          : String = 'lrf';
  Holbaek_Version    : String = '1.0.0.1';
  Options_Alias_Data : String = ''; // Determined by GetAppConfigDir
  Options_Alias_Net1 : String = '';

  DatabaseFileName   : String = 'holbaek';
  DatabaseFile       : String = '';
  SQLLitePath        : String = '';
  // Ini file placeres i samme dir som database i Options_alias_Data og hedder DatabaseFileName + '.ini'
  DatabaseUdskriv    : String = 'UDSKRIV';  // Udskrifts database til rapportdesigner
  DatabaseKontoBes   : String = 'KONTOBES'; //

  // Farver generelle
  H_Menu_knapper_Farve   = clCream;
  H_Window_Baggrund      = clSkyBlue;
  H_Edit_Baggrund        = clCream;
  H_Grid_BackColor       = $00D7FFFF;
  H_Grid_AlternateColor  = $00D7FFFF;
  H_Grid_Cell_Selected   = clBlack;  // $00FDEFE3; //clBlue; // $ 009DFFCE;
  H_Grid_Cell_FocusColor = $00EACAB6;
  H_Page_Color           = clCream;
  H_Memo_Color           = $00F0FFFF;
  H_Combo_Color          = $00D7FFFF;
  H_Group_Color          = clSkyBlue;
  H_Radio_Color          = $00F0FFFF;
  H_Panel_Color          = clCream;

  // Farver kassekladde
  H_Panel_Afstemning     = $00E6E6E6;
  H_Panel_Overskrift     = $00AAAAAA;

  // Konstanter til indstilling af Girokort
  Def_Giro_GiroTegn1              : String  = '+';
  Def_Giro_GiroTegn2              : String  = '<';
  Def_Giro_GiroTegn3              : String  = '+';
  Def_Giro_GiroTegn4              : String  = '<';
  Def_Giro_AntalTegnIIdent        : String  = '15';
  Def_Giro_FontName               : String  = 'OCRBB12';
  Def_Giro_FontStr                : String  = '12';
  Def_GiroTalon_FontName          : String  = 'Arial';
  Def_GiroTalon_FontStr           : String  = '11';
  Def_Spec1                       : String  = '<*1*>';
  Def_Spec2                       : String  = '<*2*>';
  Def_Spec3                       : String  = '<*3*>';
  Def_Udskrift_Spilletid          : String  = '<*T*>';
  Def_Udskrift_Rettidig           : String  = '<*R*>';
  Def_Udskrift_KategoriBetegnelse : String  = '<*K*>';

  Def_BS_PBSNr                    : String  = '';
  Def_BS_DebGrNr                  : String  = '';

  // Indbetalingskort
  Options_Giro_Tegn1              : String = '+';
  Options_Giro_Tegn2              : String = '<';
  Options_Giro_Tegn3              : String = '+';
  Options_Giro_Tegn4              : String = '>';
  Options_Giro_AntalTegnIIdent    : String = '15';

  Options_Udskrift_Spec1          : String = '<*S1*>';
  Options_Udskrift_Spec2          : String = '<*S2*>';
  Options_Udskrift_Spec3          : String = '<*S3*>';
  Options_Udskrift_Spec4          : String = '<*S4*>';
  Options_Udskrift_Spilletid      : String = '<*T*>';
  Options_Udskrift_Rettidig       : String = '<*R*>';
  Options_Udskrift_KategoriBetegnelse : String = '<*K*>';
  Options_Udskrift_Aktivitet      : String = '<*A*>';
  Options_Udskrift_Pris           : String = '<*$*>';


Procedure Indstil_StringGrid_Edit(Var StringGrid1 : TStringGrid);
Procedure Indstil_StringGrid_NonEdit(Var StringGrid1 : TStringGrid);
function  CompareStringsAsIntegers(List: TStringList; Index1, Index2 : Integer): Integer;
Function  FjernPunktum(HelpStr : String) : String;
function  GetRichMemoRTF(RichMemo: TRichMemo): string;
procedure SetRichMemoRTF(Const RichMemo: TRichMemo; S: string);
Function  FillUpStr(GiroNr : String) : String;
procedure SetMemo(Const MemoSet : TMemo; S: string);
function  GetMemo(MemoSet : TMemo): string;



implementation


//**********************************************************
// Indstil Grid Edit
//**********************************************************
Procedure Indstil_StringGrid_Edit(Var StringGrid1 : TStringGrid);
Begin
  StringGrid1.Color                   := H_Grid_BackColor;
  StringGrid1.FixedCols               := 0;
  StringGrid1.FixedRows               := 1;
  StringGrid1.RowCount                := 1;
  StringGrid1.AutoAdvance             := aaRight;
  StringGrid1.ColumnClickSorts        := True;
  StringGrid1.AlternateColor          := H_Grid_AlternateColor;
  StringGrid1.SelectedColor           := H_Grid_Cell_Selected;
//  StringGrid1.SelectedFontColor       := clBlack;
  StringGrid1.FocusColor              := H_Grid_Cell_FocusColor;
  StringGrid1.DefaultRowHeight        := 19;
  StringGrid1.Font.Color              := clBlack;
  StringGrid1.Options := StringGrid1.Options +
    [goAlwaysShowEditor, goEditing, goTabs, goColSizing];
End;

//**********************************************************
// Indstil grid non edit
//**********************************************************
Procedure Indstil_StringGrid_NonEdit(Var StringGrid1 : TStringGrid);
Begin
  StringGrid1.Color                   := H_Grid_BackColor;
  StringGrid1.FixedCols               := 0;
  StringGrid1.FixedRows               := 1;
  StringGrid1.RowCount                := 1;
  StringGrid1.AutoAdvance             := aaRight;
  StringGrid1.ColumnClickSorts        := True;
  StringGrid1.AlternateColor          := H_Grid_AlternateColor;
  StringGrid1.SelectedColor           := H_Grid_Cell_Selected;
//  StringGrid1.SelectedFontColor       := clBlack;
  StringGrid1.FocusColor              := H_Grid_Cell_FocusColor;
  StringGrid1.DefaultRowHeight        := 19;
  StringGrid1.Font.Color              := clBlack;
  StringGrid1.UseXORFeatures          := True;
  StringGrid1.Options := StringGrid1.Options +
    [goRowSelect, goTabs, goColSizing];
End;


//**********************************************************
// Compare integers
//**********************************************************
function CompareStringsAsIntegers(List: TStringList; Index1, Index2 : Integer): Integer;
begin
  Result := StrToInt(List[Index1]) - StrToInt(List[Index2]);
end;

//**********************************************************
// Fjerm Punktum
//**********************************************************
Function  FjernPunktum(HelpStr : String) : String;
Var HSTr : String;
    Plads : Integer;
Begin
  HStr := HelpStr;
  While Pos('.',HStr) <> 0 Do
    Begin
      Plads := Pos('.',HStr);
      Delete(HStr,Plads,1);
    End;
  FjernPunktum := HStr;
end;

//**********************************************************
// Get Rich Memo
//**********************************************************
function GetRichMemoRTF(RichMemo: TRichMemo): string;
var
  strStream: TStringStream;
begin
  strStream := TStringStream.Create('');
  try
    RichMemo.SaveRichText(strStream);
    Result := strStream.DataString;
  finally
      strStream.Free
  end;
end;

//**********************************************************
// Set rich memo
//**********************************************************
procedure SetRichMemoRTF(Const RichMemo: TRichMemo; S: string);
var
  strStream: TStringStream;
begin
  strStream := TStringStream.Create('');
  try
    strStream.WriteString(S);
    strStream.Position := 0;
    RichMemo.LoadRichText(strStream);
  finally
    strStream.Free
  end;
end;

//**********************************************************
// Get Memo
//**********************************************************
function GetMemo(MemoSet : TMemo): string;
var
  strStream: TStringStream;
begin
  strStream := TStringStream.Create('');
  try
    MemoSet.Lines.SaveToStream(strStream);
    Result := strStream.DataString;
  finally
      strStream.Free
  end;
end;

//**********************************************************
// Set memo
//**********************************************************
procedure SetMemo(Const MemoSet : TMemo; S: string);
var
  strStream: TStringStream;
begin
  strStream := TStringStream.Create('');
  try
    strStream.WriteString(S);
    strStream.Position := 0;
    MemoSet.Lines.LoadFromStream(strStream);
  finally
    strStream.Free
  end;
end;

//**********************************************************
// Fill up str
//**********************************************************
Function  FillUpStr(GiroNr : String) : String;
Var HelpStr : String;
    Len     : Integer;
    A       : Integer;
Begin
  HelpStr := GiroNr;
  Len := Length(GiroNr);
  For A := Len To (StrToInt(Options_Giro_AntalTegnIIdent) - 1) Do
    Begin
      HelpStr := '0' + HelpStr;
    End;
  FillUpStr := HelpStr;
  //  FillUpStr := ' ' + HelpStr;
End;



end.

