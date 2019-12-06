//***************************************************************************//
//  Holbæk                                                                   //
//  Copyright by Claus Moeller 2013-2019                                     //
//  Medlemsoplysninger                                                       //
//  Version                                                                  //
//  22.11.19                                                                 //
//***************************************************************************//
unit medoply;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls,
  Menus, ActnList, ExtCtrls, DbCtrls, StdCtrls, Buttons, Grids,
  clmCombobox, db, ZDataset, JDBLabeledEdit,
  JLabeledDateEdit;

type

  { TMedlemForm }

  TMedlemForm = class(TForm)
    Find: TAction;
    BitBtnMaerke: TBitBtn;
    clmMaerkeCombobox: TclmCombobox;
    DBBrugerNr: TDBEdit;
    DBSpec1: TDBEdit;
    DBSpec2: TDBEdit;
    DBSpec3: TDBEdit;
    DBSpec4: TDBEdit;
    DBMobil: TDBEdit;
    DBRadioKoen: TDBRadioGroup;
    EditEmail: TEdit;
    DBEditFax: TJDBLabeledEdit;
    DBEditMobil: TJDBLabeledEdit;
    DBMedlemSiden: TJLabeledDateEdit;
    DBUdmeldt: TJLabeledDateEdit;
    DBFoedselsdag: TJLabeledDateEdit;
    DateEditMaerke: TJLabeledDateEdit;
    Label2: TLabel;
    AlderLabel: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    Special_Tab: TTabSheet;
    SpeedEmail: TSpeedButton;
    StringGrid1: TStringGrid;
    StringGrid2: TStringGrid;
    ToolButton4: TToolButton;
    UdmeldtNulstil: TAction;
    ActionList1: TActionList;
    DBPostNr: TDBEdit;
    DBCity: TDBText;
    LandCombo: TclmCombobox;
    Datasource1: TDatasource;
    DBFornavn: TDBEdit;
    DBEfternavn: TDBEdit;
    DBAdr1: TDBEdit;
    DBAdr2: TDBEdit;
    DBTlf: TDBEdit;
    DBNavigator1: TDBNavigator;
    DBText1: TDBText;
    Help: TAction;
    ImageList1: TImageList;
    Label1: TLabel;
    LabelTlf: TLabel;
    Luk: TAction;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    PageControl1: TPageControl;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    PopupMenu1: TPopupMenu;
    PopupUdmeldt: TPopupMenu;
    StatusBar1: TStatusBar;
    Aktiviteter: TTabSheet;
    Maerke_Tab: TTabSheet;
    NytMaerke_Tab: TTabSheet;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    Udskriv: TAction;
    ZQuery1: TZQuery;
    ZQuery2: TZQuery;
    ZQuery3: TZQuery;
    ZQueryMedlem: TZQuery;
    ZQueryPostNr: TZQuery;
    procedure BitBtnMaerkeClick(Sender: TObject);
    procedure DBFoedselsdagEditingDone(Sender: TObject);
    procedure DBMedlemSidenEditingDone(Sender: TObject);
    procedure DBNavigator1Click(Sender: TObject; Button: TDBNavButtonType);
    procedure DBPostNrExit(Sender: TObject);
    procedure DBUdmeldtEditingDone(Sender: TObject);
    procedure FindExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure LandComboEditingDone(Sender: TObject);
    procedure LukExecute(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure SpeedEmailClick(Sender: TObject);
    procedure UdmeldtNulstilExecute(Sender: TObject);
    procedure ZQueryMedlemApplyUpdateError(DataSet: TDataSet;
      E: EDatabaseError; var DataAction: TDataAction);
    procedure ZQueryMedlemCalcFields(DataSet: TDataSet);
  private
    { private declarations }
    AfdDefListeKort   : TStringList; { Indeholder Kort navn på alle klubber }
    AfdDefListe       : TStringList;

    procedure Indlaes;
    procedure IndlaesLand;
    procedure IndstilAktivitet;
    procedure IndstilMarks;
    procedure IndstilNytMaerke;
    procedure IndlaesForening;
    procedure NytMedlem;
    procedure UpdateAlder;
    procedure UpdateAktiviteter;
    procedure UpdateMarks;
    procedure UpdateEmails;
    procedure UpdateAll;

  public
    { public declarations }
  end;

var
  MedlemForm: TMedlemForm;

implementation

{$R *.lfm}

Uses Holbaekconst, MainData, DateUtils, MedlemEmailOversigt,
     SoegMed;


Const
  OplAfd          : Integer = 0;
  OplAktiv        : Integer = 1;
  OplAktivitet    : Integer = 2;
  OplPrisKategori : Integer = 3;
  OplPris         : Integer = 4;
  OplAfdDef       : Integer = 5;
  OplBaneDefnr    : Integer = 6;
  OplMedlemsNr    : Integer = 7;
  OplPrisType     : Integer = 8;

  MarkDato        : Integer = 0;
  MarkBeskrivelse : Integer = 1;
  MarkNr          : Integer = 2;



  { TMedlemForm }

//**********************************************************
// Create
//**********************************************************
procedure TMedlemForm.FormCreate(Sender: TObject);
begin
  Position := poDesigned;
//  Top := 10;
//  Left := 30;
  // Farver
  ToolBar1.Color                 := H_Menu_knapper_Farve;
//  StatusBar1.Color  := H_Menu_knapper_Farve;;
  Color                          := H_Window_Baggrund;
  // Panel1.Color                   := H_Panel;
  DBFornavn.Color                := H_Edit_Baggrund;
  DBEfternavn.Color              := H_Edit_Baggrund;
  DBAdr1.Color                   := H_Edit_Baggrund;
  DBAdr2.Color                   := H_Edit_Baggrund;
  DBTlf.Color                    := H_Edit_Baggrund;
  DBMobil.Color                  := H_Edit_Baggrund;
  LandCombo.Color                := H_Combo_Color;
  DBPostNr.Color                 := H_Edit_Baggrund;
  DBFoedselsdag.Color            := H_Edit_Baggrund;
  DBMedlemSiden.Color            := H_Edit_Baggrund;
  DBUdmeldt.Color                := H_Edit_Baggrund;
  DBBrugerNr.Color               := H_Edit_Baggrund;
  DBSpec1.Color                  := H_Edit_Baggrund;
  DBSpec2.Color                  := H_Edit_Baggrund;
  DBSpec3.Color                  := H_Edit_Baggrund;
  DBSpec4.Color                  := H_Edit_Baggrund;
  EditEmail.Color                := H_Edit_Baggrund;
  DBEditFax.Color                := H_Edit_Baggrund;
  DBEditMobil.Color              := H_Edit_Baggrund;
  clmMaerkeCombobox.Color        := H_Combo_Color;
  DateEditMaerke.Color           := H_Edit_Baggrund;
//  Panel_Aktiviteter.Color        := H_Menu_knapper_Farve;
  // Database
  ZQueryMedlem.Connection := MainDataModule.ZConnection1;
  ZQueryPostnr.Connection := MainDataModule.ZConnection1;
  ZQuery1.Connection      := MainDataModule.ZConnection1;
  ZQuery2.Connection      := MainDataModule.ZConnection1;
  ZQuery3.Connection      := MainDataModule.ZConnection1;
  // Init
  AfdDefListeKort    := TStringList.Create;
  AfdDefListeKort.Sorted := False; { Ikke sorteret }
  AfdDefListe        := TStringList.Create;
  AfdDefListe.Sorted := False; { Ikke sorteret }
  IndlaesForening;
  IndstilAktivitet;
  IndstilMarks;
  IndlaesLand;
  Indlaes;
  // Dato felter

  // Andet
  UpdateAll;
end;

//**********************************************************
// Destroy
//**********************************************************
procedure TMedlemForm.FormDestroy(Sender: TObject);
begin
  AfdDefListeKort.Free;
  AfdDefListe.Free;
end;

//**********************************************************
// Land ændret
//**********************************************************
procedure TMedlemForm.LandComboEditingDone(Sender: TObject);
begin
  // Land gemmes under medlem
  ZQueryMedlem.Edit;
  ZQueryMedlem.FieldByName('LandKode').AsString:=
    LandCombo.Cells[2,LandCombo.ItemIndex];
  ZQueryMedlem.Post;
end;

//**********************************************************
// Indlaes forening
//**********************************************************
procedure TMedlemForm.IndlaesForening;
Var NrIListe : Integer;
Begin
  // Navnene på klubberne indlæses
  ZQuery1.Close;
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from AfdDef');
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount > 0 Then
    Begin
      While not ZQuery1.EOF Do
        Begin
          NrIListe := AfdDefListe.Add(ZQuery1.FieldByName('Afd').AsString);
          AfdDefListeKort.Insert(NrIListe,ZQuery1.FieldByName('KortNavn').AsString);
          ZQuery1.Next;
        end;
    end;
End;

//**********************************************************
// Luk
//**********************************************************
procedure TMedlemForm.LukExecute(Sender: TObject);
begin
  Close;
end;

//**********************************************************
// Page change
//**********************************************************
procedure TMedlemForm.PageControl1Change(Sender: TObject);
begin
  If PageControl1.ActivePageIndex = 3 Then
    Begin // Special
    end
  Else If PageControl1.ActivePageIndex = 2 Then
    Begin // Nyt Maerke
      IndstilNytMaerke;
    end
  Else If PageControl1.ActivePageIndex = 1 Then
    Begin // Maerke
      UpdateMarks;
    end;
end;


//**********************************************************
// Vælg email
//**********************************************************
procedure TMedlemForm.SpeedEmailClick(Sender: TObject);
begin
  MedlemEmailForm := TMedlemEmailForm.Create(self);
  MedlemEmailForm.MedlemsNr := ZQueryMedlem.FieldByName('MedlemsNr').AsInteger;
  MedlemEmailForm.MedlemNavn := ZQueryMedlem.FieldByName('Fornavn').AsString +
    ' ' + ZQueryMedlem.FieldByName('Efternavn').AsString;
  MedlemEmailForm.IndlaesEmails;
  MedlemEmailForm.ShowModal;
  MedlemEmailForm.Free;
end;

//**********************************************************
// Ikke udmeldt
//**********************************************************
procedure TMedlemForm.UdmeldtNulstilExecute(Sender: TObject);
begin
  ZQueryMedlem.Edit;
  ZQueryMedlem.FieldByName('Udmeldtd').Clear;
  ZQueryMedlem.Post;
  ZQueryMedlem.ApplyUpdates;
end;

procedure TMedlemForm.ZQueryMedlemApplyUpdateError(DataSet: TDataSet;
  E: EDatabaseError; var DataAction: TDataAction);
begin

end;

procedure TMedlemForm.ZQueryMedlemCalcFields(DataSet: TDataSet);
begin

end;

//**********************************************************
// Update alder
//**********************************************************
procedure TMedlemForm.UpdateAlder;
begin
  If not ZQueryMedlem.FieldByName('Foedselsdato').IsNull Then
    Begin
      AlderLabel.Caption := IntToStr(YearsBetween(Now,
        JulianDateToDateTime(ZQueryMedlem.FieldByName('Foedselsdato').AsFloat)));
    End
  Else
    Begin
      AlderLabel.Caption := '??';
    End;
end;

//**********************************************************
// UpdateEmails
//**********************************************************
procedure TMedlemForm.UpdateEmails;
Var HelpStr : String;
Begin
  // Indlæs emails
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from MedlemEmail where medlemsnr = ' +
        ZQueryMedlem.FieldByName('MedlemsNr').AsString);
    End;
  ZQuery1.Open;
  HelpStr := '';
  ZQuery1.First;
  While Not ZQuery1.EOF Do
    Begin
      HelpStr := HelpStr + ZQuery1.FieldByName('Email').AsString + ';';
      ZQuery1.Next;
    end;
  EditEmail.Caption := HelpStr;
end;


//**********************************************************
// Navigator
//**********************************************************
procedure TMedlemForm.DBNavigator1Click(Sender: TObject;
  Button: TDBNavButtonType);
begin
(*  nbFirst, nbPrior, nbNext, nbLast,
                  nbInsert, nbDelete, nbEdit, nbPost, nbCancel, nbRefresh);*)
  If Button = nbPost Then
    Begin
      inherited;
      If Not DBFoedselsdag.isNull Then
        Begin
          ZQueryMedlem.Edit;
          ZQueryMedlem.FieldByName('Foedselsdato').AsFloat := DateTimeToJulianDate(DBFoedselsdag.Value);
          ZQueryMedlem.Post;
        end;
      If Not DBMedlemSiden.isNull Then
        Begin
          ZQueryMedlem.Edit;
          ZQueryMedlem.FieldByName('MedlemSiden').AsFloat := DateTimeToJulianDate(DBMedlemSiden.Value);
          ZQueryMedlem.Post;
        end;
      If Not DBUdmeldt.isNull Then
        Begin
          ZQueryMedlem.Edit;
          ZQueryMedlem.FieldByName('Udmeldtd').AsFloat := DateTimeToJulianDate(DBUdmeldt.Value);
          ZQueryMedlem.Post;
        end;
    end
  Else If Button = nbDelete Then
    Begin
      //ShowMessage('Delete');
    end
  Else If Button = nbNext Then
    Begin
      UpdateAll;
    end
  Else If Button = nbPrior Then
    Begin
      UpdateAll;
    end
  Else If Button = nbLast Then
    Begin
      UpdateAll;
    end
  Else If Button = nbFirst Then
    Begin
      UpdateAll;
    end
  Else If Button = nbInsert Then
    Begin // New member
      NytMedlem;
    end;
end;

//**********************************************************
// Foedseldag editing done
//**********************************************************
procedure TMedlemForm.DBFoedselsdagEditingDone(Sender: TObject);
begin
  ZQueryMedlem.Edit;
end;

//**********************************************************
// Indsæt mærke
//**********************************************************
procedure TMedlemForm.BitBtnMaerkeClick(Sender: TObject);
begin
  // Undersøg om mærke er på medlem
  ZQuery1.Close;
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from marks where (medlemsnr = ' +
         ZQueryMedlem.FieldByName('MedlemsNr').AsString + ') and (Markid = ' +
         clmMaerkeCombobox.Cells[1,clmMaerkeCombobox.ItemIndex] + ')');
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount > 0 Then
    Begin // Medlem har mærke
      If MessageDlg('Medlem har mærke. Skal dato opdateres?',mtConfirmation,[mbYes,mbNo],0) = MrYes Then
        Begin
          Try
            ZQuery1.Edit;
            ZQuery1.FieldByName('Dato').AsFloat := DateTimeToJulianDate(Now);
            ZQuery1.Post;
            ZQuery1.ApplyUpdates;
          Except
            Exit;
          end;
        End;
    End
  Else
    Begin // Indsæt mærke
      ZQuery1.Close;
      With ZQuery1.SQL do
        Begin
          Clear;
          Add('Select * from marks');
        End;
      ZQuery1.Open;
      ZQuery1.Append;
      ZQuery1.Edit;
      ZQuery1.FieldByName('MarkId').AsString     := clmMaerkeCombobox.Cells[1,clmMaerkeCombobox.ItemIndex];
      ZQuery1.FieldByName('Dato').AsFloat        := DateTimeToJulianDate(DateEditMaerke.Value);
      ZQuery1.FieldByName('Medlemsnr').AsString  := ZQueryMedlem.FieldByName('MedlemsNr').AsString;
      ZQuery1.Post;
      ZQuery1.ApplyUpdates;
    end;
end;

//**********************************************************
// MedlemSiden editing done
//**********************************************************
procedure TMedlemForm.DBMedlemSidenEditingDone(Sender: TObject);
begin
  DBFoedselsdagEditingDone(Sender);
end;

//**********************************************************
// UpdateAll
//**********************************************************
procedure TMedlemForm.UpdateAll;
Begin
  UpdateAlder;
  UpdateAktiviteter;
  UpdateMarks;
  UpdateEmails;
  If ZQueryMedlem.FieldByName('Foedselsdato').AsFloat <> 0 Then
    DBFoedselsdag.Value := JulianDateToDateTime(ZQueryMedlem.FieldByName('Foedselsdato').AsFloat)
  Else
    DBFoedselsdag.clear;
End;


//**********************************************************
// PostNr - exit
//**********************************************************
procedure TMedlemForm.DBPostNrExit(Sender: TObject);
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
      ZQueryMedlem.Edit;
      ZQueryMedlem.FieldByName('PostNr').Clear;
      ZQueryMedlem.Post;
      DBPostNr.SetFocus;
      Exit;
    End;
  // Indsæt city
  Try
    ZQueryMedlem.Edit;
    ZQueryMedlem.FieldByName('City').AsString:= ZQueryPostNr.FieldByName('Town').AsString;
    ZQueryMedlem.Post;
  Except
    MessageDlg('By kunne ikke opdateres!',mtError,[mbOk],0);
    Exit;
  end;
end;

//**********************************************************
// Udmeldt editing done
//**********************************************************
procedure TMedlemForm.DBUdmeldtEditingDone(Sender: TObject);
begin
  DBFoedselsdagEditingDone(Sender);
end;

//**********************************************************
// Find
//**********************************************************
procedure TMedlemForm.FindExecute(Sender: TObject);
begin
  Cursor := crHourGlass;
  { Check if instance of for exists }
  if not Assigned(MedlemSoegForm) then
   { Create the form instance }
   Begin
     MedlemSoegForm := TMedlemSoegForm.Create(Self);
     MedlemSoegForm.Mode := 0;
   End;
  If Application.MainForm.Width > (MedlemSoegForm.Width + MedlemForm.Width) Then
   Begin // De kan stå ved siden af hinanden
     MedlemSoegForm.Left := MedlemForm.Width + 1;
   End
  Else
   Begin
     MedlemSoegForm.Left := Application.MainForm.Width - MedlemSoegForm.Width;
   End;
  MedlemSoegForm.Show;

(*  MedlemSoegForm := TMedlemSoegForm.Create(Self);
  MedlemSoegForm.ShowModal;
  MedlemSoegForm.Close;*)
end;

//**********************************************************
// Indlaes
//**********************************************************
procedure TMedlemForm.Indlaes;
Begin
  With ZQueryMedlem.SQL do
    Begin
      Clear;
      Add('Select * from medlem');
    End;
  ZQueryMedlem.Open;
  If ZQueryMedlem.RecordCount = 0 Then
    Begin
      MessageDlg('Ingen medlemmer defineret!',mtInformation,[mbOk],0);
      Exit;
    end;
end;
//**********************************************************
// Indlaes land
//**********************************************************
Procedure TMedlemForm.IndlaesLand;
Var A : Integer;
Begin
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from land');
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount = 0 Then
    Begin
      MessageDlg('Intet land endnu!',mtInformation,[mbOk],0);
      Exit;
    end;
  ZQuery1.First;
  A := 0;
  While Not ZQuery1.EOF Do
    Begin
      LandCombo.AddRow;
      LandCombo.Cells[0,A] := ZQuery1.FieldByName('LandForKort').asString;
      LandCombo.Cells[1,A] := ZQuery1.FieldByName('Land').asString;
      LandCombo.Cells[2,A] := ZQuery1.FieldByName('LandKode').asString;
      Inc(A);
      ZQuery1.Next;
    end;
  LandCombo.ItemIndex := 0;
end;

//**********************************************************
// Nyt medlem
//**********************************************************
Procedure TMedlemForm.NytMedlem;
begin
  Try
    ZQueryMedlem.Append;
    ZQueryMedlem.Edit;
    ZQueryMedlem.FieldByName('Fornavn').AsString         := 'Firstname';
    ZQueryMedlem.FieldByName('Efternavn').AsString       := 'Surname';
    ZQueryMedlem.FieldByName('Foedselsdato').AsFloat     := DateTimeToJulianDate(Now);
    ZQueryMedlem.FieldByName('MedlemSiden').AsFloat      := DateTimeToJulianDate(Now);
    ZQueryMedlem.FieldByName('Udmeldtd').Clear;
    // Gem
    ZQueryMedlem.Post;
    ZQueryMedlem.ApplyUpdates;
  Except
    MessageDlg('Medlem kunne ikke oprettes!',mtError,[mbOk],0);
    ZQueryMedlem.CancelUpdates;
    Exit;
  end;
 // Indlaes;
End;


(*
OplAfd          : Integer = 0;
OplAktiv        : Integer = 1;
OplAktivitet    : Integer = 2;
OplPrisKategori : Integer = 3;
OplPris         : Integer = 4;
OplAfdDef       : Integer = 5;
OplBaneDefnr    : Integer = 6;
OplMedlemsNr    : Integer = 7;
OplPrisType     : Integer = 8; *)


//**********************************************************
// Update aktiviteter
//**********************************************************
Procedure TMedlemForm.UpdateAktiviteter;
Var A        : Integer;
begin
  Exit;
  StringGrid1.RowCount := 1;
  A := 0;
  Try
    With ZQuery1.SQL do
      Begin
        Clear;
        Add('Select * from aktmed where (afd = ' + CurrentAfd +
            ') and (medlemsnr = ' + ZQueryMedlem.FieldByName('MedlemsNr').AsString + ')');
      End;
    ZQuery1.Open;
  Except
    Exit;
  end;
  If ZQuery1.RecordCount = 0 Then
    Begin
      Exit;
    End;
  While not ZQuery1.EOF do // Aktmed
    Begin
      With ZQuery2.SQL do // Aktiviteter
        Begin
          Clear;
          Add('Select * from aktiviteter where (afd =' + CurrentAfd +
              ') and (banedefnr = ' + ZQuery1.FieldByName('BaneDefNr').AsString + ')');
        End;
      ZQuery2.Open;
      if ZQuery2.FieldByName('Vis').AsString = '1' Then
        Begin // Hvis den skal vises aktiviteten
          With ZQuery3.SQL do // PrisKategori
            Begin
              Clear;
              Add('Select * from priskategori where (afd =' + CurrentAfd +
                  ') and (pristype = ' + ZQuery1.FieldByName('PrisType').AsString + ')');
            End;
          ZQuery3.Open;
          Inc(A);
          StringGrid1.RowCount := StringGrid1.RowCount + 1;
          With StringGrid1 do
            begin
              Cells[OplAfd,A] := AfdDefListeKort.Strings[
               AfdDefListe.IndexOf(CurrentAfd)];
              Cells[OplAktivitet,A] := ZQuery2.FieldByName('Beskrivelse').AsString;
              If ZQuery3.RecordCount > 0 Then
                Begin
                  Cells[OplPrisKategori,A] := ZQuery3.FieldByName('Beskrivelse').AsString;
                  Cells[OplPris,A] :=
                    FloatToStrF(ZQuery3.FieldByName('Pris').AsCurrency,ffNumber,18,2);
                end;
              Cells[OplAfdDef,A] := ZQuery1.FieldByName('Afd').AsString;
              Cells[OplBaneDefNr,A] :=
                ZQuery1.FieldByName('BaneDefnr').AsString;
              Cells[OplMedlemsNr,A] :=
                ZQuery1.FieldByName('Medlemsnr').AsString;
              Cells[OplPrisType,A] :=
                ZQuery1.FieldByName('PrisType').AsString;
             end;
        End;
      ZQuery1.Next;
    End;
  If StringGrid1.RowCount > 1 Then
    Begin
      StringGrid1.Row := 1;
//      Slet.Visible := True;
    End
  Else
    Begin
//      Slet.Visible := False;
    End;
end;

//**********************************************************
// Update marks
//**********************************************************
Procedure TMedlemForm.UpdateMarks;
Var A        : Integer;
begin
  StringGrid2.RowCount := 1;
  A := 0;
  ZQuery1.Close;
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from marks where (medlemsnr = ' +
         ZQueryMedlem.FieldByName('MedlemsNr').AsString + ')');
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount = 0 Then
    Begin
      Exit;
    End;
  While not ZQuery1.EOF do // Marks
    Begin
      With ZQuery2.SQL do // MarkDef
        Begin
          Clear;
          Add('Select * from markdef where (id = ' +
            ZQuery1.FieldByName('MarkId').AsString + ')');
        End;
      ZQuery2.Open;
      If ZQuery2.RecordCount > 0 Then
        Begin
          Inc(A);
          StringGrid2.RowCount := StringGrid2.RowCount + 1;
          With StringGrid2 do
            begin
              Cells[MarkDato,A]        := DateToStr(JulianDateToDateTime(ZQuery1.FieldByName('Dato').AsFloat));
              Cells[MarkBeskrivelse,A] := ZQuery2.FieldByName('Beskrivelse').AsString;
              Cells[MarkNr,A]          := ZQuery1.FieldByName('MarkId').AsString;
            End;
        end;
      ZQuery1.Next;
    End;
  If StringGrid2.RowCount > 1 Then
    Begin
      StringGrid2.Row := 1;
//      Slet.Visible := True;
    End
  Else
    Begin
//      Slet.Visible := False;
    End;
end;

//**********************************************************
// Indstil
//**********************************************************
procedure TMedlemForm.IndstilAktivitet;
begin
  Indstil_StringGrid_Edit(StringGrid1);

  StringGrid1.Columns.Clear;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;

  StringGrid1.Columns[OplAfd].Title.Caption            := 'Afd';
  StringGrid1.Columns[OplAfd].Width                    := 80;
  StringGrid1.Columns[OplAfd].Alignment                := taLeftJustify;

  StringGrid1.Columns[OplAktiv].Title.Caption          := '*';
  StringGrid1.Columns[OplAktiv].Width                  := 40;
  StringGrid1.Columns[OplAktiv].Alignment              := taCenter;

  StringGrid1.Columns[OplAktivitet].Title.Caption      := 'Aktivitet';
  StringGrid1.Columns[OplAktivitet].Width              := 200;
  StringGrid1.Columns[OplAktivitet].Alignment          := taLeftJustify;

  StringGrid1.Columns[OplPrisKategori].Title.Caption   := 'Priskategori';
  StringGrid1.Columns[OplPrisKategori].Width           := 200;
  StringGrid1.Columns[OplPrisKategori].Alignment       := taLeftJustify;

  StringGrid1.Columns[OplPris].Title.Caption           := 'Pris';
  StringGrid1.Columns[OplPris].Width                   := 100;
  StringGrid1.Columns[OplPris].Alignment               := taRightJustify;

  StringGrid1.Columns[OplAfdDef].Title.Caption         := 'AfdDEf';
  StringGrid1.Columns[OplAfdDef].Width                 := 100;
  StringGrid1.Columns[OplAfdDef].Alignment             := taLeftJustify;
  StringGrid1.Columns[OplAfdDef].Visible               := False;

  StringGrid1.Columns[OplBaneDefNr].Title.Caption      := 'Aktivitet';
  StringGrid1.Columns[OplBaneDefNr].Width              := 100;
  StringGrid1.Columns[OplBaneDefNr].Alignment          := taLeftJustify;
  StringGrid1.Columns[OplBaneDefNr].Visible            := False;

  StringGrid1.Columns[OplMedlemsNr].Title.Caption      := 'Aktivitet';
  StringGrid1.Columns[OplMedlemsNr].Width              := 100;
  StringGrid1.Columns[OplMedlemsNr].Alignment          := taLeftJustify;
  StringGrid1.Columns[OplMedlemsNr].Visible            := False;

  StringGrid1.Columns[OplPrisType].Title.Caption       := 'Aktivitet';
  StringGrid1.Columns[OplPrisType].Width               := 100;
  StringGrid1.Columns[OplPrisType].Alignment           := taLeftJustify;
  StringGrid1.Columns[OplPrisType].Visible             := False;

  StringGrid1.Options := [goRowSelect, goTabs];
end;

//**********************************************************
// Indstil mærke
//**********************************************************
procedure TMedlemForm.IndstilMarks;
begin
  Indstil_StringGrid_Edit(StringGrid2);

  StringGrid2.Columns.Clear;
  StringGrid2.Columns.Add;
  StringGrid2.Columns.Add;
  StringGrid2.Columns.Add;

  StringGrid2.Columns[MarkDato].Title.Caption            := 'Dato';
  StringGrid2.Columns[MarkDato].Width                    := 100;
  StringGrid2.Columns[MarkDato].Alignment                := taLeftJustify;

  StringGrid2.Columns[MarkBeskrivelse].Title.Caption     := 'Beskrivelse';
  StringGrid2.Columns[MarkBeskrivelse].Width             := 300;
  StringGrid2.Columns[MarkBeskrivelse].Alignment         := taLeftJustify;

  StringGrid2.Columns[MarkNr].Title.Caption              := '*';
  StringGrid2.Columns[MarkNr].Width                      := 200;
  StringGrid2.Columns[MarkNr].Alignment                  := taLeftJustify;
  StringGrid2.Columns[MarkNr].Visible                    := False;

  StringGrid2.Options := [goRowSelect, goTabs];
end;

//**********************************************************
// Indstil Nyt Maerke
//**********************************************************
procedure TMedlemForm.IndstilNytMaerke;
Var Nr : Integer;
begin
  DateEditMaerke.Value := Now;
  ZQuery2.Close;
  With ZQuery2.SQL do // MarkDef
    Begin
      Clear;
      Add('Select * from markdef');
    End;
  ZQuery2.Open;
  If ZQuery2.RecordCount > 0 Then
    Begin
      clmMaerkeCombobox.Items.Clear;
      Nr := 0;
      While not ZQuery2.EOF Do
        Begin
          clmMaerkeCombobox.AddRow;
          clmMaerkeCombobox.Cells[0,Nr] := ZQuery2.FieldByName('Beskrivelse').AsString;
          clmMaerkeCombobox.Cells[1,Nr] := ZQuery2.FieldByName('id').AsString;
          Inc(Nr);
          ZQuery2.Next;
        end;
      clmMaerkeCombobox.ItemIndex:=0;
    end;
End;

end.

