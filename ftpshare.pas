//***************************************************************************//
//  Holbæk                                                                   //
//  Copyright by Claus Moeller 2013-2017                                     //
//  FTP share                                                                //
//  Version                                                                  //
//  15.01.2017                                                               //
//***************************************************************************//
unit ftpshare;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, EditBtn, ComCtrls, StdCtrls, Menus, AbZipper, AbUnzper,
  ZDataset, IdFTP, IdComponent, IniFiles;

Const BrugerInfoFil : String = 'info.ini';
      DataFil       : String = 'holbaek.ZIP';
      LogFil        : String = 'log.txt';
type

  { TFTPShareForm }

  TFTPShareForm = class(TForm)
    AbUnZipper1: TAbUnZipper;
    AbZipper1: TAbZipper;
    IdFTP1: TIdFTP;
    ListBox1: TListBox;
    ListBoxServer: TListBox;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    ProgressBar1: TProgressBar;
    StatusBar1: TStatusBar;
    Timer1: TTimer;
    ZQuery1: TZQuery;
    procedure BackupClick(Sender: TObject);
    procedure DiagnoseButtonClick(Sender: TObject);
    procedure FjernSpaerringBTNClick(Sender: TObject);
    procedure FoersteGangClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure HentOgSpaerClick(Sender: TObject);
    procedure IdFTP1Disconnected(Sender: TObject);
    procedure IdFTP1Status(ASender: TObject; const AStatus: TIdStatus;
      const AStatusText: string);
    procedure IdFTP1Work(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCount: Int64);
    procedure IdFTP1WorkBegin(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCountMax: Int64);
    procedure IdFTP1WorkEnd(ASender: TObject; AWorkMode: TWorkMode);
    procedure LaegDataPaaNetOgHaevSpaerringBTNClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { private declarations }
    TransferringData   : Boolean;
    IniFile            : TInifile;
    AbortTransfer      : Boolean;
    BytesToTransfer    : LongWord;
    STime              : TDateTime;
    procedure ChangeDir(DirName: String);
    procedure PakBackupFraNetUd(Sender: TObject);
  public
    { public declarations }
    procedure Diagnose(Sender: TObject);
    procedure FjernSpaerring(Sender: TObject);
    procedure LaegDataOpFoersteGang(Sender: TObject);
    procedure Tagbackup(Sender: TObject);
    procedure GaaPaaNetLaegSpaerringOgHentData(Sender: TObject);
    procedure LaegDataPaaNetOgHaevSpaerring(Sender: TObject);
  end;

var
  FTPShareForm : TFTPShareForm;

implementation

{$R *.lfm}

Uses HolbaekMain, HolbaekConst, MainData, IdFTPCommon, AbUtils, AbArcTyp, clmMessage;

const SE_CreateError = 1;
      SE_CopyError   = 2;

      LogDato    : Integer = 0;
      LogKending : Integer = 1;
      LogTlf     : Integer = 2;
      LogType    : Integer = 3;

      // Log typer i log på net
      // 0 : Gå på net, læg spærring og hent data
      // 1 : Læg data på net og fjern spærring
      // 2 : Snuser (hent data ned)
      // 3 : Fjern spærring
      // 4 : Data op første gang

Var
  AverageSpeed: Double = 0;

//**********************************************************
// Create
//**********************************************************
procedure TFtpShareForm.FormCreate(Sender: TObject);
begin
  Top  := 40;
  Left := 10;
  // Init
  StatusBar1.Panels.Add;
  // Databaser
  Try
    ZQuery1.Connection             := MainData.MainDataModule.ZConnection1;
  Except
    MessageDlg('Databasen er ikke tilgængelig - se manual',mtError,[mbOK],0);
    Exit;
  End;
  ZQuery1.Close;
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from AfdDef where Afd = ' + CurrentAfd);
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount = 0 Then
    Begin
      MessageDlg('Afdeling ikke findet!',mtInformation,[mbOk],0);
      Exit;
    end;
  // Style
end;

//**********************************************************
// Hent data og spær
//**********************************************************
procedure TFTPShareForm.HentOgSpaerClick(Sender: TObject);
begin
  GaaPaaNetLaegSpaerringOgHentData(Sender);
end;


//**********************************************************
// FTP Work
//**********************************************************
procedure TFTPShareForm.IdFTP1Work(ASender: TObject; AWorkMode: TWorkMode;
  AWorkCount: Int64);
Var
  S: String;
  TotalTime: TDateTime;
  H, M, Sec, MS: Word;
  DLTime: Double;
begin
  TotalTime :=  Now - STime;
  DecodeTime(TotalTime, H, M, Sec, MS);
  Sec := Sec + M * 60 + H * 3600;
  DLTime := Sec + MS / 1000;
  if DLTime > 0 then
  AverageSpeed := {(AverageSpeed + }(AWorkCount / 1024) / DLTime{) / 2};

  S := FormatFloat('0.00 KB/s', AverageSpeed);
  Case AWorkMode of
    wmRead   : StatusBar1.Panels[0].Text := 'Download overførselshastighed ' + S;
    wmWrite  : StatusBar1.Panels[0].Text := 'Upload overførselshastighed ' + S;
  End; // End case

  if AbortTransfer then IdFTP1.Abort;

  ProgressBar1.Position := AWorkCount;
  Application.ProcessMessages;
  AbortTransfer := false;
end;

//**********************************************************
// FTP Work begin
//**********************************************************
procedure TFTPShareForm.IdFTP1WorkBegin(ASender: TObject; AWorkMode: TWorkMode;
  AWorkCountMax: Int64);
begin
  TransferringData := true;
//  AbortButton.Visible := true;
  AbortTransfer := false;
  STime := Now;
  If AWorkCountMax > 0 then
    Begin
      ProgressBar1.Max := AWorkCountMax
    End
  Else
    Begin
      ProgressBar1.Max := BytesToTransfer;
    End;
  AverageSpeed := 0;
end;

//**********************************************************
// FTP Work end
//**********************************************************
procedure TFTPShareForm.IdFTP1WorkEnd(ASender: TObject; AWorkMode: TWorkMode);
begin
  StatusBar1.Panels[0].Text := 'Transfer complete.';
  BytesToTransfer := 0;
  TransferringData := false;
  ProgressBar1.Position := 0;
  AverageSpeed := 0;
end;

//**********************************************************
// Læg data op og fjern spærring
//**********************************************************
procedure TFTPShareForm.LaegDataPaaNetOgHaevSpaerringBTNClick(Sender: TObject);
begin
  LaegDataPaaNetOgHaevSpaerring(Sender);
end;

//**********************************************************
// On timer
//**********************************************************
procedure TFTPShareForm.Timer1Timer(Sender: TObject);
begin
  Close;
end;

//**********************************************************
// Diagnose public
//**********************************************************
procedure TFTPShareForm.Diagnose(Sender: TObject);
Begin
  DiagnoseButtonClick(Sender);
end;

//**********************************************************
// Diagnose
//**********************************************************
procedure TFTPShareForm.DiagnoseButtonClick(Sender: TObject);
Begin
  Panel2.Caption := 'Forbindelsen til internettet afprøves ...';
  Panel2.Repaint;
  // Fjern ini efter brug
  if IdFTP1.Connected then
  try
    if TransferringData then IdFTP1.Abort;
    IdFTP1.Quit;
  finally
  end
else
  with IdFTP1 do
    Begin
      try
        ZQuery1.Open;
        UserName := ZQuery1.FieldByName('FTPUserId').AsString;
        Password := ZQuery1.FieldByName('FTPPassword').AsString;
        Host     := ZQuery1.FieldByName('FTPHost').AsString;
        Port     := ZQuery1.FieldByName('FTPPort').AsInteger;
        If ZQuery1.FieldByName('ProxyHost').AsString <> '' Then
          Begin
            ProxySettings.Host      := ZQuery1.FieldByName('ProxyHost').AsString;
            ProxySettings.Password  := ZQuery1.FieldByName('ProxyPassword').AsString;
            ProxySettings.Port      := ZQuery1.FieldByName('ProxyPort').AsInteger;
            ProxySettings.UserName  := ZQuery1.FieldByName('ProxyUsername').AsString;
            ProxySettings.ProxyType := TIdFtpProxyType(ZQuery1.FieldByName('ProxyHost').AsInteger);
          End;
        Connect;
        Panel2.Caption := 'Forbindelsen virker ...';
        Panel2.Repaint;
        Try
          ChangeDir(ZQuery1.FieldByName('FTPBibloPaaNet').AsString);
        Except
          Try
            Panel2.Caption := 'Biblioteket på serveren skal først oprettes ...';
            Panel2.Repaint;
            MakeDir(ZQuery1.FieldByName('FTPBibloPaaNet').AsString);
            Panel2.Caption := 'Biblioteket er oprettet...';
            Panel2.Repaint;
          Except
            Panel2.Caption := 'Biblioteket ikke kunne oprettes - check evt. om / er sat rigtigt...';
            Panel2.Repaint;
            MessageDlg('Biblioteket på serveren ikke kunne oprettes - check evt. om / er sat rigtigt...',
              mtInformation,[mbOK],0);
          End;
        End;
        Panel2.Caption := 'Forbindelsen virker og biblioteket er fundet...';
        Panel2.Repaint;
      Except
        Panel2.Caption := 'Forbindelsen virker ikke. Prøv at kontrollere indstillingerne';
        Panel2.Repaint;
      End;
    End;
  IdFTP1.Quit;
//  Timer1.Enabled := True;

end;

//**********************************************************
// BTN fjern spærring
//**********************************************************
procedure TFTPShareForm.FjernSpaerringBTNClick(Sender: TObject);
begin
  FjernSpaerring(Sender);
end;

//**********************************************************
// BTN første gang
//**********************************************************
procedure TFTPShareForm.FoersteGangClick(Sender: TObject);
begin
  LaegDataOpFoersteGang(Sender);
end;


//**********************************************************
// BTN backup
//**********************************************************
procedure TFTPShareForm.BackupClick(Sender: TObject);
begin
  TagBackup(Sender);
end;

//**********************************************************
// Fjern spaerring
//**********************************************************
procedure TFtpShareForm.FjernSpaerring(Sender: TObject);
begin
  Panel2.Caption := 'Vi logger nu ud og fjerner spærring på internettet så andre kan komme til ...';
  Panel2.Repaint;
  // Fjern ini efter brug
  if IdFTP1.Connected then
    try
      if TransferringData then IdFTP1.Abort;
      IdFTP1.Quit;
    finally
      // DirectoryListBox.Items.Clear;
    end
  else
    with IdFTP1 do
      Begin
        try
          UserName := ZQuery1.FieldByName('FTPUserId').AsString;
          Password := ZQuery1.FieldByName('FTPPassword').AsString;
          Host     := ZQuery1.FieldByName('FTPHost').AsString;
          Port     := ZQuery1.FieldByName('FTPPort').AsInteger;
          If ZQuery1.FieldByName('ProxyHost').AsString <> '' Then
            Begin
              ProxySettings.Host      := ZQuery1.FieldByName('ProxyHost').AsString;
              ProxySettings.Password  := ZQuery1.FieldByName('ProxyPassword').AsString;
              ProxySettings.Port      := ZQuery1.FieldByName('ProxyPort').AsInteger;
              ProxySettings.UserName  := ZQuery1.FieldByName('ProxyUsername').AsString;
              ProxySettings.ProxyType := TIdFtpProxyType(ZQuery1.FieldByName('ProxyType').AsInteger);
            End;
          Connect;
          Panel2.Caption := 'Der er logget på server ...';
          Panel2.Repaint;
          Self.ChangeDir(ZQuery1.FieldByName('FTPBibloPaaNet').AsString);
          // slet ini fil
          Try
            IdFTP1.Delete(BrugerInfoFil);
          Except
          End;
          //HentLog('3');
          //GemLog('3');
          Panel2.Caption := 'Spærring fjernet ...';
          Panel2.Repaint;
        Except
          MessageDlg('Spærring kunne ikke fjernes!',mtInformation,[mbOk],0);
        End;
      End;
  IdFTP1.Quit;
end;

//**********************************************************
// Change dir på server
//**********************************************************
procedure TFtpShareForm.ChangeDir(DirName: String);
begin
  try
    IdFTP1.ChangeDir(DirName);
    IdFTP1.TransferType := ftAscii;
    ListBoxServer.Items.Clear;
    IdFTP1.List(ListBoxServer.Items,'*.*',false);
  Except
    clmMessageDlg('Kan ikke skifte bibliotek på internettet - findes det?',mtError,[mbOk],'0');
  end;
end;

//**********************************************************
// FTP disconnedted
//**********************************************************
procedure TFtpShareForm.IdFTP1Disconnected(Sender: TObject);
begin
  StatusBar1.Panels[0].Text := 'Disconnected.';
end;

//**********************************************************
// FTP status
//**********************************************************
procedure TFtpShareForm.IdFTP1Status(ASender: TObject;
  const AStatus: TIdStatus; const AStatusText: String);
begin
//  DebugListBox.ItemIndex := DebugListBox.Items.Add(aStatusText);
  StatusBar1.Panels[0].Text := aStatusText;
  Application.ProcessMessages;
end;

//**********************************************************
// Læg data på nettet første gang
//**********************************************************
procedure TFtpShareForm.LaegDataOpFoersteGang(Sender: TObject);
// Denne procedure kaldes for at lægge op første gang
Var HelpStr : String;
    Stop    : Boolean;
    A       : Integer;
Begin
  // Gør backup klar
  Panel2.Caption := 'Data bibliotek på PC skal checkes først...';
  Panel2.Repaint;
  ListBox1.Items.Add('Data bibliotek på PC skal checkes først...');
  If Not ForceDirectories(Options_Alias_Net1) Then
    Begin
      MessageDlg('Bibliotek på harddisk kunne ikke oprettes',mtInformation,[mbOK],0);
      Exit;
    End;
  Panel2.Caption := 'Data pakkes ned inden afsendelse...';
  Panel2.Repaint;
  ListBox1.Items.Add('Data pakkes ned inden afsendelse...');
  TagBackup(Sender);
  // Check om der er forbindelse
  Panel2.Caption := 'Der logges på internettet...';
  Panel2.Repaint;
  ListBox1.Items.Add('Der logges på internettet...');
  if IdFTP1.Connected then
    try
      if TransferringData then IdFTP1.Abort;
      IdFTP1.Quit;
    finally
      ListBox1.Items.Clear;
    end
  else
    with IdFTP1 do
      try
        ZQuery1.Open;
        UserName := ZQuery1.FieldByName('FTPUserId').AsString;
        Port     := ZQuery1.FieldByName('FTPPort').AsInteger;
        Password := ZQuery1.FieldByName('FTPPassword').AsString;
        Host     := ZQuery1.FieldByName('FTPHost').AsString;
        If ZQuery1.FieldByName('ProxyHost').AsString <> '' Then
          Begin
            ProxySettings.Host      := ZQuery1.FieldByName('ProxyHost').AsString;
            ProxySettings.Password  := ZQuery1.FieldByName('ProxyPassword').AsString;
            ProxySettings.Port      := ZQuery1.FieldByName('ProxyPort').AsInteger;
            ProxySettings.UserName  := ZQuery1.FieldByName('ProxyUsername').AsString;
            ProxySettings.ProxyType := TIdFtpProxyType(ZQuery1.FieldByName('ProxyType').AsInteger);
          End;
        Connect;
        Panel2.Caption := 'Der er logget korrekt ind...';
        Panel2.Repaint;
        ListBox1.Items.Add('Der er logget korrekt ind...');
        ChangeDir(ZQuery1.FieldByName('FTPBibloPaaNet').AsString);
        Panel2.Caption := 'Der er skiftet til biblioteket...';
        Panel2.Repaint;
        ListBox1.Items.Add('Der er skiftet til biblioteket...');
      Except
      end;
  // Så er vi på
  // Slet gammel datafil - check først om den er der
  Stop := False;
  A := 0;
  While (A < IdFTP1.DirectoryListing.Count) and not Stop do
    Begin
      HelpStr := IdFTP1.DirectoryListing.Items[A].FileName;
      lowercase(HelpStr);
      Stop := (HelpStr = DataFil);
      inc(A);
    End;
  If Stop Then
    Begin  // Den findes slet den
      IdFTP1.Delete(DataFil);
      Panel2.Caption := 'Fjerner data på nettet ...';
      Panel2.Repaint;
      ListBox1.Items.Add('Fjerner data på nettet ...');
      //Self.ChangeDir(ZQuery1.FieldByName('FTPBibloPaaNet').AsString);
    End
  Else
    Begin // Gør ikke noget
    End;
  // Datafil lægges op
  try
    Panel2.Caption := 'Data lægges op på internettet ...';
    Panel2.Repaint;
    IdFTP1.TransferType := ftAscii;
    IdFTP1.Put(Options_Alias_Net1 + DirectorySeparator + DataFil, DataFil);
    Panel2.Caption := 'Data er lagt op på internettet ...';
    ListBox1.Items.Add('Data er lagt op på internettet ...');
    Panel2.Repaint;
  finally
  end;
  // Fjern spærring
  Try
    IdFTP1.Delete(BrugerInfoFil);
  Except
  End;
  Panel2.Caption := 'Alt OK data er lagt op ...luk og start igen';
  Panel2.Repaint;
  ListBox1.Items.Add('Alt OK data er lagt op ...luk og start igen');
End;


//**********************************************************
// Tag backup
//**********************************************************
procedure TFtpShareForm.Tagbackup(Sender: TObject);
begin
  try
    // Close database before the ZIP
    MainData.MainDataModule.ZConnection1.Disconnect;
    AbZipper1.ArchiveType := atZip;
    AbZipper1.ForceType := True;
    AbZipper1.BaseDirectory := Options_Alias_Data;
    AbZipper1.FileName := Options_Alias_Net1 + DirectorySeparator + DataFil;
    AbZipper1.StoreOptions := [soStripDrive,soRemoveDots,soRecurse];
    AbZipper1.AddFiles('*.*',faReadOnly or faHidden or faSysFile or faVolumeID or faArchive); // every file except dir
    AbZipper1.Save;
  Except
    clmMessageDlg('Fejl ved zip',mtError,[mbOk],'0');
  end;
  MainData.MainDataModule.ZConnection1.Connect;
end;

//**********************************************************
// Pak backup fra net ud
//**********************************************************
procedure TFtpShareForm.PakBackupFraNetUd(Sender: TObject);
Begin
  try
    // Close database before the ZIP
    MainData.MainDataModule.ZConnection1.Disconnect;
    AbUnZipper1.ArchiveType := atZip;
    AbUnZipper1.ForceType := True;
    AbUnZipper1.BaseDirectory := Options_Alias_Data;
    AbUnZipper1.FileName := Options_Alias_Net1 + DirectorySeparator + DataFil;
    AbUnZipper1.ExtractFiles('*.*')
  Except
    clmMessageDlg('Fejl ved zip',mtError,[mbOk],'0');
  end;
  MainData.MainDataModule.ZConnection1.Connect;
End;


//**********************************************************
// Gå på net og hent data
//**********************************************************
procedure TFtpShareForm.GaaPaaNetLaegSpaerringOgHentData(Sender: TObject);
// Denne procedure kaldes for at gå internettet og hente data ned og pak ud
Var A           : Integer;
    HelpStr     : String;
    AndenBruger : String;
    AndenTlf    : String;
    Stop        : Boolean;
Begin
  If ForceDirectories(Options_Alias_Net1) Then
    Begin //
      Try
        // Slet evt. info.ini
        DeleteFile(Options_Alias_Net1 + DirectorySeparator + BrugerInfoFil);
      Except
      End;
      Try
        // Slet evt data fil i ZIP
        DeleteFile(Options_Alias_Net1 + DataFil);
      Except
      End;
    End
  Else
    Begin
      clmMessageDlg('Bibliotek på harddisk kunne ikke oprettes',mtInformation,[mbOK],'0');
      Exit;
    End;
  Panel2.Caption := 'Dine foreningsdata fra internettet hentes nu ned og pakkes ud...<BR>Det kan tage et par minutter...';
  Panel2.Repaint;
  ListBox1.Items.Add('Dine foreningsdata fra internettet hentes nu ned og pakkes ud...<BR>Det kan tage et par minutter...');

  // Check om der er forbindelse
  if IdFTP1.Connected then
    try
      if TransferringData then IdFTP1.Abort;
      IdFTP1.Quit;
    finally
      ListBox1.Items.Clear;
    end
  else
    with IdFTP1 do
      try
        ZQuery1.Open;
        UserName := ZQuery1.FieldByName('FTPUserId').AsString;
        Port     := ZQuery1.FieldByName('FTPPort').AsInteger;
        Password := ZQuery1.FieldByName('FTPPassword').AsString;
        Host     := ZQuery1.FieldByName('FTPHost').AsString;
        If ZQuery1.FieldByName('ProxyHost').AsString <> '' Then
          Begin
            ProxySettings.Host      := ZQuery1.FieldByName('ProxyHost').AsString;
            ProxySettings.Password  := ZQuery1.FieldByName('ProxyPassword').AsString;
            ProxySettings.Port      := ZQuery1.FieldByName('ProxyPort').AsInteger;
            ProxySettings.UserName  := ZQuery1.FieldByName('ProxyUsername').AsString;
            ProxySettings.ProxyType := TIdFtpProxyType(ZQuery1.FieldByName('ProxyHost').AsInteger);
          End;
      IdFTP1.Connect;
        //Self.ChangeDir(ZQuery1.FieldByName('FTPBibloPaaNet').AsString);
      finally
      end;
  // PÅ server i det rigtige bibliotek.
  Try
    Self.ChangeDir(ZQuery1.FieldByName('FTPBibloPaaNet').AsString);
  Except
  End;
  Try
    IdFTP1.TransferType := ftAscii;
    IdFTP1.List(ListboxServer.Items,'*.*',True);
  Except
  End;
  // Se om ini fil ligger der og hent den evt. ned for at aflæse bruger
  Stop := False;
  A := 0;
  While (A < IdFTP1.DirectoryListing.Count) and not Stop do
    Begin
      HelpStr := IdFTP1.DirectoryListing.Items[A].FileName;
      Lowercase(HelpStr);
      Stop := (HelpStr = BrugerInfoFil);
      Inc(A);
    End;
  If Stop Then
    Begin  // Anden bruger
      // Hent ini fil for at finde brugeren
      try
        IdFTP1.TransferType := ftAscii;
        IdFTP1.Get(BrugerInfoFil,Options_Alias_Net1 + DirectorySeparator + BrugerInfoFil,True,False);
      finally
      end;
      // Hvis ja så vis hvem der bruger data nu og afbryd
      IniFile := TIniFile.Create(Options_Alias_Net1 + DirectorySeparator + BrugerInfoFil);
      AndenBruger := IniFile.ReadString('Brugernavn','Navn','Ukendt');
      AndenTlf    := IniFile.ReadString('Brugernavn','Tlf','?');
      IniFile.Free;
      //Panel2.Text := '< size="8" face="Arial">' + AndenBruger + ' har adgang til data på internettet. <BR>Prøv igen senere eller ring på tlf. <FONT color="#FF0000" >'+ AndenTlf + '</Font><BR>Fortsætter du vil evt. indtastninger blive <I><B>overskrevet</B></I> når du logger på næste gang.</FONT>';
      MainForm.DataHentetFraNettet := ''; // Data skal ved nedlukning ikke lægges på internet
      clmMessageDlg(AndenBruger + ' har adgang til data på Internettet.' +#13+#10+
         'Prøv igen senere eller ring til vedkommende på ' + AndenTlf + '.' + #10+#13+
         'Laver du ændringer på data vil de blive overskrevet næste gang du logger på.',mtInformation,[mbOK],'0');
      IdFTP1.Quit;
      MainForm.DataHentetFraNettet := ''; // Nulstil
      Exit;
    End
  Else
    Begin  // Læg ini fil op.
      // Først skal den laves
      Panel2.Caption := 'Du har nu adgang til data<BR>Nu spærrres adgang for andre til du er færdig';
      Panel2.Repaint;
      IniFile := TIniFile.Create(Options_Alias_Net1 + DirectorySeparator + BrugerInfoFil);
      IniFile.WriteString('Brugernavn','Navn',ZQuery1.FieldByName('FtpVigNavn').AsString);
      IniFile.WriteString('Brugernavn','Tlf',ZQuery1.FieldByName('FtpBrugerTlf').AsString);
      IniFile.Free;
      // læg filen på nettet
      try
        IdFTP1.TransferType := ftAscii;
        IdFTP1.Put(Options_Alias_Net1 + DirectorySeparator + BrugerInfoFil,
          BrugerInfoFil);
      except
        clmMessageDlg('Spærring kunne ikke lægges op!',mtError,[mbOK],'0');
        Exit;
      end;
      // hent data ned
      Panel2.Caption := 'Nu hentes data ...';
      Panel2.Repaint;
      // Slet evt. tidligere data fil i ZIP format
      Try
        // Slet evt. datafil
        DeleteFile(Options_Alias_Net1 + DirectorySeparator + DataFil);
      Except
      End;
      // hent data fil
      try
        IdFTP1.TransferType := ftBinary;
        IdFTP1.Get(DataFil,Options_Alias_Net1 + DirectorySeparator + DataFil);
      Except
        clmMessageDlg('Data (zip-fil) kunne ikke hentes ned!',mtError,[mbOK],'0');
      end;
      Panel2.Caption := 'Data er hentet ned nu - nu skal det pakkes ud ...';
      Panel2.Repaint;
      PakBackupFraNetUd(Sender);
      Panel2.Caption := 'Data er pakket ud ...';
      Panel2.Repaint;
      MainForm.DataHentetFraNettet := CurrentAfd; // Så ved Vig at de skal lægges op efter brug
    End;
  IdFTP1.Quit;
//  Timer1.Enabled := True;
end;


//**********************************************************
// Læg data på net og hæv spærring
//**********************************************************
procedure TFtpShareForm.LaegDataPaaNetOgHaevSpaerring(Sender: TObject);
// Denne procedure kaldes før der lukkes ned. Data lægges op og spærring fjernes
Var HelpStr : String;
    Stop    : Boolean;
    A       : Integer;
begin
  Panel2.Caption := 'Først tages data og pakkes ned ...';
  Panel2.Repaint;
  // Gør backup klar
  TagBackup(Sender);
  // Check om der er forbindelse
  Panel2.Caption := 'Der logges nu internettet ...';
  Panel2.Repaint;
  if IdFTP1.Connected then
    try
      if TransferringData then IdFTP1.Abort;
      IdFTP1.Quit;
    finally
      ListBoxServer.Items.Clear;
    end
  else
    with IdFTP1 do
      try
        ZQuery1.Open;
        UserName := ZQuery1.FieldByName('FTPUserId').AsString;
        Port     := ZQuery1.FieldByName('FTPPort').AsInteger;
        Password := ZQuery1.FieldByName('FTPPassword').AsString;
        Host     := ZQuery1.FieldByName('FTPHost').AsString;
        If ZQuery1.FieldByName('ProxyHost').AsString <> '' Then
          Begin
            ProxySettings.Host      := ZQuery1.FieldByName('ProxyHost').AsString;
            ProxySettings.Password  := ZQuery1.FieldByName('ProxyPassword').AsString;
            ProxySettings.Port      := ZQuery1.FieldByName('ProxyPort').AsInteger;
            ProxySettings.UserName  := ZQuery1.FieldByName('ProxyUsername').AsString;
            ProxySettings.ProxyType := TIdFtpProxyType(ZQuery1.FieldByName('ProxyHost').AsInteger);
          End;
        Connect;
        Panel2.Caption := 'Der skiftes til data bilbiotek på internettet ...';
        Panel2.Repaint;
        Self.ChangeDir(ZQuery1.FieldByName('FTPBibloPaaNet').AsString);
      finally
      end;
  // Så er vi på
  // Slet gammel datafil - check først om den er der
  Stop := False;
  A := 0;
  While (A < IdFTP1.DirectoryListing.Count) and not Stop do
    Begin
      HelpStr := IdFTP1.DirectoryListing.Items[A].FileName;
      lowercase(HelpStr);
      Stop := (HelpStr = DataFil);
      inc(A);
    End;
  If Stop Then
    Begin  // Den findes slet den
      IdFTP1.Delete(DataFil);
      Panel2.Caption := 'Fjerner data på nettet ...';
      Panel2.Repaint;
      ListBox1.Items.Add('Fjerner data på nettet ...');
      //Self.ChangeDir(ZQuery1.FieldByName('FTPBibloPaaNet').AsString);
    End
  Else
    Begin // Gør ikke noget
    End;
  // Datafil lægges op
  try
    Panel2.Caption := 'Data lægges op på internettet ...';
    Panel2.Repaint;
    IdFTP1.TransferType := ftBinary;
    IdFTP1.Put(Options_Alias_Net1 + DirectorySeparator + DataFil, DataFil);
    Panel2.Caption := 'Data er lagt op på internettet ...';
    Panel2.Repaint;
  Except
    clmMessageDlg('Advarsel: Data blev ikke lagt korrekt op på internet. De skal lægges op igen!',mtError,[mbOK],'0');
    Exit;
  End;
  // Log
//  GemLog('1');
  // Fjern spærring
  Try
//    IdFTP1.ChangeDir(ZQuery1.FieldByName('FTPBibloPaaNet').AsString);
  Except
  End;
  Try
    IdFTP1.Delete(BrugerInfoFil);
  Except
    clmMessageDlg('Advarsel: Spærring kunne ikke fjernes - bør fjernes manuelt under: Skift forening faneblad server!',mtError,[mbOK],'0');
    Exit;
  End;
  Panel2.Caption := 'Spærring fjernet ...';
  Panel2.Repaint;
end;


end.

