//***************************************************************************//
//  Holbæk                                                                   //
//  Copyright by Claus Moeller 2013-2017                                     //
//  Søg medlemmer                                                            //
//  Version                                                                  //
//  22.01.2017                                                               //
//***************************************************************************//
unit SoegMed;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ComCtrls, ExtCtrls, StdCtrls, ActnList, Menus, Grids, ZDataset;

Const AntalFelter = 7; { 0 tæller med }
Type
  SoegType  = (All{*},
              SpecPartial{*CL},
              Partial{CL*},
              Specific{Claus});

  SoegeSpec = Record
      SoegeOrd     : String;
      SoegKriterie : SoegType;
    End;

  { TMedlemSoegForm }

  TMedlemSoegForm = class(TForm)
    Nulstil: TAction;
    Find: TAction;
    ActionList1: TActionList;
    EditEfternavn: TEdit;
    EditAdr2: TEdit;
    EditAdr1: TEdit;
    EditEmail: TEdit;
    EditNr: TEdit;
    EditMobil: TEdit;
    EditTlf: TEdit;
    EditFornavn: TEdit;
    Help: TAction;
    ImageList1: TImageList;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Luk: TAction;
    MainMenu1: TMainMenu;
    Panel1: TPanel;
    Panel2: TPanel;
    StringGrid1: TStringGrid;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ZQuery1: TZQuery;
    procedure EditAdr1Exit(Sender: TObject);
    procedure EditAdr2Exit(Sender: TObject);
    procedure EditEfternavnExit(Sender: TObject);
    procedure EditEmailExit(Sender: TObject);
    procedure EditFornavnExit(Sender: TObject);
    procedure EditMobilExit(Sender: TObject);
    procedure EditNrExit(Sender: TObject);
    procedure EditTlfExit(Sender: TObject);
    procedure FindExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure HelpExecute(Sender: TObject);
    procedure LukExecute(Sender: TObject);
    procedure NulstilExecute(Sender: TObject);
  private
    { private declarations }
    DataSoeg : Array[0..AntalFelter] of SoegeSpec;{Efternavn, Fornavn, Adr}
    Function CLMUppercase(HelpStr : String) : String;
    procedure Syntax;
    procedure IndstilGrid;
  public
    { public declarations }
    Mode  : Integer;  // 0 : Medlemsoplysning; 1 = Aktivitetsliste, PBS_Total
    MedNr : LongInt;
    Navn  : String;
  end;

var
  MedlemSoegForm: TMedlemSoegForm;

implementation

{$R *.lfm}

{ TMedlemSoegForm }

Uses HolbaekConst, MainData;

Const SoegFornavn   : Integer = 0;
      SoegEfternavn : Integer = 1;
      SoegAdresse   : Integer = 2;
      SoegNr        : Integer = 3;
      SoegMedNr     : Integer = 4;
      SoegMobil     : Integer = 5;
      SoegAdr2      : Integer = 6;
      SoegEmail     : Integer = 7;
    KolFornavn   = 0;
    KolEfternavn = 1;
    KolAdresse   = 2;
    KolNr        = 3;
    KolId        = 4;

//**********************************************************
// Luk
//**********************************************************
procedure TMedlemSoegForm.LukExecute(Sender: TObject);
begin
  Close;
end;

//**********************************************************
// Nulstil
//**********************************************************
procedure TMedlemSoegForm.NulstilExecute(Sender: TObject);
begin
  EditEfternavn.Text := '*';
  EditAdr1.Text      := '*';
  EditAdr2.Text      := '*';
  EditTlf.Text       := '*';
  EditFornavn.Text   := '*';
  EditNr.Text        := '*';
  EditMobil.Text     := '*';
  EditEmail.Text     := '*';
  FindExecute(Sender);
end;

//**********************************************************
// Create
//**********************************************************
procedure TMedlemSoegForm.FormCreate(Sender: TObject);
begin
  Top  := 100;
  Left := 130;
  // Farver
  Color                               := H_Window_Baggrund;
  ToolBar1.Color                      := H_Menu_knapper_Farve;
  EditEfternavn.Color                 := H_Edit_Baggrund;
  EditFornavn.Color                   := H_Edit_Baggrund;
  EditAdr1.Color                      := H_Edit_Baggrund;
  EditAdr2.Color                      := H_Edit_Baggrund;
  EditTlf.Color                       := H_Edit_Baggrund;
  EditMobil.Color                     := H_Edit_Baggrund;
  EditNr.Color                        := H_Edit_Baggrund;
  EditEmail.Color                     := H_Edit_Baggrund;
  // Grid
  IndstilGrid;

//  StatusBar1.Color  := H_Menu_knapper_Farve;
  // Database
  ZQuery1.Connection := MainData.MainDataModule.ZConnection1;

end;

//**********************************************************************
// Help
//**********************************************************************
procedure TMedlemSoegForm.HelpExecute(Sender: TObject);
begin
  ShowMessage('HJælp');
end;

//**********************************************************************
// Uppercase
//**********************************************************************
Function TMedlemSoegForm.CLMUppercase(HelpStr : String) : String;
Var A : Integer;
    UpStr : String;
Begin
  UpStr := '';
  For A := 1 To Length(HelpStr) Do
    Begin
      If HelpStr[A] in ['a'..'z','A'..'Z'] Then
        Begin
          UpStr := UpStr + Upcase(HelpStr[A]);
        End
      Else If HelpStr[A] = 'ø' Then
        Begin
          UpStr := UpStr + 'Ø';
        End
      Else If HelpStr[A] = 'æ' Then
        Begin
          UpStr := UpStr + 'Æ';
        End
      Else If HelpStr[A] = 'å' Then
        Begin
          UpStr := UpStr + 'Å';
        End
      Else
        Begin
          UpStr := UpStr + HelpStr[A];
        End
    End;
  CLMUppercase := UpStr;
End;

//**********************************************************************
// Syntax
//**********************************************************************
procedure TMedlemSoegForm.Syntax;
Var PosStj  : Byte;
    A       : Integer;
begin
//  ShowMessage('|' + DataSoeg[3].SoegeOrd + '|');
  A := 0;
  While A <= AntalFelter Do
    Begin
      PosStj := Pos('*',DataSoeg[A].SoegeOrd);
      If PosStj = 0 Then
        Begin { Ingen Stjerne }
          DataSoeg[A].SoegKriterie := Specific;
        End
      Else
        If (PosStj = 1) And (Length(DataSoeg[A].SoegeOrd)= 1) Then
          Begin { Stjerne - all - * }
            DataSoeg[A].SoegKriterie := All;
            DataSoeg[A].SoegeOrd := ''; { Fjern stjerne }
          End
        Else
          Begin
            If (PosStj = 1) Then
              Begin { Stjerne - *CL - specpartial }
                DataSoeg[A].SoegKriterie := SpecPartial;
                Delete(DataSoeg[A].SoegeOrd,1,1); { Fjern stjerne }
              End
            Else
              Begin { Stjerne - CL* - Partial }
                DataSoeg[A].SoegKriterie := Partial;
                Delete(DataSoeg[A].SoegeOrd,PosStj,1); { Fjern stjerne }
              End
          End;
      Inc(A);
    End;
end;

//**********************************************************
// Find
//**********************************************************
procedure TMedlemSoegForm.FindExecute(Sender: TObject);
Var
  Naeste   : Boolean;
  HelpStrM : String;
  Stop     : Boolean;

Begin
  StringGrid1.RowCount := 1;
  { Først skal der foretages syntaxcheck }
  DataSoeg[SoegFornavn].SoegeOrd := ClmUpperCase(EditEfternavn.Text);
  DataSoeg[SoegEfternavn].SoegeOrd := CLMUpperCase(EditFornavn.Text);
  DataSoeg[SoegAdresse].SoegeOrd := CLMUpperCase(EditAdr1.Text);
  DataSoeg[SoegNr].SoegeOrd := CLMUpperCase(EditNr.Text);
  DataSoeg[SoegMedNr].SoegeOrd := CLMUpperCase(EditTlf.Text);
  DataSoeg[SoegMobil].SoegeOrd := CLMUpperCase(EditMobil.Text);
  DataSoeg[SoegAdr2].SoegeOrd := CLMUpperCase(EditAdr2.Text);
  DataSoeg[SoegEmail].SoegeOrd := CLMUpperCase(EditEmail.Text);
  Syntax;
  { Medlem søges igennem }
  StringGrid1.BeginUpdate;
  ZQuery1.Close;
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from Medlem');
    end;
  ZQuery1.Open;
  While Not ZQuery1.EOF Do
    Begin
      Naeste := False;
      // ** Efternavn
      If Not Naeste Then
        Begin
          HelpStrM := CLMUpperCase(ZQuery1.FieldByName('Efternavn').AsString);
          Case DataSoeg[SoegFornavn].SoegKriterie of
            All:
             Begin
               Naeste := False;
             End;
            Specific :
              Begin
                Naeste := Not (HelpStrM =DataSoeg[SoegFornavn].SoegeOrd);
              End;
            Partial : {CLM*}
              Begin
                 Naeste := Not ( Pos(DataSoeg[SoegFornavn].SoegeOrd,
                  HelpStrM) = 1) ;
              End;
            SpecPartial : {*CLM}
              Begin
                 Naeste := Not ( Pos(DataSoeg[SoegFornavn].SoegeOrd,
                 HelpStrM) > 0) ;
              End;
          End { End Case }
        End;
      // ** Fornavn
      If Not Naeste Then
        Begin
          HelpStrM := CLMUpperCase(ZQuery1.FieldByName('Fornavn').AsString);
          Case DataSoeg[SoegEfternavn].SoegKriterie of
            All:
              Begin
                Naeste := False;
              End;
            Specific :
              Begin
                Naeste := Not (HelpStrM = DataSoeg[SoegEfternavn].SoegeOrd);
              End;
            Partial : {CLM*}
              Begin
                 Naeste := Not ( Pos(DataSoeg[SoegEfternavn].SoegeOrd,
                  HelpStrM) = 1) ;
              End;
            SpecPartial : {*CLM}
              Begin
                 Naeste := Not ( Pos(DataSoeg[SoegEfternavn].SoegeOrd,
                  HelpStrM) > 0) ;
              End;
          End { End Case }
        End;
      // ** Adresse
      If Not Naeste Then
        Begin
          HelpStrM := CLMUpperCase(ZQuery1.FieldByName('Adr1').AsString);
          Case DataSoeg[SoegAdresse].SoegKriterie of
            All:
              Begin
                Naeste := False;
              End;
            Specific :
              Begin
                Naeste := Not (HelpStrM = DataSoeg[SoegAdresse].SoegeOrd);
              End;
            Partial : {CLM*}
              Begin
                Naeste := Not ( Pos(DataSoeg[SoegAdresse].SoegeOrd,HelpStrM) = 1) ;
              End;
            SpecPartial : {*CLM}
              Begin
                Naeste := Not ( Pos(DataSoeg[SoegAdresse].SoegeOrd,HelpStrM) > 0) ;
              End;
          End; { End Case }
        End;
      // ** Medlemsnr
      If Not Naeste Then
        Begin
          HelpStrM := CLMUpperCase(ZQuery1.FieldByName('brugermedlemsnr').AsString);
          Case DataSoeg[SoegNr].SoegKriterie of
            All:
              Begin
                Naeste := False;
              End;
            Specific :
              Begin
                Naeste := Not (HelpStrM = DataSoeg[SoegNr].SoegeOrd);
              End;
            Partial : {CLM*}
              Begin
                Naeste := Not ( Pos(DataSoeg[SoegNr].SoegeOrd,HelpStrM) = 1) ;
              End;
            SpecPartial : {*CLM}
              Begin
                Naeste := Not ( Pos(DataSoeg[SoegNr].SoegeOrd,HelpStrM) > 0) ;
              End;
          End; { End Case }
        End;
      // Tlf
      If Not Naeste Then
        Begin
          HelpStrM := CLMUpperCase(ZQuery1.FieldByName('Telefon').AsString);
          Case DataSoeg[SoegMedNr].SoegKriterie of
            All:
              Begin
                Naeste := False;
              End;
            Specific :
              Begin
                Naeste := Not (HelpStrM = DataSoeg[SoegMedNr].SoegeOrd);
              End;
            Partial : {CLM*}
              Begin
                Naeste := Not ( Pos(DataSoeg[SoegMedNr].SoegeOrd,HelpStrM) = 1) ;
              End;
            SpecPartial : {*CLM}
              Begin
                Naeste := Not ( Pos(DataSoeg[SoegMedNr].SoegeOrd,HelpStrM) > 0) ;
              End;
          End; { End Case }
        End;
      // Mobilnr
      If Not Naeste Then
        Begin
          HelpStrM := CLMUpperCase(ZQuery1.FieldByName('MobilTlfnr').AsString);
          Case DataSoeg[5].SoegKriterie of
            All:
              Begin
                Naeste := False;
              End;
            Specific :
              Begin
                Naeste := Not (HelpStrM = DataSoeg[SoegMobil].SoegeOrd);
              End;
            Partial : {CLM*}
              Begin
                Naeste := Not ( Pos(DataSoeg[SoegMobil].SoegeOrd,HelpStrM) = 1) ;
              End;
            SpecPartial : {*CLM}
              Begin
                Naeste := Not ( Pos(DataSoeg[SoegMobil].SoegeOrd,HelpStrM) > 0) ;
              End;
          End; { End Case }
        End;
      // Adr2
      If Not Naeste Then
        Begin
          HelpStrM := CLMUpperCase(ZQuery1.FieldByName('Adr2').AsString);
          Case DataSoeg[SoegAdr2].SoegKriterie of
            All:
              Begin
                Naeste := False;
              End;
            Specific :
              Begin
                Naeste := Not (HelpStrM = DataSoeg[SoegAdr2].SoegeOrd);
              End;
            Partial : {CLM*}
              Begin
                Naeste := Not ( Pos(DataSoeg[SoegAdr2].SoegeOrd,HelpStrM) = 1) ;
              End;
            SpecPartial : {*CLM}
              Begin
                Naeste := Not ( Pos(DataSoeg[SoegAdr2].SoegeOrd,HelpStrM) > 0) ;
              End;
          End; { End Case }
        End;
      // Email
(*      If Not Naeste and (EditEmail.Text <> '*') Then
        Begin
          Stop := False;
          EmailTabel.First;
          while Not Stop and Not EmailTabel.Eof do
            Begin
              If EmailTabel.FieldByName('MedlemsNr').AsString =
                ZQuery1.FieldByName('MedlemsNr').AsString Then
                Begin
                   HelpStrM := CLMUpperCase(EmailTabel.FieldByName('Email').AsString);
                   Case DataSoeg[SoegEmail].SoegKriterie of
                     All:
                       Begin
                         Stop := True;
                       End;
                     Specific :
                       Begin
                         Stop := (HelpStrM = DataSoeg[SoegEmail].SoegeOrd);
                       End;
                     Partial : {CLM*}
                       Begin
                         Stop := ( Pos(DataSoeg[SoegEmail].SoegeOrd,HelpStrM) = 1) ;
                       End;
                     SpecPartial : {*CLM}
                       Begin
                         Stop := ( Pos(DataSoeg[SoegEmail].SoegeOrd,HelpStrM) > 0) ;
                       End;
                    End; { End Case }
                End
              Else
                Begin
                  Stop := False;
                End;
              EmailTabel.Next;
            End;
          If Not Stop Then Naeste := True;
        End;*)
      If Not Naeste Then { Indsæt medlem i listbox }
        Begin
          StringGrid1.RowCount := StringGrid1.RowCount + 1;
          StringGrid1.Cells[SoegFornavn,StringGrid1.RowCount-1] :=
            ZQuery1.FieldByName('Fornavn').AsString;
          StringGrid1.Cells[SoegEfternavn,StringGrid1.RowCount-1] :=
            ZQuery1.FieldByName('Efternavn').AsString;
          StringGrid1.Cells[SoegAdresse,StringGrid1.RowCount-1] :=
            ZQuery1.FieldByName('Adr1').AsString;
          StringGrid1.Cells[SoegNr,StringGrid1.RowCount-1] :=
            ZQuery1.FieldByName('brugermedlemsnr').AsString;
          StringGrid1.Cells[SoegMedNr,StringGrid1.RowCount-1] :=
            ZQuery1.FieldByName('MedlemsNr').AsString;
(*          NrIListe := StringGrid1.RowCount - 1;
          MedlemListe.Insert(NrIListe,
            ZQuery1.FieldByName('MedlemsNr').AsString);*)
        End;
      ZQuery1.Next;
    End; // While
  StringGrid1.EndUpdate;
end;

//**********************************************************
// Efternavn exit
//**********************************************************
procedure TMedlemSoegForm.EditEfternavnExit(Sender: TObject);
begin
  FindExecute(Sender);
end;

//**********************************************************
// Email exit
//**********************************************************
procedure TMedlemSoegForm.EditEmailExit(Sender: TObject);
begin
  FindExecute(Sender);
end;

//**********************************************************
// Adr1 exit
//**********************************************************
procedure TMedlemSoegForm.EditAdr1Exit(Sender: TObject);
begin
  FindExecute(Sender);
end;

//**********************************************************
// Adr2 exit
//**********************************************************
procedure TMedlemSoegForm.EditAdr2Exit(Sender: TObject);
begin
  FindExecute(Sender);
end;

//**********************************************************
// Fornavn exit
//**********************************************************
procedure TMedlemSoegForm.EditFornavnExit(Sender: TObject);
begin
  FindExecute(Sender);
end;

//**********************************************************
// Mobil exit
//**********************************************************
procedure TMedlemSoegForm.EditMobilExit(Sender: TObject);
begin
  FindExecute(Sender);
end;

//**********************************************************
// Nr exit
//**********************************************************
procedure TMedlemSoegForm.EditNrExit(Sender: TObject);
begin
  FindExecute(Sender);
end;

//**********************************************************
// Tlf exit
//**********************************************************
procedure TMedlemSoegForm.EditTlfExit(Sender: TObject);
begin
  FindExecute(Sender);
end;


//**********************************************************
// Indstil grid
//**********************************************************
procedure TMedlemSoegForm.IndstilGrid;
Begin
  Indstil_StringGrid_NonEdit(StringGrid1);
  StringGrid1.Color := H_Grid_BackColor;

  StringGrid1.Columns.Clear;
  // Indsæt 4 + 1 kol
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;

  // Indstil
  StringGrid1.Columns[KolFornavn].Title.Caption   := 'Fornavn';
  StringGrid1.Columns[KolFornavn].Width           := 110;
  StringGrid1.Columns[KolFornavn].Alignment       := taLeftJustify;

  StringGrid1.Columns[KolEfternavn].Title.Caption := 'Efternavn';
  StringGrid1.Columns[KolEfternavn].Width         := 110;
  StringGrid1.Columns[KolEfternavn].Alignment     := taLeftJustify;

  StringGrid1.Columns[KolAdresse].Title.Caption   := 'Adresse';
  StringGrid1.Columns[KolAdresse].Width            := 150;
  StringGrid1.Columns[KolAdresse].Alignment        := taLeftJustify;

  StringGrid1.Columns[KolNr].Title.Caption         := 'Nr';
  StringGrid1.Columns[KolNr].Width                 := 50;
  StringGrid1.Columns[KolNr].Alignment             := taRightJustify;

  StringGrid1.Columns[KolId].Title.Caption         := 'Id';
  StringGrid1.Columns[KolId].Width                 := 70;
  StringGrid1.Columns[KolId].Visible               := False;
end;



end.

