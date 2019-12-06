//***************************************************************************//
//  Holbæk                                                                   //
//  Copyright by Claus Moeller 2013-2014                                     //
//  Se og ændre kontingent                                                   //
//  Version                                                                  //
//  23.11.14                                                                 //
//***************************************************************************//
unit FKonti;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, DateTimePicker, Forms, Controls, Graphics,
  Dialogs, ComCtrls, Menus, ActnList, ExtCtrls, DbCtrls, StdCtrls, Buttons,
  DBExtCtrls, clmCombobox, jdblabeleddateedit, jdblabeledcurrencyedit,
  JDBLabeledEdit, ZDataset, db, Inifiles;

type

  { TFormKontigentSeAendre }

  TFormKontigentSeAendre = class(TForm)
    BitBtn2: TBitBtn;
    CheckAktivitet: TCheckBox;
    CheckMedlemsNavn: TCheckBox;
    CheckMedlemsNr: TCheckBox;
    clmCombobox1: TclmCombobox;
    DateTimePicker1: TDateTimePicker;
    EditDateUdsendt: TDBDateEdit;
    DBText1: TDBText;
    DBText3: TDBText;
    Gem: TAction;
    ActionList1: TActionList;
    BitBtn1: TBitBtn;
    ComboKonto: TclmCombobox;
    ComboAfstemning: TclmCombobox;
    ComboSortering: TclmCombobox;
    ComboMedlem: TclmCombobox;
    ComboPeriode: TclmCombobox;
    DataFraKontigent: TDataSource;
    DataFraMedlem: TDataSource;
    DBNavigator1: TDBNavigator;
    DBStatusRadioGroup: TDBRadioGroup;
    DBText2: TDBText;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    Help: TAction;
    ImageList1: TImageList;
    ImageList2: TImageList;
    DateEditRettidig: TJDBLabeledDateEdit;
    DateEditIndbetaltd: TJDBLabeledDateEdit;
    EditBeloebOpkraevet: TJDBLabeledCurrencyEdit;
    EditBeloebIndbetalt: TJDBLabeledCurrencyEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    LabelMedlemNavn: TLabel;
    Luk: TAction;
    MenuItem1: TMenuItem;
    PageColor1: TShape;
    PageColor2: TShape;
    PageControl1: TPageControl;
    PanelNederst: TPanel;
    PopupMenu1: TPopupMenu;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton6: TToolButton;
    ZQuery1: TZQuery;
    ZQueryMedlem: TZQuery;
    ZQueryKontingent: TZQuery;
    procedure ComboMedlemChange(Sender: TObject);
    procedure ComboPeriodeChange(Sender: TObject);
    procedure DataFraKontigentDataChange(Sender: TObject; Field: TField);
    procedure DBNavigator1Click(Sender: TObject; Button: TDBNavButtonType);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure GemExecute(Sender: TObject);
    procedure LukExecute(Sender: TObject);
  private
    { private declarations }
    IniFile : TIniFile;
    Procedure UpdateFields;
    Procedure IndlaesPeriode;
    procedure IndlaesMedlemmer;
    procedure IndlaesSortering;
    Procedure IndstilKontingent;
    procedure IndlaesKonti;
  public
    { public declarations }
  end;

var
  FormKontigentSeAendre: TFormKontigentSeAendre;

implementation

{$R *.lfm}

Uses HolbaekConst, MainData;

{ TFormKontigentSeAendre }

//**********************************************************
// Create
//**********************************************************
procedure TFormKontigentSeAendre.FormCreate(Sender: TObject);
begin
  Top  := 10;
  Left := 30;
  ShowHint               := True;
  // Farver
  Color                  := H_Window_Baggrund;
  ToolBar1.Color         := H_Menu_knapper_Farve;
  PanelNederst.Color     := H_Menu_knapper_Farve;
  PageColor1.Brush.Color := H_Page_Color;
  PageColor1.Align       := alClient;
  PageColor2.Brush.Color := H_Page_Color;
  PageColor2.Align       := alClient;

  EditDateUdsendt.Color     := H_Edit_Baggrund;
  DateEditRettidig.Color    := H_Edit_Baggrund;
  DateEditIndbetaltd.Color  := H_Edit_Baggrund;
  EditBeloebOpkraevet.Color := H_Edit_Baggrund;
  EditBeloebIndbetalt.Color := H_Edit_Baggrund;
  DBStatusRadioGroup.Color  := H_Edit_Baggrund;
  ComboPeriode.Color        := H_Combo_Color;
  ComboMedlem.Color         := H_Combo_Color;
  ComboKonto.Color          := H_Combo_Color;
  ComboAfstemning.Color     := H_Combo_Color;
  // Database
  ZQuery1.Connection              := MainDataModule.ZConnection1;
  ZQueryKontingent.Connection     := MainDataModule.ZConnection1;
  ZQueryMedlem.Connection         := MainDataModule.ZConnection1;
  // Lists

  // Indstil
  IndlaesSortering;
  IndlaesMedlemmer;
  IndlaesPeriode;
  IndstilKontingent;
  UpdateFields;
  IndlaesKonti;
  //Indstil;
  // Indlæs fra inifil
  IniFile := TIniFile.Create(HolbaekIniFile);
  ComboKonto.ItemIndex      := IniFile.ReadInteger('SeKontingent','Konto',0);
  ComboAfstemning.ItemIndex := IniFile.ReadInteger('SeKontingent','ModKonto',0);
  CheckMedlemsNr.Checked    := Inifile.ReadBool('SeKontingent','CheckMedlemsNr',True);
  CheckMedlemsNavn.Checked  := Inifile.ReadBool('SeKontingent','CheckMedlemsNavn',True);
  CheckAktivitet.Checked    := Inifile.ReadBool('SeKontingent','CheckAktivitet',True);
  IniFile.free;
  //IndlaesMarkLister;
  // Indlæs
  //IndlaesIGrid;
end;

//**********************************************************
// Form show
//**********************************************************
procedure TFormKontigentSeAendre.FormShow(Sender: TObject);
begin
end;

//**********************************************************
// Gem
//**********************************************************
procedure TFormKontigentSeAendre.GemExecute(Sender: TObject);
begin
  IniFile := TIniFile.Create(HolbaekIniFile);
  Inifile.WriteInteger('SeKontingent','Konto',ComboKonto.ItemIndex);
  Inifile.WriteInteger('SeKontingent','ModKonto',ComboAfstemning.ItemIndex);
  Inifile.WriteBool('SeKontingent','CheckMedlemsNr',CheckMedlemsNr.Checked);
  Inifile.WriteBool('SeKontingent','CheckMedlemsNavn',CheckMedlemsNavn.Checked);
  Inifile.WriteBool('SeKontingent','CheckAktivitet',CheckAktivitet.Checked);
  IniFile.free;
end;

//**********************************************************
// Luk
//**********************************************************
procedure TFormKontigentSeAendre.LukExecute(Sender: TObject);
begin
  Close;
end;

//**********************************************************
// UpdateFields
//**********************************************************
procedure TFormKontigentSeAendre.UpdateFields;

Begin
  With ZQueryMedlem.SQL do
    Begin
      Clear;
      Add('Select * from medlem where MedlemsNr = ' + ZQueryKontingent.FieldByName('MedlemsNr').AsString);
    End;
  ZQueryMedlem.Open;
  LabelMedlemNavn.Caption := ZQueryMedlem.FieldByName('Fornavn').AsString + ' ' +
    ZQueryMedlem.FieldByName('Efternavn').AsString;
end;

//**********************************************************
// Navigator click
//**********************************************************
procedure TFormKontigentSeAendre.DBNavigator1Click(Sender: TObject;
  Button: TDBNavButtonType);
begin
  UpdateFields;
end;

//**********************************************************
// Combo periode change
//**********************************************************
procedure TFormKontigentSeAendre.ComboPeriodeChange(Sender: TObject);
begin
  IndstilKontingent;
end;

procedure TFormKontigentSeAendre.DataFraKontigentDataChange(Sender: TObject;
  Field: TField);
begin

end;

//**********************************************************
// ComboMedlem change
//**********************************************************
procedure TFormKontigentSeAendre.ComboMedlemChange(Sender: TObject);
begin
  With ZQueryKontingent.SQL do
    Begin
      Clear;
      Add('Select * from kontingent where (afd = '+ CurrentAfd +
        ') and (periodeid = ' + ComboPeriode.Cells[1,ComboPeriode.ItemIndex] + ')' +
        ' and (medlemsnr = ' + ComboMedlem.Cells[2,ComboMedlem.ItemIndex] + ')' +
        ' order by ' + ComboSortering.Cells[1,ComboSortering.ItemIndex]);
    End;
  ZQueryKontingent.Open;
  TDateField(ZQueryKontingent.FieldByName('GiroBilagsNummer')).DisplayFormat:='#0';
  UpdateFields;
end;

//**********************************************************
// Indlæs periode
//**********************************************************
procedure TFormKontigentSeAendre.IndlaesPeriode;
Var A : Integer;
begin
  // Find Periode
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from periodedef');
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount = 0 Then
    Begin
      MessageDlg('Ingen periode er defineret!',mtInformation,[mbOk],0);
      Exit;
    end;
  // Combo gøres klar
  A := 0;
  ComboPeriode.Clear;
  ComboPeriode.Columns.add;
  ComboPeriode.Columns.add;
  ComboPeriode.Columns.Items[0].Width   := ComboPeriode.Width;
  ComboPeriode.Columns.Items[0].Color   := $00A6FFFF;
  ComboPeriode.Columns.Items[1].Visible := False;
  ZQuery1.First;
  While not ZQuery1.Eof Do
    Begin
      If (ZQuery1.FieldByName('Afd').AsString = CurrentAfd) and
         (ZQuery1.FieldByName('Afsluttet').AsString <> '1') Then
         Begin
           ComboPeriode.AddRow;
           ComboPeriode.Cells[0,A] := ZQuery1.FieldByName('Periode').AsString;
           ComboPeriode.Cells[1,A] := ZQuery1.FieldByName('Nr').AsString;
           Inc(A);
         end;
      ZQuery1.Next;
    End;
  // Vælg default
  ComboPeriode.ItemIndex := 0;
end;

//**********************************************************
// Indstil kontingent
//**********************************************************
procedure TFormKontigentSeAendre.IndstilKontingent;

Begin
  With ZQueryKontingent.SQL do
    Begin
      Clear;
      Add('Select * from kontingent where (afd = '+ CurrentAfd +
        ') and (periodeid = ' + ComboPeriode.Cells[1,ComboPeriode.ItemIndex] + ')' +
        ' order by ' + ComboSortering.Cells[1,ComboSortering.ItemIndex]);
    End;
  ZQueryKontingent.Open;
  TDateField(ZQueryKontingent.FieldByName('GiroBilagsNummer')).DisplayFormat:='#0';
end;


//**********************************************************************
//  Indlæs medlemmer til combo
//**********************************************************************
procedure TFormKontigentSeAendre.IndlaesMedlemmer;
Var A : Integer;
Begin
  // Find Medlemmer
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from medlem');
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount = 0 Then
    Begin
      MessageDlg('Ingen medlemmer er defineret!',mtInformation,[mbOk],0);
      Exit;
    end;
  // Combo gøres klar
  A := 0;
  ComboMedlem.Clear;
  ComboMedlem.Columns.add;
  ComboMedlem.Columns.add;
  ComboMedlem.Columns.add;
  ComboMedlem.Columns.Items[0].Width   := ComboMedlem.Width;
  ComboMedlem.Columns.Items[0].Color   := $00A6FFFF;
  ComboMedlem.Columns.Items[1].Visible := False;
  ComboMedlem.Columns.Items[2].Visible := False;
  ZQuery1.First;
  While not ZQuery1.Eof Do
    Begin
      ComboMedlem.AddRow;
      ComboMedlem.Cells[0,A] := ZQuery1.FieldByName('Fornavn').AsString + ' ' +
        ZQuery1.FieldByName('Efternavn').AsString;
      ComboMedlem.Cells[1,A] := ZQuery1.FieldByName('brugermedlemsnr').AsString;
      ComboMedlem.Cells[2,A] := ZQuery1.FieldByName('Medlemsnr').AsString;
      Inc(A);
      ZQuery1.Next;
    End;
  // Vælg default
  ComboMedlem.ItemIndex := 0;
End;

//**********************************************************
// Indlæs Sortering
//**********************************************************
procedure TFormKontigentSeAendre.IndlaesSortering;
Var A : Integer;
begin
  // Combo gøres klar
  A := 0;
  ComboSortering.Clear;
  ComboSortering.Columns.add;
  ComboSortering.Columns.add;
  ComboSortering.Columns.Items[0].Width   := ComboSortering.Width;
  ComboSortering.Columns.Items[0].Color   := $00A6FFFF;
  ComboSortering.Columns.Items[1].Visible := False;
  // Indsæt
  ComboSortering.AddRow;
  ComboSortering.Cells[0,A] := 'Indbetalingsnr';
  ComboSortering.Cells[1,A] := 'GirobilagsNummer';
  Inc(A);
  ComboSortering.AddRow;
  ComboSortering.Cells[0,A] := 'Status';
  ComboSortering.Cells[1,A] := 'Afsluttet';
  Inc(A);
  ComboSortering.AddRow;
  ComboSortering.Cells[0,A] := 'PrisKategori';
  ComboSortering.Cells[1,A] := 'PrisType';
  Inc(A);
  // Vælg default
  ComboSortering.ItemIndex := 0;
end;

//**********************************************************************
//  Indlæs konti
//**********************************************************************
procedure TFormKontigentSeAendre.IndlaesKonti;
Var A : Integer;
Begin
  // Find Medlemmer
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from kontobes where (Afd = ' + CurrentAfd +
           ') and (Type < 2) ');
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount = 0 Then
    Begin
      MessageDlg('Ingen konti er defineret!',mtInformation,[mbOk],0);
      Exit;
    end;
  // Combo gøres klar
  A := 0;
  ComboKonto.Clear;
  ComboKonto.Columns.add;
  ComboKonto.Columns.add;
  ComboKonto.Columns.add;
  ComboKonto.Columns.Items[0].Width   := ComboKonto.Width;
  ComboKonto.Columns.Items[0].Color   := $00A6FFFF;
  ComboKonto.Columns.Items[1].Visible := False;

  ComboAfstemning.Clear;
  ComboAfstemning.Columns.add;
  ComboAfstemning.Columns.add;
  ComboAfstemning.Columns.Items[0].Width   := ComboAfstemning.Width;
  ComboAfstemning.Columns.Items[0].Color   := $00A6FFFF;
  ComboAfstemning.Columns.Items[1].Visible := False;

  ZQuery1.First;
  While not ZQuery1.Eof Do
    Begin
      ComboKonto.AddRow;
      ComboKonto.Cells[0,A] := ZQuery1.FieldByName('Beskrivelse').AsString;
      ComboKonto.Cells[1,A] := ZQuery1.FieldByName('id').AsString;
      ComboAfstemning.AddRow;
      ComboAfstemning.Cells[0,A] := ZQuery1.FieldByName('Beskrivelse').AsString;
      ComboAfstemning.Cells[1,A] := ZQuery1.FieldByName('id').AsString;
      Inc(A);
      ZQuery1.Next;
    End;
  // Vælg default
  ComboKonto.ItemIndex := 0;
  ComboAfstemning.ItemIndex := 0;
End;

end.

