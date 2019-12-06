//***************************************************************************//
//  Holbæk                                                                   //
//  Copyright by Claus Moeller 2013-2019                                     //
//  Importer fra Vig database                                                //
//  Version                                                                  //
//  23.12.14
//  25.11.2019
//***************************************************************************//
unit Import_Vig;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  ActnList, EditBtn, StdCtrls, Grids, ExtCtrls, Buttons, DBGrids,
  db, ZDataset, IniFiles, paradoxds;

type

  { TImportVigForm }

  TImportVigForm = class(TForm)
    VaelgIngen: TAction;
    VaelgAlle: TAction;
    BitBtn1: TBitBtn;
    Slet: TAction;
    CheckEmpty: TCheckBox;
    DBGrid1: TDBGrid;
    Label2: TLabel;
    Paradox1: TParadoxDataset;
    ProgressBar1: TProgressBar;
    Indlaes: TAction;
    DataSource1: TDataSource;
    GemIndstil: TAction;
    ActionList1: TActionList;
    StringGrid1: TStringGrid;
    TabSheet2: TTabSheet;
    VaelgAktivitetAlle: TSpeedButton;
    VaelgIngenAktiviteter: TSpeedButton;
    VigDirectoryEdit: TDirectoryEdit;
    Label1: TLabel;
    Luk: TAction;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ZQuery1: TZQuery;
    ZQuery2: TZQuery;
    ZQuery3: TZQuery;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure GemIndstilExecute(Sender: TObject);
    procedure IndlaesExecute(Sender: TObject);
    procedure LukExecute(Sender: TObject);
    procedure SletExecute(Sender: TObject);
    procedure VaelgAlleExecute(Sender: TObject);
    procedure VaelgIngenExecute(Sender: TObject);
  private
    { private declarations }
    IniFile        : TInifile;
    Procedure IndstilGrid;
    procedure SetupGrid;

    procedure IndlaesAfdDef;
    procedure IndlaesLand;
    procedure IndlaesPostNr;
    procedure IndlaesMedlem;
    procedure IndlaesKontobes;
    procedure IndlaesAktiviteter;
    procedure IndlaesPrisKategori;
    procedure IndlaesAktMed;
    procedure IndlaesPeriode;
    procedure IndlaesMarkDef;
    procedure IndlaesMarks;
    procedure IndlaesOkoMaerke;
    procedure IndlaesMomsKode;
    procedure IndlaesBilag;
    procedure IndlaesKontingent;
  public
    { public declarations }
  end;

var
  ImportVigForm: TImportVigForm;

implementation

{$R *.lfm}

{ TImportVigForm }

Uses HolbaekConst, MainData, CheckDatabase, dateutils;

Const
  ImportCheck            : Integer = 0;
  ImportNavn             : Integer = 1;
  ImportStatus           : Integer = 2;

  RaekAfdDef             : Integer = 1;
  RaekLand               : Integer = 2;
  RaekPostNr             : Integer = 3;
  RaekMedlem             : Integer = 4;
  RaekKontoBes           : Integer = 5;
  RaekAktiviteter        : Integer = 6;
  RaekPrisKategori       : Integer = 7;
  RaekAktMed             : Integer = 8;
  RaekPeriode            : Integer = 9;
  RaekMaerke             : Integer = 10;
  RaekMarks              : Integer = 11;
  RaekOkoMaerke          : Integer = 12;
  RaekMoms               : Integer = 13;
  RaekBilag              : Integer = 14;
  RaekKontingent         : Integer = 15;

//**********************************************************
// Create
//**********************************************************
procedure TImportVigForm.FormCreate(Sender: TObject);
begin
  Position := poDesigned;
  (*Top := 10;
  Left := 30;*)
  // Farver
  ToolBar1.Color             := H_Menu_knapper_Farve;
  // Database
  ZQuery1.Connection         := MainDataModule.ZConnection1;
  ZQuery2.Connection         := MainDataModule.ZConnection1;
  ZQuery3.Connection         := MainDataModule.ZConnection1;
  // Indstil
  IniFile := TIniFile.Create(HolbaekIniFile);
  VigDirectoryEdit.Directory := Inifile.ReadString('VigSti','Sti','c:\');
  Paradox1.TargetEncoding    := 'UTF-8';

  IndstilGrid;
  SetupGrid;
  // Start checkdatase to recreate tables
  CheckDatabaseForm := TCheckDatabaseForm.Create(Self);
end;


//**********************************************************
// Destroy
//**********************************************************
procedure TImportVigForm.FormDestroy(Sender: TObject);
begin
  CheckDatabaseForm.Free;
  IniFile.Free;
end;

//**********************************************************
// Gem indstillinger
//**********************************************************
procedure TImportVigForm.GemIndstilExecute(Sender: TObject);
begin
   IniFile.WriteString('VigSti','Sti',VigDirectoryEdit.Directory);
end;

//**********************************************************
// Indlæs
//**********************************************************
procedure TImportVigForm.IndlaesExecute(Sender: TObject);
Var A : Integer;
begin
  A := 1;
  While A < StringGrid1.RowCount Do
    Begin
      If StringGrid1.Cells[ImportCheck,A] = '1' Then
        Begin // Indlæses
          If A = RaekAfdDef Then IndlaesAfdDef;
          If A = RaekLand Then IndlaesLand;
          If A = RaekPostNr Then IndlaesPostNr;
          If A = RaekMedlem Then IndlaesMedlem;
          If A = RaekKontoBes Then IndlaesKontoBes;
          If A = RaekAktiviteter Then IndlaesAktiviteter;
          If A = RaekPrisKategori Then IndlaesPrisKategori;
          If A = RaekAktMed Then IndlaesAktMed;
          If A = RaekPeriode Then IndlaesPeriode;
          If A = RaekMaerke Then IndlaesMarkDef;
          If A = RaekMarks Then IndlaesMarks;
          If A = RaekOkoMaerke Then IndlaesOkoMaerke;
          If A = RaekMoms Then IndlaesMomsKode;
          If A = RaekBilag Then IndlaesBilag;
          If A = RaekKontingent Then IndlaesKontingent;
          Application.ProcessMessages;
        end;
      Inc(A);
    end;
end;

//**********************************************************
// Setup Grid
//**********************************************************
procedure TImportVigForm.SetupGrid;
Begin
  StringGrid1.RowCount := 16;
  // Insert tables to be imported
  StringGrid1.Cells[ImportCheck,RaekAfdDef]        := '0';
  StringGrid1.Cells[ImportNavn,RaekAfdDef]         := 'AfdDef';
  StringGrid1.Cells[ImportStatus,RaekAfdDef]       := 'Ikke indlæst';

  StringGrid1.Cells[ImportCheck,RaekLand]          := '0';
  StringGrid1.Cells[ImportNavn,RaekLand]           := 'Land';
  StringGrid1.Cells[ImportStatus,RaekLand]         := 'Ikke indlæst';

  StringGrid1.Cells[ImportCheck,RaekPostNr]        := '0';
  StringGrid1.Cells[ImportNavn,RaekPostNr]         := 'Postnr';
  StringGrid1.Cells[ImportStatus,RaekPostNr]       := 'Ikke indlæst';

  StringGrid1.Cells[ImportCheck,RaekMedlem]        := '0';
  StringGrid1.Cells[ImportNavn,RaekMedlem]         := 'Medlem';
  StringGrid1.Cells[ImportStatus,RaekMedlem]       := 'Ikke indlæst';

  StringGrid1.Cells[ImportCheck,RaekKontoBes]      := '0';
  StringGrid1.Cells[ImportNavn,RaekKontoBes]       := 'Kontobes';
  StringGrid1.Cells[ImportStatus,RaekKontoBes]     := 'Ikke indlæst';

  StringGrid1.Cells[ImportCheck,RaekAktiviteter]   := '0';
  StringGrid1.Cells[ImportNavn,RaekAktiviteter]    := 'Aktiviter';
  StringGrid1.Cells[ImportStatus,RaekAktiviteter]  := 'Ikke indlæst';

  StringGrid1.Cells[ImportCheck,RaekPrisKategori]  := '0';
  StringGrid1.Cells[ImportNavn,RaekPrisKategori]   := 'Priskategori';
  StringGrid1.Cells[ImportStatus,RaekPrisKategori] := 'Ikke indlæst';

  StringGrid1.Cells[ImportCheck,RaekAktMed]        := '0';
  StringGrid1.Cells[ImportNavn,RaekAktMed]         := 'AktMed';
  StringGrid1.Cells[ImportStatus,RaekAktMed]       := 'Ikke indlæst';

  StringGrid1.Cells[ImportCheck,RaekPeriode]       := '0';
  StringGrid1.Cells[ImportNavn,RaekPeriode]        := 'Periode';
  StringGrid1.Cells[ImportStatus,RaekPeriode]      := 'Ikke indlæst';

  StringGrid1.Cells[ImportCheck,RaekMaerke]        := '0';
  StringGrid1.Cells[ImportNavn,RaekMaerke]         := 'Mærker';
  StringGrid1.Cells[ImportStatus,RaekMaerke]       := 'Ikke indlæst';

  StringGrid1.Cells[ImportCheck,RaekMarks]         := '0';
  StringGrid1.Cells[ImportNavn,RaekMarks]          := 'Marks';
  StringGrid1.Cells[ImportStatus,RaekMarks]        := 'Ikke indlæst';

  StringGrid1.Cells[ImportCheck,RaekOkoMaerke]     := '0';
  StringGrid1.Cells[ImportNavn,RaekOkoMaerke]      := 'Okomaerke';
  StringGrid1.Cells[ImportStatus,RaekOkoMaerke]    := 'Ikke indlæst';

  StringGrid1.Cells[ImportCheck,RaekMoms]          := '0';
  StringGrid1.Cells[ImportNavn,RaekMoms]           := 'Moms';
  StringGrid1.Cells[ImportStatus,RaekMoms]         := 'Ikke indlæst';

  StringGrid1.Cells[ImportCheck,RaekBilag]         := '0';
  StringGrid1.Cells[ImportNavn,RaekBilag]          := 'Bilag';
  StringGrid1.Cells[ImportStatus,RaekBilag]        := 'Ikke indlæst';

  StringGrid1.Cells[ImportCheck,RaekKontingent]    := '0';
  StringGrid1.Cells[ImportNavn,RaekKontingent]     := 'Kontingent';
  StringGrid1.Cells[ImportStatus,RaekKontingent]   := 'Ikke indlæst';
end;

//**********************************************************
// Indlæs AfdDef
//**********************************************************
procedure TImportVigForm.IndlaesAfdDef;
Var Count : Integer;
Begin
  //Findes tabel
  Try
    Paradox1.Active   := False;
    Paradox1.TableName := VigDirectoryEdit.Directory + '\AfdDef.db';
    Paradox1.Active   := True;
  Except
    MessageDlg('AfdDef database findes ikke', mtInformation, [mbOK],0);
    Exit;
  end;
  ShowMessage('Antal: ' + IntToStr(Paradox1.RecordCount));
  Paradox1.First;
  ProgressBar1.Max := Paradox1.RecordCount;
  ProgressBar1.Min := 0;
  ProgressBar1.Position:=0;
  ZQuery1.Connection.AutoCommit:=False;
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from AfdDef');
    End;
  ZQuery1.Open;
  // Start indlæsning
  Count := 0;
  ZQuery1.First;
  Paradox1.First;
  While Not Paradox1.EOF Do
    Begin
      Try
        If ZQuery1.Eof Then
          Begin
            ZQuery1.Append;
            ZQuery1.Edit;
          end
        Else
          Begin
            ZQuery1.Edit;
          end;
        ZQuery1.FieldbyName('Navn').AsString:= Paradox1.FieldByName('Navn').AsString;
        ZQuery1.FieldbyName('Kortnavn').AsString:= Paradox1.FieldByName('Kort_navn').AsString;
        ZQuery1.FieldbyName('Adr').AsString:= Paradox1.FieldByName('Adr').AsString;
        ZQuery1.FieldbyName('PostNr').AsString:= Paradox1.FieldByName('PostNr').AsString;
        ZQuery1.FieldbyName('Town').AsString:= Paradox1.FieldByName('By').AsString;
        ZQuery1.FieldbyName('FI').AsString:= Paradox1.FieldByName('FI').AsString;
        ZQuery1.FieldbyName('SE').AsString:= Paradox1.FieldByName('SE').AsString;
        ZQuery1.FieldbyName('Telefon').AsString:= Paradox1.FieldByName('Telefon').AsString;
        ZQuery1.FieldbyName('Fax').AsString:= Paradox1.FieldByName('Fax').AsString;
        ZQuery1.FieldbyName('Bankkonto').AsString:= Paradox1.FieldByName('BankKonto').AsString;
        ZQuery1.FieldbyName('Giro').AsString:= Paradox1.FieldByName('Giro').AsString;
        ZQuery1.FieldbyName('Betalingskort').AsString:= Paradox1.FieldByName('Betalingskort').AsString;
        ZQuery1.FieldbyName('Email').AsString:= Paradox1.FieldByName('Email').AsString;
        ZQuery1.FieldbyName('Hjemmeside').AsString:= Paradox1.FieldByName('Hjemmeside').AsString;
        ZQuery1.FieldbyName('K71pbsnr').AsString:= Paradox1.FieldByName('K71pbsNr').AsString;
        ZQuery1.FieldbyName('k71debi').AsString:= Paradox1.FieldByName('k71debi').AsString;
        ZQuery1.FieldbyName('PBSNr').AsString:= Paradox1.FieldByName('PBSNr').AsString;
        ZQuery1.FieldbyName('DatalevNr').AsString:= Paradox1.FieldByName('Datalevnr').AsString;
        ZQuery1.FieldbyName('BankRegNr').AsString:= Paradox1.FieldByName('BankRegNr').AsString;
//        ZQuery1.FieldbyName('Periode').AsString:= Paradox1.FieldByName('Periode').AsString;
        ZQuery1.FieldbyName('SMTPServer').AsString:= Paradox1.FieldByName('smtpServer').AsString;
        ZQuery1.FieldbyName('SMTPPassword').AsString:= Paradox1.FieldByName('SMTPPassword').AsString;
        ZQuery1.FieldbyName('Port').AsString:= Paradox1.FieldByName('Port').AsString;
        ZQuery1.FieldbyName('BrugerId').AsString:= Paradox1.FieldByName('BrugerId').AsString;
//        ZQuery1.FieldbyName('SmtpLogon').AsString:= Paradox1.FieldByName('SmtpLogon').AsString;
        ZQuery1.FieldbyName('Pop3Server').AsString:= Paradox1.FieldByName('Pop3Server').AsString;
        ZQuery1.FieldbyName('AccountName').AsString:= Paradox1.FieldByName('AccountName').AsString;
        ZQuery1.FieldbyName('Password').AsString:= Paradox1.FieldByName('Password').AsString;
        ZQuery1.FieldbyName('landkode').AsInteger := Paradox1.FieldByName('landkode').AsInteger;
        ZQuery1.FieldbyName('landkodeDefault').AsInteger := Paradox1.FieldByName('landkodeDefault').AsInteger;
        ZQuery1.FieldbyName('postnrdefault').AsString:= Paradox1.FieldByName('postnrdefault').AsString;
        ZQuery1.FieldbyName('ftphost').AsString:= Paradox1.FieldByName('ftphost').AsString;
        ZQuery1.FieldbyName('ftppassword').AsString:= Paradox1.FieldByName('ftppassword').AsString;
        ZQuery1.FieldbyName('ftpport').AsString:= Paradox1.FieldByName('ftpport').AsString;
        ZQuery1.FieldbyName('ftpuserid').AsString:= Paradox1.FieldByName('ftpuserid').AsString;
        ZQuery1.FieldbyName('ftpvignavn').AsString:= Paradox1.FieldByName('ftpvignavn').AsString;
        ZQuery1.FieldbyName('ftpbrugertlf').AsString:= Paradox1.FieldByName('ftpbrugertlf').AsString;
        ZQuery1.FieldbyName('ftpbiblopaanet').AsString:= Paradox1.FieldByName('ftpbiblopaanet').AsString;
        // ZQuery1.FieldbyName('ftpcheckbase').AsBoolean := Paradox1.FieldByName('ftpcheckbase').AsString;
        ZQuery1.FieldbyName('proxyhost').AsString:= Paradox1.FieldByName('proxyhost').AsString;
        ZQuery1.FieldbyName('proxypassword').AsString:= Paradox1.FieldByName('proxypassword').AsString;
        ZQuery1.FieldbyName('proxyport').AsString:= Paradox1.FieldByName('proxyport').AsString;
        ZQuery1.FieldbyName('proxytype').AsInteger := Paradox1.FieldByName('proxytype').AsInteger;
        ZQuery1.FieldbyName('proxyusername').AsString:= Paradox1.FieldByName('proxyusername').AsString;
        // Askdataup
        // Snuser - boolean
        // Medtag skabeloner
        ZQuery1.FieldbyName('smtpafsender').AsString:= Paradox1.FieldByName('smtpafsender').AsString;
        // pbsdrift VARCHAR(1),');
        // logning VARCHAR(1),');
        ZQuery1.FieldbyName('smtpafsender').AsString:= Paradox1.FieldByName('smtpafsender').AsString;
        ZQuery1.FieldbyName('mailsystem').AsInteger := Paradox1.FieldByName('mailsystem').AsInteger;
        ZQuery1.FieldbyName('spec1').AsString:= Paradox1.FieldByName('spec1').AsString;
        ZQuery1.FieldbyName('spec2').AsString:= Paradox1.FieldByName('spec2').AsString;
        ZQuery1.FieldbyName('spec3').AsString:= Paradox1.FieldByName('spec3').AsString;
        ZQuery1.FieldbyName('spec4').AsString:= Paradox1.FieldByName('spec4').AsString;
        // mailreadreceipt VARCHAR(1),');
//        ZQuery1.FieldbyName('mailmaxburst').AsInteger := Paradox1.FieldByName('mailmaxburst').AsInteger;
//        ZQuery1.FieldbyName('mailtidimellemburst').AsInteger := Paradox1.FieldByName('mailtidimellemburst').AsInteger;
        //
        ZQuery1.Post;
        Inc(Count);
        ProgressBar1.Position := Count;
        Application.ProcessMessages;
        Paradox1.Next;
        If Not ZQuery1.EOF Then ZQuery1.Next;
      Except
        MessageDlg('Fejl ved indlæsning af medlem!',mtError,[mbOk],0);
        ZQuery1.Cancel;
        Exit;
      end;
    end;
  ZQuery1.Connection.AutoCommit := True;
  StringGrid1.Cells[ImportStatus,RaekAfdDef] := 'Indlæst - ' + IntToStr(Count) + ' afdeling' ;
end;

//**********************************************************
// Indlæs Land
//**********************************************************
procedure TImportVigForm.IndlaesLand;
Var Count : Integer;
Begin
  //Findes tabel
  Try
    Paradox1.Active   := False;
    Paradox1.TableName := VigDirectoryEdit.Directory + '\Land.db';
    Paradox1.Active   := True;
  Except
    MessageDlg('Landkode database findes ikke', mtInformation, [mbOK],0);
    Exit;
  end;
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from Land');
    End;
  ProgressBar1.Max := Paradox1.RecordCount;
  ProgressBar1.Min := 0;
  ProgressBar1.Position:=0;
  ZQuery1.Open;
  // Start indlæsning
  Count := 0;
  ZQuery1.First;
  Paradox1.First;
  While Not Paradox1.EOF Do
    Begin
      Try
        If ZQuery1.Eof Then
          Begin
            ZQuery1.Append;
            ZQuery1.Edit;
          end
        Else
          Begin
            ZQuery1.Edit;
          end;
        ZQuery1.FieldbyName('Land').AsString:= Paradox1.FieldByName('Land').AsString;
        ZQuery1.FieldbyName('LandForKort').AsString:= Paradox1.FieldByName('LandForKort').AsString;
        ZQuery1.FieldbyName('Cifre').AsInteger := Paradox1.FieldByName('Cifre').AsInteger;
        ZQuery1.FieldbyName('KType').AsString:= Paradox1.FieldByName('Type').AsString;
        ZQuery1.Post;
        Inc(Count);
        ProgressBar1.Position := Count;
        Application.ProcessMessages;
        Paradox1.Next;
        If Not ZQuery1.EOF Then ZQuery1.Next;
      Except
        MessageDlg('Fejl ved indlæsning af land!',mtError,[mbOk],0);
        ZQuery1.Cancel;
        Exit;
      end;
    end;
  StringGrid1.Cells[ImportStatus,RaekLand] := 'Indlæst - ' + IntToStr(Count) + ' lande' ;
end;

//**********************************************************
// Indlæs PostNr
//**********************************************************
procedure TImportVigForm.IndlaesPostNr;
Var Count : Integer;
Begin
  //Findes tabel
  Try
    Paradox1.Active   := False;
    Paradox1.TableName:= VigDirectoryEdit.Directory + '\PostNr.db';
    Paradox1.Active   := True;
  Except
    MessageDlg('PostNr database findes ikke', mtInformation, [mbOK],0);
    Exit;
  end;
  ProgressBar1.Max := Paradox1.RecordCount;
  ProgressBar1.Min := 0;
  ProgressBar1.Position:=0;
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from PostNr');
    End;
  ZQuery1.Open;
  // Start indlæsning
  Count := 0;
  ZQuery1.First;
  Paradox1.First;
  While Not Paradox1.EOF Do
    Begin
      Try
        If ZQuery1.Eof Then
          Begin
            ZQuery1.Append;
            ZQuery1.Edit;
          end
        Else
          Begin
            ZQuery1.Edit;
          end;
        ZQuery1.FieldbyName('Landkode').AsInteger := Paradox1.FieldByName('LandKode').AsInteger + 1; // In Vig it started with 0 zero.
        // Changed in Holbæk to have all id to start with 1
        ZQuery1.FieldbyName('PostNr').AsString:= Paradox1.FieldByName('PNr').AsString;
        ZQuery1.FieldbyName('Town').AsString:= Paradox1.FieldByName('By').AsString;
        ZQuery1.Post;
        Inc(Count);
        ProgressBar1.Position := Count;
        Application.ProcessMessages;
        Paradox1.Next;
        If Not ZQuery1.EOF Then ZQuery1.Next;
      Except
        MessageDlg('Fejl ved indlæsning af postnr!',mtError,[mbOk],0);
        ZQuery1.Cancel;
        Exit;
      end;
    end;
  StringGrid1.Cells[ImportStatus,RaekPostNr] := 'Indlæst - ' + IntToStr(Count) + ' postnumre' ;
end;

//**********************************************************
// Indlæs Medlem
//**********************************************************
procedure TImportVigForm.IndlaesMedlem;
Var Count : Integer;
Begin
  //Findes tabel
  Try
    Paradox1.Active   := False;
    Paradox1.TableName := VigDirectoryEdit.Directory + '\medlem.db';
    Paradox1.Active   := True;
  Except
    MessageDlg('Medlems database findes ikke', mtInformation, [mbOK],0);
    Exit;
  end;
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from medlem');
    End;
  ProgressBar1.Max := Paradox1.RecordCount;
  ProgressBar1.Min := 0;
  ProgressBar1.Position:=0;
  ZQuery1.Open;
  If ZQuery1.RecordCount > 0 Then
    Begin
      If MessageDlg('Der er medlemmer i databasen - skal der tilføjes?',mtConfirmation,[mbYes,mbNo],0) <> mrYes Then Exit;
    end;
  // Start indlæsning
  Count := 0;
  Paradox1.First;
  While Not Paradox1.EOF Do
    Begin
      Try
        ZQuery1.Append;
        ZQuery1.Edit;
        ZQuery1.FieldbyName('BrugerMedlemsNr').AsInteger:= Paradox1.FieldByName('BrugerMedNr').AsInteger;
        ZQuery1.FieldbyName('Fornavn').AsString:= Paradox1.FieldByName('Fornavn').AsString;
        ZQuery1.FieldbyName('Efternavn').AsString:= Paradox1.FieldByName('Efternavn').AsString;
        ZQuery1.FieldbyName('Adr1').AsString:= Paradox1.FieldByName('Adr1').AsString;
        ZQuery1.FieldbyName('Adr2').AsString:= Paradox1.FieldByName('Adr2').AsString;
        ZQuery1.FieldbyName('landkode').AsInteger:= Paradox1.FieldByName('LandKode').AsInteger + 1;
        // Landkode: add 1; see more explanation under land
        ZQuery1.FieldbyName('PostNr').AsString:= Paradox1.FieldByName('PostNr').AsString;
        ZQuery1.FieldbyName('City').AsString:= Paradox1.FieldByName('By').AsString;
        ZQuery1.FieldbyName('Telefon').AsString:= Paradox1.FieldByName('Telefon').AsString;
        ZQuery1.FieldbyName('Fax').AsString:= Paradox1.FieldByName('Fax').AsString;
        ZQuery1.FieldbyName('MobilTlfNr').AsString:= Paradox1.FieldByName('MobilTlfNr').AsString;
        ZQuery1.FieldbyName('Foedselsdato').AsFloat := DateTimeToJulianDate(Paradox1.FieldByName('Foedselsdato').AsDateTime);
        ZQuery1.FieldbyName('MedlemSiden').AsFloat := DateTimeToJulianDate(Paradox1.FieldByName('Medlemsiden').AsDateTime);
        ZQuery1.FieldbyName('Mand').AsString:= Paradox1.FieldByName('Mand').AsString;
        ZQuery1.FieldbyName('Spec1').AsString:= Paradox1.FieldByName('Spec1').AsString;
        ZQuery1.FieldbyName('Spec2').AsString:= Paradox1.FieldByName('Spec2').AsString;
        ZQuery1.FieldbyName('Spec3').AsString:= Paradox1.FieldByName('Spec3').AsString;
        ZQuery1.FieldbyName('Spec4').AsString:= Paradox1.FieldByName('Spec4').AsString;
//        ZQuery1.FieldbyName('Beskrivelse').AsVariant := Paradox1.FieldByName('Beskrivelse').AsVariant;
(*        ZQuery1.FieldbyName('Vaerge').AsString :=Paradox1.FieldByName('Vaerge').AsString;
        ZQuery1.FieldbyName('VaergeBetal').AsString :=Paradox1.FieldByName('VaergeBetal').AsString;*)
//        ZQuery1.FieldbyName('BilledType').AsString:= Paradox1.FieldByName('Billedtype').AsString;
//        ZQuery1.FieldbyName('Billede').AsVariant := Paradox1.FieldByName('Billede').AsVariant;
        ZQuery1.FieldbyName('PbsAftaleNr').AsString:= Paradox1.FieldByName('PBSAftaleNr').AsString;
        ZQuery1.FieldbyName('PBSBankReg').AsString:= Paradox1.FieldByName('PBSBankReg').AsString;
        ZQuery1.FieldbyName('PBSKontoNr').AsString:= Paradox1.FieldByName('PBSKontoNr').AsString;
        ZQuery1.FieldbyName('PBSCPR1').AsString:= Paradox1.FieldByName('PBSCPR1').AsString;
        ZQuery1.FieldbyName('PBSCPR2').AsString:= Paradox1.FieldByName('PBSCPR2').AsString;
        ZQuery1.FieldbyName('PBSKundeNr').AsString:= Paradox1.FieldByName('PBSKundeNr').AsString;
        ZQuery1.FieldbyName('PBSGammeltNr').AsString:= Paradox1.FieldByName('PBSGammeltNr').AsString;
        ZQuery1.FieldbyName('PBSAktion').AsString:= Paradox1.FieldByName('PBSAktion').AsString;
        ZQuery1.FieldbyName('PBSSidsteDato').AsDateTime := Paradox1.FieldByName('PBSSidsteDato').AsDateTime;
        ZQuery1.FieldbyName('PBSStatus').AsString:= Paradox1.FieldByName('PBSStatus').AsString;
        ZQuery1.FieldbyName('UdmeldtD').AsFloat := DateTimeToJulianDate(Paradox1.FieldByName('UdmeldtD').AsDateTime);
        ZQuery1.FieldbyName('VigNr').AsString := Paradox1.FieldByName('MedlemsNr').AsString;
        //
        ZQuery1.Post;
        Inc(Count);
        ProgressBar1.Position := Count;
        Application.ProcessMessages;
        Paradox1.Next;
      Except
        MessageDlg('Fejl ved indlæsning af medlem!',mtError,[mbOk],0);
        ZQuery1.Cancel;
        Exit;
      end;
    end;
  StringGrid1.Cells[ImportStatus,RaekMedlem] := 'Indlæst - ' + IntToStr(Count) + ' medlemmer' ;
end;

//**********************************************************
// Indlæs Kontobes
//**********************************************************
procedure TImportVigForm.IndlaesKontobes;
Var Count : Integer;
Begin
  //Findes tabel
  Try
    Paradox1.Active   := False;
    Paradox1.TableName := VigDirectoryEdit.Directory + '\kontobes.db';
    Paradox1.Active   := True;
  Except
    MessageDlg('KontoBes database findes ikke', mtInformation, [mbOK],0);
    Exit;
  end;
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from kontobes');
    End;
  ProgressBar1.Max := Paradox1.RecordCount;
  ProgressBar1.Min := 0;
  ProgressBar1.Position:=0;
  ZQuery1.Open;
  // Start indlæsning
  Count := 0;
  Paradox1.First;
  While Not Paradox1.EOF Do
    Begin
      Try
        If ZQuery1.Eof Then
            Begin
              ZQuery1.Append;
              ZQuery1.Edit;
            end
          Else
            Begin
              ZQuery1.Edit;
            end;
        ZQuery1.FieldbyName('Afd').AsInteger := Paradox1.FieldByName('Afd').AsInteger;
        ZQuery1.FieldbyName('Beskrivelse').AsString := Paradox1.FieldByName('Beskrivelse').AsString;
//        ZQuery1.FieldbyName('Momskode').AsInteger := Paradox1.FieldByName('MomsKode').AsInteger;
        ZQuery1.FieldbyName('BrugerKonto').AsInteger := Paradox1.FieldByName('BrugerKonto').AsInteger;
        ZQuery1.FieldbyName('KGB').AsString:= Paradox1.FieldByName('KGB').AsString;
        ZQuery1.FieldbyName('Type').AsInteger := Paradox1.FieldByName('Type').AsInteger;
        ZQuery1.FieldbyName('Fra').AsInteger := Paradox1.FieldByName('Fra').AsInteger;
        ZQuery1.FieldbyName('Til').AsInteger := Paradox1.FieldByName('Til').AsInteger;
        If Paradox1.FieldByName('SumMed').AsBoolean Then ZQuery1.FieldbyName('SumMed').AsString := '1'
          Else ZQuery1.FieldbyName('SumMed').AsString := '0';
        ZQuery1.FieldbyName('SumType').AsInteger := Paradox1.FieldByName('SumType').AsInteger;
        ZQuery1.FieldbyName('DefaultTekst').AsString:= Paradox1.FieldByName('DefaultTekst').AsString;
        If Paradox1.FieldByName('Spaerret').AsBoolean Then ZQuery1.FieldbyName('Spaerret').AsString := '1'
          Else ZQuery1.FieldbyName('Spaerret').AsString := '0';
        If Paradox1.FieldByName('Direkte').AsBoolean Then ZQuery1.FieldbyName('Direkte').AsString := '1'
          Else ZQuery1.FieldbyName('Direkte').AsString := '0';
        If Paradox1.FieldByName('Afstembar').AsBoolean Then ZQuery1.FieldbyName('Afstembar').AsString := '1'
          Else ZQuery1.FieldbyName('Afstembar').AsString := '0';
        If Paradox1.FieldByName('Default_D').AsBoolean Then ZQuery1.FieldbyName('Default_D').AsString := '1'
          Else ZQuery1.FieldbyName('Default_D').AsString := '0';
        ZQuery1.FieldbyName('RettetD').AsFloat := DateTimeToJulianDate(Paradox1.FieldByName('RettetD').AsDateTime);
        If Paradox1.FieldByName('VisningD-K').AsBoolean Then ZQuery1.FieldbyName('VisningD_K').AsString := '1'
          Else ZQuery1.FieldbyName('VisningD_K').AsString := '0';
//        ZQuery1.FieldbyName('DefaultModKonto').AsInteger := Paradox1.FieldByName('DefaultModKonto').AsInteger;
        ZQuery1.FieldbyName('OkoNr').AsInteger := Paradox1.FieldByName('OkoNr').AsInteger;
        If Paradox1.FieldByName('VisIkkeTekst').AsBoolean Then ZQuery1.FieldbyName('VisIkkeTekst').AsString := '1'
          Else ZQuery1.FieldbyName('VisIkkeTekst').AsString := '0';
        ZQuery1.FieldbyName('VigNr').AsString := Paradox1.FieldByName('KontoNr').AsString;
        //
        ZQuery1.Post;
        Inc(Count);
        ProgressBar1.Position := Count;
        Application.ProcessMessages;
        Paradox1.Next;
        If Not ZQuery1.EOF Then ZQuery1.Next;
      Except
        MessageDlg('Fejl ved indlæsning af medlem!',mtError,[mbOk],0);
        ZQuery1.Cancel;
        Exit;
      end;
    end;
  StringGrid1.Cells[ImportStatus,RaekKontoBes] := 'Indlæst - ' + IntToStr(Count) + ' konti' ;
end;

//**********************************************************
// Indlæs Aktiviteter
//**********************************************************
procedure TImportVigForm.IndlaesAktiviteter;
Var Count : Integer;
Begin
  //Findes tabel
  Try
    Paradox1.Active   := False;
    Paradox1.TableName := VigDirectoryEdit.Directory + '\bane.db';
    Paradox1.Active   := True;
  Except
    MessageDlg('Aktiviteter database findes ikke', mtInformation, [mbOK],0);
    Exit;
  end;
  ProgressBar1.Max := Paradox1.RecordCount;
  ProgressBar1.Min := 0;
  ProgressBar1.Position:=0;
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from Aktiviteter');
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount > 0 Then
    Begin
      If MessageDlg('Der er aktiviteter i databasen - skal der tilføjes?',mtConfirmation,[mbYes,mbNo],0) <> mrYes Then Exit;
    end;
  // Start indlæsning
  Count := 0;
  Paradox1.First;
  While Not Paradox1.EOF Do
    Begin
      Try
        ZQuery1.Append;
        ZQuery1.Edit;
        ZQuery1.FieldbyName('Afd').AsInteger := Paradox1.FieldByName('Afd').AsInteger;
        ZQuery1.FieldbyName('Beskrivelse').AsString := Paradox1.FieldByName('Beskrivelse').AsString;
        If Paradox1.FieldByName('Vis').AsBoolean Then ZQuery1.FieldbyName('Vis').AsString := '1'
          Else ZQuery1.FieldbyName('Vis').AsString := '0';
        ZQuery1.FieldbyName('ExInfo').AsString:= Paradox1.FieldByName('ExInfo').AsString;
        ZQuery1.FieldbyName('Konto').AsInteger := Paradox1.FieldByName('Konto').AsInteger;
        ZQuery1.FieldbyName('ModKonto').AsInteger := Paradox1.FieldByName('ModKonto').AsInteger;
        ZQuery1.FieldbyName('MaxAntal').AsInteger := Paradox1.FieldByName('MaxAntal').AsInteger;
        ZQuery1.FieldbyName('MaxOption').AsInteger := Paradox1.FieldByName('MaxOption').AsInteger;
        ZQuery1.FieldbyName('NaesteFelt').AsInteger := Paradox1.FieldByName('NaesteFelt').AsInteger;
        ZQuery1.FieldbyName('VigNr').AsString := Paradox1.FieldByName('BaneDefNr').AsString;
        ZQuery1.FieldbyName('BaneDefNr').AsString := Paradox1.FieldByName('BaneDefNr').AsString;
        ZQuery1.Post;
        Inc(Count);
        ProgressBar1.Position := Count;
        Application.ProcessMessages;
        Paradox1.Next;
      Except
        MessageDlg('Fejl ved indlæsning af medlem!',mtError,[mbOk],0);
        ZQuery1.Cancel;
        Exit;
      end;
    end;
  StringGrid1.Cells[ImportStatus,RaekAktiviteter] := 'Indlæst - ' + IntToStr(Count) + ' aktiviteter' ;
end;

//**********************************************************
// Indlæs Priskategori
//**********************************************************
procedure TImportVigForm.IndlaesPrisKategori;
Var Count : Integer;
Begin
  //Findes tabel
  Try
    Paradox1.Active   := False;
    Paradox1.TableName := VigDirectoryEdit.Directory + '\Afd.db';
    Paradox1.Active   := True;
  Except
    MessageDlg('Priskategori database findes ikke', mtInformation, [mbOK],0);
    Exit;
  end;
  ProgressBar1.Max := Paradox1.RecordCount;
  ProgressBar1.Min := 0;
  ProgressBar1.Position:=0;
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from Priskategori');
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount > 0 Then
    Begin
      If MessageDlg('Der er priskategori i databasen - skal der tilføjes?',mtConfirmation,[mbYes,mbNo],0) <> mrYes Then Exit;
    end;
  // Start indlæsning
  Count := 0;
  Paradox1.First;
  While Not Paradox1.EOF Do
    Begin
      Try
        ZQuery1.Append;
        ZQuery1.Edit;
        ZQuery1.FieldbyName('Afd').AsInteger := Paradox1.FieldByName('Afd').AsInteger;
        ZQuery1.FieldbyName('Beskrivelse').AsString := Paradox1.FieldByName('Betegnelse').AsString;
        ZQuery1.FieldbyName('Pris').AsFloat := Paradox1.FieldByName('Pris').AsFloat;
        If Paradox1.FieldByName('Vis').AsBoolean Then ZQuery1.FieldbyName('Vis').AsString := '1'
          Else ZQuery1.FieldbyName('Vis').AsString := '0';
        ZQuery1.FieldbyName('Special').AsInteger := Paradox1.FieldByName('Special').AsInteger;
        ZQuery1.FieldbyName('VigNr').AsString := Paradox1.FieldByName('PrisType').AsString;
        ZQuery1.FieldbyName('PrisType').AsString := Paradox1.FieldByName('PrisType').AsString;
        ZQuery1.Post;
        Inc(Count);
        ProgressBar1.Position := Count;
        Application.ProcessMessages;
        Paradox1.Next;
      Except
        MessageDlg('Fejl ved indlæsning af Pristype!',mtError,[mbOk],0);
        ZQuery1.Cancel;
        Exit;
      end;
    end;
  StringGrid1.Cells[ImportStatus,RaekPriskategori] := 'Indlæst - ' + IntToStr(Count) + ' priskategorier' ;
end;

//**********************************************************
// Indlæs AktMed
//**********************************************************
procedure TImportVigForm.IndlaesAktMed;
Var Count : Integer;
Begin
  //Findes tabel
  Try
    Paradox1.Active   := False;
    Paradox1.TableName := VigDirectoryEdit.Directory + '\AktMed.db';
    Paradox1.Active   := True;
  Except
    MessageDlg('AktMed database findes ikke', mtInformation, [mbOK],0);
    Exit;
  end;
//  ZQuery1.SQL;
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from AktMed');
    End;
  ProgressBar1.Max := Paradox1.RecordCount;
  ProgressBar1.Min := 0;
  ProgressBar1.Position:=0;
  ZQuery1.Open;
  If ZQuery1.RecordCount > 0 Then
    Begin
      If MessageDlg('Der er aktmed i databasen - skal der tilføjes?',mtConfirmation,[mbYes,mbNo],0) <> mrYes Then Exit;
    end;
  // Start indlæsning
  Count := 0;
  Paradox1.First;
  While Not Paradox1.EOF Do
    Begin
      Try
        ZQuery1.Append;
        ZQuery1.Edit;
        ZQuery1.FieldbyName('Afd').AsInteger := Paradox1.FieldByName('Afd').AsInteger;
        // ZQuery2 -> PrisType
        With ZQuery2.SQL do
          Begin
            Clear;
            Add('Select * from PrisKategori where (VigNr = ' +
              Paradox1.FieldByName('PrisType').AsString + ') and (Afd = ' +
              ZQuery1.FieldbyName('Afd').AsString + ')');
          end;
        ZQuery2.Open;
        If ZQuery2.RecordCount = 0 Then
          Begin
            MessageDlg('Fejl: Priskategori ikke fundet!',mtError,[mbOk],0);
            ZQuery1.Cancel;
            Exit;
          end;
        ZQuery1.FieldbyName('PrisType').AsInteger := ZQuery2.FieldByName('Id').AsInteger;
        // ZQuery2 -> Medlem
        With ZQuery2.SQL do
          Begin
            Clear;
            Add('Select * from Medlem where (VigNr = ' +
              Paradox1.FieldByName('MedlemsNr').AsString + ')');
          end;
        ZQuery2.Open;
        If ZQuery2.RecordCount = 0 Then
          Begin
            MessageDlg('Fejl: Medlem ikke fundet!',mtError,[mbOk],0);
            ZQuery1.Cancel;
            Exit;
          end;
        ZQuery1.FieldbyName('MedlemsNr').AsInteger := ZQuery2.FieldByName('Medlemsnr').AsInteger;
        // ZQuery2 -> Banedefnr
        With ZQuery2.SQL do
          Begin
            Clear;
            Add('Select * from Aktiviteter where (VigNr = ' +
              Paradox1.FieldByName('BaneDefNr').AsString + ') and (Afd = ' +
              ZQuery1.FieldbyName('Afd').AsString + ')');
          end;
        ZQuery2.Open;
        If ZQuery2.RecordCount = 0 Then
          Begin
            MessageDlg('Fejl: Aktivitet ikke fundet!',mtError,[mbOk],0);
            ZQuery1.Cancel;
            Exit;
          end;
        ZQuery1.FieldbyName('BaneDefNr').AsInteger := ZQuery2.FieldByName('Id').AsInteger;
        ZQuery1.FieldbyName('Dato').AsFloat  := DateTimeToJulianDate(Paradox1.FieldByName('AktDato').AsDateTime);
        ZQuery1.Post;
        Inc(Count);
        ProgressBar1.Position := Count;
        Application.ProcessMessages;
        Paradox1.Next;
      Except
        MessageDlg('Fejl ved indlæsning af aktmed!',mtError,[mbOk],0);
        ZQuery1.Cancel;
        Exit;
      end;
    end;
  StringGrid1.Cells[ImportStatus,RaekAktMed] := 'Indlæst - ' + IntToStr(Count) + ' medlemmer på aktiviteter' ;
end;


//**********************************************************
// Indlæs Periode
//**********************************************************
procedure TImportVigForm.IndlaesPeriode;
Var Count : Integer;
Begin
  //Findes tabel
  Try
    Paradox1.Active   := False;
    Paradox1.TableName := VigDirectoryEdit.Directory + '\PerioDef.db';
    Paradox1.Active   := True;
  Except
    MessageDlg('PeriodeDef database findes ikke', mtInformation, [mbOK],0);
    Exit;
  end;
  ProgressBar1.Max := Paradox1.RecordCount;
  ProgressBar1.Min := 0;
  ProgressBar1.Position:=0;
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from PeriodeDef');
    End;
  ZQuery1.Open;
  // Start indlæsning
  Count := 0;
  Paradox1.First;
  While Not Paradox1.EOF Do
    Begin
      Try
        If ZQuery1.Eof Then
            Begin
              ZQuery1.Append;
              ZQuery1.Edit;
            end
          Else
            Begin
              ZQuery1.Edit;
            end;
        ZQuery1.FieldbyName('Afd').AsInteger := Paradox1.FieldByName('Afd').AsInteger;
        ZQuery1.FieldbyName('Periode').AsString := Paradox1.FieldByName('PeriodeBetegnelse').AsString;
        ZQuery1.FieldbyName('Beskrivelse').AsString := Paradox1.FieldByName('Beskrivelse').AsString;
        ZQuery1.FieldbyName('DatoFra').AsFloat := DateTimeToJulianDate(Paradox1.FieldByName('DatoFra').AsDateTime);
        ZQuery1.FieldbyName('DatoTil').AsFloat := DateTimeToJulianDate(Paradox1.FieldByName('DatoTil').AsDateTime);
        If Paradox1.FieldByName('Afsluttet').AsBoolean Then ZQuery1.FieldbyName('Afsluttet').AsString := '1'
          Else ZQuery1.FieldbyName('Afsluttet').AsString := '0';
//        ZQuery1.FieldbyName('NextPeriod').AsInteger := Paradox1.FieldByName('NextPeriod').AsInteger;
        ZQuery1.FieldbyName('Option').AsInteger := Paradox1.FieldByName('Option').AsInteger;
        ZQuery1.Post;
        Inc(Count);
        ProgressBar1.Position := Count;
        Application.ProcessMessages;
        Paradox1.Next;
        If Not ZQuery1.EOF Then ZQuery1.Next;
      Except
        MessageDlg('Fejl ved indlæsning af periode!',mtError,[mbOk],0);
        ZQuery1.Cancel;
        Exit;
      end;
    end;
  StringGrid1.Cells[ImportStatus,RaekPeriode] := 'Indlæst - ' + IntToStr(Count) + ' perioder' ;
end;


//**********************************************************
// Indlæs Maerke
//**********************************************************
procedure TImportVigForm.IndlaesMarkDef;
Var Count : Integer;
Begin
  //Findes tabel
  Try
    Paradox1.Active   := False;
    Paradox1.TableName := VigDirectoryEdit.Directory + '\MarkDef.db';
    Paradox1.Active   := True;
  Except
    MessageDlg('MarkDef database findes ikke', mtInformation, [mbOK],0);
    Exit;
  end;
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from MarkDef');
    End;
  ProgressBar1.Max := Paradox1.RecordCount;
  ProgressBar1.Min := 0;
  ProgressBar1.Position:=0;
  ZQuery1.Open;
  If ZQuery1.RecordCount > 0 Then
    Begin
      If MessageDlg('Der er mærker i databasen - skal der tilføjes?',mtConfirmation,[mbYes,mbNo],0) <> mrYes Then Exit;
    end;
  // Start indlæsning
  Count := 0;
  Paradox1.First;
  While Not Paradox1.EOF Do
    Begin
      Try
        ZQuery1.Append;
        ZQuery1.Edit;
        ZQuery1.FieldbyName('Beskrivelse').AsString := Paradox1.FieldByName('Beskrivelse').AsString;
        ZQuery1.FieldbyName('VigNr').AsInteger := Paradox1.FieldByName('Auto').AsInteger;
        ZQuery1.Post;
        Inc(Count);
        ProgressBar1.Position := Count;
        Application.ProcessMessages;
        Paradox1.Next;
      Except
        MessageDlg('Fejl ved indlæsning af markdef!',mtError,[mbOk],0);
        ZQuery1.Cancel;
        Exit;
      end;
    end;
  StringGrid1.Cells[ImportStatus,RaekMaerke] := 'Indlæst - ' + IntToStr(Count) + ' mærker definitioner' ;
end;

//**********************************************************
// Indlæs Marks
//**********************************************************
procedure TImportVigForm.IndlaesMarks;
Var Count : Integer;
Begin
  //Findes tabel
  Try
    Paradox1.Active   := False;
    Paradox1.TableName := VigDirectoryEdit.Directory + '\Marks.db';
    Paradox1.Active   := True;
  Except
    MessageDlg('Marks database findes ikke', mtInformation, [mbOK],0);
    Exit;
  end;
  ProgressBar1.Max := Paradox1.RecordCount;
  ProgressBar1.Min := 0;
  ProgressBar1.Position:=0;
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from Marks');
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount > 0 Then
    Begin
      If MessageDlg('Der er mærker i databasen - skal der tilføjes?',mtConfirmation,[mbYes,mbNo],0) <> mrYes Then Exit;
    end;
  // Start indlæsning
  Count := 0;
  Paradox1.First;
  While Not Paradox1.EOF Do
    Begin
      Try
        ZQuery1.Append;
        ZQuery1.Edit;
        // ZQuery2 -> Medlem
        With ZQuery2.SQL do
          Begin
            Clear;
            Add('Select * from Medlem where (VigNr = ' +
              Paradox1.FieldByName('MedlemsNr').AsString + ')');
          end;
        ZQuery2.Open;
        If ZQuery2.RecordCount = 0 Then
          Begin
            MessageDlg('Fejl: Medlem ikke fundet! ' + Paradox1.FieldByName('MedlemsNr').AsString,mtError,[mbOk],0);
            ZQuery1.Cancel;
            Exit;
          end;
        ZQuery1.FieldbyName('MedlemsNr').AsInteger := ZQuery2.FieldByName('Medlemsnr').AsInteger;
        // ZQuery2 -> MarkDef
        With ZQuery2.SQL do
          Begin
            Clear;
            Add('Select * from MarkDef where VigNr = ' +
              Paradox1.FieldByName('Mark').AsString);
          end;
        ZQuery2.Open;
        If ZQuery2.RecordCount = 0 Then
          Begin
            MessageDlg('Fejl: Mærke ikke fundet!',mtError,[mbOk],0);
            ZQuery1.Cancel;
            Exit;
          end;
        ZQuery1.FieldbyName('MarkId').AsInteger := ZQuery2.FieldByName('Id').AsInteger;
        ZQuery1.FieldbyName('Dato').AsFloat  := DateTimeToJulianDate(Paradox1.FieldByName('DatoMarksOprettet').AsDateTime);
        ZQuery1.Post;
        Inc(Count);
        ProgressBar1.Position := Count;
        Application.ProcessMessages;
        Paradox1.Next;
      Except
        MessageDlg('Fejl ved indlæsning af marks!',mtError,[mbOk],0);
        ZQuery1.Cancel;
        Exit;
      end;
    end;
  StringGrid1.Cells[ImportStatus,RaekMarks] := 'Indlæst - ' + IntToStr(Count) + ' mærker tilknytninger' ;
end;

//**********************************************************
// Indlæs okomaerke
//**********************************************************
procedure TImportVigForm.IndlaesOkoMaerke;
Var Count : Integer;
Begin
  //Findes tabel
  Try
    Paradox1.Active   := False;
    Paradox1.TableName := VigDirectoryEdit.Directory + '\OkoMarksDef.db';
    Paradox1.Active   := True;
  Except
    MessageDlg('Økomærke database findes ikke', mtInformation, [mbOK],0);
    Exit;
  end;
  ProgressBar1.Max := Paradox1.RecordCount;
  ProgressBar1.Min := 0;
  ProgressBar1.Position:=0;
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from OkoMaerkeDef');
    End;
  ZQuery1.Open;
  // Start indlæsning
  Count := 0;
  ZQuery1.First;
  Paradox1.First;
  While Not Paradox1.EOF Do
    Begin
      Try
        If ZQuery1.Eof Then
          Begin
            ZQuery1.Append;
            ZQuery1.Edit;
          end
        Else
          Begin
            ZQuery1.Edit;
          end;
        ZQuery1.FieldbyName('Afd').AsString:= Paradox1.FieldByName('Afd').AsString;
        ZQuery1.FieldbyName('Beskrivelse').AsString:= Paradox1.FieldByName('Beskrivelse').AsString;
        ZQuery1.FieldbyName('VigNr').AsInteger := Paradox1.FieldByName('OkoNr').AsInteger;
        ZQuery1.Post;
        Inc(Count);
        ProgressBar1.Position := Count;
        Application.ProcessMessages;
        Paradox1.Next;
        If Not ZQuery1.EOF Then ZQuery1.Next;
      Except
        MessageDlg('Fejl ved indlæsning af økomærke!',mtError,[mbOk],0);
        ZQuery1.Cancel;
        Exit;
      end;
    end;
  StringGrid1.Cells[ImportStatus,RaekOkoMaerke] := 'Indlæst - ' + IntToStr(Count) + ' økomærker' ;
end;

//**********************************************************
// Indlæs MomsKode
//**********************************************************
procedure TImportVigForm.IndlaesMomsKode;
Var Count : Integer;
Begin
  //Findes tabel
  Try
    Paradox1.Active   := False;
    Paradox1.TableName := VigDirectoryEdit.Directory + '\MomsKode.db';
    Paradox1.Active   := True;
  Except
    MessageDlg('Momskode database findes ikke', mtInformation, [mbOK],0);
    Exit;
  end;
  ProgressBar1.Max := Paradox1.RecordCount;
  ProgressBar1.Min := 0;
  ProgressBar1.Position:=0;
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from momskode');
    End;
  ZQuery1.Open;
  // Start indlæsning
  Count := 0;
  ZQuery1.First;
  Paradox1.First;
  While Not Paradox1.EOF Do
    Begin
      Try
        If ZQuery1.Eof Then
          Begin
            ZQuery1.Append;
            ZQuery1.Edit;
          end
        Else
          Begin
            ZQuery1.Edit;
          end;
        ZQuery1.FieldbyName('Afd').AsString:= Paradox1.FieldByName('Afd').AsString;
        ZQuery1.FieldbyName('Navn').AsString:= Paradox1.FieldByName('Navn').AsString;
        ZQuery1.FieldbyName('Procent').AsFloat := Paradox1.FieldByName('Procent').AsFloat;
        If Paradox1.FieldByName('SalgsMoms').AsBoolean Then
          ZQuery1.FieldbyName('SalgsMoms').AsString := '1'
        Else
          ZQuery1.FieldbyName('SalgsMoms').AsString := '0';
        ZQuery1.FieldbyName('Beskrivelse').AsString:= Paradox1.FieldByName('Besk').AsString;
        // ZQuery2 -> MomsKonto
        With ZQuery2.SQL do
          Begin
            Clear;
            Add('Select * from KontoBes where (Afd = ' + ZQuery1.FieldbyName('Afd').AsString +
              ') and (VigNr = ' + Paradox1.FieldByName('MomsKonto').AsString +')');
          end;
        ZQuery2.Open;
        If ZQuery2.RecordCount = 0 Then
          Begin
            MessageDlg('Fejl: Kontonr ikke fundet!',mtError,[mbOk],0);
            ZQuery1.Cancel;
            Exit;
          end;
        ZQuery1.FieldbyName('MomsKonto').AsInteger := ZQuery2.FieldByName('Id').AsInteger;
        ZQuery1.Post;
        Inc(Count);
        ProgressBar1.Position := Count;
        Application.ProcessMessages;
        Paradox1.Next;
        If Not ZQuery1.EOF Then ZQuery1.Next;
      Except
        MessageDlg('Fejl ved indlæsning af momskode!',mtError,[mbOk],0);
        ZQuery1.Cancel;
        Exit;
      end;
    end;
  StringGrid1.Cells[ImportStatus,RaekMoms] := 'Indlæst - ' + IntToStr(Count) + ' momskoder' ;
end;

//**********************************************************
// Indlæs bilag
//**********************************************************
procedure TImportVigForm.IndlaesBilag;
Var Count : Integer;
Begin
  //Findes tabel
  Try
    Paradox1.Active   := False;
    Paradox1.TableName := VigDirectoryEdit.Directory + '\bilag.db';
    Paradox1.Active   := True;
  Except
    MessageDlg('Bilag database findes ikke', mtInformation, [mbOK],0);
    Exit;
  end;
  ProgressBar1.Max := Paradox1.RecordCount;
  ProgressBar1.Min := 0;
  ProgressBar1.Position:=0;
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from bilag');
    End;
  ZQuery1.Open;
  // Start indlæsning
  Count := 0;
  ZQuery1.First;
  Paradox1.First;
  While Not Paradox1.EOF Do
    Begin
      Try
        If ZQuery1.Eof Then
          Begin
            ZQuery1.Append;
            ZQuery1.Edit;
          end
        Else
          Begin
            ZQuery1.Edit;
          end;
        ZQuery1.FieldbyName('Afd').AsString := Paradox1.FieldByName('Afd').AsString;
        // ZQuery2 -> Periode
        With ZQuery2.SQL do
          Begin
            Clear;
            Add('Select * from PeriodeDef where (Afd = ' + ZQuery1.FieldbyName('Afd').AsString +
              ') and (Periode = ' + Paradox1.FieldByName('Periode').AsString +')');
          end;
        ZQuery2.Open;
        If ZQuery2.RecordCount = 0 Then
          Begin
            MessageDlg('Fejl: Periode ikke fundet!',mtError,[mbOk],0);
            ZQuery1.Cancel;
            Exit;
          end;
        ZQuery1.FieldbyName('Periode').AsInteger := ZQuery2.FieldByName('Nr').AsInteger;
        ZQuery1.FieldbyName('BilagsNr').AsInteger := Paradox1.FieldByName('BilagsNr').AsInteger;
        ZQuery1.FieldbyName('Tekst').AsString := Paradox1.FieldByName('Tekst').AsString;
        ZQuery1.FieldbyName('kType').AsString := Paradox1.FieldByName('Type').AsString;
        ZQuery1.FieldbyName('D_K').AsString := Paradox1.FieldByName('D-K').AsString;
        // ZQuery2 -> Konto
        If Paradox1.FieldByName('Konto').AsString = '-1' Then
          Begin
            ZQuery1.FieldbyName('Konto').AsInteger  := -1;
          end
        Else
          Begin
            With ZQuery2.SQL do
              Begin
                Clear;
                Add('Select * from KontoBes Where (VigNr = ' + Paradox1.FieldByName('Konto').AsString + ')');
              end;
            ZQuery2.Open;
            If ZQuery2.RecordCount = 0 Then
              Begin
                MessageDlg('Fejl: Bilag kontoid ikke fundet!',mtError,[mbOk],0);
                ZQuery1.Cancel;
                Exit;
              end;
            ZQuery1.FieldbyName('Konto').AsInteger  := ZQuery2.FieldByName('Id').AsInteger;
          end;
        // ZQuery2 -> Moms
        If Paradox1.FieldByName('Moms').AsString <> '' Then
          Begin
            With ZQuery2.SQL do
              Begin
                Clear;
                Add('Select * from MomsKode where (Afd = ' + ZQuery1.FieldbyName('Afd').AsString +
                  ') and (Navn = ' + QuotedStr(Paradox1.FieldByName('Moms').AsString) +')');
              end;
            ZQuery2.Open;
            If ZQuery2.RecordCount = 0 Then
              Begin
                MessageDlg('Fejl: Bilag momskode ikke fundet!',mtError,[mbOk],0);
                ZQuery1.Cancel;
                Exit;
              end;
            ZQuery1.FieldbyName('Moms').AsInteger  := ZQuery2.FieldByName('Nr').AsInteger;
          end
        Else
          Begin
            ZQuery1.FieldbyName('Moms').Clear;
          end;
        ZQuery1.FieldbyName('Dato').AsFloat := DateTimeToJulianDate(Paradox1.FieldByName('Dato').AsDateTime);
        ZQuery1.FieldbyName('Beloeb').AsFloat := Paradox1.FieldByName('Beloeb').AsFloat;
        ZQuery1.FieldbyName('BogfoertDato').AsFloat := DateTimeToJulianDate(Paradox1.FieldByName('BogfoertDato').AsDateTime);
        // ZQuery2 -> OkoNr
        If Paradox1.FieldByName('OkoNr').AsString <> '' Then
          Begin
            With ZQuery2.SQL do
              Begin
                Clear;
                Add('Select * from OkomaerkeDef  where (Afd = ' + ZQuery1.FieldbyName('Afd').AsString +
                  ') and (VigNr = ' + Paradox1.FieldByName('OkoNr').AsString +')');
              end;
            ZQuery2.Open;
            If ZQuery2.RecordCount = 0 Then
              Begin
                MessageDlg('Fejl: Økomærke ikke fundet!',mtError,[mbOk],0);
                ZQuery1.Cancel;
                Exit;
              end;
            ZQuery1.FieldbyName('OkoNr').AsInteger  := ZQuery2.FieldByName('Nr').AsInteger;
          end
        Else
          Begin  // Null
            ZQuery1.FieldbyName('OkoNr').Clear;
          end;
        ZQuery1.Post;
        Inc(Count);
        ProgressBar1.Position := Count;
        Application.ProcessMessages;
        Paradox1.Next;
        If Not ZQuery1.EOF Then ZQuery1.Next;
      Except
          MessageDlg('Fejl ved indlæsning af bilag!',mtError,[mbOk],0);
          ZQuery1.Cancel;
          Exit;
      end;
    end;
  StringGrid1.Cells[ImportStatus,RaekBilag] := 'Indlæst - ' + IntToStr(Count) + ' bilag' ;
end;

//**********************************************************
// Indlæs kontingent
//**********************************************************
procedure TImportVigForm.IndlaesKontingent;
Var Count : Integer;
Begin
  //Findes tabel
  Try
    Paradox1.Active   := False;
    Paradox1.TableName := VigDirectoryEdit.Directory + '\kontigen.db';
    Paradox1.Active   := True;
  Except
    MessageDlg('Kontingent database findes ikke', mtInformation, [mbOK],0);
    Exit;
  end;
  ProgressBar1.Max := Paradox1.RecordCount;
  ProgressBar1.Min := 0;
  ProgressBar1.Position:=0;
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from kontingent');
    End;
  ZQuery1.Open;
  // Start indlæsning
  Count := 0;
  ZQuery1.First;
  Paradox1.First;
  While Not Paradox1.EOF Do
    Begin
      Try
        If ZQuery1.Eof Then
          Begin
            ZQuery1.Append;
            ZQuery1.Edit;
          end
        Else
          Begin
            ZQuery1.Edit;
          end;
        ZQuery1.FieldbyName('Afd').AsString := Paradox1.FieldByName('Afd').AsString;
        ZQuery1.FieldbyName('girobilagsnummer').AsString := Paradox1.FieldByName('girobilagsnummer').AsString;
        ZQuery1.FieldbyName('DatoForIndbetalingAfKont').AsFloat := DateTimeToJulianDate(Paradox1.FieldByName('DatoForIndbetalingAfKont').AsDateTime);
        ZQuery1.FieldbyName('DatoForUdsendelse').AsFloat := DateTimeToJulianDate(Paradox1.FieldByName('DatoForUdsendelse').AsDateTime);
        ZQuery1.FieldbyName('SenestRettidigIndbetaling').AsFloat := DateTimeToJulianDate(Paradox1.FieldByName('SenestRettidigIndbetaling').AsDateTime);
        ZQuery1.FieldbyName('BeloebOpkraevet').AsFloat := Paradox1.FieldByName('BeloebOpkraevet').AsFloat;
        ZQuery1.FieldbyName('BeloebIndbetalt').AsFloat := Paradox1.FieldByName('BeloebIndbetalt').AsFloat;
        // ZQuery2 -> Medlemsnr
        With ZQuery2.SQL do
          Begin
            Clear;
            Add('Select * from Medlem Where (VigNr = ' + Paradox1.FieldByName('MedlemsNr').AsString + ')');
          end;
        ZQuery2.Open;
        If ZQuery2.RecordCount = 0 Then
          Begin
            MessageDlg('Fejl: Medlem ikke fundet!',mtError,[mbOk],0);
            ZQuery1.Cancel;
            Exit;
          end;
        ZQuery1.FieldbyName('MedlemsNr').AsInteger  := ZQuery2.FieldByName('MedlemsNr').AsInteger;
        // ZQuery2 -> Periode
        With ZQuery2.SQL do
          Begin
            Clear;
            Add('Select * from PeriodeDef where (Afd = ' + ZQuery1.FieldbyName('Afd').AsString +
              ') and (Periode = ' + Paradox1.FieldByName('Periode').AsString +')');
          end;
        ZQuery2.Open;
        If ZQuery2.RecordCount = 0 Then
          Begin
            MessageDlg('Fejl: Periode ikke fundet!',mtError,[mbOk],0);
            ZQuery1.Cancel;
            Exit;
          end;
        ZQuery1.FieldbyName('PeriodeId').AsInteger := ZQuery2.FieldByName('Nr').AsInteger;
        ZQuery1.FieldbyName('AntalRykkere').AsInteger := Paradox1.FieldByName('AntalRykkere').AsInteger;
        // ZQuery2 -> Banedefnr
        If Paradox1.FieldByName('BaneDefNr').AsString <> '' Then
          Begin
            If Paradox1.FieldByName('BaneDefNr').AsString = '0' Then
              Begin // Paradox giver 0 hvis felt er Null
                ZQuery1.FieldByName('BaneDefNr').Clear;
              end
            Else
              Begin
                With ZQuery2.SQL do
                  Begin
                    Clear;
                    Add('Select * from Aktiviteter where (VigNr = ' +
                      Paradox1.FieldByName('BaneDefNr').AsString + ') and (Afd = ' +
                      ZQuery1.FieldbyName('Afd').AsString + ')');
                  end;
                ZQuery2.Open;
                If ZQuery2.RecordCount = 0 Then
                  Begin
                    MessageDlg('Fejl: Aktivitet ' + Paradox1.FieldByName('BaneDefNr').AsString + ' ikke fundet!',mtError,[mbOk],0);
                    ZQuery1.Cancel;
                    Exit;
                  end;
                ZQuery1.FieldbyName('BaneDefNr').AsInteger := ZQuery2.FieldByName('Id').AsInteger;
              end;
            End
          Else
            Begin
              ZQuery1.FieldbyName('BaneDefNr').Clear;
            end;
        // ZQuery2 -> PrisType
        If Paradox1.FieldByName('PrisType').AsString <> '' Then
          Begin
            If (Paradox1.FieldByName('PrisType').AsInteger = -1) Then
              Begin // Manuel
                ZQuery1.FieldbyName('PrisType').AsInteger := -1;
              end
            Else If (Paradox1.FieldByName('PrisType').AsString = '0') Then
              Begin // Fejl i paradox læser tom bliver til 0
                ZQuery1.FieldbyName('PrisType').Clear;
              end
            Else
              Begin
                With ZQuery2.SQL do
                  Begin
                    Clear;
                    Add('Select * from PrisKategori where (VigNr = ' +
                      Paradox1.FieldByName('PrisType').AsString + ') and (Afd = ' +
                      ZQuery1.FieldbyName('Afd').AsString + ')');
                  end;
                ZQuery2.Open;
                If ZQuery2.RecordCount = 0 Then
                  Begin
                    MessageDlg('Fejl: Priskategori ' + Paradox1.FieldByName('PrisType').AsString + ' ikke fundet!' + #10+#13
                      + 'Gironummer: ' + ZQuery1.FieldbyName('girobilagsnummer').AsString,mtError,[mbOk],0);
                    ZQuery1.Cancel;
                    Exit;
                  end;
                ZQuery1.FieldbyName('PrisType').AsInteger := ZQuery2.FieldByName('Id').AsInteger;
              end;
          End
        Else
          Begin
            ZQuery1.FieldbyName('PrisType').Clear;
          end;
        ZQuery1.FieldbyName('Afsluttet').AsInteger := Paradox1.FieldByName('Afsluttet').AsInteger;
        ZQuery1.FieldbyName('Manuel').AsFloat := Paradox1.FieldByName('Manuel').AsFloat;
        ZQuery1.FieldbyName('AltTekst').AsString := Paradox1.FieldByName('AltTekst').AsString;
        ZQuery1.FieldbyName('Vaerge').AsFloat := Paradox1.FieldByName('Vaerge').AsFloat;
        If Paradox1.FieldByName('Bogfoert').AsBoolean Then ZQuery1.FieldbyName('Bogfoert').AsString := '1'
        Else ZQuery1.FieldbyName('Bogfoert').AsString := '0';
        ZQuery1.FieldbyName('BogFoertD').AsFloat := DateTimeToJulianDate(Paradox1.FieldByName('BogFoertD').AsDateTime);

        ZQuery1.Post;
        Inc(Count);
        ProgressBar1.Position := Count;
        Application.ProcessMessages;
        Paradox1.Next;
        If Not ZQuery1.EOF Then ZQuery1.Next;
      Except
          MessageDlg('Fejl ved indlæsning af kontingent!',mtError,[mbOk],0);
          ZQuery1.Cancel;
          Exit;
      end;
    end;
  StringGrid1.Cells[ImportStatus,RaekKontingent] := 'Indlæst - ' + IntToStr(Count) + ' kontingenter' ;
end;

//**********************************************************
// Indstil Grid
//**********************************************************
Procedure TImportVigForm.IndstilGrid;
Begin
  Indstil_StringGrid_Edit(StringGrid1);
  StringGrid1.Columns.Clear;

  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;

  StringGrid1.Columns[ImportCheck].Title.Caption       := '*';
  StringGrid1.Columns[ImportCheck].Width               := 30;
  StringGrid1.Columns[ImportCheck].Alignment           := taCenter;
  StringGrid1.Columns[ImportCheck].ButtonStyle         := cbsCheckboxColumn;

  StringGrid1.Columns[ImportNavn].Title.Caption          := 'Tabel';
  StringGrid1.Columns[ImportNavn].Width                  := 80;
  StringGrid1.Columns[ImportNavn].Alignment              := taLeftJustify;
  StringGrid1.Columns[ImportNavn].ReadOnly               := True;

  StringGrid1.Columns[ImportStatus].Title.Caption        := 'Status';
  StringGrid1.Columns[ImportStatus].Width                := 200;
  StringGrid1.Columns[ImportStatus].Alignment            := taLeftJustify;
  StringGrid1.Columns[ImportStatus].ReadOnly             := True;

(*  StringGrid1.Options  := [goTabs,goEditing,goRowSelect,goFixedVertline,
     goFixedHorzLine];*)
end;


//**********************************************************
// Luk
//**********************************************************
procedure TImportVigForm.LukExecute(Sender: TObject);
begin
  Close;
end;

//**********************************************************
// Slet
//**********************************************************
procedure TImportVigForm.SletExecute(Sender: TObject);
begin
  If MessageDlg('Sletter du databasen kan det ikke gøres om! Fortsæt?',mtConfirmation,[mbYes,mbNo],0) = mrYes Then
    Begin
      MainDataModule.ZConnection1.Disconnect;
      // Slet database
      If FileExists(DatabaseFile) Then
        Begin
          If SysUtils.DeleteFile(DatabaseFile) Then
            Begin
              ShowMessage('Slettet - der oprettes en ny');
              MainDataModule.ZConnection1.Connect;
              CheckDatabaseForm := TCheckDatabaseForm.Create(Self);
              CheckDatabaseForm.Show;
              CheckDatabaseForm.Check;
              CheckDatabaseForm.Free;
            end;
        end;
    end;
end;

//**********************************************************
// Vælg alle
//**********************************************************
procedure TImportVigForm.VaelgAlleExecute(Sender: TObject);
Var A : Integer;
begin
  A := 1;
  While A < StringGrid1.RowCount Do
    Begin
      StringGrid1.Cells[ImportCheck,A] := '1';
      Inc(A);
    end;
end;

//**********************************************************
// Vælg ingen
//**********************************************************
procedure TImportVigForm.VaelgIngenExecute(Sender: TObject);
Var A : Integer;
begin
  A := 1;
  While A < StringGrid1.RowCount Do
    Begin
      StringGrid1.Cells[ImportCheck,A] := '0';
      Inc(A);
    end;
end;


end.

