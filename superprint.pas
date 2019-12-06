//***************************************************************************//
//  Holbæk                                                                   //
//  Copyright by Claus Moeller 2013-2014                                     //
//  SuperPrinte                                                              //
//  Version                                                                  //
//  25.11.13                                                                 //
//***************************************************************************//
unit SuperPrint;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil,Forms,
  Controls, Graphics, Dialogs, ComCtrls, ActnList, ExtCtrls, StdCtrls, Buttons,
  ZDataset, IniFiles, LR_DBSet, LR_Class;

type

  { TSuperPrintForm }

  TSuperPrintForm = class(TForm)
    BitBtn5: TBitBtn;
    DataTilUdskriv: TfrDBDataSet;
    frReport1: TfrReport;
   // frReport1: TfrReport;
    ToolButton2: TToolButton;
    //DataTilUdskriv: TfrDBDataSet;
    Help: TAction;
    BitBtn4: TBitBtn;
    CheckSpecifikkeRapporter: TCheckBox;
    ActionList1: TActionList;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    RapportCombo: TComboBox;
    EditNyRapport: TEdit;
    ImageList1: TImageList;
    Label1: TLabel;
    Luk: TAction;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    Udskriv_Data: TZQuery;
    procedure DefaultExecute(Sender: TObject);
    procedure EditorExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure HelpExecute(Sender: TObject);
    procedure LukExecute(Sender: TObject);
    procedure NyExecute(Sender: TObject);
    procedure SletExecute(Sender: TObject);
    procedure UdskrivExecute(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    TypeRapport    : Integer;
    IniFile        : TInifile;
    RapportTitel   : String;
    procedure IndlaesFlueben;
    procedure IndlaesRapportCombo;
  end;

var
  SuperPrintForm: TSuperPrintForm;

implementation

{$R *.lfm}

Uses HolbaekConst, HolbaekMain;

{ TSuperPrintForm }

//**********************************************************
// Luk
//**********************************************************
procedure TSuperPrintForm.LukExecute(Sender: TObject);
begin
  Close;
end;

//**********************************************************
// Ny
//**********************************************************
procedure TSuperPrintForm.NyExecute(Sender: TObject);
Var Result : Boolean;
begin
  // File must be copied
  If EditNyRapport.Text = RapportCombo.Text Then
    Begin
      MessageDlg('Rapport kan ikke kopieres oven i sig selv !',mtError,[mbOk],0);
      Exit;
    End;
  If FileExists(Options_Alias_Data + DirectorySeparator + EditNyRapport.Text + '.' + ReportExt) Then
    Begin
      If MessageDlg('Rapporten findes i forvejen. Skal den overskrives ?',
        mtConfirmation,[mbYes,mbNo],0) <> mrYes Then
        Begin
          Exit;
        End;
    End;
  Result := CopyFile(Options_Alias_Data + DirectorySeparator + RapportCombo.Text + '.' + ReportExt,
    Options_Alias_Data + DirectorySeparator + EditNyRapport.Text + '.' + ReportExt);
  If Not Result Then
    Begin
      MessageDlg('Rapporten kunne ikke oprettes !',mtError,[mbOk],0);
    End
  Else
    Begin
      IndlaesRapportCombo;
      RapportCombo.ItemIndex := RapportCombo.Items.IndexOf(EditNyRapport.Text);
      MessageDlg('Rapporten er nu oprettet !',mtInformation,[mbOk],0);
    End;

end;

//**********************************************************
// Slet
//**********************************************************
procedure TSuperPrintForm.SletExecute(Sender: TObject);
begin
  ShowMessage('Slet');
end;

//**********************************************************
// Udskriv
//**********************************************************
procedure TSuperPrintForm.UdskrivExecute(Sender: TObject);
begin
  // Forbered data
//  Udskriv_Data.Connection := MainForm.ZConnection1;
  With Udskriv_Data.SQL do
    Begin
      Clear;
      Add('Select * from udskriv order by nr');
    End;
  Udskriv_Data.Open;
  // Find rapport
  If RapportCombo.ItemIndex = -1 Then
    Begin // Ikke fundet en rapport
      MessageDlg('Der skal vælges en rapport før den kan udskrives!',
        mtInformation,[mbOK],0);
      Exit;
    End;
  // Alle data ligger nu i tabellen - start reportdesigner
  frReport1.LoadFromFile(Options_Alias_Data +
     DirectorySeparator + RapportCombo.Text + '.' + ReportExt);
  frReport1.ShowReport;
end;

//**********************************************************
// Editor
//**********************************************************
procedure TSuperPrintForm.EditorExecute(Sender: TObject);
Var HelpStr : String;
begin
  // Forbered data
//  Udskriv_Data.Connection := MainForm.ZConnection1;
  With Udskriv_Data.SQL do
    Begin
      Clear;
      Add('Select * from udskriv');
    End;
  Udskriv_Data.Open;
  // Hent rapport
  frReport1.LoadFromFile(Options_Alias_Data +
     DirectorySeparator + RapportCombo.Text + '.' + ReportExt);
  frReport1.DesignReport;
  // Sæt fokus
  HelpStr := RapportCombo.Text;
  IndlaesRapportCombo;
  RapportCombo.ItemIndex := RapportCombo.Items.IndexOf(HelpStr);
end;

//**********************************************************
// Create
//**********************************************************
procedure TSuperPrintForm.FormCreate(Sender: TObject);
begin
  Position := poDesigned;
  (*Top := 10;
  Left := 30;*)
  // Farver
  ToolBar1.Color    := H_Menu_knapper_Farve;
//  StatusBar1.Color  := H_Menu_knapper_Farve;;
  Color             := H_Window_Baggrund;
  // Inifile
  IniFile := TIniFile.Create(HolbaekIniFile);
end;

//**********************************************************
// Destroy
//**********************************************************
procedure TSuperPrintForm.FormDestroy(Sender: TObject);
begin
  Inifile.Free;
end;

//**********************************************************
// Close
//**********************************************************
procedure TSuperPrintForm.HelpExecute(Sender: TObject);
begin
  Close;
end;

//**********************************************************
// Default
//**********************************************************
procedure TSuperPrintForm.DefaultExecute(Sender: TObject);
begin
    // Check først om der er en at sætte
  If RapportCombo.Text = '' Then
    Begin
      MessageDlg('Der skal vælges en rapport først!',mtInformation,[mbOK],0);
    End
  Else
    Begin
      Case TypeRapport Of
        1 : Begin // Kassekladde
              IniFile.WriteString('OkoSuperPrint','KasseDefault',RapportCombo.Text);
              IniFile.WriteBool('OkoSuperPrint','KasseRapporter',
                CheckSpecifikkeRapporter.Checked);
            End;
        2 : Begin // Kontoplan
              IniFile.WriteString('OkoSuperPrint','KontoDefault',RapportCombo.Text);
              IniFile.WriteBool('OkoSuperPrint','KontoRapporter',
                CheckSpecifikkeRapporter.Checked);
            End;
        3 : Begin // Se konto
              IniFile.WriteString('OkoSuperPrint','KortDefault',RapportCombo.Text);
              IniFile.WriteBool('OkoSuperPrint','KortRapporter',
                CheckSpecifikkeRapporter.Checked);
            End;
        4 : Begin // Oko def
              IniFile.WriteString('OkoSuperPrint','OkoDefDefault',RapportCombo.Text);
              IniFile.WriteBool('OkoSuperPrint','OkoDefRapporter',
                CheckSpecifikkeRapporter.Checked);
            End;
        5 : Begin // Afstemning
              IniFile.WriteString('OkoSuperPrint','AfstemningDefault',RapportCombo.Text);
              IniFile.WriteBool('OkoSuperPrint','Afstemningskonti',
                CheckSpecifikkeRapporter.Checked);
            End;
        6 : Begin // Postering
              IniFile.WriteString('OkoSuperPrint','PosteringDefault',RapportCombo.Text);
              IniFile.WriteBool('OkoSuperPrint','Postering',
                CheckSpecifikkeRapporter.Checked);
            End;
        7 : Begin // Flere konti
              IniFile.WriteString('OkoSuperPrint','FlereKontiDefault',RapportCombo.Text);
              IniFile.WriteBool('OkoSuperPrint','FlereKonti',
                CheckSpecifikkeRapporter.Checked);
            End;
        8 : Begin // Find bilag
              IniFile.WriteString('OkoSuperPrint','FindBilagDefault',RapportCombo.Text);
              IniFile.WriteBool('OkoSuperPrint','FindBilag',
                CheckSpecifikkeRapporter.Checked);
            End;
        9 : Begin // Rap okonomi felter
              IniFile.WriteString('OkoSuperPrint','RapOkoDefault',RapportCombo.Text);
              IniFile.WriteBool('OkoSuperPrint','RapOko',
                CheckSpecifikkeRapporter.Checked);
            End;
        10 : Begin // Kassekladde oversigt
              IniFile.WriteString('OkoSuperPrint','KasOverDefault',RapportCombo.Text);
              IniFile.WriteBool('OkoSuperPrint','KasOver',
                CheckSpecifikkeRapporter.Checked);
            End;
        11 : Begin // Net kontoplan
              IniFile.WriteString('OkoSuperPrint','NetKontoDefault',RapportCombo.Text);
              IniFile.WriteBool('OkoSuperPrint','NetKonto',
                CheckSpecifikkeRapporter.Checked);
            End;
        20: Begin // Find indbetaling
              IniFile.WriteString('OkoSuperPrint','FindIndbetalingDefault',RapportCombo.Text);
              IniFile.WriteBool('OkoSuperPrint','FindIndbetaling',
                CheckSpecifikkeRapporter.Checked);
            End;
        30: Begin // Undersøg aktiviteter
              IniFile.WriteString('OkoSuperPrint','UndersoegAktiviterDefault',RapportCombo.Text);
              IniFile.WriteBool('OkoSuperPrint','UndersoegAktiviteter',
                CheckSpecifikkeRapporter.Checked);
            End;
        31: Begin // Undersøg aktiviteter oversigt
              IniFile.WriteString('OkoSuperPrint','UndersoegAktiviterOversigtDefault',RapportCombo.Text);
              IniFile.WriteBool('OkoSuperPrint','UndersoegAktiviteterOversigt',
                CheckSpecifikkeRapporter.Checked);
            End;
        32: Begin // Aktiviteter find
              IniFile.WriteString('OkoSuperPrint','AktFindDefault',RapportCombo.Text);
              IniFile.WriteBool('OkoSuperPrint','AktFind',CheckSpecifikkeRapporter.Checked);
            End;
        33: Begin // Aktiviteter Ledige
              IniFile.WriteString('OkoSuperPrint','AktLedigeDefault',RapportCombo.Text);
              IniFile.WriteBool('OkoSuperPrint','AktLedige',CheckSpecifikkeRapporter.Checked);
            End;
        34: Begin // Rabatoversigt
              IniFile.WriteString('OkoSuperPrint','RabatOversigtDefault',RapportCombo.Text);
              IniFile.WriteBool('OkoSuperPrint','RabatOversigtCheck',CheckSpecifikkeRapporter.Checked);
            End;
        35: Begin // Aktivitet objekter
              IniFile.WriteString('OkoSuperPrint','AktObjektDefault',RapportCombo.Text);
              IniFile.WriteBool('OkoSuperPrint','AktObjekt',CheckSpecifikkeRapporter.Checked);
            End;
        40: Begin // Medlem check
              IniFile.WriteString('OkoSuperPrint','MdlCheckDefault',RapportCombo.Text);
              IniFile.WriteBool('OkoSuperPrint','MedlemCheck',CheckSpecifikkeRapporter.Checked);
            End;
        50: Begin // PBS FIK04
              IniFile.WriteString('OkoSuperPrint','PBSFIK04Default',RapportCombo.Text);
              IniFile.WriteBool('OkoSuperPrint','PBSFIK04Check',CheckSpecifikkeRapporter.Checked);
            End;
        60: Begin // PBS total
              IniFile.WriteString('OkoSuperPrint','PBSTotalDefault',RapportCombo.Text);
              IniFile.WriteBool('OkoSuperPrint','PBSTotalCheck',CheckSpecifikkeRapporter.Checked);
            End;
        61: Begin // PBS total aftaler
              IniFile.WriteString('OkoSuperPrint','PBSAftDefault',RapportCombo.Text);
              IniFile.WriteBool('OkoSuperPrint','PBSAftCheck',CheckSpecifikkeRapporter.Checked);
            End;
        70: Begin // Medlemsoplysninger
              IniFile.WriteString('OkoSuperPrint','MedOplyDefault',RapportCombo.Text);
              IniFile.WriteBool('OkoSuperPrint','MedOplyCheck',CheckSpecifikkeRapporter.Checked);
            End
        Else
            Begin // Ved fejl
            End;
      End; // End Case
    End;
end;


//**********************************************************
// Indlæs RapportCombo
//**********************************************************
procedure TSuperPrintForm.IndlaesRapportCombo;
var
  sr: TSearchRec;
  FindStr : String;
  HelpStr : String;
Begin
  // Sæt default for udskriv tabellensnavn
  Case TypeRapport Of
    1 : Begin // Kassekladde
          CheckSpecifikkeRapporter.Caption := 'Vis kun kassekladderapporter:';
          EditNyRapport.Text  := 'Kasse_Navn';
          Application.ProcessMessages;
          FindStr := Options_Alias_Data + 'Kasse*.' + ReportExt;
        End;
    2 : Begin // Kontoplan
          CheckSpecifikkeRapporter.Caption := 'Vis kun kontoplansrapporter:';
          EditNyRapport.Text  := 'Konto_Navn';
          Application.ProcessMessages;
          FindStr := Options_Alias_Data + '\Konto*.' + ReportExt;
        End;
    3 : Begin // Se konto
          CheckSpecifikkeRapporter.Caption := 'Vis kun kontokortsrapporter:';
          EditNyRapport.Text  := 'Kort_Navn';
          Application.ProcessMessages;
          FindStr := Options_Alias_Data + '\Kort*.' + ReportExt;
        End;
    4 : Begin // Øko def
          CheckSpecifikkeRapporter.Caption := 'Vis kun økofelts definitionsrapporter';
          EditNyRapport.Text  := 'Oko_Navn';
          Application.ProcessMessages;
          FindStr := Options_Alias_Data + '\Oko*.' + ReportExt;
        End;
    5 : Begin // Afstemningskonti
          CheckSpecifikkeRapporter.Caption := 'Vis kun afstemningskontirapporter';
          EditNyRapport.Text  := 'Afstem_Navn';
          Application.ProcessMessages;
          FindStr := Options_Alias_Data + '\Afstem*' + ReportExt;
        End;
    6 : Begin // Posteringsjounal
          CheckSpecifikkeRapporter.Caption := 'Vis kun posteringsjounaler';
          EditNyRapport.Text  := 'Postering_Navn';
          Application.ProcessMessages;
          FindStr := Options_Alias_Data + '\Postering*' + ReportExt;
        End;
    7 : Begin // Flere konti
          CheckSpecifikkeRapporter.Caption := 'Vis kun rapporter til flere konti';
          EditNyRapport.Text  := 'FlereKonti_Navn';
          Application.ProcessMessages;
          FindStr := Options_Alias_Data + '\FlereKonti*' + ReportExt;
        End;
    8 : Begin // Find bilag
          CheckSpecifikkeRapporter.Caption := 'Vis kun rapporter til Find bilag';
          EditNyRapport.Text  := 'FindBilag_Navn';
          Application.ProcessMessages;
          FindStr := Options_Alias_Data + '\FindBilag*' + ReportExt;
        End;
    9 : Begin // Økorapporter
          CheckSpecifikkeRapporter.Caption := 'Vis kun rapporter til Økofelter';
          EditNyRapport.Text  := 'RapOko_Navn';
          Application.ProcessMessages;
          FindStr := Options_Alias_Data + '\RapOko*' + ReportExt;
        End;
    10 : Begin // Kassekladde oversigt
          CheckSpecifikkeRapporter.Caption := 'Vis kun rapporter til kassekladde oversigt';
          EditNyRapport.Text  := 'KasOver_Navn';
          Application.ProcessMessages;
          FindStr := Options_Alias_Data + '\KasOver*' + ReportExt;
        End;
    11 : Begin // Kontoplan fra Net
          CheckSpecifikkeRapporter.Caption := 'Vis kun rapporter til kontoplans oversigt';
          EditNyRapport.Text  := 'NetKonto_Navn';
          Application.ProcessMessages;
          FindStr := Options_Alias_Data + '\NetKonto*' + ReportExt;
        End;
    20: Begin // Find indbetalingskort
          Caption := 'Find indbetalingskort...';
          CheckSpecifikkeRapporter.Caption := 'Vis kun rapporter til Find indbetalingskort';
          EditNyRapport.Text  := 'Indb_Navn';
          Application.ProcessMessages;
          FindStr := Options_Alias_Data + '\Indb*.' + ReportExt;
        End;
    30: Begin // Undersøg aktiviteter
          Caption := 'Undersøg aktiviteter...';
          CheckSpecifikkeRapporter.Caption := 'Vis kun rapporter til Undersøg aktiviteter';
          EditNyRapport.Text  := 'AktUnder_Navn';
          Application.ProcessMessages;
          FindStr := Options_Alias_Data + '\AktUnder*' + ReportExt;
        End;
    31: Begin // Undersøg aktiviteter oversigt
          Caption := 'Undersøg aktiviteter...';
          CheckSpecifikkeRapporter.Caption := 'Vis kun rapporter til aktivitet oversigt';
          EditNyRapport.Text  := 'AktUnderOver_Navn';
          Application.ProcessMessages;
          FindStr := Options_Alias_Data + '\AktUnderO*' + ReportExt;
        End;
    32: Begin // Aktiviteter find
          Caption := 'Find medlemmer på aktiviteter...';
          CheckSpecifikkeRapporter.Caption := 'Vis kun rapporter til find aktivitet';
          EditNyRapport.Text  := 'AktFind_Navn';
          Application.ProcessMessages;
          FindStr := Options_Alias_Data + '\AktFind*' + ReportExt;
        End;
    33: Begin // Undersøg aktiviteter ledige
          Caption := 'Ledige på aktiviteter...';
          CheckSpecifikkeRapporter.Caption := 'Vis kun rapporter til ledige på aktivitet';
          EditNyRapport.Text  := 'AktLedige_Navn';
          Application.ProcessMessages;
          FindStr := Options_Alias_Data + '\AktLedige*' + ReportExt;
        End;
    34: Begin // Rabatoversigt
          Caption := 'Oversigt over rabatter per priskategori...';
          CheckSpecifikkeRapporter.Caption := 'Vis kun rapporter til rabatter';
          EditNyRapport.Text  := 'RabatOv_Navn';
          Application.ProcessMessages;
          FindStr := Options_Alias_Data + '\RabatOv_*' + ReportExt;
        End;
    35: Begin // Aktivitet objekter
          Caption := 'Objekter på aktiviteter...';
          CheckSpecifikkeRapporter.Caption := 'Vis kun rapporter til objekter på aktiviteter';
          EditNyRapport.Text  := 'AktObjekt_Navn';
          Application.ProcessMessages;
          FindStr := Options_Alias_Data + '\AktObjekt*' + ReportExt;
        End;
    40: Begin // MedlemCheck
          Caption := 'Medlemsliste ud fra mærker...';
          CheckSpecifikkeRapporter.Caption := 'Vis kun rapporter til mærker';
          EditNyRapport.Text  := 'MdlCheck_Navn';
          Application.ProcessMessages;
          FindStr := Options_Alias_Data + '\MdlCheck*' + ReportExt;
        End;
    50: Begin // PBS_FIK04
          Caption := 'Betalinghåndtering FIK04...';
          CheckSpecifikkeRapporter.Caption := 'Vis kun rapporter til FIK04';
          EditNyRapport.Text  := 'PBSFIK04_Navn';
          Application.ProcessMessages;
          FindStr := Options_Alias_Data + '\PBSFIK04*' + ReportExt;
        End;
    60: Begin // PBS Total
          Caption := 'Betalingsservice indbetalinger...';
          CheckSpecifikkeRapporter.Caption := 'Vis kun rapporter til betalingsservice';
          EditNyRapport.Text  := 'PBSTot_Navn';
          Application.ProcessMessages;
          FindStr := Options_Alias_Data + '\PBSTot*' + ReportExt;
        End;
    61: Begin // PBS Total aftaler
          Caption := 'Betalingsservice aftaler...';
          CheckSpecifikkeRapporter.Caption := 'Vis kun rapporter til PBS aftaler';
          EditNyRapport.Text  := 'PBSAft_Navn';
          Application.ProcessMessages;
          FindStr := Options_Alias_Data + '\PBSAft*' + ReportExt;
        End;
    70: Begin // Medlemsoplysninger
          Caption := 'Medlemsoplysninger...';
          CheckSpecifikkeRapporter.Caption := 'Vis kun rapporter til Medlemsoplysninger';
          EditNyRapport.Text  := 'MedOply_Navn';
          Application.ProcessMessages;
          FindStr := Options_Alias_Data + '\MedOply*' + ReportExt;
        End
    Else
        Begin // Ved fejl
        End;
  End; // End Case
  // Åben Tabel
  Try
//    UdskrivOkonomiTabel.Open;
  Except
    MessageDlg('Kan ikke åbne datafilen!!!',mtError,[mbOK],0);
    Exit;
  End;
  RapportCombo.Clear;
  If Not CheckSpecifikkeRapporter.Checked Then
    Begin // Kun de raporter som starter med Medlem
      FindStr := Options_Alias_Data + '*.' + ReportExt;
    End;
  If FindFirst(FindStr,faAnyFile, sr) = 0 then
    Begin
      HelpStr := Sr.Name;
      Delete(Helpstr,Pos('.',Sr.Name),Length(Sr.Name)-Pos('.',Sr.Name)+1);
      RapportCombo.Items.Add(HelpStr);
      While FindNext(sr) = 0 do
        Begin
          HelpStr := Sr.Name;
          Delete(Helpstr,Pos('.',Sr.Name),Length(Sr.Name)-Pos('.',Sr.Name)+1);
          RapportCombo.Items.Add(HelpStr);
        End;
      SysUtils.FindClose(sr);
    end;
  // Tag default
  Case TypeRapport Of
    1 : Begin // Kassekladde
          HelpStr := IniFile.ReadString('OkoSuperPrint','KasseDefault',RapportCombo.Text);
        End;
    2 : Begin // Kontoplan
          HelpStr := IniFile.ReadString('OkoSuperPrint','KontoDefault',RapportCombo.Text);
        End;
    3 : Begin // Se Konto
          HelpStr := IniFile.ReadString('OkoSuperPrint','KortDefault',RapportCombo.Text);
        End;
    4 : Begin // Oko def
          HelpStr := IniFile.ReadString('OkoSuperPrint','OkoDefDefault',RapportCombo.Text);
        End;
    5 : Begin // Afstemningskonti
          HelpStr := IniFile.ReadString('OkoSuperPrint','AfstemningDefault',RapportCombo.Text);
        End;
    6 : Begin // Posteringsjounaler
          HelpStr := IniFile.ReadString('OkoSuperPrint','PosteringDefault',RapportCombo.Text);
        End;
    7 : Begin // Flere konti
          HelpStr := IniFile.ReadString('OkoSuperPrint','FlereKontiDefault',RapportCombo.Text);
        End;
    8 : Begin // Find bilag
          HelpStr := IniFile.ReadString('OkoSuperPrint','FindBilagDefault',RapportCombo.Text);
        End;
    9 : Begin // Øko rapporter
          HelpStr := IniFile.ReadString('OkoSuperPrint','RapOkoDefault',RapportCombo.Text);
        End;
    10 : Begin // Kassekladde oversigt
          HelpStr := IniFile.ReadString('OkoSuperPrint','KasOverDefault',RapportCombo.Text);
        End;
    11 : Begin // Net kontoplan
          HelpStr := IniFile.ReadString('OkoSuperPrint','NetKontoDefault',RapportCombo.Text);
        End;
    20 : Begin // Find indbetalingskort
          HelpStr := IniFile.ReadString('OkoSuperPrint','FindIndbetalingDefault',RapportCombo.Text);
         End;
    30 : Begin // Undersoeg Aktiviteter
          HelpStr := IniFile.ReadString('OkoSuperPrint','UndersoegAktiviterDefault',RapportCombo.Text);
         End;
    31 : Begin // Undersoeg Aktiviteter oversigt
          HelpStr := IniFile.ReadString('OkoSuperPrint','UndersoegAktiviteterOversigtDefault',RapportCombo.Text);
         End;
    32 : Begin // Aktiviteter find
          HelpStr := IniFile.ReadString('OkoSuperPrint','AktFindDefault',RapportCombo.Text);
         End;
    33 : Begin // Aktiviteter ledige
          HelpStr := IniFile.ReadString('OkoSuperPrint','AktLedigeDefault',RapportCombo.Text);
          End;
    34 : Begin // RabatOversigt
          HelpStr := IniFile.ReadString('OkoSuperPrint','RabatOversigtDefault',RapportCombo.Text);
         End;
    35 : Begin // Aktivitet objekter
          HelpStr := IniFile.ReadString('OkoSuperPrint','AktObjektDefault',RapportCombo.Text);
          End;
    40 : Begin // Medlemcheck
          HelpStr := IniFile.ReadString('OkoSuperPrint','MdlCheckDefault',RapportCombo.Text);
         End;
    50 : Begin // PBS FIK 04
          HelpStr := IniFile.ReadString('OkoSuperPrint','PBSFIK04Default',RapportCombo.Text);
         End;
    60 : Begin // PBS total
          HelpStr := IniFile.ReadString('OkoSuperPrint','PBSTotalDefault',RapportCombo.Text);
         End;
    61 : Begin // PBS total aftaler
          HelpStr := IniFile.ReadString('OkoSuperPrint','PBSAftDefault',RapportCombo.Text);
         End;
    70 : Begin // Medlemsoplysninger
          HelpStr := IniFile.ReadString('OkoSuperPrint','MedOplyDefault',RapportCombo.Text);
         End;
    Else
        Begin // Ved fejl
        End;
  End; // End Case
  RapportCombo.ItemIndex := RapportCombo.Items.IndexOf(HelpStr);
  If RapportCombo.ItemIndex = -1 Then
    Begin
      RapportCombo.ItemIndex := 0;
    End;
End;

//**********************************************************
// Indlæs Flueben
//**********************************************************
procedure TSuperPrintForm.IndlaesFlueben;
Begin
  Case TypeRapport Of
    1 : Begin // Kassekladde
          CheckSpecifikkeRapporter.Checked := IniFile.ReadBool('OkoSuperPrint','KasseRapporter',True);
        End;
    2 : Begin // Kontoplan
          CheckSpecifikkeRapporter.Checked := IniFile.ReadBool('OkoSuperPrint','KontoRapporter',True);
        End;
    3 : Begin // Se Konto
          CheckSpecifikkeRapporter.Checked := IniFile.ReadBool('OkoSuperPrint','KortRapporter',True);
        End;
    4 : Begin // Okofelter
          CheckSpecifikkeRapporter.Checked := IniFile.ReadBool('OkoSuperPrint','OkoDefRapporter',True);
        End;
    5 : Begin // Afstemningskonti
          CheckSpecifikkeRapporter.Checked := IniFile.ReadBool('OkoSuperPrint','Afstemningskonti',True);
        End;
    6 : Begin // Posteringsjounal
          CheckSpecifikkeRapporter.Checked := IniFile.ReadBool('OkoSuperPrint','Postering',True);
        End;
    7 : Begin // Flere konti
          CheckSpecifikkeRapporter.Checked := IniFile.ReadBool('OkoSuperPrint','FlereKonti',True);
        End;
    8 : Begin // Find Bilag
          CheckSpecifikkeRapporter.Checked := IniFile.ReadBool('OkoSuperPrint','FindBilag',True);
        End;
    9 : Begin // Økorapporter
          CheckSpecifikkeRapporter.Checked := IniFile.ReadBool('OkoSuperPrint','RapOko',True);
        End;
    10 : Begin // Kassekladde oversigt
          CheckSpecifikkeRapporter.Checked := IniFile.ReadBool('OkoSuperPrint','KasOver',True);
        End;
    11 : Begin // KontoFraNet
          CheckSpecifikkeRapporter.Checked := IniFile.ReadBool('OkoSuperPrint','NetKonto',True);
        End;
    20: Begin // Find indbetalinskort
          CheckSpecifikkeRapporter.Checked := IniFile.ReadBool('OkoSuperPrint','FindIndbetalingskort',True);
        End;
    30: Begin // Undersøg aktiviteter
          CheckSpecifikkeRapporter.Checked := IniFile.ReadBool('OkoSuperPrint','UndersoegAktiviteter',True);
        End;
    31: Begin // Undersøg aktiviteter oversigt
          CheckSpecifikkeRapporter.Checked := IniFile.ReadBool('OkoSuperPrint','UndersoegAktiviteterOversigt',True);
        End;
    32: Begin // Aktiviteter find
          CheckSpecifikkeRapporter.Checked := IniFile.ReadBool('OkoSuperPrint','AktFind',True);
        End;
    33: Begin // Aktiviteter ledige
          CheckSpecifikkeRapporter.Checked := IniFile.ReadBool('OkoSuperPrint','AktLedige',True);
        End;
    34: Begin // Rabatoversigt
          CheckSpecifikkeRapporter.Checked := IniFile.ReadBool('OkoSuperPrint','RabatOversigtCheck',True);
        End;
    35: Begin // Aktivitet objekter
          CheckSpecifikkeRapporter.Checked := IniFile.ReadBool('OkoSuperPrint','AktObjekt',True);
        End;
    40: Begin // Medlem Check
          CheckSpecifikkeRapporter.Checked := IniFile.ReadBool('OkoSuperPrint','MedlemCheck',True);
        End;
    50: Begin // PBS håndtering
          CheckSpecifikkeRapporter.Checked := IniFile.ReadBool('OkoSuperPrint','PBSFIK04Check',True);
        End;
    60: Begin // PBS total  indbetalinger
          CheckSpecifikkeRapporter.Checked := IniFile.ReadBool('OkoSuperPrint','PBSTotalCheck',True);
        End;
    61: Begin // PBS total aftaler
          CheckSpecifikkeRapporter.Checked := IniFile.ReadBool('OkoSuperPrint','PBSAftCheck',True);
        End;
    70: Begin // Medlemoplysninger
          CheckSpecifikkeRapporter.Checked := IniFile.ReadBool('OkoSuperPrint','MedOplyCheck',True);
        End;
    Else
        Begin // Ved fejl
        End;
  End; // End Case
End;


end.

