//***************************************************************************//
//  Holbæk                                                                   //
//  Copyright by Claus Moeller 2013-2016                                     //
//  Kassekladde                                                              //
//  Version                                                                  //
//  05.12.13                                                                 //
//***************************************************************************//
(* Holbæk - Claus Møller 26.10.13 *)
unit kassekladde;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  ComCtrls, ActnList, StdCtrls, Grids, EditBtn, Spin, Buttons, Menus,
  ZDataset, DateUtils;

type

  { TKasseKladdeForm }

 PDataKonto = ^TDataKonto;
 TDataKonto = Record
   KontoNr           : LongInt;
   BrugerKonto       : LongInt;
   Beskrivelse       : String;
   DebetBogfoert     : Currency;
   KreditBogFoert    : Currency;
   DebetKassekladde  : Currency;
   KreditKassekladde : Currency;
   StartSaldoBilag   : Currency;
   StartSaldoKasse   : Currency;
   BeregnetSaldo     : Currency;
   SumFra            : LongInt;
   SumTil            : LongInt;
   KontoType         : Integer;
   Moms              : String;
   Genvej            : String;
   SumMed            : Boolean;
   SumType           : Integer;
   VisningDK         : Boolean;
 End;

 PDataRefKonto = ^TDataRefKonto;
 TDataRefKonto = Record
   RefBeregnetSaldo   : Currency;
 End;

 PDataKassekladde = ^TDataKassekladde;
 TDataKassekladde = Record
   BL               : String;
   Dato             : String;
   Konto            : String;
   Kontonavn        : String;
   Tekst            : String;
   DK               : String;
   Beloeb           : String;
   Moms             : String;
   ModKonto         : String;
   ModKontoNavn     : String;
 End;

 PDataKassekladdeDef = ^TDataKassekladdeDef;
 TDataKassekladdeDef = Record
   Nr              : String;
   Beskrivelse     : String;
   Toemmes         : Boolean;
 End;

 EMyException = class(Exception);


 TKasseKladdeForm = class(TForm)
    MenuItem3: TMenuItem;
    ToolButton11: TToolButton;
    Udskriv_Postering: TAction;
    ToolButton10: TToolButton;
    Udskriv_kontoplan: TAction;
    ToolButton9: TToolButton;
    Udskriv_Kassekladde: TAction;
    BogfoerAlle: TAction;
    MenuItem2: TMenuItem;
    SpeedSumKassekladde: TSpeedButton;
    SpeedSumBogfoert: TSpeedButton;
    SpeedSumBogfoertPlusKassekladde: TSpeedButton;
    SpeedRefreshAfstemningskonti: TSpeedButton;
    StringGrid2: TStringGrid;
    StringGridPost: TStringGrid;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    VisAfstemningsKonti: TAction;
    Bogfoer: TAction;
    CheckBilagFormaal: TCheckBox;
    GroupBox4: TGroupBox;
    Label5: TLabel;
    AfstemningsSpeed: TSpeedButton;
    StatusBilagLabel: TLabel;
    Panel2: TPanel;
    AfstemStringGrid: TStringGrid;
    TjekKassekladde: TAction;
    CheckBoxSmartDefaultTekst: TCheckBox;
    CheckKunAfstemningskonti: TCheckBox;
    CheckVisCombo: TCheckBox;
    ComboKassekladde: TComboBox;
    DateTimePosteringFra: TDateEdit;
    DateTimePosteringTil: TDateEdit;
    GroupAfstemningskonto: TGroupBox;
    GroupBox3: TGroupBox;
    Group_DefaultSmartTekst: TGroupBox;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    MenuItem1: TMenuItem;
    PanelIndstilling: TPanel;
    PopupMenuRediger: TPopupMenu;
    RedigerAfstemningskonti: TAction;
    ComboFormaal: TComboBox;
    ComboPeriode: TComboBox;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBoxIndstillinger: TGroupBox;
    KassekladdeOversigtPanel: TPanel;
    Label1: TLabel;
    Kassekladde_Tjek_Panel: TPanel;
    AfstemningsPanel: TPanel;
    Panel1: TPanel;
    TjekPanelButton: TPanel;
    SpeedCloseTjekPanel: TSpeedButton;
    TjekMemo: TMemo;
    Slet: TAction;
    NytBilag: TAction;
    DateEdit1: TDateEdit;
    FloatSpinEdit1: TFloatSpinEdit;
    Luk: TAction;
    ActionList1: TActionList;
    PageControl1: TPageControl;
    Kassekladde_Page: TTabSheet;
    PanelKassekladde: TPanel;
    StringGrid1: TStringGrid;
    TabKontoplan: TTabSheet;
    Posteringsoversigt: TTabSheet;
    Indstilinger: TTabSheet;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ZQuery1: TZQuery;
    ZQuery2: TZQuery;
    ZBogfoerKassekladde: TZQuery;
    ZBogfoerMoms: TZQuery;
    ZBogfoerBilag: TZQuery;
    ZTable1: TZTable;
    procedure AfstemningsSpeedClick(Sender: TObject);
    procedure BogfoerAlleExecute(Sender: TObject);
    procedure BogfoerExecute(Sender: TObject);
    procedure CheckKunAfstemningskontiChange(Sender: TObject);
    procedure CheckVisComboChange(Sender: TObject);
    procedure ComboFormaalChange(Sender: TObject);
    procedure ComboKassekladdeChange(Sender: TObject);
    procedure ComboPeriodeChange(Sender: TObject);
    procedure DateEdit1Exit(Sender: TObject);
    procedure DateEdit1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure LukExecute(Sender: TObject);
    procedure NytBilagExecute(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure PageControl1Changing(Sender: TObject; var AllowChange: Boolean);
    procedure RedigerAfstemningskontiExecute(Sender: TObject);
    procedure SletExecute(Sender: TObject);
    procedure SpeedCloseTjekPanelClick(Sender: TObject);
    procedure SpeedRefreshAfstemningskontiClick(Sender: TObject);
    procedure SpeedSumBogfoertClick(Sender: TObject);
    procedure SpeedSumBogfoertPlusKassekladdeClick(Sender: TObject);
    procedure SpeedSumKassekladdeClick(Sender: TObject);
    procedure StringGrid1BeforeSelection(Sender: TObject; aCol, aRow: Integer);
    procedure StringGrid1ButtonClick(Sender: TObject; aCol, aRow: Integer);
    procedure StringGrid1Click(Sender: TObject);
    procedure StringGrid1CompareCells(Sender: TObject; ACol, ARow, BCol,
      BRow: Integer; var Result: integer);
    procedure StringGrid1EditingDone(Sender: TObject);
    procedure StringGrid1Enter(Sender: TObject);
    procedure StringGrid1GetEditText(Sender: TObject; ACol, ARow: Integer;
      var Value: string);
    procedure StringGrid1PickListSelect(Sender: TObject);
    procedure StringGrid1SelectEditor(Sender: TObject; aCol, aRow: Integer;
      var Editor: TWinControl);
    procedure StringGrid1ValidateEntry(sender: TObject; aCol, aRow: Integer;
      const OldValue: string; var NewValue: String);
    procedure StringGrid2CompareCells(Sender: TObject; ACol, ARow, BCol,
      BRow: Integer; var Result: integer);
    procedure StringGrid2DblClick(Sender: TObject);
    procedure StringGridPostCompareCells(Sender: TObject; ACol, ARow, BCol,
      BRow: Integer; var Result: integer);
    procedure TjekKassekladdeExecute(Sender: TObject);
    procedure BeregnMoms(Beloeb : Double; MomsStr : String;
       Var Saldo,Moms : String);
    procedure OpdaterStatusLinie(ARow : Integer);
    procedure BeregnAfstemningskonti;
    procedure Udskriv_KassekladdeExecute(Sender: TObject);
    procedure Udskriv_kontoplanExecute(Sender: TObject);
    procedure Udskriv_PosteringExecute(Sender: TObject);
    procedure VisAfstemningsKontiExecute(Sender: TObject);
  private
    { private declarations }
    UpdateGrid         : Boolean;
    PeriodeNrListe     : TStringList;
    KontoBeskListe     : TStringList;
    KontoNrListe       : TStringList;
    BrugerNrListe      : TStringList;
    MomsKodeListe      : TStringList;
    MomsKodeNrListe    : TStringList;
    MomsBeregnListe    : TStringList;
    FormaalNrListe     : TStringList;
    AfstemningskontiListe   : TStringList;
    AfstemningskontiNrListe : TStringList;
    KassekladdeDefNrListe   : TList;

    Procedure IndstilKassekladdeGrid;
    Procedure IndstilAfstemStringGrid;
    procedure IndstilKontoplan;
    Procedure IndlaesBilag;
    procedure IndlaesPeriode;
    procedure IndlaesOkoMaerker;
    procedure IndlaesKonti;
    procedure IndlaesMomsKoder;
    procedure IndlaesAfstemningskonti;
    procedure IndlaesKassekladdeDef;
    procedure CheckKonto(Var Value : String);
    function  CheckShortCut(TheText : String; Var KOntoStr : String) : Boolean;
    function  FindNytBilagsNr : String;
    function  FoersteKonto : String;
    Procedure GemRowTilTabel;
    function  Forundersoegelse(NoKasse: String; NrStr : String;
       Var Svar : String) : Boolean;
    procedure IndlaesKontoplan;
    Procedure IndstilPosteringsOversigt;
    procedure IndlaesPostering;

  public
    { public declarations }
    AlleData  : TList;
    function  FindKontoBeskrivelse(BrugerNr : String) : String;
    function  FindKontoFraBruger(BrugerKontoNr : String) : String;
    function  FindBrugerFraKonto(KontoNr : String) : String;
    procedure BeregnKontiSaldi(Kassekladde, BogFoert : Boolean;
      VisningFra, VisningTil : TDateTime; PeriodeNr : String);
  end;

var
  KasseKladdeForm : TKasseKladdeForm;

implementation

{$R *.lfm}
Uses
  HolbaekConst, MainData, PickKonto, RedigerAfstemning, SuperPrint, DB;

Const
// Kassekladdens grid søjler tildeles et nr for indhold
KasDato       : Integer = 0;
KasBL         : Integer = 1;
KasKonto      : Integer = 2;
KasTekst      : Integer = 3;
KasMoms       : Integer = 4;
KasDK         : Integer = 5;
KasBeloeb     : Integer = 6;
KasAfstemning : Integer = 7;
KasOkoNr      : Integer = 8;
KasIdent      : Integer = 9;

// Afstemningskonto
AfNavn        : Integer = 0;
AfKonto       : Integer = 1;
AfStart       : Integer = 2;
AfBogfoert    : Integer = 3;
AfBevaeg      : Integer = 4;
AfSlut        : Integer = 5;
AfNr          : Integer = 6;

// Kontoplan faneblad
Konto_Nr      : Integer = 0;
Konto_Navn    : Integer = 1;
Konto_Type    : Integer = 2;
Konto_Moms    : Integer = 3;
Konto_Fra     : Integer = 4;
Konto_Til     : Integer = 5;
Konto_Genvej  : Integer = 6;
Konto_Saldo   : Integer = 7;
Konto_Ref     : Integer = 8;
Konto_id      : Integer = 9;

// Posterings grid kolonner
PostId        : Integer = 0;
PostDato      : Integer = 1;
PostNr        : Integer = 2;
PostArt       : Integer = 3;
PostKonto     : Integer = 4;
PostTekst     : Integer = 5;
PostMoms      : Integer = 6;
PostDK        : Integer = 7;
PostBeloeb    : Integer = 8;
PostFormaal   : Integer = 9;
PostBogfoert  : Integer = 10;



{ TKasseKladdeForm }

//**********************************************************
// Create
//**********************************************************
procedure TKasseKladdeForm.FormCreate(Sender: TObject);
begin
  // Farver
  ToolBar1.Color                 := H_Menu_knapper_Farve;

  PanelKassekladde.Color         := H_Page_Color;
  KassekladdeOversigtPanel.Color := H_Page_Color;
  Kassekladde_Tjek_Panel.Color   := H_Page_Color;
  AfstemningsPanel.Color         := H_Panel_Afstemning;
  Panel1.Color                   := H_Panel_Afstemning;
  PanelIndstilling.Color         := H_Panel_Afstemning;
  TjekMemo.Color                 := H_Memo_Color;
  ComboPeriode.Color             := H_Combo_Color;
  ComboKassekladde.Color         := H_Combo_Color;
  ComboFormaal.Color             := H_Combo_Color;

//  StatusBar1.Color  := H_Menu_knapper_Farve;
  Color                     := H_Window_Baggrund;
  // Indstil
  UpdateGrid                     := False;
  IndstilKassekladdeGrid;
  IndstilAfstemStringGrid;
  IndstilKontoplan;

  Kassekladde_Tjek_Panel.Visible := False;

  //  DateTimePosteringFra.f  Format      := 'dd-MM-yyyy';

  DateTimePosteringFra.Text      := '01-01-1900';
  DateTimePosteringTil.Text      := '01-01-2100';
  // Databaser
  ZQuery1.Connection             := MainDataModule.ZConnection1;
  ZQuery2.Connection             := MainDataModule.ZConnection1;
  ZBogfoerKassekladde.Connection := MainDataModule.ZConnection1;
  ZBogfoerMoms.Connection        := MainDataModule.ZConnection1;
  ZBogfoerBilag.Connection       := MainDataModule.ZConnection1;
  ZTable1.Connection             := MainDataModule.ZConnection1;

  // Indlæs
  AlleData                       := TList.Create;

  PeriodeNrListe                 := TStringList.Create;
  PeriodeNrListe.Sorted          := False;
  KontoBeskListe                 := TStringList.Create;
  KontoBeskListe.Sorted          := False;
  KontoNrListe                   := TStringList.Create;
  KontoNrListe.Sorted            := False;
  BrugerNrListe                  := TStringList.Create;
  BrugerNrListe.Sorted           := False;
  MomsKodeListe                  := TStringList.Create;
  MomsKodeListe.Sorted           := True;
  MomsKodeNrListe                := TStringList.Create;
  MomsKodeNrListe.Sorted         := False;
  MomsBeregnListe                := TStringList.Create;
  MomsBeregnListe.Sorted         := False;
  FormaalNrListe                 := TStringList.Create;
  FormaalNrListe.Sorted          := False;
  AfstemningsKontiNrListe        := TStringList.Create;
  AfstemningsKontiNrListe.Sorted := True;
  AfstemningsKontiListe          := TStringList.Create;
  AfstemningsKontiListe.Sorted   := False;
  KassekladdeDefNrListe          := TList.Create;

  IndlaesKonti;
  IndlaesPeriode;
  IndlaesMomskoder;
  IndlaesOkoMaerker;
  IndlaesAfstemningskonti;
  IndlaesKassekladdeDef;
  IndlaesBilag;
  BeregnKontiSaldi(True,True,StrToDate('01-01-1900'),StrToDate('01-01-2100'), PeriodeNrListe.Strings[ComboPeriode.ItemIndex]);
  BeregnAfstemningskonti;
  IndlaesKontoplan;
  IndstilPosteringsOversigt;
  IndlaesPostering;
  PageControl1Change(Sender); // Opdater knapper
  If StringGrid1.RowCount > 1 Then
    Begin
      OpdaterStatusLinie(1);
    end;
end;

//**********************************************************
// Destroy
//**********************************************************
procedure TKasseKladdeForm.FormDestroy(Sender: TObject);
begin
  KassekladdeDefNrListe.Free;
  AfstemningskontiListe.Free;
  AfstemningskontiNrListe.Free;
  FormaalNrListe.Free;
  MomsKodeListe.Free;
  MomsKodeNrListe.Free;
  MomsBeregnListe.Free;
  PeriodeNrListe.Free;
  KontoBeskListe.Free;
  KontoNrListe.Free;
  BrugerNrListe.Free;
  AlleData.Free;
end;

//**********************************************************
// Form Resize
//**********************************************************
procedure TKasseKladdeForm.FormResize(Sender: TObject);
begin
  If Width < 700 Then
    Begin
      Width := 700;
    end;
  If Height < 600 Then
    Begin
      Height := 600;
    end;
end;

//**********************************************************
// Indlæs afstemningskonti
//**********************************************************
procedure TKasseKladdeForm.IndlaesAfstemningskonti;
Var A : Integer;
Begin
  AfstemningskontiNrListe.Clear;
  AfstemningskontiListe.Clear;
  A                     := 1;
  With ZQuery1.SQL do
    Begin
      Clear;
      If CheckKunAfstemningskonti.Checked Then
        Begin
          Add('Select * from AfstemningsKonti where Afd = ' + CurrentAfd);
        End
      Else
        Begin
          Add('Select * from KontoBes where Afd = ' + CurrentAfd);
        End;
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount = 0 Then
    Begin
      //StringGrid1.RowCount  := 1;
      // MessageDlg('kassekladde tom!',mtInformation,[mbOk],0);
      Exit;
    end;
  If CheckKunAfstemningskonti.Checked Then
    Begin
      A := AfstemningskontiNrListe.Add('');
      AfstemningskontiListe.Insert(A,'');
      A := AfstemningskontiNrListe.Add('-1');
      AfstemningskontiListe.Insert(A,'-1');
      ZQuery1.First;
      While Not ZQuery1.EOF Do
        Begin
          If ZQuery1.FieldByName('afd').AsString = CurrentAfd Then
            Begin
              A := AfstemningskontiNrListe.Add(ZQuery1.FieldByName('BrugerKonto').AsString);
              AfstemningskontiListe.Insert(A,FindKontoBeskrivelse(ZQuery1.FieldByName('BrugerKonto').AsString));
            end;
          ZQuery1.Next;
        end;
    end
  Else
    Begin
      A := AfstemningskontiNrListe.Add('');
      AfstemningskontiListe.Insert(A,'');
      ZQuery1.First;
      While Not ZQuery1.EOF Do
        Begin
          If ZQuery1.FieldByName('Type').AsInteger <=1 Then
            Begin // Kun drift og status
              A := AfstemningskontiNrListe.Add(ZQuery1.FieldByName('BrugerKonto').AsString);
              AfstemningskontiListe.Insert(A,FindKontoBeskrivelse(ZQuery1.FieldByName('BrugerKonto').AsString));
            end;
          ZQuery1.Next;
        end;
    end;
End;

//**********************************************************
// Indlæs kassekladdedef
//**********************************************************
procedure TKasseKladdeForm.IndlaesKassekladdeDef;
Var Data : PDataKassekladdeDef;
    HelpNr : Integer;
Begin
  ComboKassekladde.Items.Clear;
  ComboKassekladde.Sorted := False;
  KasseKladdeDefNrListe.Clear;
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from kassekladdedef where Afd = ' + CurrentAfd);
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount = 0 Then
    Begin
      Exit;
    end;
  ZQuery1.First;
  While Not ZQuery1.EOF Do
    Begin
      New(Data);
      Data^.Nr          := ZQuery1.FieldByName('Nr').AsString;
      Data^.Beskrivelse := ZQuery1.FieldByName('Beskrivelse').AsString;
      Data^.Toemmes     := (ZQuery1.FieldByName('Toemmes').AsString = '1');
      KassekladdeDefNrListe.Add(Data);
      ComboKassekladde.Items.Add(ZQuery1.FieldByName('Beskrivelse').AsString);
      ZQuery1.Next;
    End;
  If ComboKassekladde.Items.Count > 0 Then
    Begin // Alt OK
      ComboKassekladde.ItemIndex := 0;
    End
  Else
    Begin // Opret kassekladde
      With ZQuery1.SQL do
        Begin
          Clear;
          Add('Select * from kassekladdedef order by nr');
        End;
      ZQuery1.Open;
      If ZQuery1.RecordCount = 0 Then
        Begin
          HelpNr := 1;
        end
      Else
        Begin
          ZQuery1.Last;
          HelpNr := ZQuery1.FieldByName('Nr').AsInteger + 1;
        end;
      Try
        ZQuery1.Append;
        ZQuery1.Edit;
        ZQuery1.FieldByName('Nr').AsInteger           := HelpNr;
        ZQuery1.FieldByName('Afd').AsString           := CurrentAfd;
        // Beskrivelse
        ZQuery1.FieldByName('Beskrivelse').AsString   := 'Aut. kassekladde';
        ZQuery1.FieldByName('Toemmes').AsBoolean      := True;
        ZQuery1.Post;
      Except
        ZQuery1.Cancel;
        MessageDlg('Kassekladde kunne ikke oprettes',mtError,[mbOK],0);
        Exit;
      End;
    End;
End;


//**********************************************************
// Indlæs bilag
//**********************************************************
procedure TKasseKladdeForm.IndlaesBilag;
Var A        : Integer;
    HelpData : PDataKassekladdeDef;
Begin
  UpdateGrid := True;
  New(HelpData);
  HelpData := KassekladdeDefNrListe.Items[ComboKassekladde.ItemIndex];
  A                     := 1;
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from KasseKladde where Afd = ' + CurrentAfd +
        ' and periode = ' + PeriodeNrListe.Strings[ComboPeriode.ItemIndex] +
        ' and nokasse = ' + HelpData^.Nr);
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount = 0 Then
    Begin
      StringGrid1.RowCount  := 1;
      // MessageDlg('kassekladde tom!',mtInformation,[mbOk],0);
      Exit;
    end;
  ZQuery1.First;
  StringGrid1.RowCount  := 1;
  StringGrid1.BeginUpdate;
  While Not ZQuery1.EOF Do
    Begin
      StringGrid1.RowCount := StringGrid1.RowCount + 1;
      StringGrid1.Cells[KasDato,A]       := DateToStr(JulianDateToDateTime(ZQuery1.FieldByName('dato').AsFloat));
      StringGrid1.Cells[KasBL,A]         := ZQuery1.FieldByName('bilagsnr').AsString;
      StringGrid1.Cells[KasKonto,A]      :=
        FindBrugerFraKonto(ZQuery1.FieldByName('konto').AsString);
      StringGrid1.Cells[KasTekst,A]      := ZQuery1.FieldByName('tekst').AsString;
      If ZQuery1.FieldByName('moms').IsNull Then
        Begin
          StringGrid1.Cells[KasMoms,A] := '';
        end
      Else
        Begin
          StringGrid1.Cells[KasMoms,A] :=
            MomsKodeListe.Strings[MomsKodeNrListe.IndexOf(ZQuery1.FieldByName('moms').AsString)];
        end;
      StringGrid1.Cells[KasDK,A]         := ZQuery1.FieldByName('d_k').AsString;
      StringGrid1.Cells[KasBeloeb,A]     :=
         FloatToStrF(ZQuery1.FieldByName('Beloeb').AsCurrency,ffNumber,18,2);
      StringGrid1.Cells[KasAfstemning,A] :=
        FindBrugerFraKonto(ZQuery1.FieldByName('modkonto').AsString);
      If Not ZQuery1.FieldByName('okonr').IsNull Then
         Begin
           ShowMessage(ZQuery1.FieldByName('okonr').AsString);
           StringGrid1.Cells[KasOkoNr,A]      :=
            ComboFormaal.Items[FormaalNrListe.IndexOf(ZQuery1.FieldByName('okonr').AsString)];
         end;
      StringGrid1.Cells[KasIdent,A]      := ZQuery1.FieldByName('nr').AsString;
      Inc(A);
      ZQuery1.Next;
    end;
  StringGrid1.EndUpdate;
  UpdateGrid := False;
end;

//**********************************************************
// Indlæs periode
//**********************************************************
procedure TKasseKladdeForm.IndlaesPeriode;
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
// Indlæs økomærker
//**********************************************************
procedure TKasseKladdeForm.IndlaesOkoMaerker;
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
// Indlæs momskoder
//**********************************************************
Procedure TKasseKladdeForm.IndlaesMomsKoder;
Var HelpNr : Integer;
Begin
  // Moms
  MomsBeregnListe.Clear;
  MomsBeregnListe.Add('0'); // Uden moms
  MomsKodeListe.Clear;
  MomsKodeListe.Add('');
  MomsKodeNrListe.Clear;
  MomsKodeNrListe.Add('');
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from Momskode where Afd = ' + CurrentAfd);
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount = 0 Then
    Begin
      //StringGrid1.RowCount  := 1;
      // MessageDlg('Momskoder ikke defineret!',mtInformation,[mbOk],0);
      Exit;
    end;
  ZQuery1.First;
  While Not ZQuery1.Eof Do
    Begin
      HelpNr := MomsKodeListe.Add(ZQuery1.FieldByName('Navn').AsString);
      // Moms type og størrelse indsættes i stringlist
      MomsBeregnListe.Insert(HelpNr,ZQuery1.FieldByName('Procent').AsString);
      MomsKodeNrListe.Insert(HelpNr,ZQuery1.FieldByName('Nr').AsString);
      ZQuery1.Next;
    End;
End;


//**********************************************************
// Find Konto beskrivelse
//**********************************************************
function TKasseKladdeForm.FindKontoBeskrivelse(BrugerNr : String) : String;
Var HelpNr : Integer;
Begin
  HelpNr := BrugerNrListe.IndexOf(BrugerNr);
  If HelpNr >= 0 Then
    Begin // Konti fundet
      Result := KontoBeskListe[HelpNr];
    End
  Else
    Begin
      Result := 'Ingen Valgt';
    End;
End;

//**********************************************************
// Find Konto fra Brugernr
//**********************************************************
function TKasseKladdeForm.FindKontoFraBruger(BrugerKontoNr : String) : String;
Var HelpNr : Integer;
begin
  Helpnr := BrugerNrListe.IndexOf(BrugerKontoNr);
  If HelpNr >= 0 Then
    Begin // Konti fundet
      Result := KontoNrListe.Strings[HelpNr];
    End
  Else
    Begin
      If BrugerKontoNr = '-1' Then
        Begin // Åbningsbalalnce
          Result := '-1';
        End
      Else
        Begin
          Result := 'Ingen valgt';
        End;
    End;
end;

//**********************************************************
// Find Bruger fra Kontonr
//**********************************************************
function TKasseKladdeForm.FindBrugerFraKonto(KontoNr : String) : String;
Var HelpNr : Integer;
begin
  Helpnr := KontoNrListe.IndexOf(KontoNr);
  If HelpNr >= 0 Then
    Begin // Konti fundet
      Result := BrugerNrListe.Strings[HelpNr];
    End
  Else
    Begin
      If KontoNr = '-1' Then
        Begin
          Result := '-1';
        End
      Else
        Begin
          Result := '???';
        End;
    End;
end;
//**********************************************************
// Check om konto er short-cut
//**********************************************************
function TKasseKladdeForm.CheckShortCut(TheText : String; Var KOntoStr : String) : Boolean;
begin
  // Find konto ud fra short-cut
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from Kontobes where Afd = ' + CurrentAfd +
          ' and KGB = ''' + UpperCase(TheText)+ '''');
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount = 0 Then
    Begin
      KontoStr := '';
    End
  Else
    Begin
      KontoStr := ZQuery1.FieldByName('BrugerKonto').AsString;
    End;
  CheckShortCut := (KontoStr <> '');
End;

//**********************************************************
// Indlæs konti
//**********************************************************
procedure TKasseKladdeForm.IndlaesKonti;
Var Nr : LongInt;
Begin
  Try
    With ZQuery1.SQL do
      Begin
        Clear;
        Add('Select * from kontobes where Afd = ' + CurrentAfd);
      End;
    ZQuery1.Open;
//    If ZQuery1.RecordCount > 0 Then ShowMessage('HGallo mand!' + IntToStr(ZQuery1.RecordCount));
    KontoBeskListe.Sorted := False;
    KontoBeskListe.Clear;
    KontoBeskListe.Add(''); // dummy for ingenting
    KontoNrListe.Clear;
    KontoNrListe.Add('');
    BrugerNrListe.Clear;
    BrugerNrListe.Add('');
    While not ZQuery1.EOF Do
      Begin
        Nr := KontoBeskListe.Add(ZQuery1.FieldByName('Beskrivelse').AsString);
        KontoNrListe.Insert(Nr,ZQuery1.FieldByName('Id').AsString);
        BrugerNrListe.Insert(Nr,ZQuery1.FieldByName('BrugerKonto').AsString);
        ZQuery1.Next;
      end;
  Except
  End;
end;

//**********************************************************
// Checker konto
//**********************************************************
procedure TKasseKladdeForm.CheckKonto(Var Value : String);
Var HelpKontoStr : String;
begin
  If (StringGrid1.Col = KasKonto) Then
    Begin
      HelpKontoStr := FindKontoFraBruger(Value);
      If HelpKontoStr <> 'Ingen valgt' Then
        Begin // Konto fundet
          If Value = '' Then
            Begin
              Raise Exception.Create('Konto skal vælges!');
            End
          Else
            Begin
              // Find konto
              With ZQuery1.SQL do
                Begin
                  Clear;
                  Add('Select * from kontobes where id = ' + HelpkontoStr);
                End;
              ZQuery1.Open;
              // Konto type
              If ZQuery1.FieldByName('Type').AsInteger > 1 Then
                Begin // Konto defineret til tekst eller sum
                  Raise Exception.Create('Konto skal være drift eller status!');
                End;
              // Direkte
              If Not ZQuery1.FieldByName('Direkte').AsBoolean Then
                Begin // Må ikke konteres på den direkte
                  Raise Exception.Create('Der må ikke konteres direkte på denne konto!');
                End;
              // Spærret
              If ZQuery1.FieldByName('Spaerret').AsBoolean Then
                Begin // Må ikke konteres på den direkte
                  Raise Exception.Create('Kontoen: ' +
                    ZQuery1.FieldByName('Beskrivelse').AsString + ' er spærret!');
                End;
              // Moms skal findes
              If ZQuery1.FieldByName('MomsKode').IsNull Then
                Begin
                  StringGrid1.Cells[KasMoms,StringGrid1.Row] :='';
                end
              Else
                Begin
                  ShowMessage(':'+ZQuery1.FieldByName('MomsKode').AsString+':');
                  StringGrid1.Cells[KasMoms,StringGrid1.Row] :=
                    MomsKodeListe.Strings[MomsKodeNrListe.
                     IndexOf(ZQuery1.FieldByName('MomsKode').AsString)];
                end;
              // Default tekst
              If CheckBoxSmartDefaultTekst.Checked Then
                Begin // Såfremt det ikke er standard tekst behold den gamle
                  If StringGrid1.Cells[KasTekst,StringGrid1.Row] <>
                     ZQuery1.FieldByName('DefaultTekst').AsString Then
                    Begin // Forskellig fra default
                      If StringGrid1.Cells[KasTekst,StringGrid1.Row] = '' Then
                        Begin
                          StringGrid1.Cells[KasTekst,StringGrid1.Row] :=
                            ZQuery1.FieldByName('DefaultTekst').AsString;
                        End;
                    End
                  Else
                    Begin
                      StringGrid1.Cells[KasTekst,StringGrid1.Row] :=
                        ZQuery1.FieldByName('DefaultTekst').AsString;
                    End;
                End
              Else
                Begin // Uanset hvad indsæt den default tekst
                  StringGrid1.Cells[KasTekst,StringGrid1.Row] :=
                    ZQuery1.FieldByName('DefaultTekst').AsString;
                End;
              // Default D_K
              If ZQuery1.FieldByName('Default_D').AsBoolean Then
                Begin
                  StringGrid1.Cells[KasDK,StringGrid1.Row] := 'D';
                End
              Else
                Begin
                  StringGrid1.Cells[KasDK,StringGrid1.Row] := 'K';
                End;
              // Default modkonto
              If ZQuery1.FieldByName('DefaultModkonto').AsInteger <> -1 Then
                Begin
                  StringGrid1.Cells[KasAfstemning,StringGrid1.Row] :=
                  FindBrugerFraKonto(
                    ZQuery1.FieldByName('DefaultModkonto').AsString);
                End
              Else
                Begin
                  StringGrid1.Cells[KasAfstemning,StringGrid1.Row] := '';
                End;
              // Formål
              If Not ZQuery1.FieldByName('OkoNr').IsNull then
                Begin // Indsæt default
                  StringGrid1.Cells[KasOkoNr,StringGrid1.Row] :=
                    ComboFormaal.Items[
                      FormaalNrListe.IndexOf(ZQuery1.FieldByName('OkoNr').AsString)];
                End;
            End;
        End
      Else
        Begin
          // Check om det skulle være en short cut
          If Value = '' Then
            Begin
              Raise Exception.Create('Konto skal vælges!');
            End;
          If CheckShortCut(Value,HelpKontoStr) Then
            Begin // Fundet
              Value := HelpKontoStr;
              CheckKonto(Value);
            End
          Else
            Begin
              Raise Exception.Create('Konto findes ikke!');
            End;
        End;
      Exit;
    End;
  If (StringGrid1.Col = KasAfstemning) Then
    Begin // Specielt for afstemning
      HelpKontoStr := FindKontoFraBruger(Value);
      If (HelpKontoStr <> 'Ingen valgt') Then
        Begin // Konto fundet
          // Check først for åbningsbalance -1
          If (HelpKontoStr = '-1') or (HelpKontoStr = '') Then
            Begin // Accepteres
            End
          Else
            Begin
              // Check om kontoen er en drift eller status konto
              With ZQuery1.SQL do
                Begin
                  Clear;
                  Add('Select * from kontobes where id = ' + HelpkontoStr);
                End;
              ZQuery1.Open;
              If ZQuery1.FieldByName('Type').AsInteger > 1 Then
                Begin // Konto defineret til tekst eller sum
                  Raise Exception.Create('Konto skal være til drift eller status!');
                End;
              // Direkte
              If Not ZQuery1.FieldByName('Direkte').AsBoolean Then
                Begin // Må ikke konteres på den direkte
                  Raise Exception.Create('Der må ikke konteres direkte på denne modkonto!');
                End;
              // Spærret
              If ZQuery1.FieldByName('Spaerret').AsBoolean Then
                Begin // Må ikke konteres på den direkte
                  Raise Exception.Create('Modkontoen: ' +
                    ZQuery1.FieldByName('Beskrivelse').AsString + ' er spærret!');
                End;
            End;
        End
      Else
        Begin
          // Check om det skulle være en short cut
          If CheckShortCut(Value,HelpKontoStr) Then
            Begin // Fundet
              Value := HelpKontoStr;
              CheckKonto(Value);
            End
          Else
            Begin
              Raise Exception.Create('Konto findes ikke!');
            End;
        End;
      Exit;
    End;
end;

//**********************************************************
// Luk
//**********************************************************
procedure TKasseKladdeForm.LukExecute(Sender: TObject);
begin
  Close;
end;

//**********************************************************
// Opret
//**********************************************************
procedure TKasseKladdeForm.NytBilagExecute(Sender: TObject);
Var HelpNr : Integer;
begin
  If StringGrid1.EditorMode Then
    Begin // Afslut edit mode
      // StringGrid1.Editor.Hide;
      StringGrid1.EditorMode := False;
    End;
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from Kassekladde');
    End;
  ZQuery1.Open;
  Try
    ZQuery1.Append;
    ZQuery1.Edit;
    ZQuery1.FieldByName('Afd').AsString           := CurrentAfd;
    ZQuery1.FieldByName('Periode').AsString       :=
      PeriodeNrListe.Strings[ComboPeriode.ItemIndex];
    ZQuery1.FieldByName('Dato').AsFloat           := DateTimeToJulianDate(Date);
    ZQuery1.FieldByName('Konto').AsString         := FoersteKonto;
    ZQuery1.FieldByName('BilagsNr').AsString      := FindNytBilagsNr;
    ZQuery1.FieldByName('Tekst').AsString         := 'Beskrivelse';
    ZQuery1.FieldByName('Moms').Clear;
    ZQuery1.FieldByName('D_K').AsString           := 'D';
    ZQuery1.FieldByName('Beloeb').AsString        := '0';
    ZQuery1.FieldByName('Modkonto').AsString      := '';
    ZQuery1.FieldByName('NoKasse').AsString       :=
      PDataKassekladdeDef(KasseKladdeDefNrListe.Items[ComboKassekladde.ItemIndex])^.Nr;
    ZQuery1.FieldByName('okonr').AsString         := '';
    // Gem
    ZQuery1.Post;
    ZQuery1.ApplyUpdates;
  Except
    MessageDlg('Bilag kunne ikke oprettes!',mtError,[mbOk],0);
    ZQuery1.CancelUpdates;
    Exit;
  end;
  IndlaesBilag;
end;

//**********************************************************
// Page control change
//**********************************************************
procedure TKasseKladdeForm.PageControl1Change(Sender: TObject);
Var A : Integer;
begin
  For A := 0 To Toolbar1.ButtonCount-1 do
    Begin
      Toolbar1.Buttons[A].Align := alCustom;
    end;
  Application.ProcessMessages;
  If PageControl1.ActivePageIndex = 0 Then
    Begin  // Kassekladde
      NytBilag.Visible                := True;
      Slet.Visible                    := True;
      RedigerAfstemningskonti.Visible := True;
      TjekKassekladde.Visible         := True;
      BogFoer.Visible                 := True;
      BogFoerAlle.Visible             := True;
      VisAfstemningsKonti.Visible     := True;
      Udskriv_Kassekladde.Visible     := True;
      Udskriv_Kontoplan.Visible       := False;
      Udskriv_Postering.Visible       := False;
    end
  Else if PageControl1.ActivePageIndex = 1 Then
    Begin  // Kontoplan
      NytBilag.Visible                := False;
      Slet.Visible                    := False;
      RedigerAfstemningskonti.Visible := False;
      TjekKassekladde.Visible         := False;
      BogFoer.Visible                 := False;
      BogFoerAlle.Visible             := False;
      VisAfstemningsKonti.Visible     := False;
      Udskriv_Kassekladde.Visible     := False;
      Udskriv_Kontoplan.Visible       := True;
      Udskriv_Postering.Visible       := False;
    end
  Else if PageControl1.ActivePageIndex = 2 Then
    Begin  // Posteringsoversigt
      NytBilag.Visible                := False;
      Slet.Visible                    := False;
      RedigerAfstemningskonti.Visible := False;
      TjekKassekladde.Visible         := False;
      BogFoer.Visible                 := False;
      BogFoerAlle.Visible             := False;
      VisAfstemningsKonti.Visible     := False;
      Udskriv_Kassekladde.Visible     := False;
      Udskriv_Kontoplan.Visible       := False;
      Udskriv_Postering.Visible       := True;
      IndlaesPostering;
    end
  Else if PageControl1.ActivePageIndex = 3 Then
    Begin  // Indstillinger
      NytBilag.Visible                := False;
      Slet.Visible                    := False;
      RedigerAfstemningskonti.Visible := False;
      TjekKassekladde.Visible         := False;
      BogFoer.Visible                 := False;
      BogFoerAlle.Visible             := False;
      VisAfstemningsKonti.Visible     := False;
      Udskriv_Kassekladde.Visible     := False;
      Udskriv_Kontoplan.Visible       := False;
      Udskriv_Postering.Visible       := False;
    end;
  For A := 0 To Toolbar1.ButtonCount-1 do
    Begin
      Toolbar1.Buttons[A].Align := alNone;
    end;
end;

procedure TKasseKladdeForm.PageControl1Changing(Sender: TObject;
  var AllowChange: Boolean);
begin
end;


//**********************************************************
// Rediger afstemningskonti
//**********************************************************
procedure TKasseKladdeForm.RedigerAfstemningskontiExecute(Sender: TObject);
begin
  AfstemningsKontiForm := TAfstemningsKontiForm.Create(Self);
  AfstemningsKontiForm.ShowModal;
  AfstemningsKontiForm.Free;
end;

//**********************************************************
// Slet
//**********************************************************
procedure TKasseKladdeForm.SletExecute(Sender: TObject);
begin
  // Find Record
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from Kassekladde where Afd = ' + CurrentAfd +
          ' and nr = ' + StringGrid1.Cells[KasIdent,StringGrid1.Row]);
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount <> 1 Then
    Begin
      MessageDlg('Bilag kan ikke opdateres!',mtInformation,[mbOk],0);
      Exit;
    end;
  ZQuery1.First;
  Try
    ZQuery1.Delete;
  Except
    MessageDlg('Kan ikke fjerne bilag!',mtError,[mbOk],0);
    ZQuery1.CancelUpdates;
    Exit;
  End;
  IndlaesBilag;
end;

//**********************************************************
// Close tjek panel
//**********************************************************
procedure TKasseKladdeForm.SpeedCloseTjekPanelClick(Sender: TObject);
begin
  Kassekladde_Tjek_Panel.Visible := False;
end;

//**********************************************************
// AfstemStringGrid: Refresh Button click
//**********************************************************
procedure TKasseKladdeForm.SpeedRefreshAfstemningskontiClick(Sender: TObject);
begin
  BeregnKontiSaldi(True,True,StrToDate('01-01-1900'),StrToDate('01-01-2100'),PeriodeNrListe.Strings[ComboPeriode.ItemIndex]); // Beregn begge dele
  BeregnAfstemningskonti;
end;

//**********************************************************
// AfstemStringGrid: Bogført click
//**********************************************************
procedure TKasseKladdeForm.SpeedSumBogfoertClick(Sender: TObject);
begin
  BeregnAfstemningskonti;
end;

//**********************************************************
// AfstemStringGrid: Bogfør og kassekladde
//**********************************************************
procedure TKasseKladdeForm.SpeedSumBogfoertPlusKassekladdeClick(Sender: TObject
  );
begin
  BeregnAfstemningskonti;
end;

//**********************************************************
// AfstemStringGrid: Kassekladde
//**********************************************************
procedure TKasseKladdeForm.SpeedSumKassekladdeClick(Sender: TObject);
begin
  BeregnAfstemningskonti;
end;

//**********************************************************
// StringGrid: Before selection
//**********************************************************
procedure TKasseKladdeForm.StringGrid1BeforeSelection(Sender: TObject; aCol,
  aRow: Integer);
begin
end;

//**********************************************************
// AfstemStringGrid: Button click
//**********************************************************
procedure TKasseKladdeForm.StringGrid1ButtonClick(Sender: TObject; aCol,
  aRow: Integer);
begin
  If acol = KasKonto Then
    Begin
      PickKontoForm := TPickKontoForm.Create(Self);
      If PickKontoForm.ShowMOdal = mrOk Then
        Begin
          StringGrid1.Cells[aCol,aRow] := PickKontoForm.Valgt;
        End;
      PickKontoForm.Free;
      StringGrid1.SetFocus;
    end
  Else If Acol = KasAfstemning Then
    Begin
      PickKontoForm := TPickKontoForm.Create(Self);
      PickKontoForm.Afstemningskonti := CheckKunAfstemningskonti.Checked;
      PickKontoForm.IndlaesKonti;
      If PickKontoForm.ShowMOdal = mrOk Then
        Begin
          StringGrid1.Cells[aCol,aRow] := PickKontoForm.Valgt;
        End;
      PickKontoForm.Free;
      StringGrid1.SetFocus;
    end;
end;

//**********************************************************
// StringGrid: On click
//**********************************************************
procedure TKasseKladdeForm.StringGrid1Click(Sender: TObject);
begin
  If (StringGrid1.Row > 0) and (StringGrid1.RowCount > 1) Then
    Begin
      OpdaterStatusLinie(StringGrid1.Row);
    end;
end;

//**********************************************************
// AfstemStringGrid: Compare cells
//**********************************************************
procedure TKasseKladdeForm.StringGrid1CompareCells(Sender: TObject; ACol, ARow,
  BCol, BRow: Integer; var Result: integer);
Var Help1, Help2 : String;
    HelpTal : Currency;
begin
  If (ACol = KasKonto) or (ACol = KasBL) or (ACol = KasAfstemning) Then
    Begin // Sorter integer
      Result := StrToIntDef(StringGrid1.Cells[ACol,ARow],0) - StrToIntDef(StringGrid1.Cells[BCol,BRow],0);
      If StringGrid1.SortOrder = soDescending Then
        Begin
          Result := -Result;
        end;
    end
  Else If (ACol = KasBeloeb) Then
    Begin // Sorter beløb
      Help1 := FjernPunktum(StringGrid1.Cells[ACol,ARow]);
      Help2 := FjernPunktum(StringGrid1.Cells[BCol,BRow]);
      Result := Round(StrToCurrDef(Help1,0) - StrToCurrDef(Help2,0));
      If StringGrid1.SortOrder = soDescending Then
        Begin
          Result := -Result;
        end;
    end
  Else If (ACol = KasDato) Then
    Begin // Sorter dato
      Result := CompareDate(StrToDate(StringGrid1.Cells[ACol,ARow]),StrToDate(StringGrid1.Cells[BCol,BRow]));
      If StringGrid1.SortOrder = soDescending Then
        Begin
          Result := -Result;
        end;
    end;
end;

//**********************************************************
// AfstemStringGrid: Editing done
//**********************************************************
procedure TKasseKladdeForm.StringGrid1EditingDone(Sender: TObject);
begin
  GemRowTilTabel;
end;

//**********************************************************
// AfstemStringGrid: Enter
//**********************************************************
procedure TKasseKladdeForm.StringGrid1Enter(Sender: TObject);
begin
end;

//**********************************************************
// AfstemStringGrid:
//**********************************************************
procedure TKasseKladdeForm.StringGrid1GetEditText(Sender: TObject; ACol,
  ARow: Integer; var Value: string);
begin
end;

procedure TKasseKladdeForm.StringGrid1PickListSelect(Sender: TObject);
begin
  If StringGrid1.Col = KasAfstemning Then
    Begin
      ShowMessage('Wups: ' + INtTOStr(TCustomComboBox(StringGrid1.Editor).ItemIndex));
    End;
end;


//**********************************************************
// AfstemStringGrid: Select Editor
//**********************************************************
procedure TKasseKladdeForm.StringGrid1SelectEditor(Sender: TObject; aCol,
  aRow: Integer; var Editor: TWinControl);
begin
  If      aCol = KasBL Then
    Begin
      Editor := StringGrid1.EditorByStyle(cbsAuto);
      //Editor := StringGrid1.EditorByStyle(cbsPickList);
      //TCustomComboBox(Editor).Items.CommaText := 'A,B,C,D';
    end
  Else If acol = KasDato Then
    Begin
      try
        DateEdit1.BoundsRect := StringGrid1.CellRect(aCol,aRow);
        If StringGrid1.Cells[StringGrid1.Col,StringGrid1.Row] <> '' Then
          DateEdit1.Date := StrToDate(StringGrid1.Cells[StringGrid1.Col,StringGrid1.Row]);
        Editor := DateEdit1;
      Except
      end;
    end
  Else If acol = KasKonto Then
    Begin
      Editor := StringGrid1.EditorByStyle(cbsEllipsis);
    end
  Else If acol = KasTekst Then
    Begin
      Editor := StringGrid1.EditorByStyle(cbsAuto);
    end
  Else If acol = KasMoms Then
    Begin
      Editor := StringGrid1.EditorByStyle(cbsPickList);
      TCustomComboBox(Editor).Items.Clear;
      TCustomComboBox(Editor).Items.AddStrings(MomsKodeListe); // Moms
      TCustomComboBox(Editor).Style := csDropDownList;
    end
  Else If acol = KasDK Then
    Begin
      Editor := StringGrid1.EditorByStyle(cbsPickList);
      TCustomComboBox(Editor).Items.Clear;
      TCustomComboBox(Editor).Items.CommaText := 'D,K';
      TCustomComboBox(Editor).Style := csDropDownList;
    end
  Else If acol = KasBeloeb Then
    Begin
      Editor := StringGrid1.EditorByStyle(cbsAuto);
    end
  Else If acol = KasAfstemning Then
    Begin
       If CheckVisCombo.Checked Then
        Begin
          Editor := StringGrid1.EditorByStyle(cbsPickList);
          TCustomComboBox(Editor).Items.Clear;
          TCustomComboBox(Editor).Items.AddStrings(AfstemningskontiListe); // Afstemning
          TCustomComboBox(Editor).Style := csDropDownList;
        End
      Else
        Begin
          Editor := StringGrid1.EditorByStyle(cbsEllipsis);
        End;
    end
  Else If acol = KasOkoNr Then
    Begin
      Editor := StringGrid1.EditorByStyle(cbsPickList);
      TCustomComboBox(Editor).Items.Clear;
      TCustomComboBox(Editor).Items.AddStrings(ComboFormaal.Items); // Formål
      TCustomComboBox(Editor).Style := csDropDownList;
    end
end;


//**********************************************************
// AfstemStringGrid: Validate entry
//**********************************************************
procedure TKasseKladdeForm.StringGrid1ValidateEntry(sender: TObject; aCol,
  aRow: Integer; const OldValue: string; var NewValue: String);
Var I, Code : Integer;
    Valid   : Boolean;
    Tal     : Real;
    TestStr : String;
    Help40  : String[40];
begin
  If      aCol = KasBL Then
    Begin // Check if number
      Val(NewValue,I,Code);
      if Code <> 0 Then Raise Exception.CreateFmt('Bilagsnr ikke korrekt : ''%s''', [newvalue]);
     end
  Else If acol = KasDato Then
    Begin
      // Her skal der undersøges om interval
      Valid := (StrToDate(NewValue) >= DateTimePosteringFra.Date-1) and
               (StrToDate(NewValue) <= DateTimePosteringTil.Date);
      If not Valid Then
        Begin
          Raise Exception.CreateFmt('Dato ligger ikke i det tilladte interval - ændre evt. under indstillinger : ''%s''', [newvalue]);
        End
      Else
        Begin
          { TODO 3 -oclm -cKassekladde : Dato'en gemmes til næste gang kassekladden startes }
(*          // Dato'en gemmes til næste gang kassekladden startes
          If CheckAutoDate.Checked Then
            Begin  // StdTimePicker = Sidst indtastet
              StdDateTimePicker.DateTime := StrToDate(Value);
            End;
          IniFile.WriteDate('Kassekladde','LastDate',StdDateTimePicker.DateTime);
          IniFile.WriteBool('Kassekladde','AutoDate',CheckAutoDate.Checked);
          IniFile.WriteBool('Kassekladde','DagsDato',CheckDagsDato.Checked);*)
        End;
    end
  Else If acol = KasKonto Then
    Begin // Does account exist?
      If NewValue = '-1' Then
        Begin
          Raise Exception.Create('Konto -1 kan ikke vælges her!');
        end
      Else CheckKonto(NewValue);
    end
  Else If acol = KasTekst Then
    Begin
      If Length(NewValue) > 39 Then
        Begin
          Help40 := NewValue;
          NewValue := Help40;
        End;
    end
  Else If acol = KasMoms Then
    Begin
    end
  Else If acol = KasDK Then
    Begin
    end
  Else If acol = KasBeloeb Then
    Begin
      Try
        TestStr := NewValue;
        TestStr := FjernPunktum(TestStr);
        Tal := StrToFloat(TestStr)
      Except
        Raise Exception.Create('Beløb er ikke et tal!');
      End;
    end
  Else If acol = KasAfstemning Then
    Begin
      If CheckVisCombo.Checked Then
        Begin // Oversæt fra Beskrivelse til BrugerKontonr
          NewValue := AfstemningskontiNrListe.Strings[
            TCustomComboBox(StringGrid1.Editor).ItemIndex];
        End;
      CheckKonto(NewValue);
    end
  Else If acol = KasOkoNr Then
    Begin

    end
end;

//**********************************************************
// Kontoplan: Compare cells
//**********************************************************
procedure TKasseKladdeForm.StringGrid2CompareCells(Sender: TObject; ACol, ARow,
  BCol, BRow: Integer; var Result: integer);
Var Help1, Help2 : String;
    HelpTal : Currency;
begin
  If (ACol = Konto_Nr) or (ACol = Konto_Fra) or (ACol = Konto_Til)Then
    Begin // Sorter integer
      Result := StrToIntDef(StringGrid2.Cells[ACol,ARow],0) - StrToIntDef(StringGrid2.Cells[BCol,BRow],0);
      If StringGrid2.SortOrder = soDescending Then
        Begin
          Result := -Result;
        end;
    end
  Else If (ACol = Konto_Saldo) Then
    Begin // Sorter beløb
      Help1 := FjernPunktum(StringGrid2.Cells[ACol,ARow]);
      Help2 := FjernPunktum(StringGrid2.Cells[BCol,BRow]);
      Result := Round(StrToCurrDef(Help1,0) - StrToCurrDef(Help2,0));
      If StringGrid2.SortOrder = soDescending Then
        Begin
          Result := -Result;
        end;
    end
  Else
    Begin // String
      If StringGrid2.Cells[ACol,ARow] = StringGrid2.Cells[BCol,BRow] Then
        Result := 0
      Else If StringGrid2.Cells[ACol,ARow] > StringGrid2.Cells[BCol,BRow] Then
        Result := 1
      Else
        Result := -1;
      If StringGrid2.SortOrder = soDescending Then
        Begin
          Result := -Result;
        end;
    end;
end;

//**********************************************************
// Kontoplan: Double click
//**********************************************************
procedure TKasseKladdeForm.StringGrid2DblClick(Sender: TObject);
begin
  ShowMessage('Double click');
end;

//**********************************************************
// Posteringsgrid: Compare cells
//**********************************************************
procedure TKasseKladdeForm.StringGridPostCompareCells(Sender: TObject; ACol,
  ARow, BCol, BRow: Integer; var Result: integer);
Var Help1, Help2 : String;
    HelpTal : Currency;
begin
  If (ACol = PostBeloeb) Then
    Begin // Sorter beløb
      Help1 := FjernPunktum(StringGridPost.Cells[ACol,ARow]);
      Help2 := FjernPunktum(StringGridPost.Cells[BCol,BRow]);
      Result := Round(StrToCurrDef(Help1,0) - StrToCurrDef(Help2,0));
      If StringGridPost.SortOrder = soDescending Then
        Begin
          Result := -Result;
        end;
    end
  Else If (ACol = PostNr) or (ACol = PostArt) or (ACol = PostKonto)
     or (ACol = PostId) Then
    Begin // Sorter integer
      Result := StrToIntDef(StringGridPost.Cells[ACol,ARow],0) - StrToIntDef(StringGridPost.Cells[BCol,BRow],0);
      If StringGridPost.SortOrder = soDescending Then
        Begin
          Result := -Result;
        end;
    end
  Else If (ACol = PostDato) Then
    Begin // Dato
      Result := CompareDateTime(StrToDateTime(StringGridPost.Cells[ACol,ARow]),
        StrToDateTime(StringGridPost.Cells[BCol,BRow]));
      If StringGridPost.SortOrder = soDescending Then
        Begin
          Result := -Result;
        end;
    end
  Else //If (ACol = PostDato) Then
    Begin // String
      If StringGridPost.Cells[ACol,ARow] = StringGridPost.Cells[BCol,BRow] Then
        Result := 0
      Else If StringGridPost.Cells[ACol,ARow] > StringGridPost.Cells[BCol,BRow] Then
        Result := 1
      Else
        Result := -1;
      If StringGridPost.SortOrder = soDescending Then
        Begin
          Result := -Result;
        end;
    end;
end;

//**********************************************************
// Date exit
//**********************************************************
procedure TKasseKladdeForm.DateEdit1Exit(Sender: TObject);
begin
  StringGrid1.Cells[StringGrid1.Col,StringGrid1.Row] := DateToStr(DateEdit1.Date);
end;

//**********************************************************
// Check vis combo: Change
//**********************************************************
procedure TKasseKladdeForm.CheckVisComboChange(Sender: TObject);
begin
  IndlaesAfstemningskonti;

end;

//**********************************************************
// ComboFormaal: Change
//**********************************************************
procedure TKasseKladdeForm.ComboFormaalChange(Sender: TObject);
begin
  IndlaesBilag;
end;

//**********************************************************
// ComboKassekladde: Change
//**********************************************************
procedure TKasseKladdeForm.ComboKassekladdeChange(Sender: TObject);
begin
  IndlaesBilag;
end;

//**********************************************************
// ComboPeriode: Change
//**********************************************************
procedure TKasseKladdeForm.ComboPeriodeChange(Sender: TObject);
begin
  IndlaesBilag;
end;

//**********************************************************
// CheckKunAfstemningskonti: Change
//**********************************************************
procedure TKasseKladdeForm.CheckKunAfstemningskontiChange(Sender: TObject);
begin
  IndlaesAfstemningskonti;
end;



//**********************************************************
// Date Edit key down
//**********************************************************
procedure TKasseKladdeForm.DateEdit1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key=9 then
    begin
      StringGrid1.EditorMode := false;
      if StringGrid1.Col < StringGrid1.ColCount then
         StringGrid1.Col := StringGrid1.Col + 1
      Else
        StringGrid1.Col := 0;
      StringGrid1.SetFocus;
    end;
end;


//**********************************************************
// Form close
//**********************************************************
procedure TKasseKladdeForm.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  ZQuery1.Close;
  ZQuery2.Close;
  CloseAction := caFree;
end;

//**********************************************************
// Indstil kassekladde
//**********************************************************
Procedure TKasseKladdeForm.IndstilKassekladdeGrid;
Begin
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
  StringGrid1.Columns.Add;  // Formål
  StringGrid1.Columns.Add;  // Ident
  //
  StringGrid1.Columns[KasDato].Title.Caption          := 'Dato';
  StringGrid1.Columns[KasDato].Width                  := 82;
  StringGrid1.Columns[KasDato].Alignment              := taLeftJustify;

  StringGrid1.Columns[KasBL].Title.Caption            := 'Nr';
  StringGrid1.Columns[KasBL].Width                    := 57;
  StringGrid1.Columns[KasBL].Alignment                := taRightJustify;
  StringGrid1.Columns[KasKonto].Title.Caption         := 'Konto';
  StringGrid1.Columns[KasKonto].Width                 := 60;
  StringGrid1.Columns[KasKonto].Alignment             := taRightJustify;
  StringGrid1.Columns[KasTekst].Title.Caption         := 'Tekst';
  StringGrid1.Columns[KasTekst].Width                 := 190;
  StringGrid1.Columns[KasTekst].Alignment             := taLeftJustify;
  StringGrid1.Columns[KasMoms].Title.Caption          := 'Moms';
  StringGrid1.Columns[KasMoms].Width                  := 42;
  StringGrid1.Columns[KasMOms].Alignment              := taLeftJustify;
  StringGrid1.Columns[KasDK].Title.Caption            := 'D/K';
  StringGrid1.Columns[KasDK].Width                    := 30;
  StringGrid1.Columns[KasDK].Alignment                := taLeftJustify;
  StringGrid1.Columns[KasBeloeb].Title.Caption        := 'Beløb';
  StringGrid1.Columns[KasBeloeb].Width                := 80;
  StringGrid1.Columns[KasBeloeb].Alignment            := taRightJustify;
  StringGrid1.Columns[KasAfstemning].Title.Caption    := 'Afs.konto';
  StringGrid1.Columns[KasAfstemning].Width            := 60;
  StringGrid1.Columns[KasAfstemning].Alignment        := taRightJustify;
  StringGrid1.Columns[KasOkoNr].Title.Caption         := 'Formål';
  StringGrid1.Columns[KasOkoNr].Width                 := 60;
  StringGrid1.Columns[KasOkoNr].Alignment             := taLeftJustify;
  StringGrid1.Columns[KasIdent].Title.Caption         := 'Ident';
  StringGrid1.Columns[KasIdent].Width                 := 60;
  StringGrid1.Columns[KasIdent].Alignment             := taRightJustify;
  StringGrid1.Columns[KasIdent].Visible               := False;

  PageControl1.Color := H_Menu_knapper_Farve;
end;


//**********************************************************
// Nyt BilagsNr
//**********************************************************
function TKasseKladdeForm.FindNytBilagsNr : String;
Var NrIKladde : LongInt;
    NrIBilag  : LongInt;
begin
  NrIKladde := 0;
  NrIBilag  := 0;
  // Kassekladde undersøges først
  With ZQuery2.SQL do
    Begin
      Clear;
      Add('Select * from Kassekladde where Afd = ' + CurrentAfd +
          ' and periode = ' + PeriodeNrListe.Strings[ComboPeriode.ItemIndex]);
    End;
  ZQuery2.Open;
  ZQuery2.First;
  While Not ZQuery2.EOF do
    Begin
      If ZQuery2.FieldByName('BilagsNr').AsInteger > NrIKladde Then
        Begin
          NrIKladde := ZQuery2.FieldByName('BilagsNr').AsInteger;
        End;
      ZQuery2.Next;
    end;
  Inc(NrIKladde);
  // Bilag skal undersøges
  { TODO -ckassekladde : Bilag nyt bilagsnr nummer skal laves }

  If NrIBilag > NrIKladde Then
    Begin
      FindNytBilagsNr := IntToStr(NrIBilag);
    End
  Else
    Begin
      FindNytBilagsNr := IntToStr(NrIKladde);
    End;
end;

//**********************************************************
// Første konto
//**********************************************************
function TKasseKladdeForm.FoersteKonto : String;
Var Stop : Boolean;
begin
  Stop := False;
  // Kassekladde undersøges først
  With ZQuery2.SQL do
    Begin
      Clear;
      Add('Select * from Kontobes where Afd = ' + CurrentAfd);
    End;
  ZQuery2.Open;
  ZQuery2.First;
  While Not ZQuery2.EOF and not Stop do
    Begin
      Stop := (ZQuery2.FieldByName('Type').AsInteger < 2);
      If not Stop Then ZQuery2.Next;
    end;
  FoersteKonto := ZQuery2.FieldByName('id').AsString
end;

//**********************************************************
// Gem row til tabel
//**********************************************************
Procedure TKasseKladdeForm.GemRowTilTabel;
Var Stop    : Boolean;
    HelpStr : String;
Begin
  If UpdateGrid Then Exit;
  // Find Record
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from kassekladde where Afd = ' + CurrentAfd +
          ' and nr = ' + StringGrid1.Cells[KasIdent,StringGrid1.Row]);
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount <> 1 Then
    Begin
      MessageDlg('Bilag kan ikke opdateres!',mtInformation,[mbOk],0);
      Exit;
    end;
  ZQuery1.First;
  Try
    ZQuery1.Edit;
    // Nr, afd periode er opdateret
    // Bilagsnr
    ZQuery1.FieldByName('BilagsNr').AsString          :=
      StringGrid1.Cells[KasBL,StringGrid1.Row];
    // Dato
    ZQuery1.FieldByName('Dato').AsFloat          :=
      DateTimeToJulianDate(StrToDate(StringGrid1.Cells[KasDato,StringGrid1.Row]));
    // Tekst
    ZQuery1.FieldByName('Tekst').AsString          :=
      StringGrid1.Cells[KasTekst,StringGrid1.Row];
    // D-K
    ZQuery1.FieldByName('D_K').AsString          :=
      StringGrid1.Cells[KasDK,StringGrid1.Row];
    // Type
    ZQuery1.FieldByName('Type').AsString          := '1';
    // Konto
    ZQuery1.FieldByName('Konto').AsString          :=
      FindKontoFraBruger(StringGrid1.Cells[KasKonto,StringGrid1.Row]);
    // Modkonto
    ZQuery1.FieldByName('Modkonto').AsString          :=
      FindKontoFraBruger(StringGrid1.Cells[KasAfstemning,StringGrid1.Row]);
    // Beløb
    HelpStr := StringGrid1.Cells[KasBeloeb,StringGrid1.Row];
    ZQuery1.FieldByName('Beloeb').AsCurrency     :=
       StrToCurr(FjernPunktum(HelpStr));
    // Moms
    If StringGrid1.Cells[KasMoms,StringGrid1.Row] = '' Then
      Begin
        ZQuery1.FieldByName('Moms').Clear;
      End
    Else
      Begin
        ZQuery1.FieldByName('Moms').AsString :=
          MomsKodeNrListe.Strings[MomsKodeListe.
            IndexOf(StringGrid1.Cells[KasMoms,StringGrid1.Row])];
      End;
    // Formål
    ZQuery1.FieldByName('OkoNr').AsString :=
        FormaalNrListe.Strings[
        ComboFormaal.Items.IndexOf(StringGrid1.Cells[KasOkoNr,StringGrid1.Row])];
    // Gem
    ZQuery1.Post;
    ZQuery1.ApplyUpdates;
  Except
    ZQuery1.CancelUpdates;
    MessageDlg('Bilag blev ikke gemt!',mtError,[mbOK],0);
    Exit;
  End
End;


//**********************************************************
// Forundersøgelse inden bogføring af bilag
//**********************************************************
function TKasseKladdeForm.Forundersoegelse(NoKasse: String; NrStr : String;
   Var Svar : String) : Boolean;
Var SumDebet  : Currency;
    SumKredit : Currency;
    Stop      : Boolean;
    OK        : Boolean;
    StopMoms  : Boolean;
    BelobHelp : String;
    BelobTal  : Currency;
begin
  // Check om bilag er i balance
  StopMoms := False;
  SumDebet := 0;
  SumKredit:= 0;
  Svar := '';
  // Check balance på bilag
  // Find Record
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from kassekladde where Afd = ' + CurrentAfd +
          ' and periode = ' +  PeriodeNrListe.Strings[ComboPeriode.ItemIndex] +
          ' and bilagsnr = ' + NrStr +
          ' and nokasse = ' + Nokasse +
          '');
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount = 0 Then
    Begin
      MessageDlg('Bilag kan ikke findes!',mtError,[mbOk],0);
      Exit;
    end;
  ZQuery1.First;
  // Gå til den første med dette bilag nr
  Stop := False;
  While Not Stop And not ZQuery1.EOF Do
    Begin
      If ZQuery1.FieldByName('BilagsNr').AsString = NrStr then
        Begin // Samme bilagsnr
          BelobHelp := ZQuery1.FieldByName('Beloeb').AsString;
          FjernPunktum(BelobHelp);
          BelobTal := StrToCurr(BelobHelp);
          If ZQuery1.FieldByName('D_K').AsString = 'D' Then
            Begin
              SumDebet := SumDebet + BelobTal;
              If Not ZQuery1.FieldByName('ModKonto').IsNull Then
                Begin // Linje er krediteret
                  SumKredit := SumKredit + BelobTal;
                End;
            End
          Else
            Begin
              SumKredit := SumKredit + BelobTal;
              If Not ZQuery1.FieldByName('ModKonto').IsNull Then
                Begin // Linje er debiteret
                  SumDebet := SumDebet + BelobTal;
                End;
            End;
        End
      Else
        Begin
          Stop := True;
        End;
      ZQuery1.Next;
    End;
  // Er beløbet <> 0 kr ?
  If Not ((SumDebet = 0) and (SumKredit = 0)) Then
    Begin
      OK := True;
    End
  Else
    Begin
      OK := False;
      Svar := NrStr + ': Giver ikke mening at bogføre 0 kr!';
    End;
  // Er bilag i balance
  If OK Then
    Begin
      If Ok And (SumDebet - SumKredit = 0) Then
        Begin
          OK := True;
        End
      Else
        Begin
          OK := False;
          Svar := NrStr + ': er ikke i balance - > Diff = ' +
            FloatToStrF(SumDebet-SumKredit,ffNumber,18,2);
        End;
    End;
  // Check om dato passer med indstillinger for kassekladden
(*  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from kassekladde where Afd = ' + CurrentAfd +
          ' and periode = ' +  PeriodeNrListe.Strings[ComboPeriode.ItemIndex] +
          ' and nr = ' + NrStr +
          ' and nokasse = ' + Nokasse +
          '');
    End;
  ZQuery1.Open;
  If OK and (ZQuery1.RecordCount > 0) Then
    Begin
      If CompareDate(ZQuery1.FieldByName('Dato').AsDateTime,DateTimePosteringTil.Date) = 1 Then
        Begin
          OK := False;
          Svar := ZQuery1.FieldByName('BilagsNr').AsString +
                    ' er senere end intervallet angivet under Indstillinger';
        End
      Else
        If CompareDate(ZQuery1.FieldByName('Dato').AsDateTime,DateTimePosteringFra.Date) = -1 Then
          Begin
            OK := False;
            Svar := ZQuery1.FieldByName('BilagsNr').AsString +
                      ' er før end intervallet angivet under Indstillinger';
          End;
    End;*)

  // Check om der kan posteres på konti
  ZQuery1.First;
  If OK and (ZQuery1.RecordCount > 0) Then
    Begin
      // Gå til den første med dette bilag nr
      Stop := False;
      While Not Stop And not ZQuery1.EOF Do
        Begin
          If ZQuery1.FieldByName('BilagsNr').AsString = NrStr then
            Begin // Samme bilagsnr
              With ZQuery2.SQL do
                Begin
                  Clear;
                  Add('Select * from kontobes where Afd = ' + CurrentAfd +
                      ' and id = ' + ZQuery1.FieldByName('konto').AsString);
                End;
              ZQuery2.Open;
              If ZQuery2.RecordCount > 0 Then
                Begin
                  If ZQuery2.FieldByName('Type').AsInteger > 1 Then
                    Begin // Konto defineret til tekst eller sum
                      Svar := ZQuery2.FieldByName('BrugerKonto').AsString + ' ' +
                        ZQuery2.FieldByName('Beskrivelse').AsString +
                        ' skal være drift eller status!';
                      Stop := True;
                    End
                  // Direkte
                  Else If Not ZQuery2.FieldByName('Direkte').AsBoolean Then
                    Begin // Må ikke konteres på den direkte
                      Svar := 'Der må ikke konteres direkte på denne ' +
                       ZQuery2.FieldByName('BrugerKonto').AsString + ' ' +
                       ZQuery2.FieldByName('Beskrivelse').AsString;
                      Stop := True;
                    End
                  // Spærret
                  Else If ZQuery2.FieldByName('Spaerret').AsBoolean Then
                    Begin // Må ikke konteres på den direkte
                      Svar := ZQuery2.FieldByName('BrugerKonto').AsString + ' ' +
                      ZQuery2.FieldByName('Beskrivelse').AsString +
                        ' er spærret!';
                      Stop := True;
                    End;
                End
              Else
                Begin
                  MessageDlg('Konto kan ikke findes',mtInformation,[mbOk],0);
                  Svar := FindBrugerFraKonto(ZQuery1.FieldByName('Konto').AsString) +
                    ' kan ikke findes';
                  Stop := True;
                End;
              If Ok and not ZQuery1.FieldByName('ModKonto').IsNull Then
                Begin
                  // Der må ikke posteres på samme konto som modkonto
                  If (ZQuery1.FieldByName('ModKonto').AsInteger =
                     ZQuery1.FieldByName('Konto').AsInteger) Then
                     Begin
                       OK := False;
                       Stop := True;
                       Svar := NrStr + ': Konto og modkonto er ens - det giver ikke mening!';
                     End;
                  If OK Then
                    Begin
                      With ZQuery2.SQL do
                        Begin
                          Clear;
                          Add('Select * from kontobes where Afd = ' + CurrentAfd +
                              ' and id = ' + ZQuery1.FieldByName('modkonto').AsString);
                        End;
                      ZQuery2.Open;
                      If ZQuery2.RecordCount > 0 Then
                        Begin
                          If ZQuery2.FieldByName('Type').AsInteger > 1 Then
                            Begin // Konto defineret til tekst eller sum
                              Svar := NrStr + ': ' + ZQuery2.FieldByName('BrugerKonto').AsString + ' ' +
                                ZQuery2.FieldByName('Beskrivelse').AsString +
                                ' som modkonto skal være drift eller status!';
                              Stop := True;
                            End
                          // Direkte
                          Else If Not ZQuery2.FieldByName('Direkte').AsBoolean Then
                            Begin // Må ikke konteres på den direkte
                              Svar := NrStr + ': Der må ikke konteres direkte på denne modkonto ' +
                               ZQuery2.FieldByName('BrugerKonto').AsString + ' ' +
                               ZQuery2.FieldByName('Beskrivelse').AsString;
                              Stop := True;
                            End
                          // Spærret
                          Else If ZQuery2.FieldByName('Spaerret').AsBoolean Then
                            Begin // Må ikke konteres på den direkte
                              Svar := NrStr + ': ' + ZQuery2.FieldByName('BrugerKonto').AsString + ' ' +
                                ZQuery2.FieldByName('Beskrivelse').AsString +
                                ' er spærret også som modkonto!';
                              Stop := True;
                            End;
                        End;
                    End
                  Else
                    Begin
                      If Not (ZQuery1.FieldByName('ModKonto').AsString = '-1') Then
                        Begin
                          MessageDlg('Modkonto kan ikke findes',mtInformation,[mbOk],0);
                          Svar := NrStr + ': ' + FindBrugerFraKonto(ZQuery1.FieldByName('ModKonto').AsString) +
                            ' kan ikke findes';
                          Stop := True;
                          Exit;
                        End;
                    End;
                End;
            End
          Else
            Begin
              ZQuery1.Last; // Forcerer et stop...
            End;
          ZQuery1.Next;
        End;
      OK := Not Stop;
    End;

  // Check modkonto ikke automatisk moms
  If OK Then
    Begin
      ZQuery1.First;
      IF ZQuery1.RecordCount > 0 Then
        Begin
          // Gå til den første med dette bilag nr
          Stop := False;
          While Not Stop And not ZQuery1.EOF Do
            Begin
              If (ZQuery1.FieldByName('NoKasse').AsString = NoKasse) and
               (ZQuery1.FieldByName('BilagsNr').AsString = NrStr) then
                Begin // Samme bilagsnr
                  If Not ZQuery1.FieldByName('Modkonto').IsNull Then
                    Begin // Se om konto har momskode
                      StopMoms := False;
                      With ZQuery2.SQL do
                        Begin
                          Clear;
                          Add('Select * from kontobes where Afd = ' + CurrentAfd +
                              ' and id = ' + ZQuery1.FieldByName('modkonto').AsString);
                        End;
                      ZQuery2.Open;
                      ZQuery2.First;
                      While Not ZQuery2.EOF and Not StopMoms Do
                        Begin
                          If (ZQuery2.FieldByName('Afd').AsString = CurrentAfd) And
                             (ZQuery2.FieldByName('id').AsString =
                                ZQuery1.FieldByName('ModKonto').AsString) Then
                            Begin
                              StopMoms := Not (ZQuery2.FieldByName('MomsKode').IsNull);
                              If StopMoms Then
                                Begin
                                  Svar := NrStr + ': Modkonto ' +
                                    ZQuery2.FieldByName('BrugerKonto').AsString + ' ' +
                                    ZQuery2.FieldByName('Beskrivelse').AsString +
                                    ' har automatisk moms - kan ikke være modkonto !';
                                End;
                            End;
                          If Not StopMoms Then ZQuery2.Next;
                        End; // While
                      Stop := StopMoms;
                    End;
                End
              Else
                Begin
                  Stop := True;
                End;
              ZQuery1.Next;
            End;
        End;
      OK := Not StopMoms;
    End;

  // Check om momskode passer med debet/kredit Salgsmoms = debet og købsmoms = kredit
  If OK Then
    Begin
      Svar := '';
      ZQuery1.First;
      If ZQuery1.RecordCount > 0 Then
        Begin
          // Gå til den første med dette bilag nr
          Stop := False;
          While Not Stop And not ZQuery1.EOF Do
            Begin // Samme bilagsnr
              If (ZQuery1.FieldByName('BilagsNr').AsString = NrStr) and
                Not ZQuery1.FieldByName('Moms').IsNull Then
                Begin // Se om bilag har momskode
                  With ZQuery2.SQL do
                    Begin
                      Clear;
                      Add('Select * from momskode where Afd = ' + CurrentAfd +
                          ' and navn = ' + ZQuery1.FieldByName('Moms').AsString);
                    End;
                  ZQuery2.Open;
                  ZQuery2.First;
                  If ZQuery2.RecordCount > 0 Then
                    Begin // Ved salgsmoms = debet
                      If ZQuery2.FieldByName('SalgsMoms').AsBoolean Then
                        Begin // Salgsmoms
                          If Not (ZQuery1.FieldByName('D_K').AsString = 'K') Then
                            Begin
                              Stop := True;
                              Svar := NrStr + ': Salgsmoms skal krediteres !!!';
                            End;
                        End
                      Else
                        Begin // Købsmoms
                          If Not (ZQuery1.FieldByName('D_K').AsString = 'D') Then
                            Begin
                              Stop := True;
                              Svar := NrStr + ': Købsmoms skal debeteres !!!';
                            End;
                        End;
                    End;
                End;
              ZQuery1.Next;
            End; // While
        End;
      OK := (Svar = '');
    End;

  // Fomål
  If OK Then
    Begin
      ZQuery1.First;
      If ZQuery1.RecordCount > 0 Then
        If CheckBilagFormaal.Checked then
          Begin
            if ZQuery1.FieldByName('OkoNr').IsNull then
              Begin
                Svar := NrStr + ': Formål skal angives !!!';
                OK := False;
              End;
          End;
    End;
  Forundersoegelse := OK;
end;


//**********************************************************
// Tjek Kassekladde
//**********************************************************
procedure TKasseKladdeForm.TjekKassekladdeExecute(Sender: TObject);
Var A     : Integer;
    NrStr   : String;
    Svar    : String;
    OldSvar : String;
begin
  // Løb kassekladden igennem for fejl
  A := 1;
  TjekMemo.Lines.Clear;
  OldSvar := '';
  While A < StringGrid1.RowCount Do
    Begin
      // Find Bilag udfra bilagsnr og lije
      NrStr := StringGrid1.Cells[KasBL,A];
      If Not ForUndersoegelse(
        PDataKassekladdeDef(KasseKladdeDefNrListe.Items[ComboKassekladde.ItemIndex])^.Nr,
        NrStr,Svar) Then
        Begin // Indsæt beskrivelse i fejl vindue
          Kassekladde_Tjek_Panel.Visible := True;
          If Oldsvar <> Svar Then
            Begin
              TjekMemo.Lines.Add(Svar);
              OldSvar := Svar;
            End;
        End;
      Inc(A);
    End;
 If TjekMemo.Lines.Count > 0 Then
   Begin // Fejl i kladde
     TjekMemo.Font.Color := ClRed;
     TjekMemo.Lines.Add('FEJL i kassekladde, som skal rettes inden der kan bogføres!');
     TjekMemo.Font.Color := ClBlack;
   End
 Else
   Begin
     Kassekladde_Tjek_Panel.Visible := False;
     MessageDlg('Holbæk fandt ingen fejl i kassekladde!',mtInformation,[mbOk],0);
   End;
end;


//**********************************************************
// Indstil Afstem stringgrid
//**********************************************************
Procedure TKasseKladdeForm.IndstilAfstemStringGrid;
Begin
  Indstil_StringGrid_NonEdit(AfstemStringGrid);
  AfstemStringGrid.Columns.Clear;
  AfstemStringGrid.Columns.Add;
  AfstemStringGrid.Columns.Add;
  AfstemStringGrid.Columns.Add;
  AfstemStringGrid.Columns.Add;
  AfstemStringGrid.Columns.Add;
  AfstemStringGrid.Columns.Add;
  AfstemStringGrid.Columns.Add;

  //
  AfstemStringGrid.Columns[AfNavn].Title.Caption          := 'Navn';
  AfstemStringGrid.Columns[AfNavn].Width                  := 150;
  AfstemStringGrid.Columns[AfNavn].Alignment              := taLeftJustify;

  AfstemStringGrid.Columns[AfKonto].Title.Caption         := 'Konto';
  AfstemStringGrid.Columns[AfKonto].Width                 := 100;
  AfstemStringGrid.Columns[AfKonto].Alignment             := taRightJustify;

  AfstemStringGrid.Columns[AfStart].Title.Caption         := 'Startsaldo';
  AfstemStringGrid.Columns[AfStart].Width                 := 100;
  AfstemStringGrid.Columns[AfStart].Alignment             := taRightJustify;

  AfstemStringGrid.Columns[AfBogfoert].Title.Caption      := 'Bogført';
  AfstemStringGrid.Columns[AfBogfoert].Width              := 100;
  AfstemStringGrid.Columns[AfBogfoert].Alignment          := taRightJustify;

  AfstemStringGrid.Columns[AfBevaeg].Title.Caption        := 'Bevægelse';
  AfstemStringGrid.Columns[AfBevaeg].Width                := 100;
  AfstemStringGrid.Columns[AfBevaeg].Alignment            := taRightJustify;

  AfstemStringGrid.Columns[Afslut].Title.Caption          := 'Slutsaldo';
  AfstemStringGrid.Columns[Afslut].Width                  := 100;
  AfstemStringGrid.Columns[Afslut].Alignment              := taRightJustify;

  AfstemStringGrid.Columns[AfNr].Title.Caption            := 'Nr';
  AfstemStringGrid.Columns[AfNr].Width                    := 60;
  AfstemStringGrid.Columns[AfNr].Alignment                := taRightJustify;
  AfstemStringGrid.Columns[AfNr].Visible                  := False;

  PageControl1.Color := H_Menu_knapper_Farve;

  AfstemStringGrid.Options  := [goTabs];
  AfstemStringGrid.FocusRectVisible          :=False;
end;


//**********************************************************
// Beregn kontisaldi
//**********************************************************
procedure TKasseKladdeForm.BeregnKontiSaldi(Kassekladde, BogFoert : Boolean;
  VisningFra, VisningTil : TDateTime; PeriodeNr : String);
Var
   PKontiRec         : PDataKonto;
   KontoAtFinde      : LongInt;
   A                 : LongInt;
   B                 : LongInt;
   Found             : Boolean;
   Stop              : Boolean;
   ForrigeBilagsKontoNr   : LongInt;
   NaesteKassekladde : Boolean;
   NaesteBilag       : Boolean;

Begin
  // Ud fra antallet af konti i KontoBes laves en saldo udregning
  If Kassekladde or Bogfoert Then
    Begin
      AlleData.Clear;
      ForrigeBilagsKontoNr := -1;
      // Konti indlæses
      With ZQuery2.SQL do
        Begin
          Clear;
          Add('Select * from kontobes where Afd = ' + CurrentAfd);
        End;
      ZQuery2.Open;
      ZQuery2.First;
      While Not ZQuery2.EOF Do
        Begin
          If ZQuery2.FieldByName('Afd').AsString = CurrentAfd Then
            Begin
              New(PKontiRec);
              PKontiRec^.KontoNr     := ZQuery2.FieldByName('Id').AsInteger;
              PKontiRec^.BrugerKonto := ZQuery2.FieldByName('BrugerKonto').AsInteger;
              PKontiRec^.Beskrivelse := ZQuery2.FieldByName('Beskrivelse').AsString;
              PKontiRec^.DebetBogfoert          := 0;
              PKontiRec^.KreditBogFoert         := 0;
              PKontiRec^.DebetKassekladde       := 0;
              PKontiRec^.KreditKassekladde      := 0;
              PKontiRec^.StartSaldoBilag        := 0;
              PKontiRec^.StartSaldoKasse        := 0;
              PKontiRec^.Genvej  := ZQuery2.FieldByName('KGB').AsString;
              PKontiRec^.Moms    := ZQuery2.FieldByName('MomsKode').AsString;
              // Fra
              If ZQuery2.FieldByName('Fra').IsNull Then
                Begin
                  PKontiRec^.SumFra  := 0;
                End
              Else
                Begin
                  PKontiRec^.SumFra := ZQuery2.FieldByName('Fra').AsInteger;
                End;
              // Til
              If ZQuery2.FieldByName('Til').IsNull Then
                Begin
                  PKontiRec^.SumTil := 0;
                End
              Else
                Begin
                  PKontiRec^.SumTil := ZQuery2.FieldByName('Til').AsInteger;
                End;
              // Sum Med
              PKontiRec^.SumMed     := ZQuery2.FieldByName('SumMed').AsBoolean;
              // Sum Type
              PKontiRec^.SumType    := ZQuery2.FieldByName('SumType').AsInteger;
              // Type
              Try
                PKontiRec^.KontoType := ZQuery2.FieldByName('Type').AsInteger;
              Except
                PKontiRec^.KontoType := 0;
              End;
              // Visning D- K
              PKontiRec^.VisningDK := ZQuery2.FieldByName('VisningD_K').AsBoolean;
              AlleData.Add(PKontiRec);
            End;
          ZQuery2.Next;
        End;
    End;
  If AlleData.Count = 0 Then
    Begin
      MessageDlg('Ingen konti defineret',mtInformation,[mbOk] ,0);
      Exit;
    End;
  // Beregn bogførte bilag
  If Bogfoert Then
    Begin
      // Nulstil de bogførte
      A := 0;
      While A < (AlleData.Count) Do
        Begin
          PKontiRec := AlleData.Items[A];
          PKontiRec^.StartSaldoBilag        := 0;
          PKontiRec^.DebetBogfoert          := 0;
          PKontiRec^.KreditBogFoert         := 0;
          Inc(A);
        End;
      // ** Søg igennem Bilag basen: bilag for bilag
      With ZQuery1.SQL do
        Begin
          Clear;
          Add('Select * from bilag where Afd = ' + CurrentAfd +
              ' and periode = ' +  PeriodeNr);
        End;
      ZQuery1.Open;
      If ZQuery1.RecordCount = 0 Then
        Begin
        end;
      ZQuery1.First;
      While Not ZQuery1.EOF Do
        Begin
          NaesteBilag := False;
          // Formål
          If Not NaesteBilag And (ComboFormaal.ItemIndex <> 0) Then
            Begin
              NaesteBilag := (ZQuery1.FieldByName('OkoNr').AsString <>
               FormaalNrListe.Strings[ComboFormaal.ItemIndex]);
            End;
          // Dato
          If Not NaesteBilag Then
            Begin
              NaesteBilag :=
              (ZQuery1.FieldByName('Dato').AsFloat < DateTimeToJulianDate(VisningFra)) or
              (ZQuery1.FieldByName('Dato').AsFloat > DateTimeToJulianDate(VisningTil))
            End;
          If Not NaesteBilag Then
            Begin
              // Ved bogførte bilag gemmes konto = -1
              If Not (ZQuery1.FieldByName('Konto').AsString = '-1') Then
                Begin
                  A := 0;
                  Found := False;
                  KontoAtFinde := ZQuery1.FieldByName('Konto').AsInteger;
                  While (Not Found) And (A < AlleData.Count) do
                    begin
                      PKontiRec := AlleData.Items[A];
                      Found := (KontoAtFinde = PKontiRec^.KontoNr);
                      Inc(A);
                    end;
                  If Not Found Then
                    Begin
                      MessageDlg('Følgende bilag er ikke posteret : ' +
                            ZQuery1.FieldByName('BilagsNr').AsString,
                            mtError,[mbOk] ,0);
                    End;
                  Dec(A);
                  PKontiRec := AlleData.Items[A];
                End;
              If ZQuery1.FieldByName('Konto').AsInteger = -1 Then
                 Begin
                   // Bilag er bogført derfor fratrækkes startsaldo på debet
                  If ZQuery1.FieldByName('D_K').AsString = 'D' Then
                    Begin
                      PKontiRec^.StartSaldoBilag := PKontiRec^.StartSaldoBilag -
                        ZQuery1.FieldByName('Beloeb').AsCurrency;
                      PKontiRec^.KreditBogFoert := PKontiRec^.KreditBogfoert -
                        ZQuery1.FieldByName('Beloeb').AsCurrency;
                    End
                  Else
                    Begin
                      PKontiRec^.StartSaldoBilag := PKontiRec^.StartSaldoBilag +
                        ZQuery1.FieldByName('Beloeb').AsCurrency;
                      PKontiRec^.DebetBogfoert := PKontiRec^.DebetBogfoert -
                        ZQuery1.FieldByName('Beloeb').AsCurrency;
                    End;
                 End
              Else
                Begin // Ikke startsaldo men normal bilag
                  If ZQuery1.FieldByName('D_K').AsString = 'D' Then
                    Begin // Debet Bogført
                      PKontiRec^.DebetBogfoert := PKontiRec^.DebetBogfoert +
                        ZQuery1.FieldByName('Beloeb').AsCurrency;
                    End
                  Else
                    Begin // Kredit Bogført
                      PKontiRec^.KreditBogfoert := PKontiRec^.KreditBogfoert +
                            ZQuery1.FieldByName('Beloeb').AsCurrency;
                    End;
                End;
            End;
          ZQuery1.Next;
        End;
    End; // Slut beregning bogført
  // Beregning af kassekladde
  If Kassekladde Then
    Begin
      // Nulstil kassekladde
      A := 0;
      While A < (AlleData.Count-1) Do
        Begin
          PKontiRec := AlleData.Items[A];
          PKontiRec^.StartSaldoKasse        := 0;
          PKontiRec^.DebetKassekladde       := 0;
          PKontiRec^.KreditKassekladde      := 0;
          Inc(A);
        End;
      // ** Søg igennem Bilag basen: bilag for bilag
      With ZQuery1.SQL do
        Begin
          Clear;
          Add('Select * from kassekladde where Afd = ' + CurrentAfd +
              ' and periode = ' +  PeriodeNrListe.Strings[ComboPeriode.ItemIndex]);
        End;
      ZQuery1.Open;
      If ZQuery1.RecordCount = 0 Then
        Begin
        end;
      ZQuery1.First;
      While Not ZQuery1.EOF Do
        Begin
          NaesteKassekladde := False;
          // Formål
          If Not NaesteKassekladde And (ComboFormaal.ItemIndex <> 0) Then
            Begin
              NaesteKassekladde := (ZQuery1.FieldByName('OkoNr').AsString <>
               FormaalNrListe.Strings[ComboFormaal.ItemIndex]);
            End;
          // Dato
          If Not NaesteKassekladde Then
            Begin
              NaesteKassekladde :=
              (ZQuery1.FieldByName('Dato').AsFloat < DateTimeToJulianDate(VisningFra)) or
              (ZQuery1.FieldByName('Dato').AsFloat > DateTimeToJulianDate(VisningTil))
            End;
          If Not NaesteKassekladde Then
            Begin // Skal vises
              KontoAtFinde := ZQuery1.FieldByName('Konto').AsInteger;
              A := 0;
              Found := False;
              While (Not Found) And (A < AlleData.Count) do
                begin
                  PKontiRec := AlleData.Items[A];
                  Found := (KontoAtFinde = PKontiRec^.KontoNr);
                  Inc(A);
                end;
              If Not Found Then
                Begin
                  MessageDlg('Følgende bilag er ikke posteret : ' +
                        ZQuery1.FieldByName('BilagsNr').AsString,mtError,[mbOk] ,0);
                End;
              Dec(A);
              PKontiRec := AlleData.Items[A];
    //          Inc(PKontiRec^.AntalBilag);
              If ZQuery1.FieldByName('Konto').AsInteger = -1 Then
                 Begin
                   PKontiRec^.StartSaldoKasse := PKontiRec^.StartSaldoKasse +
                     ZQuery1.FieldByName('Beloeb').AsCurrency;
                   // Bilag er fratrækkes startsaldo på debet ellers dobbelt
                   PKontiRec^.DebetKasseKladde := PKontiRec^.DebetKassekladde -
                     ZQuery1.FieldByName('Beloeb').AsFloat;
                 End
              Else
                Begin
                  If ZQuery1.FieldByName('D_K').AsString = 'D' Then
                    Begin // Debet
                      PKontiRec^.DebetKasseKladde := PKontiRec^.DebetKassekladde +
                        ZQuery1.FieldByName('Beloeb').AsCurrency;
                    End
                  Else
                    Begin // Kredit
                      PKontiRec^.KreditKasseKladde := PKontiRec^.KreditKassekladde +
                         ZQuery1.FieldByName('Beloeb').AsCurrency;
                    End;
                End;
              // Er der modkonto ?
              If Not ZQuery1.FieldByName('ModKonto').IsNull Then
                Begin // Der er modkonto
                  // Spørg om åbningssaldo
                  If ZQuery1.FieldByName('ModKonto').AsInteger = -1 Then
                    Begin
                      KontoAtFinde := ZQuery1.FieldByName('id').AsInteger;
                    End
                  Else
                    Begin
                      KontoAtFinde := ZQuery1.FieldByName('ModKonto').AsInteger;
                    End;
                  A := 0;
                  Found := False;
                  While (Not Found) And (A < AlleData.Count) do
                    begin
                      PKontiRec := AlleData.Items[A];
                      Found := (KontoAtFinde = PKontiRec^.KontoNr);
                      Inc(A);
                    end;
                  If Not Found Then
                    Begin
                      MessageDlg('Følgende bilag er ikke posteret : ' +
                            ZQuery1.FieldByName('BilagsNr').AsString,
                            mtError,[mbOk] ,0);
                    End;
                  Dec(A);
                  PKontiRec := AlleData.Items[A];
    //              Inc(PKontiRec^.AntalBilag);
                  If ZQuery1.FieldByName('ModKonto').AsInteger = -1 Then
                    Begin
                      PKontiRec^.StartSaldoKasse := PKontiRec^.StartSaldoKasse +
                        ZQuery1.FieldByName('Beloeb').AsCurrency;
                      // Bilag er fratrækkes startsaldo på debet ellers dobbelt
                      PKontiRec^.DebetKasseKladde := PKontiRec^.DebetKassekladde -
                        ZQuery1.FieldByName('Beloeb').AsFloat;
                    End
                  Else
                    Begin
                      If ZQuery1.FieldByName('D_K').AsString = 'D' Then
                        Begin // Modkonto = Kredit
                          PKontiRec^.KreditKassekladde := PKontiRec^.KreditKassekladde +
                             ZQuery1.FieldByName('Beloeb').AsCurrency;
                        End
                      Else
                        Begin
                          PKontiRec^.DebetKassekladde := PKontiRec^.DebetKassekladde +
                             ZQuery1.FieldByName('Beloeb').AsCurrency;
                        End;
                    End;
                End;
            End;
          ZQuery1.Next;
        End;
    End;
  If Bogfoert Then
    Begin
      // Nu skal SUM konti udregnes.
      A := 0;
      While A < AlleData.Count Do
        Begin   // Alle konti løbes igennem
          If TDataKonto(AlleData.Items[A]^).KontoType = 2 Then // Sumkonti
            Begin // Sum Konto skal beregnes
              Stop := False;
              B := 0;
              While not Stop and (B < AlleData.Count) Do
                Begin
                  If (TDataKonto(AlleData.Items[B]^).BrugerKonto  >=
                    TDataKonto(AlleData.Items[A]^).SumFra)  and
                    (TDataKonto(AlleData.Items[B]^).BrugerKonto <=
                    TDataKonto(AlleData.Items[A]^).SumTil) And
                    ((not (TDataKonto(AlleData.Items[B]^).KontoType = 2) or // Sum
                      TDataKonto(AlleData.Items[A]^).SumMed)) Then
                    Begin
                      // Data for konto skal lægges til
                      Case TDataKOnto(AlleData.Items[B]^).SumType of
                        0 : Begin // D-K
                              TDataKonto(AlleData.Items[A]^).KreditBogfoert :=
                                TDataKOnto(AlleData.Items[A]^).KreditBogfoert  +
                                TDataKOnto(AlleData.Items[B]^).KreditBogfoert;
                              TDataKonto(AlleData.Items[A]^).DebetBogfoert :=
                                TDataKOnto(AlleData.Items[A]^).DebetBogfoert  +
                                TDataKOnto(AlleData.Items[B]^).DebetBogfoert;
                              TDataKonto(AlleData.Items[A]^).StartSaldoBilag :=
                                TDataKOnto(AlleData.Items[A]^).StartSaldoBilag  +
                                TDataKOnto(AlleData.Items[B]^).StartSaldoBilag;
                            End;
                        1 : Begin // Sum K-D
                              TDataKonto(AlleData.Items[A]^).KreditBogfoert :=
                                TDataKOnto(AlleData.Items[A]^).KreditBogfoert  +
                                TDataKOnto(AlleData.Items[B]^).DebetBogfoert;
                              TDataKonto(AlleData.Items[A]^).DebetBogfoert :=
                                TDataKOnto(AlleData.Items[A]^).DebetBogfoert  +
                                TDataKOnto(AlleData.Items[B]^).KreditBogfoert;
                              TDataKonto(AlleData.Items[A]^).StartSaldoBilag :=
                                TDataKOnto(AlleData.Items[A]^).StartSaldoBilag  +
                                TDataKOnto(AlleData.Items[B]^).StartSaldoBilag;
                            End;
                        2 : Begin // Sum D
                              TDataKonto(AlleData.Items[A]^).DebetBogfoert :=
                                TDataKOnto(AlleData.Items[A]^).DebetBogfoert  +
                                TDataKOnto(AlleData.Items[B]^).DebetBogfoert;
                            End;
                        3 : Begin // Sum K
                              TDataKonto(AlleData.Items[A]^).KreditBogfoert :=
                                TDataKOnto(AlleData.Items[A]^).KreditBogfoert  +
                                TDataKOnto(AlleData.Items[B]^).KreditBogfoert;
                            End;
                      End; // End Case
                    End;
                  Stop := (B = A);
                  If Stop Then
                    Begin  // Beregnet saldo
                      Case TDataKonto(AlleData.Items[A]^).SumType of
                        0 : Begin // Sum D_K
                              TDataKonto(AlleData.Items[A]^).BeregnetSaldo :=
                                TDataKOnto(AlleData.Items[A]^).DebetBogfoert -
                                TDataKOnto(AlleData.Items[A]^).KreditBogFoert +
                                TDataKOnto(AlleData.Items[A]^).StartSaldoBilag;
                            End;
                        1 : Begin // Sum K-D
                              TDataKonto(AlleData.Items[A]^).BeregnetSaldo :=
                                TDataKOnto(AlleData.Items[A]^).KreditBogfoert -
                                TDataKOnto(AlleData.Items[A]^).DebetBogFoert +
                                TDataKOnto(AlleData.Items[A]^).StartSaldoBilag;
                            End;
                        2 : Begin // Sum D
                              TDataKonto(AlleData.Items[A]^).BeregnetSaldo :=
                                TDataKOnto(AlleData.Items[A]^).DebetBogfoert +
                                TDataKOnto(AlleData.Items[A]^).StartSaldoBilag;
                            End;
                        3 : Begin // Sum K
                              TDataKonto(AlleData.Items[A]^).BeregnetSaldo :=
                                TDataKOnto(AlleData.Items[A]^).KreditBogFoert +
                                TDataKOnto(AlleData.Items[A]^).StartSaldoBilag;
                            End;
                      End; // End Case
                    End;
                  Inc(B);
                End;
            End
          Else
            Begin // Beregnet saldo for ikke sum-konti
              If TDataKonto(AlleData.Items[A]^).SumType <> 3 Then // Tekst
                Begin
                  If TDataKonto(AlleData.Items[A]^).VisningDK Then
                    Begin
                      TDataKonto(AlleData.Items[A]^).BeregnetSaldo :=
                        TDataKOnto(AlleData.Items[A]^).DebetBogfoert -
                        TDataKOnto(AlleData.Items[A]^).KreditBogFoert +
                        TDataKOnto(AlleData.Items[A]^).StartSaldoBilag;
                    End
                  Else
                    Begin
                      TDataKonto(AlleData.Items[A]^).BeregnetSaldo :=
                        TDataKOnto(AlleData.Items[A]^).KreditBogFoert -
                        TDataKOnto(AlleData.Items[A]^).DebetBogfoert +
                        TDataKOnto(AlleData.Items[A]^).StartSaldoBilag;
                    End;
                End
              Else
                Begin
                  TDataKonto(AlleData.Items[A]^).BeregnetSaldo := 0;
                End;
            End;
          Inc(A);
        End;
    End;
End;


//**********************************************************
// Bogfør
//**********************************************************
procedure TKasseKladdeForm.BogFoerExecute(Sender: TObject);
Var NrStr        : String;
    A            : Integer;
    MomsMed      : Boolean;
    Momskonto    : String;
    MomsProcent  : Real;
    ModKonto     : String;
    Tekst        : String;
    SalgsMoms    : Boolean;
    Momsbeloeb   : Real;
    HovedKonto   : String;
    Debet        : Boolean;
    Dato         : TDateTime;
    Svar         : String;
    LastNrStr    : String;
    HelpListe    : TStringList;
    HelpNr       : Integer;

begin
  If StringGrid1.RowCount = 1 Then
    Begin
      MessageDlg('Ingen bilag at bogføre - kassekladde er tom',mtInformation,[mbOk],0);
      Exit;
    End;
  // Hvormange bilag ønskes bogført
  HelpListe := TStringList.Create;
  HelpListe.Sorted := True;
  HelpListe.Duplicates := dupIgnore;
  For A := StringGrid1.Selection.Top to StringGrid1.Selection.Bottom do
    Begin
      HelpListe.Add(StringGrid1.Cells[KasBL,A]);
    End;
  MomsBeloeb := 0;
  MomsProcent := 0;
  SalgsMoms := False;
  NrStr     := '';
  LastNrStr := '-1';
  // Find Record
  With ZBogfoerKassekladde.SQL do
    Begin
      Clear;
      Add('Select * from kassekladde where Afd = ' + CurrentAfd +
          ' and periode = ' +  PeriodeNrListe.Strings[ComboPeriode.ItemIndex] +
          ' and nokasse = ' +
          PDataKassekladdeDef(KasseKladdeDefNrListe.Items[ComboKassekladde.ItemIndex])^.Nr);
    End;
  ZBogfoerKassekladde.Open;
  If ZBogfoerKassekladde.RecordCount = 0 Then
    Begin
      MessageDlg('Bilag kan ikke findes!',mtError,[mbOk],0);
      Exit;
    end;
  // Gå til den første med dette bilag nr
  ZBogfoerKassekladde.First;
  // Dialog
  If MessageDlg('Skal antal: ' + IntToStr(HelpListe.Count) +
     ' bilag bogføres?  Det kan ikke fortrydes !', mtConfirmation,[mbYes,mbNo],0) = mrYes Then
    Begin // Bogfør bilag
      A := 0;
      While A < HelpListe.Count Do
        Begin
          // Bilag fra selection forsøges bogført
          NrStr := HelpListe.Strings[A];
          If Forundersoegelse(
            PDataKassekladdeDef(KasseKladdeDefNrListe.Items[ComboKassekladde.ItemIndex])^.Nr,
            NrStr,Svar) Then
            Begin // Bilag kan bogføres
              While (Not ZBogfoerKassekladde.EOF) do
                Begin
                  If (ZBogfoerKassekladde.FieldByName('BilagsNr').AsString =  NrStr) Then
                    Begin
                      Dato := ZBogfoerKassekladde.FieldByName('Dato').AsDateTime;
                      Debet := ZBogfoerKassekladde.FieldByName('D_K').AsString = 'D';
                      ModKonto := ZBogfoerKassekladde.FieldByName('ModKonto').AsString;
                      HovedKonto := ZBogfoerKassekladde.FieldByName('Konto').AsString;
                      MomsMed := False;
                      Tekst   := ZBogfoerKassekladde.FieldByName('Tekst').AsString;
                      // Der skal undersøges om moms skal trækkes i denne linje
                      If ZBogfoerKassekladde.FieldByName('Moms').AsString <> '' Then
                        Begin // Der skal tages moms
                          With ZBogfoerMoms.SQL do
                            Begin
                              Clear;
                              Add('Select * from momskode where Afd = ' + CurrentAfd +
                                  ' and navn = ' + ZBogfoerKassekladde.FieldByName('Moms').AsString);
                            End;
                          ZBogfoerMoms.Open;
                          If ZBogfoerMoms.RecordCount = 0 Then
                            Begin // Momsen huskes at skulle beregnes
                              MomsMed     := True;
                              Momskonto   := ZBogfoerMoms.FieldByName('MomsKonto').AsString;
                              MomsProcent := ZBogfoerMoms.FieldByName('Procent').AsFloat;
                              SalgsMoms   := ZBogfoerMoms.FieldByName('SalgsMoms').AsBoolean;
                            End
                           Else
                            Begin
                              MessageDlg('Momsen ukendt !',mtError,[mbOk],0);
                              Exit;
                            End;
                        End;
                      // Bogfør bilag i bilagtabel
                      Try
                        With ZBogfoerBilag.SQL do
                          Begin
                            Clear;
                            Add('Select * from bilag order by nr');
                          End;
                        ZBogfoerBilag.Open;
                        If ZBogfoerBilag.RecordCount = 0 Then
                          Begin
                            HelpNr := 1;
                          end
                        Else
                          Begin
                            ZBogfoerBilag.Last;
                            HelpNr := ZBogfoerBilag.FieldByName('Nr').AsInteger + 1;
                          end;
                        ZBogfoerBilag.Append;
                        ZBogfoerBilag.Edit;
                        ZBogfoerBilag.FieldByName('Nr').AsInteger           := HelpNr;
                        ZBogfoerBilag.FieldByName('Afd').AsString :=
                          ZBogfoerKassekladde.FieldByName('Afd').AsString;
                        ZBogfoerBilag.FieldByName('Periode').AsString :=
                          ZBogfoerKassekladde.FieldByName('Periode').AsString;
                        ZBogfoerBilag.FieldByName('BilagsNr').AsString :=
                          ZBogfoerKassekladde.FieldByName('BilagsNr').AsString;
                        ZBogfoerBilag.FieldByName('Tekst').AsString :=
                          ZBogfoerKassekladde.FieldByName('Tekst').AsString;
                        ZBogfoerBilag.FieldByName('Type').AsString :=
                          ZBogfoerKassekladde.FieldByName('Type').AsString;
                        ZBogfoerBilag.FieldByName('D_K').AsString :=
                          ZBogfoerKassekladde.FieldByName('D_K').AsString;
                        ZBogfoerBilag.FieldByName('Konto').AsString :=
                          ZBogfoerKassekladde.FieldByName('Konto').AsString;
                        ZBogfoerBilag.FieldByName('Moms').AsString :=
                          ZBogfoerKassekladde.FieldByName('Moms').AsString;
                        ZBogfoerBilag.FieldByName('Dato').AsString :=
                          ZBogfoerKassekladde.FieldByName('Dato').AsString;
                        ZBogfoerBilag.FieldByName('Beloeb').AsString :=
                          ZBogfoerKassekladde.FieldByName('Beloeb').AsString;
                        // Posterings dato indsættes
                        ZBogfoerBilag.FieldByName('BogfoertDato').AsDateTime := Now;
                        // Check moms
                        MomsBeloeb := ZBogfoerKassekladde.FieldByName('Beloeb').AsCurrency;
                        If MomsMed Then
                          Begin // Beløbet skal der tages moms af.
                            ZBogfoerBilag.FieldByName('Beloeb').AsCurrency :=
                              (*ZBogfoerKassekladde.FieldByName('Beloeb').AsCurrency *
                              (1/(1 + (MomsProcent/100))));*)
                              Round((ZBogfoerKassekladde.FieldByName('Beloeb').AsCurrency *
                              (1/(1 + (MomsProcent/100))))*100) / 100;
                          End;
                        // Økomærke
                        ZBogfoerBilag.FieldByName('OkoNr').AsString :=
                          ZBogfoerKassekladde.FieldByName('OkoNr').AsString;
                        // Gem
                        ZBogfoerBilag.Post;
                      Except
                        MessageDlg('Bilag kunne ikke bogføres!',mtError,[mbOk],0);
                        Exit;
                      End;
                      // Der skal indsættes en ekstra linje til moms
                      If MomsMed then
                        Begin
                          Try
                            With ZBogfoerBilag.SQL do
                              Begin
                                Clear;
                                Add('Select * from bilag order by nr');
                              End;
                            ZBogfoerBilag.Open;
                            If ZBogfoerBilag.RecordCount = 0 Then
                              Begin
                                HelpNr := 1;
                              end
                            Else
                              Begin
                                ZBogfoerBilag.Last;
                                HelpNr := ZBogfoerBilag.FieldByName('Nr').AsInteger + 1;
                              end;
                            ZBogfoerBilag.Append;
                            ZBogfoerBilag.Edit;
                            ZBogfoerBilag.FieldByName('Afd').AsString :=
                              ZBogfoerKassekladde.FieldByName('Afd').AsString;
                            ZBogfoerBilag.FieldByName('Periode').AsString :=
                              ZBogfoerKassekladde.FieldByName('Periode').AsString;
                            ZBogfoerBilag.FieldByName('BilagsNr').AsString :=
                              ZBogfoerKassekladde.FieldByName('BilagsNr').AsString;
                            ZBogfoerBilag.FieldByName('Tekst').AsString :=
                              ZBogfoerKassekladde.FieldByName('Tekst').AsString;
                            ZBogfoerBilag.FieldByName('Type').AsString :=
                              ZBogfoerKassekladde.FieldByName('Type').AsString;
                            ZBogfoerBilag.FieldByName('Konto').AsString := MomsKonto;
                            ZBogfoerBilag.FieldByName('Moms').AsString :=
                              ZBogfoerKassekladde.FieldByName('Moms').AsString;
                            ZBogfoerBilag.FieldByName('Dato').AsString :=
                              ZBogfoerKassekladde.FieldByName('Dato').AsString;
                            ZBogfoerBilag.FieldByName('Beloeb').AsCurrency :=
                              Round(
                              (MomsBeloeb - (Momsbeloeb * (1/(1 + (MomsProcent/100))))
                                   ) * 100) / 100;
                              //MomsBeloeb - (Momsbeloeb * (1/(1 + (MomsProcent/100))));
                            If SalgsMoms Then
                              Begin
                                ZBogfoerBilag.FieldByName('D_K').AsString := 'K';
                              End
                            Else
                              Begin
                                ZBogfoerBilag.FieldByName('D_K').AsString := 'D';
                              End;
                            // Posterings dato indsættes
                            ZBogfoerBilag.FieldByName('BogfoertDato').AsDateTime := Now;
                            // Økomærke
                            ZBogfoerBilag.FieldByName('OkoNr').AsString :=
                              ZBogfoerKassekladde.FieldByName('OkoNr').AsString;
                            // Gem
                            ZBogfoerBilag.Post;
                          Except
                            MessageDlg('Bilag kunne ikke bogføres; postering af moms!',mtError,[mbOk],0);
                            Exit;
                          End;
                        End;
                      // Næste linje med mod postering
                      If Modkonto <> '' Then
                        Begin  // Hvis der var en modpostering så opret linje
                          Try
                            With ZBogfoerBilag.SQL do
                              Begin
                                Clear;
                                Add('Select * from bilag order by nr');
                              End;
                            ZBogfoerBilag.Open;
                            If ZBogfoerBilag.RecordCount = 0 Then
                              Begin
                                HelpNr := 1;
                              end
                            Else
                              Begin
                                ZBogfoerBilag.Last;
                                HelpNr := ZBogfoerBilag.FieldByName('Nr').AsInteger + 1;
                              end;
                            ZBogfoerBilag.Append;
                            ZBogfoerBilag.Edit;
                            ZBogfoerBilag.FieldByName('Nr').AsInteger := HelpNr;
                            ZBogfoerBilag.FieldByName('Afd').AsString :=
                              ZBogfoerKassekladde.FieldByName('Afd').AsString;
                            ZBogfoerBilag.FieldByName('Periode').AsString :=
                              ZBogfoerKassekladde.FieldByName('Periode').AsString;
                            ZBogfoerBilag.FieldByName('BilagsNr').AsString :=
                              ZBogfoerKassekladde.FieldByName('BilagsNr').AsString;
                            ZBogfoerBilag.FieldByName('Tekst').AsString :=
                              ZBogfoerKassekladde.FieldByName('Tekst').AsString;
                            ZBogfoerBilag.FieldByName('Type').AsString :=
                              ZBogfoerKassekladde.FieldByName('Type').AsString;
                            ZBogfoerBilag.FieldByName('Konto').AsString := ModKonto;
                            ZBogfoerBilag.FieldByName('Moms').AsString :=
                              ZBogfoerKassekladde.FieldByName('Moms').AsString;
                            ZBogfoerBilag.FieldByName('Dato').AsString :=
                              ZBogfoerKassekladde.FieldByName('Dato').AsString;
                            If MomsMed Then
                              Begin
                                ZBogfoerBilag.FieldByName('Beloeb').AsCurrency := MomsBeloeb;
                                If SalgsMoms Then
                                  Begin
                                    ZBogfoerBilag.FieldByName('D_K').AsString := 'D';
                                  End
                                Else
                                  Begin
                                    ZBogfoerBilag.FieldByName('D_K').AsString := 'K';
                                  End;
                              End
                            Else
                              Begin
                                ZBogfoerBilag.FieldByName('Beloeb').AsCurrency := MomsBeloeb;
                                If Debet Then
                                  Begin
                                    ZBogfoerBilag.FieldByName('D_K').AsString := 'K';
                                  End
                                Else
                                  Begin
                                    ZBogfoerBilag.FieldByName('D_K').AsString := 'D';
                                  End;
                              End;
                            // Posterings dato indsættes
                            ZBogfoerBilag.FieldByName('BogfoertDato').AsDateTime := Now;
                            // Økomærke
                            ZBogfoerBilag.FieldByName('OkoNr').AsString :=
                              ZBogfoerKassekladde.FieldByName('OkoNr').AsString;
                            // Gem
                            ZBogfoerBilag.Post;
                          Except
                            MessageDlg('Bilag kunne ikke bogføres; modpostering!',mtError,[mbOk],0);
                            Exit;
                          End;
                        End;
                      // Kassekladdebilag er bogført - slet det
                      If  PDataKassekladdeDef(
                          KasseKladdeDefNrListe.Items[ComboKassekladde.ItemIndex])^.Toemmes Then
                        Begin
                          Try
                            ZBogfoerKassekladde.Delete;
                          Except
                            MessageDlg('Bilag i kassekladde kunne ikke fjernes efter bogføring!',
                               mtError,[mbOk],0);
                            Exit;
                          End;
                        End
                      Else
                        Begin  // gå videre til næste linie
                          ZBogfoerKassekladde.Next;
                        End;
                    end
                  Else
                    Begin
                      ZBogfoerKassekladde.Next;
                    end;
                End;
            End
          Else
            Begin
              MessageDlg(Svar,mtInformation,[mbOk],0);
              HelpListe.Free;
              IndlaesBilag;
              Exit;
            End;
          Inc(A);
        End;
      // Opdater afstemningskonti
      BeregnAfStemningsKonti;
    End;
  HelpListe.Free;
  IndlaesBilag;
end;

//**********************************************************
//  Kassekladde - Bogfør alle bilag
//**********************************************************
procedure TKasseKladdeForm.BogfoerAlleExecute(Sender: TObject);
Var R : TRect;
begin
  R.Left   := 0;
  R.Right  := KasOkoNr;
  R.Top    := 1;
  R.Bottom := StringGrid1.RowCount-1;
  StringGrid1.Selection := R;
//  BoegFoerExecute(Sender);
end;

//**********************************************************
// Afstemning: Speed click vis/skjul
//**********************************************************
procedure TKasseKladdeForm.AfstemningsSpeedClick(Sender: TObject);
begin
  Afstemningspanel.Visible := False;
  VisAfstemningskonti.Checked := False;
end;

//**********************************************************
// Beregn moms
//**********************************************************
procedure TKasseKladdeForm.BeregnMoms(Beloeb : Double; MomsStr : String;
  Var Saldo,Moms : String);
Var SaldoDouble : Double;
Begin
  SaldoDouble := Beloeb/(1 + (StrToFloat(MomsStr)) / 100);
  Saldo := FloatToSTrF(SaldoDouble,ffnumber,18,2);
  Moms := FloatToStrF(Beloeb - SaldoDouble,ffnumber,18,2);
End;

//**********************************************************
// Beregn status linie
//**********************************************************
procedure TKasseKladdeForm.OpdaterStatusLinie(ARow : Integer);
(*
1) Linienummer
2) Kontonavn: Navnet på den konto, der er angivet i kolonnen "Kontonr."
3) Nettobeløb: Det beløb, der vil blive konteret på kontoen i "Kontonr." dvs. fratrukket evt. moms
4) Saldo: Saldoen på kontoen i "Kontonr."
5) Moms: Momsandelen af beløbet i beløbs-/debet-/kreditkolonnen

6) Afstemningskonto: Saldo på afstemningskontoen til og med den aktuelle linie
7) Balance: Summen af alle posteringer til og med den aktuelle linie.
 *)
Var NrStr   : String;
    KontoNavn : String;
    Nettobeloeb : String;
    Saldo       : String;
    SaldoKasse  : String;
    MomsAndel   : String;
    KOnto       : String;
    B           : Integer;
    Stop        : Boolean;
Begin
  Try
    If (ARow = 0) Then
      Begin // Er opdateret eller grid tom
        Exit;
      End;
    // Find Bilag udfra bilagsnr og lije
    NrStr := StringGrid1.Cells[KasBL,ARow];
    // Find kontonavn
    Kontonavn := FindKontoBeskrivelse(StringGrid1.Cells[KasKonto,ARow]);
    If StringGrid1.Cells[KasKonto,ARow] = '-1' Then
      Begin // Overførsel
        Kontonavn := 'Overførsel';
      End;
    // Nettobeløb
    If StrToFloat(FjernPunktum(StringGrid1.Cells[KasBeloeb,ARow])) = 0 Then
      Begin // Netto også 0
        Nettobeloeb := '0,00';
        MomsAndel := '0,00';
      End
    Else
      Begin
        BeregnMoms(StrToFloat(FjernPunktum(StringGrid1.Cells[KasBeloeb,ARow])),
           MomsBeregnListe[MomsKodeLIste.IndexOf(
                      StringGrid1.Cells[KasMoms,ARow])],NettoBeloeb,MomsAndel);
      End;
    // Saldo
    Konto := FindKontoFraBruger(StringGrid1.Cells[KasKonto,ARow]);
    Stop := False;
    B := 0;
    If not (AlleData.Count > 0) Then
      Begin // Beregn kassekladde og bogførte bilag og indlæs kontoplan
        BeregnKontiSaldi(True,True,StrToDate('01-01-1900'),StrToDate('01-01-2100'),
          PeriodeNrListe.Strings[ComboPeriode.ItemIndex]);
      End;
    While (Not Stop) And (B < AlleData.Count) Do
      Begin
        If TDataKOnto(AlleData.Items[B]^).KontoNr = StrToInt(Konto) Then
          Begin
            Stop := True;
          End
        Else
          Begin
            Inc(B);
          End;
      End;
    If AlleData.Count > 0 Then
      Begin
        Saldo := 'Saldo bogført: ' + FloatToStrF(
          TDataKOnto(AlleData.Items[B]^).DebetBogfoert -
          TDataKOnto(AlleData.Items[B]^).KreditBogFoert +
          TDataKOnto(AlleData.Items[B]^).StartSaldoBilag +
            TDataKOnto(AlleData.Items[B]^).StartSaldoKasse,ffNumber,18,2);
        SaldoKasse := 'Saldo kassekl: '+ FloatToStrF(
          TDataKOnto(AlleData.Items[B]^).StartSaldoKasse +
          TDataKOnto(AlleData.Items[B]^).DebetKassekladde -
          TDataKOnto(AlleData.Items[B]^).KreditKassekladde,ffNumber,18,2);
      End
    Else
      Begin
        Saldo := 'Saldo bogført: -';
        SaldoKasse := 'Saldo kassekl: -';
      End;
    StatusBilagLabel.Caption := '[' + NrStr  + ']' +
    '     ' + Kontonavn +
    '     ' + 'Nettobeløb: ' + Nettobeloeb +
    '     ' + Saldo +
    '     ' + SaldoKasse +
    '     ' + 'Moms: ' + Momsandel;
  Except
  End;
End;

//**********************************************************
// Beregn Afstemningskonti
//**********************************************************
procedure TKasseKladdeForm.BeregnAfstemningskonti;
Var A : Integer;
    B : Integer;
    Stop : Boolean;
Begin
  BeregnKontiSaldi(True,True,StrToDate('01-01-1900'),StrToDate('01-01-2100'),
    PeriodeNrListe.Strings[ComboPeriode.ItemIndex]);
  AfstemStringGrid.RowCount := 1;
//  AfstemStringGrid.Rows[1].Clear;
  If Not VisAfstemningsKonti.Checked Then
    Begin
      Exit;
    End;
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from afstemningskonti where Afd = ' + CurrentAfd);
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount = 0 Then
    Begin
      AfstemStringGrid.RowCount  := 1;
      MessageDlg('Ingen afstemningskonti valgt endnu!',mtInformation,[mbOk],0);
      Exit;
    end;
  ZQuery1.First;
  AfstemStringGrid.RowCount  := 1;
  A := 0;
  AfstemStringGrid.BeginUpdate;
  ZQuery1.First;
  While Not ZQuery1.Eof Do
    Begin
      Inc(A);
      AfstemStringGrid.RowCount := AfstemStringGrid.RowCount + 1;
      // Data i Alledata
      B := 0;
      Stop := False;
      While Not Stop and (B < AlleData.Count) Do
        Begin
          Stop := (TDataKonto(AlleData.Items[B]^).BrugerKonto =
            ZQuery1.FieldByName('BrugerKonto').AsInteger);
          If not Stop Then Inc(B);
        End;
      If Stop Then
        Begin // Indsæt data i grid
          AfstemStringGrid.Cells[0,A] := TDataKonto(AlleData.Items[B]^).Beskrivelse;
          // Bruger konto nr
          AfstemStringGrid.Cells[1,A] := IntToStr(TDataKonto(AlleData.Items[B]^).BrugerKonto);
          // Startsaldo
          AfstemStringGrid.Cells[2,A] := CurrToStrF(
            TDataKonto(AlleData.Items[B]^).StartSaldoBilag +
            TDataKonto(AlleData.Items[B]^).StartSaldoKasse,ffNumber,2);
          // Bogført
          AfstemStringGrid.Cells[3,A] := CurrToStrF(TDataKonto(AlleData.Items[B]^).DebetBogFoert -
           TDataKonto(AlleData.Items[B]^).KreditBogFoert,ffNumber,2);
          // Bevægelse
          AfstemStringGrid.Cells[4,A] := CurrToStrF(TDataKonto(AlleData.Items[B]^).DebetKassekladde -
           TDataKonto(AlleData.Items[B]^).KreditKassekladde,ffNumber,2);
          // SlutSaldo
          If SpeedSumBogfoertPlusKassekladde.Down Then
            Begin // Slutsaldo = Sum Kassekladde + bogført
              If TDataKonto(AlleData.Items[B]^).VisningDK Then
                Begin  // D-K
                  AfstemStringGrid.Cells[5,A] :=
                  CurrToStrF(
                    TDataKonto(AlleData.Items[B]^).StartSaldoBilag +
                    TDataKonto(AlleData.Items[B]^).StartSaldoKasse +
                    TDataKonto(AlleData.Items[B]^).DebetBogfoert -
                    TDataKonto(AlleData.Items[B]^).KreditBogfoert +
                    TDataKonto(AlleData.Items[B]^).DebetKassekladde -
                    TDataKonto(AlleData.Items[B]^).KreditKassekladde,ffNumber,2);
                End
              Else
                Begin // K-D
                  AfstemStringGrid.Cells[5,A] :=
                  CurrToStrF(
                    TDataKonto(AlleData.Items[B]^).StartSaldoBilag +
                    TDataKonto(AlleData.Items[B]^).StartSaldoKasse +
                    TDataKonto(AlleData.Items[B]^).KreditBogfoert -
                    TDataKonto(AlleData.Items[B]^).DebetBogfoert -
                    TDataKonto(AlleData.Items[B]^).DebetKassekladde +
                    TDataKonto(AlleData.Items[B]^).KreditKassekladde,ffNumber,2);
                End;
            End
          Else If SpeedSumBogfoert.Down Then
            Begin // Bogført
              If TDataKonto(AlleData.Items[B]^).VisningDK Then
                Begin
                  AfstemStringGrid.Cells[5,A] := CurrToStrF(
                    TDataKonto(AlleData.Items[B]^).StartSaldoBilag +
                    TDataKonto(AlleData.Items[B]^).DebetBogfoert -
                    TDataKonto(AlleData.Items[B]^).KreditBogfoert,ffNumber,2);
                End
              Else
                Begin
                  AfstemStringGrid.Cells[5,A] := CurrToStrF(
                    TDataKonto(AlleData.Items[B]^).StartSaldoBilag -
                    TDataKonto(AlleData.Items[B]^).DebetBogfoert +
                    TDataKonto(AlleData.Items[B]^).KreditBogfoert,ffNumber,2);
                End;
            End
          Else If SpeedSumKassekladde.Down Then
            Begin // Kassekladde
              If TDataKonto(AlleData.Items[B]^).VisningDK Then
                Begin
                  AfstemStringGrid.Cells[5,A] := CurrToStrF(
                    TDataKonto(AlleData.Items[B]^).StartSaldoKasse +
                    TDataKonto(AlleData.Items[B]^).DebetKassekladde -
                    TDataKonto(AlleData.Items[B]^).KreditKassekladde,ffNumber,2);
                End
              Else
                Begin
                  AfstemStringGrid.Cells[5,A] := CurrToStrF(
                    TDataKonto(AlleData.Items[B]^).StartSaldoKasse -
                    TDataKonto(AlleData.Items[B]^).DebetKassekladde +
                    TDataKonto(AlleData.Items[B]^).KreditKassekladde,ffNumber,2);
                End;
            End;
        End
      Else
        Begin

        End;
      ZQuery1.Next;
    End;
  AfstemStringGrid.EndUpdate;
End;

//**********************************************************
// Udskriv_Kassekladde
//**********************************************************
procedure TKasseKladdeForm.Udskriv_KassekladdeExecute(Sender: TObject);
Var A : Integer;
    HelpNr : Integer;
    Help1  : String;
begin
  // Lav database med udskrifts database
  // Findes den - så slet
  ZTable1.TableName := DatabaseUdskriv;
  If ZTable1.Exists Then
    Begin // Drop Table
      Try
        With ZQuery1.SQL do
          Begin
            Clear;
            Add('drop table ' + DatabaseUdskriv)
          end;
        ZQuery1.ExecSQL;
      finally
      end;
    end;
  // Lav ny Udskriv_Kassekladde tabel
  Try
    With ZQuery1.SQL do
      Begin
        Clear;
        Add('CREATE TABLE + ' + DatabaseUdskriv +' (');
        Add('  nr  INTEGER NOT NULL PRIMARY KEY,');
        Add('  afd INTEGER NOT NULL,');
        Add('  periode INTEGER,');
        Add('  bilagsnr INTEGER,');
        Add('  tekst VARCHAR(40),');
        Add('  type INTEGER,');
        Add('  d_k CHAR(1),');
        Add('  konto VARCHAR(40),');
        Add('  modkonto VARCHAR(40),');
        Add('  moms INTEGER,');
        Add('  dato TIMESTAMP,');
        Add('  beloeb FLOAT,');
        Add('  nokasse INTEGER,');
        Add('  formaal VARCHAR(40)');
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
  ZQuery1.Close;
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from + ' + DatabaseUdskriv + ' order by nr');
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount = 0 Then
    Begin
      HelpNr := 1;
    end
  Else
    Begin
      ZQuery1.Last;
      HelpNr := ZQuery1.FieldByName('Nr').AsInteger + 1;
    end;
  // Indsæt data i Udskriv_Kassekladde tabel
  A := 1;
  While A < StringGrid1.RowCount Do
    Begin
      Try
        ZQuery1.Append;
        ZQuery1.Edit;
        ZQuery1.FieldByName('Nr').AsInteger           := HelpNr;
        ZQuery1.FieldByName('Afd').AsString           := CurrentAfd;
        ZQuery1.FieldByName('periode').AsString       := ComboPeriode.Items[ComboPeriode.ItemIndex];
        ZQuery1.FieldByName('dato').AsString          := StringGrid1.Cells[KasDato,A];
        ZQuery1.FieldByName('bilagsnr').AsString      := StringGrid1.Cells[KasBL,A];
        ZQuery1.FieldByName('konto').AsString         := StringGrid1.Cells[KasKonto,A];
        ZQuery1.FieldByName('tekst').AsString         := StringGrid1.Cells[KasTekst,A];
        ZQuery1.FieldByName('moms').AsString          := StringGrid1.Cells[KasMoms,A];
        ZQuery1.FieldByName('d_k').AsString           := StringGrid1.Cells[KasDK,A];
        Help1 := FjernPunktum(StringGrid1.Cells[KasBeloeb,A]);
        ZQuery1.FieldByName('Beloeb').AsString        := Help1;
        ZQuery1.FieldByName('modkonto').AsString      := StringGrid1.Cells[KasAfstemning,A];
        ZQuery1.FieldByName('formaal').AsString         := StringGrid1.Cells[KasOkoNr,A];
        // Gem
        ZQuery1.Post;
        ZQuery1.ApplyUpdates;
      Except
        MessageDlg('Kassekladde linje kunne ikke indsættes!',mtError,[mbOk],0);
        ZQuery1.CancelUpdates;
        Exit;
      end;
      Inc(HelpNr);
      Inc(A);
    end;
  // Udskriv_Kassekladde
  SuperPrintForm := TSuperPrintForm.Create(Self);
  SuperPrintForm.TypeRapport := 1;
  SuperPrintForm.RapportTitel := 'Kassekladde';
  SuperPrintForm.IndlaesFlueben;
  SuperPrintForm.IndlaesRapportCombo;
  SuperPrintForm.ShowModal;
  SuperPrintForm.Free;
end;

//**********************************************************
// Kontoplan Udskriv
//**********************************************************
procedure TKasseKladdeForm.Udskriv_kontoplanExecute(Sender: TObject);
Var A      : Integer;
    B      : Integer;
    HelpNr : Integer;
    Help1  : String;
    Stop   : Boolean;
begin
  BeregnKontiSaldi(True,True,StrToDate('01-01-1900'),StrToDate('01-01-2100'), PeriodeNrListe.Strings[ComboPeriode.ItemIndex]);

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
  // Lav ny Udskriv_Kontoplan tabel
  Try
    With ZQuery1.SQL do
      Begin
        Clear;
        Add('CREATE TABLE udskriv (');
        Add('  nr  INTEGER NOT NULL PRIMARY KEY,');
        Add('  afd INTEGER NOT NULL,');
        Add('  id  INTEGER,');
        Add('  brugerkonto INTEGER,');
        Add('  beskrivelse VARCHAR(40),');
        Add('  debetbogfoert FLOAT,');
        Add('  kreditbogfoert FLOAT,');
        Add('  startsaldo FLOAT,');
        Add('  debetkassekladde FLOAT,');
        Add('  kreditkassekladde FLOAT,');
        Add('  beregnetsaldo FLOAT,');
        Add('  refberegnetsaldo FLOAT,');
        Add('  sumfra VARCHAR(6),');
        Add('  sumtil VARCHAR(6),');
        Add('  kontotype INTEGER,');
        Add('  momskode VARCHAR(3),');
        Add('  genvej VARCHAR(2),');
        Add('  type INTEGER,');
        Add('  typeBesk VARCHAR(10),');
        Add('  datofra TIMESTAMP,');
        Add('  datotil TIMESTAMP,');
        Add('  datoreffra TIMESTAMP,');
        Add('  datoreftil TIMESTAMP,');
        Add('  periode VARCHAR(4),');
        Add('  beregnetsaldobudget FLOAT,');
        Add('  okonr INTEGER,');
        Add('  okobeskrivelse VARCHAR(40)');
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
  // Indsæt data i Udskriv kontoplan tabel
  ZQuery1.Close;
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from udskriv order by nr');
    End;
  ZQuery1.Open;
  A := 1;
  While A < StringGrid2.RowCount Do
    Begin
      Try
        // Find konto i grid og find dennes data
        Stop := False;
        B := 0;
        While (Not Stop) And (B < AlleData.Count) Do
          Begin
            If IntToStr(TDataKonto(AlleData.Items[B]^).Brugerkonto) =
              StringGrid2.Cells[Konto_Nr,A] Then // Check om konto i grid er den som skal bruges
              Begin
                Stop := True;
              End
            Else
              Begin
                Inc(B);
              End;
          End;
        ZQuery1.Append;
        ZQuery1.Edit;
        ZQuery1.FieldByName('Nr').AsInteger := A;
        ZQuery1.FieldByName('Afd').AsInteger := StrToInt(CurrentAfd);
        ZQuery1.FieldByName('id').AsInteger :=
          TDataKonto(AlleData.Items[B]^).KontoNr;
        ZQuery1.FieldByName('Brugerkonto').AsInteger :=
          TDataKonto(AlleData.Items[B]^).BrugerKonto;
        ZQuery1.FieldByName('Beskrivelse').AsString :=
          TDataKonto(AlleData.Items[B]^).Beskrivelse;
        ZQuery1.FieldByName('DebetBogfoert').AsCurrency :=
          TDataKonto(AlleData.Items[B]^).DebetBogfoert;
        ZQuery1.FieldByName('KreditBogfoert').AsCurrency :=
          TDataKonto(AlleData.Items[B]^).KreditBogfoert;
        ZQuery1.FieldByName('Debetkassekladde').AsCurrency :=
          TDataKonto(AlleData.Items[B]^).DebetKassekladde;
        ZQuery1.FieldByName('Kreditkassekladde').AsCurrency :=
          TDataKonto(AlleData.Items[B]^).Kreditkassekladde;
        ZQuery1.FieldByName('Startsaldo').AsCurrency :=
          TDataKonto(AlleData.Items[B]^).StartSaldoBilag + TDataKonto(AlleData.Items[B]^).StartSaldoKasse;
        ZQuery1.FieldByName('BeregnetSaldo').AsCurrency :=
          TDataKonto(AlleData.Items[B]^).BeregnetSaldo;
        ZQuery1.FieldByName('RefBeregnetSaldo').AsCurrency := 0;
          // TDataRefKonto(RefKontoListe.Items[B]^).RefBeregnetSaldo;
        ZQuery1.FieldByName('SumFra').AsString :=
          IntToStr(TDataKonto(AlleData.Items[B]^).Sumfra);
        ZQuery1.FieldByName('SumTil').AsString :=
          IntToStr(TDataKonto(AlleData.Items[B]^).SumTil);
        ZQuery1.FieldByName('Kontotype').AsString :=
          IntToStr(TDataKonto(AlleData.Items[B]^).Kontotype);
        ZQuery1.FieldByName('Momskode').AsString :=
          TDataKonto(AlleData.Items[B]^).Moms;
        ZQuery1.FieldByName('Genvej').AsString :=
          TDataKonto(AlleData.Items[B]^).Genvej;
        ZQuery1.FieldByName('DatoFra').AsDateTime := Now;
          // DateIntervalFra.Date;
        ZQuery1.FieldByName('DatoTil').AsDateTime := Now;
          // DateIntervalTil.Date;
        ZQuery1.FieldByName('DatoRefFra').AsDateTime := Now;
          // DateRefIntervalFra.Date;
        ZQuery1.FieldByName('DatoRefTil').AsDateTime := Now;
          // DateRefIntervalTil.Date;
        ZQuery1.FieldByName('Periode').AsString :=
          ComboPeriode.Text;
        (*ZQuery1.FieldByName('Interval').AsString :=
          ComboPeriodeInterval.Text;*)
        ZQuery1.FieldByName('BeregnetSaldoBudget').AsCurrency := 0;
          (*BeregnBudgetTal(ComboPeriode.Text, DateIntervalFra.Date,
            DateIntervalTil.Date, TDataKonto(AlleData.Items[B]^).KontoNr,
            TDataKonto(AlleData.Items[B]^).BrugerKonto,
            TDataKonto(AlleData.Items[B]^).KontoType);*)
        ZQuery1.FieldByName('OkoNr').AsString :=
          FormaalNrListe.Strings[ComboFormaal.ItemIndex];
        ZQuery1.FieldByName('OkoBeskrivelse').AsString :=
          ComboFormaal.Items[ComboFormaal.ItemIndex];
        // Hent oplysninger fra konto
        With ZQuery2.SQL do
          Begin
            Clear;
            Add('Select * from KONTOBES where (Afd = ' + CurrentAfd +
                 ') and (Brugerkonto = ' +
                 IntToStr(TDataKonto(AlleData.Items[B]^).BrugerKonto)+')');
          End;
        ZQuery2.Open;
        If ZQuery2.RecordCount = 0 Then
          Begin
            MessageDlg('Fejl kan ikke finde konto definition',mtError,[mbOK],0);
            Exit;
          end;
        ZQuery1.FieldByName('Type').AsString := ZQuery2.FieldByName('Type').AsString;
        Case ZQuery1.FieldByName('Type').AsInteger of
          0 : ZQuery1.FieldByName('TypeBesk').AsString := 'Drift';
          1 : ZQuery1.FieldByName('TypeBesk').AsString := 'Status';
          2 : ZQuery1.FieldByName('TypeBesk').AsString := 'Sum';
          3 : ZQuery1.FieldByName('TypeBesk').AsString := 'Tekst';
        Else
          ZQuery1.FieldByName('TypeBesk').AsString := 'Udefineret';
        End; // End Case
        ZQuery1.Post;
        ZQuery1.ApplyUpdates;
      Except
        ZQuery1.Cancel;
        MessageDlg('Udskriv kontoplan - Data kunne ikke indsættes; A= ' + IntToStr(A),mtError,[mbOk],0);
      End;
      Inc(A);
    End;
  // Udskriv_Kassekladde
  ZQuery1.First;
  SuperPrintForm := TSuperPrintForm.Create(Self);
  SuperPrintForm.TypeRapport := 2;
  SuperPrintForm.RapportTitel := 'Kontoplan...';
  SuperPrintForm.IndlaesFlueben;
  SuperPrintForm.IndlaesRapportCombo;
  SuperPrintForm.ShowModal;
  SuperPrintForm.Free;
end;

//**********************************************************
// Postering Udskriv
//**********************************************************
procedure TKasseKladdeForm.Udskriv_PosteringExecute(Sender: TObject);
Var A : Integer;
begin
  // Undersøg om der udvalgt dele af grid
  If(StringGridPost.Selection.Bottom - StringGridPost.Selection.Top) <= 0 Then
    Begin
      If MessageDlg('Skal der kun udskrives en linie - husk shift medens pil ned udvælger!',
        mtInformation,[mbYes,mbNo],0) = mrNo Then
        Begin
          Exit;
        End;
    End;
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
  // Lav ny Udskriv_Postering tabel
  Try
    With ZQuery1.SQL do
      Begin
        Clear;
        Add('CREATE TABLE udskriv (');
        Add('  nr  INTEGER NOT NULL PRIMARY KEY,');
        Add('  afd INTEGER NOT NULL,');
        Add('  id  INTEGER,');
        Add('  bilagsnr INTEGER,');
        Add('  dato TIMESTAMP,');
        Add('  type INTEGER,');
        Add('  konto INTEGER,');
        Add('  kontonavn VARCHAR(40),');
        Add('  tekst VARCHAR(40),');
        Add('  moms VARCHAR(4),');
        Add('  dk VARCHAR(1),');
        Add('  beloeb FLOAT,');
        Add('  bogfoertdato TIMESTAMP,');
        Add('  periode INTEGER,');
        Add('  formaal VARCHAR(40),');
        Add('  sumalle FLOAT');
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
  // Indsæt data i Udskriv kontoplan tabel
  ZQuery1.Close;
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from udskriv order by nr');
    End;
  ZQuery1.Open;
  A := 1;
  While A < StringGridPost.RowCount Do
    Begin
      ZQuery1.Append;
      ZQuery1.Edit;
      ZQuery1.FieldByName('Nr').AsInteger  := A;
      ZQuery1.FieldByName('Afd').AsInteger := StrToInt(CurrentAfd);
      ZQuery1.FieldByName('id').AsString   := StringGridPost.Cells[PostId,A];
      ZQuery1.FieldByName('Dato').AsString := StringGridPost.Cells[PostDato,A];
      ZQuery1.FieldByName('BilagsNr').AsString   := StringGridPost.Cells[PostNr,A];
      ZQuery1.FieldByName('Type').AsString       := StringGridPost.Cells[PostArt,A];
      ZQuery1.FieldByName('Konto').AsString      := StringGridPost.Cells[PostKonto,A];
      ZQuery1.FieldByName('Kontonavn').AsString  := FindKontoBeskrivelse(StringGridPost.Cells[PostKonto,A]);
      ZQuery1.FieldByName('Tekst').AsString      := StringGridPost.Cells[PostTekst,A];
      ZQuery1.FieldByName('Moms').AsString       := StringGridPost.Cells[PostMoms,A];
      ZQuery1.FieldByName('DK').AsString         := StringGridPost.Cells[PostDK,A];
      ZQuery1.FieldByName('Beloeb').AsString     := FjernPunktum(StringGridPost.Cells[PostBeloeb,A]);
      ZQuery1.FieldByName('Formaal').AsString    := StringGridPost.Cells[PostFormaal,A];
      ZQuery1.FieldByName('BogfoertDato').AsString := StringGridPost.Cells[PostBogfoert,A];
      ZQuery1.Post;
      Inc(A);
    end;
  // Udskriv_Kassekladde
  ZQuery1.First;
  SuperPrintForm := TSuperPrintForm.Create(Self);
  SuperPrintForm.TypeRapport := 6;
  SuperPrintForm.RapportTitel := 'Posteringsoversigt...';
  SuperPrintForm.IndlaesFlueben;
  SuperPrintForm.IndlaesRapportCombo;
  SuperPrintForm.ShowModal;
  SuperPrintForm.Free;
end;

//**********************************************************
// Vis Afstemningskonti
//**********************************************************
procedure TKasseKladdeForm.VisAfstemningsKontiExecute(Sender: TObject);
begin
  If Afstemningspanel.Visible Then
    Begin // Lukker vindue
      Afstemningspanel.Visible := False;
      VisAfstemningskonti.Checked := False;
    End
  Else
    Begin
      Afstemningspanel.Visible := True;
      VisAfstemningskonti.Checked := True;
      BeregnAfstemningskonti;
    End;
end;

//**********************************************************
// Indstil Kontoplan grid
//**********************************************************
Procedure TKasseKladdeForm.IndstilKontoplan;
Begin
  Indstil_StringGrid_NonEdit(StringGrid2);
  StringGrid2.Columns.Clear;

  StringGrid2.Columns.Add;
  StringGrid2.Columns.Add;
  StringGrid2.Columns.Add;
  StringGrid2.Columns.Add;
  StringGrid2.Columns.Add;
  StringGrid2.Columns.Add;
  StringGrid2.Columns.Add;
  StringGrid2.Columns.Add;
  StringGrid2.Columns.Add;
  StringGrid2.Columns.Add;

  //
  StringGrid2.Columns[Konto_Nr].Title.Caption        := 'KontoNr';
  StringGrid2.Columns[Konto_Nr].Width                := 57;
  StringGrid2.Columns[Konto_Nr].Alignment            := taRightJustify;

  StringGrid2.Columns[Konto_Navn].Title.Caption      := 'Kontonavn';
  StringGrid2.Columns[Konto_Navn].Width              := 175;
  StringGrid2.Columns[Konto_Navn].Alignment          := taLeftJustify;

  StringGrid2.Columns[Konto_Type].Title.Caption      := 'Type';
  StringGrid2.Columns[Konto_Type].Width              := 46;
  StringGrid2.Columns[Konto_Type].Alignment          := taLeftJustify;

  StringGrid2.Columns[Konto_Moms].Title.Caption      := 'Moms';
  StringGrid2.Columns[Konto_Moms].Width              := 57;
  StringGrid2.Columns[Konto_Moms].Alignment          := taLeftJustify;

  StringGrid2.Columns[Konto_Fra].Title.Caption       := 'Fra';
  StringGrid2.Columns[Konto_Fra].Width               := 57;
  StringGrid2.Columns[Konto_Fra].Alignment           := taRightJustify;

  StringGrid2.Columns[Konto_Til].Title.Caption       := 'Til';
  StringGrid2.Columns[Konto_Til].Width               := 57;
  StringGrid2.Columns[Konto_Til].Alignment           := taRightJustify;

  StringGrid2.Columns[Konto_Genvej].Title.Caption    := 'Genvej';
  StringGrid2.Columns[Konto_Genvej].Width            := 43;
  StringGrid2.Columns[Konto_Genvej].Alignment        := taLeftJustify;

  StringGrid2.Columns[Konto_Saldo].Title.Caption     := 'Saldo';
  StringGrid2.Columns[Konto_Saldo].Width             := 80;
  StringGrid2.Columns[Konto_Saldo].Alignment         := taRightJustify;

  StringGrid2.Columns[Konto_Ref].Title.Caption       := 'Ref';
  StringGrid2.Columns[Konto_Ref].Width               := 80;
  StringGrid2.Columns[Konto_Ref].Alignment           := taRightJustify;

  StringGrid2.Columns[Konto_Id].Title.Caption        := 'id';
  StringGrid2.Columns[Konto_Id].Width                := 20;
  StringGrid2.Columns[Konto_Id].Alignment            := taRightJustify;
  StringGrid2.Columns[Konto_Id].Visible              := False;

  StringGrid2.Options  := [goTabs,goRowSelect,goFixedVertline,goFixedHorzLine];
//  StringGrid
  //StringGrid2.FocusRectVisible          :=False;
end;

//**********************************************************
// Indlaes Kontoplan
//**********************************************************
procedure TKasseKladdeForm.IndlaesKontoplan;
Var A : Integer;
    B : LongInt;
    Stop : Boolean;
    HelpRefKonto  : PDataRefKonto;

begin
(*  // Beregn ref saldi
  If RefCombo.ItemIndex = -1 Then RefCombo.ItemIndex := 0;
  SelectedPeriode := RefCombo.Items[RefCombo.ItemIndex];
  BeregnKontiSaldi(False,True,DateRefIntervalFra.DateTime,DateRefIntervalTil.DateTime); // Ikke kassekladde
//  BeregnKontiSaldi(False,True,StrToDate('01-01-1900'),StrToDate('01-01-2100')); // Ikke kassekladde
  RefKontoListe.Clear;
  For A := 0 To (AlleData.Count - 1) Do
    Begin
      New(HelpRefKonto);
      HelpRefKonto.RefBeregnetSaldo :=
        TDataKonto(AlleData.Items[A]^).BeregnetSaldo;
      RefKontoListe.Add(HelpRefKonto);
    End;
  // Periode sættes tilbage igen
  SelectedPeriode := ComboPeriode.Items[ComboPeriode.ItemIndex];*)
  // Beregn konti
//  BeregnKontiSaldi(False,True,DateIntervalFra.DateTime,DateIntervalTil.DateTime); // Ikke kassekladde
  BeregnKontiSaldi(False,True,StrToDate('01-01-1900'),StrToDate('01-01-2100'),
    PeriodeNrListe.Strings[ComboPeriode.ItemIndex]); // Ikke kassekladde

  // Indlæs data til grid
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from KontoBes where Afd = ' + CurrentAfd);
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount = 0 Then
    Begin
      StringGrid2.RowCount  := 1;
      MessageDlg('Ingen konti defineret!',mtInformation,[mbOk],0);
      Exit;
    end;
  StringGrid2.RowCount := 1;
  A := 0;
  StringGrid2.BeginUpdate;
  ZQuery1.First;
  While not ZQuery1.EOF Do
    Begin
      Try
        Inc(A);
        StringGrid2.RowCount := A + 1;
        If ZQuery1.FieldByName('Type').AsInteger <> 3 Then // ikke Tekst
          Begin
            With StringGrid2 do
              begin
                Cells[Konto_Id,A]     := ZQuery1.FieldByName('Id').AsString;
                Cells[Konto_Nr,A]     := ZQuery1.FieldByName('BrugerKonto').AsString;
                Cells[Konto_Navn,A]   := ZQuery1.FieldByName('Beskrivelse').AsString;
                Case ZQuery1.FieldByName('Type').AsInteger of
                  0 : Cells[Konto_Type,A] := 'Drift';
                  1 : Cells[Konto_Type,A] := 'Status';
                  2 : Cells[Konto_Type,A] := 'Sum';
                  3 : Cells[Konto_Type,A] := 'Tekst';
                Else
                  Cells[Konto_Type,A] := 'Udefineret';
                End; // End Case
                Cells[Konto_Moms,A] :=  MomsKodeListe.Strings[MomsKodeNrListe.IndexOf(ZQuery1.FieldByName('MomsKode').AsString)];
                // Ved sum konto skal fra og til opdateres
                If ZQuery1.FieldByName('Type').AsInteger = 2 Then
                  Begin //Sum
                    Cells[Konto_Fra,A] := ZQuery1.FieldByName('Fra').AsString;
                    Cells[Konto_Til,A] := ZQuery1.FieldByName('Til').AsString;
                  End
                Else
                  Begin
                    Cells[Konto_Fra,A] := '';
                    Cells[Konto_Til,A] := '';
                  End;
                Cells[Konto_Genvej,A] := ZQuery1.FieldByName('KGB').AsString;
                // Saldo
                Stop := False;
                B := 0;
                While (Not Stop) And (B < AlleData.Count) Do
                  Begin
                    If TDataKOnto(AlleData.Items[B]^).KontoNr =
                     ZQuery1.FieldByName('Id').AsInteger Then
                      Begin
                        Stop := True;
                        Cells[Konto_Saldo,A] := Format('%n',[
                              TDataKonto(AlleData.Items[B]^).BeregnetSaldo]);
                      End;
                    Inc(B);
                  End;
                // Ref Saldo
(*                Stop := False;
                B := 0;
                While (Not Stop) And (B < AlleData.Count) Do
                  Begin
                    If TDataKOnto(AlleData.Items[B]^).KontoNr =
                     ZQuery1.FieldByName('Id').AsInteger Then
                      Begin
                        Stop := True;
                        Cells[Konto_Ref,A] := Format('%n',[
                              TDataRefKonto(RefKontoListe.Items[B]^).RefBeregnetSaldo]);
                      End;
                    Inc(B);
                  End; *)
              end;
          End
        Else
          Begin // Tekst
            With StringGrid2 do
              begin
                Cells[Konto_Id,A] := ZQuery1.FieldByName('Id').AsString;
                If ZQuery1.FieldByName('VisIkkeTekst').AsBoolean Then
                  Begin
                    Cells[Konto_Nr,A] := '';
                    Cells[Konto_Navn,A] := '';
                    Cells[Konto_Type,A] := '';
                  End
                Else
                  Begin
                    Cells[Konto_Nr,A] := ZQuery1.FieldByName('BrugerKonto').AsString;
                    Cells[Konto_Navn,A] := ZQuery1.FieldByName('Beskrivelse').AsString;
                    Cells[Konto_Type,A] := 'Tekst';
                  End;
                Cells[Konto_Moms,A]     := ''; // MomsKode
                Cells[Konto_Fra,A]      := '';
                Cells[Konto_Til,A]      := '';
                Cells[Konto_Genvej,A]   := ''; // KGB
                Cells[Konto_Saldo,A]    := '';
              end;
          End;
      Except
        MessageDlg('Kunne ikke indsættes i grid',mtError,[mbOK],0);
        Exit;
      End;
      ZQuery1.Next;
    End;
  StringGrid2.EndUpdate;
end;

//**********************************************************
// Indstil posteringsoversigt
//**********************************************************
Procedure TKasseKladdeForm.IndstilPosteringsOversigt;
Begin
  Indstil_StringGrid_NonEdit(StringGridPost);
  StringGridPost.Columns.Clear;

  StringGridPost.Columns.Add;
  StringGridPost.Columns.Add;
  StringGridPost.Columns.Add;
  StringGridPost.Columns.Add;
  StringGridPost.Columns.Add;
  StringGridPost.Columns.Add;
  StringGridPost.Columns.Add;
  StringGridPost.Columns.Add;
  StringGridPost.Columns.Add;
  StringGridPost.Columns.Add;
  StringGridPost.Columns.Add;

  //
  StringGridPost.Columns[PostDato].Title.Caption        := 'Dato';
  StringGridPost.Columns[PostDato].Width                := 70;
  StringGridPost.Columns[PostDato].Alignment            := taLeftJustify;

  StringGridPost.Columns[PostNr].Title.Caption          := 'Bilagsnr';
  StringGridPost.Columns[PostNr].Width                  := 55;
  StringGridPost.Columns[PostNr].Alignment              := taRightJustify;

  StringGridPost.Columns[PostArt].Title.Caption         := 'Art';
  StringGridPost.Columns[PostArt].Width                 := 46;
  StringGridPost.Columns[PostArt].Alignment             := taLeftJustify;

  StringGridPost.Columns[PostKonto].Title.Caption       := 'Konto';
  StringGridPost.Columns[PostKonto].Width               := 100;
  StringGridPost.Columns[PostKonto].Alignment           := taLeftJustify;

  StringGridPost.Columns[PostTekst].Title.Caption       := 'Tekst';
  StringGridPost.Columns[PostTekst].Width               := 100;
  StringGridPost.Columns[PostTekst].Alignment           := taLeftJustify;

  StringGridPost.Columns[PostMoms].Title.Caption        := 'Moms';
  StringGridPost.Columns[PostMoms].Width                := 57;
  StringGridPost.Columns[PostMoms].Alignment            := taLeftJustify;

  StringGridPost.Columns[PostDK].Title.Caption          := 'D/K';
  StringGridPost.Columns[PostDK].Width                  := 43;
  StringGridPost.Columns[PostDK].Alignment              := taLeftJustify;

  StringGridPost.Columns[PostBeloeb].Title.Caption      := 'Beløb';
  StringGridPost.Columns[PostBeloeb].Width              := 80;
  StringGridPost.Columns[PostBeloeb].Alignment          := taRightJustify;

  StringGridPost.Columns[PostFormaal].Title.Caption     := 'Formål';
  StringGridPost.Columns[PostFormaal].Width             := 80;
  StringGridPost.Columns[PostFormaal].Alignment         := taLeftJustify;

  StringGridPost.Columns[PostId].Title.Caption          := 'id';
  StringGridPost.Columns[PostId].Width                  := 40;
  StringGridPost.Columns[PostId].Alignment              := taRightJustify;
  StringGridPost.Columns[PostId].Visible                := True;

  StringGridPost.Columns[PostBogfoert].Title.Caption    := 'Bogført d';
  StringGridPost.Columns[PostBogfoert].Width            := 20;
  StringGridPost.Columns[PostBogfoert].Alignment        := taRightJustify;
  StringGridPost.Columns[PostBogfoert].Visible          := False;

  StringGridPost.Options  := [goTabs,goRowSelect,goRangeSelect,goFixedVertline,
     goFixedHorzLine];
//  StringGrid
  //StringGridPost.FocusRectVisible          :=False;
end;

//**********************************************************
//  Postering - IndlaesIGrid
//**********************************************************
procedure TKasseKladdeForm.IndlaesPostering;
Var A      : Integer;
    Naeste : Boolean;
begin
  // Indlæs data til grid
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from bilag where Afd = ' + CurrentAfd +
          ' and periode = ' + PeriodeNrListe.Strings[ComboPeriode.ItemIndex]);
    End;
  StringGridPost.RowCount := 1;
  ZQuery1.Open;
  If ZQuery1.RecordCount = 0 Then
    Begin
      MessageDlg('Ingen bilag!',mtInformation,[mbOk],0);
      Exit;
    end;
  ZQuery1.First;
  A := 0;
  ZQuery1.First;
  StringGridPost.BeginUpdate;
  A := 0;
  While Not ZQuery1.Eof Do
    Begin
      Naeste := False;
      // Først Formål
      If Not Naeste And (ComboFormaAl.ItemIndex <> 0) Then
        Begin
          Naeste := (ZQuery1.FieldByName('OkoNr').AsString <>
           FormaalNrListe.Strings[ComboFormaal.ItemIndex]);
        End;
      If Not Naeste Then
        Begin
          Inc(A);
          StringGridPost.RowCount := StringGridPost.RowCount + 1;
          With StringGridPost do
            Begin
              Cells[PostDato,A]   := DateToStr(JulianDateToDateTime(ZQuery1.FieldByName('Dato').AsFloat));
              Cells[PostNr,A]     := ZQuery1.FieldByName('BilagsNr').AsString;
              Cells[PostArt,A]    := ZQuery1.FieldByName('Type').AsString;
              Cells[PostKonto,A]  := FindBrugerFraKonto(ZQuery1.FieldByName('Konto').AsString);
              Cells[PostTekst,A]  := ZQuery1.FieldByName('Tekst').AsString;
              Cells[PostMoms,A]   := MomsKodeListe.Strings[
                MomskodeNrListe.IndexOf(ZQuery1.FieldByName('Moms').AsString)];
              Cells[PostDK,A]     := ZQuery1.FieldByName('D_K').AsString;
              Cells[PostBeloeb,A] :=
                FloatToStrF(ZQuery1.FieldByName('Beloeb').AsCurrency,ffNumber,18,2);
              Cells[PostFormaal,A]:= ComboFormaal.Items[
                FormaalNrListe.IndexOf(ZQuery1.FieldByName('OkoNr').AsString)];
              Cells[PostId,A]     := ZQuery1.FieldByName('Nr').AsString;
              Cells[PostBogfoert,A] := DateToStr(JulianDateToDateTime(ZQuery1.FieldByName('BogfoertDato').AsFloat));
            End;
        End;
      ZQuery1.Next;
    End;
  StringGridPost.EndUpdate;
end;


end.

