//***************************************************************************//
//  Holbæk                                                                   //
//  Copyright by Claus Moeller 2013-2014                                     //
//  Generer indbetalingskort manuelt                                         //
//  Version                                                                  //
//  08.11.14                                                                 //
//***************************************************************************//
unit KonManuel;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  Menus, ActnList, Grids, ExtCtrls, StdCtrls, Buttons, ZDataset, IniFiles,
  clmCombobox, JLabeledIntegerEdit, JLabeledCurrencyEdit, JLabeledDateEdit;

type

  { TKontingentManuelForm }

  TKontingentManuelForm = class(TForm)
    GenererIndbetalingskort: TAction;
    FindMedlem: TAction;
    AntalEdit: TJLabeledIntegerEdit;
    IntervalCombo: TComboBox;
    AntalDageIntervalEdit: TJLabeledIntegerEdit;
    IntervalLabel: TLabel;
    EditMedNr: TJLabeledIntegerEdit;
    RettidigLabel: TLabel;
    RettidigCombo: TComboBox;
    GroupBox3: TGroupBox;
    RettidigDate: TJLabeledDateEdit;
    SpeedFindMedlem: TSpeedButton;
    StartDate: TJLabeledDateEdit;
    RadioEngang: TRadioButton;
    RadioLoebende: TRadioButton;
    ActionList1: TActionList;
    CheckBoxRabat: TCheckBox;
    ComboPrisKategori: TclmCombobox;
    ComboPeriode: TclmCombobox;
    ComboMedlem: TclmCombobox;
    AltTekstEdit: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Help: TAction;
    ImageList1: TImageList;
    EditPris: TJLabeledCurrencyEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Luk: TAction;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    PageControl1: TPageControl;
    Panel1: TPanel;
    PopupMenu1: TPopupMenu;
    PageColor2: TShape;
    PageColor1: TShape;
    RadioMedlem: TRadioButton;
    RadioMaerke: TRadioButton;
    SpeedButton1: TSpeedButton;
    StringGrid1: TStringGrid;
    StringGridRabat: TStringGrid;
    TabSheet1: TTabSheet;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ZQuery1: TZQuery;
    ZQueryMedlem: TZQuery;
    ZQueryRabatDef: TZQuery;
    ZQueryRabatKategori: TZQuery;
    procedure AltTekstEditExit(Sender: TObject);
    procedure AntalEditExit(Sender: TObject);
    procedure CheckBoxRabatChange(Sender: TObject);
    procedure ComboMedlemChange(Sender: TObject);
    procedure ComboPeriodeChange(Sender: TObject);
    procedure ComboPrisKategoriChange(Sender: TObject);
    procedure EditMedNrExit(Sender: TObject);
    procedure EditPrisExit(Sender: TObject);
    procedure FindMedlemExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure GenererIndbetalingskortExecute(Sender: TObject);
    procedure HelpExecute(Sender: TObject);
    procedure IntervalComboChange(Sender: TObject);
    procedure LukExecute(Sender: TObject);
    procedure RadioEngangChange(Sender: TObject);
    procedure RadioEngangClick(Sender: TObject);
    procedure RadioLoebendeClick(Sender: TObject);
    procedure RadioMaerkeClick(Sender: TObject);
    procedure RadioMedlemClick(Sender: TObject);
    procedure RettidigComboChange(Sender: TObject);
    procedure RettidigDateExit(Sender: TObject);
    procedure SaetDefaultsPrisKategoriExecute(Sender: TObject);
    procedure StartDateExit(Sender: TObject);
  private
    { private declarations }
    IniFile        : TInifile;
    PeriodeStart   : TDatetime;
    PeriodeSlut    : TDateTime;
    PeriodeLaengde : Double;
    HelpInt     : TDateTime; // Bruges til beregning af date
    procedure IndlaesPeriode;
    procedure IndlaesMedlemmer;
    procedure IndlaesMaerker;
    procedure IndlaesPrisKategori;
    procedure Indstil;
    procedure VisPris;
    procedure SoegOpdater;
    Function  BeregnPeriodeDataTilRabat : Boolean;
    Function  DanGiroNummer(Man,Afd,Periode,Nr : String): String;
    Function  CheckRabat(PrisType : String; Var EndeligPris: Double) : Boolean;
    Function  FindManNr(MedlemsNr : String) : String;
    procedure IndlaesRabatter(Pristype: String);
    Function  TaelAktiviteterForMedlem(MedlemsNr : String) : Integer;
  public
    { public declarations }
  end;

var
  KontingentManuelForm: TKontingentManuelForm;

implementation

{$R *.lfm}

Uses HolbaekConst, HolbaekMain, DateUtils;

Const
  GenNr                 : Integer = 0;
  GenNavn               : Integer = 1;
  GenAdr                : Integer = 2;
  GenBeloeb             : Integer = 3;
  GenBesk               : Integer = 4;
  GenBaneDefNr          : Integer = 5;
  GenMedlemsNr          : Integer = 6;
  GenB                  : Integer = 7;

  RabatNr               : Integer = 0;
  RabatType             : Integer = 1;
  RabatEndelig          : Integer = 2;


{ TKontingentManuelForm }

//**********************************************************
// Create
//**********************************************************
procedure TKontingentManuelForm.FormCreate(Sender: TObject);
begin
  Top  := 10;
  Left := 30;
  ShowHint               := True;
  // Farver
  Color                  := H_Window_Baggrund;
  ToolBar1.Color         := H_Menu_knapper_Farve;

  PageColor1.Brush.Color := H_Page_Color;
  PageColor1.Align       := alClient;
  PageColor2.Brush.Color := H_Panel_Overskrift;
  PageColor2.Align       := alClient;
  ComboPeriode.Color     := H_Combo_Color;
  ComboMedlem.Color      := H_Combo_Color;
  ComboPrisKategori.Color:= H_Combo_Color;
  EditPris.Color         := H_Edit_Baggrund;
  AltTekstEdit.Color     := H_Edit_Baggrund;

  StartDate.Color        := H_Edit_Baggrund;
  RettidigDate.Color     := H_Edit_Baggrund;
  IntervalCombo.Color    := H_Combo_Color;
  RettidigCombo.Color    := H_Combo_Color;
  AntalDageIntervalEdit.Color := H_Edit_Baggrund;
  AntalEdit.Color        := H_Edit_Baggrund;
  EditMedNr.Color        := H_Edit_Baggrund;

  // Database
//  ZQuery1.Connection      := MainForm.ZConnection1;
//  ZQueryMedlem.Connection := MainForm.ZConnection1;
//  ZQueryRabatDef.Connection := MainForm.ZConnection1;
//  ZQueryRabatKategori.Connection := MainForm.ZConnection1;
  IniFile := TIniFile.Create(HolbaekIniFile);

  //Lists

  // Indstil
  Indstil;
  StartDate.Value         := Now;
  RettidigDate.Value      := StrToDate(FormatDateTime('dd-mm-yyyy',Date+30));
  RettidigCombo.ItemIndex := 2;

  // Indlæs
  IndlaesPeriode;
  IndlaesMedlemmer;
  IndlaesPrisKategori;
  SoegOpdater;
end;

//**********************************************************************
//  Destroy
//**********************************************************************
procedure TKontingentManuelForm.FormDestroy(Sender: TObject);
begin
  IniFile.Free;
end;

//**********************************************************
// Generer
//**********************************************************
procedure TKontingentManuelForm.GenererIndbetalingskortExecute(Sender: TObject);
Var A           : Integer;
    ManStr      : String;
    B           : Integer;
    HelpBetInt  : TDateTime;
    NrGen       : LongInt;
    IdNr        : Real;
begin
  // Medlemmer nu fundet og skal indsættes i kontingenttabel
  //*** her kunne evt. indsættes dialogboks medliste over de fundne medlemmer
  NrGen := 0;
  A := 1;
  While A < StringGrid1.RowCount Do
    Begin // løb igennem grid
      Try
        // Find ledigt nr
        With ZQuery1.SQL do
          Begin
            Clear;
            Add('Select * from kontingent order by id');
          End;
        ZQuery1.Open;
        If ZQuery1.RecordCount = 0 Then
          Begin // ingen - den første får nummer 1
            IdNr := 1;
          End
        Else
          Begin // Sidste + 1
            IdNr := ZQuery1.RecordCount + 1;
          End;
        ZQuery1.Append;
        ZQuery1.Edit;
        // Id
        ZQuery1.FieldByName('Id').AsFloat   := IdNr;
        // Afd - 1
        ZQuery1.FieldByName('Afd').AsString := CurrentAfd;
        // GiroBilagsnummer - 2
        ZQuery1.FieldByName('GiroBilagsNummer').AsString :=
          StringGrid1.Cells[GenNr,A];
        //  DatoForIndbetalingAfKont - 3
        ZQuery1.FieldByName('DatoForIndbetalingAfKont').AsDateTime :=
          StrToDateTime('11-11-1911');
        // Dato for udsendelse - 4
        If RadioEngang.Checked Then
          Begin // der skal kun genereres et
            // Dato for udsendelse - 4
           ZQuery1.FieldByName('DatoForUdsendelse').AsDateTime :=
              StartDate.Value;
           HelpInt := StartDate.Value;
           // Seneste rettidig indbetaling - 5 }
           ZQuery1.FieldByName('SenestRettidigIndbetaling').AsDateTime :=
              RettidigDate.Value;
          End
        Else
          Begin // flere kontingenter
            B := StrToInt(StringGrid1.Cells[GenB,A]);
            // Interval skal udregenes
            Case IntervalCombo.ItemIndex Of
              0 : Begin  // Manuelt
                    Try
                      HelpInt := StartDate.Value + B *
                        StrToInt(AntalDageIntervalEdit.Text);
                    Except
                      MessageDlg('Dage mellem interval ikke et tal !!!',
                        mtError,[mbOK],0);
                      Exit;
                    End;
                  End;
              1 : Begin  // 7 dage
                    HelpInt := StartDate.Value +  B * 7;
                  End;
              2 : Begin  // 14 dage
                    HelpInt := StartDate.Value + B * 14;
                  End;
              3 : Begin  // Måned
                    HelpInt := IncMonth(StartDate.Value, B);
                  End;
            End; // End case
            // Dato for udsendelse - 4
           ZQuery1.FieldByName('DatoForUdsendelse').AsDateTime :=
              HelpInt;
           // Rettidig indbetaling
            Case RettidigCombo.ItemIndex Of
              0 : Begin  // 7 dage
                    HelpBetInt := HelpInt +  7;
                  End;
              1 : Begin  // 14 dage
                    HelpBetInt := HelpInt + 14;
                  End;
              2,3,4,5,6,7,8,9,10,11,12,13,14 : Begin  // Måneder
                    HelpBetInt := IncMonth(HelpInt,
                      RettidigCombo.ItemIndex - 1);
                  End;
            End; // End case
           // Seneste rettidig indbetaling - 5 }
           ZQuery1.FieldByName('SenestRettidigIndbetaling').AsDateTime :=
              HelpBetInt;
          End;
        // Beløb opkrævet - 6
        ZQuery1.FieldByName('BeloebOpKraevet').AsFloat :=
          StrToFloat(StringGrid1.Cells[GenBeloeb,A]);
        // Beløb indbetalt - 7
        ZQuery1.FieldByName('BeloebIndbetalt').AsFloat := 0;
        // MedlemsNr - 8
        ZQuery1.FieldByName('MedlemsNr').AsString :=
          StringGrid1.Cells[GenMedlemsNr,A];
        // Periode - 9
        ZQuery1.FieldByName('PeriodeId').AsString :=
          ComboPeriode.Cells[1,ComboPeriode.ItemIndex];
        // Rykkere  - 10
        ZQuery1.FieldByName('AntalRykkere').AsInteger := 1;
        // BaneDefNr - 11
        ZQuery1.FieldByName('BaneDefNr').Clear;
        Try
          // PrisType - 12
          If ComboPriskategori.ItemIndex = 0 Then
            Begin
              ZQuery1.FieldByName('PrisType').Clear;
            End
          Else
            Begin
              ZQuery1.FieldByName('PrisType').AsString :=
                ComboPrisKategori.Cells[1,ComboPriskategori.ItemIndex];
            End;
        Except
        End;
        // Afsluttet - 13
        ZQuery1.FieldByName('Afsluttet').AsInteger := 1; {Mangler}
        // Manuel - 14
        ManStr := '';
        ZQuery1.FieldByName('Manuel').AsString := ManStr;
        // AltTekst - 14
        ZQuery1.FieldByName('AltTekst').AsString :=
          StringGrid1.Cells[GenBesk,A];
        // Vaerge - 15
        With ZQueryMedlem.SQL Do
          Begin
            Clear;
            Add('Select * from Medlem where (MedlemsNr = ' +
              StringGrid1.Cells[GenMedlemsNr,A] + ')');
          end;
        ZQueryMedlem.Open;
        If ZQueryMedlem.RecordCount > 0 Then
          Begin
            If Not ZQueryMedlem.FieldByName('Vaerge').IsNull Then
              Begin
                If ZQueryMedlem.FieldByName('VaergeBetal').AsBoolean = True Then
                  Begin
                    ZQuery1.FieldByName('Vaerge').AsInteger :=
                      ZQueryMedlem.FieldByName('Vaerge').AsInteger;
                  End;
              End;
          End;
        // Indsæt Record i Tabel
        ZQuery1.Post;
        //ZQuery1.Cancel;
        Inc(NrGen);
      Except
        // hvis ikke succesfuld
        ZQuery1.Cancel;
        MessageDlg('Fejl ved generering af indbetalingskort',mtError,[mbOk],0);
      End;
      Inc(A);
    End;
  MessageDlg('Der er genereret ' + IntToStr(NrGen) + ' indbetalingskort',mtInformation,[mbOk],0);
  SoegOpdater;
(*  TaskDialog1.Options := [doHyperlinks,doCommandLinks];
  TaskDialog1.Title := 'Oprettelse af indbetalingskort...';
  TaskDialog1.Instruction := 'Der er genereret ' + IntToStr(NrGen) + ' indbetalingskort';
  TaskDialog1.Icon := tiQuestion;
  TaskDialog1.Content := 'Disse indbetalingskort kan nu udskrives, sendes og rettes.';
  TaskDialog1.ExpandedText := TaskExpandTextStd;
  TaskDialog1.ExpandControlText := 'Klik for at gemme';
  TaskDialog1.CollapsControlText := 'Klik for at se mere';
  TaskDialog1.CommonButtons := [cbOK];
  TaskDialog1.Footer := TaskFooterTextStd;
  TaskDialog1.FooterIcon := tfiInformation;
  TaskDialog1.Execute;*)
end;

//**********************************************************
// Hjælp
//**********************************************************
procedure TKontingentManuelForm.HelpExecute(Sender: TObject);
begin
  ShowMessage('Hjælp');
end;

//**********************************************************
// Combo Interval change
//**********************************************************
procedure TKontingentManuelForm.IntervalComboChange(Sender: TObject);
begin
  SoegOpdater;
end;

//**********************************************************************
//  Indstil
//**********************************************************************
procedure TKontingentManuelForm.Indstil;

Begin
  Indstil_StringGrid_NonEdit(StringGrid1);
  StringGrid1.Columns.Clear;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;

  StringGrid1.Columns[GenNr].Title.Caption          := 'Nr';
  StringGrid1.Columns[GenNr].Width                  := 100;
  StringGrid1.Columns[GenNr].Alignment              := taRightJustify;

  StringGrid1.Columns[GenNavn].Title.Caption        := 'Navn';
  StringGrid1.Columns[GenNavn].Width                := 150;
  StringGrid1.Columns[GenNavn].Alignment            := taLeftJustify;

  StringGrid1.Columns[GenAdr].Title.Caption         := 'Adr';
  StringGrid1.Columns[GenAdr].Width                 := 150;
  StringGrid1.Columns[GenAdr].Alignment             := taLeftJustify;

  StringGrid1.Columns[GenBeloeb].Title.Caption      := 'Beløb';
  StringGrid1.Columns[GenBeloeb].Width              := 80;
  StringGrid1.Columns[GenBeloeb].Alignment          := taRightJustify;

  StringGrid1.Columns[GenBesk].Title.Caption        := 'Beskrivelse';
  StringGrid1.Columns[GenBesk].Width                := 150;
  StringGrid1.Columns[GenBesk].Alignment            := taLeftJustify;

  StringGrid1.Columns[GenBaneDefNr].Title.Caption   := 'BaneDefNr';
  StringGrid1.Columns[GenBaneDefNr].Width           := 100;
  StringGrid1.Columns[GenBaneDefNr].Alignment       := taRightJustify;
  StringGrid1.Columns[GenBaneDefNr].Visible         := False;

  StringGrid1.Columns[GenMedlemsNr].Title.Caption   := 'MedlemsNr';
  StringGrid1.Columns[GenMedlemsNr].Width           := 100;
  StringGrid1.Columns[GenMedlemsNr].Alignment       := taRightJustify;
  StringGrid1.Columns[GenMedlemsNr].Visible         := False;

  StringGrid1.Columns[GenB].Title.Caption           := 'BaneDefNr';
  StringGrid1.Columns[GenB].Width                   := 100;
  StringGrid1.Columns[GenB].Alignment               := taRightJustify;
  StringGrid1.Columns[GenB].Visible                 := False;


  PageControl1.Color := H_Menu_knapper_Farve;

//  StringGrid1.Options  := [goTabs];
//  StringGrid1.FocusRectVisible          :=False;
end;

//**********************************************************************
//  Dan Giro nummer
//**********************************************************************
Function TKontingentManuelForm.DanGiroNummer(Man,Afd,Periode,Nr : String): String;
{ Kontrolciffer til indbetaleridentifikation udregnes efter modules 10.
  Postgiro udregner dette på følgende m†de
  Indbetaler:  0  0  1  2  3  4  5  6  7  8  9  0  9  8  6
  Vægttal   :  2  1  2  1  2  1  2  1  2  1  2  1  2  1  2
  produkter :  0  0  2  2  6  4 10  6 14  8 18  0 18  8 12
  tæller    :  0  0  2  2  6  4  1  6  5  8  9  0  9  8  3 = 63

  63 : 10 = 6 rest 3
  kontrolciffer  10 - 3 = 7
  }

Const
  VaegtArray : Array[1..15] of Byte = (2,1,2,1,2,1,2,1,2,1,2,1,2,1,2);
  Indbetaler : Array[1..15] of Byte = (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
  Produkter  : Array[1..15] of Byte = (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
  Taeller    : Array[1..15] of Byte = (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);

Var
  A    : Byte;
  Sum  : Byte;
  Rest : Byte;
  KontrolCiffer : Byte;
  ResultString  : String;

Begin
  { Dan indbetaler kode }
{  For A := 1 to 15 Do Indbetaler[A] := 0;}
  For A := 1 To 4 Do If Nr[A] = ' ' Then Nr[A] := '0';
  For A := 1 To 4 Do If Man[A] = ' ' Then Man[A] := '0';
  If StrToInt(Afd) < 10 Then
    Begin
      Afd := '0' + Afd;
    End;
  Indbetaler[2]:= Ord(Man[1])-48;
  Indbetaler[3]:= Ord(Man[2])-48;
  Indbetaler[4]:= Ord(Man[3])-48;
  Indbetaler[5]:= Ord(Man[4])-48;
  Indbetaler[6]:= Ord(Afd[1])-48;
  Indbetaler[7] := Ord(Afd[2])-48;
  Indbetaler[8] := Ord(Periode[1])-48;
  Indbetaler[9] := Ord(Periode[2])-48;
  Indbetaler[10]:= Ord(Periode[3])-48;
  Indbetaler[11] := Ord(Periode[4])-48;
  Indbetaler[12]:= Ord(Nr[1])-48;
  Indbetaler[13]:= Ord(Nr[2])-48;
  Indbetaler[14]:= Ord(Nr[3])-48;
  Indbetaler[15]:= Ord(Nr[4])-48;
  { Dan ProduktArray }
  For A := 1 to 15 Do
    Begin
      Produkter[A] := Indbetaler[A] * VaegtArray[A];
    End;
  { Dan TaellerArray }
  For A := 1 To 15 Do
    Begin
      If Produkter[A] > 9 Then
        Begin
          Taeller[A] := Produkter[A]-10+1; { Tv‘rsum - tal altid < 20 }
        End
      Else
        Begin
          Taeller[A] := Produkter[A];
        End;
    End;
  {Dan Sum }
  Sum := 0;
  For A := 1 to 15 Do
    Begin
      Sum := Sum + Taeller[A];
    End;
  Rest := Sum mod 10;
  If Rest = 0 Then
    KontrolCiffer := 0
  Else
    KontrolCiffer := 10 - Rest;
  { Dan result string }
  SetLength(ResultString,15);
  For A := 1 To 15 Do
    Begin
      ResultString[A] := Chr(Indbetaler[A]+48);
    End;
  ResultString := ResultString + Chr(KontrolCiffer+48);
  DanGiroNummer := ResultString;
End;


//**********************************************************************
//  Find manuelt nr
//**********************************************************************
function TKontingentManuelForm.FindManNr(MedlemsNr : String) : String;
Var HelpStr : String;
begin
  // Find Periode
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from kontingent where (afd = ' +
        CurrentAfd + ') and (PeriodeId = ' + ComboPeriode.Cells[1,ComboPeriode.ItemIndex] +
        ') and (Medlemsnr = ' + MedlemsNr + ')');
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount = 0 Then
    Begin // ingen - den første får nummer 1
      FindManNr := '0001';
    End
  Else
    Begin // Sidste + 1
      Str((ZQuery1.RecordCount + 1) : 4, HelpStr);
      FindManNr := HelpStr;
    End;
end;


//**********************************************************************
//  Priskategori change
//**********************************************************************
procedure TKontingentManuelForm.ComboPriskategoriChange(Sender: TObject);
begin
  VisPris;
  SoegOpdater;
end;

//**********************************************************
// Edit medlem change
//**********************************************************
procedure TKontingentManuelForm.EditMedNrExit(Sender: TObject);
begin
  SoegOpdater;
end;

//**********************************************************
// Edit pris exit
//**********************************************************
procedure TKontingentManuelForm.EditPrisExit(Sender: TObject);
begin
  SoegOpdater;
end;

//**********************************************************
// Combo Periode change
//**********************************************************
procedure TKontingentManuelForm.ComboPeriodeChange(Sender: TObject);
begin
  SoegOpdater;
end;

//**********************************************************
// Combo medlem change
//**********************************************************
procedure TKontingentManuelForm.ComboMedlemChange(Sender: TObject);
begin
  SoegOpdater;
end;

//**********************************************************
// Alt tekst exit
//**********************************************************
procedure TKontingentManuelForm.AltTekstEditExit(Sender: TObject);
begin
  SoegOpdater;
end;

//**********************************************************
// Edit antal exit
//**********************************************************
procedure TKontingentManuelForm.AntalEditExit(Sender: TObject);
begin
  SoegOpdater;
end;

//**********************************************************
// Check rabat
//**********************************************************
procedure TKontingentManuelForm.CheckBoxRabatChange(Sender: TObject);
begin
  SoegOpdater;
end;

//**********************************************************
// Find medlem
//**********************************************************
procedure TKontingentManuelForm.FindMedlemExecute(Sender: TObject);
begin
  ShowMessage('Hallo Finn');
end;

//**********************************************************
// Luk
//**********************************************************
procedure TKontingentManuelForm.LukExecute(Sender: TObject);
begin
  Close;
end;

procedure TKontingentManuelForm.RadioEngangChange(Sender: TObject);
begin

end;


//**********************************************************************
//  Radio Et indbetalingskort
//**********************************************************************
procedure TKontingentManuelForm.RadioEngangClick(Sender: TObject);
begin
  RettidigDate.Visible           := True;
  IntervalLabel.Visible          := False;
  IntervalCombo.Visible          := False;
  RettidigLabel.Visible          := False;
  RettidigCombo.Visible          := False;
  AntalDageIntervalEdit.Visible  := False;
  AntalEdit.Visible              := False;
  SoegOpdater;
end;

//**********************************************************************
//  Radio løbende
//**********************************************************************
procedure TKontingentManuelForm.RadioLoebendeClick(Sender: TObject);
begin
  RettidigDate.Visible           := False;
  IntervalLabel.Visible          := True;
  IntervalCombo.Visible          := True;
  RettidigLabel.Visible          := True;
  RettidigCombo.Visible          := True;
  AntalDageIntervalEdit.Visible  := True;
  AntalEdit.Visible              := True;
  SoegOpdater;
end;

//**********************************************************
// Radio mærke
//**********************************************************
procedure TKontingentManuelForm.RadioMaerkeClick(Sender: TObject);
begin
  IndlaesMaerker;
  EditMedNr.Visible       := False;
  SpeedFindMedlem.Visible := False;
end;

//**********************************************************
// Radio Medlem
//**********************************************************
procedure TKontingentManuelForm.RadioMedlemClick(Sender: TObject);
begin
  IndlaesMedlemmer;
  EditMedNr.Visible       := True;
  SpeedFindMedlem.Visible := True;
end;

//**********************************************************
// Rettidig combo change
//**********************************************************
procedure TKontingentManuelForm.RettidigComboChange(Sender: TObject);
begin
  SoegOpdater;
end;

//**********************************************************
// Rettidig date exit
//**********************************************************
procedure TKontingentManuelForm.RettidigDateExit(Sender: TObject);
begin
  SoegOpdater;
end;

//**********************************************************
// Sæt default pris kategori
//**********************************************************
procedure TKontingentManuelForm.SaetDefaultsPrisKategoriExecute(Sender: TObject);
begin
  IniFile.WriteInteger('KonManuel','PrisKatItemIndex',ComboPrisKategori.ItemIndex);
end;

//**********************************************************
// Start date exit
//**********************************************************
procedure TKontingentManuelForm.StartDateExit(Sender: TObject);
begin
  SoegOpdater;
end;

//**********************************************************
// Indlæs periode
//**********************************************************
procedure TKontingentManuelForm.IndlaesPeriode;
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

//**********************************************************************
//  Indlæs medlemmer til combo
//**********************************************************************
procedure TKontingentManuelForm.IndlaesMedlemmer;
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

//**********************************************************************
//  Indlæs mærker til combo
//**********************************************************************
procedure TKontingentManuelForm.IndlaesMaerker;
Var A : Integer;
Begin
  // Find Medlemmer
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from markdef');
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount = 0 Then
    Begin
      MessageDlg('Ingen mærker er defineret!',mtInformation,[mbOk],0);
      Exit;
    end;
  // Combo gøres klar
  A := 0;
  ComboMedlem.Clear;
  ComboMedlem.Columns.add;
  ComboMedlem.Columns.add;
  ComboMedlem.Columns.Items[0].Width   := ComboMedlem.Width;
  ComboMedlem.Columns.Items[0].Color   := $00A6FFFF;
  ComboMedlem.Columns.Items[1].Visible := False;
  ZQuery1.First;
  While not ZQuery1.Eof Do
    Begin
      ComboMedlem.AddRow;
      ComboMedlem.Cells[0,A] := ZQuery1.FieldByName('Beskrivelse').AsString;
      ComboMedlem.Cells[1,A] := ZQuery1.FieldByName('id').AsString;
      Inc(A);
      ZQuery1.Next;
    End;
  // Vælg default
  ComboMedlem.ItemIndex := 0;
End;

//**********************************************************************
//  Indlæs Priskategori
//**********************************************************************
procedure TKontingentManuelForm.IndlaesPrisKategori;
Var A : Integer;
Begin
  // Find priskategori
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from priskategori where (afd = ' + CurrentAfd + ')');
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount = 0 Then
    Begin
      MessageDlg('Ingen priskategori er defineret!',mtInformation,[mbOk],0);
      Exit;
    end;
  // Combo gøres klar
  A := 0;
  ComboPrisKategori.Clear;
  ComboPrisKategori.Columns.add;
  ComboPrisKategori.Columns.add;
  ComboPrisKategori.Columns.add;
  ComboPrisKategori.Columns.Items[0].Width   := ComboPrisKategori.Width;
  ComboPrisKategori.Columns.Items[0].Color   := $00A6FFFF;
  ComboPrisKategori.Columns.Items[1].Visible := False;
  ComboPrisKategori.Columns.Items[2].Visible := False;
  // Manualt indsættes
  ComboPrisKategori.Sorted := False;
  ComboPrisKategori.AddRow;
  ComboPrisKategori.Cells[0,A] := 'Manuelt';
  ComboPrisKategori.Cells[1,A] := '-1';
  ComboPrisKategori.Cells[2,A] := '-1';
  Inc(A);
  ZQuery1.First;
  While not ZQuery1.Eof Do
    Begin
      ComboPrisKategori.AddRow;
      ComboPrisKategori.Cells[0,A] := ZQuery1.FieldByName('Beskrivelse').AsString;
      ComboPrisKategori.Cells[1,A] := ZQuery1.FieldByName('PrisType').AsString;
      ComboPrisKategori.Cells[2,A] := ZQuery1.FieldByName('id').AsString;
      Inc(A);
      ZQuery1.Next;
    End;
  // Vælg default
  ComboPrisKategori.ItemIndex := 0;
  //ComboPrisKategori.ItemIndex := IniFile.ReadInteger('KonManuel','PrisKatItemIndex',0);
  VisPris;
end;

//**********************************************************************
//  Vis Pris
//**********************************************************************
procedure TKontingentManuelForm.VisPris;
begin
  If ComboPrisKategori.ItemIndex = 0 Then
    Begin // opdater med default værdier for manuel
      AltTekstEdit.Text := 'Manuelt fastsat pris';
      EditPris.Value    := 100;
    End
  Else
    Begin // Indlæs værdier for priskategori
      // Find priskategori
      With ZQuery1.SQL do
        Begin
          Clear;
          Add('Select * from priskategori where (afd = ' + CurrentAfd +
          ') and ( PrisType = ' + ComboPrisKategori.Cells[1,ComboPrisKategori.ItemIndex] + ')');
        End;
      ZQuery1.Open;
      If ZQuery1.RecordCount = 0 Then
        Begin // opdater med default værdier for manuel
          AltTekstEdit.Text := 'Manuelt fastsat pris';
          EditPris.Value     := 100;
        end
      Else
        Begin
          AltTekstEdit.Text := ZQuery1.FieldByName('Beskrivelse').AsString;
          EditPris.Value    := ZQuery1.FieldByName('Pris').AsCurrency;
        end;
    end;
end;

//**********************************************************************
//  Søg opdater
//**********************************************************************
procedure TKontingentManuelForm.SoegOpdater;
Var MedlemListe : TStringList;
    A           : Integer;
    ManStr      : String;
    MedNrStr    : String;
    ResultStr   : String;
    B           : Integer;
    EndeligPris : Double;
    HelpNr      : Integer;

begin
  // Check indtastninger;
  // Check Periode
  If ComboPeriode.Text = '' Then
    Begin
      MessageDlg('Ingen periode valgt - opret en periode',mtError,[mbOk],0);
      ComboPeriode.SetFocus;
      Exit;
    End;
  // Indstil rabat
  If Not BeregnPeriodeDataTilRabat Then Exit;
  //
  MedlemListe := TStringList.Create;
  MedlemListe.Sorted := False;
  If RadioMedlem.Checked Then
    Begin // Indsæt medlemsnr på medlemmet
      MedlemListe.Add(ComboMedlem.Cells[2,ComboMedlem.ItemIndex]);
    End
  Else
    Begin
      // Find mærker
      With ZQuery1.SQL do
        Begin
          Clear;
          Add('Select * from marks where markid = ' +
            ComboMedlem.Cells[1,ComboMedlem.ItemIndex]);
        End;
      ZQuery1.Open;
      If ZQuery1.RecordCount = 0 Then
        Begin
          MessageDlg('Ingen medlemmer på mærke: ' +
            ComboMedlem.Cells[0,ComboMedlem.ItemIndex],mtInformation,[mbOk],0);
          MedlemListe.Free;
          Exit;
        end;
      ZQuery1.First;
      While Not ZQuery1.EOF Do
        Begin
          MedlemListe.Add(ZQuery1.FieldByName('Medlemsnr').AsString);
          ZQuery1.Next;
        End;  ;
    End;
//  StringGrid1.BeginUpdate;
  StringGrid1.RowCount := 1;
  A := 0;
  While A < MedlemListe.Count Do
    Begin // løb igennem liste med fundne medlemmer
      For B := 1 to StrToInt(AntalEdit.Text) Do
        Begin
          // Data indsættes i grid
          StringGrid1.RowCount := StringGrid1.RowCount + 1;
          // Indsæt B - antal
          StringGrid1.Cells[GenB,StringGrid1.RowCount-1] := IntToStr(B);
          // Nr
          If B = 1 Then
            Begin
              ManStr := FindManNr(MedlemListe[A]);
            End
          Else
            Begin
              HelpNr := StrToInt(ManStr);
              Inc(HelpNr);
              Str(HelpNr:4,ManStr);
            End;
          Str(StrToInt(MedlemListe.Strings[A]):4,MedNrStr);
          ResultStr := DanGiroNummer(ManStr,CurrentAfd,ComboPeriode.Text,MedNrStr);
          StringGrid1.Cells[GenNr,StringGrid1.RowCount-1]:= ResultStr;
          // Find Medlem
          With ZQueryMedlem.SQL do
            Begin
              Clear;
              Add('Select * from medlem where medlemsnr = ' +
                MedlemListe.Strings[A]);
            End;
          ZQueryMedlem.Open;
          If ZQueryMedlem.RecordCount = 0 Then
            Begin
              MessageDlg('Medlem ikke fundet i medlemsdatabase!',mtError,[mbOk],0);
              Exit;
            End;
          // Navn
          StringGrid1.Cells[GenNavn,StringGrid1.RowCount-1] :=
            ZQueryMedlem.FieldByName('Fornavn').AsString + ' ' +
            ZQueryMedlem.FieldByName('Efternavn').AsString;
          // Adr
          StringGrid1.Cells[GenAdr,StringGrid1.RowCount-1]:=
            ZQueryMedlem.FieldByName('Adr1').AsString;
          // Besk
          StringGrid1.Cells[GenBesk,StringGrid1.RowCount-1]:=
            AltTekstEdit.Text;
          // MedlemsNr
          StringGrid1.Cells[GenMedlemsNr,StringGrid1.RowCount-1]:=
            ZQueryMedlem.FieldByName('MedlemsNr').AsString;
          // Pris
          If Not (ComboPrisKategori.ItemIndex = 0) and CheckBoxRabat.Checked Then
            Begin // Priskategori valgt check rabat
              EndeligPris := StrToFloat(EditPris.Text); //AfdTabel.FieldByName('Pris').AsFloat;
              If CheckRabat(ComboPrisKategori.Cells[1,ComboPrisKategori.ItemIndex], EndeligPris) Then
                Begin
                  StringGrid1.Cells[GenBeloeb,StringGrid1.RowCount-1]:=
                    FloatToStr(EndeligPris);
                End
              Else
                Begin
                  StringGrid1.Cells[GenBeloeb,StringGrid1.RowCount-1]:=
                    EditPris.Text;
                End;
            End
          Else
            Begin
              StringGrid1.Cells[GenBeloeb,StringGrid1.RowCount-1]:=
                EditPris.Text;
            End;
        End;
      Inc(A);
    End;
//  StringGrid1.EndUpdate;
  MedlemListe.Free;
end;

//**********************************************************
// Tæl aktiviteter for medlem
//**********************************************************
Function TKontingentManuelForm.TaelAktiviteterForMedlem(MedlemsNr : String) : Integer;
Begin
  // Find i aktmed antal aktiviteter som medlem har
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from aktmed where (Afd = '+ CurrentAfd +
        ') and (Medlemsnr = ' +
        Medlemsnr + ')');
    End;
  ZQuery1.Open;
  TaelAktiviteterForMedlem := ZQuery1.RecordCount;
End;

//**********************************************************
// Beregn periode data til rabat
//**********************************************************
Function TKontingentManuelForm.BeregnPeriodeDataTilRabat : Boolean;
Begin
  // Find periode
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from periodedef where nr = ' +
        ComboPeriode.Cells[1,ComboPeriode.ItemIndex]);
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount = 0 Then
    Begin
      MessageDlg('Periode kan ikke findes!',mtError,[mbOk],0);
      BeregnPeriodeDataTilRabat := False;
    end
  Else
    Begin
      PeriodeStart := ZQuery1.FieldByName('DatoFra').AsDateTime;
      PeriodeSlut  := ZQuery1.FieldByName('DatoTil').AsDateTime;
      PeriodeLaengde :=  DaysBetween(ZQuery1.FieldByName('DatoTil').AsDateTime,
        ZQuery1.FieldByName('DatoFra').AsDateTime);
      BeregnPeriodeDataTilRabat := True;
    End;
End;


//**********************************************************
// CheckRabat
//**********************************************************
Function TKontingentManuelForm.CheckRabat(PrisType : String; Var EndeligPris: Double) : Boolean;
Var AntalBidderIPerioden : Integer;
    AntalBidderAfPeriode : Integer;
    AntalAktiviteter     : Integer;
    AntalMult            : Integer;
    MedlemsAlder         : Integer;
    HelpTal              : Double;
    A                    : Integer;
Begin
  If EndeligPris <= 0 Then
    Begin
      CheckRabat := False;
      Exit;
    End;
  IndlaesRabatter(PrisType);
  If StringGridRabat.RowCount = 1 Then
    Begin // Ingen rabat
      CheckRabat := False;
      Exit;
    End;
  // Løb igennem rabatgrid og beregn rabatten
  CheckRabat := True;
  A := 1;
  While A < StringGridRabat.RowCount Do
    Begin
      With ZQueryRabatDef.SQL do
        Begin
          Clear;
          Add('Select * from rabatdef where (Afd = ' + CurrentAfd + ') and (id = ' +
            StringGridRabat.Cells[RabatNr,A] +')');
        End;
      ZQueryRabatDef.Open;
      If ZQueryRabatDef.RecordCount > 0 Then
        Begin
          Case ZQueryRabatDef.FieldByName('Type').AsInteger of
            0 : Begin  // Nedskrivning
                  Case ZQueryRabatDef.FieldByName('Param3').AsInteger of
                    0 : Begin // Følger periode - hele beløb
                        End;
                    1 : Begin // Dags dato til periode slut
                          // Rabat efter hvormeget af perioden der er gået
                          AntalBidderIPerioden := Round( DaysBetween(PeriodeSlut,PeriodeStart) /
                            ZQueryRabatDef.FieldByName('Param1').AsInteger);
                          AntalBidderAfPeriode := Round((Now - PeriodeStart) /
                            ZQueryRabatDef.FieldByName('Param1').AsInteger);
                          EndeligPris := ((AntalBidderIPerioden - AntalBidderAfPeriode) * EndeligPris) /
                            AntalBidderIPerioden;
                          // Afrunding
                          EndeligPris := Round(
                             EndeligPris/ZQueryRabatDef.FieldByName('Param2').AsFloat) *
                             ZQueryRabatDef.FieldByName('Param2').AsFloat;
                        End;
                    2 : Begin // Følger datoer
                          If (ZQueryRabatDef.FieldByName('ParamDate1').AsDateTime < Now) and
                             (ZQueryRabatDef.FieldByName('ParamDate2').AsDateTime > Now) Then
                            Begin
                              AntalBidderIPerioden := Round( DaysBetween(ZQueryRabatDef.FieldByName('ParamDate2').AsDateTime,
                                ZQueryRabatDef.FieldByName('ParamDate1').AsDateTime) /
                                ZQueryRabatDef.FieldByName('Param1').AsInteger);
                              AntalBidderAfPeriode := Round((NOw -
                                ZQueryRabatDef.FieldByName('ParamDate1').AsDateTime) /
                                ZQueryRabatDef.FieldByName('Param1').AsInteger);
                              EndeligPris := ((AntalBidderIPerioden - AntalBidderAfPeriode) * EndeligPris) /
                                AntalBidderIPerioden;
                              // Afrunding
                              EndeligPris := Round(
                                 EndeligPris/ZQueryRabatDef.FieldByName('Param2').AsFloat) *
                                 ZQueryRabatDef.FieldByName('Param2').AsFloat;
                            End
                          Else
                            Begin // Udenfor periode - ingen
                              // EndeligPris := EndeligPris;
                            End;
                        End;
                    End; // End Case
                  StringGridRabat.Cells[RabatEndelig,A] := FloatToStr(EndeligPris);
                End;
            1 : Begin // Indmeldelsesgebyr
                  // Hvis medlem er tilmeldt efter start af periode
                  If ZQueryMedlem.FieldByName('MedlemSiden').AsDateTime >= PeriodeStart Then
                    Begin
                      Case ZQueryRabatDef.FieldByName('Param3').AsInteger of
                        0 : Begin // Følger periode
                              EndeligPris := EndeligPris +
                                ZQueryRabatDef.FieldByName('Param2').AsFloat;
                            End;
                        1 : Begin
                              HelpTal := (((PeriodeSlut - Now) / (PeriodeSlut - PeriodeStart)) *
                                 ZQueryRabatDef.FieldByName('Param2').AsFloat);
                              EndeligPris := EndeligPris + Int(HelpTal);
                            End;
                        2 : Begin // Følger datoer
                              If (ZQueryRabatDef.FieldByName('ParamDate1').AsDateTime < Now) and
                                 (ZQueryRabatDef.FieldByName('ParamDate2').AsDateTime > Now) Then
                                Begin
                                  HelpTal := (((ZQueryRabatDef.FieldByName('ParamDate2').AsDateTime - Now) /
                                    (ZQueryRabatDef.FieldByName('ParamDate2').AsDateTime - ZQueryRabatDef.FieldByName('ParamDate1').AsDateTime)) *
                                     ZQueryRabatDef.FieldByName('Param2').AsFloat);
                                  EndeligPris := EndeligPris + Int(HelpTal);
                                End
                              Else
                                Begin // Udenfor periode - ingen
                                  // EndeligPris := EndeligPris;
                                End;
                            End;
                      End; // End Case
                    End;
                  StringGridRabat.Cells[RabatEndelig,A] := FloatToStr(EndeligPris);
                End;
            2 : Begin // Mængderabat
                  // Hvis medlem er tilmeldt flere aktiviteter
                  AntalAktiviteter := TaelAktiviteterForMedlem(
                    ZQueryMedlem.FieldByName('MedlemsNr').AsString);
                  If Not (AntalAktiviteter = 1) Then
                    Begin
                      If AntalAktiviteter <= ZQueryRabatDef.FieldByName('Param3').AsInteger Then
                        Begin // Multiplikator rabat
                          AntalMult := AntalAktiviteter - 1;
                        End
                      Else
                        Begin // Max rabat nået
                          AntalMult := ZQueryRabatDef.FieldByName('Param3').AsInteger - 1;
                        End;
                      // Rabat i procent eller kr?
                      Case ZQueryRabatDef.FieldByName('Param1').AsInteger of
                        0 : Begin // %
                              EndeligPris := EndeligPris -
                               ((AntalMult * ZQueryRabatDef.FieldByName('Param2').AsFloat *  EndeligPris) /
                                 100);
                            End;
                        1 : Begin // Kr
                              EndeligPris := EndeligPris -
                                (AntalMult * ZQueryRabatDef.FieldByName('Param2').AsFloat);
                            End
                      Else
                        Begin // Error
                          MessageDlg('Ulovlig parameter i Param1',mtError,[mbOk],0);
                          CheckRabat := False;
                          Exit;
                        End;
                      End; // End case
                    End;
                  StringGridRabat.Cells[RabatEndelig,A] := FloatToStr(EndeligPris);
                End;
            3 : Begin // Pensionistrabat
                  // Hvis medlem er over en bestemt alder gives ranat
                  MedlemsAlder := YearsBetween(Now,ZQueryMedlem.FieldByName('FoedselsDato').AsDateTime);
                  If MedlemsAlder >= ZQueryRabatDef.FieldByName('Param3').AsInteger Then
                    Begin // Rabat
                      Case ZQueryRabatDef.FieldByName('Param1').AsInteger of
                        0 : Begin // %
                              EndeligPris := EndeligPris -
                               ((ZQueryRabatDef.FieldByName('Param2').AsFloat *  EndeligPris) /
                                 100);
                            End;
                        1 : Begin // Kr
                              EndeligPris := EndeligPris -
                                (ZQueryRabatDef.FieldByName('Param2').AsFloat);
                            End;
                      End; // End Case
                    End;
                  StringGridRabat.Cells[RabatEndelig,A] := FloatToSTr(EndeligPris);
                End;
            4 : Begin // Mærkerabat
                  With ZQuery1.SQL do
                    Begin
                      Clear;
                      Add('Select * from marks where (MarkId = ' +
                        ComboMedlem.Cells[1,ComboMedlem.ItemIndex] + ') and (afd = '
                        + CurrentAfd + ')');
                    End;
                  ZQuery1.Open;
                  If ZQuery1.RecordCount > 0 Then
                    Begin // Medlem har mærket og skal have rabatten
                      Case ZQueryRabatDef.FieldByName('Param1').AsInteger of
                        0 : Begin // %
                              EndeligPris := EndeligPris -
                               ((ZQueryRabatDef.FieldByName('Param2').AsFloat *  EndeligPris) /
                                 100);
                            End;
                        1 : Begin // Kr
                              EndeligPris := EndeligPris -
                                (ZQueryRabatDef.FieldByName('Param2').AsFloat);
                            End;
                      End; // End Case
                    End;
                  StringGridRabat.Cells[RabatEndelig,A] := FloatToStr(EndeligPris);
                End;
            5 : Begin // Ungdomsrabat
                  // Hvis medlem er under en bestemt alder gives ranat
                  MedlemsAlder := YearsBetween(Now,ZQueryMedlem.FieldByName('FoedselsDato').AsDateTime);
                  If MedlemsAlder <= ZQueryRabatDef.FieldByName('Param3').AsInteger Then
                    Begin // Rabat
                      Case ZQueryRabatDef.FieldByName('Param1').AsInteger of
                        0 : Begin // %
                              EndeligPris := EndeligPris -
                               ((ZQueryRabatDef.FieldByName('Param2').AsFloat *  EndeligPris) /
                                 100);
                            End;
                        1 : Begin // Kr
                              EndeligPris := EndeligPris -
                                (ZQueryRabatDef.FieldByName('Param2').AsFloat);
                            End;
                      End; // End Case
                    End;
                  StringGridRabat.Cells[RabatEndelig,A] := FloatToStr(EndeligPris);
                End;
            6 : Begin // Fastrabat
                  // Hvis medlem er tilmeldt flere aktiviteter
                  AntalAktiviteter := TaelAktiviteterForMedlem(
                    ZQueryMedlem.FieldByName('MedlemsNr').AsString);
                  If Not (AntalAktiviteter = 1) Then
                    Begin
                      // Rabat i procent eller kr?
                      Case ZQueryRabatDef.FieldByName('Param1').AsInteger of
                        0 : Begin // %
                              EndeligPris := ((100 - ZQueryRabatDef.FieldByName('Param2').AsFloat) *  EndeligPris) /
                                 100;
                            End;
                        1 : Begin // Kr
                              EndeligPris := AntalMult * (EndeligPris - ZQueryRabatDef.FieldByName('Param2').AsFloat);
                            End
                      Else
                        Begin // Error
                          MessageDlg('Ulovlig parameter i Param1',mtError,[mbOk],0);
                          CheckRabat := False;
                          Exit;
                        End;
                      End; // End case
                    End;
                  StringGridRabat.Cells[RabatEndelig,A] := FloatToStr(EndeligPris);
                End;
          End; // End Case
        End;
      Inc(A);
    End;
End;

//**********************************************************
// Indlæs rabatter
//**********************************************************
procedure TKontingentManuelForm.IndlaesRabatter(Pristype: String);
Begin
  StringGridRabat.RowCount := 1;
  // Check Om denne rabat findes på denne PrisType
  With ZQueryRabatKategori.SQL do
    Begin
      Clear;
      Add('Select * from rabatkategori where (Afd = ' + CurrentAfd + ') and (pristype = ' +
        PrisType +')');
    End;
  ZQueryRabatKategori.Open;
  If ZQueryRabatKategori.RecordCount > 0 Then
    Begin // Fundet rabbatter på denne pristype - beregn alle rabatter
      While Not ZQueryRabatKategori.Eof Do
        Begin
          With ZQueryRabatDef.SQL do
            Begin
              Clear;
              Add('Select * from rabatdef where (Afd = ' + CurrentAfd + ') and (Id = ' +
                ZQueryRabatKategori.FieldByName('Nr').AsString +')');
            End;
          ZQueryRabatDef.Open;
          If ZQueryRabatDef.RecordCount > 0 Then
            Begin // Fundet
              Case ZQueryRabatDef.FieldByName('Type').AsInteger of
                0,2,3,4,5,6 : Begin  // Nedskrivning, Mængderabat, Pensionistrabat, Mærkerabat, Ungdomsrabat
                      // Altid først
                      StringGridRabat.InsertColRow(False,1);
                      // slettes siden hen StringGridRabat.InsertRows(1,1);
                      StringGridRabat.Cells[RabatNr,1]   := ZQueryRabatKategori.FieldByName('Nr').AsString;
                      StringGridRabat.Cells[RabatType,1] := ZQueryRabatKategori.FieldByName('PrisType').AsString;
                    End;
                1 : Begin // Indmeldelsesgebyr
                      StringGridRabat.RowCount := StringGridRabat.RowCount + 1;
                      StringGridRabat.Cells[RabatNr,StringGridRabat.RowCount - 1] :=
                        ZQueryRabatKategori.FieldByName('Nr').AsString;
                      StringGridRabat.Cells[RabatType,StringGridRabat.RowCount - 1] :=
                        ZQueryRabatKategori.FieldByName('PrisType').AsString;
                    End;
              End; // End case
            End
          Else
            Begin // Rabatdefintion kunne ikke findes
              MessageDlg('Rabat kunne ikke findes - afbryder',mtError,[mbOk],0);
              Exit;
            End;
          ZQueryRabatKategori.Next;
        End;
    End;
End;


end.

