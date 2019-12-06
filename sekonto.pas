//***************************************************************************//
//  Holbæk                                                                   //
//  Copyright by Claus Moeller 2013-2016                                     //
//  Se konto                                                                 //
//  Version                                                                  //
//  18.01.14, 29.12.16                                                       //
//***************************************************************************//

unit SeKonto;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  Menus, ActnList, ExtCtrls, StdCtrls, EditBtn, Grids, clmCombobox,
  JLabeledDateEdit, ZDataset;

{ TSeKontoForm }


Const CDefaultStr           : String = '9 1 2 3 4 5 6';

type
  PDataKonto = ^TDataKonto;
  TDataKonto = Record
    Dato             : String;
    Tekst            : String;
    BilagNr          : String;
    DebitBeloeb      : Currency;
    KreditBeloeb     : Currency;
    Saldo            : Currency;
    Konto            : String;
    KontoNavn        : String;
    Checked          : Char; { Gør at den regnes med }
    VisningDK        : Boolean;
    Formaal          : String;
  End;

  PDataKontoDefListType = ^TDataKontoDefListType;
  TDataKontoDefListType = Record
    NrIDef      : Integer;
    PrintNavn   : String;
    Laengde     : Integer;
    Valgt       : Boolean;
    Nr          : Integer; //
    HAlign      : TAlignment;
    AStyle      : TSortOrder;
  End;

  TSeKontoForm = class(TForm)
    Action1: TAction;
    ComboKonto: TclmCombobox;
    DatoFra: TJLabeledDateEdit;
    DatoTil: TJLabeledDateEdit;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    ToolButton2: TToolButton;
    Udskriv: TAction;
    ActionList1: TActionList;
    ComboFormaal: TComboBox;
    ComboPeriode: TComboBox;
    Help: TAction;
    ImageList1: TImageList;
    Label1: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    LabelDebet: TLabel;
    LabelAntal: TLabel;
    LabelKredit: TLabel;
    LabelSaldo: TLabel;
    Luk: TAction;
    MenuItem1: TMenuItem;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    PopupMenu1: TPopupMenu;
    StringGrid1: TStringGrid;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton3: TToolButton;
    ZQuery1: TZQuery;
    procedure ComboFormaalChange(Sender: TObject);
    procedure ComboKontoChange(Sender: TObject);
    procedure ComboPeriodeChange(Sender: TObject);
    procedure DatoFraChange(Sender: TObject);
    procedure DatoTilChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure HelpExecute(Sender: TObject);
    procedure LukExecute(Sender: TObject);
    procedure StringGrid1CheckboxToggled(sender: TObject; aCol, aRow: Integer;
      aState: TCheckboxState);
    procedure StringGrid1CompareCells(Sender: TObject; ACol, ARow, BCol,
      BRow: Integer; var Result: integer);
    procedure StringGrid1SelectEditor(Sender: TObject; aCol, aRow: Integer;
      var Editor: TWinControl);
    procedure UdskrivExecute(Sender: TObject);
  private
    { private declarations }
    SortColumn         : Integer;
    UpdateGrid         : Boolean;
    PeriodeNrListe     : TStringList;
    KontiListe         : TStringList;
    KontiListeNr       : TStringList;
    KontiListeBrugerNr : TStringList;
    KontiListeVisning  : TStringList;
    FormaalNrListe     : TStringList;
    DontUpdate         : Boolean;
    procedure IndlaesOkoMaerker;
    procedure IndlaesKonti;
    procedure Indstil;
    procedure Indlaes;
    procedure IndlaesPeriode;
    procedure IndlaesTilAlleData(KontoNrStr : String);
    procedure Opdater;
  public
    { public declarations }
    AlleData            : TList;
    SumDebit            : Currency;
    SumKredit           : Currency;
    SumSaldo            : Currency;
    SumFoerDebit        : Currency;
    SumFoerKredit       : Currency;
    AntalBilag          : LongInt;
    ResultDefListe      : TList;
  end;

var
  SeKontoForm: TSeKontoForm;

implementation

{$R *.lfm}

Uses HolbaekConst, MainData, DateUtils;

Const
   MinHeight    : Integer = 330;

   SeCheck      : Integer = 0;
   SeDato       : Integer = 1;
   SeTekst      : Integer = 2;
   SeNr         : Integer = 3;
   SeDebet      : Integer = 4;
   SeKredit     : Integer = 5;
   SeSaldo      : Integer = 6;
   SeFormaal    : Integer = 7;
   SeKontonr    : Integer = 8;
   SeKontonavn  : Integer = 9;
   SeRowNr      : Integer = 10;

{ TSeKontoForm }

//**********************************************************
// Create
//**********************************************************
procedure TSeKontoForm.FormCreate(Sender: TObject);
begin
  Position := poDesigned;
  (*Top := 10;
  Left := 30;*)
  // Farver
  ToolBar1.Color                 := H_Menu_knapper_Farve;
//  StatusBar1.Color  := H_Menu_knapper_Farve;;
  Color                          := H_Window_Baggrund;
  Panel1.Color                   := H_Panel_Afstemning;
  ComboKonto.Color               := H_Combo_Color;

  // Database
  ZQuery1.Connection := MainData.MainDataModule.ZConnection1;

  // Init
  AlleData                       := TList.Create;

  PeriodeNrListe                 := TStringList.Create;
  PeriodeNrListe.Sorted          := False;
  KontiListe                     := TStringList.Create;
  KontiListe.Sorted              := False;
  KontiListeNr                   := TStringList.Create;
  KontiListeNr.Sorted            := False;
  KontiListeVisning              := TStringList.Create;
  KontiListeVisning.Sorted       := False;
  KontiListeBrugerNr             := TStringList.Create;
  KontiListeBrugerNr.Sorted      := True;
  KontiListeBrugerNr.CustomSort(@CompareStringsAsIntegers);
  FormaalNrListe                 := TStringList.Create;
  FormaalNrListe.Sorted          := False;

  SortColumn := - 1;
  UpdateGrid := True;
  DontUpdate := True;
  // Dato felter
  IndlaesKonti;
  DatoFra.Value := StrToDate('01-01-1990');
  DatoTil.Value:= StrToDate('01-01-2100');

  IndlaesOkoMaerker;
  Indstil;
  IndlaesPeriode;
  DontUpdate := False;
  UpdateGrid := False;
(*  IndlaesTilAlleData(KontiListeNr.Strings[ComboKonto.ItemIndex]);
  Indlaes;*)
  // Andet

end;


//**********************************************************
// Combo formaal
//**********************************************************
procedure TSeKontoForm.ComboFormaalChange(Sender: TObject);
begin
  Opdater;
end;

//**********************************************************
// Combo Konto change
//**********************************************************
procedure TSeKontoForm.ComboKontoChange(Sender: TObject);
begin
  Opdater;
end;

//**********************************************************
// Combo periode
//**********************************************************
procedure TSeKontoForm.ComboPeriodeChange(Sender: TObject);
begin
  Opdater;
end;

//**********************************************************
// Dato fra ændret
//**********************************************************
procedure TSeKontoForm.DatoFraChange(Sender: TObject);
begin
  Opdater;
end;

//**********************************************************
// Dato til ændret
//**********************************************************
procedure TSeKontoForm.DatoTilChange(Sender: TObject);
begin
  Opdater;
end;

//**********************************************************
// Destroy
//**********************************************************
procedure TSeKontoForm.FormDestroy(Sender: TObject);
begin
  AlleData.Free;
  PeriodeNrListe.Free;
  KontiListeBrugerNr.Free;
  KontiListeNr.Free;
  KontiListeVisning.Free;
  KontiListe.Free;
  FormaalNrListe.Free;
end;

//**********************************************************
// Form resize
//**********************************************************
procedure TSeKontoForm.FormResize(Sender: TObject);
begin
  If Height < MinHeight Then
    Height := MinHeight;
end;
//**********************************************************
// Hjælp
//**********************************************************
procedure TSeKontoForm.HelpExecute(Sender: TObject);
begin
  ShowMessage('Hjælp');
end;

//**********************************************************
// Luk
//**********************************************************
procedure TSeKontoForm.LukExecute(Sender: TObject);
begin
  Close;
end;

//**********************************************************
// Stringgrid: Checkbox clicked
//**********************************************************
procedure TSeKontoForm.StringGrid1CheckboxToggled(sender: TObject; aCol,
  aRow: Integer; aState: TCheckboxState);
Var   HelpDataKonto       : PDataKonto;
      A                   : Integer;
begin
  HelpDataKonto := AlleData[StrToInt(StringGrid1.Cells[SeRowNr,aRow])-1];
  If aState = cbChecked Then
    Begin
      HelpDataKonto^.Checked:='1';
    end
  Else
    Begin
      HelpDataKonto^.Checked:='0';
    end;
  Indlaes;
end;

//**********************************************************
// StringGrid Compare cells
//**********************************************************
procedure TSeKontoForm.StringGrid1CompareCells(Sender: TObject; ACol, ARow,
  BCol, BRow: Integer; var Result: integer);
Var Help1, Help2 : String;
    HelpTal : Currency;
begin
  If (ACol = SeNr) or (ACol = SeCheck) Then
    Begin // Sorter integer
      Result := StrToIntDef(StringGrid1.Cells[ACol,ARow],0) - StrToIntDef(StringGrid1.Cells[BCol,BRow],0);
      If StringGrid1.SortOrder = soDescending Then
        Begin
          Result := -Result;
        end;
    end
  Else If (ACol = SeDebet) or (ACol = SeKredit) or (ACol = SeSaldo)Then
    Begin // Sorter beløb
      Help1 := FjernPunktum(StringGrid1.Cells[ACol,ARow]);
      Help2 := FjernPunktum(StringGrid1.Cells[BCol,BRow]);
      Result := Round(StrToCurrDef(Help1,0) - StrToCurrDef(Help2,0));
      If StringGrid1.SortOrder = soDescending Then
        Begin
          Result := -Result;
        end;
    end
  Else If (ACol = SeDato) Then
    Begin // Sorter dato
      Result := CompareDate(StrToDate(StringGrid1.Cells[ACol,ARow]),StrToDate(StringGrid1.Cells[BCol,BRow]));
      If StringGrid1.SortOrder = soDescending Then
        Begin
          Result := -Result;
        end;
    end
  Else If (ACol = SeTekst) Then
    Begin // Sorter beskrivelse
      Result := CompareStr(StringGrid1.Cells[ACol,ARow],StringGrid1.Cells[BCol,BRow]);
      If StringGrid1.SortOrder = soDescending Then
        Begin
          Result := -Result;
        end;
    end;
end;

//**********************************************************
// StringGrid Select editor
//**********************************************************
procedure TSeKontoForm.StringGrid1SelectEditor(Sender: TObject; aCol,
  aRow: Integer; var Editor: TWinControl);
begin
  If      aCol = SeCheck Then
    Begin
      Editor := StringGrid1.EditorByStyle(cbsCheckboxColumn);
    end
  Else
    Begin
      Editor := StringGrid1.EditorByStyle(cbsNone);
    end;
end;

//**********************************************************
// Udskriv
//**********************************************************
procedure TSeKontoForm.UdskrivExecute(Sender: TObject);
begin
  ShowMessage('uDSKRIV');
end;

//**********************************************************
// Indlæs konti
//**********************************************************
procedure TSeKontoForm.IndlaesKonti;
Var A : Integer;
Begin
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from kontobes where Afd = ' + CurrentAfd);
    End;
  ZQuery1.Open;
  A := 0;
  ZQuery1.First;
  While Not ZQuery1.EOF Do
    Begin
      If ZQuery1.FieldByName('afd').AsString = CurrentAfd Then
        Begin
          ComboKonto.AddRow;
          ComboKonto.Cells[0,A] := ZQuery1.FieldByName('BrugerKonto').asString;
          ComboKonto.Cells[1,A] := ZQuery1.FieldByName('Beskrivelse').asString;
          ComboKonto.Cells[2,A] := ZQuery1.FieldByName('id').asString;
          ComboKonto.Cells[3,A] := ZQuery1.FieldByName('VisningD_K').asString;
          Inc(A);
        end;
      ZQuery1.Next;
    end;
  If ComboKonto.Items.Count > 0 Then
    Begin
      ComboKonto.ItemIndex := 0;
    end;
(*  While Not ZQuery1.EOF Do
    Begin
      If ZQuery1.FieldByName('afd').AsString = CurrentAfd Then
        Begin
          A := KontiListeBrugerNr.Add(ZQuery1.FieldByName('BrugerKonto').asString);
          KontiListeNr.Insert(A,ZQuery1.FieldByName('id').asString);
          KontiListe.Insert(A,ZQuery1.FieldByName('Beskrivelse').asString);
          KontiListeVisning.Insert(A,ZQuery1.FieldByName('VisningD_K').asString);
        end;
      ZQuery1.Next;
    end;*)
end;

//**********************************************************
// Indstil
//**********************************************************
procedure TSeKontoForm.Indstil;
begin
  Indstil_StringGrid_NonEdit(StringGrid1);

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
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;

  StringGrid1.Columns[SeCheck].Title.Caption        := '*';
  StringGrid1.Columns[SeCheck].Width                := 30;
  StringGrid1.Columns[SeCheck].ButtonStyle          := cbsCheckboxColumn;

  StringGrid1.Columns[SeDato].Title.Caption         := 'Dato';
  StringGrid1.Columns[SeDato].Width                 := 70;
  StringGrid1.Columns[SeDato].Alignment             := taLeftJustify;

  StringGrid1.Columns[SeTekst].Title.Caption        := 'Beskrivelse';
  StringGrid1.Columns[SeTekst].Width                := 210;
  StringGrid1.Columns[SeTekst].Alignment             := taLeftJustify;

  StringGrid1.Columns[SeNr].Title.Caption           := 'Nr';
  StringGrid1.Columns[SeNr].Width                   := 60;
  StringGrid1.Columns[SeNr].Alignment               := taRightJustify;

  StringGrid1.Columns[SeDebet].Title.Caption        := 'Debet';
  StringGrid1.Columns[SeDebet].Width                := 95;
  StringGrid1.Columns[SeDebet].Alignment            := taRightJustify;

  StringGrid1.Columns[SeKredit].Title.Caption       := 'Kredit';
  StringGrid1.Columns[SeKredit].Width               := 95;
  StringGrid1.Columns[SeKredit].Alignment           := taRightJustify;

  StringGrid1.Columns[SeSaldo].Title.Caption        := 'Saldo';
  StringGrid1.Columns[SeSaldo].Width                := 95;
  StringGrid1.Columns[SeSaldo].Alignment            := taRightJustify;

  StringGrid1.Columns[SeFormaal].Title.Caption      := 'Formaal';
  StringGrid1.Columns[SeFormaal].Width              := 80;
  StringGrid1.Columns[SeFormaal].Visible            := False;

  StringGrid1.Columns[SeKontoNr].Title.Caption      := 'KontoNr';
  StringGrid1.Columns[SeKontoNr].Width              := 80;
  StringGrid1.Columns[SeKontoNr].Visible            := False;

  StringGrid1.Columns[SeKontoNavn].Title.Caption    := 'Kontonavn';
  StringGrid1.Columns[SeKontoNavn].Width            := 80;
  StringGrid1.Columns[SeKontoNavn].Visible          := False;

  StringGrid1.Columns[SeRowNr].Title.Caption        := 'Id';
  StringGrid1.Columns[SeRowNr].Width                := 50;
  StringGrid1.Columns[SeRowNr].Visible              := False;

  StringGrid1.Options := StringGrid1.Options +
    [goRowSelect, goEditing, goTabs];

end;

//**********************************************************
// Indlæs
//**********************************************************
Procedure TSeKontoForm.Indlaes;
Var A : Integer;
    HelpDataKonto       : PDataKonto;
    OldRow              : Integer;
    RowSort             : Integer;
Begin
  OldRow               := StringGrid1.Row;
  UpdateGrid           := True;
  A                    := 1;
  StringGrid1.RowCount := 1;
  StringGrid1.BeginUpdate;
  AntalBilag           := 0;
  SumDebit             := 0;
  SumKredit            := 0;
  SumSaldo             := 0;
  While A <= AlleData.Count Do
    Begin
      HelpDataKonto := AlleData[A-1];
      If (HelpDataKonto^.Checked = '1')  Then
        Begin
          SumDebit := SumDebit + HelpDataKonto^.DebitBeloeb;
          SumKredit := SumKredit + HelpDataKonto^.KreditBeloeb;
          If HelpDataKonto^.VisningDK Then
            Begin
              SumSaldo := SumDebit - SumKredit + SumFoerDebit - SumFoerKredit;//nyt
            End
          Else
            Begin
              SumSaldo := SumKredit - SumDebit + SumFoerKredit- SumFoerDebit ;//nyt
            End;
          HelpDataKonto^.Saldo := Sumsaldo;
          Inc(AntalBilag);
        End;
      // Indsæt i grid
      StringGrid1.RowCount                 := StringGrid1.RowCount + 1;
      StringGrid1.Cells[SeCheck,A]         := HelpDataKonto^.Checked;
      StringGrid1.Cells[SeDato,A]          := HelpDataKonto^.Dato;
      StringGrid1.Cells[SeTekst,A]         := HelpDataKonto^.Tekst;
      StringGrid1.Cells[SeNr,A]            := HelpDataKonto^.BilagNr;
      StringGrid1.Cells[SeDebet,A]         :=
        FloatToStrF(HelpDataKonto^.DebitBeloeb,ffNumber,18,2);
      StringGrid1.Cells[SeKredit,A]        :=
        FloatToStrF(HelpDataKonto^.KreditBeloeb,ffNumber,18,2);
      StringGrid1.Cells[SeSaldo,A]         :=
        FloatToStrF(HelpDataKonto^.Saldo,ffNumber,18,2);
      StringGrid1.Cells[SeFormaal,A]       := HelpDataKonto^.Formaal;
      StringGrid1.Cells[SeKontoNr,A]       := HelpDataKonto^.Konto;
      StringGrid1.Cells[SeKontoNavn,A]     := HelpDataKonto^.KontoNavn;
      StringGrid1.Cells[SeRowNr,A]         := IntToStr(A);
      Inc(A);
    end;
  StringGrid1.EndUpdate;
  LabelDebet.Caption  := FloatToStrF(SumDebit,ffNumber,18,2);
  LabelKredit.Caption := FloatToStrF(SumKredit,ffNumber,18,2);
  LabelSaldo.Caption  := FloatToStrF(SumSaldo,ffNumber,18,2);
  LabelAntal.Caption  := IntToStr(AntalBilag) + '(' + IntToStr(StringGrid1.RowCount-1) + ')';
  If SortColumn <> - 1 Then
    StringGrid1.SortColRow(True,SortColumn);
  UpdateGrid := False;
  StringGrid1.Row := OldRow;
end;


//**********************************************************
// Indlæs økomærker
//**********************************************************
procedure TSeKontoForm.IndlaesOkoMaerker;
Var A : Integer;
Begin
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from OkoMaerkeDef where Afd = ' + CurrentAfd);
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount = 0 Then
    Begin
      StringGrid1.RowCount  := 1;
      // MessageDlg('Økomærker/Formål ikke defineret!',mtInformation,[mbOk],0);
      Exit;
    end;

  ComboFormaal.Items.Clear;
  // Dummmy ind først
  ComboFormaal.Items.Add('');
  FormaalNrListe.Add('');
  ZQuery1.First;
  While Not ZQuery1.EOF Do
    Begin
      A := ComboFormaal.Items.Add(ZQuery1.FieldByName('Beskrivelse').AsString);
      FormaalNrListe.Insert(A,ZQuery1.FieldByName('Nr').AsString);
      ZQuery1.Next;
    end;
  ComboFormaal.ItemIndex:=0;
End;

//**********************************************************
// Indlæs periode
//**********************************************************
procedure TSeKontoForm.IndlaesPeriode;
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
      StringGrid1.RowCount  := 1;
      MessageDlg('Perioder ikke defineret!',mtInformation,[mbOk],0);
      Exit;
    end;

  ComboPeriode.Items.Clear;
  ZQuery1.First;
  While Not ZQuery1.EOF Do
    Begin
      If ZQuery1.FieldByName('Afd').AsString = CurrentAfd Then
        Begin
          A := ComboPeriode.Items.Add(ZQuery1.FieldByName('Periode').AsString);
          PeriodeNrListe.Insert(A,ZQuery1.FieldByName('Nr').AsString);
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

//**********************************************************
// Indlæs til alle data
//**********************************************************
procedure TSeKontoForm.IndlaesTilAlleData(KontoNrStr : String);
Var
  Naeste              : Boolean;
  VisBilag            : Boolean;
  DatoBilagEfterHelp  : TDateTime;
  DatoBilagFoerHelp   : TDateTime;
  HelpDataKonto       : PDataKonto;

begin
  { AlleData skal resettes}
  AlleData.Clear;
  { Konverter data fra dialogbox }
  DatoBilagEfterHelp  := DatoFra.Value;
  DatoBilagFoerHelp   := DatoTil.Value;
  //
  SumFoerDebit  := 0;
  SumFoerKredit := 0;
  SumKredit     := 0;
  SumSaldo      := 0;
  { Her skal data findes frem, bilag for bilag }
//  UpdateGrid := True;
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from bilag where (Afd = ' + CurrentAfd + ') and (periode = ' +
        PeriodeNrListe.Strings[ComboPeriode.ItemIndex] + ')');
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount = 0 Then
    Begin
      MessageDlg('Ingen bilag endnu!',mtInformation,[mbOk],0);
      Exit;
    end;
  ZQuery1.First;
  While Not ZQuery1.EOF Do
    Begin
      // ** Check med maske - felt for felt
      { ** Dato ligger før den valgte tidsafsnit men i denne periode  }
      Naeste := Not (ZQuery1.FieldByName('Dato').AsDateTime < DatoBilagEfterHelp);
      // Summen af bilag skal udregnes før den valgte dato
      If Not Naeste and
         (KontoNrStr = ZQuery1.FieldByName('Konto').AsString) Then
        Begin
          If ZQuery1.FieldByName('D-K').AsString = 'D' Then
            Begin
              SumFoerDebit  := SumFoerDebit +
                ZQuery1.FieldByName('Beloeb').AsCurrency;
            End
          Else
            Begin
              SumFoerKredit := SumFoerKredit +
                ZQuery1.FieldByName('Beloeb').AsCurrency;
            End;
        End;
      ZQuery1.Next;
    End;
  // Indsæt primo
  If ZQuery1.RecordCount = 0 Then Exit;
  New(HelpDataKonto);
  HelpDataKonto^.Dato      := DateToStr(DatoFra.Value -1);
  HelpDataKonto^.Tekst     := 'Primo';
  HelpDataKonto^.BilagNr   := '';
  HelpDataKonto^.Konto     := KontiListeBrugerNr.Strings[ComboKonto.ItemIndex];
  // Navn på bruger konto
  HelpDataKonto^.Kontonavn := ComboKonto.Text;
  HelpDataKonto^.VisningDK := (KontiListeVisning.Strings[ComboKonto.ItemIndex]='T');
  HelpDataKonto^.DebitBeloeb  := SumFoerDebit;
  HelpDataKonto^.KreditBeloeb := SumFoerKredit;
  HelpDataKonto^.Saldo := SumFoerDebit - SumFoerKredit;
  //** Checked sættes
  HelpDataKonto^.Checked := '0';
  AlleData.Add(HelpDataKonto);

  // Nu indlæses bilag
  ZQuery1.First;
  While not ZQuery1.EOF Do
    Begin
      { ** Check med maske - felt for felt }
      VisBilag := False;
      // Check hvilke bilag der skal vises
      { ** Dato efter  }
      Naeste :=  Not (
            ZQuery1.FieldByName('Dato').AsDateTime >=  DatoBilagEfterHelp);
      { ** Dato før  }
      If Not Naeste Then
        Begin
          Naeste :=  Not (
            ZQuery1.FieldByName('Dato').AsDateTime <= DatoBilagFoerHelp);
        End;
      { ** Formål  }
      If Not Naeste Then
        Begin
          if ComboFormaal.ItemIndex <> 0 then
            Begin
              Naeste :=  Not (
                ZQuery1.FieldByName('OkoNr').AsString =
                  FormaalNrListe.Strings[ComboFormaal.ItemIndex]);
            End;
        End;
      // ** konto = udvalgt
      If Not Naeste And
         (KontoNrStr = ZQuery1.FieldByName('Konto').AsString) Then
        Begin
          New(HelpDataKonto);
          HelpDataKonto^.VisningDK := (KontiListeVisning.Strings[
            KontiListeNr.IndexOf(ZQuery1.FieldByName('Konto').AsString)] ='T');
          VisBilag := True;
          If ZQuery1.FieldByName('D_K').AsString = 'D' Then
            Begin
              HelpDataKonto^.KreditBeloeb := 0;
              HelpDataKonto^.DebitBeloeb  := ZQuery1.FieldByName('Beloeb').AsCurrency;
              If HelpDataKonto^.VisningDK Then
                Begin
                  HelpDataKonto^.Saldo := SumSaldo + HelpDataKonto^.DebitBeloeb +
                    SumFoerDebit - SumFoerKredit;
                End
              Else
                Begin
                  HelpDataKonto^.Saldo := SumSaldo - HelpDataKonto^.DebitBeloeb -
                    SumFoerDebit + SumFoerKredit;
                End;
            End
          Else
            Begin
              HelpDataKonto^.DebitBeloeb := 0;
              HelpDataKonto^.KreditBeloeb  := ZQuery1.FieldByName('Beloeb').AsCurrency;
              If HelpDataKonto^.VisningDK Then
                Begin
                  HelpDataKonto^.Saldo := SumSaldo - HelpDataKonto^.KreditBeloeb +
                    SumFoerDebit - SumFoerKredit;
                End
              Else
                Begin
                  HelpDataKonto^.Saldo := SumSaldo + HelpDataKonto^.KreditBeloeb -
                    SumFoerDebit + SumFoerKredit;
                End;
            End;
        End;
      If VisBilag Then
        Begin
          HelpDataKonto^.Dato      := ZQuery1.FieldByName('Dato').AsString;
          HelpDataKonto^.Tekst     := ZQuery1.FieldByName('Tekst').AsString;
          HelpDataKonto^.BilagNr   := ZQuery1.FieldByName('BilagsNr').AsString;
          HelpDataKonto^.Formaal   := ZQuery1.FieldByName('OkoNr').AsString;
          HelpDataKonto^.Konto     := KontiListeBrugerNr.Strings[
            KontiListeNr.IndexOf(ZQuery1.FieldByName('Konto').AsString)];
          // Navn på bruger konto
          HelpDataKonto^.Kontonavn := KontiListe.Strings[
            KontiListeNr.IndexOf(ZQuery1.FieldByName('Konto').AsString)];
          //** Checked sættes
          HelpDataKonto^.Checked := '1';
          // Saldo
          SumSaldo := HelpDataKonto^.Saldo;
          //** Data indsættes i AlleData - TList
          AlleData.Add(HelpDataKonto);
        End;
      ZQuery1.Next;
    End;
end;


//**********************************************************
// Opdater
//**********************************************************
procedure TSeKontoForm.Opdater;
Begin
  If Not DontUpdate Then
    Begin
      IndlaesTilAlleData(ComboKonto.Cells[2,ComboKonto.ItemIndex]);
      Indlaes;
    end;
end;


End.
