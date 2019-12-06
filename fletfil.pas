//***************************************************************************//
//  Holbæk                                                                   //
//  Copyright by Claus Moeller 2013-2014                                     //
//  Udskriv send indbetalingskort                                            //
//  Version                                                                  //
//  03.12.14                                                                 //
//***************************************************************************//
unit FletFil;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  Menus, ActnList, ExtCtrls, StdCtrls, EditBtn, Grids, Buttons,
  JLabeledCurrencyEdit, clmCombobox, ZDataset;

type

  { TFormFletFil }

  TFormFletFil = class(TForm)
    Udskriv: TAction;
    ActionList1: TActionList;
    AktivitetSpeedAll: TAction;
    AktivitetSpeedNone: TAction;
    CheckAktiviteter: TCheckBox;
    CheckAktiviteter1: TCheckBox;
    ComboMedlem: TclmCombobox;
    ComboPeriode: TclmCombobox;
    DatoUdFra: TDateEdit;
    DatoRetFra: TDateEdit;
    DatoRetTil: TDateEdit;
    DatoUdTil: TDateEdit;
    GenererIndbetalingskort: TAction;
    GridAktiviteter: TStringGrid;
    GridAktiviteter1: TStringGrid;
    GroupBox1: TGroupBox;
    Help: TAction;
    ImageList1: TImageList;
    ImageList2: TImageList;
    CurrencyEdit1: TJLabeledCurrencyEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    LabelMedlemMaerke: TLabel;
    Luk: TAction;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    PageColor1: TShape;
    PageColor2: TShape;
    PageColor3: TShape;
    PageControl1: TPageControl;
    PopupMenu1: TPopupMenu;
    RadioAktivt: TRadioButton;
    RadioMark: TRadioButton;
    RadioMedlem: TRadioButton;
    RadioStatus: TRadioGroup;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    VaelgAktivitetAlle: TSpeedButton;
    VaelgAktivitetAlle1: TSpeedButton;
    VaelgIngenAktivitet: TSpeedButton;
    VaelgIngenAktivitet1: TSpeedButton;
    ZQuery1: TZQuery;
    ZQueryKontingent: TZQuery;
    procedure AktivitetSpeedAllExecute(Sender: TObject);
    procedure AktivitetSpeedNoneExecute(Sender: TObject);
    procedure CheckAktiviteterClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure LukExecute(Sender: TObject);
    procedure RadioAktivtClick(Sender: TObject);
    procedure RadioMarkClick(Sender: TObject);
    procedure RadioMedlemClick(Sender: TObject);
    procedure UdskrivExecute(Sender: TObject);
  private
    { private declarations }
    KontingentList : TStringList;
    MaerkeBesk     : String;      // Ved søgning på mærke
    MaerkeNr       : String;
    procedure IndlaesPeriode;
    procedure IndstilAktiviteter;
    procedure IndlaesAktiviteter;
    procedure IndlaesMedlemmer;
    procedure IndlaesMaerker;
    procedure FindGiroKort;
  public
    { public declarations }
  end;

var
  FormFletFil: TFormFletFil;

implementation

{$R *.lfm}

Uses HolbaekConst, KonaUdsk;

{ TFormFletFil }

Const
  AktCheck              : Integer = 0;
  AktNavn               : Integer = 1;
  AktNr                 : Integer = 2;

//**********************************************************
// Create
//**********************************************************
procedure TFormFletFil.FormCreate(Sender: TObject);
begin
  Top  := 10;
  Left := 30;
  ShowHint               := True;
  // Farver
  Color                  := H_Window_Baggrund;
  ToolBar1.Color         := H_Menu_knapper_Farve;

  PageColor1.Brush.Color := H_Page_Color;
  PageColor1.Align       := alClient;
  ComboPeriode.Color     := H_Combo_Color;
  DatoUdFra.Color        := H_Edit_Baggrund;
  DatoUdFra.Date         := StrToDate('01-01-1900');
  DatoUdTil.Color        := H_Edit_Baggrund;
  DatoUdTil.Date         := StrToDate('01-01-2100');
  DatoRetFra.Color       := H_Edit_Baggrund;
  DatoRetFra.Date        := StrToDate('01-01-1900');
  DatoRetTil.Color       := H_Edit_Baggrund;
  DatoRetTil.Date        := StrToDate('01-01-2100');
  RadioStatus.Color      := H_Radio_Color;

//  PageColor2.Brush.Color := H_Page_Color;
  PageColor2.Align       := alClient;


  PageColor3.Brush.Color := H_Page_Color;
  PageColor3.Align       := alClient;
  ComboMedlem.Color      := H_Combo_Color;

(*  ComboPeriode.Color     := H_Combo_Color;
  MaskUdsendelse.Color   := H_Edit_Baggrund;
  MaskRettidig.Color     := H_Edit_Baggrund;
  EditDage.Color         := H_Edit_Baggrund;*)

  // Database
(*  ZQuery1.Connection          := MainForm.ZConnection1;
  ZQueryKontingent.Connection := MainForm.ZConnection1;*)
  // Indstil
  KontingentList := TStringList.Create; { Liste hvis girokort skal udskrives }
  KontingentList.Sorted := False;

  // Indlæs
  IndlaesPeriode;
  IndstilAktiviteter;
  IndlaesAktiviteter;
end;

//**********************************************************
// Destroy
//**********************************************************
procedure TFormFletFil.FormDestroy(Sender: TObject);
begin
  KontingentList.Free;
end;

//**********************************************************
// Check aktiviteter
//**********************************************************
procedure TFormFletFil.CheckAktiviteterClick(Sender: TObject);
begin
  GridAktiviteter.Visible     := Not GridAktiviteter.Visible;
  VaelgAktivitetAlle.Visible  := GridAktiviteter.Visible;
  VaelgIngenAktivitet.Visible := GridAktiviteter.Visible;
end;

//**********************************************************
// Luk
//**********************************************************
procedure TFormFletFil.LukExecute(Sender: TObject);
begin
  Close;
end;

//**********************************************************
// Radio IkkeAktivt
//**********************************************************
procedure TFormFletFil.RadioAktivtClick(Sender: TObject);
begin
  LabelMedlemMaerke.Visible := False;
  ComboMedlem.Visible       := False;
end;

//**********************************************************
// Radio Mærke
//**********************************************************
procedure TFormFletFil.RadioMarkClick(Sender: TObject);
begin
  LabelMedlemMaerke.Visible := True;
  ComboMedlem.Visible       := True;
  IndlaesMaerker;
end;

//**********************************************************
// Radio Medlem
//**********************************************************
procedure TFormFletFil.RadioMedlemClick(Sender: TObject);
begin
  LabelMedlemMaerke.Visible := True;
  ComboMedlem.Visible       := True;
  IndlaesMedlemmer;
end;

//**********************************************************
// Udskriv
//**********************************************************
procedure TFormFletFil.UdskrivExecute(Sender: TObject);
begin
  If RadioStatus.ItemIndex <> 1 Then
    Begin
      If MessageDlg('Indbetalingskort som er afsluttet - bør ikke udskrives igen. Fortsæt?',
      mtWarning,[mbYes,mbNo],0) = mrNo Then Exit;
    End;
  FindGiroKort; { Genererer liste }
  { Liste skal overføres til Konaudsk }
  Cursor := crHourGlass;
  KonGiroUdskriv := TKonGiroUdskriv.Create(Self);
  KonGiroUdskriv.KontingentList.Assign(KontingentList);
//  KongiroUdskriv.SortAdresse := (MedlemSortering.ItemIndex = 2); // Sort adresse
  KongiroUdskriv.MaerkeBesk  := MaerkeBesk; // Ved søgning på mærke
  KongiroUdskriv.MaerkeNr    := MaerkeNr;
  KontingentList.Clear;
  KonGiroUdskriv.ShowList;
  KonGiroUdskriv.ShowModal;
  KonGiroUdskriv.Close;
  Cursor := crDefault;
end;

//**********************************************************
// Aktivitet vælg alle
//**********************************************************
procedure TFormFletFil.AktivitetSpeedAllExecute(Sender: TObject);
Var A : Integer;
begin
  A := 1;
  While A < GridAktiviteter.RowCount Do
    Begin
      GridAktiviteter.Cells[AktCheck,A] := '1';
      Inc(A);
    end;
end;

//**********************************************************
// Aktivitet vælg ingen
//**********************************************************
procedure TFormFletFil.AktivitetSpeedNoneExecute(Sender: TObject);
Var A : Integer;
begin
  A := 1;
  While A < GridAktiviteter.RowCount Do
    Begin
      GridAktiviteter.Cells[AktCheck,A] := '0';
      Inc(A);
    end;
end;

//**********************************************************
// Indlæs periode
//**********************************************************
procedure TFormFletFil.IndlaesPeriode;
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
  // Default
  ComboPeriode.AddRow;
  ComboPeriode.Cells[0,A] := '***';
  ComboPeriode.Cells[1,A] := '-1';
  Inc(A);
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


//**********************************************************************
// Indstil Aktiviteter
//**********************************************************************
procedure TFormFletFil.IndstilAktiviteter;
Begin
  GridAktiviteter.RowCount := 1;
  Indstil_StringGrid_NonEdit(GridAktiviteter);
  GridAktiviteter.Columns.Clear;
  GridAktiviteter.Columns.Add;
  GridAktiviteter.Columns.Add;
  GridAktiviteter.Columns.Add;
  GridAktiviteter.Columns[AktCheck].Title.Caption   := '*';
  GridAktiviteter.Columns[AktCheck].Width           := 20;
  GridAktiviteter.Columns[AktCheck].ButtonStyle     := cbsCheckboxColumn;

  GridAktiviteter.Columns[AktNavn].Title.Caption    := 'Aktivitet';
  GridAktiviteter.Columns[AktNavn].Width            := 200;
  GridAktiviteter.Columns[AktNavn].Alignment        := taLeftJustify;

  GridAktiviteter.Columns[AktNr].Title.Caption      := 'Nr';
  GridAktiviteter.Columns[AktNr].Width              := 50;
  GridAktiviteter.Columns[AktNr].Alignment          := taLeftJustify;
  GridAktiviteter.Columns[AktNr].Visible            := False;

  GridAktiviteter.Options := GridAktiviteter.Options +
    [goRowSelect, goEditing, goTabs] - [goHorzLine, goVertLine];
end;

//**********************************************************************
// Indlaes Aktiviteter
//**********************************************************************
procedure TFormFletFil.IndlaesAktiviteter;
Begin
  GridAktiviteter.RowCount := 1;
  //  GridAktiviteter.BeginUpdate;
  // Find aktiviteter i denne afd
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from aktiviteter where afd = ' + CurrentAfd);
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount = 0 Then
    Begin
      MessageDlg('Ingen aktiviteter defineret!',mtInformation,[mbOk],0);
      Exit;
    end;
  ZQuery1.First;
  While not ZQuery1.EOF Do
    Begin
      If ZQuery1.FieldByName('Vis').AsString = '1' Then
        Begin
          GridAktiviteter.RowCount := GridAktiviteter.RowCount + 1;
          GridAktiviteter.Cells[AktCheck,GridAktiviteter.RowCount-1] := '1';
          GridAktiviteter.Cells[AktNavn,GridAktiviteter.RowCount-1] :=
            ZQuery1.FieldByName('Beskrivelse').AsString;
          GridAktiviteter.Cells[AktNr,GridAktiviteter.RowCount-1] :=
            ZQuery1.FieldByName('BaneDefNr').AsString;
        End;
      ZQuery1.Next;
    End;
//  GridAktiviteter.EndUpdate;
End;

//**********************************************************************
// Indlaes Medlemmer
//**********************************************************************
procedure TFormFletFil.IndlaesMedlemmer;
Var A : Integer;
Begin
  // Find medlemmer
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from medlem order by Efternavn');
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount = 0 Then
    Begin
      MessageDlg('Ingen medlemmer fundet!',mtInformation,[mbOk],0);
      Exit;
    end;
  A := 0;
  ComboMedlem.Clear;
  ComboMedlem.Columns.Add;
  ComboMedlem.Columns.Add;
  ComboMedlem.Columns.Items[0].Width   := ComboMedlem.Width;
  ComboMedlem.Columns.Items[0].Color   := $00A6FFFF;
  ComboMedlem.Columns.Items[1].Visible := False;
  ZQuery1.First;
  While not ZQuery1.Eof Do
    Begin
      ComboMedlem.AddRow;
      ComboMedlem.Cells[0,A] := ZQuery1.FieldByName('Fornavn').AsString + ' ' +
        ZQuery1.FieldByName('Efternavn').AsString;
      ComboMedlem.Cells[1,A] := ZQuery1.FieldByName('MedlemsNr').AsString;
      Inc(A);
      ZQuery1.Next;
    End;
  // Vælg default
  ComboMedlem.ItemIndex := 0;
End;

//**********************************************************************
// Indlaes Mærker
//**********************************************************************
procedure TFormFletFil.IndlaesMaerker;
Var A : Integer;
Begin
  // Find medlemmer
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from markdef order by beskrivelse');
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount = 0 Then
    Begin
      MessageDlg('Ingen mærker fundet!',mtInformation,[mbOk],0);
      Exit;
    end;
  A := 0;
  ComboMedlem.Clear;
  ComboMedlem.Columns.Add;
  ComboMedlem.Columns.Add;
  ComboMedlem.Columns.Items[0].Width   := ComboMedlem.Width;
  ComboMedlem.Columns.Items[0].Color   := $00A6FFFF;
  ComboMedlem.Columns.Items[1].Visible := False;
  ZQuery1.First;
  While not ZQuery1.Eof Do
    Begin
      ComboMedlem.AddRow;
      ComboMedlem.Cells[0,A] := ZQuery1.FieldByName('Beskrivelse').AsString;
      ComboMedlem.Cells[1,A] := ZQuery1.FieldByName('Id').AsString;
      Inc(A);
      ZQuery1.Next;
    End;
  // Vælg default
  ComboMedlem.ItemIndex := 0;
End;

//**********************************************************************
//  FindGiroKort
//**********************************************************************
procedure TFormFletFil.FindGiroKort;

Type SpillerType = Array[1..3] of String;

var
  Naeste                  : Boolean;
  HelpStr                 : String;
  PosInList               : Integer;
  Nr                      : Integer;
  Stop                    : Boolean;

Begin
  // Løb igennem Kontingent record for record
  With ZQueryKontingent.SQL do
    Begin
      Clear;
      Add('Select * from kontingent where (afd = ' + CurrentAfd + ')');
    End;
  ZQueryKontingent.Open;
  If ZQueryKontingent.RecordCount = 0 Then
    Begin
      MessageDlg('Ingen indbetalingskort fundet!',mtInformation,[mbOk],0);
      Exit;
    end;
  Naeste := False;
  PosInList := 0;
  KontingentList.Clear;
  // Husk mærkerne til senere at kunne flette
  MaerkeBesk := '';
  MaerkeNr   := '';
  If RadioMark.Checked Then
    Begin
      MaerkeBesk := ComboMedlem.Cells[0,ComboMedlem.ItemIndex];
      MaerkeNr   := ComboMedlem.Cells[1,ComboMedlem.ItemIndex];
    End;
  While Not ZQueryKontingent.EOF Do
    Begin
      {If ZQueryKontingent.FieldByName('Afsluttet').AsString <> '1' Then
        ShowMessage(ZQueryKontingent.FieldByName('Afsluttet').AsString);}

      { ** Check med maske - felt for felt }
      { ** Dato for udsendelse efter }
      If Not Naeste Then
        Begin
          Naeste :=  Not (
            ZQueryKontingent.FieldByName('DatoForUdsendelse').AsDateTime >=
             DatoUdFra.Date);
        End;
      { ** Dato for udsendelse før }
      If Not Naeste Then
        Begin
          Naeste :=  Not (
            ZQueryKontingent.FieldByName('DatoForUdsendelse').AsDateTime <=
             DatoUdTil.Date);
        End;
      { ** Dato for rettidig indbetaling efter }
      If Not Naeste Then
        Begin
          Naeste :=  Not (
            ZQueryKontingent.FieldByName('SenestRettidigIndbetaling').AsDateTime
            >= DatoRetFra.Date);
        End;
      { ** Dato for rettidig indbetaling før }
      If Not Naeste Then
        Begin
          Naeste :=  Not (
            ZQueryKontingent.FieldByName('SenestRettidigIndbetaling').AsDateTime
            <= DatoRetTil.Date);
        End;
      { ** Periode }
      If Not Naeste and Not (ComboPeriode.Text = '***') Then
        Begin
          Naeste :=  Not (
           ZQueryKontingent.FieldByName('PeriodeId').AsString =
             ComboPeriode.Cells[1,ComboPeriode.ItemIndex]);
        End;
      // ** Kontingent beløb
      If (Not Naeste) And (CurrencyEdit1.Value <> 0) Then
        Begin
          Naeste :=  Not (
            ZQueryKontingent.FieldByName('BeloebOpkraevet').AsFloat
            = CurrencyEdit1.Value);
        End;
      { ** Status }
      If (Not Naeste) And (RadioStatus.ItemIndex <> 3) Then
        Begin
          Naeste :=  Not (
            ZQueryKontingent.FieldByName('Afsluttet').AsInteger =
              RadioStatus.ItemIndex);
        End;
      { ** Beskrivelse i den advancerede }
      If (Not Naeste) And (CheckAktiviteter.State = cbChecked) Then
        Begin
          Nr := GridAktiviteter.Cols[1].IndexOf(
            ZQueryKontingent.FieldByName('BaneDefNr').AsString);
          Naeste := Not ((Nr <> -1) and (
            GridAktiviteter.Cells[0,Nr] = '1'));
        End;
      // Check medlem
      If (Not Naeste) And RadioMedlem.Checked Then
        Begin
          Naeste := (ZQueryKontingent.FieldByName('MedlemsNr').AsString <>
            ComboMedlem.Cells[1,ComboMedlem.ItemIndex]);
        End;
      // Check mærke
      If (Not Naeste) And RadioMark.Checked Then
        Begin
          With ZQuery1.SQL do
            Begin
              Clear;
              Add('Select * from marks where (MedlemsNr = ' +
                ZQueryKontingent.FieldByName('MedlemsNr').AsString + ')');
            End;
          ZQuery1.Open;
          If ZQuery1.RecordCount = 0 Then
            Begin
              //MessageDlg('Ingen indbetalingskort fundet!',mtInformation,[mbOk],0);
              //Exit;
              Naeste := True;
            end
          Else
            Begin  // Fundet et mærke på medlem
              Naeste := False;
            end;
        End;
      If Not Naeste Then
        Begin // Liste hvis girokort skal udskrives
          // I base Medlem skal oplysninger på medlemmet findes}
          // ShowMessage(ZQueryKontingent.FieldByName('MedlemsNr').AsString);
          KontingentList.Add(ZQueryKontingent.FieldByName('GiroBilagsNummer').AsString);
(*          MedlemTabel.First;
          MedlemTabel.SetKey; { Gør klar til søgning }
          MedlemTabel.FieldByName('MedlemsNr').AsFloat :=
            ZQueryKontingent.FieldByName('MedlemsNr').AsFloat;
          If MedlemTabel.GotoKey Then
            Begin
              HelpStr := MedlemTabel.FieldByName('Efternavn').AsString;
              { Afhængig af sortering skal der sorteres }
              Case MedlemSortering.ItemIndex of
                0 : PosInList :=   { MedlemsNr}
                  HelpSortList.Add(MedlemTabel.FieldByName('MedlemsNr').AsString);
                1 : PosInList :=   { Efternavn}
                  HelpSortList.Add(MedlemTabel.FieldByName('Efternavn').AsString);
                2 : PosInList :=   { Adr1 }
                  HelpSortList.Add(MedlemTabel.FieldByName('Adr1').AsString);
                3 : PosInList :=   { Telefon }
                  HelpSortList.Add(MedlemTabel.FieldByName('Telefon').AsString);
              End; { End Case}
              { GiroNummer indsættes i Liste }
              KontingentList.Insert(PosInList,
                ZQueryKontingent.FieldByName('GiroBilagsNummer').AsString);
            End
          Else
            Begin
              MessageDlg('Medlem kunne ikke findes',mtError,[mbOk],0);
            End;*)
        End;
      ZQueryKontingent.Next;
      Naeste := False;
    End;
end;

end.

