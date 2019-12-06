//***************************************************************************//
//  Holbæk                                                                   //
//  Copyright by Claus Moeller 2013-2014                                     //
//  Vig Foreningsprogram  - Show find                                        //
//  19.10.14
//***************************************************************************//
unit ShowFind;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  Grids, ActnList, Menus, ExtCtrls, StdCtrls, ZDataset, IniFiles;

type
  PShowFindResultDefListType = ^TShowFindResultDefListType;
  TShowFindResultDefListType = Record
    NrIDef      : Integer;
    PrintNavn   : String;
    Laengde     : Integer;
    Valgt       : Boolean;
    Nr          : Integer;
  End;

  { TShowFindForm }

  TShowFindForm = class(TForm)
    Action1: TAction;
    Action2: TAction;
    Action3: TAction;
    Action4: TAction;
    Action5: TAction;
    Action6: TAction;
    Indstillinger: TAction;
    Label1: TLabel;
    AntalMaendLabel: TLabel;
    Label2: TLabel;
    AntalKvinderLabel: TLabel;
    Label4: TLabel;
    AntalFlereLabel: TLabel;
    ToolButton11: TToolButton;
    ToolButton12: TToolButton;
    ToolButton13: TToolButton;
    ToolButton14: TToolButton;
    ToolButton15: TToolButton;
    ToolButton16: TToolButton;
    ToolButton17: TToolButton;
    ToolButton18: TToolButton;
    ToolButton19: TToolButton;
    Udmeldt: TAction;
    AktivitetTildeling: TAction;
    SletMedlemmer: TAction;
    FjernRaekke: TAction;
    SaetMaerke: TAction;
    SaveDialog1: TSaveDialog;
    Save_File: TAction;
    ActionList1: TActionList;
    Help: TAction;
    ImageList1: TImageList;
    Luk: TAction;
    MenuItem1: TMenuItem;
    ToolButton10: TToolButton;
    ToolButton4: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    Udskriv: TAction;
    Panel1: TPanel;
    PopupMenu1: TPopupMenu;
    Sum_Panel_Color: TShape;
    Slet: TAction;
    StringGrid1: TStringGrid;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton5: TToolButton;
    ZQuery1: TZQuery;
    ZQueryMedlem: TZQuery;
    ZTable1: TZTable;
    procedure Action1Execute(Sender: TObject);
    procedure Action2Execute(Sender: TObject);
    procedure Action3Execute(Sender: TObject);
    procedure Action4Execute(Sender: TObject);
    procedure Action5Execute(Sender: TObject);
    procedure Action6Execute(Sender: TObject);
    procedure AktivitetTildelingExecute(Sender: TObject);
    procedure FjernRaekkeExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure HelpExecute(Sender: TObject);
    procedure IndstillingerExecute(Sender: TObject);
    procedure LukExecute(Sender: TObject);
    procedure SaetMaerkeExecute(Sender: TObject);
    procedure Save_FileExecute(Sender: TObject);
    procedure SletMedlemmerExecute(Sender: TObject);
    procedure UdmeldtExecute(Sender: TObject);
    procedure UdskrivExecute(Sender: TObject);
  private
    { private declarations }
    AntalMaend   : Integer;
    AntalKvinder : Integer;
    AntalFlere   : Integer;
    RowToSave    : Integer;
    procedure SaetHelp;
  public
    { public declarations }
    ResultDefListe : TList;
    IniFile        : TInifile;
    NrFilter       : Integer;
    procedure ReadData;
    procedure IndlaesIGrid(Nr : Integer);
  end;

var
  ShowFindForm: TShowFindForm;

implementation

{$R *.lfm}

Uses HolbaekConst, HolbaekMain, FindMed, DB, SuperPrint, MarkVaelg,
     Aktivitet_Masse, Medlem_Udmeldt, ShowFind_Def, MainData;

{ TShowFindForm }

//**********************************************************
// Create
//**********************************************************
procedure TShowFindForm.FormCreate(Sender: TObject);
begin
  Top  := 10;
  Left := 30;
  ShowHint := True;
  // Farver
  Color             := H_Window_Baggrund;
  ToolBar1.Color    := H_Menu_knapper_Farve;
  Sum_Panel_Color.Color := H_Menu_knapper_Farve;;
  Indstil_StringGrid_NonEdit(StringGrid1);
  // Database
  ZTable1.Connection      := MainData.MainDataModule.ZConnection1;
  ZQueryMedlem.Connection := MainData.MainDataModule.ZConnection1;
  ZQuery1.Connection      := MainData.MainDataModule.ZConnection1;

  // Lister
  ResultDefListe := TList.Create;
  // Data til visning af liste
  ReadData;
  SaetHelp;
end;

//**********************************************************
// Fjern en række
//**********************************************************
procedure TShowFindForm.FjernRaekkeExecute(Sender: TObject);
Var A : Integer;
begin
  A := StringGrid1.Selection.Bottom;
  For A := StringGrid1.Selection.Bottom DownTo StringGrid1.Selection.Top Do
    Begin
      StringGrid1.DeleteRow(A);
    end;
end;

//**********************************************************
// Massetildeling
//**********************************************************
procedure TShowFindForm.AktivitetTildelingExecute(Sender: TObject);
Var A : Integer;
begin
  AktivitetMasseForm := TAktivitetMasseForm.Create(Self);
  For A := 1 to StringGrid1.RowCount-1 Do
    Begin
      AktivitetMasseForm.ResultListe.Add(StringGrid1.Cells[0,A]);
    End;
  AktivitetMasseForm.IndlaesTilFra;
  AktivitetMasseForm.ShowModal;
  AktivitetMasseForm.Free;
end;

//**********************************************************
// Destroy
//**********************************************************
procedure TShowFindForm.FormDestroy(Sender: TObject);
begin
  ResultDefListe.Free;
end;

//**********************************************************
// Hjælp
//**********************************************************
procedure TShowFindForm.HelpExecute(Sender: TObject);
begin
  ShowMessage('Help');
end;

//**********************************************************
// Indstillinger
//**********************************************************
procedure TShowFindForm.IndstillingerExecute(Sender: TObject);
begin
  ShowFindDefForm := TShowFindDefForm.Create(Self);
  ShowFindDefForm.ShowModal;
  ShowFindDefForm.Free;
//  SaetHelp;

end;

//**********************************************************
// Luk
//**********************************************************
procedure TShowFindForm.LukExecute(Sender: TObject);
begin
  Close;
end;

//**********************************************************
// Sæt eller slet mærke(r)
//**********************************************************
procedure TShowFindForm.SaetMaerkeExecute(Sender: TObject);
begin
  Mark_Vaelg := TMark_Vaelg.Create(Self);
  Mark_Vaelg.ShowModal;
  Mark_Vaelg.Free;
end;

//**********************************************************
// Gem til fil
//**********************************************************
procedure TShowFindForm.Save_FileExecute(Sender: TObject);
begin
  ShowMessage('Gem til fil');
  SaveDialog1.Filter:= 'Komma separeret|*.csv|Tekst fil|*.txt';
  SaveDialog1.InitialDir := Options_Alias_Data;
  SaveDialog1.Title      := 'Gem rapport som...';
  SaveDialog1.FileName   := 'ShowFind' + DateToStr(Now);
  If SaveDialog1.Execute Then
    Begin
      If SaveDialog1.FilterIndex = 0 Then
        StringGrid1.SaveToCSVFile(SaveDialog1.FileName,',',False,False)
      Else
        StringGrid1.SaveToFile(SaveDialog1.FileName);
    End;
end;


//**********************************************************
// Sæt Help
//**********************************************************
procedure TShowFindForm.SaetHelp;
Var HelpStr : String;
    A       : Integer;
Begin
  IniFile := TIniFile.Create(HolbaekIniFile);
  For A := 1 To 6 Do
    Begin
      HelpStr := IniFile.ReadString('ShowFindMed',IntToStr(A) + 'Help','');
      If HelpStr <> '' Then
        Begin
          Case A of
            1 : Begin
                  Action1.Hint := HelpStr;
                End;
            2 : Begin
                  Action2.Hint := HelpStr;
                End;
            3 : Begin
                  Action3.Hint := HelpStr;
                End;
            4 : Begin
                  Action4.Hint := HelpStr;
                End;
            5 : Begin
                  Action5.Hint := HelpStr;
                End;
            6 : Begin
                  Action6.Hint := HelpStr;
                End;
          End; // End Case
        End;
    End;
  IniFile.Free;
End;



//**********************************************************
// Slet medlemmer
//**********************************************************
procedure TShowFindForm.SletMedlemmerExecute(Sender: TObject);
begin
  ShowMessage('Slet medlemmer');
end;

//**********************************************************
// Udmeld
//**********************************************************
procedure TShowFindForm.UdmeldtExecute(Sender: TObject);
Var A : Integer;
    NrAendret : Integer;
begin
  MedlemUdmeldtForm := TMedlemUdmeldtForm.Create(Self);
  A         := 1;
  NrAendret := 0;
  If MedlemUdmeldtForm.ShowModal = mrOk Then
    Begin
      While A < StringGrid1.RowCount do
        Begin
          With ZQueryMedlem.SQL do
            Begin
              Clear;
              Add('Select * from medlem where medlemsnr = ' + StringGrid1.Cells[0,A]);
            End;
          ZQueryMedlem.Open;
          If ZQueryMedlem.RecordCount = 0 Then
            Begin // Fejl medlem kunne ikke findes
              Exit;
            End;
          // Sæt
          ZQueryMedlem.Edit;
          Case MedlemUdmeldtForm.RadioGroup1.ItemIndex of
            0 : Begin
                  ZQueryMedlem.FieldByName('UdmeldtD').AsString := '';
                End;
            1 : Begin
                  ZQueryMedlem.FieldByName('UdmeldtD').AsDateTime := MedlemUdmeldtForm.DateEdit1.Value;
                End;
          End; // End Case
          Try
            ZQueryMedlem.Post;
            Inc(NrAendret);
          Except
            MessageDlg(ZQueryMedlem.FieldByName('Fornavn').AsString + ' ' +
             ZQueryMedlem.FieldByName('Efternavn').AsString + ' kan ikke ændre udmeldt status?',
             mtWarning,[mbYes],0);
          End;
          Inc(A);
        End;
      MessageDlg('Der blev ændret ' + IntToStr(NrAendret) + ' medlemmer', mtInformation,
        [mbOk],0);
//      IndlaesIGrid(NrFilter);
    End;
end;

//**********************************************************
// Udskriv
//**********************************************************
procedure TShowFindForm.UdskrivExecute(Sender: TObject);
Var A       : Integer;
    HelpNr  : Integer;

begin
  // Lav database med udskrifts database
  // Findes den - så slet
  ZTable1.TableName := 'udskriv';
  If ZTable1.Exists Then
    Begin // Drop Table
      Try
        With ZQuery1.SQL do
          Begin
            Clear;
            Add('drop table udskriv')
          end;
        ZQuery1.ExecSQL;
      finally
      end;
    end;
  // Lav ny udskriv tabel med disse data
  Try
    With ZQuery1.SQL do
      Begin
        Clear;
        Add('CREATE TABLE udskriv (');
        Add('  nr  INTEGER NOT NULL PRIMARY KEY,');
        Add('  afd INTEGER NOT NULL,');
        // Medlem
        Add('  medlemsnr INTEGER,');
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
        Add('  foedselsdato TIMESTAMP,');
        Add('  medlemsiden TIMESTAMP,');
        Add('  mand INTEGER,');
        Add('  spec1 VARCHAR(40),');
        Add('  spec2 VARCHAR(40),');
        Add('  spec3 VARCHAR(40),');
        Add('  spec4 VARCHAR(40),');
        Add('  beskrivelse BLOB SUB_TYPE 1 SEGMENT SIZE 255,');
        Add('  vaerge INTEGER,');
        Add('  vaergebetal CHAR(1),');
        Add('  billedtype INTEGER,');
        Add('  billed BLOB,');
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
        Add('  udmeldtd TIMESTAMP');
        Add(')');
      end;
    ZQuery1.ExecSQL;
  Except
    on E: EDatabaseError do
      begin
        MessageDlg('Error', 'A database error has occurred. Technical error message: ' +
            E.Message, mtError, [mbOK], 0);
      end;
  end;
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from udskriv')
    end;
  ZQuery1.Open;
  HelpNr := 1;
  // Indsæt data i tabel
  A := 1;
  While A < StringGrid1.RowCount Do
    Begin
      Try
        ZQuery1.Append;
        ZQuery1.Edit;
        ZQuery1.FieldByName('Nr').AsInteger           := HelpNr;
        ZQuery1.FieldByName('Afd').AsString           := CurrentAfd;
//        ZQuery1.FieldByName('periode').AsString       := ComboPeriode.Items[ComboPeriode.ItemIndex];
        // Medlem findes
        With ZQueryMedlem.SQL do
          Begin
            Clear;
            Add('Select * from medlem where medlemsnr = ' + StringGrid1.Cells[0,A]);
          End;
        ZQueryMedlem.Open;
        If ZQueryMedlem.RecordCount > 0 Then
          Begin // Medlem fundet
            ZQuery1.FieldByName('medlemsnr').AsString   :=
              ZQueryMedlem.FieldByName('medlemsnr').AsString;
            ZQuery1.FieldByName('brugermedlemsnr').AsString   :=
              ZQueryMedlem.FieldByName('brugermedlemsnr').AsString;
            ZQuery1.FieldByName('fornavn').AsString   :=
              ZQueryMedlem.FieldByName('fornavn').AsString;
            ZQuery1.FieldByName('efternavn').AsString   :=
              ZQueryMedlem.FieldByName('efternavn').AsString;
            ZQuery1.FieldByName('Adr1').AsString   :=
              ZQueryMedlem.FieldByName('Adr1').AsString;
            ZQuery1.FieldByName('Adr2').AsString   :=
              ZQueryMedlem.FieldByName('Adr2').AsString;
            ZQuery1.FieldByName('landkode').AsString   :=
              ZQueryMedlem.FieldByName('landkode').AsString;
            ZQuery1.FieldByName('postnr').AsString   :=
              ZQueryMedlem.FieldByName('postnr').AsString;
            ZQuery1.FieldByName('city').AsString   :=
              ZQueryMedlem.FieldByName('city').AsString;
            ZQuery1.FieldByName('telefon').AsString   :=
              ZQueryMedlem.FieldByName('telefon').AsString;
            ZQuery1.FieldByName('fax').AsString   :=
              ZQueryMedlem.FieldByName('fax').AsString;
            ZQuery1.FieldByName('mobiltlfnr').AsString   :=
              ZQueryMedlem.FieldByName('mobiltlfnr').AsString;
            ZQuery1.FieldByName('foedselsdato').AsString   :=
              ZQueryMedlem.FieldByName('foedselsdato').AsString;
            ZQuery1.FieldByName('medlemsiden').AsString   :=
              ZQueryMedlem.FieldByName('medlemsiden').AsString;
            ZQuery1.FieldByName('mand').AsString   :=
              ZQueryMedlem.FieldByName('mand').AsString;
            ZQuery1.FieldByName('spec1').AsString   :=
              ZQueryMedlem.FieldByName('spec1').AsString;
            ZQuery1.FieldByName('spec2').AsString   :=
              ZQueryMedlem.FieldByName('spec2').AsString;
            ZQuery1.FieldByName('spec3').AsString   :=
              ZQueryMedlem.FieldByName('spec3').AsString;
            ZQuery1.FieldByName('spec4').AsString   :=
              ZQueryMedlem.FieldByName('spec4').AsString;
            ZQuery1.FieldByName('beskrivelse').AsVariant   :=
              ZQueryMedlem.FieldByName('beskrivelse').AsVariant;
            ZQuery1.FieldByName('vaerge').AsString   :=
              ZQueryMedlem.FieldByName('vaerge').AsString;
            ZQuery1.FieldByName('vaergebetal').AsString   :=
              ZQueryMedlem.FieldByName('vaergebetal').AsString;
            ZQuery1.FieldByName('billedtype').AsString   :=
              ZQueryMedlem.FieldByName('billedtype').AsString;
            ZQuery1.FieldByName('billed').AsVariant   :=
              ZQueryMedlem.FieldByName('billed').AsVariant;
            ZQuery1.FieldByName('pbsaftalenr').AsFloat   :=
              ZQueryMedlem.FieldByName('pbsaftalenr').AsFloat;
            ZQuery1.FieldByName('pbsbankreg').AsString   :=
              ZQueryMedlem.FieldByName('pbsbankreg').AsString;
            ZQuery1.FieldByName('pbskontonr').AsString   :=
              ZQueryMedlem.FieldByName('pbskontonr').AsString;
            ZQuery1.FieldByName('pbscpr1').AsString   :=
              ZQueryMedlem.FieldByName('pbscpr1').AsString;
            ZQuery1.FieldByName('pbscpr2').AsString   :=
              ZQueryMedlem.FieldByName('pbscpr2').AsString;
            ZQuery1.FieldByName('pbskundenr').AsFloat   :=
              ZQueryMedlem.FieldByName('pbskundenr').AsFloat;
            ZQuery1.FieldByName('pbsgammeltnr').AsFloat   :=
              ZQueryMedlem.FieldByName('pbsgammeltnr').AsFloat;
            ZQuery1.FieldByName('pbssidstedato').AsString   :=
              ZQueryMedlem.FieldByName('pbssidstedato').AsString;
            ZQuery1.FieldByName('pbsstatus').AsString   :=
              ZQueryMedlem.FieldByName('pbsstatus').AsString;
            ZQuery1.FieldByName('udmeldtd').AsString   :=
              ZQueryMedlem.FieldByName('udmeldtd').AsString;
          end;
        // Gem
        ZQuery1.Post;
        ZQuery1.ApplyUpdates;
      Except
        MessageDlg('Række fra grid kunne ikke indsættes!',mtError,[mbOk],0);
        ZQuery1.CancelUpdates;
        Exit;
      end;
      Inc(HelpNr);
      Inc(A);
    end;
  // Udskriv
  SuperPrintForm := TSuperPrintForm.Create(Self);
  SuperPrintForm.TypeRapport := 1;
  SuperPrintForm.RapportTitel := 'Find medlemmer';
  SuperPrintForm.IndlaesFlueben;
  SuperPrintForm.IndlaesRapportCombo;
  SuperPrintForm.ShowModal;
  SuperPrintForm.Free;
end;

//**********************************************************
// Read Data
//**********************************************************
procedure TShowFindForm.ReadData;
Var HelpData : PShowFindResultDefListType;
begin
  IniFile := TIniFile.Create(HolbaekIniFile);
  ResultDefListe.Clear;
  New(HelpData);
  With HelpData^ Do // MedlemsNr
    Begin
      NrIDef      := 1;
      PrintNavn   := 'Nr';
      Laengde     := 40;
      Valgt       := False;
    End;
  ResultDefListe.Add(Helpdata);
  New(HelpData);
  With HelpData^ Do // Fornavn
    Begin
      NrIDef      := 2;
      PrintNavn   := 'Fornavn';
      Laengde     := 110;
      Valgt       := True;
    End;
  ResultDefListe.Add(Helpdata);
  New(HelpData);
  With HelpData^ Do // Efternavn
    Begin
      NrIDef      := 3;
      PrintNavn   := 'Efternavn';
      Laengde     := 110;
      Valgt       := True;
    End;
  ResultDefListe.Add(Helpdata);
  New(HelpData);
  With HelpData^ Do // Adresse
    Begin
      NrIDef      := 4;
      PrintNavn   := 'Adresse';
      Laengde     := 130;
      Valgt       := True;
    End;
  ResultDefListe.Add(Helpdata);
  New(HelpData);
  With HelpData^ Do // Adr 2
    Begin
      NrIDef      := 5;
      PrintNavn   := 'Adr2';
      Laengde     := 130;
      Valgt       := False;
    End;
  ResultDefListe.Add(Helpdata);
  New(HelpData);
  With HelpData^ Do // Postnr
    Begin
      NrIDef      := 7;
      PrintNavn   := 'Pnr';
      Laengde     := 40;
      Valgt       := True;
    End;
  ResultDefListe.Add(Helpdata);
  New(HelpData);
  With HelpData^ Do // By
    Begin
      NrIDef      := 8;
      PrintNavn   := 'By';
      Laengde     := 110;
      Valgt       := True;
    End;
  ResultDefListe.Add(Helpdata);
  New(HelpData);
  With HelpData^ Do // Telefon
    Begin
      NrIDef      := 9;
      PrintNavn   := 'Tlf';
      Laengde     := 60;
      Valgt       := True;
    End;
  ResultDefListe.Add(Helpdata);
  New(HelpData);
  With HelpData^ Do // CPR
    Begin
      NrIDef      := 12;
      PrintNavn   := 'Foedselsdato';
      Laengde     := 70;
      Valgt       := False;
    End;
  ResultDefListe.Add(Helpdata);
  New(HelpData);
  With HelpData^ Do // Medlemsiden
    Begin
      NrIDef      := 13;
      PrintNavn   := 'Indmeddelsesdato.';
      Laengde     := 80;
      Valgt       := False;
    End;
  ResultDefListe.Add(Helpdata);
  New(HelpData);
  With HelpData^ Do // Mand
    Begin
      NrIDef      := 14;
      PrintNavn   := 'Køn';
      Laengde     := 20;
      Valgt       := False;
    End;
  ResultDefListe.Add(Helpdata);
  New(HelpData);
  With HelpData^ Do // Spec1
    Begin
      NrIDef      := 15;
      PrintNavn   := IniFile.ReadString('Medlem','Spec1','Special 1:');
      Laengde     := 110;
      Valgt       := False;
    End;
  ResultDefListe.Add(Helpdata);
  New(HelpData);
  With HelpData^ Do // Spec2
    Begin
      NrIDef      := 16;
      PrintNavn   := IniFile.ReadString('Medlem','Spec2','Special 2:');
      Laengde     := 110;
      Valgt       := False;
    End;
  ResultDefListe.Add(Helpdata);
  New(HelpData);
  With HelpData^ Do // Spec3
    Begin
      NrIDef      := 17;
      PrintNavn   := IniFile.ReadString('Medlem','Spec3','Special 3:');
      Laengde     := 110;
      Valgt       := False;
    End;
  ResultDefListe.Add(Helpdata);
  New(HelpData);
  With HelpData^ Do // Spec4
    Begin
      NrIDef      := 18;
      PrintNavn   := IniFile.ReadString('Medlem','Spec4','Special 4:');
      Laengde     := 110;
      Valgt       := False;
    End;
  ResultDefListe.Add(Helpdata);
  New(HelpData);
  With HelpData^ Do // BrugerMedNr
    Begin
      NrIDef      := 1;
      PrintNavn   := 'Bruger nr';
      Laengde     := 50;
      Valgt       := False;
    End;
  ResultDefListe.Add(Helpdata);
  New(HelpData);
  With HelpData^ Do // Fax
    Begin
      NrIDef      := 10;
      PrintNavn   := 'Fax';
      Laengde     := 60;
      Valgt       := False;
    End;
  ResultDefListe.Add(Helpdata);
  New(HelpData);
  With HelpData^ Do // MobilTlfNr
    Begin
      NrIDef      := 11;
      PrintNavn   := 'MobilTlfNr';
      Laengde     := 60;
      Valgt       := False;
    End;
  ResultDefListe.Add(Helpdata);
  New(HelpData);
  With HelpData^ Do // Udmeldt
    Begin
      NrIDef      := 34;
      PrintNavn   := 'Udmeldt d.';
      Laengde     := 60;
      Valgt       := False;
    End;
  ResultDefListe.Add(Helpdata);
  // > 100 Land
  New(HelpData);
  With HelpData^ Do // Land
    Begin
      NrIDef      := 101;
      PrintNavn   := 'Land';
      Laengde     := 80;
      Valgt       := False;
    End;
  ResultDefListe.Add(Helpdata);
  New(HelpData);
  With HelpData^ Do // Land
    Begin
      NrIDef      := 102;
      PrintNavn   := 'LandForkort';
      Laengde     := 60;
      Valgt       := False;
    End;
  ResultDefListe.Add(Helpdata);
  // > 200 < 250 -> Medgruppedef
  New(HelpData);
  With HelpData^ Do
    Begin
      NrIDef      := 201;
      PrintNavn   := 'GruppeBesk';
      Laengde     := 100;
      Valgt       := False;
    End;
  ResultDefListe.Add(Helpdata);
  // > 250 -> Medgruppe
  New(HelpData);
  With HelpData^ Do
    Begin
      NrIDef      := 252;
      PrintNavn   := 'GruppeNrI';
      Laengde     := 100;
      Valgt       := False;
    End;
  ResultDefListe.Add(Helpdata);
  New(HelpData);
  With HelpData^ Do
    Begin
      NrIDef      := 253;
      PrintNavn   := 'GruppeNrMan';
      Laengde     := 100;
      Valgt       := False;
    End;
  ResultDefListe.Add(Helpdata);
  // > 300 -> Email
  New(HelpData);
  With HelpData^ Do
    Begin
      NrIDef      := 301;
      PrintNavn   := 'Email';
      Laengde     := 100;
      Valgt       := False;
    End;
  ResultDefListe.Add(Helpdata);
  // > 400 -> Værge oplysninger
  New(HelpData);
  With HelpData^ Do
    Begin
      NrIDef      := 401;
      PrintNavn   := 'Vaergenavn';
      Laengde     := 100;
      Valgt       := False;
    End;
  ResultDefListe.Add(Helpdata);
  New(HelpData);
  With HelpData^ Do
    Begin
      NrIDef      := 402;
      PrintNavn   := 'VaergeAdr';
      Laengde     := 80;
      Valgt       := False;
    End;
  ResultDefListe.Add(Helpdata);
  New(HelpData);
  With HelpData^ Do
    Begin
      NrIDef      := 403;
      PrintNavn   := 'VaergeEmail';
      Laengde     := 80;
      Valgt       := False;
    End;
  ResultDefListe.Add(Helpdata);
  IniFile.Free;
End;

//**********************************************************************
// Indlaes i grid
//**********************************************************************
procedure TShowFindForm.IndlaesIGrid(Nr : Integer);
Var A               : Integer;
    B               : Integer;
    HelpStrOriginal : String;
    HelpStr         : String;
    NrStr           : String;
    HelpData        : PShowFindResultDefListType;
    HelpNr          : Integer;
    KolNr           : Integer;
    GrpNr           : Integer;
    HelpEmail       : String;
begin
  // Oprette det specifiserede antaller kollonner
  IniFile := TIniFile.Create(HolbaekIniFile);
  HelpStr := '';
//  StringGrid1.FloatingFooter.Visible := False;
//  StringGrid1.BeginUpdate;
  StringGrid1.Columns.Clear;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;
  StringGrid1.Columns[0].Visible         := False;
  StringGrid1.Columns[0].Title.Caption   := '*';
  StringGrid1.Columns[1].Visible         := False;
  StringGrid1.Columns[1].Title.Caption   := '*';
  StringGrid1.RowCount                   := 2;

  HelpStrOriginal := IniFile.ReadString('ShowFindMed',IntToStr(Nr) + 'C','1 2 3 4 7 8 101 102');
  HelpStr := HelpStrOriginal;
  While (Length(HelpStr) > 0) Do
      Begin
        If Pos(' ',HelpStr) > 0 Then
          Begin
            NrStr := Copy(HelpStr,1,Pos(' ',HelpStr)-1);
            Delete(HelpStr,1,Pos(' ',HelpStr));
          End
        Else
          Begin // Sidste tal
            NrStr := HelpStr;
            HelpStr := '';
          End;
        // Indsæt i checkdialog boks
        HelpNr := StrToInt(NrStr);
        StringGrid1.Columns.Add;
        A := 0;
        Try
          HelpData := ResultDefListe.Items[A];
          While Helpdata^.NrIDef <> Helpnr Do
            Begin
              Inc(A);
              HelpData := ResultDefListe.Items[A];
            End;
          StringGrid1.Columns[StringGrid1.Columns.Count-1].Title.Caption := HelpData^.PrintNavn;
          StringGrid1.Columns[StringGrid1.Columns.Count-1].Width         := HelpData^.Laengde;
        Except
        End;
      End;
  StringGrid1.Columns[0].Visible := False;  // Fjern kolonner som ikke skal vises
  StringGrid1.Columns[1].Visible := False;
  StringGrid1.RowCount := 1;
  B := 0;
  AntalMaend    := 0;
  AntalKvinder  := 0;
  AntalFlere    := 0;
//  A := 0;
  While B < FormFindMedlemmer.ResultListe.Count Do
    Begin
      // HVis der ikke er søgt på gruppe
      If TResultListType(FormFindMedlemmer.ResultListe.Items[B]^).Gruppe.Count <= 0 Then
        Begin
          GrpNr := 0;
        End
      Else
        Begin
          GrpNr := 1;
        End;
      With ZQueryMedlem.SQL do
        Begin
          Clear;
          Add('Select * from medlem where medlemsnr = ' +
           IntToStr(TResultListType(FormFindMedlemmer.ResultListe.Items[B]^).MedlemsNr));
        End;
      ZQueryMedlem.Open;
      ZQueryMedlem.First;
      If Not ZQueryMedlem.Eof Then
         Begin
           While GrpNr <= TResultListType(
             FormFindMedlemmer.ResultListe.Items[B]^).Gruppe.Count Do
             Begin
               HelpStr := HelpStrOriginal;
               KolNr   := 2;
               StringGrid1.RowCount := StringGrid1.RowCount + 1;
               // Indsæt første kol som medlemsnr.
               StringGrid1.Cells[0,StringGrid1.RowCount-1]:=
                     ZQueryMedlem.FieldbyName('MedlemsNr').AsString;
               // Opdater statistik
               If ZQueryMedlem.FieldByName('Mand').AsString = '0' Then
                 Inc(AntalMaend)
               Else
               If ZQueryMedlem.FieldByName('Mand').AsString = '1' Then
                 Inc(AntalKvinder)
               Else
                 Inc(AntalFlere);
               //
               If TResultListType(FormFindMedlemmer.ResultListe.Items[B]^).Gruppe.Count = 0 Then
                 Begin // Ingen gruppe valgt
                   StringGrid1.Cells[1,StringGrid1.RowCount-1]:= '0';
                 End
               Else
                 Begin // Indlæs gruppenr
                   StringGrid1.Cells[1,StringGrid1.RowCount-1]:=
                     TResultListType(FormFindMedlemmer.ResultListe.Items[B]^).Gruppe.Strings[GrpNr-1];
                 End;
               // Indsæt de andre felter i defineret rækkefølge
               While (Length(HelpStr) > 0) Do
                 Begin
                   If Pos(' ',HelpStr) > 0 Then
                     Begin
                       NrStr := Copy(HelpStr,1,Pos(' ',HelpStr)-1);
                       Delete(HelpStr,1,Pos(' ',HelpStr));
                     End
                   Else
                     Begin // Sidste tal
                       NrStr := HelpStr;
                       HelpStr := '';
                     End;
                   // Indsæt i checkdialog boks
                   HelpNr := StrToInt(NrStr);
                   Try
                     A := 0;
                     HelpData := ResultDefListe.Items[A];
                     While Helpdata^.NrIDef <> Helpnr Do
                       Begin
                         Inc(A);
                         HelpData := ResultDefListe.Items[A];
                       End;
                     If Helpdata^.NrIDef < 100 Then
                       Begin
                         StringGrid1.Cells[KolNr,StringGrid1.RowCount-1]:=
                           ZQueryMedlem.Fields.Fields[Helpdata^.NrIDef].AsString;
                       End
                     Else If Helpdata^.NrIDef < 200 Then
                       Begin // Land
                         With ZQuery1.SQL do
                           Begin
                             Clear;
                             Add('Select * from land where (landkode = ' +
                                   ZQueryMedlem.FieldByName('landkode').AsString + ')' );
                           End;
                         ZQuery1.Open;
                         If ZQuery1.RecordCount <> 0 Then
                           Begin
                             StringGrid1.Cells[KolNr,StringGrid1.RowCount-1]:=
                              ZQuery1.Fields.Fields[Helpdata^.NrIDef-100].AsString;
                           end;
                       End
(*                     Else If Helpdata^.NrIDef < 250 Then
                       Begin // MedGruppeDef
                         If (GrpNr > 0) And MedGruppeDefTabel.FindKey([
                         TResultListType(FormFindMedlemmer.ResultListe.Items[B]^).Gruppe.Strings[GrpNr-1]]) Then
                           Begin
                             StringGrid1.Cells[KolNr,StringGrid1.RowCount-1]:=
                              MedGruppeDefTabel.Fields.Fields[Helpdata^.NrIDef-200].AsString;
                           End;
                       End
                     Else If Helpdata^.NrIDef < 300 Then
                       Begin // MedGruppe
                         If (GrpNr > 0 ) And MedGruppeTabel.FindKey([
                         TResultListType(FormFindMedlemmer.ResultListe.Items[B]^).Gruppe.Strings[GrpNr-1],
                         ZQueryMedlem.FieldByName('MedlemsNr').AsString]) Then
                           Begin
                             StringGrid1.Cells[KolNr,StringGrid1.RowCount-1]:=
                              MedGruppeTabel.Fields.Fields[Helpdata^.NrIDef-250].AsString;
                           End;
                       End
                     Else If Helpdata^.NrIDef < 400 Then
                       Begin // Email
                         If MedlemEmailTabel.FindKey([ZQueryMedlem.FieldByName('MedlemsNr').AsString]) Then
                           Begin
                             HelpEmail := '';
                             While Not MedlemEmailTabel.Eof and (MedlemEmailTabel.FieldByName('MedlemsNr').AsString =
                               ZQueryMedlem.FieldByName('MedlemsNr').AsString) Do
                               Begin
                                 HelpEmail := HelpEmail + MedlemEmailTabel.FieldByName('Email').AsString + ';';
                                 MedlemEmailTabel.Next;
                               End;
                             StringGrid1.Cells[KolNr,StringGrid1.RowCount-1]:= HelpEmail;
                           End;
                       End
                     Else If Helpdata^.NrIDef < 500 Then
                       Begin // Vaerge
                         If Helpdata^.NrIDef = 401 Then
                           Begin
                             If Medlem2Tabel.FindKey([ZQueryMedlem.FieldByName('Vaerge').AsString]) Then
                               Begin
                                 StringGrid1.Cells[KolNr,StringGrid1.RowCount-1]:=
                                    Medlem2Tabel.FieldByName('Fornavn').AsString + ' ' +
                                    Medlem2Tabel.FieldByName('Efternavn').AsString;
                               End;
                           End
                         Else If Helpdata^.NrIDef = 402 Then
                           Begin
                             If Medlem2Tabel.FindKey([ZQueryMedlem.FieldByName('Vaerge').AsString]) Then
                               Begin
                                 StringGrid1.Cells[KolNr,StringGrid1.RowCount-1]:=
                                    Medlem2Tabel.FieldByName('Adr1').AsString;
                               End;
                           End
                         Else If Helpdata^.NrIDef = 403 Then
                           Begin  // Værge Email
                             If Medlem2Tabel.FindKey([ZQueryMedlem.FieldByName('Vaerge').AsString]) Then
                               Begin
                                 If MedlemEmailTabel.FindKey([Medlem2Tabel.FieldByName('MedlemsNr').AsString]) Then
                                   Begin
                                     HelpEmail := '';
                                     While Not MedlemEmailTabel.Eof and (MedlemEmailTabel.FieldByName('MedlemsNr').AsString =
                                       Medlem2Tabel.FieldByName('MedlemsNr').AsString) Do
                                       Begin
                                         HelpEmail := HelpEmail + MedlemEmailTabel.FieldByName('Email').AsString + ';';
                                         MedlemEmailTabel.Next;
                                       End;
                                     StringGrid1.Cells[KolNr,StringGrid1.RowCount-1]:= HelpEmail;
                                   End;
                               End;
                           End;
                       End;*)
                   Except
                   End;
                   Inc(KolNr);
                 End;
               Inc(GrpNr);
             End;
         End
       Else
         Begin
           MessageDlg('Hej den findes ikke: ' +
            IntToStr(TResultListType(FormFindMedlemmer.ResultListe.Items[B]^).MedlemsNr),
             mtInformation,[mbOK],0);
         End;
      Inc(B)
    End;
  IniFile.Free;
//  StringGrid1.EndUpdate;
(*  If StringGrid1.SearchFooter.Visible Then
    Begin
      StringGrid1.SearchFooter.Visible := False;
      StringGrid1.SearchFooter.Visible := True;
    End;*)
  StringGrid1.Refresh;
  // Opdater statistik;
  AntalMaendLabel.Caption   := IntToStr(AntalMaend);
  AntalKvinderLabel.Caption := IntToStr(AntalKvinder);
  AntalFlereLabel.Caption   := IntToStr(AntalFlere);
//    UpdateFooter(True);
end;


//**********************************************************
// Speed 1
//**********************************************************
procedure TShowFindForm.Action1Execute(Sender: TObject);
begin
  IndlaesIGrid(1);
  NrFilter := 1;
end;

//**********************************************************
// Speed 2
//**********************************************************
procedure TShowFindForm.Action2Execute(Sender: TObject);
begin
  IndlaesIGrid(2);
  NrFilter := 2;
end;

//**********************************************************
// Speed 3
//**********************************************************
procedure TShowFindForm.Action3Execute(Sender: TObject);
begin
  IndlaesIGrid(3);
  NrFilter := 3;
end;

//**********************************************************
// Speed 4
//**********************************************************
procedure TShowFindForm.Action4Execute(Sender: TObject);
begin
  IndlaesIGrid(4);
  NrFilter := 4;
end;

//**********************************************************
// Speed 5
//**********************************************************
procedure TShowFindForm.Action5Execute(Sender: TObject);
begin
  IndlaesIGrid(5);
  NrFilter := 5;
end;

//**********************************************************
// Speed 6
//**********************************************************
procedure TShowFindForm.Action6Execute(Sender: TObject);
begin
  IndlaesIGrid(6);
  NrFilter := 6;
end;


end.

