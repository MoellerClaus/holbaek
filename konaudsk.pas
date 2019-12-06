//***************************************************************************//
//  Holbæk                                                                   //
//  Copyright by Claus Moeller 2013-2014                                     //
//  Udskriv send indbetalingskort                                            //
//  Version                                                                  //
//  07.12.14                                                                 //
//***************************************************************************//
unit konaudsk;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  Menus, ActnList, ExtCtrls, StdCtrls, Grids, DbCtrls, Buttons, FileCtrl,
  clmCombobox, RichMemo, ZDataset, ZSqlProcessor, ZSequence, db;

type

  { TKonGiroUdskriv }

  TKonGiroUdskriv = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    DBNavigator2: TDBNavigator;
    HelpMemo1: TMemo;
    OpenUdskriv: TButton;
    ComboBlanket: TclmCombobox;
    DataFraKontEdit: TDataSource;
    DataFraUdskriv: TDataSource;
    DBEdit1: TDBEdit;
    DBMemo1: TDBMemo;
    DBMemoHelp: TDBMemo;
    DBMemoHelpKopi: TDBMemo;
    DBNavigator1: TDBNavigator;
    FileListBox1: TFileListBox;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    HelpRich: TRichMemo;
    SletLinje: TAction;
    ActionList1: TActionList;
    CheckKlubFelter: TCheckBox;
    CheckIndbetalingslinje: TCheckBox;
    CheckMeddelser: TCheckBox;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    Help: TAction;
    ImageList1: TImageList;
    AntalFundne: TLabel;
    Label2: TLabel;
    Luk: TAction;
    MenuItem1: TMenuItem;
    MenuItem4: TMenuItem;
    PageColor1: TShape;
    PageColor2: TShape;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    PopupMenu1: TPopupMenu;
    SpeedButton3: TSpeedButton;
    StringGrid1: TStringGrid;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    Udskriv: TAction;
    ZQuery1: TZQuery;
    ZQueryVaerge: TZQuery;
    ZQueryMedlem: TZQuery;
    ZQueryAktiviteter: TZQuery;
    ZQueryUdskriv: TZQuery;
    ZQueryKontingentMedlem: TZQuery;
    ZQueryKontEdit: TZQuery;
    ZQueryAfdDef: TZQuery;
    ZSequenceUdskriv: TZSequence;
    ZSQLProcessor1: TZSQLProcessor;
    ZTable1: TZTable;
    procedure FormCreate(Sender: TObject);
    procedure LukExecute(Sender: TObject);
    procedure OpenUdskrivClick(Sender: TObject);
    procedure SletLinjeExecute(Sender: TObject);
    procedure UdskrivExecute(Sender: TObject);
  private
    { private declarations }
    procedure Indstil;
    procedure IndstilKontEdit;
    procedure IndlaesSkabeloner;
    procedure OpdaterAktPrisTekstFelt;
    procedure LavUdskrivtabel;
    Function  BlankeBagved(HelpStr : String; AntalTegn : Integer) : String;
    Function  SpaceForan(HelpStr : String; AntalTegn : Integer) : String;
    procedure LavGeneratorOgTrigger(Navn : String; Ident : String);
  public
    { public declarations }
    MaerkeBesk     : String;      // Ved søgning på mærke
    MaerkeNr       : String;
    KontingentList : TStringList; // Liste hvis girokort skal udskrives
    CountToUdskriv : Integer;
    Procedure ShowList;
    procedure UdskrivA5User(VisRapportDesigner : Boolean; FlerePaaSamme : Integer);
  end;

var
  KonGiroUdskriv: TKonGiroUdskriv;

implementation

{$R *.lfm}

Uses HolbaekConst, MainData, DateUtils, ZScriptParser, SuperPrint, StrUtils;

{ TKonGiroUdskriv }

Const
  GenNavn               : Integer = 0;
  GenAdr                : Integer = 1;
  GenBesk               : Integer = 2;
  GenBeloeb             : Integer = 3;
  GenIndbNr             : Integer = 4;
  GenMedlemsNr          : Integer = 5;


//**********************************************************
// Create
//**********************************************************
procedure TKonGiroUdskriv.FormCreate(Sender: TObject);
begin
  Top  := 10;
  Left := 30;
  ShowHint               := True;
  // Farver
  Color                  := H_Window_Baggrund;
  ToolBar1.Color         := H_Menu_knapper_Farve;

  PageColor1.Color       := H_Panel_Color;
  PageColor1.Align       := alClient;
  PageColor2.Brush.Color := H_Panel_Overskrift;
  PageColor2.Align       := alClient;
//  PageColor3.Brush.Color := H_Page_Color;
//  PageColor3.Align       := alClient;


//  ComboMedlem.Color      := H_Combo_Color;

(*  ComboPeriode.Color     := H_Combo_Color;
  MaskUdsendelse.Color   := H_Edit_Baggrund;
  MaskRettidig.Color     := H_Edit_Baggrund;
  EditDage.Color         := H_Edit_Baggrund;*)

  // Database
  ZQuery1.Connection                := MainDataModule.ZConnection1;
  ZQueryKontingentMedlem.Connection := MainDataModule.ZConnection1;
  ZQueryVaerge.Connection   := MainDataModule.ZConnection1;
  ZQueryKontEdit.Connection         := MainDataModule.ZConnection1;
  ZQueryAfdDef.Connection           := MainDataModule.ZConnection1;
  ZQueryUdskriv.Connection          := MainDataModule.ZConnection1;
  ZTable1.Connection                := MainDataModule.ZConnection1;
  ZQueryMedlem.Connection           := MainDataModule.ZConnection1;
  ZQueryAktiviteter.Connection      := MainDataModule.ZConnection1;
  ZSQLProcessor1.Connection         := MainDataModule.ZConnection1;
  ZSequenceUdskriv.Connection       := MainDataModule.ZConnection1;
  DBMemoHelp.DataSource             := DataFraKontEdit;
  // Indstil
  Indstil;
  IndstilKontEdit;
  KontingentList := TStringList.Create; { Liste hvis girokort skal udskrives }
  KontingentList.Sorted := False;

  // Indlæs
  IndlaesSkabeloner;
end;


//**********************************************************************
// Lav generator og trigger
//**********************************************************************
procedure TKonGiroUdskriv.LavGeneratorOgTrigger(Navn : String; Ident : String);

Begin
  Navn := UpperCase(Navn);
  Ident := UpperCase(Ident);
  // Set generator and trigger for autoinc functionality
  ZSQLProcessor1.CleanupStatements := True;
  ZSQLProcessor1.Delimiter:='!!';
  ZSQLProcessor1.DelimiterType:=dtSetTerm;
  Try
    With ZSQLProcessor1.Script do
      Begin
        Clear;
        Add('CREATE GENERATOR GEN_'+ Navn + '_'+ Ident + ' !!');
        Add('SET GENERATOR GEN_'+ Navn + '_' + Ident + ' TO 0 !!');
        Add('CREATE TRIGGER T_' + Navn + ' FOR ' + Navn);
        Add('ACTIVE BEFORE INSERT POSITION 0');
        Add('AS');
        ADD('BEGIN');
        ADD('IF (NEW.' + Ident +' IS NULL) THEN NEW.' + Ident +
          ' = GEN_ID(GEN_' + Navn + '_' + Ident + ', 1);');
        Add('END!!');
      end;
    ZSQLProcessor1.Execute;
    ZSequenceUdskriv.SequenceName := 'GEN_' + Navn + '_' + Ident;
  Except
    // Don't show errors
  end;
end;

//**********************************************************
// Indstil kont edit
//**********************************************************
procedure TKonGiroUdskriv.IndstilKontEdit;
Begin
  With ZQueryKontEdit.SQL do
    Begin
      Clear;
      Add('Select * from KontingentTekst where afd = ' + CurrentAfd);
    End;
  ZQueryKontEdit.Open;
end;

//**********************************************************************
//  Luk
//**********************************************************************
procedure TKonGiroUdskriv.LukExecute(Sender: TObject);
begin
  Close;
end;

//**********************************************************************
//  Open udskriv
//**********************************************************************
procedure TKonGiroUdskriv.OpenUdskrivClick(Sender: TObject);
begin
  ZQueryUdskriv.Close;
  With ZQueryUdskriv.SQL Do
    Begin
      Clear;
      Add('Select * from ' + DatabaseUdskriv + ' order by id');
    end;
  DBMemoHelpKopi.DataField := 'AktPrisTekst';
  ZQueryUdskriv.Open;
end;

//**********************************************************************
//  Slet linje
//**********************************************************************
procedure TKonGiroUdskriv.SletLinjeExecute(Sender: TObject);
begin
  If StringGrid1.RowCount > 1 Then
    Begin
      StringGrid1.DeleteRow(StringGrid1.Row);
    end;
end;

//**********************************************************************
//  Udskriv
//**********************************************************************
procedure TKonGiroUdskriv.UdskrivExecute(Sender: TObject);
Var A : Integer;
begin
  If KontingentList.Count = 0 Then
    Begin
      MessageDlg('Ingen indbetalingskort!',mtInformation,[mbOk],0);
      Exit;
    end;
  // KontigentListe skal overtages...
  KontingentList.Clear;
  For A := 1 to StringGrid1.RowCount-1 Do
    Begin
      KontingentList.Add(StringGrid1.Cells[GenIndbNr,A]);
    End;
  UdskrivA5User(True,3); // Enkelt
//  UdskrivA5User(True,1); // Enkelt
end;

//**********************************************************************
//  Indstil
//**********************************************************************
procedure TKonGiroUdskriv.Indstil;

Begin
  Indstil_StringGrid_NonEdit(StringGrid1);
  StringGrid1.Columns.Clear;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;

  StringGrid1.Columns[GenNavn].Title.Caption        := 'Navn';
  StringGrid1.Columns[GenNavn].Width                := 150;
  StringGrid1.Columns[GenNavn].Alignment            := taLeftJustify;

  StringGrid1.Columns[GenAdr].Title.Caption         := 'Adr';
  StringGrid1.Columns[GenAdr].Width                 := 150;
  StringGrid1.Columns[GenAdr].Alignment             := taLeftJustify;

  StringGrid1.Columns[GenBesk].Title.Caption        := 'Beskrivelse';
  StringGrid1.Columns[GenBesk].Width                := 150;
  StringGrid1.Columns[GenBesk].Alignment            := taLeftJustify;

  StringGrid1.Columns[GenBeloeb].Title.Caption      := 'Beløb';
  StringGrid1.Columns[GenBeloeb].Width              := 80;
  StringGrid1.Columns[GenBeloeb].Alignment          := taRightJustify;


  StringGrid1.Columns[GenIndbNr].Title.Caption      := 'Indbetalingsnr';
  StringGrid1.Columns[GenIndbNr].Width              := 100;
  StringGrid1.Columns[GenIndbNr].Alignment          := taRightJustify;
//  StringGrid1.Columns[GenIndbNr].Visible          := False;

  StringGrid1.Columns[GenMedlemsNr].Title.Caption   := 'MedlemsNr';
  StringGrid1.Columns[GenMedlemsNr].Width           := 100;
  StringGrid1.Columns[GenMedlemsNr].Alignment       := taRightJustify;
//  StringGrid1.Columns[GenMedlemsNr].Visible         := False;


//  StringGrid1.Options  := [goTabs];
//  StringGrid1.FocusRectVisible          :=False;
end;


//**********************************************************
// ShowList
//**********************************************************
procedure TKonGiroUdskriv.ShowList;
Var A : Integer;
begin
  // Indstil om der skal være grupper
//  Fjern.Enabled     := True;
  // Liste tom ?
  If KontingentList.Count = 0 Then
    Begin
      //Fjern.Visible := False;
      StringGrid1.RowCount := 1;
      Exit;
    End;
  Antalfundne.Caption := IntToStr(KontingentList.Count);
  Application.ProcessMessages; // Opdater tekst
  A := 0;
  While A < KontingentList.Count Do
    Begin
      // Find indbetalingskort
      With ZQueryKontingentMedlem.SQL do
        Begin
          Clear;
          Add('Select * from kontingent where (afd = ' + CurrentAfd +
            ') and (Girobilagsnummer = ' + KontingentList.Strings[A] + ')');
        End;
      ZQueryKontingentMedlem.Open;
      If ZQueryKontingentMedlem.RecordCount > 0 Then
        Begin // Fundet
          StringGrid1.RowCount := StringGrid1.RowCount + 1;
          // Medlem skal findes frem
          With ZQuery1.SQL do
            Begin
              Clear;
              Add('Select * from medlem where (medlemsnr = ' +
                ZQueryKontingentMedlem.FieldByName('MedlemsNr').AsString + ')');
            End;
          ZQuery1.Open;
          If ZQuery1.RecordCount > 0 Then
            Begin // Fundet
              StringGrid1.Cells[GenNavn,A+1] := ZQuery1.FieldByName('Fornavn').AsString + ' ' +
                ZQuery1.FieldByName('Efternavn').AsString;
              StringGrid1.Cells[GenAdr,A+1] := ZQuery1.FieldByName('Adr1').AsString;
            end
          Else
            Begin
              StringGrid1.Cells[GenNavn,A+1] := '?';
              StringGrid1.Cells[GenAdr,A+1] := '?';
            end;
          // Aktivitet beskrivelse skal findes frem
          If ZQueryKontingentMedlem.FieldByName('BaneDefNr').AsString <> '' Then
            Begin
              With ZQuery1.SQL do
                Begin
                  Clear;
                  Add('Select * from aktiviteter where (Afd = ' + CurrentAfd +
                  ') and (Id = ' +
                    ZQueryKontingentMedlem.FieldByName('BaneDefNr').AsString + ')');
                End;
              ZQuery1.Open;
              If ZQuery1.RecordCount > 0 Then
                Begin // Fundet
                  If ZQuery1.FieldByName('Beskrivelse').AsString <> '' Then
                    Begin
                      StringGrid1.Cells[GenBesk,A+1] :=
                        ZQuery1.FieldByName('Beskrivelse').AsString;
                    end
                  Else
                    Begin
                      StringGrid1.Cells[GenBesk,A+1] :=
                        ZQueryKontingentMedlem.FieldByName('AltTekst').AsString;
                    end;
                End;
            end
          Else
            Begin
              StringGrid1.Cells[GenBesk,A+1] :=
                ZQueryKontingentMedlem.FieldByName('AltTekst').AsString;
            end;
          StringGrid1.Cells[GenBeloeb,A+1] :=
            FloatToStrF(ZQueryKontingentMedlem.FieldByName('BeloebOpkraevet').AsCurrency,ffNumber,18,2);
          StringGrid1.Cells[GenIndbNr,A+1] := ZQueryKontingentMedlem.FieldByName('GiroBilagsnummer').AsString;
          StringGrid1.Cells[GenMedlemsNr,A+1] := ZQueryKontingentMedlem.FieldByName('MedlemsNr').AsString;
        End
      Else
        Begin
          MessageDlg('Fejl indbetaling kunne ikke findes længere',mtError,[mbOk],0);
        End;
      Inc(A);
    End;
end;

//**********************************************************
// Indlæs skabeloner
//**********************************************************
procedure TKonGiroUdskriv.IndlaesSkabeloner;
Var A : Integer;
Begin
  ComboBlanket.Clear;
  ComboBlanket.Clear;
  ComboBlanket.Columns.add;
  ComboBlanket.Columns.add;
  ComboBlanket.Columns.Items[0].Width   := ComboBlanket.Width;
  ComboBlanket.Columns.Items[0].Color   := $00A6FFFF;
  ComboBlanket.Columns.Items[1].Visible := False;
  FileListBox1.Directory := Options_Alias_Data;
  FileListBox1.Mask      := '*.' + ReportExt;
  A := 0;
  While A < FileListBox1.Count Do
    Begin
      ComboBlanket.AddRow;
      ComboBlanket.Cells[0,A] := ExtractFileName(FileListBox1.Items[A]);
      ComboBlanket.Cells[1,A] := FileListBox1.Items[A];
      Inc(A);
    end;
  ComboBlanket.ItemIndex := 0;
End;


//**********************************************************
// Blanke bagved
//**********************************************************
Function TKonGiroUdskriv.BlankeBagved(HelpStr : String; AntalTegn : Integer) : String;
Var A  : Integer;
Begin
  A      := Length(HelpStr);
  While A <= AntalTegn Do
    Begin
      HelpStr := HelpStr + '.';
      Inc(A);
    End;
  Result := HelpStr;
End;

//**********************************************************
// Space foran
//**********************************************************
Function TKonGiroUdskriv.SpaceForan(HelpStr : String; AntalTegn : Integer) : String;
Var A  : Integer;
Begin
  A      := Length(HelpStr);
  While A <= AntalTegn Do
    Begin
      HelpStr := ' ' + HelpStr;
      Inc(A);
    End;
  Result := HelpStr;
End;


//**********************************************************
// Opdater PrisAkt Felt
//**********************************************************
procedure TKonGiroUdskriv.OpdaterAktPrisTekstFelt;
Var TempFile    : String;
    FoundAt     : LongInt;
    Tekst       : String;

Begin
  DBMemoHelp.DataField := 'AktPrisTekst';
  // Tag kopi
  DBMemoHelpKopi.DataField := 'AktPrisTekst';
  DBMemoHelpKopi.Lines.AddStrings(DBMemoHelp.Lines); // Add to existing lines
  If DBMemoHelpKopi.Lines.Count = 0 Then
    Begin // Tom - intet at indsætte
      Exit;
    End;
  // Hent Rapport ind
  HelpMemo1.Text := DBMemoHelpKopi.Text;
  // Aktivitet skal findes frem
  If ZQueryKontingentMedlem.FieldByName('BaneDefNr').IsNull Then
    Begin
      Tekst := BlankeBagVed(ZQueryKontingentMedlem.FieldByName('AltTekst').AsString,40);
    end
  Else
    Begin
      With ZQuery1.SQL do
        Begin
          Clear;
          Add('Select * from aktiviteter where (id = ' + ZQueryKontingentMedlem.FieldByName('BaneDefNr').AsString + ')');
        End;
      ZQuery1.Open;
      If ZQuery1.RecordCount > 0 Then
        Begin // Fundet
          Tekst := BlankeBagVed(ZQuery1.FieldByName('Beskrivelse').AsString,40);
        End
      Else
        Begin
          Tekst := BlankeBagVed(ZQueryKontingentMedlem.FieldByName('AltTekst').AsString,40);
        End;
    end;
  HelpMemo1.WordWrap := False;
  If PosEx(Options_Udskrift_Aktivitet, HelpMemo1.Text, 1) > 0 Then
    Begin
      HelpMemo1.Text := StringReplace(HelpMemo1.Text,Options_Udskrift_Aktivitet,Tekst,[rfReplaceAll,rfIgnoreCase]);
    end;
  HelpMemo1.WordWrap := True;

  // Pris
(*  StartPos := 0;
  HelpRich.SelectAll;
  ToEnd := HelpRich.SelLength;
  FoundAt := HelpRich.Search(Options_Udskrift_Pris,StartPos, ToEnd,[TSearchOption(soMatchCase)]);
  While FoundAt <> -1 Do
    Begin  // Felt skal indsættes
      SetFocus;
      HelpRich.SelStart  := FoundAt;
      HelpRich.SelLength := Length(Options_Udskrift_Pris);
      HelpRich.SelText   := SpaceForan(FloatToStrF(ZQueryKontingentMedlem.FieldByName('BeloebOpkraevet').AsCurrency,ffNumber,18,2),16);
      HelpRich.SelStart  := 0;
      HelpRich.SelLength := 0;
      // Start søgning
      HelpRich.SelectAll;
      ToEnd := HelpRich.SelLength;
      FoundAt := HelpRich.Search(Options_Udskrift_Pris,StartPos, ToEnd,[TSearchOption(soMatchCase)]);
    End;*)
  // Indsæt denne tekst bagerst i AktPrisSumFelt

(*  DBMemoHelpKopi.Text :=  HelpMemo1.Text;  //GetRichMemoRTF(HelpRich);
  DBMemoHelpKopi.DataSource.DataSet.Post;
  DBMemoHelpKopi.DataSource.Edit;*)
End;


//**********************************************************
// Lav Udskrivtabel
//**********************************************************
procedure TKonGiroUdskriv.LavUdskrivtabel;
Begin
  // Lav database med udskrifts database

  // Findes den - så slet
  // Set generator and trigger for autoinc functionality
(*  ZQueryUdskriv.Close;
  MainForm.ZConnectionTestFiles.Connected :=False;
  ZTable1.Connection := MainForm.ZConnectionTestFiles;
  Try
    MainForm.ZConnectionTestFiles.Connect;
  except
    MessageDlg('Kan ikke forbinde til server - test files!',mtInformation,
      [mbOk],0);
    Exit;
  end;
  ZTable1.TableName := DatabaseUdskriv;
  If ZTable1.Exists Then
    Begin // Drop Table
      Try
        With ZQuery1.SQL do
          Begin
            Clear;
            Add('drop table ' + DatabaseUdskriv);
          end;
        ZQuery1.ExecSQL;
        With ZQuery1.SQL do
          Begin
            Clear;
            Add('drop generator GEN_'+ DatabaseUdskriv + '_ID')
          end;
        ZQuery1.ExecSQL;
      finally
      end;
    end;
  ZTable1.Close;
  // Lav ny Udskriv_Kassekladde tabel
  Try
    With ZQuery1.SQL do
      Begin
        Clear;
        Add('CREATE TABLE ' + DatabaseUdskriv + ' (');
        Add('  ID  INTEGER NOT NULL PRIMARY KEY,');
        Add('  Medlemsnr INTEGER,');
        Add('  PBSKundeNr VARCHAR(15),');
        Add('  Navn VARCHAR(40),');
        Add('  Adr VARCHAR(40),');
        Add('  Adr2 VARCHAR(40),');
        Add('  City VARCHAR(40),');
        Add('  PostNr VARCHAR(5),');
        Add('  PostNrBy VARCHAR(40),');
        Add('  Spec1 VARCHAR(40),');
        Add('  Spec2 VARCHAR(40),');
        Add('  Spec3 VARCHAR(40),');
        Add('  Spec4 VARCHAR(40),');
        Add('  Rettidig TIMESTAMP,');
        Add('  AktivitetsBeskrivelse VARCHAR(40),');
        Add('  ExInfo VARCHAR(40),');
        Add('  BrugerNr FLOAT,');
        Add('  VaergeNr FLOAT,');
        Add('  VaergeBrugerNr FLOAT,');
        Add('  VaergeNavn VARCHAR(40),');
        Add('  VaergeAdr VARCHAR(40),');
        Add('  VaergePostNr VARCHAR(5),');
        Add('  VaergeBy VARCHAR(40),');
        Add('  VaergePostBy VARCHAR(40),');
        Add('  Kr FLOAT,');
        Add('  Oere VARCHAR(2),');
        Add('  KrOere FLOAT,');
        Add('  Meddelelser VARCHAR(40),');
        Add('  IndbetalingsNr VARCHAR(40),');
        Add('  KlubGiro VARCHAR(16),');
        Add('  KlubNavn VARCHAR(40),');
        Add('  KlubAdr VARCHAR(40),');
        Add('  KlubBy VARCHAR(40),');
        Add('  Tekst BLOB SUB_TYPE 1 SEGMENT SIZE 255,');
        Add('  K71PBSNr VARCHAR(40),');
        Add('  K71DebiGrNr VARCHAR(40),');
        Add('  Periode VARCHAR(4),');
        Add('  PeriodeBeskrivelse VARCHAR(40),');
        Add('  Afsluttet INTEGER,');
        Add('  SumAlt FLOAT,');
        Add('  SumKr FLOAT,');
        Add('  SumOere VARCHAR(2),');
        Add('  Land VARCHAR(40),');
        Add('  LandForKort VARCHAR(3),');
        Add('  MaerkeBeskrivelse VARCHAR(40),');
        Add('  MaerkeNr VARCHAR(5),');
        Add('  GiroNr VARCHAR(16),');
        Add('  PrisBeskrivelse VARCHAR(40),');
        Add('  AltTekst VARCHAR(40),');
        Add('  AktPrisTekst BLOB SUB_TYPE 1 SEGMENT SIZE 255,');
        Add('  AfslutningsTekst BLOB SUB_TYPE 1 SEGMENT SIZE 255,');
        Add('  Altekst BLOB SUB_TYPE 1 SEGMENT SIZE 255,');
        Add('  Alder VARCHAR(3)');
        Add(')');
      End;
    ZQuery1.ExecSQL;
  finally
  end;
  // Set generator and trigger for autoinc functionality
  ZQuery1.Close;
  LavGeneratorOgTrigger(DatabaseUdskriv,'ID');*)
End;


//**********************************************************
// Udskriv A5 USER
//**********************************************************
procedure TKonGiroUdskriv.UdskrivA5User(VisRapportDesigner : Boolean; FlerePaaSamme : Integer);
// Flere paa samme. 1: Enkelt, 2: Flere, 3 : PBS

Type SpillerType = Array[1..3] of String;

Var BeloebKr    : LongInt;
    BeloebOre   : Integer;
    OreStr      : String;
    KontrolNr   : String;
    A           : Integer;
    Spillere    : SpillerType;
    AntalFundet : Word;
    FoundAt     : LongInt;
    StartPos    : LongInt;
    ToEnd       : LongInt;
//    HelpTekst   : TQRDesignRichText;
    Sum         : Currency;
    SammeMedlem : LongInt;
    TempFile    : String;
    HelpCountUdskriv : LongInt;
    Stop             : Boolean;
    FormatGiroNr     : String;

Begin
  // Find den rette afdeling;
  With ZQueryAfdDef.Sql Do
    Begin
      Clear;
      Add('Select * from AfdDef where Afd = ' + CurrentAfd);
    End;
  ZQueryAfdDef.Open;
  If ZQueryAfdDef.RecordCount = 0 Then
    Begin
      MessageDlg('Afdelingen kan ikke findes!',mtError,[mbOk],0);
      Exit;
    end;
  // Check om report file ligger der
  If Not FileExists (Options_Alias_Data + '\' + ComboBlanket.Text) Then
    Begin
      MessageDlg('Kontingent-skabelon: ' + Options_Alias_Data + '\' +  ComboBlanket.Text +
       ' findes ikke ! ',mtInformation,[mbOk],0);
      Exit;
    End;
  // Lav database med udskrifts database
  LavUdskrivtabel;
  // Ny flyttes data over i den valgte rækkefølge


  (*  UdskrivKontigentTabel.Open;
  { Indstil barometer }
  GaugeUdskriv.Visible := True;
  GaugeUdskriv.MaxValue := KontigentList.Count;
  GaugeUdskriv.Progress := 0;*)
  CountToUdskriv := 0;
  Sum := 0;
  SammeMedlem := 0;
  With ZQueryUdskriv.SQL Do
    Begin
      Clear;
      Add('Select * from ' + DatabaseUdskriv);
    End;
  ZQueryUdskriv.Open;
  While CountToUdskriv < KontingentList.Count Do
    Begin
      // GaugeUdskriv.Progress := CountToUdskriv+1;
      // De specifikke data på medlemmet findes frem
      With ZQueryKontingentMedlem.SQL Do
        Begin
          Clear;
          Add('Select * from Kontingent where (Afd = ' + CurrentAfd + ') and ' +
              '(GiroBilagsnummer = ' + KontingentList.Strings[CountToUdskriv] + ')');
        End;
      ZQueryKontingentMedlem.Open;
      If ZQueryKontingentMedlem.RecordCount = 0 Then
        Begin
          MessageDlg('Der er ingen data !',mtWarning,[mbOk],0);
          // CountToUdskriv := KontingentList.Count;
          Exit;
        End;
      Try
        // Start med at indsætte data
        ZQueryUdskriv.Append;
        ZQueryUdskriv.Edit;
        // Medlemsoplysninger
        With ZQueryMedlem.SQL Do
          Begin
            Clear;
            Add('Select * from Medlem where (Medlemsnr = ' +
               ZQueryKontingentMedlem.FieldByName('MedlemsNr').AsString + ')');
          End;
        ZQueryMedlem.Open;
        If ZQueryMedlem.RecordCount = 0 Then
          Begin
            MessageDlg('Medlem ikke fundet til indbetalingskort - fejl!',mtWarning,[mbOk],0);
            Exit;
          End;
        ZQueryUdskriv.FieldByName('ID').AsInteger := ZSequenceUdskriv.GetNextValue;
        ZQueryUdskriv.FieldByName('MedlemsNr').AsString :=
          ZqueryMedlem.FieldByName('MedlemsNr').AsString;
        ZQueryUdskriv.FieldByName('PBSKundeNr').AsString :=
          ZqueryMedlem.FieldByName('PBSKundeNr').AsString;
        ZQueryUdskriv.FieldByName('Navn').AsString :=
          ZqueryMedlem.FieldByName('Fornavn').AsString + ' ' +
            ZqueryMedlem.FieldByName('Efternavn').AsString;
        ZQueryUdskriv.FieldByName('Adr').AsString :=
          ZqueryMedlem.FieldByName('Adr1').AsString;
        ZQueryUdskriv.FieldByName('Adr2').AsString :=
          ZqueryMedlem.FieldByName('Adr2').AsString;
        ZQueryUdskriv.FieldByName('PostNr').AsString :=
          ZqueryMedlem.FieldByName('PostNr').AsString;
        ZQueryUdskriv.FieldByName('City').AsString :=
          ZqueryMedlem.FieldByName('City').AsString;
        ZQueryUdskriv.FieldByName('PostNrBy').AsString :=
          ZqueryMedlem.FieldByName('PostNr').AsString + ' ' +
          ZqueryMedlem.FieldByName('City').AsString;
        ZQueryUdskriv.FieldByName('Spec1').AsString :=
          ZqueryMedlem.FieldByName('Spec1').AsString;
        ZQueryUdskriv.FieldByName('Spec2').AsString :=
          ZqueryMedlem.FieldByName('Spec2').AsString;
        ZQueryUdskriv.FieldByName('Spec3').AsString :=
          ZqueryMedlem.FieldByName('Spec3').AsString;
        ZQueryUdskriv.FieldByName('Spec4').AsString :=
          ZqueryMedlem.FieldByName('Spec4').AsString;
        ZQueryUdskriv.FieldByName('Rettidig').AsString :=
          ZQueryKontingentMedlem.FieldByName('SenestRettidigIndbetaling').AsString;
        ZQueryUdskriv.FieldByName('Alder').AsString :=
          IntToStr(YearsBetween(Now,ZqueryMedlem.FieldByName('Foedselsdato').AsDateTime));
        // Oplysninger fra aktiviteter
        If ZQueryKontingentMedlem.FieldByName('BaneDefNr').AsString <> '' Then
          Begin
            With ZQueryAktiviteter.SQL Do
              Begin
                Clear;
                Add('Select * from aktiviteter where (Afd = ' + CurrentAfd +
                ') and (Id = ' + ZQueryKontingentMedlem.FieldByName('BaneDefNr').AsString + ')' );
              End;
            ZQueryAktiviteter.Open;
            If ZQueryAktiviteter.RecordCount = 0 Then
              Begin
                MessageDlg('Aktivitet ikke fundet til indbetalingskort - fejl!',mtWarning,[mbOk],0);
                Exit;
              End;
            If ZQueryAktiviteter.FieldByName('Beskrivelse').AsString = '' Then
              Begin
                ZQueryUdskriv.FieldByName('AktivitetsBeskrivelse').AsString :=
                  ZQueryKontingentMedlem.FieldByName('AltTekst').AsString;
              End
            Else
              Begin
                ZQueryUdskriv.FieldByName('AktivitetsBeskrivelse').AsString :=
                  ZQueryAktiviteter.FieldByName('Beskrivelse').AsString;
              End;
          End
        Else
          Begin
            ZQueryUdskriv.FieldByName('AktivitetsBeskrivelse').AsString :=
              ZQueryKontingentMedlem.FieldByName('AltTekst').AsString;
          End;
        ZQueryUdskriv.FieldByName('ExInfo').AsString :=
          ZQueryAktiviteter.FieldByName('ExInfo').AsString;
        ZQueryUdskriv.FieldByName('BrugerNr').AsString :=
          ZQueryMedlem.FieldByName('brugermedlemsnr').AsString;
        // Land skal findes
        With ZQuery1.SQL Do
          Begin
            Clear;
            Add('Select * from land where landkode = ' +
              ZQueryMedlem.FieldByName('landkode').AsString);
          End;
        ZQuery1.Open;
        If ZQuery1.RecordCount = 0 Then
          Begin
            MessageDlg('Land kan ikke findes - fejl!',mtWarning,[mbOk],0);
            Exit;
          end;
        ZQueryUdskriv.FieldByName('Land').AsString :=
          ZQuery1.FieldByName('Land').AsString;
        ZQueryUdskriv.FieldByName('LandForkort').AsString :=
          ZQuery1.FieldByName('LandForkort').AsString;
      // Hvis værge felt sat
(*       If (Not ZQueryMedlem.FieldByName('Vaerge').IsNull) And
         (ZQueryMedlem.FieldByName('VaergeBetal').AsBoolean = True)   Then
        Begin // Værge skal indsættes*)
        If FlerePaaSamme = 3 Then // PBS
          Begin // kontingentlist skal være sorteret på medlemsnr
            If SammeMedlem <> ZQueryMedlem.FieldByName('MedlemsNr').AsInteger Then
              Begin // Ny sum
                Sum := 0;
                // Nulstil AktPrisTekstSum
                // HelpRich.Clear;
                SammeMedlem := ZQueryMedlem.FieldByName('MedlemsNr').AsInteger;
                // Løb de næste igennem og lav sum...
                While (CountToUdskriv < KontingentList.Count) and
                  (SammeMedlem = ZQueryMedlem.FieldByName('MedlemsNr').AsInteger) Do
                  Begin
                    With ZQueryKontingentMedlem.SQL do
                      Begin
                        Clear;
                        Add('Select * from Kontingent where (Afd = ' + CurrentAfd + ') and ' +
                            '(GiroBilagsnummer = ' + KontingentList.Strings[CountToUdskriv] + ')');
                      end;
                    ZQueryKontingentMedlem.Open;
                    If ZQueryKontingentMedlem.RecordCount = 0 Then
                      Begin
                        MessageDlg('Fejl i kontingentliste',mtError,[mbOk],0);
                        Exit;
                      End;
                    If SammeMedlem = ZQueryKontingentMedlem.FieldByName('MedlemsNr').AsInteger Then
                      Begin
                        // OpdaterAktPrisTekstFelt;
                        Sum := Sum + ZQueryKontingentMedlem.FieldByName('BeloebOpkraevet').AsCurrency;
                        Inc(CountToUdskriv);
                      End
                    Else
                      Begin // Nej ikke samme - så gå en tilbage
                        Dec(CountToUdskriv);
                        SammeMedlem := 0; // Dummy
                        With ZQueryKontingentMedlem.SQL do
                          Begin
                            Clear;
                            Add('Select * from Kontingent where (Afd = ' + CurrentAfd + ') and ' +
                                '(GiroBilagsnummer = ' + KontingentList.Strings[CountToUdskriv] + ')');
                          end;
                        ZQueryKontingentMedlem.Open;
                        If ZQueryKontingentMedlem.RecordCount = 0 Then
                          Begin
                            MessageDlg('Fejl i kontingentliste',mtError,[mbOk],0);
                            Exit;
                          End;
                      End;
                  End;
                // AktPrisTekst skal gemmes i udskriv database
(*                    TempFile := GetTempFile;
                HelpRich.Lines.SaveToFile(TempFile);
                // Hentes ind i Udskrivdatabase over hjælpe felt.
                jvDBRichAktPrisUdskriv.Lines.LoadFromFile(TempFile);
                SysUtils.DeleteFile(TempFile);*)
              End;
          End
        Else If FlerePaaSamme = 2 Then // Flere
          Begin
            If SammeMedlem <> ZQueryKontingentMedlem.FieldByName('MedlemsNr').AsInteger Then
              Begin // Ny sum
                Sum := 0;
                SammeMedlem := ZQueryKontingentMedlem.FieldByName('MedlemsNr').AsInteger;
                // Løb de næste igennem og lav sum...
                HelpCountUdskriv := CountToUdskriv;
                Stop             := False;
                While (HelpCountUdskriv < KontingentList.Count) and not Stop Do
                  Begin
                    With ZQueryKontingentMedlem.SQL do
                      Begin
                        Clear;
                        Add('Select * from Kontingent where (Afd = ' + CurrentAfd + ') and ' +
                            '(GiroBilagsnummer = ' + KontingentList.Strings[HelpCountUdskriv] + ')');
                      end;
                    ZQueryKontingentMedlem.Open;
                    If ZQueryKontingentMedlem.RecordCount = 0 Then
                      Begin
                        MessageDlg('Fejl i kontingentliste',mtError,[mbOk],0);
                        Exit;
                      End;
                    If SammeMedlem = ZQueryKontingentMedlem.FieldByName('MedlemsNr').AsInteger Then
                      Begin
                        Sum := Sum + ZQueryKontingentMedlem.FieldByName('BeloebOpkraevet').AsCurrency;
                        Inc(HelpCountUdskriv);
                      End
                    Else
                      Begin
                        Stop := True;
                      end;
                  End;
              End;
          End
        Else
          Begin // Enkelt
            Sum := ZQueryKontingentMedlem.FieldByName('BeloebOpkraevet').AsCurrency;
          End;
        // Sum
        ZQueryUdskriv.FieldByName('SumAlt').AsCurrency := Sum;
        // Værge findes frem
        If ZQueryMedlem.FieldByName('Vaerge').AsString <> '' Then
          Begin
            With ZQueryVaerge.SQL do
              Begin
                Clear;
                Add('Select * from Medlem where (MedlemsNr = ' +
                  ZQueryMedlem.FieldByName('Vaerge').AsString + ')');
              end;
            ZQueryVaerge.Open;
            If ZQueryVaerge.RecordCount = 0 Then
              Begin
                MessageDlg('Fejl i kontingentliste - Værge kan ikke findes',mtError,[mbOk],0);
                Exit;
              End;
            // Nr
            ZQueryUdskriv.FieldByName('VaergeNr').AsString :=
               ZQueryVaerge.FieldByName('MedlemsNr').AsString;
            // Brugernr
            ZQueryUdskriv.FieldByName('VaergeBrugerNr').AsString :=
                ZQueryVaerge.FieldByName('BrugerMedNr').AsString;
            // Navn
            ZQueryUdskriv.FieldByName('VaergeNavn').AsString :=
              ZQueryVaerge.FieldByName('Fornavn').AsString + ' ' +
              ZQueryVaerge.FieldByName('Efternavn').AsString;
            // Værge adr.
            ZQueryUdskriv.FieldByName('VaergeAdr').AsString :=
              ZQueryVaerge.FieldByName('Adr1').AsString;
            // Værge postnr by
            ZQueryUdskriv.FieldByName('VaergePostNr').AsString :=
              ZQueryVaerge.FieldByName('PostNr').AsString;
            ZQueryUdskriv.FieldByName('VaergeBy').AsString :=
              ZQueryVaerge.FieldByName('Town').AsString;
            ZQueryUdskriv.FieldByName('VaergePostNrBy').AsString :=
              ZQueryVaerge.FieldByName('PostNr').AsString + ' ' +
              ZQueryVaerge.FieldByName('Town').AsString;
          end;
        // Kr og Oere
        ZQueryUdskriv.FieldByName('KrOere').AsCurrency :=
          ZQueryKontingentMedlem.FieldByName('BeloebOpkraevet').AsCurrency;
        BeloebKr := Trunc(ZQueryKontingentMedlem.FieldByName('BeloebOpkraevet').AsFloat);
        BeloebOre:= Round( (ZQueryKontingentMedlem.FieldByName('BeloebOpkraevet').AsFloat
          - Trunc(ZQueryKontingentMedlem.FieldByName('BeloebOpkraevet').AsFloat) )*100 );
        OreStr := IntToStr(BeloebOre);
        If BeloebOre = 0 Then OreStr := '00';
        // Kr
        ZQueryUdskriv.FieldByName('Kr').AsString :=
          IntToStr(BeloebKr);
        // Øre
        ZQueryUdskriv.FieldByName('Oere').AsString :=
          OreStr;
        // Meddelser
        If CheckMeddelser.Checked Then
          Begin // Skal indsættes
            ZQueryUdskriv.FieldByName('Meddelelser').AsString :=
              ZQueryKontingentMedlem.FieldByName('GiroBilagsnummer').AsString;
          End
        Else
          Begin // Blankes
            ZQueryUdskriv.FieldByName('Meddelelser').AsString := '';
          End;
        // Indbetalingslinje
        FormatGiroNr :=  '%.' + Options_Giro_AntalTegnIIdent + 'd';
        If (ZQueryAfdDef.FieldByName('Betalingskort').AsString  <> '01') and
           (ZQueryAfdDef.FieldByName('Betalingskort').AsString  <> '73') Then
          Begin // Ved kortart 04, 71, 75
            // betalingsidentifikation indsættes
            If (ZQueryAfdDef.FieldByName('Betalingskort').AsString  = '71') or
               (ZQueryAfdDef.FieldByName('Betalingskort').AsString  = '04') Then
              Begin
                KontrolNr := Options_Giro_Tegn1 +
                  ZQueryAfdDef.FieldByName('Betalingskort').AsString  +
                  Options_Giro_Tegn2 +
                  ' ' +
                  FillUpStr(ZQueryKontingentMedlem.FieldByName('GiroBilagsnummer').AsString) +
                  Options_Giro_Tegn3 +
                  ZQueryAfdDef.FieldByName('Giro').AsString +
                  Options_Giro_Tegn4;
                ZQueryUdskriv.FieldByName('Indbetalingsnr').AsString :=
                  KontrolNr;
                ZQueryUdskriv.FieldByName('GiroNr').AsString :=
                  FillUpStr(ZQueryKontingentMedlem.FieldByName('GiroBilagsnummer').AsString);
              End
            Else
              Begin
                KontrolNr := Options_Giro_Tegn1 +
                  ZQueryAfdDef.FieldByName('Betalingskort').AsString  +
                  Options_Giro_Tegn2 +
                  FillUpStr(ZQueryKontingentMedlem.FieldByName('GiroBilagsnummer').AsString) +
                  Options_Giro_Tegn3 +
                  ZQueryAfdDef.FieldByName('Giro').AsString +
                  Options_Giro_Tegn4;
                ZQueryUdskriv.FieldByName('Indbetalingsnr').AsString :=
                  KontrolNr;
                ZQueryUdskriv.FieldByName('GiroNr').AsString :=
                  FillUpStr(ZQueryKontingentMedlem.FieldByName('GiroBilagsnummer').AsString);
              End;
          End
        Else
          Begin // Ved kort art 01, 73
            KontrolNr := Options_Giro_Tegn1 +
              ZQueryAfdDef.FieldByName('Betalingskort').AsString  +
              Options_Giro_Tegn2 +
              FillUpStr('0') +
              Options_Giro_Tegn3 +
              ZQueryAfdDef.FieldByName('Giro').AsString +
              Options_Giro_Tegn4;
            ZQueryUdskriv.FieldByName('Indbetalingsnr').AsString :=
              KontrolNr;
            ZQueryUdskriv.FieldByName('GiroNr').AsString :=
              FillUpStr(ZQueryKontingentMedlem.FieldByName('GiroBilagsnummer').AsString);
          End;
        // KlubGiro
        ZQueryUdskriv.FieldByName('KlubGiro').AsString :=
          ZQueryAfdDef.FieldByName('Giro').AsString;
        // KlubNavn
        ZQueryUdskriv.FieldByName('KlubNavn').AsString :=
          ZQueryAfdDef.FieldByName('Navn').AsString;
        // KlubAdr
        ZQueryUdskriv.FieldByName('KlubAdr').AsString :=
          ZQueryAfdDef.FieldByName('Adr').AsString;
        // KlubBy
        ZQueryUdskriv.FieldByName('KlubBy').AsString :=
          ZQueryAfdDef.FieldByName('PostNr').AsString + ' ' +
          ZQueryAfdDef.FieldByName('Town').AsString;
        If ZQueryAfdDef.FieldByName('Betalingskort').AsString = '71' Then
          Begin // PBS kan indsættes
            //K71PBSNr
            ZQueryUdskriv.FieldByName('K71PBSNr').AsString :=
              ZQueryAfdDef.FieldByName('K71PBSNr').AsString;
            //K71DebiGrNr
            ZQueryUdskriv.FieldByName('K71DebiGrNr').AsString :=
              ZQueryAfdDef.FieldByName('K71Debi').AsString;
          End;
        // Periode skal findes
        With ZQuery1.SQL Do
          Begin
            Clear;
            Add('Select * from PeriodeDef where Nr = ' +
              ZQueryKontingentMedlem.FieldByName('PeriodeId').AsString);
          End;
        ZQuery1.Open;
        If ZQuery1.RecordCount = 0 Then
          Begin
            MessageDlg('Periode kan ikke findes - fejl!',mtWarning,[mbOk],0);
            Exit;
          end;
        ZQueryUdskriv.FieldByName('Periode').AsString :=
          ZQuery1.FieldByName('Periode').AsString;
          // Periode beskrivelse
        ZQueryUdskriv.FieldByName('PeriodeBeskrivelse').AsString :=
          ZQuery1.FieldByName('Beskrivelse').AsString;
        // Afsluttet
        ZQueryUdskriv.FieldByName('Afsluttet').AsString :=
          ZQueryKontingentMedlem.FieldByName('Afsluttet').AsString;
(*        // Evt. Mærke informationer
        ZQueryUdskriv.FieldByName('MaerkeBeskrivelse').AsString :=
          MaerkeBesk;
        ZQueryUdskriv.FieldByName('MaerkeNr').AsString :=
          MaerkeNr;
        // Priskategori beskrivelse
        ZQueryUdskriv.FieldByName('PrisBeskrivelse').AsString :=
          AfdTabel.FieldByName('Betegnelse').AsString;
        // Alt. tekst
        ZQueryUdskriv.FieldByName('AltTekst').AsString :=
          ZQueryKontingentMedlem.FieldByName('AltTekst').AsString;
        // Tekst
        IndsaetTekstFelt(TempFileName);
        ZQueryUdskriv.Post;
          // Indsæt Indledning + AktPris i AlTekst
          jvRichAll.Lines.Clear;
          jvRichAll.Lines.AddStrings(jvRichEdit.Lines);
          jvRichAll.Lines.AddStrings(HelpRich.Lines);
        // Afslutning
        ZQueryUdskriv.Edit;
        IndsaetAfslutningTekst('');
          // Indsæt Afslutning i AlTekst
          jvRichAll.Lines.AddStrings(jvRichEdit.Lines);
        ZQueryUdskriv.Post;
        // Al tekst
        ZQueryUdskriv.Edit;
        TempFile := GetTempFile;
        jvRichAll.Lines.SaveToFile(TempFile);
          // Hentes ind i Udskrivdatabase over hjælpe felt.
        jvDBRichAll.Lines.LoadFromFile(TempFile);
        //SysUtils.DeleteFile(TempFile);
        // Så gemmes der (igen)*)
        ZQueryUdskriv.Post;
       // Nustil hjælpe memo
        //RxRichAktPrisSum.Lines.Clear;
      Except
        ZQueryUdskriv.Cancel;
        MessageDlg('Data kunne ikke indsættes; CountToUdskriv= ' + IntToStr(CountToUdskriv),
          mtError,[mbOk],0);
      End;
      Inc(CountToUdskriv);
    End;
  ZQueryUdskriv.Close;
//  GaugeUdskriv.Visible  := False;
  If VisRapportDesigner Then
    Begin
      // Nu skal der vises rapportgenerator
      // Udskriv
      SuperPrintForm := TSuperPrintForm.Create(Self);
      SuperPrintForm.TypeRapport := 80;
      SuperPrintForm.RapportTitel := 'Indbetalingskort...';
      SuperPrintForm.IndlaesFlueben;
      SuperPrintForm.IndlaesRapportCombo;
      SuperPrintForm.ShowModal;
      SuperPrintForm.Free;
    End;
End;

(*
Begin // Ikke værge ; medlem indsættes
  If FlerePaaSamme = 3 Then // PBS
    Begin // kontingentlist skal være sorteret på medlemsnr
      If SammeMedlem <> ZqueryMedlem.FieldByName('MedlemsNr').AsInteger Then
        Begin // Ny sum
          Sum := 0;
          // Nulstil AktPrisTekstSum
          HelpRich.Lines.Clear;
          SammeMedlem := ZqueryMedlem.FieldByName('MedlemsNr').AsInteger;
          // Løb de næste igennem og lav sum...
          While (CountToUdskriv < KontingentList.Count) and
            (SammeMedlem = ZqueryMedlem.FieldByName('MedlemsNr').AsInteger) Do
            Begin
              If Not ZQueryKontingentMedlem.FindKey([CurrentAfd,KontingentList.Strings[CountToUdskriv]]) Then
                Begin
                  MessageDlg('Fejl i kontingentliste',mtError,[mbOk],0);
                  Exit;
                End;
              If SammeMedlem = ZqueryMedlem.FieldByName('MedlemsNr').AsInteger Then
                Begin
                  OpdaterAktPrisTekstFelt;
                  Sum := Sum + ZQueryKontingentMedlem.FieldByName('BeloebOpkraevet').AsCurrency;
                  Inc(CountToUdskriv);
                End
              Else
                Begin // Nej ikke samme - så gå en tilbage
                  Dec(CountToUdskriv);
                  SammeMedlem := 0; // Dummy
                  If Not ZQueryKontingentMedlem.FindKey([CurrentAfd,KontingentList.Strings[CountToUdskriv]]) Then
                    Begin
                      AdvMessageDlg('Fejl i kontingentliste',mtError,[mbOk],0);
                      Exit;
                    End;
                End;
            End;
          // AktPrisTekst skal gemmes i udskriv database
          TempFile := GetTempFile;
          HelpRich.Lines.SaveToFile(TempFile);
          // Hentes ind i Udskrivdatabase over hjælpe felt.
          jvDBRichAktPrisUdskriv.Lines.LoadFromFile(TempFile);
          //SysUtils.DeleteFile(TempFile);
        End;
    End
  Else If FlerePaaSamme = 2 Then // Flere
    Begin
      If SammeMedlem <> ZqueryMedlem.FieldByName('MedlemsNr').AsInteger Then
        Begin // Ny sum
          HelpRich.Lines.Clear;
          Sum := 0;
          SammeMedlem := ZqueryMedlem.FieldByName('MedlemsNr').AsInteger;
          // Løb de næste igennem og lav sum...
          BookMedlem := ZQueryKontingentMedlem.GetBookmark;
          HelpCountUdskriv := CountToUdskriv;
          While HelpCountUdskriv < KontingentList.Count Do
            Begin

              If Not ZQueryKontingentMedlem.FindKey([CurrentAfd,KontingentList.Strings[HelpCountUdskriv]]) Then
                Begin
                  AdvMessageDlg('Fejl i kontingentliste',mtError,[mbOk],0);
                  Exit;
                End;
              If SammeMedlem = ZqueryMedlem.FieldByName('MedlemsNr').AsInteger Then
                Begin
                  Sum := Sum + ZQueryKontingentMedlem.FieldByName('BeloebOpkraevet').AsCurrency;
                  OpdaterAktPrisTekstFelt;
                End;
              Inc(HelpCountUdskriv);
            End;
          ZQueryKontingentMedlem.GotoBookmark(BookMedlem);
        End;
    End
  Else
    Begin // Enkelt
      HelpRich.Lines.Clear;
      OpdaterAktPrisTekstFelt;
      TempFile := GetTempFile;
      HelpRich.Lines.SaveToFile(TempFile);
      // Hentes ind i Udskrivdatabase over hjælpe felt.
      jvDBRichAktPrisUdskriv.Lines.LoadFromFile(TempFile);
      //SysUtils.DeleteFile(TempFile);
      Sum := ZQueryKontingentMedlem.FieldByName('BeloebOpkraevet').AsCurrency;
    End;
  // Sum
  UdskrivKontigentTabel.FieldByName('Sum').AsCurrency := Sum;
  // Sum Kr og Oere
  BeloebKr := Trunc(Sum);
  BeloebOre:= Round( (Sum - Trunc(Sum) ) * 100 );
  OreStr := IntToStr(BeloebOre);
  If BeloebOre = 0 Then OreStr := '00';
  // Kr
  UdskrivKontigentTabel.FieldByName('SumKr').AsString :=
    IntToStr(BeloebKr);
  // Øre
  UdskrivKontigentTabel.FieldByName('SumOere').AsString := OreStr;
  // Værge
  UdskrivKontigentTabel.FieldByName('VaergeNr').AsString :=
    ZqueryMedlem.FieldByName('MedlemsNr').AsString;
  UdskrivKontigentTabel.FieldByName('VaergeBrugerNr').AsString :=
    ZqueryMedlem.FieldByName('BrugerMedNr').AsString;
  // Værge navn
  UdskrivKontigentTabel.FieldByName('VaergeNavn').AsString :=
    ZqueryMedlem.FieldByName('Fornavn').AsString + ' ' +
    ZqueryMedlem.FieldByName('Efternavn').AsString;
  // Værge adr.
  UdskrivKontigentTabel.FieldByName('VaergeAdr').AsString :=
    ZqueryMedlem.FieldByName('Adr1').AsString;
  // Værge postnr by
  UdskrivKontigentTabel.FieldByName('VaergePostNr').AsString :=
    ZqueryMedlem.FieldByName('PostNr').AsString;
  UdskrivKontigentTabel.FieldByName('VaergeBy').AsString :=
    ZqueryMedlem.FieldByName('By').AsString;
  UdskrivKontigentTabel.FieldByName('VaergePostNrBy').AsString :=
    ZqueryMedlem.FieldByName('PostNr').AsString + ' ' +
    ZqueryMedlem.FieldByName('By').AsString;
End;
end;
*)

end.

