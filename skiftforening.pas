//***************************************************************************//
//  Holbæk                                                                   //
//  Copyright by Claus Moeller 2013-2014                                     //
//  Skift forenming                                                          //
//  Version                                                                  //
//  02.03.14                                                                 //
//***************************************************************************//
unit SkiftForening;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics,
  Dialogs, ComCtrls, Menus, ActnList, DbCtrls, StdCtrls,
  ZDataset, clmCombobox, db, LCLType;

type

  { TSkiftForeningForm }

  TSkiftForeningForm = class(TForm)
    ActionList1: TActionList;
    ButtonLaegDataPaaInternet: TButton;
    ButtonFjernSpaerring: TButton;
    ButtonTest: TButton;
    ComboBox1: TComboBox;
    ComboPeriode: TclmCombobox;
    DBBankkonto: TDBEdit;
    DBCheckAktiverDPI: TDBCheckBox;
    DBBibloPaaNet: TDBEdit;
    DBCheckAskDataUp: TDBCheckBox;
    DBCheckSnuser: TDBCheckBox;
    DBCheckSnuser1: TDBCheckBox;
    DBCheckLogning: TDBCheckBox;
    DBFTPHost: TDBEdit;
    DBProxyHost: TDBEdit;
    DBFTPPassword: TDBEdit;
    DBProxyPassword: TDBEdit;
    DBProxyPort: TDBEdit;
    DBFTPUserId: TDBEdit;
    DBFTPPort: TDBEdit;
    DBProxyUserId: TDBEdit;
    DBKending: TDBEdit;
    DBFTPBrugerTlf: TDBEdit;
    DBPop3Server: TDBEdit;
    DBPop3BrugerId: TDBEdit;
    DBPop3Password: TDBEdit;
    DBTidMellemBurst: TDBEdit;
    DBSMTPLogon: TDBCheckBox;
    DBMailModtaget: TDBCheckBox;
    DBSMTPPassword: TDBEdit;
    DBMaxBurst: TDBEdit;
    DBSMTPServer: TDBEdit;
    DBCheckBox1: TDBCheckBox;
    DBComboKortArt: TDBComboBox;
    DBDataLevNr: TDBEdit;
    DBGiro: TDBEdit;
    DBEmail: TDBEdit;
    DBK71PBSNr: TDBEdit;
    DBDebiNr: TDBEdit;
    DBHjemmeside: TDBEdit;
    DBSMTPPort: TDBEdit;
    GroupBox10: TGroupBox;
    GroupBox7: TGroupBox;
    GroupBox8: TGroupBox;
    GroupBox9: TGroupBox;
    Label21: TLabel;
    DBSMTPAfsender: TDBEdit;
    DBPBSNr: TDBEdit;
    DBRadioGroup1: TDBRadioGroup;
    DBSE: TDBEdit;
    DBPostNrDefault: TDBEdit;
    DBFI: TDBEdit;
    DBBankReg: TDBEdit;
    DBTelefon: TDBEdit;
    DBFax: TDBEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    GroupBox5: TGroupBox;
    GroupBox6: TGroupBox;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label20: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    Label29: TLabel;
    Label30: TLabel;
    Label31: TLabel;
    Label32: TLabel;
    Label33: TLabel;
    Label34: TLabel;
    Label35: TLabel;
    Label36: TLabel;
    Label37: TLabel;
    Label38: TLabel;
    Label39: TLabel;
    Label40: TLabel;
    Label41: TLabel;
    Label42: TLabel;
    Label43: TLabel;
    Label44: TLabel;
    Label45: TLabel;
    Label46: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    LandCombo: TclmCombobox;
    Datasource1: TDatasource;
    DBPostNr: TDBEdit;
    DBEditNavn: TDBEdit;
    DBEditForkort: TDBEdit;
    DBEditAdr: TDBEdit;
    DBNavigator1: TDBNavigator;
    DBText1: TDBText;
    Help: TAction;
    ImageList1: TImageList;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    LandCombo1: TclmCombobox;
    Luk: TAction;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    PageControl1: TPageControl;
    PopupMenu1: TPopupMenu;
    DBBrugerId: TDBEdit;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton3: TToolButton;
    ZQuery1: TZQuery;
    ZQuery2: TZQuery;
    ZQueryAfdDef: TZQuery;
    ZQueryPostNr: TZQuery;
    procedure ButtonFjernSpaerringClick(Sender: TObject);
    procedure ButtonLaegDataPaaInternetClick(Sender: TObject);
    procedure ButtonTestClick(Sender: TObject);
    procedure DBPostNrExit(Sender: TObject);
    procedure DBNavigator1Click(Sender: TObject; Button: TDBNavButtonType);
    procedure FormCreate(Sender: TObject);
    procedure LandCombo1Change(Sender: TObject);
    procedure LandComboChange(Sender: TObject);
    procedure LukExecute(Sender: TObject);
  private
    { private declarations }
    procedure Indstil;
    procedure NyForening;
    Procedure IndlaesLand;
    procedure IndlaesPeriode;
  public
    { public declarations }
  end;

var
  SkiftForeningForm: TSkiftForeningForm;

implementation

Uses HolbaekMain, HolbaekConst, MainData, FtpShare;

{$R *.lfm}

{ TSkiftForeningForm }

//**********************************************************
// Create
//**********************************************************
procedure TSkiftForeningForm.FormCreate(Sender: TObject);
begin
  Position := poDesigned;
  (*Top := 10;
  Left := 30;*)
  // Farver
  ToolBar1.Color        := H_Menu_knapper_Farve;
  Color                 := H_Window_Baggrund;
  DBEditNavn.Color      := H_Edit_Baggrund;
  DBEditForkort.Color   := H_Edit_Baggrund;
  DBEditAdr.Color       := H_Edit_Baggrund;
  DBPostNr.Color        := H_Edit_Baggrund;
  LandCombo.Color       := H_Combo_Color;
  LandCombo1.Color      := H_Combo_Color;
  DBTelefon.Color       := H_Edit_Baggrund;
  DBFax.Color           := H_Edit_Baggrund;
  DBEmail.Color         := H_Edit_Baggrund;
  DBHjemmeside.Color    := H_Edit_Baggrund;
  ComboPeriode.Color    := H_Combo_Color;
  DBPostNrDefault.Color := H_Edit_Baggrund;
  DBGiro.Color          := H_Edit_Baggrund;
  DBK71PBSNr.Color         := H_Edit_Baggrund;
  DBDebiNr.Color        := H_Edit_Baggrund;
  DBPBSNr.Color         := H_Edit_Baggrund;
  DBSE.Color            := H_Edit_Baggrund;
  DBFI.Color            := H_Edit_Baggrund;
  DBBankReg.Color       := H_Edit_Baggrund;
  DBBankkonto.Color     := H_Edit_Baggrund;
  DBDataLevNr.Color     := H_Edit_Baggrund;
  DBSMTPAfsender.Color  := H_Edit_Baggrund;
  DBBrugerId.Color      := H_Edit_Baggrund;
  DBSMTPPassword.Color  := H_Edit_Baggrund;
  DBSMTPServer.Color    := H_Edit_Baggrund;

  DBSMTPPort.Color      := H_Edit_Baggrund;
  DBMaxBurst.Color      := H_Edit_Baggrund;
  DBTidMellemBurst.Color:= H_Edit_Baggrund;
  DBPop3Server.Color    := H_Edit_Baggrund;
  DBPop3BrugerId.Color  := H_Edit_Baggrund;
  DBPop3Password.Color  := H_Edit_Baggrund;

  DBKending.Color       := H_Edit_Baggrund;
  DBFTPBrugerTlf.Color  := H_Edit_Baggrund;
  DBBibloPaaNet.Color   := H_Edit_Baggrund;

  DBFTPHost.Color       := H_Edit_Baggrund;
  DBFTPPassword.Color   := H_Edit_Baggrund;
  DBFTPPort.Color       := H_Edit_Baggrund;
  DBFTPUserId.Color     := H_Edit_Baggrund;

  DBProxyHost.Color     := H_Edit_Baggrund;
  DBProxyPassword.Color := H_Edit_Baggrund;
  DBProxyPort.Color     := H_Edit_Baggrund;
  DBProxyUserId.Color   := H_Edit_Baggrund;

  // Database
  ZQuery1.Connection := MainDataModule.ZConnection1;
  ZQuery2.Connection := MainDataModule.ZConnection1;
  ZQueryPostNr.Connection := MainDataModule.ZConnection1;
  ZQueryAfdDef.Connection := MainDataModule.ZConnection1;

  // Init

  //UpdateGrid := False;

  Indstil;
  // Indlaes
  IndlaesLand;
  IndlaesPeriode;


  //Indlaes;

end;


//**********************************************************
// Land combo default change
//**********************************************************
procedure TSkiftForeningForm.LandCombo1Change(Sender: TObject);
begin
  DataSource1.Edit;
end;

//**********************************************************
// Land combo change
//**********************************************************
procedure TSkiftForeningForm.LandComboChange(Sender: TObject);
begin
  DataSource1.Edit;
end;

//**********************************************************
// Navigator
//**********************************************************
procedure TSkiftForeningForm.DBNavigator1Click(Sender: TObject;
  Button: TDBNavButtonType);
begin
    If Button = nbPost Then
      Begin
        // Save content in comboboxes.
        Try
          ZQueryAfdDef.Edit;
          ZQueryAfdDef.FieldByName('LandKode').AsString :=
            LandCombo.Cells[2,LandCombo.ItemIndex];
          ZQueryAfdDef.FieldByName('LandKodeDefault').AsString :=
            LandCombo1.Cells[2,LandCombo1.ItemIndex];
          ZQueryAfdDef.Post;
        finally
        end;
      end
    Else If Button = nbDelete Then
      Begin
        //ShowMessage('Delete');

      end
    Else If Button = nbNext Then
      Begin

      end
    Else If Button = nbPrior Then
      Begin
      end
    Else If Button = nbLast Then
      Begin
      end
    Else If Button = nbFirst Then
      Begin
      end
    Else If Button = nbInsert Then
      Begin // New club
        NyForening;
      end;
  CurrentAfd := ZQueryAfdDef.FieldByName('Afd').AsString;
  IndlaesPeriode;
  IndlaesLand;
end;


//**********************************************************
// Postnr ændret
//**********************************************************
procedure TSkiftForeningForm.DBPostNrExit(Sender: TObject);
Var Str  : String;
    Tal  : Integer;
    Code : Integer;
begin
  If DBPostNr.Text = '' Then Exit;
  // Check om post er gyldigt
  Str := DBPostNr.Text;
  Val(Str,Tal,Code);
  If Code > 0 Then
    Begin
      MessageDlg('Postnr ikke et tal',mtError,[mbOk],0);
      DBPostNr.SetFocus;
      Exit;
    End;
  // Findes post?
  With ZQueryPostNr.SQL do
    Begin
      Clear;
      Add('Select * from postnr where (postnr = ' + Str +
          ') and (landkode = ' + LandCombo.Cells[2,LandCombo.ItemIndex]+ ')');
    End;
  ZQueryPostNr.Open;
  If ZQueryPostNr.RecordCount = 0 Then
    Begin // Fejl ikke oprettet
      MessageDlg('Postnr findes ikke - bør evt. oprettes!',mtError,[mbOk],0);
      ZQueryAfdDef.Edit;
      ZQueryAfdDef.FieldByName('PostNr').Clear;
      ZQueryAfdDef.Post;
      DBPostNr.SetFocus;
      Exit;
    End;
  // Indsæt city
  Try
    ZQueryAfdDef.Edit;
    ZQueryAfdDef.FieldByName('Town').AsString:= ZQueryPostNr.FieldByName('Town').AsString;
    ZQueryAfdDef.Post;
  Except
    MessageDlg('By kunne ikke opdateres!',mtError,[mbOk],0);
    Exit;
  end;
end;

//**********************************************************
// Test internet
//**********************************************************
procedure TSkiftForeningForm.ButtonTestClick(Sender: TObject);
begin
  FtpShareForm := TFtpShareForm.Create(Self);
  FtpShareForm.Timer1.Interval := 10000;
  FtpShareForm.Timer1.Enabled := True;
  FtpShareForm.Show;
  FtpShareForm.Diagnose(Sender);
end;

//**********************************************************
// BTN Fjern spærring
//**********************************************************
procedure TSkiftForeningForm.ButtonFjernSpaerringClick(Sender: TObject);
begin
  FtpShareForm := TFtpShareForm.Create(Self);
  FtpShareForm.Timer1.Interval := 10000;
  FtpShareForm.Timer1.Enabled := True;
  FtpShareForm.Show;
  FtpShareForm.FjernSpaerring(Sender);
end;

//**********************************************************
// Læg data op på nettet første gang.
//**********************************************************
procedure TSkiftForeningForm.ButtonLaegDataPaaInternetClick(Sender: TObject);
begin
  FtpShareForm := TFtpShareForm.Create(Self);
  FtpShareForm.Timer1.Interval := 30000;
  FtpShareForm.Timer1.Enabled := True;
  FtpShareForm.Show;
  FtpShareForm.LaegDataOpFoersteGang(Sender);
end;

//**********************************************************
// Luk
//**********************************************************
procedure TSkiftForeningForm.LukExecute(Sender: TObject);
begin
  Close;
end;

//**********************************************************
// Indstil
//**********************************************************
procedure TSkiftForeningForm.Indstil;
begin
  With ZQueryAfdDef.SQL do
    Begin
      Clear;
      Add('Select * from afddef');
    End;
  ZQueryAfdDef.Open;
  If ZQueryAfdDef.RecordCount = 0 Then
    Begin
      MessageDlg('Forening kan ikke findes!',mtError,[mbok],0);
    end;
end;

//**********************************************************
// Ny forening
//**********************************************************
procedure TSkiftForeningForm.NyForening;
Var HelpNr : Integer;
begin
  With ZQueryAfdDef.SQL do
    Begin
      Clear;
      Add('Select * from afddef order by afd');
    End;
  ZQueryAfdDef.Open;
  If ZQueryAfdDef.RecordCount = 0 Then
    Begin
      MessageDlg('Fejl - der bør være en forening',mtError,[mbOk],0);
      Exit;
    End
  Else
    Begin
      Try
        ZQueryAfdDef.Last;
        HelpNr := ZQueryAfdDef.FieldByName('Afd').AsInteger + 1;
        ZQueryAfdDef.Append;
        ZQueryAfdDef.Edit;
        ZQueryAfdDef.FieldByName('Afd').AsInteger           := HelpNr;
        ZQueryAfdDef.FieldByName('Navn').AsString           := 'Forening ' + IntToStr(HelpNr);
        ZQueryAfdDef.Post;
        ZQueryAfdDef.ApplyUpdates;
      Except
        MessageDlg('Fejl - forening kunne ikke oprettes!',mtError,[mbOk],0);
        ZQueryAfdDef.CancelUpdates;
        Exit;
      end;
    end;
end;


//**********************************************************
// Indlaes land
//**********************************************************
Procedure TSkiftForeningForm.IndlaesLand;
Var A : Integer;
Begin
  ZQuery2.Close;
  With ZQuery2.SQL do
    Begin
      Clear;
      Add('Select * from land');
    End;
  ZQuery2.Open;
  If ZQuery2.RecordCount = 0 Then
    Begin
      MessageDlg('Intet land endnu!',mtInformation,[mbOk],0);
      Exit;
    end;
  ZQuery2.First;
  A := 0;
  While Not ZQuery2.EOF Do
    Begin
      LandCombo.AddRow;
      LandCombo.Cells[0,A] := ZQuery2.FieldByName('LandForKort').asString;
      LandCombo.Cells[1,A] := ZQuery2.FieldByName('Land').asString;
      LandCombo.Cells[2,A] := ZQuery2.FieldByName('LandKode').asString;
      LandCombo1.AddRow;
      LandCombo1.Cells[0,A] := ZQuery2.FieldByName('LandForKort').asString;
      LandCombo1.Cells[1,A] := ZQuery2.FieldByName('Land').asString;
      LandCombo1.Cells[2,A] := ZQuery2.FieldByName('LandKode').asString;
      Inc(A);
      ZQuery2.Next;
    end;
  If ZQueryAfdDef.FieldByName('LandKode').isnull Then
    Begin
      LandCombo.ItemIndex := 0;
    end
  Else
    Begin
      LandCombo.ItemIndex := LandCombo.IndexInColumnOf(2,ZQueryAfdDef.FieldByName('LandKode').AsString);
    end;
  If ZQueryAfdDef.FieldByName('LandKodeDefault').isNull Then
    Begin
      LandCombo1.ItemIndex := 0;
    end
  Else
    Begin
      LandCombo1.ItemIndex := LandCombo1.IndexInColumnOf(2,ZQueryAfdDef.FieldByName('LandKodeDefault').AsString);
    end;
end;

//**********************************************************
// Indlæs periode
//**********************************************************
procedure TSkiftForeningForm.IndlaesPeriode;
Var A : Integer;
Begin
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from PeriodeDef where Afd = ' + CurrentAfd);
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount = 0 Then
    Begin
      // StringGrid1.RowCount  := 1;
      MessageDlg('Perioder ikke defineret!',mtInformation,[mbOk],0);
      Exit;
    end;

  ComboPeriode.Items.Clear;
  ZQuery1.First;
  A := 0;
  While Not ZQuery1.EOF Do
    Begin
      If ZQuery1.FieldByName('Afd').AsString = CurrentAfd Then
        Begin
          ComboPeriode.AddRow;
          ComboPeriode.Cells[0,A] := ZQuery1.FieldByName('Periode').AsString;
          ComboPeriode.Cells[1,A] := ZQuery1.FieldByName('Nr').AsString;
          Inc(A);
        end;
      ZQuery1.Next;
    end;
  If ComboPeriode.Items.Count > 0 Then
    Begin
      { TODO : Kassekladde: indstil til valgt periode }
      ComboPeriode.ItemIndex:=0;
    end
  Else
    Begin
      MessageDlg('Ingen periode defineret',mtError,[mbOk],0);
      Exit;
    end;
End;

end.

