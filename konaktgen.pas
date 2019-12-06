//***************************************************************************//
//  Holbæk                                                                   //
//  Copyright by Claus Moeller 2013-2014                                     //
//  Generer indbetalingskort ud fra aktivitet                                //
//  Version                                                                  //
//  28.11.14                                                                 //
//***************************************************************************//
unit KonAktGen;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  ActnList, Menus, ExtCtrls, Grids, StdCtrls, Buttons, clmCombobox,
  JLabeledDateEdit, JLabeledIntegerEdit, ZDataset, DateUtils, IniFiles;

type

  { TKonAktGenForm }

  TKonAktGenForm = class(TForm)
    AktivitetSpeedNone: TAction;
    AktivitetSpeedAll: TAction;
    ActionList1: TActionList;
    CheckAktiviteter: TCheckBox;
    CheckboxRabat: TCheckBox;
    ComboPeriode: TclmCombobox;
    GenererIndbetalingskort: TAction;
    Help: TAction;
    ImageList1: TImageList;
    ImageList2: TImageList;
    EditDage: TJLabeledIntegerEdit;
    Label1: TLabel;
    Label2: TLabel;
    MaskRettidig: TJLabeledDateEdit;
    MaskUdsendelse: TJLabeledDateEdit;
    Luk: TAction;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    PageColor1: TShape;
    PageColor2: TShape;
    PageColor3: TShape;
    PageControl1: TPageControl;
    Panel1: TPanel;
    PopupMenu1: TPopupMenu;
    SpeedButton1: TSpeedButton;
    StringGrid1: TStringGrid;
    GridAktiviteter: TStringGrid;
    StringGridRabat: TStringGrid;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    VaelgAktivitetAlle: TSpeedButton;
    VaelgIngenAktivitet: TSpeedButton;
    ZQuery1: TZQuery;
    ZQueryAktMed: TZQuery;
    ZQueryKontingent: TZQuery;
    ZQueryMedlem: TZQuery;
    ZQueryPrisKategori: TZQuery;
    ZQueryRabatKategori: TZQuery;
    ZQueryRabatDef: TZQuery;
    procedure AktivitetSpeedAllExecute(Sender: TObject);
    procedure AktivitetSpeedNoneExecute(Sender: TObject);
    procedure CheckAktiviteterClick(Sender: TObject);
    procedure EditDageEditingDone(Sender: TObject);
    procedure EditDageExit(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure GenererIndbetalingskortExecute(Sender: TObject);
    procedure GridAktiviteterClick(Sender: TObject);
    procedure HelpExecute(Sender: TObject);
    procedure LukExecute(Sender: TObject);
  private
    { private declarations }
    IniFile        : TInifile;
    PeriodeStart   : TDatetime;
    PeriodeSlut    : TDateTime;
    PeriodeLaengde : Double;
    procedure IndlaesPeriode;
    procedure IndstilAktiviteter;
    procedure IndlaesAktiviteter;
    procedure Indstil;
    procedure SoegOpdater;
    Function  BeregnPeriodeDataTilRabat : Boolean;
    Function  FindSidsteNummer : LongInt;
    Function  CheckRabat(PrisType : String; Var EndeligPris: Double) : Boolean;
    procedure IndlaesRabatter(Pristype: String);
    Function  TaelAktiviteterForMedlem(MedlemsNr : String) : Integer;
    Function  DanGiroNummer(Afd,Periode,Nr : String): String;
  public
    { public declarations }
  end;

var
  KonAktGenForm: TKonAktGenForm;

implementation

{$R *.lfm}

Uses HolbaekConst, HolbaekMain;

{ TKonAktGenForm }


Const
  GenNr                 : Integer = 0;
  GenNavn               : Integer = 1;
  GenAdr                : Integer = 2;
  GenBeloeb             : Integer = 3;
  GenBesk               : Integer = 4;
  GenBaneDefNr          : Integer = 5;
  GenMedlemsNr          : Integer = 6;
  GenPrisType           : Integer = 7;

  AktCheck              : Integer = 0;
  AktNavn               : Integer = 1;
  AktNr                 : Integer = 2;

  RabatNr               : Integer = 0;
  RabatType             : Integer = 1;
  RabatEndelig          : Integer = 2;



//**********************************************************
// Create
//**********************************************************
procedure TKonAktGenForm.FormCreate(Sender: TObject);
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
  PageColor3.Brush.Color := H_Page_Color;
  PageColor3.Align       := alClient;

  ComboPeriode.Color     := H_Combo_Color;
  MaskUdsendelse.Color   := H_Edit_Baggrund;
  MaskRettidig.Color     := H_Edit_Baggrund;
  EditDage.Color         := H_Edit_Baggrund;

  // Database
//  ZQuery1.Connection          := MainForm.ZConnection1;
//  ZQueryAktMed.Connection     := MainForm.ZConnection1;
//  ZQueryKontingent.Connection := MainForm.ZConnection1;
//  ZQueryMedlem.Connection     := MainForm.ZConnection1;
//ZQueryPrisKategori.Connection := MainForm.ZConnection1;
//  ZQueryRabatDef.Connection   := MainForm.ZConnection1;
//  ZQueryRabatKategori.Connection:= MainForm.ZConnection1;
  // Indstil
  Indstil;
  IndstilAktiviteter;
  MaskUdsendelse.Value   := Now;
  MaskRettidig.Value     := StrToDate(FormatDateTime('dd-mm-yyyy',Date+30));

  // Indlæs
  IndlaesPeriode;
  IndlaesAktiviteter;
  SoegOpdater;
end;

//**********************************************************
// Generer indbetalingskort
//**********************************************************
procedure TKonAktGenForm.GenererIndbetalingskortExecute(Sender: TObject);
Var A           : Integer;
    ManStr      : String;
    NrGen       : LongInt;
    IdNr        : Real;
    HelpFloat   : Real;
begin
  If StringGrid1.RowCount = 1 Then
    Begin
      MessageDlg('Ingen indbetalingskort klar til generering!',mtInformation,[mbOk],0);
      Exit;
    end;
  // Medlemmer nu fundet og skal indsættes i kontingenttabel
  //*** her kunne evt. indsættes dialogboks medliste over de fundne medlemmer
  NrGen := 0;
  A     := 1;
  While A < StringGrid1.RowCount Do
    Begin // løb igennem grid
      Try
        // Find ledigt nr
        With ZQueryKontingent.SQL do
          Begin
            Clear;
            Add('Select * from kontingent order by id');
          End;
        ZQueryKontingent.Open;
        If ZQueryKontingent.RecordCount = 0 Then
          Begin // ingen - den første får nummer 1
            IdNr := 1;
          End
        Else
          Begin // Sidste + 1
            IdNr := ZQueryKontingent.RecordCount + 1;
          End;
        With ZQueryKontingent.SQL do
          Begin
            Clear;
            Add('Select * from kontingent');
          End;
        ZQueryKontingent.Open;
        ZQueryKontingent.Append;
        ZQueryKontingent.Edit;
        // Id
        ZQueryKontingent.FieldByName('Id').AsFloat   := IdNr;
        // Afd - 1
        ZQueryKontingent.FieldByName('Afd').AsString := CurrentAfd;
        // GiroBilagsnummer - 2
        HelpFloat := StrToFloat(StringGrid1.Cells[GenNr,A]);
        ZQueryKontingent.FieldByName('GiroBilagsNummer').AsFloat := HelpFloat;
//          StringGrid1.Cells[GenNr,A];
         ShowMessage(StringGrid1.Cells[GenNr,A] + ' ' + ZQueryKontingent.FieldByName('GiroBilagsNummer').AsString);
        //  DatoForIndbetalingAfKont - 3
        ZQueryKontingent.FieldByName('DatoForIndbetalingAfKont').AsDateTime :=
          StrToDateTime('11-11-1911');
        // Dato for udsendelse - 4
        ZQueryKontingent.FieldByName('DatoForUdsendelse').AsDateTime :=
           MaskUdsendelse.Value;
        // Seneste rettidig indbetaling - 5 }
        ZQueryKontingent.FieldByName('SenestRettidigIndbetaling').AsDateTime :=
           MaskRettidig.Value;
        // Beløb opkrævet - 6
        ZQueryKontingent.FieldByName('BeloebOpKraevet').AsFloat :=
          StrToFloat(StringGrid1.Cells[GenBeloeb,A]);
        // Beløb indbetalt - 7
        ZQueryKontingent.FieldByName('BeloebIndbetalt').AsFloat := 0;
        // MedlemsNr - 8
        ZQueryKontingent.FieldByName('MedlemsNr').AsString :=
          StringGrid1.Cells[GenMedlemsNr,A];
        // Periode - 9
        ZQueryKontingent.FieldByName('PeriodeId').AsString :=
          ComboPeriode.Cells[1,ComboPeriode.ItemIndex];
        // Rykkere  - 10
        ZQueryKontingent.FieldByName('AntalRykkere').AsInteger := 1;
        // BaneDefNr - 11
        ZQueryKontingent.FieldByName('BaneDefNr').AsString :=
          StringGrid1.Cells[GenBaneDefNr,A];
        // PrisType - 12
        ZQueryKontingent.FieldByName('PrisType').AsString :=
          StringGrid1.Cells[GenPrisType,A];
        // Afsluttet - 13
        ZQueryKontingent.FieldByName('Afsluttet').AsInteger := 1; {Mangler}
        // Manuel - 14
        ManStr := '';
        ZQueryKontingent.FieldByName('Manuel').AsString := ManStr;
        // AltTekst - 14
        ZQueryKontingent.FieldByName('AltTekst').AsString :=
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
                    ZQueryKontingent.FieldByName('Vaerge').AsInteger :=
                      ZQueryMedlem.FieldByName('Vaerge').AsInteger;
                  End;
              End;
          End;
        // Indsæt Record i Tabel
        ZQueryKontingent.Post;
        Inc(NrGen);
      Except
        // hvis ikke succesfuld
        ZQueryKontingent.Cancel;
        MessageDlg('Fejl ved generering af indbetalingskort',mtError,[mbOk],0);
      End;
      Inc(A);
    End;
  MessageDlg('Der er genereret ' + IntToStr(NrGen) + ' indbetalingskort',mtInformation,[mbOk],0);
  SoegOpdater;
end;

procedure TKonAktGenForm.GridAktiviteterClick(Sender: TObject);
begin

end;

//**********************************************************
// Check aktiviteter
//**********************************************************
procedure TKonAktGenForm.CheckAktiviteterClick(Sender: TObject);
begin
  GridAktiviteter.Visible     := Not GridAktiviteter.Visible;
  VaelgAktivitetAlle.Visible  := GridAktiviteter.Visible;
  VaelgIngenAktivitet.Visible := GridAktiviteter.Visible;
end;

//**********************************************************
// Edit dage done
//**********************************************************
procedure TKonAktGenForm.EditDageEditingDone(Sender: TObject);
begin
  ShowMessage('Edit done');
end;

procedure TKonAktGenForm.EditDageExit(Sender: TObject);
begin
  MaskRettidig.Value     := StrToDate(FormatDateTime('dd-mm-yyyy',
    IncDay(MaskUdsendelse.Value,EditDage.Value)));
   sHOWmESSAGE(DateToStr(MaskRettidig.Value) + ' ... ' + IntTosTr(EditDage.Value));

end;

//**********************************************************
// Aktivitet vælg alle
//**********************************************************
procedure TKonAktGenForm.AktivitetSpeedAllExecute(Sender: TObject);
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
procedure TKonAktGenForm.AktivitetSpeedNoneExecute(Sender: TObject);
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
// Hjælp
//**********************************************************
procedure TKonAktGenForm.HelpExecute(Sender: TObject);
begin
  ShowMessage('Hjælp');
end;

//**********************************************************
// Luk
//**********************************************************
procedure TKonAktGenForm.LukExecute(Sender: TObject);
begin
  Close;
end;

//**********************************************************
// Indlæs periode
//**********************************************************
procedure TKonAktGenForm.IndlaesPeriode;
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
//  Indstil
//**********************************************************************
procedure TKonAktGenForm.Indstil;

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
  StringGrid1.Columns[GenNr].Width                  := 110;
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

  StringGrid1.Columns[GenPrisType].Title.Caption    := 'PrisType';
  StringGrid1.Columns[GenPrisType].Width            := 100;
  StringGrid1.Columns[GenPrisType].Alignment        := taRightJustify;
  StringGrid1.Columns[GenPrisType].Visible          := False;

  PageControl1.Color := H_Menu_knapper_Farve;

//  StringGrid1.Options  := [goTabs];
//  StringGrid1.FocusRectVisible          :=False;
end;

//**********************************************************************
// Indstil Aktiviteter
//**********************************************************************
procedure TKonAktGenForm.IndstilAktiviteter;
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
procedure TKonAktGenForm.IndlaesAktiviteter;
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

//**********************************************************
// Find sidste nummer
//**********************************************************
Function TKonAktGenForm.FindSidsteNummer : LongInt;
Var OldHelpNr : LongInt;
    HelpStr   : String;
    HelpNr    : Integer;
Begin
  // Find periode
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from kontingent where (Afd = ' + CurrentAfd +
        (') and (periodeid = ') +
        ComboPeriode.Cells[1,ComboPeriode.ItemIndex] + ')');
    End;
  OldHelpNr := 0;
  ZQuery1.Open;
  If ZQuery1.RecordCount > 0 Then
    Begin
      While not ZQuery1.EOF Do
        Begin
          HelpStr := ZQuery1.FieldByName('GiroBilagsNummer').AsString;
          HelpStr := Copy(HelpStr,Length(HelpStr)-4,5);
          Delete(HelpStr,5,1);
          HelpNr := StrToInt(HelpStr);
          If HelpNr > OldHelpNr Then
            Begin
              OldHelpNr := HelpNr;
            End;
          ZQuery1.Next;
        end;
    End;
  FindSidsteNummer := OldHelpNr;
End;

//**********************************************************************
//  Søg opdater
//**********************************************************************
procedure TKonAktGenForm.SoegOpdater;
Var A             : Integer;
    GiroRecNr     : LongInt;
    GiroNrStr     : String;
    ResultStr     : String;
    LobendeNummer : LongInt;
    EndeligPris   : Double;

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
  // Find nr til indbetalingskort
  LobendeNummer := FindSidsteNummer;
  //  StringGrid1.BeginUpdate;
  StringGrid1.RowCount := 1;
  A := 1;
  With ZQueryAktMed.SQL do
    Begin
      Clear;
      Add('Select * from aktmed where (Afd = ' + CurrentAfd + ')');
    End;
  ZQueryAktMed.Open;
  If ZQueryAktMed.RecordCount > 0 Then
    Begin // Nu skal vi se om der er indbetalingskort som skal oprettes
      While Not ZQueryAktMed.EOF Do
        Begin
          With ZQueryKontingent.SQL do
            Begin
              Clear;
              Add('Select * from kontingent where (Afd = ' + CurrentAfd +
                ') and (PeriodeId = ' + ComboPeriode.Cells[1,ComboPeriode.ItemIndex] +
                ') and (BaneDefNr = ' + ZQueryAktMed.FieldByName('BaneDefNr').AsString +
                ') and (MedlemsNr = ' + ZQueryAktMed.FieldByName('MedlemsNr').AsString +
                ')');
            End;
          ZQueryKontingent.Open;
          If ZQueryKontingent.RecordCount = 0 Then
            Begin // Ikke oprettet endnu
              // Beregn gironr
              LobendeNummer := LobendeNummer + 1;
              GiroRecNr := LobendeNummer;
              Str(GiroRecNr:4,GiroNrStr);
              ResultStr := DanGiroNummer(CurrentAfd,
                ComboPeriode.Text,
                GiroNrStr);
              // Data indsættes i grid
              StringGrid1.RowCount := StringGrid1.RowCount + 1;
              StringGrid1.Cells[GenNr,StringGrid1.RowCount-1]:= ResultStr;
              // Find Medlem
              With ZQueryMedlem.SQL do
                Begin
                  Clear;
                  Add('Select * from medlem where medlemsnr = ' +
                    ZQueryAktMed.FieldByName('MedlemsNr').AsString);
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
              With ZQueryPrisKategori.SQL do
                Begin
                  Clear;
                  Add('Select * from PrisKategori where (Afd = ' + CurrentAfd +
                    ') and (PrisType = ' + ZQueryAktMed.FieldByName('PrisType').AsString +
                    ')');
                End;
              ZQueryPrisKategori.Open;
              If ZQueryPrisKategori.RecordCount = 0 Then
                Begin // Ikke fundet
                  MessageDlg('Pristype ikke fundet!',mtError,[mbOk],0);
                  Exit;
                end;
              StringGrid1.Cells[GenBesk,StringGrid1.RowCount-1]:=
                ZQueryPrisKategori.FieldByName('Beskrivelse').AsString;
              //
              // MedlemsNr
              StringGrid1.Cells[GenMedlemsNr,StringGrid1.RowCount-1]:=
                ZQueryMedlem.FieldByName('MedlemsNr').AsString;
              // Pris
              If CheckBoxRabat.Checked Then
                Begin // regn rabat
                  EndeligPris := ZQueryPrisKategori.FieldByName('Pris').AsFloat;
                  If CheckRabat(ZQueryPrisKategori.FieldByName('PrisType').AsString, EndeligPris) Then
                    Begin
                      StringGrid1.Cells[GenBeloeb,StringGrid1.RowCount-1]:=
                        FloatToStr(EndeligPris);
                    End
                  Else
                    Begin
                      StringGrid1.Cells[GenBeloeb,StringGrid1.RowCount-1]:=
                        ZQueryPrisKategori.FieldByName('Pris').AsString;
                    End;
                End
              Else
                Begin
                  StringGrid1.Cells[GenBeloeb,StringGrid1.RowCount-1]:=
                    ZQueryPrisKategori.FieldByName('Pris').AsString;
                End;
              // BaneDefNr
              StringGrid1.Cells[GenBaneDefNr,StringGrid1.RowCount-1]:=
                ZQueryAktMed.FieldByName('BaneDefNr').AsString;
              // PrisType
              StringGrid1.Cells[GenPrisType,StringGrid1.RowCount-1]:=
                ZQueryAktMed.FieldByName('PrisType').AsString;
              Inc(A);
            End;
          ZQueryAktMed.Next;
        end;
    end;
//  StringGrid1.EndUpdate;
end;


//**********************************************************
// Beregn periode data til rabat
//**********************************************************
Function TKonAktGenForm.BeregnPeriodeDataTilRabat : Boolean;
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
Function TKonAktGenForm.CheckRabat(PrisType : String; Var EndeligPris: Double) : Boolean;
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
                  // Find mærke
                  With ZQuery1.SQL do
                    Begin
                      Clear;
                      Add('Select * from marks where (MarkId = ' +
                        ZQueryRabatDef.FieldByName('Param3').AsString + ') and (medlemsnr = '
                        + ZQueryAktMed.FieldByName('MedlemsNr').AsString + ')');
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
procedure TKonAktGenForm.IndlaesRabatter(Pristype: String);
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


//**********************************************************
// Tæl aktiviteter for medlem
//**********************************************************
Function TKonAktGenForm.TaelAktiviteterForMedlem(MedlemsNr : String) : Integer;
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
// DanGiroNummer
//**********************************************************
Function TKonAktGenForm.DanGiroNummer(Afd,Periode,Nr : String): String;
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
{  Indbetaler[6] := Ord(Afd[1])-48;}
  Indbetaler[7] := Ord(Afd[1])-48;
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


end.

