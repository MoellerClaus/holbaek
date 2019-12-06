//**********************************************************
// Checkdatabase
// 05.12.2016
//**********************************************************

unit CheckDatabase;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  StdCtrls, ActnList, ZDataset, DB;

type

  { TCheckDatabaseForm }

  TCheckDatabaseForm = class(TForm)
    Label1: TLabel;
    Memo1: TMemo;
    ProgressBar1: TProgressBar;
    StatusBar1: TStatusBar;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure HelpExecute(Sender: TObject);
    procedure LukExecute(Sender: TObject);
  private
    { private declarations }
    Tabeller : TStringList;
    procedure KontoBesDo;
    procedure KassekladdeDo;
    procedure PeriodeDefDo;
    procedure MomsDefDo;
    procedure OkoMaerkeDefDo;
    procedure AfstemningsKontiDo;
    procedure KassekladdeDefDo;
    procedure BilagDo;
    procedure MedlemDo;
    procedure MedlemEmailDo;
    procedure PostNrDo;
    procedure LandDo;
    procedure AktiviteterDo;
    procedure PrisKategoriDo;
    procedure AktMedDo;
    procedure MarkDefDo;
    procedure MarksDo;
    procedure AfdDefDo;
    procedure KontingentDefDo;
    procedure RabatDefDo;
    procedure RabatKategoriDo;
    procedure KontingentTekstDo;

  public
    { public declarations }
    Procedure Check;
    procedure CheckTriggers;
  end;

var
  CheckDatabaseForm: TCheckDatabaseForm;

implementation

{$R *.lfm}

Uses MainData, HolbaekConst, DateUtils;

{ TCheckDatabaseForm }

//**********************************************************
// Close
//**********************************************************
procedure TCheckDatabaseForm.LukExecute(Sender: TObject);
begin
  Close;
end;

//**********************************************************
// Hjaelp
//**********************************************************
procedure TCheckDatabaseForm.HelpExecute(Sender: TObject);
begin
  ShowMessage('Hjælp');
end;

//**********************************************************
// Create
//**********************************************************
procedure TCheckDatabaseForm.FormCreate(Sender: TObject);
begin
  Position := poDesigned;
  (*Top := 10;
  Left := 30;*)
  // Farver
  ToolBar1.Color    := H_Menu_knapper_Farve;
  Color             := H_Window_Baggrund;
  // Init
  Tabeller          := TStringList.Create;
end;

//**********************************************************************
// Destroy
//**********************************************************************
procedure TCheckDatabaseForm.FormDestroy(Sender: TObject);
begin
  Tabeller.Free;
end;


//**********************************************************
// Check
//**********************************************************
procedure TCheckDatabaseForm.Check;
Begin
  MainDataModule.ZConnection1.GetTableNames('',Tabeller);
//  ShowMessage('Antal : ' + IntToStr(Tabeller.Count));
  If Tabeller.IndexOf('kontobes') = -1 Then
    Begin
      KontoBesDo;
    end;
  If Tabeller.IndexOf('kassekladde') = -1 Then
    Begin
      KassekladdeDo;
    end;
  If Tabeller.IndexOf('periodedef') = -1 Then
    Begin
      PeriodeDefDo;
    end;
  If Tabeller.IndexOf('momskode') = -1 Then
    Begin
      MomsDefDo;
    end;
  If Tabeller.IndexOf('okomaerkedef') = -1 Then
    Begin
      OkoMaerkeDefDo;
    end;
  If Tabeller.IndexOf('AfstemningsKonti') = -1 Then
    Begin
      AfstemningsKontiDo;
    end;
  If Tabeller.IndexOf('KassekladdeDef') = -1 Then
    Begin
      KassekladdeDefDo;
    end;
  If Tabeller.IndexOf('Bilag') = -1 Then
    Begin
      BilagDo;
    end;
  If Tabeller.IndexOf('medlem') = -1 Then
    Begin
      MedlemDo;
    end;
  If Tabeller.IndexOf('MedlemEmail') = -1 Then
    Begin
      MedlemEmailDo;
    end;
  If Tabeller.IndexOf('PostNr') = -1 Then
    Begin
      PostNrDo;
    end;
  If Tabeller.IndexOf('Land') = -1 Then
    Begin
      LandDo;
    end;
  If Tabeller.IndexOf('Aktiviteter') = -1 Then
    Begin
      AktiviteterDo;
    end;
  If Tabeller.IndexOf('PrisKategori') = -1 Then
    Begin
      PrisKategoriDo;
    end;
  If Tabeller.IndexOf('AktMed') = -1 Then
    Begin
      AktMedDo;
    end;
  If Tabeller.IndexOf('MarkDef') = -1 Then
    Begin
      MarkDefDo;
    end;
  If Tabeller.IndexOf('Marks') = -1 Then
    Begin
      MarksDo;
    end;
  If Tabeller.IndexOf('AfdDef') = -1 Then
    Begin
      AfdDefDo;
    end;
  If Tabeller.IndexOf('Kontingent') = -1 Then
    Begin
      KontingentDefDo;
    end;
  If Tabeller.IndexOf('KontingentTekst') = -1 Then
    Begin
      KontingentTekstDo;
    end;
  If Tabeller.IndexOf('RabatDef') = -1 Then
    Begin
      RabatDefDo;
    end;
  If Tabeller.IndexOf('RabatKategori') = -1 Then
    Begin
      RabatKategoriDo;
    end;
end;

//**********************************************************
// Check triggers
//**********************************************************
procedure TCheckDatabaseForm.CheckTriggers;
Begin
End;

//**********************************************************
// KontoBes
//**********************************************************
procedure TCheckDatabaseForm.KontoBesDo;
Begin
  // Check maybe if fields are complete
  With MainDataModule.ZQuery1 do
    Begin
      Try
        With SQL do
          Begin
            Clear;
            Add('CREATE TABLE kontobes (');
            Add('  id   INTEGER PRIMARY KEY AUTOINCREMENT,');
            Add('  afd  INTEGER,');
            Add('  beskrivelse VARCHAR(40),');
            Add('  momskode INTEGER,');
            Add('  brugerkonto INTEGER,');
            Add('  kgb VARCHAR(2),');
            Add('  type INTEGER,');
            Add('  fra INTEGER,');
            Add('  til INTEGER,');
            Add('  summed INTEGER,');
            Add('  sumtype INTEGER,');
            Add('  defaulttekst VARCHAR(40),');
            Add('  spaerret INTEGER,');
            Add('  direkte INTEGER,');
            Add('  afstembar INTEGER,');
            Add('  default_d INTEGER,');
            Add('  rettetd VARCHAR(23),');
            Add('  visningd_k INTEGER,');
            Add('  defaultmodkonto INTEGER,');
            Add('  okonr INTEGER,');
            Add('  visikketekst INTEGER,');
            Add('  VigNr INTEGER');
            Add(')');
          end;
        ExecSQL;
        //Maindata.MainDataModule.ZConnection1.Commit;
      except
        on E: EDatabaseError do
          begin
            MessageDlg('Error', 'A database error has occurred. Technical error message: ' +
                E.Message, mtError, [mbOK], 0);
          end;
      end;
      // Indsæt default minimums data
      Try
        SQL.Clear;
        SQL.Add('Select * from kontobes');
        Open;
        Append;
        Edit;
        FieldByName('Afd').AsInteger              := 1;
        FieldByName('Beskrivelse').AsString       := 'Konto';
        FieldByName('BrugerKonto').AsString       := '100';
        FieldByName('Type').AsInteger             := 1;
        FieldByName('BrugerKonto').AsString       := '100';
        FieldByName('Direkte').AsString           := '1';
        Post;
        ApplyUpdates;
        // Maindata.MainDataModule.ZConnection1.Commit;
      Except
        on E: EDatabaseError do
          begin
            MessageDlg('Error', 'A database error has occurred. Technical error message: ' +
                E.Message, mtError, [mbOK], 0);
          end;
      end;
    end; // End with
end;

//**********************************************************
// Kassekladde
//**********************************************************
procedure TCheckDatabaseForm.KassekladdeDo;
Begin
  // Check maybe if fields are complete
  With MainDataModule.ZQuery1 do
    Begin
      Try
        With SQL do
          Begin
            Clear;
            Add('CREATE TABLE kassekladde (');
            Add('  nr  INTEGER PRIMARY KEY AUTOINCREMENT,');
            Add('  afd INTEGER NOT NULL,');
            Add('  periode INTEGER,');
            Add('  bilagsnr INTEGER,');
            Add('  tekst VARCHAR(40),');
            Add('  type INTEGER,');
            Add('  d_k VARCHAR(1),');
            Add('  konto INTEGER,');
            Add('  modkonto INTEGER,');
            Add('  moms INTEGER,');
            Add('  dato REAL,');
            Add('  beloeb FLOAT,');
            Add('  nokasse INTEGER,');
            Add('  okonr INTEGER');
            Add(')');
          end;
        ExecSQL;
        // MainDataModule.ZConnection1.Commit;
      Except
        on E: EDatabaseError do
          begin
            MessageDlg('Error', 'A database error has occurred. Technical error message: ' +
                E.Message, mtError, [mbOK], 0);
          end;
       end;
    end;
End;

//**********************************************************
// Periode
//**********************************************************
procedure TCheckDatabaseForm.PeriodeDefDo;
Begin
  // Check maybe if fields are complete
  With MainDataModule.ZQuery1 do
    Begin
      Try
        With SQL do
          Begin
            Clear;
            Add('CREATE TABLE periodedef(');
            Add('  nr  INTEGER PRIMARY KEY AUTOINCREMENT,');
            Add('  afd INTEGER NOT NULL,');
            Add('  periode CHAR(4),');
            Add('  beskrivelse VARCHAR(40),');
            Add('  datofra REAL,');
            Add('  datotil REAL,');
            Add('  afsluttet INTEGER,');
            Add('  nextperiod INTEGER,');
            Add('  option INTEGER');
            Add(')');
          end;
        ExecSQL;
        // MainDataModule.ZConnection1.Commit;
      except
        on E: EDatabaseError do
          begin
            MessageDlg('Error', 'A database error has occurred. Technical error message: ' +
                E.Message, mtError, [mbOK], 0);
          end;
      end;
      // Indsæt default minimums data
      Try
        SQL.Clear;
        SQL.Add('Select * from periodedef');
        Open;
        Append;
        Edit;
        FieldByName('Afd').AsInteger                 := 1;
        FieldByName('Periode').AsString              := '2017';
        FieldByName('Beskrivelse').AsString          := 'Sæson 2017';
        FieldByName('DatoFra').AsFloat               := DateTimeToJulianDate(StrToDate('01-01-1900'));
        FieldByName('DatoTil').AsFloat               := DateTimeToJulianDate(StrToDate('01-01-2100'));
        Post;
        ApplyUpdates;
        // MainDataModule.ZConnection1.Commit;
      Except
        on E: EDatabaseError do
          begin
            MessageDlg('Error', 'A database error has occurred. Technical error message: ' +
                E.Message, mtError, [mbOK], 0);
          end;
      end;
    End;
End;

//**********************************************************
// Moms
//**********************************************************
procedure TCheckDatabaseForm.MomsDefDo;
Begin
  // Check maybe if fields are complete
  With MainDataModule.ZQuery1 do
    Begin
      Try
        With SQL do
          Begin
            Clear;
            Add('CREATE TABLE momskode(');
            Add('  nr  INTEGER PRIMARY KEY AUTOINCREMENT,');
            Add('  afd INTEGER NOT NULL,');
            Add('  navn CHAR(3),');
            Add('  procent FLOAT,');
            Add('  salgsmoms CHAR(1),');
            Add('  beskrivelse VARCHAR(40),');
            Add('  momskonto INTEGER,');
            Add('  VigNr INTEGER');
            Add(')');
          end;
        ExecSQL;
        // MainDataModule.ZConnection1.Commit;
      except
        on E: EDatabaseError do
          begin
            MessageDlg('Error', 'A database error has occurred. Technical error message: ' +
                E.Message, mtError, [mbOK], 0);
          end;
      end;
      // Indsæt default minimums data
      Try
        SQL.Clear;
        SQL.Add('Select * from momskode');
        Open;
        Append;
        Edit;
        FieldByName('Afd').AsInteger          := 1;
        FieldByName('Navn').AsString          := 'S25';
        FieldByName('procent').AsString       := '25';
        FieldByName('SalgsMoms').AsString     := '1';
        FieldByName('Beskrivelse').AsString   := 'Noget med salgsmoms';
        Post;
        ApplyUpdates;
        // MainDataModule.ZConnection1.Commit;
      Except
        on E: EDatabaseError do
          begin
            MessageDlg('Error', 'A database error has occurred. Technical error message: ' +
                E.Message, mtError, [mbOK], 0);
          end;
      end;
    end;
End;

//**********************************************************
// Okomærke
//**********************************************************
procedure TCheckDatabaseForm.OkoMaerkeDefDo;
Begin
  // Check maybe if fields are complete
  With MainDataModule.ZQuery1 do
    Begin
      Try
        With SQL do
          Begin
            Clear;
            Add('CREATE TABLE okomaerkedef(');
            Add('  nr  INTEGER PRIMARY KEY AUTOINCREMENT,');
            Add('  afd INTEGER NOT NULL,');
            Add('  beskrivelse VARCHAR(40),');
            Add('  VigNr INTEGER');
            Add(')');
          end;
        ExecSQL;
        // MainDataModule.ZConnection1.Commit;
      except
        on E: EDatabaseError do
          begin
            MessageDlg('Error', 'A database error has occurred. Technical error message: ' +
                E.Message, mtError, [mbOK], 0);
          end;
      end;
      // Indsæt default minimums data
      Try
        SQL.Clear;
        SQL.Add('Select * from okomaerkedef');
        Open;
        Append;
        Edit;
        FieldByName('Afd').AsInteger          := 1;
        FieldByName('Beskrivelse').AsString   := 'Sikke en fest øøøø';
        Post;
        ApplyUpdates;
        // MainDataModule.ZConnection1.Commit;
      Except
        on E: EDatabaseError do
          begin
            MessageDlg('Error', 'A database error has occurred. Technical error message: ' +
                E.Message, mtError, [mbOK], 0);
          end;
      end;
    end;
End;

//**********************************************************
// Afstemningskonti
//**********************************************************
procedure TCheckDatabaseForm.AfstemningsKontiDo;
Begin
  // Check maybe if fields are complete
  With MainDataModule.ZQuery1 do
    Begin
      Try
        With SQL do
          Begin
            Clear;
            Add('CREATE TABLE AfstemningsKonti(');
            Add('  nr  INTEGER PRIMARY KEY AUTOINCREMENT,');
            Add('  afd INTEGER NOT NULL,');
            Add('  brugerkonto INTEGER');
            Add(')');
          end;
        ExecSQL;
        // MainDataModule.ZConnection1.Commit;
      except
        on E: EDatabaseError do
          begin
            MessageDlg('Error', 'A database error has occurred. Technical error message: ' +
                E.Message, mtError, [mbOK], 0);
          end;
      end;
    end;
End;

//**********************************************************
// KassekladdeDef
//**********************************************************
procedure TCheckDatabaseForm.KassekladdeDefDo;
Begin
  // Check maybe if fields are complete
  With MainDataModule.ZQuery1 do
    Begin
      Try
        With SQL do
          Begin
            Clear;
            Add('CREATE TABLE KassekladdeDef(');
            Add('  nr  INTEGER PRIMARY KEY AUTOINCREMENT,');
            Add('  afd INTEGER NOT NULL,');
            Add('  beskrivelse VARCHAR(40),');
            Add('  toemmes INTEGER');
            Add(')');
          end;
        ExecSQL;
        // MainDataModule.ZConnection1.Commit;
      except
        on E: EDatabaseError do
          begin
            MessageDlg('Error', 'A database error has occurred. Technical error message: ' +
                E.Message, mtError, [mbOK], 0);
          end;
      end;
      // Indsæt default minimums data
      Try
        SQL.Clear;
        SQL.Add('Select * from KassekladdeDef');
        Open;
        Append;
        Edit;
        FieldByName('Afd').AsInteger          := 1;
        FieldByName('Beskrivelse').AsString   := 'Normal';
        FieldByName('Toemmes').AsString       := '1';
        Post;
        ApplyUpdates;
        // MainDataModule.ZConnection1.Commit;
      Except
        on E: EDatabaseError do
          begin
            MessageDlg('Error', 'A database error has occurred. Technical error message: ' +
                E.Message, mtError, [mbOK], 0);
          end;
      end;
    end;
End;

//**********************************************************
// Bilag
//**********************************************************
procedure TCheckDatabaseForm.BilagDo;
Begin
  // Check maybe if fields are complete
  With MainDataModule.ZQuery1 do
    Begin
      Try
        With SQL do
          Begin
            Clear;
            Add('CREATE TABLE bilag (');
            Add('  nr  INTEGER PRIMARY KEY AUTOINCREMENT,');
            Add('  afd INTEGER NOT NULL,');
            Add('  periode INTEGER,');
            Add('  bilagsnr INTEGER,');
            Add('  tekst VARCHAR(40),');
            Add('  ktype VARCHAR(1),');
            Add('  d_k VARCHAR(1),');
            Add('  konto INTEGER,');
            Add('  moms INTEGER,');
            Add('  dato REAL,');
            Add('  beloeb FLOAT,');
            Add('  bogfoertdato REAL,');
            Add('  okonr INTEGER');
            Add(')');
          end;
        ExecSQL;
        // MainDataModule.ZConnection1.Commit;
      Except
        on E: EDatabaseError do
          begin
            MessageDlg('Error', 'A database error has occurred. Technical error message: ' +
                E.Message, mtError, [mbOK], 0);
          end;
       end;
    end
End;

//**********************************************************
// Medlem
//**********************************************************
procedure TCheckDatabaseForm.MedlemDo;
Begin
  With MainDataModule.ZQuery1 do
    Begin
      Try
        With SQL do
          Begin
            Clear;
            Add('CREATE TABLE medlem (');
            Add('  medlemsnr INTEGER PRIMARY KEY AUTOINCREMENT,');
            Add('  brugermedlemsnr FLOAT,');
            Add('  fornavn VARCHAR(40),');
            Add('  efternavn VARCHAR(40),');
            Add('  adr1 VARCHAR(40),');
            Add('  adr2 VARCHAR(40),');
            Add('  landkode INTEGER,');
            Add('  postnr VARCHAR(6),');
            Add('  city VARCHAR(40),');
            Add('  telefon VARCHAR(40),');
            Add('  fax VARCHAR(40),');
            Add('  mobiltlfnr VARCHAR(40),');
            Add('  foedselsdato REAL,');
            Add('  medlemsiden REAL,');
            Add('  mand INTEGER,');
            Add('  spec1 VARCHAR(40),');
            Add('  spec2 VARCHAR(40),');
            Add('  spec3 VARCHAR(40),');
            Add('  spec4 VARCHAR(40),');
            Add('  beskrivelse BLOB');
            Add('  vaerge INTEGER,');
            Add('  vaergebetal INTEGER,');
            Add('  billedtype VARCHAR(8),');
            Add('  billede BLOB,');
            Add('  pbsaftalenr FLOAT,');
            Add('  pbsbankreg VARCHAR(4),');
            Add('  pbskontonr VARCHAR(10),');
            Add('  pbscpr1 VARCHAR(6),');
            Add('  pbscpr2 VARCHAR(4),');
            Add('  pbskundenr FLOAT,');
            Add('  pbsgammeltnr FLOAT,');
            Add('  pbsaktion INTEGER,');
            Add('  pbssidstedato TIMESTAMP,');
            Add('  pbsstatus INTEGER,');
            Add('  udmeldtd REAL,');
            Add('  vignr INTEGER');
            Add(')');
          end;
        ExecSQL;
        // MainDataModule.ZConnection1.Commit;
      Except
        on E: EDatabaseError do
          begin
            MessageDlg('Error', 'A database error has occurred. Technical error message: ' +
                E.Message, mtError, [mbOK], 0);
          end;
       end;
    end
End;


//**********************************************************
// MedlemEmail
//**********************************************************
procedure TCheckDatabaseForm.MedlemEmailDo;
Begin
  With MainDataModule.ZQuery1 do
    Begin
      Try
        With SQL do
          Begin
            Clear;
            Add('CREATE TABLE medlememail (');
            Add('  nr  INTEGER PRIMARY KEY AUTOINCREMENT,');
            Add('  medlemsnr INTEGER,');
            Add('  email VARCHAR(80)');
            Add(')');
          end;
        ExecSQL;
        // MainDataModule.ZConnection1.Commit;
      Except
        on E: EDatabaseError do
          begin
            MessageDlg('Error', 'A database error has occurred. Technical error message: ' +
                E.Message, mtError, [mbOK], 0);
          end;
       end;
    end;
End;


//**********************************************************
// PostNr
//**********************************************************
procedure TCheckDatabaseForm.PostNrDo;
Begin
  With MainDataModule.ZQuery1 do
    Begin
      Try
        With SQL do
          Begin
            Clear;
            Add('CREATE TABLE postnr (');
            Add('  id INTEGER PRIMARY KEY AUTOINCREMENT,');
            Add('  landkode INTEGER,');
            Add('  postnr VARCHAR(6),');
            Add('  town VARCHAR(40)');
            Add(')');
          end;
        ExecSQL;
        // MainDataModule.ZConnection1.Commit;
      Except
        on E: EDatabaseError do
          begin
            MessageDlg('Error', 'A database error has occurred. Technical error message: ' +
                E.Message, mtError, [mbOK], 0);
          end;
       end;
    end;
End;

//**********************************************************
// Land
//**********************************************************
procedure TCheckDatabaseForm.LandDo;
Begin
  With MainDataModule.ZQuery1 do
    Begin
      Try
        With SQL do
          Begin
            Clear;
            Add('CREATE TABLE land (');
            Add('  landkode INTEGER PRIMARY KEY AUTOINCREMENT,');
            Add('  land VARCHAR(40),');
            Add('  landforkort VARCHAR(3),');
            Add('  cifre INTEGER,');
            Add('  type INTEGER,');
            Add('  ktype INTEGER');
            Add(')');
          end;
        ExecSQL;
        // MainDataModule.ZConnection1.Commit;
      Except
        on E: EDatabaseError do
          begin
            MessageDlg('Error', 'A database error has occurred. Technical error message: ' +
                E.Message, mtError, [mbOK], 0);
          end;
       end;
      // Indsæt default minimums data
      Try
        SQL.Clear;
        SQL.Add('Select * from land');
        Open;
        Append;
        Edit;
        FieldByName('Land').AsString           := 'Danmark';
        FieldByName('LandForKort').AsString    := 'DK';
        FieldByName('Cifre').AsInteger         := 4;
        FieldByName('Type').AsInteger          := 0;
        Post;
        ApplyUpdates;
        // MainDataModule.ZConnection1.Commit;
      Except
        on E: EDatabaseError do
          begin
            MessageDlg('Error', 'A database error has occurred. Technical error message: ' +
                E.Message, mtError, [mbOK], 0);
          end;
      End;
    end
End;


//**********************************************************
// Aktiviteter
//**********************************************************
procedure TCheckDatabaseForm.AktiviteterDo;
Begin
  With MainDataModule.ZQuery1 do
    Begin
      Try
        With SQL do
          Begin
            Clear;
            Add('CREATE TABLE aktiviteter (');
            Add('  id INTEGER PRIMARY KEY AUTOINCREMENT,');
            Add('  afd INTEGER NOT NULL,');
            Add('  banedefnr INTEGER,');
            Add('  beskrivelse VARCHAR(40),');
            Add('  vis INTEGER,');
            Add('  exinfo VARCHAR(40),');
            Add('  konto INTEGER,');
            Add('  modkonto INTEGER,');
            Add('  maxantal INTEGER,');
            Add('  maxoption INTEGER,');
            Add('  naestefelt INTEGER,');
            Add('  VigNr INTEGER');
            Add(')');
          end;
        ExecSQL;
        // MainDataModule.ZConnection1.Commit;
      Except
        on E: EDatabaseError do
          begin
            MessageDlg('Error', 'A database error has occurred. Technical error message: ' +
                E.Message, mtError, [mbOK], 0);
          end;
       end;
    end;
End;


//**********************************************************
// Pris kategori
//**********************************************************
procedure TCheckDatabaseForm.PrisKategoriDo;
Begin
  With MainDataModule.ZQuery1 do
    Begin
      Try
        With SQL do
          Begin
            Clear;
            Add('CREATE TABLE priskategori (');
            Add('  id INTEGER PRIMARY KEY AUTOINCREMENT,');
            Add('  afd INTEGER,');
            Add('  pristype INTEGER,');
            Add('  beskrivelse VARCHAR(40),');
            Add('  pris FLOAT,');
            Add('  vis INTEGER,');
            Add('  special INTEGER,');
            Add('  VigNr INTEGER');
            Add(')');
          end;
        ExecSQL;
        // MainDataModule.ZConnection1.Commit;
      Except
        on E: EDatabaseError do
          begin
            MessageDlg('Error', 'A database error has occurred. Technical error message: ' +
                E.Message, mtError, [mbOK], 0);
          end;
       end;
    end
End;

//**********************************************************
// Akt med
//**********************************************************
procedure TCheckDatabaseForm.AktMedDo;
Begin
  With MainDataModule.ZQuery1 do
    Begin
      Try
        With SQL do
          Begin
            Clear;
            Add('CREATE TABLE aktmed (');
            Add('  id INTEGER PRIMARY KEY AUTOINCREMENT,');
            Add('  afd INTEGER NOT NULL,');
            Add('  pristype INTEGER,');
            Add('  medlemsnr INTEGER,');
            Add('  banedefnr INTEGER,');
            Add('  dato REAL');
            Add(')');
          end;
        ExecSQL;
        // MainDataModule.ZConnection1.Commit;
      Except
        on E: EDatabaseError do
          begin
            MessageDlg('Error', 'A database error has occurred. Technical error message: ' +
                E.Message, mtError, [mbOK], 0);
          end;
       end;
    end
End;

//**********************************************************
// MarkDef
//**********************************************************
procedure TCheckDatabaseForm.MarkDefDo;
Begin
  With MainDataModule.ZQuery1 do
    Begin
      Try
        With SQL do
          Begin
            Clear;
            Add('CREATE TABLE markdef (');
            Add('  id INTEGER PRIMARY KEY AUTOINCREMENT,');
            Add('  beskrivelse VARCHAR(40),');
            Add('  VigNr INTEGER');
            Add(')');
          end;
        ExecSQL;
        // MainDataModule.ZConnection1.Commit;
      Except
        on E: EDatabaseError do
          begin
            MessageDlg('Error', 'A database error has occurred. Technical error message: ' +
                E.Message, mtError, [mbOK], 0);
          end;
       end;
    end;
End;

//**********************************************************
// Marks
//**********************************************************
procedure TCheckDatabaseForm.MarksDo;
Begin
  With MainDataModule.ZQuery1 do
    Begin
      Try
        With SQL do
          Begin
            Clear;
            Add('CREATE TABLE marks (');
            Add('  id INTEGER PRIMARY KEY AUTOINCREMENT,');
            Add('  markid INTEGER,');
            Add('  medlemsnr INTEGER,');
            Add('  dato REAL');
            Add(')');
          end;
        ExecSQL;
        // MainDataModule.ZConnection1.Commit;
      Except
        on E: EDatabaseError do
          begin
            MessageDlg('Error', 'A database error has occurred. Technical error message: ' +
                E.Message, mtError, [mbOK], 0);
          end;
       end;
    end;
End;

//**********************************************************
// AfdDefDo
//**********************************************************
procedure TCheckDatabaseForm.AfdDefDo;
Begin
  With MainDataModule.ZQuery1 do
    Begin
      Try
        With SQL do
          Begin
            Clear;
            Add('CREATE TABLE afddef (');
            Add('  afd INTEGER PRIMARY KEY AUTOINCREMENT,');
            Add('  navn VARCHAR(40),');
            Add('  kortnavn VARCHAR(6),');
            Add('  adr VARCHAR(40),');
            Add('  postnr VARCHAR(6),');
            Add('  town VARCHAR(40),');
            Add('  fi VARCHAR(20),');
            Add('  se VARCHAR(8),');
            Add('  telefon VARCHAR(10),');
            Add('  fax VARCHAR(10),');
            Add('  bankkonto VARCHAR(10),');
            Add('  giro VARCHAR(8),');
            Add('  betalingskort VARCHAR(2),');
            Add('  email VARCHAR(40),');
            Add('  hjemmeside VARCHAR(40),');
            Add('  k71pbsnr VARCHAR(40),');
            Add('  k71debi VARCHAR(40),');
            Add('  pbsnr VARCHAR(8),');
            Add('  datalevnr VARCHAR(15),');
            Add('  bankregnr VARCHAR(4),');
            Add('  periode VARCHAR(4),');
            Add('  smtpserver VARCHAR(80),');
            Add('  smtppassword VARCHAR(80),');
            Add('  port VARCHAR(4),');
            Add('  brugerid VARCHAR(40),');
            Add('  smtplogon VARCHAR(1),');
            Add('  pop3server VARCHAR(80),');
            Add('  accountname VARCHAR(40),');
            Add('  password VARCHAR(20),');
            Add('  landkode INTEGER,');
            Add('  landkodedefault INTEGER,');
            Add('  postnrdefault VARCHAR(6),');
            Add('  ftphost VARCHAR(80),');
            Add('  ftppassword VARCHAR(20),');
            Add('  ftpport VARCHAR(2),');
            Add('  ftpuserid VARCHAR(80),');
            Add('  ftpvignavn VARCHAR(40),');
            Add('  ftpbrugertlf VARCHAR(15),');
            Add('  ftpbiblopaanet VARCHAR(80),');
            Add('  ftpcheckbase INTEGER,');
            Add('  proxyhost VARCHAR(80),');
            Add('  proxypassword VARCHAR(20),');
            Add('  proxyport VARCHAR(2),');
            Add('  proxytype INTEGER,');
            Add('  proxyusername VARCHAR(40),');
            Add('  askdataup INTEGER,');
            Add('  snuser INTEGER,');
            Add('  medtagskabeloner INTEGER,');
            Add('  smtpafsender VARCHAR(40),');
            Add('  pbsdrift INTEGER,');
            Add('  logning INTEGER,');
            Add('  mailsystem INTEGER,');
            Add('  spec1 VARCHAR(40),');
            Add('  spec2 VARCHAR(40),');
            Add('  spec3 VARCHAR(40),');
            Add('  spec4 VARCHAR(40),');
            Add('  mailreadreceipt INTEGER,');
            Add('  mailmaxburst INTEGER,');
            Add('  mailtidimellemburst INTEGER');
            Add(')');
          end;
        ExecSQL;
        // MainDataModule.ZConnection1.Commit;
      Except
        on E: EDatabaseError do
          begin
            MessageDlg('Error', 'A database error has occurred. Technical error message: ' +
                E.Message, mtError, [mbOK], 0);
          end;
       end;
      // Indsæt default minimums data
      Try
        SQL.Clear;
        SQL.Add('Select * from afddef');
        Open;
        Append;
        Edit;
        FieldByName('Navn').AsString          := 'Forening 1';
        Post;
        ApplyUpdates;
        // MainDataModule.ZConnection1.Commit;
      Except
        on E: EDatabaseError do
          begin
            MessageDlg('Error', 'A database error has occurred. Technical error message: ' +
                E.Message, mtError, [mbOK], 0);
          end;
      end;
    end;
End;

//**********************************************************
// Kontingent
//**********************************************************
procedure TCheckDatabaseForm.KontingentDefDo;
Begin
  With MainDataModule.ZQuery1 do
    Begin
      Try
        With SQL do
          Begin
            Clear;
            Add('CREATE TABLE kontingent (');
            Add('  Id INTEGER PRIMARY KEY AUTOINCREMENT,');
            Add('  afd INTEGER NOT NULL,');
            Add('  girobilagsnummer BIGINT,');
            Add('  DatoForIndbetalingAfKont REAL,');
            Add('  DatoForUdsendelse REAL,');
            Add('  SenestRettidigIndbetaling REAL,');
            Add('  BeloebOpkraevet FLOAT,');
            Add('  BeloebIndbetalt FLOAT,');
            Add('  MedlemsNr INTEGER,');
            Add('  PeriodeId INTEGER,');
            Add('  AntalRykkere INTEGER,');
            Add('  BaneDefNr INTEGER,');
            Add('  PrisType INTEGER,');
            Add('  Afsluttet INTEGER,');
            Add('  Manuel BIGINT,');
            Add('  AltTekst VARCHAR(40),');
            Add('  Vaerge INTEGER,');
            Add('  BogFoert INTEGER,');
            Add('  BogFoertD REAL');
            Add(')');
          end;
        ExecSQL;
        // MainDataModule.ZConnection1.Commit;
      Except
        on E: EDatabaseError do
          begin
            MessageDlg('Error', 'A database error has occurred. Technical error message: ' +
                E.Message, mtError, [mbOK], 0);
          end;
       end;
    end;
End;

//**********************************************************
// KontingentTekst
//**********************************************************
procedure TCheckDatabaseForm.KontingentTekstDo;
Begin
  With MainDataModule.ZQuery1 do
    Begin
      Try
        With SQL do
          Begin
            Clear;
            Add('CREATE TABLE KontingentTekst (');
            Add('  Id INTEGER PRIMARY KEY AUTOINCREMENT,');
            Add('  afd INTEGER NOT NULL,');
            Add('  overskrift VARCHAR(80),');
            Add('  tekst BLOB ,');
            Add('  DatoOprettet REAL,');
            Add('  DatoSidstAendret REAL,');
            Add('  forklaring BLOB,');
            Add('  AktPrisTekst BLOB,');
            Add('  AfslutningTekst BLOB');
            Add(')');
          end;
        ExecSQL;
        // MainDataModule.ZConnection1.Commit;
      Except
        on E: EDatabaseError do
          begin
            MessageDlg('Error', 'A database error has occurred. Technical error message: ' +
                E.Message, mtError, [mbOK], 0);
          end;
       end;
    end;
End;


//**********************************************************
// RabatDef
//**********************************************************
procedure TCheckDatabaseForm.RabatDefDo;
Begin
  With MainDataModule.ZQuery1 do
    Begin
      Try
        With SQL do
          Begin
            Clear;
            Add('CREATE TABLE rabatdef (');
            Add('  Id INTEGER PRIMARY KEY AUTOINCREMENT,');
            Add('  afd INTEGER NOT NULL,');
            Add('  type INTEGER,');
            Add('  beskrivelse VARCHAR(40),');
            Add('  param1 REAL,');
            Add('  param2 REAL,');
            Add('  param3 REAL,');
            Add('  paramdate1 REAL,');
            Add('  paramdate2 REAL');
            Add(')');
          end;
        ExecSQL;
        // MainDataModule.ZConnection1.Commit;
      Except
        on E: EDatabaseError do
          begin
            MessageDlg('Error', 'A database error has occurred. Technical error message: ' +
                E.Message, mtError, [mbOK], 0);
          end;
       end;
    end;
End;

//**********************************************************
// RabatKategori
//**********************************************************
procedure TCheckDatabaseForm.RabatKategoriDo;
Begin
  With MainDataModule.ZQuery1 do
    Begin
      Try
        With SQL do
          Begin
            Clear;
            Add('CREATE TABLE rabatkategori (');
            Add('  Id INTEGER PRIMARY KEY AUTOINCREMENT,');
            Add('  afd INTEGER NOT NULL,');
            Add('  pristype INTEGER,');
            Add('  nr FLOAT' );
            Add(')');
          end;
        ExecSQL;
        // MainDataModule.ZConnection1.Commit;
      Except
        on E: EDatabaseError do
          begin
            MessageDlg('Error', 'A database error has occurred. Technical error message: ' +
                E.Message, mtError, [mbOK], 0);
          end;
       end;
    end;
End;




end.


