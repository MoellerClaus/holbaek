//***************************************************************************//
//  Holbæk                                                                   //
//  Copyright by Claus Moeller 2013-2016                                     //
//  Main form                                                                //
//  Version                                                                  //
//  Genoptaget 11.2019
//  08.12.16 - Sidste gang                                                   //
//***************************************************************************//
unit holbaekmain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, ActnList,
  ComCtrls, ZConnection, lazutf8;

type

  { TMainForm }

  TMainForm = class(TForm)
    About: TAction;
    ActionList1: TActionList;
    Aktivitet_Massetildeling: TAction;
    Aktivitet_Start: TAction;
    Backup: TMenuItem;
    Database: TAction;
    Definitioner: TMenuItem;
    Diverse: TMenuItem;
    Forening_Skift: TAction;
    Help: TAction;
    KassekladdeDef_Start: TAction;
    Kassekladde_Start: TAction;
    Kontigent_Manual_Gen: TAction;
    Kontingent_Aktivitet_Gen: TAction;
    Kontingent_edit_Tekst: TAction;
    Kontingent_SeAendre: TAction;
    Kontoplan_Start: TAction;
    Luk: TAction;
    MaerkeDef_Start: TAction;
    MainMenu1: TMainMenu;
    MedlemFind: TAction;
    MedlemOplys: TAction;
    MenuForening: TMenuItem;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem15: TMenuItem;
    MenuItem16: TMenuItem;
    MenuItem17: TMenuItem;
    MenuItem18: TMenuItem;
    MenuItem19: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem20: TMenuItem;
    MenuItem21: TMenuItem;
    MenuItem22: TMenuItem;
    MenuItem23: TMenuItem;
    MenuItem24: TMenuItem;
    MenuItem25: TMenuItem;
    MenuItem26: TMenuItem;
    MenuItem27: TMenuItem;
    MenuItem28: TMenuItem;
    MenuItem29: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem30: TMenuItem;
    MenuItem31: TMenuItem;
    MenuItem32: TMenuItem;
    MenuItem33: TMenuItem;
    MenuItem34: TMenuItem;
    MenuItem35: TMenuItem;
    MenuItem36: TMenuItem;
    MenuItem37: TMenuItem;
    MenuItem38: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    MomsDef_Start: TAction;
    OkoMaerke_Start: TAction;
    Option: TAction;
    PeriodeDef_Start: TAction;
    PostNrRediger: TAction;
    Priskategori_Start: TAction;
    RabatDef_Start: TAction;
    Rapport_Designer: TAction;
    SeKontoAction: TAction;
    StatusBar1: TStatusBar;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    Udskriv_Send: TAction;
    VigImport: TAction;
    procedure Aktivitet_MassetildelingExecute(Sender: TObject);
    procedure Aktivitet_StartExecute(Sender: TObject);
    procedure BackupClick(Sender: TObject);
    procedure DatabaseExecute(Sender: TObject);
    procedure Forening_SkiftExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure KassekladdeDef_StartExecute(Sender: TObject);
    procedure Kassekladde_StartExecute(Sender: TObject);
    procedure Kontigent_Manual_GenExecute(Sender: TObject);
    procedure Kontingent_Aktivitet_GenExecute(Sender: TObject);
    procedure Kontingent_edit_TekstExecute(Sender: TObject);
    procedure Kontoplan_StartExecute(Sender: TObject);
    procedure LukExecute(Sender: TObject);
    procedure Kontingent_SeAendreExecute(Sender: TObject);
    procedure MaerkeDef_StartExecute(Sender: TObject);
    procedure MedlemFindExecute(Sender: TObject);
    procedure MedlemOplysExecute(Sender: TObject);
    procedure MomsDef_StartExecute(Sender: TObject);
    procedure OkoMaerke_StartExecute(Sender: TObject);
    procedure OptionExecute(Sender: TObject);
    procedure PeriodeDef_StartExecute(Sender: TObject);
    procedure PostNrRedigerExecute(Sender: TObject);
    procedure Priskategori_StartExecute(Sender: TObject);
    procedure RabatDef_StartExecute(Sender: TObject);
    procedure SeKontoActionExecute(Sender: TObject);
    procedure Udskriv_SendExecute(Sender: TObject);
    procedure VigImportExecute(Sender: TObject);

  private
    procedure CheckIni;
    Procedure CheckandConnectDatabase;
    procedure clmExceptionHandler(Sender: TObject; E: Exception);
    procedure DisplayHint(Sender : TObject);

  public
    // function  MyAppName : AnsiString;
    DataHentetFraNettet : String;

  end;


var
  MainForm: TMainForm;

implementation

{$R *.lfm}

  Uses
  FKonti,             // Se og ændre kontingent
  holbaekconst,       // Konstanter til definitioner
  maindata,           // Database access
  CheckDatabase,      // Undersøg databse
  Import_Vig,         // Importerer evt. data fra Vig - paradox
  Database_see,       // Se database
  Medoply,            // Medlemsoplysninger
  SkiftForening,      // Forenings opltsninger bl.a.
  FindMed,            // Find medlemmer
  Aktivitet_Masse,    // Se og ændre medlemmer på aktiviteter
  Kassekladde,        // Kassekladden
  SeKonto,            // Se kontoopgørelse
  KonManuel,          // Manuel generer indbetalingskort
  KonAktGen,          // Aktivitet generer indbetalingskort
  KontEditTekst,      // Rediger tekst til indbetalingskort
  Option,             // Option
  PostNr,             // Postnumre
  KontoOversigt,      // Kontonumre
  PeriodeDef,         // Perioder oprettes slettes
  MomsDef,            // Moms koder
  RabatDef,           // Rabat
  OkoMaerke,          // Økomærker
  KassekladdeDef,     // Kassekladder defineres
  Def_Aktiviteter,    // Aktiviteter defineres
  Def_PrisKategori,   // Priskategori
  Def_Maerker,        // Mærke definition
  Backup,             // Evt. backup
  FletFil;            // Kontigent - Udskriv eller send


//**********************************************************
// Luk
//**********************************************************
procedure TMainForm.LukExecute(Sender: TObject);
begin
  Close;
end;

//**********************************************************
// Exception handler
//**********************************************************
procedure TMainForm.clmExceptionHandler(Sender: TObject; E: Exception);
Begin
  MessageDlg(E.Message,mtInformation,[mbOk],0);
end;

//**********************************************************
// Form Show Hint
//**********************************************************
procedure TMainForm.DisplayHint(Sender : TObject);
Begin
  StatusBar1.Panels[1].Text := Application.Hint;
end;

//**********************************************************
// Check and connect database
//**********************************************************
Procedure TMainForm.CheckandConnectDatabase;
Var    HelpStr  : String;
Begin
//  clmMessageDlg('Hallo claus',mtInformation,[mbOk],'');
  // Check directories
  // Lav evt sti til database
  DatabaseFile := Options_Alias_Data + DatabaseFilename + '.sqlite';
  If not DirectoryExists(Options_Alias_Data) Then
    Begin
      ShowMessage('Wups det eksisterer ikke: ' + Options_Alias_Data );
      ForceDirectories(LazUTF8.UTF8ToSys(Options_Alias_Data));
    End;
  {$ifdef Windows}
    SQLLitePath := ExtractFilePath(Application.ExeName);
    // Test database Sqlite - the sqlite3.dll and sqlite3.def to be in ApplicationDatapath
    HelpStr :=  SQLLitePath + 'sqlite3.dll';
    if Not FileExists(HelpStr) then
      Begin
        MessageDlg('sqlite3.dll skal være i ' + SQLLitePath + ' biblioteket', TMsgDlgType.mtWarning, [TMsgDlgBtn.mbYes,TMsgDlgBtn.mbNo], 0);
        Exit;
      End;
    HelpStr :=  SQLLitePath + 'sqlite3.def';
    if Not FileExists(HelpStr) then
      Begin
        MessageDlg('sqlite3.def skal være i ' + SQLLitePath + ' biblioteket', TMsgDlgType.mtWarning, [TMsgDlgBtn.mbYes,TMsgDlgBtn.mbNo], 0);
        Exit;
      End;
    // Connect to database
    MainDataModule:= TMainDataModule.Create(Self);
    MainDataModule.ZConnection1.Database:=DatabaseFile;
    MainDataModule.ZConnection1.Connect;
  {$endif}
  // Prepare
  CheckDatabaseForm := TCheckDatabaseForm.Create(Self);
  CheckDatabaseForm.Show;
  CheckDatabaseForm.Check;
  CheckDatabaseForm.Free;
end;

//**********************************************************
// Check Ini
//**********************************************************
procedure TMainForm.CheckIni;
Var  ProgramNavn  : String;
Begin
  // Dan ini fil
  ProgramNavn := ExtractFileName(Application.Exename);
  Delete(ProgramNavn,
    Pos('.',ProgramNavn),
    Length(ProgramNavn)-3);
  HolbaekIniFile := Options_Alias_Data + ProgramNavn + '.ini';
  // Undersøg om Vig biblioteket er oprettet
  If Not SysUtils.ForceDirectories(Utf8ToSys(Options_Alias_Data)) Then
    Begin // opret biblioteket lykkes ikke
      MessageDlg('Holbæk biblioteket kunne ikke oprettes - afbryd!',mtError,[mbOk],0);
      Exit;
    End
  Else
    Begin // Lav net bibliotek
      If Not SysUtils.ForceDirectories(Utf8ToSys(Options_Alias_Net1)) Then
        Begin // opret biblioteket lykkes ikke
          MessageDlg('Holbæk biblioteket til internet access kunne ikke oprettes - afbryd!',mtError,[mbOk],0);
          Exit;
        End ;
    end;
End;

//**********************************************************
// Create
//**********************************************************
procedure TMainForm.FormCreate(Sender: TObject);
begin
  // Farver
  ToolBar1.Color := H_Menu_knapper_Farve;

  Application.OnException := @clmExceptionHandler;
  // OnGetApplicationName    := @MyAppname;
  Application.OnHint      := @DisplayHint;
  // Basis indstillinger
  Options_Alias_Data := GetAppConfigDir(True); // Global for alle users on the PC
  Options_Alias_Net1 := Options_Alias_Data + 'Net';
  CheckIni;
  // Indlæs
  StatusBar1.Panels[0].Text := DateToStr(Now);
   // Check and connect to database
   CheckandConnectDatabase;
end;

//**********************************************************
// Destroy
//**********************************************************
procedure TMainForm.FormDestroy(Sender: TObject);
begin
//  Tabeller.Free;
  MainDataModule.Free;

end;

//**********************************************************
// Diverse - KassekladdeDef
//**********************************************************
procedure TMainForm.KassekladdeDef_StartExecute(Sender: TObject);
begin
  KassekladdeDefForm := TKassekladdeDefForm.Create(Self);
  KassekladdeDefForm.ShowModal;
  KassekladdeDefForm.Free;
end;

//**********************************************************
// Kassekladde start
//**********************************************************
procedure TMainForm.Kassekladde_StartExecute(Sender: TObject);
begin
  KasseKladdeForm := TKasseKladdeForm.Create(Self);
  KasseKladdeForm.ShowModal;
  KasseKladdeForm.Free;
end;

//**********************************************************
// Kontingent: Manuel generer indbetalingskort
//**********************************************************
procedure TMainForm.Kontigent_Manual_GenExecute(Sender: TObject);
begin
  KontingentManuelForm := TKontingentManuelForm.Create(Self);
  KontingentManuelForm.ShowModal;
  KontingentManuelForm.Free;
end;

//**********************************************************
// Kontingent: Aktivitet generer indbetalingskort
//**********************************************************
procedure TMainForm.Kontingent_Aktivitet_GenExecute(Sender: TObject);
begin
  KonAktGenForm := TKonAktGenForm.Create(Self);
  KonAktGenForm.ShowModal;
  KonAktGenForm.Free;
end;

//**********************************************************
// Kontigent: Ret tekst til indbetalingskort
//**********************************************************
procedure TMainForm.Kontingent_edit_TekstExecute(Sender: TObject);
begin
  KontEditPBSTekstForm := TKontEditPBSTekstForm.Create(Self);
  KontEditPBSTekstForm.ShowModal;
  KontEditPBSTekstForm.Free;
end;

//**********************************************************
// Kontoplan
//**********************************************************
procedure TMainForm.Kontoplan_StartExecute(Sender: TObject);
begin
  KontiForm := TKontiForm.Create(Self);
  kontiForm.ShowModal;
  KontiForm.Free;
end;

//**********************************************************
// Database
//**********************************************************
procedure TMainForm.DatabaseExecute(Sender: TObject);
begin
  DatabaseSeeForm := TDatabaseSeeForm.Create(Self);
  DatabaseSeeForm.ShowModal;
  DatabaseSeeForm.Close;
end;

//**********************************************************
// Aktivitet
//**********************************************************
procedure TMainForm.Aktivitet_MassetildelingExecute(Sender: TObject);
begin
  AktivitetMasseForm := TAktivitetMasseForm.Create(Self);
  AktivitetMasseForm.IndlaesAlle;
  AktivitetMasseForm.ShowModal;
  AktivitetMasseForm.Free;
end;

//**********************************************************
// Diverse aktivitet
//**********************************************************
procedure TMainForm.Aktivitet_StartExecute(Sender: TObject);
begin
  DefAktiviteterForm := TDefAktiviteterForm.Create(Self);
  DefAktiviteterForm.ShowModal;
  DefAktiviteterForm.Free;
end;

//**********************************************************
// Backup
//**********************************************************
procedure TMainForm.BackupClick(Sender: TObject);
begin
  BackupForm := TBackupForm.Create(Self);
  BackupForm.ShowModal;
  BackupForm.Free;
end;

//**********************************************************
// Forening
//**********************************************************
procedure TMainForm.Forening_SkiftExecute(Sender: TObject);
begin
  SkiftForeningForm := TSkiftForeningForm.Create(Self);
  SkiftForeningForm.ShowModal;
  SkiftForeningForm.Free;
end;

//**********************************************************
// Kontigent: Se og ændre indbetalingskort
//**********************************************************
procedure TMainForm.Kontingent_SeAendreExecute(Sender: TObject);
begin
  FormKontigentSeAendre := TFormKontigentSeAendre.Create(Self);
  FormKontigentSeAendre.ShowModal;
  FormKontigentSeAendre.Free;
end;

//**********************************************************
// Mærke definition
//**********************************************************
procedure TMainForm.MaerkeDef_StartExecute(Sender: TObject);
begin
  DefMaerkeForm := TDefMaerkeForm.Create(Self);
  DefMaerkeForm.ShowModal;
  DefMaerkeForm.Free;
end;

//**********************************************************
// Medlem Find
//**********************************************************
procedure TMainForm.MedlemFindExecute(Sender: TObject);
begin
  FormFindMedlemmer := TFormFindMedlemmer.Create(Self);
  FormFindMedlemmer.ShowModal;
  FormFindMedlemmer.Free;
end;


//**********************************************************
// Medlem
//**********************************************************
procedure TMainForm.MedlemOplysExecute(Sender: TObject);
begin
  MedlemForm := TMedlemForm.Create(Self);
  MedlemForm.ShowModal;
  MedlemForm.Free;
end;

//**********************************************************
// Diverse - Momsdef
//**********************************************************
procedure TMainForm.MomsDef_StartExecute(Sender: TObject);
begin
  MomsDefForm := TMomsDefForm.Create(Self);
  MomsDefForm.ShowModal;
  MomsDefForm.Free;
end;


//**********************************************************
// Diverse - Øko mærke
//**********************************************************
procedure TMainForm.OkoMaerke_StartExecute(Sender: TObject);
begin
  OkoMaerkeForm := TOkoMaerkeForm.Create(Self);
  OkoMaerkeForm.ShowModal;
  OkoMaerkeForm.Free;
end;

//**********************************************************
// Option
//**********************************************************
procedure TMainForm.OptionExecute(Sender: TObject);
begin
  OptionForm := TOptionForm.Create(Self);
  OptionForm.ShowModal;
  OptionForm.Free;
end;

//**********************************************************
// Diverse - Periode
//**********************************************************
procedure TMainForm.PeriodeDef_StartExecute(Sender: TObject);
begin
  PeriodeDefForm := TPeriodeDefForm.Create(Self);
  PeriodeDefForm.ShowModal;
  PeriodeDefForm.Free;
end;

//**********************************************************
// PostNr
//**********************************************************
procedure TMainForm.PostNrRedigerExecute(Sender: TObject);
begin
  PostNrForm := TPostNrForm.Create(Self);
  PostNrForm.ShowModal;
  PostNrForm.Free;
end;

//**********************************************************
// Pris
//**********************************************************
procedure TMainForm.Priskategori_StartExecute(Sender: TObject);
begin
  DefPrisKategoriForm := TDefPrisKategoriForm.Create(Self);
  DefPrisKategoriForm.ShowModal;
  DefPrisKategoriForm.Free;
end;

//**********************************************************
// Rabat
//**********************************************************
procedure TMainForm.RabatDef_StartExecute(Sender: TObject);
begin
  RabatDefForm := TRabatDefForm.Create(Self);
  RabatDefForm.ShowModal;
  RabatDefForm.Free;
end;

//**********************************************************
// Økonomi - Se kontoopgørelse
//**********************************************************
procedure TMainForm.SeKontoActionExecute(Sender: TObject);
begin
  SeKontoForm := TSeKontoForm.Create(Self);
  SeKontoForm.ShowModal;
  SeKontoForm.Free;
end;


//**********************************************************
// Kontigent - Udskriv eller send
//**********************************************************
procedure TMainForm.Udskriv_SendExecute(Sender: TObject);
begin
  FormFletFil := TFormFletFil.Create(Self);
  FormFletFil.ShowModal;
  FormFletFil.Close;
end;

//**********************************************************
// Hjælp - Import fra Vig
//**********************************************************
procedure TMainForm.VigImportExecute(Sender: TObject);
begin
  ImportVigForm := TImportVigForm.Create(Self);
  ImportVigForm.ShowModal;
  ImportVigForm.Close;
end;

end.

