//***************************************************************************//
//  Holbæk                                                                   //
//  Copyright by Claus Moeller 2013-2017                                     //
//  Find medlemsoplysninger                                                  //
//  Version                                                                  //
//  20.01.17                                                                 //
//***************************************************************************//
unit findmed;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  Menus, ActnList, ExtCtrls, StdCtrls, Grids, Buttons, clmCombobox,
  JLabeledFloatEdit, JLabeledDateEdit, JLabeledIntegerEdit, ZDataset, DateUtils;

type

  { TFormFindMedlemmer }

  PResultListType = ^TResultListType;
  TResultListType = Record
    MedlemsNr : LongInt;
    Gruppe    : TStringList;
  End;

  TFormFindMedlemmer = class(TForm)
    AktivitetSpeedNone: TAction;
    AktivitetSpeedAll: TAction;
    ActionList1: TActionList;
    CheckAktivitet: TCheckBox;
    CheckAkitivitetsgruppe: TCheckBox;
    CheckMarks: TCheckBox;
    CheckKategori: TCheckBox;
    CheckIngenAktivitet: TCheckBox;
    CheckAlder: TCheckBox;
    CheckNonMarks: TCheckBox;
    CheckPostnr: TCheckBox;
    CheckUdmeldt: TCheckBox;
    CheckMedSiden: TCheckBox;
    CheckAlderFraTil: TCheckBox;
    CheckIkkeUdmeldt: TCheckBox;
    ComboKategori: TclmCombobox;
    ComboLand: TclmCombobox;
    DateIndmeldtEfter: TJLabeledDateEdit;
    DateUdmeldtEfter: TJLabeledDateEdit;
    DateIndmeldtFoer: TJLabeledDateEdit;
    DateUdmeldtFoer: TJLabeledDateEdit;
    DatoTil: TJLabeledDateEdit;
    FoedFraCombo: TComboBox;
    FoedTilCombo: TComboBox;
    DateAlderTil: TJLabeledDateEdit;
    GridAktGruppe: TStringGrid;
    GroupAlder: TGroupBox;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    Help: TAction;
    ImageList1: TImageList;
    ImageList2: TImageList;
    DateAlderFra: TJLabeledDateEdit;
    DatoFra: TJLabeledDateEdit;
    MainMenu1: TMainMenu;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    PostOmraade: TJLabeledIntegerEdit;
    Label1: TLabel;
    Label2: TLabel;
    MaskEditDato: TJLabeledDateEdit;
    MaskAlderFra: TJLabeledFloatEdit;
    Luk: TAction;
    MaskAlderTil: TJLabeledFloatEdit;
    MenuItem1: TMenuItem;
    PostLig: TRadioButton;
    PostForskellig: TRadioButton;
    MaerkeIndstillingGroup: TRadioGroup;
    Soeg: TAction;
    PageColor3: TShape;
    PageControl1: TPageControl;
    PopupMenu1: TPopupMenu;
    PageColor1: TShape;
    PageColor2: TShape;
    RadioGroupKoen: TRadioGroup;
    RadioGroupAktive: TRadioGroup;
    RadioHaendelse: TRadioGroup;
    SoegFlere: TAction;
    GridMarks: TStringGrid;
    VaelgAktivitetAlle: TSpeedButton;
    VaelgIngenAktiviteter: TSpeedButton;
    StatusBar1: TStatusBar;
    GridAktiviteter: TStringGrid;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ZQuery1: TZQuery;
    ZQueryMedlem: TZQuery;
    procedure AktivitetSpeedAllExecute(Sender: TObject);
    procedure AktivitetSpeedNoneExecute(Sender: TObject);
    procedure CheckAktivitetClick(Sender: TObject);
    procedure CheckAlderClick(Sender: TObject);
    procedure CheckAlderFraTilClick(Sender: TObject);
    procedure CheckIkkeUdmeldtClick(Sender: TObject);
    procedure CheckIngenAktivitetClick(Sender: TObject);
    procedure CheckKategoriClick(Sender: TObject);
    procedure CheckMarksClick(Sender: TObject);
    procedure CheckMedSidenClick(Sender: TObject);
    procedure CheckPostnrClick(Sender: TObject);
    procedure CheckUdmeldtClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure GridMarksCheckboxToggled(sender: TObject; aCol, aRow: Integer;
      aState: TCheckboxState);
    procedure GridMarksSelectEditor(Sender: TObject; aCol, aRow: Integer;
      var Editor: TWinControl);
    procedure HelpExecute(Sender: TObject);
    procedure LukExecute(Sender: TObject);
    procedure SoegExecute(Sender: TObject);
    procedure VaelgAktivitetAlleClick(Sender: TObject);
    procedure VaelgIngenAktiviteterClick(Sender: TObject);
  private
    { private declarations }
    NonMarksListe  : TStringList;
    procedure IndlaesLand;
    procedure LavListeMedNonMarks;
    Function  AarMellem(Ny,Dengang : TDatetime) : Word;
    procedure IndstilAktiviteter;
    procedure IndlaesAktiviteter;
    procedure IndstilKategori;
    procedure IndlaesKategori;
    procedure IndstilMarks;
    procedure IndlaesMarks;
    procedure ForetagSoegning(Clear : Boolean);
  public
    { public declarations }
    ResultListe        : TList;
  end;

var
  FormFindMedlemmer: TFormFindMedlemmer;

implementation

{$R *.lfm}

Uses HolbaekConst, HolbaekMain, MainData, ShowFind;

{ TFormFindMedlemmer }

Const AktCheck       : Integer = 0;
      AktNavn        : Integer = 1;
      AktNr          : Integer = 2;

      KatNavn        : Integer = 0;
      KatPris        : Integer = 1;
      KatNr          : Integer = 2;

      MarkCheck      : Integer = 0;
      MarkNonCheck   : Integer = 1;
      MarkBesk       : Integer = 2;
      MarkAuto       : Integer = 3;

//**********************************************************
// Create
//**********************************************************
procedure TFormFindMedlemmer.FormCreate(Sender: TObject);
begin
  Top  := 10;
  Left := 30;
  ShowHint               := True;
  // Farver
  Color                  := H_Window_Baggrund;
  ToolBar1.Color         := H_Menu_knapper_Farve;
  StatusBar1.Color       := H_Menu_knapper_Farve;

  PageColor1.Brush.Color := H_Page_Color;
  PageColor1.Align       := alClient;
  PageColor2.Brush.Color := H_Page_Color;
  PageColor2.Align       := alClient;
  PageColor3.Brush.Color := H_Page_Color;
  PageColor3.Align       := alClient;

  GroupAlder.Color       := H_Group_Color;

  MaskAlderFra.Color     := H_Edit_Baggrund;
  MaskAlderTil.Color     := H_Edit_Baggrund;
  MaskEditDato.Color     := H_Edit_Baggrund;
  DateAlderFra.Color     := H_Edit_Baggrund;
  DateAlderTil.Color     := H_Edit_Baggrund;
  FoedFraCombo.Color     := H_Combo_Color;
  FoedTilCombo.Color     := H_Combo_Color;
  DateIndmeldtEfter.Color:= H_Edit_Baggrund;
  DateIndmeldtFoer.Color := H_Edit_Baggrund;
  DateUdmeldtEfter.Color := H_Edit_Baggrund;
  DateUdmeldtFoer.Color  := H_Edit_Baggrund;
  ComboLand.Color        := H_Combo_Color;
  PostOmraade.Color      := H_Edit_Baggrund;

  ComboKategori.Color    := H_Combo_Color;

  DatoFra.Color          := H_Edit_Baggrund;
  DatoTil.Color          := H_Edit_Baggrund;

  // Database
  ZQueryMedlem.Connection := MainDataModule.ZConnection1;
  ZQuery1.Connection      := MainDataModule.ZConnection1;

  //Lists
  NonMarksListe      := TStringList.Create;
  ResultListe        := TList.Create;

  // Indstil

  MaskEditDato.Value := Date;
  IndstilAktiviteter;
  IndstilKategori;
  DatoFra.Value := StrToDate('01-01-1900');
  DatoTil.Value := StrToDate('01-01-2100');
  IndstilMarks;

  // Indlæs
  IndlaesLand; // Combo under søgning
  IndlaesAktiviteter;
  IndlaesKategori;
  LavListeMedNonMarks;
  IndlaesMarks;
end;

//**********************************************************
// Destroy
//**********************************************************
procedure TFormFindMedlemmer.FormDestroy(Sender: TObject);
Var HelpData : PShowFindResultDefListType;
    A : Integer;
begin
(*  For A := ResultListe.Count-1 downto 0 Do
    Begin
      HelpData := ResultListe[A];
      Dispose(HelpData);
    end;*)
  ResultListe.Free;
  NonMarksListe.Free;
end;

//**********************************************************
// GridMarks check
//**********************************************************
procedure TFormFindMedlemmer.GridMarksCheckboxToggled(sender: TObject; aCol,
  aRow: Integer; aState: TCheckboxState);
begin
  // Kun en af de to kolonner kan være checked
  If (aCol = MarkCheck) Then
    Begin
      GridMarks.Cells[MarkNonCheck,aRow] := '0';
    end
  Else If aCol = MarkNonCheck Then
    Begin
      GridMarks.Cells[MarkCheck,aRow] := '0';
    end;
end;

//**********************************************************
// Grid Marks select editor
//**********************************************************
procedure TFormFindMedlemmer.GridMarksSelectEditor(Sender: TObject; aCol,
  aRow: Integer; var Editor: TWinControl);
begin
  If aCol = MarkCheck Then
    Begin
      Editor := GridMarks.EditorByStyle(cbsCheckboxColumn);
    end
  Else If aCol = MarkNonCheck Then
    Begin
      Editor := GridMarks.EditorByStyle(cbsCheckboxColumn);
    end
  Else
    Begin
      Editor := GridMarks.EditorByStyle(cbsNone);
    end;

end;

//**********************************************************
// Hjælp
//**********************************************************
procedure TFormFindMedlemmer.HelpExecute(Sender: TObject);
begin
  ShowMessage('Help');
end;

//**********************************************************
// Alder check
//**********************************************************
procedure TFormFindMedlemmer.CheckAlderClick(Sender: TObject);
begin
  If CheckAlder.Checked Then
    Begin
      MaskAlderFra.Visible := True;
      MaskAlderTil.Visible := True;
      MaskEditDato.Visible := True;
//      AdvStringMark.Visible  := True;
      CheckAlderFratil.Checked := False;
      CheckAlderFraTilClick(Sender);
    End
  Else
    Begin
      MaskAlderFra.Visible := False;
      MaskAlderTil.Visible := False;
      MaskEditDato.Visible := False;
//      AdvStringMark.Visible  := False;
    End;
end;

//**********************************************************
// Aktiviteter Vælg Alle
//**********************************************************
procedure TFormFindMedlemmer.AktivitetSpeedAllExecute(Sender: TObject);
Var A : Integer;
begin
  A := 1;
  While A < GridAktiviteter.RowCount Do
    Begin
      GridAktiviteter.Cells[AktCheck,A] := '1';
      Inc(A);
    end;
end;

//**********************************************************
// Aktiviteter Vælg ingen
//**********************************************************
procedure TFormFindMedlemmer.AktivitetSpeedNoneExecute(Sender: TObject);
Var A : Integer;
begin
  A := 1;
  While A < GridAktiviteter.RowCount Do
    Begin
      GridAktiviteter.Cells[AktCheck,A] := '0';
      Inc(A);
    end;
end;

//**********************************************************
// Ingen Aktivitet Click
//**********************************************************
procedure TFormFindMedlemmer.CheckIngenAktivitetClick(Sender: TObject);
begin
  If CheckIngenAktivitet.Checked Then
    Begin
      CheckAktivitet.Checked := False;
      CheckAktivitetClick(Sender);
    End
  Else
    Begin
    End;
end;

//**********************************************************
// Check Kategori
//**********************************************************
procedure TFormFindMedlemmer.CheckKategoriClick(Sender: TObject);
begin
  If CheckKategori.Checked Then
    Begin
      ComboKategori.Visible := True;
      IndlaesKategori;
    End
  Else
    Begin
      ComboKategori.Visible := False;
    End;
end;

//**********************************************************
// Check Marks
//**********************************************************
procedure TFormFindMedlemmer.CheckMarksClick(Sender: TObject);
begin
  If CheckMarks.Checked Then
    Begin
      Label1.Visible            := True;
      Label2.Visible            := True;
      DatoFra.Visible           := True;
      DatoTil.Visible           := True;
      DatoFra.Visible           := True;
      GridMarks.Visible         := True;
      MaerkeIndstillingGroup.Visible := True;
      IndlaesMarks;
      If GridMarks.RowCount < 2 Then
        Begin
          MessageDlg('Der er ikke defineret et mærke',mtInformation,[mbOk],0);
          CheckMarks.Checked := False;
          CheckMarksClick(Sender);
        End;
      CheckNonMarks.Checked     := False;
    End
  Else
    Begin
      Label1.Visible            := False;
      Label2.Visible            := False;
      DatoFra.Visible           := False;
      DatoTil.Visible           := False;
      DatoFra.Visible           := False;
      GridMarks.Visible         := False;
      MaerkeIndstillingGroup.Visible := False;
    End;
end;

//**********************************************************
// Check Aktiviteter
//**********************************************************
procedure TFormFindMedlemmer.CheckAktivitetClick(Sender: TObject);
begin
  If CheckAktivitet.Checked Then
    Begin
      GridAktiviteter.Visible := True;
      IndlaesAktiviteter;
      CheckAkitivitetsgruppe.Visible := True;
      CheckIngenAktivitet.Checked    := False;
      VaelgAktivitetAlle.Visible     := True;
      VaelgIngenAktiviteter.Visible  := True;
    End
  Else
    Begin
      GridAktiviteter.Visible := False;
      CheckAkitivitetsgruppe.Visible := False;
      GridAktGruppe.Visible := False;
      VaelgAktivitetAlle.Visible     := False;
      VaelgIngenAktiviteter.Visible  := False;
    End;
end;


//**********************************************************************
// Vælg ingen aktiviteter
//**********************************************************************
procedure TFormFindMedlemmer.VaelgIngenAktiviteterClick(Sender: TObject);
Var A : Integer;
begin
  For A := 1 To GridAktiviteter.RowCount-1 Do
    Begin
      GridAktiviteter.Cells[AktCheck,A] := '0';
    End;
end;


//**********************************************************
// Check FraTil
//**********************************************************
procedure TFormFindMedlemmer.CheckAlderFraTilClick(Sender: TObject);
begin
  If CheckAlderFraTil.Checked Then
    Begin
      DateAlderFra.Visible := True;
      DateAlderTil.Visible := True;
      CheckAlder.Checked   := False;
      CheckAlderClick(Sender);
    End
  Else
    Begin
      DateAlderFra.Visible := False;
      DateAlderTil.Visible := False;
    End;
end;

//**********************************************************
// Check Ikke udmeldt
//**********************************************************
procedure TFormFindMedlemmer.CheckIkkeUdmeldtClick(Sender: TObject);
begin
  If CheckIkkeUdmeldt.Checked Then
    Begin
      CheckUdmeldt.Checked := False;
      CheckUdmeldtClick(Sender);
    End;
end;


//**********************************************************
// Check Medlem siden
//**********************************************************
procedure TFormFindMedlemmer.CheckMedSidenClick(Sender: TObject);
begin
  If CheckMedSiden.Checked Then
    Begin
      DateIndmeldtEfter.Visible := True;
      DateIndmeldtFoer.Visible  := True;
    End
  Else
    Begin
      DateIndmeldtEfter.Visible := False;
      DateIndmeldtFoer.Visible  := False;
    End;
end;

//**********************************************************
// Check post
//**********************************************************
procedure TFormFindMedlemmer.CheckPostnrClick(Sender: TObject);
begin
  If CheckPostNr.Checked Then
    Begin
      ComboLand.Visible      := True;
      PostLig.Visible        := True;
      PostOmraade.Visible    := True;
      PostForskellig.Visible := True;
    End
  Else
    Begin
      ComboLand.Visible      := False;
      PostLig.Visible        := False;
      PostOmraade.Visible    := False;
      PostForskellig.Visible := False;
    End;
end;

//**********************************************************
// Check udmeldt
//**********************************************************
procedure TFormFindMedlemmer.CheckUdmeldtClick(Sender: TObject);
begin
  If CheckUdmeldt.Checked Then
    Begin
      DateUdmeldtEfter.Visible := True;
      DateUdmeldtFoer.Visible  := True;
      CheckIkkeUdmeldt.Checked := False;
    End
  Else
    Begin
      DateUdmeldtEfter.Visible := False;
      DateUdmeldtFoer.Visible  := False;
    End;
end;

//**********************************************************
// Indlæs Land
//**********************************************************
procedure TFormFindMedlemmer.IndlaesLand;
Var A : Integer;
begin
  // Find lande
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from land');
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount = 0 Then
    Begin
      MessageDlg('Ingen lande er defineret!',mtInformation,[mbOk],0);
      Exit;
    end;
  // Combo gøres klar
  A := 0;
  ComboLand.Clear;
  ComboLand.Columns.add;
  ComboLand.Columns.add;
  ComboLand.Columns.Items[0].Width:= ComboLand.Width;
  ComboLand.Columns.Items[0].Color:=$00A6FFFF;
  ComboLand.Columns.Items[1].Visible:= False;
  ZQuery1.First;
  While not ZQuery1.Eof Do
    Begin
      ComboLand.AddRow;
      ComboLand.Cells[0,A] := ZQuery1.FieldByName('Land').AsString;
      ComboLand.Cells[1,A] := ZQuery1.FieldByName('LandKode').AsString;
      Inc(A);
      ZQuery1.Next;
    End;
  // Vælg default
  ComboLand.ItemIndex := 0;
end;

//**********************************************************************
// Indstil Kategori
//**********************************************************************
procedure TFormFindMedlemmer.IndstilKategori;
Begin
  ComboKategori.Columns.Clear;
  ComboKategori.Columns.Add;
  ComboKategori.Columns.Add;
  ComboKategori.Columns.Add;

  ComboKategori.Columns.Items[KatNavn].Width := 150;
  ComboKategori.Columns.Items[KatNavn].Alignment := taLeftJustify;

  ComboKategori.Columns.Items[KatPris].Width := 50;
  ComboKategori.Columns.Items[KatPris].Alignment := taRightJustify;

  ComboKategori.Columns.Items[KatNr].Width := 150;
  ComboKategori.Columns.Items[KatNr].Visible := False;
End;

//**********************************************************************
// Indlæs kategori
//**********************************************************************
procedure TFormFindMedlemmer.IndlaesKategori;
Var A : Integer;
Begin
//  ComboKategori.Clear;
  //  GridAktiviteter.BeginUpdate;
  // Find kategorier i denne afd
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from priskategori where afd = ' + CurrentAfd);
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount = 0 Then
    Begin
      MessageDlg('Ingen priskategori defineret!',mtInformation,[mbOk],0);
      Exit;
    end;
  A := 0;
  ZQuery1.First;
  While not ZQuery1.EOF Do
    Begin
      If ZQuery1.FieldByName('Vis').AsString = '1' Then
        Begin
          ComboKategori.AddRow;
          ComboKategori.Cells[KatNavn,A] := ZQuery1.FieldByName('beskrivelse').AsString;
          ComboKategori.Cells[KatPris,A] :=
            FloatToStrF(ZQuery1.FieldByName('Pris').AsCurrency,ffNumber,18,2);
          ComboKategori.Cells[KatNr,A]   := ZQuery1.FieldByName('PrisType').AsString;
          Inc(A);
        End;
      ZQuery1.Next;
    End;
  ComboKategori.ItemIndex := 0;
End;

//**********************************************************************
// Indstil Aktiviteter
//**********************************************************************
procedure TFormFindMedlemmer.IndstilAktiviteter;
Begin
  GridAktiviteter.RowCount := 1;
  Indstil_StringGrid_NonEdit(GridAktiviteter);
  GridAktiviteter.Columns.Clear;
  GridAktiviteter.Columns.Add;
  GridAktiviteter.Columns.Add;
  GridAktiviteter.Columns.Add;
  GridAktiviteter.Columns[AktCheck].Title.Caption   := '*';
  GridAktiviteter.Columns[AktCheck].Width           := 20;
  GridAktiviteter.Columns[AktCheck].ButtonStyle     := cbsCheckboxColumn;

  GridAktiviteter.Columns[AktNavn].Title.Caption    := 'Aktivitet';
  GridAktiviteter.Columns[AktNavn].Width            := 200;
  GridAktiviteter.Columns[AktNavn].Alignment        := taLeftJustify;

  GridAktiviteter.Columns[AktNr].Title.Caption      := 'Nr';
  GridAktiviteter.Columns[AktNr].Width              := 50;
  GridAktiviteter.Columns[AktNr].Alignment          := taLeftJustify;
  GridAktiviteter.Columns[AktNr].Visible            := False;

  GridAktiviteter.Options := GridAktiviteter.Options +
    [goRowSelect, goEditing, goTabs];
end;

//**********************************************************************
// Indlaes Aktiviteter
//**********************************************************************
procedure TFormFindMedlemmer.IndlaesAktiviteter;
Begin
  GridAktiviteter.RowCount := 1;
  //  GridAktiviteter.BeginUpdate;
  // Find aktiviteter i denne afd
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from aktiviteter where afd = ' + CurrentAfd);
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount = 0 Then
    Begin
      MessageDlg('Ingen aktiviteter defineret!',mtInformation,[mbOk],0);
      Exit;
    end;
  ZQuery1.First;
  While not ZQuery1.EOF Do
    Begin
      If ZQuery1.FieldByName('Vis').AsString = '1' Then
        Begin
          GridAktiviteter.RowCount := GridAktiviteter.RowCount + 1;
          GridAktiviteter.Cells[AktCheck,GridAktiviteter.RowCount-1] := '1';
          GridAktiviteter.Cells[AktNavn,GridAktiviteter.RowCount-1] :=
            ZQuery1.FieldByName('Beskrivelse').AsString;
          GridAktiviteter.Cells[AktNr,GridAktiviteter.RowCount-1] :=
            ZQuery1.FieldByName('BaneDefNr').AsString;
        End;
      ZQuery1.Next;
    End;
//  GridAktiviteter.EndUpdate;
End;

//**********************************************************************
// Indstil Marks
//**********************************************************************
procedure TFormFindMedlemmer.IndstilMarks;
Begin
  GridMarks.RowCount := 1;
  Indstil_StringGrid_NonEdit(GridMarks);
  GridMarks.Columns.Clear;
  GridMarks.Columns.Add;
  GridMarks.Columns.Add;
  GridMarks.Columns.Add;
  GridMarks.Columns.Add;

  GridMarks.Columns[MarkCheck].Title.Caption   := '*';
  GridMarks.Columns[MarkCheck].Width           := 20;
  GridMarks.Columns[MarkCheck].ButtonStyle     := cbsCheckboxColumn;

  GridMarks.Columns[MarkNonCheck].Title.Caption   := '%';
  GridMarks.Columns[MarkNonCheck].Width           := 20;
  GridMarks.Columns[MarkNonCheck].ButtonStyle     := cbsCheckboxColumn;

  GridMarks.Columns[MarkBesk].Title.Caption    := 'Mærke';
  GridMarks.Columns[MarkBesk].Width            := 200;
  GridMarks.Columns[MarkBesk].Alignment        := taLeftJustify;

  GridMarks.Columns[MarkAuto].Title.Caption      := 'Nr';
  GridMarks.Columns[MarkAuto].Width              := 50;
  GridMarks.Columns[MarkAuto].Alignment          := taLeftJustify;
  GridMarks.Columns[MarkAuto].Visible            := False;

  GridMarks.Options := GridMarks.Options +
    [goRowSelect, goEditing, goTabs];
end;

//**********************************************************************
// Indlaes Marks
//**********************************************************************
procedure TFormFindMedlemmer.IndlaesMarks;
Begin
  GridMarks.RowCount := 1;
  //  GridMarks.BeginUpdate;
  // Find mærker
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from markdef');
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount = 0 Then
    Begin
      MessageDlg('Ingen mærker defineret!',mtInformation,[mbOk],0);
      Exit;
    end;
  ZQuery1.First;
  While not ZQuery1.EOF Do
    Begin
      GridMarks.RowCount := GridMarks.RowCount + 1;
      GridMarks.Cells[MarkCheck,GridMarks.RowCount-1] := '0';
      GridMarks.Cells[MarkNonCheck,GridMarks.RowCount-1] := '0';
      GridMarks.Cells[MarkBesk,GridMarks.RowCount-1] :=
        ZQuery1.FieldByName('Beskrivelse').AsString;
      GridMarks.Cells[MarkAuto,GridMarks.RowCount-1] :=
        ZQuery1.FieldByName('Id').AsString;
      ZQuery1.Next;
    End;
//  GridMarks.EndUpdate;
End;


//**********************************************************
// Luk
//**********************************************************
procedure TFormFindMedlemmer.LukExecute(Sender: TObject);
begin
  Close;
end;

//**********************************************************
// Søg
//**********************************************************
procedure TFormFindMedlemmer.SoegExecute(Sender: TObject);
Var A : Integer;
    State : Boolean;
begin
  // Find evt checkede
(*  CheckMedlemmerList.Clear;
  If Not CheckNumre.Checked Then
    Begin
      If AdvStringGrid1.RowCount > 1 Then
        Begin // Indsæt evt. udvalgte i særlig liste
          For A := 1 to AdvStringGrid1.RowCount-1 Do
            Begin
              If AdvStringGrid1.GetCheckBoxState(FindMedCheck,A,State) Then
                If State Then
                  Begin
                    CheckMedlemmerList.Add(AdvStringGrid1.Cells[FindMedBrugerNr,A]);
                  End;
            End;
        End;
    End;*)
  // Ekstra
(*  CheckEkstraList.Clear;
  If AdvStringGridEkstra.RowCount > 1 Then
    Begin // Indsæt evt. udvalgte i særlig liste
      For A := 1 to AdvStringGridEkstra.RowCount-1 Do
        Begin
          If AdvStringGridEkstra.GetCheckBoxState(MedEkstraCheck,A,State) Then
            If State Then
              Begin
                CheckEkstraList.Add(AdvStringGridEkstra.Cells[MedEkstraObjekt,A]);
              End;
        End;
    End;*)
  // Non Marks evt?
(*  If CheckNonMarks.Checked Then
    Begin // Lav liste med medlemmer som intet mærke har
      LavListeMedNonMarks;
    End;*)
  // Non gruppe evt?
(*  If CheckIngenGruppe.Checked Then
    Begin // Lav liste med medlemmer som ikke er tilknyttet en gruppe
      LavListeMedNonGruppe;
    End;*)
  ForetagSoegning(True);
end;

//**********************************************************************
// Vælg alle i aktivitet
//**********************************************************************
procedure TFormFindMedlemmer.VaelgAktivitetAlleClick(Sender: TObject);
Var A : Integer;
begin
  For A := 1 To GridAktiviteter.RowCount-1 Do
    Begin
      GridAktiviteter.Cells[AktCheck,A] := '1';
    End;
end;


//**********************************************************
// Lav liste med non marks
//**********************************************************
procedure TFormFindMedlemmer.LavListeMedNonMarks;
Begin
  NonMarksListe.Clear;
  With ZQueryMedlem.SQL do
    Begin
      Clear;
      Add('Select * from medlem');
    End;
  ZQueryMedlem.Open;
  If ZQueryMedlem.RecordCount = 0 Then
    Begin
      Exit;
    End;
  ZQueryMedlem.First;
  While Not ZQueryMedlem.Eof Do
    Begin
      With ZQuery1.SQL do
        Begin
          Clear;
          Add('Select * from marks where Medlemsnr = ' +
            ZQueryMedlem.FieldByName('MedlemsNr').AsString);
        End;
      ZQuery1.Open;
      If ZQuery1.RecordCount = 0 Then
        Begin // Indsæt nr i ikke mærke liste
          NonMarksListe.Add(ZQueryMedlem.FieldByName('MedlemsNr').AsString);
        end;
      ZQueryMedlem.Next;
    End;
End;

//**********************************************************************
// År mellem
//**********************************************************************
Function TFormFindMedlemmer.AarMellem(Ny,Dengang : TDatetime) : Word;
Begin
  AarMellem := YearOf(ny) - YearOf(Dengang);
End;

//**********************************************************************
// Foretagsøgning
//**********************************************************************
procedure TFormFindMedlemmer.ForetagSoegning(Clear : Boolean);
Var
  Naeste                : Boolean;
  AlderFraDate          : TDateTime;
  AldertilDate          : TDateTime;
  Year,Month,Day        : Word;
  HelpData              : PResultListType;
  InsertOne             : Boolean;
  NrEkstra              : Integer;
  EkstraStop            : Boolean;
  NrMaerke              : Integer;
  OKMaerke              : Boolean;
  HelpBool              : Boolean;
  FundetIGruppe         : Integer;
  HelpBoolAkt           : Boolean;
  A                     : Integer;
  HelpStr               : String;

Begin
(*  AdvStringGrid1.Col := FindMedBrugerNr;*)
  If Clear Then ResultListe.Clear;
  Try
    DecodeDate(MaskEditDato.Value,Year,Month,Day);
    AlderFraDate := EncodeDate(Year - StrToInt(MaskAlderFra.Text), Month,Day);
    AlderTilDate := EncodeDate(Year - StrToInt(MaskAlderTil.Text)-1, Month,Day);
  Except
    MessageDlg('Indtastningsfejl - alder',mtWarning,[mbOk],0);
    Exit;
  End;
  //  Løb igennem Medlem record for record
  With ZQueryMedlem.SQL do
    Begin
      Clear;
      Add('Select * from medlem');
    End;
  ZQueryMedlem.Open;
  If ZQueryMedlem.RecordCount = 0 Then
    Begin
      MessageDlg('Ingen medlemmer oprettet - der stoppes',mtError,[mbOk],0);
      Exit;
    End;
  ZQueryMedlem.First;

  // Nummer serie
(*  Try
    NrFra := StrToInt(EditNrFra.Text);
    NrTil := StrToInt(EditNrTil.Text);
  Except
    AdvMessageDlg('Numre ikke korrekte',mtError,[mbOk],0);
    Exit;
  End;*)

{  MedlemTabel.DisableControls;}
  Naeste := False;
  Cursor := crHourGlass;
  While Not ZQueryMedlem.Eof Do
    Begin
      { ** Check med maske - felt for felt }
      // Medlemsfødselsdag skal omregnes først
      Naeste := False;
      If (CheckAlder.Checked) Then
        Begin
          If ZQueryMedlem.FieldByName('Foedselsdato').IsNull Then
            Begin
              Naeste := True;
            End
          Else
            Begin
              { ** Alder fra }
              If Not Naeste Then
                Begin
                  Naeste :=  Not (ZQueryMedlem.FieldByName('Foedselsdato').AsFloat <=  DateTimeToJulianDate(AlderFraDate));
                End;
              { ** Alder til }
              If Not Naeste Then
                Begin
                  Naeste :=  Not (ZQueryMedlem.FieldByName('Foedselsdato').AsFloat >=  DateTimeToJulianDate(AldertilDate));
                End;
            End;
        End;
      // Alder
      If (CheckAlderFraTil.Checked) Then
        Begin
          If ZQueryMedlem.FieldByName('Foedselsdato').IsNull Then
            Begin
              Naeste := True;
            End
          Else
            Begin
              // ** Alder fra
              If Not Naeste Then
                Begin
                  Naeste :=  Not (ZQueryMedlem.FieldByName('Foedselsdato').AsFloat >=
                    DateTimeToJulianDate(DateAlderFra.Value));
                End;
              // ** Alder til
              If Not Naeste Then
                Begin
                  Naeste :=  Not (ZQueryMedlem.FieldByName('Foedselsdato').AsFloat <=
                    DateTimeToJulianDate(DateAlderTil.Value));
                End;
            End;
        End;
      // Fødselsdags interval
      If Not Naeste and (RadioHaendelse.ItemIndex <> 0) Then
        Begin
          // Fødselsdag i interval ?
          Naeste := Not (
            (MonthOf(ZQueryMedlem.FieldByName('Foedselsdato').AsDateTime) >= (FoedFraCombo.ItemIndex + 1)) and
            (MonthOf(ZQueryMedlem.FieldByName('Foedselsdato').AsDateTime) <= (FoedTilCombo.ItemIndex + 1)) );
          If Not Naeste and (RadioHaendelse.ItemIndex = 1) Then
            Begin
              // ER det rund?
              Naeste := Not
                  ((AarMellem(Now,ZQueryMedlem.FieldByName('Foedselsdato').AsDateTime)  Div 10) =
                   (AarMellem(Now,ZQueryMedlem.FieldByName('Foedselsdato').AsDateTime)  / 10));
            End
          Else If Not Naeste and (RadioHaendelse.ItemIndex = 2) Then
            Begin
              // Er det halv rund?
              Naeste := Not
                  ((AarMellem(Now,ZQueryMedlem.FieldByName('Foedselsdato').AsDateTime)  Div 5) =
                   (AarMellem(Now,ZQueryMedlem.FieldByName('Foedselsdato').AsDateTime)  / 5));
            End;
        End;
      // Medlem siden
      If Not Naeste and CheckMedSiden.Checked Then
        Begin
          If ZQueryMedlem.FieldByName('MedlemSiden').IsNull Then
            Begin
              Naeste := True;
            End
          Else
            Begin
              // ** Medlem siden
              If Not Naeste Then
                Begin
                  Naeste :=  Not (ZQueryMedlem.FieldByName('MedlemSiden').AsDateTime >
                    DateIndmeldtEfter.Value);
                End;
              // ** Indmeldt før
              If Not Naeste Then
                Begin
                  Naeste :=  Not (ZQueryMedlem.FieldByName('MedlemSiden').AsDateTime <
                    DateIndmeldtFoer.Value);
                End;
            End;
        End;
      // Udmeldt
      If Not Naeste and CheckUdmeldt.Checked Then
        Begin
          If ZQueryMedlem.FieldByName('UdmeldtD').IsNull Then
            Begin
              Naeste := True;
            End
          Else
            Begin
              // ** Udmeldt efter
              If Not Naeste Then
                Begin
                  Naeste :=  Not (ZQueryMedlem.FieldByName('UdmeldtD').AsDateTime >
                    DateUdmeldtEfter.Value);
                End;
              // ** Udmeldt før
              If Not Naeste Then
                Begin
                  Naeste :=  Not (ZQueryMedlem.FieldByName('UdmeldtD').AsDateTime <
                    DateUdmeldtFoer.Value);
                End;
            End;
        End;
      // Ikke Udmeldt
      If Not Naeste and CheckIkkeUdmeldt.Checked Then
        Begin
          Naeste := Not ZQueryMedlem.FieldByName('UdmeldtD').IsNull;
        End;
      // ** PostNr
      If Not Naeste And CheckPostNr.Checked Then
        Begin
          // Land først
          Naeste := Not (ZQueryMedlem.FieldByName('LandKode').AsString =
                 ComboLand.Cells[ComboLand.ItemIndex,1]);
          // Evt. postnr
          If Not Naeste and (PostOmraade.Text <> '****') Then
            Begin
              If PostLig.Checked Then
                Begin
                  Naeste :=  Not (
                    (ZQueryMedlem.FieldByName('PostNr').AsString = PostOmraade.Text) and
                    (ZQueryMedlem.FieldByName('LandKode').AsString =
                     ComboLand.Cells[ComboLand.ItemIndex,1]));
                End
              Else
                Begin
                  Naeste :=  Not (
                    (ZQueryMedlem.FieldByName('PostNr').AsString <> PostOmraade.Text) and
                    (ZQueryMedlem.FieldByName('LandKode').AsString =
                     ComboLand.Cells[ComboLand.ItemIndex,1]));
                End;
            End;
        End;
      // ** Køn
      If Not Naeste And (RadioGroupKoen.ItemIndex <> 3) {2 = begge køn } Then
        Begin
          Naeste :=  Not (
            ZQueryMedlem.FieldByName('Mand').AsInteger =
            RadioGroupKoen.ItemIndex);
        End;
      // ** Aktive, ikke aktive
      If Not Naeste And (RadioGroupAktive.ItemIndex <> 2) {3 svarer til alle} Then
        Begin
          With ZQuery1.SQL do
            Begin
              Clear;
              Add('Select * from aktmed where (afd = ' + CurrentAfd + ') and ' +
                   ' (medlemsnr = ' + ZQueryMedlem.FieldByName('MedlemsNr').AsString + ')');
            End;
          ZQuery1.Open;
          If ZQuery1.RecordCount = 0 Then
            Begin
              Naeste :=  Not (RadioGroupAktive.ItemIndex = 0);
            End
          Else
            Begin
              Naeste :=  Not (RadioGroupAktive.ItemIndex = 1); // Ikke tilmeldt
            End;
        End;
      // Aktiviteter skal undersøges
      If Not Naeste And (CheckAktivitet.Checked) Then
        Begin
          A := 1;
          While Not Naeste and (A < GridAktiviteter.RowCount) do
            Begin
              If GridAktiviteter.Cells[AktCheck,A] = '1' Then
                Begin // Checked
                  With ZQuery1.SQL do
                    Begin
                      Clear;
                      Add('Select * from aktmed where (afd = ' + CurrentAfd + ') and ' +
                           ' (medlemsnr = ' + ZQueryMedlem.FieldByName('MedlemsNr').AsString + ')');
                    End;
                  ZQuery1.Open;
                  If ZQuery1.RecordCount = 0 Then
                    Begin
                      Naeste := True
                    end;
                End;
              Inc(A);
            End;
        End;
      // ** Kategori skal undersøges
      If Not Naeste And (CheckKategori.Checked) Then
        Begin
          With ZQuery1.SQL do
            Begin
              Clear;
              Add('Select * from aktmed where (afd = ' + CurrentAfd + ') and ' +
                   ' (medlemsnr = ' + ZQueryMedlem.FieldByName('MedlemsNr').AsString + ') and ' +
                   ' (pristype = ' + ComboKategori.Cells[2,ComboKategori.ItemIndex] + ')');
            End;
          ZQuery1.Open;
          Naeste := (ZQuery1.RecordCount = 0);
        End;
      // Ingen Aktiviteter skal undersøges
      If Not Naeste And (CheckIngenAktivitet.Checked) Then
        Begin
          With ZQuery1.SQL do
            Begin
              Clear;
              Add('Select * from aktmed where (afd = ' + CurrentAfd + ') and ' +
                   ' (medlemsnr = ' + ZQueryMedlem.FieldByName('MedlemsNr').AsString + ')');
            End;
          ZQuery1.Open;
          Naeste := (ZQuery1.RecordCount <> 0);
        End;
      // Mærker skal undersøges
      If Not Naeste And (CheckMarks.Checked) Then
        Begin
          If MaerkeIndstillingGroup.ItemIndex = 0 Then
            Begin
              // Alle mærker i grid skal undersøges - har medlem et skal han optages i liste
              OKMaerke := False;
              NrMaerke  := 1;
              While (NrMaerke < GridMarks.RowCount) And Not OKMaerke Do
                Begin
                  HelpBool := False;
                  // Undersøg om medlem har dette mærke
                  If (GridMarks.Cells[MarkCheck,NrMaerke] = '1') and Not OKMaerke Then
                    Begin
                      With ZQuery1.SQL do
                        Begin
                          Clear;
                          Add('Select * from marks where (medlemsnr = ' +
                                ZQueryMedlem.FieldByName('MedlemsNr').AsString + ') and ' +
                             '(markid = ' + GridMarks.Cells[MarkAuto,NrMaerke] + ')' );
                        End;
                      ZQuery1.Open;
                      If ZQuery1.RecordCount <> 0 Then
                        Begin
                          // ** Dato fra
                          OKMaerke := (ZQuery1.FieldByName('Dato').AsDateTime >= DatoFra.Value);
                          // ** Dato til
                          If OKMaerke Then
                            Begin
                              OKMaerke := (ZQuery1.FieldByName('Dato').AsDateTime <= DatoTil.Value);
                            End;
                        end;
                    End
                  Else
                    Begin  // Hvis ikke dette mærke
                      If (GridMarks.Cells[MarkNonCheck,NrMaerke] = '1') and Not OKMaerke Then
                        Begin
                          With ZQuery1.SQL do
                            Begin
                              Clear;
                              Add('Select * from marks where (medlemsnr = ' +
                                    ZQueryMedlem.FieldByName('MedlemsNr').AsString + ') and ' +
                                 '(markid = ' + GridMarks.Cells[MarkAuto,NrMaerke] + ')' );
                            End;
                          ZQuery1.Open;
                          OKMaerke := (ZQuery1.RecordCount = 0);
                        End;
                    End;
                  Inc(NrMaerke);
                End;
              // Er alle maerkekriterier
              Naeste := Not OKMaerke;
            End
          Else
            Begin
              // Alle mærker i grid skal undersøges - har medlem alle skal han optages i liste
              OKMaerke := True;
              NrMaerke  := 1;
              While (NrMaerke < GridMarks.RowCount) And OKMaerke Do
                Begin
                  // Skal der checkes for dette mærke
                  If (GridMarks.Cells[MarkCheck,NrMaerke] = '1') and OKMaerke Then
                    Begin
                      // Undersøg om medlem har dette mærke
                      With ZQuery1.SQL do
                        Begin
                          Clear;
                          Add('Select * from marks where (medlemsnr = ' +
                                ZQueryMedlem.FieldByName('MedlemsNr').AsString + ') and ' +
                             '(markid = ' + GridMarks.Cells[MarkAuto,NrMaerke] + ')' );
                        End;
                      ZQuery1.Open;
                      If ZQuery1.RecordCount <> 0 Then
                        Begin
                          // ** Dato fra
                          If OkMaerke Then
                            Begin
                              OKMaerke := (ZQuery1.FieldByName('Dato').AsDateTime >= DatoFra.Value);
                            end;
                          // ** Dato til
                          If OKMaerke Then
                            Begin
                              OKMaerke := (ZQuery1.FieldByName('Dato').AsDateTime <= DatoTil.Value);
                            End;
                        end
                      Else
                        Begin
                          OKMaerke := False;
                        end;
                    End
                  Else
                    Begin  // Hvis ikke dette mærke
                      If (GridMarks.Cells[MarkNonCheck,NrMaerke] = '1') and OKMaerke Then
                        Begin
                          With ZQuery1.SQL do
                            Begin
                              Clear;
                              Add('Select * from marks where (medlemsnr = ' +
                                    ZQueryMedlem.FieldByName('MedlemsNr').AsString + ') and ' +
                                 '(markid = ' + GridMarks.Cells[MarkAuto,NrMaerke] + ')' );
                            End;
                          ZQuery1.Open;
                          OKMaerke := (ZQuery1.RecordCount = 0);
                        End;
                    End;
                  Inc(NrMaerke);
                End;
              // Er alle maerkekriterier
              Naeste := Not OKMaerke;
            End;
        End;
      // ** Non marks
      If Not Naeste and (CheckNonMarks.Checked) Then
        Begin
          Naeste := (NonMarksListe.IndexOf(ZQueryMedlem.FieldByName('Medlemsnr').AsString) = -1);
        End;
      // ** Nr. serie skal undersøges
(*      If Not Naeste And (CheckNumre.Checked) Then
        Begin
          Naeste := Not
               ((ZQueryMedlem.FieldByName('BrugerMedNr').AsInteger >= NrFra) And
                     (ZQueryMedlem.FieldByName('BrugerMedNr').AsInteger <= NrTil));
        End;
      // check om det er et udvalgt medlem
      If Not Naeste And Not CheckNumre.Checked And (CheckMedlemmerList.Count > 0) Then
        Begin
          Naeste := (CheckMedlemmerList.IndexOf(ZQueryMedlem.FieldByName('BrugerMedNr').AsString) = -1);
        End;
      // ** Check objekter / ekstra medlemmer
      If Not Naeste and EkstraMedlemCheck.Checked Then
        Begin
          NrEkstra := 0;
          EkstraStop := False;
          While (NrEkstra < CheckEkstraList.Count) and not EkstraStop Do
            Begin
              EkstraStop := AktObjektTabel.FindKey([CurrentAfd,CheckEkstraList.Strings[NrEkstra],
                ZQueryMedlem.FieldByName('MedlemsNr').AsString]);
              Inc(NrEkstra);
            End;
          Naeste := not EkstraStop;
        End;
      // ** Gruppe af medlemmer
      If Not Naeste and CheckGruppe.Checked Then
        Begin
          // Løb igennem grid og undersøg hvis checked
          NrIGrid := 1;
          InsertOne     := False;
          FundetIGruppe := 0;
          MedGruppeTabel.First;
          While (NrIGrid < AdvStringGrid2.RowCount) Do
            Begin
              AdvStringGrid2.GetCheckBoxState(MedGruppeCheck,NrIgrid,State);
              If State Then // Der er hak for denne gruppe
                Begin
                  If MedGruppeTabel.FindKey([AdvStringGrid2.cells[MedGruppeNr,NrIGrid],
                    ZQueryMedlem.FieldByName('MedlemsNr').AsString]) Then
                    Begin
                      If CheckMereEndEn.Checked Then
                        Begin
                          Inc(FundetIGruppe);
                          If CheckFlere.Checked Then
                            Begin // Alle gruppers data skal indsættes - er der kun denne ene skal den slettes
                              If FundetIGruppe = 1 Then
                                Begin
                                  New(HelpData);
                                  HelpData^.MedlemsNr := ZQueryMedlem.FieldByName('MedlemsNr').AsInteger;
                                  HelpData^.Gruppe := TStringList.Create;
                                  HelpData^.Gruppe.Sorted := False;
                                  HelpData^.Gruppe.Add(AdvStringGrid2.Cells[MedGruppeNr,NrIGrid]);
                                  InsertOne := True;
                                End
                              Else
                                Begin // Medlem er fundet i en gruppe
                                  HelpData^.Gruppe.Add(AdvStringGrid2.Cells[MedGruppeNr,NrIGrid]);
                                End;
                            End
                          Else
                            Begin // Allerede fundet en indsæt
                              If FundetIGruppe = 2 Then
                                Begin
                                  New(HelpData);
                                  HelpData^.MedlemsNr := ZQueryMedlem.FieldByName('MedlemsNr').AsInteger;
                                  HelpData^.Gruppe := TStringList.Create;
                                  HelpData^.Gruppe.Sorted := False;
                                  HelpData^.Gruppe.Add(AdvStringGrid2.Cells[MedGruppeNr,NrIGrid]);
                                  InsertOne := True;
                                End;
                           End;
                        End
                      Else
                        Begin
                          If Not InsertOne then
                            Begin
                              New(HelpData);
                              HelpData^.MedlemsNr := ZQueryMedlem.FieldByName('MedlemsNr').AsInteger;
                              HelpData^.Gruppe := TStringList.Create;
                              HelpData^.Gruppe.Sorted := False;
                              HelpData^.Gruppe.Add(AdvStringGrid2.Cells[MedGruppeNr,NrIGrid]);
                              InsertOne := True;
                            End
                          Else
                            If CheckFlere.Checked Then
                              Begin // Medlem er fundet i en gruppe
                                HelpData^.Gruppe.Add(AdvStringGrid2.Cells[MedGruppeNr,NrIGrid]);
                              End;
                        End;
                    End;
                End;
              Inc(NrIGrid);
            End;
          // Fjern evt. helpdata hvis
          If CheckMereEndEn.Checked and CheckFlere.Checked and (FundetIGruppe = 1) Then
            Begin
              HelpData^.Gruppe.Free;
              InsertOne := False;
            End;
          If InsertOne Then
            Begin
              ResultListe.Add(HelpData);
              Naeste := True;
            End
          Else
            Begin
              Naeste := True;
            End;
        End;
      // ** Non gruppe
      If (Not Naeste and (CheckIngenGruppe.Checked)) Then
        Begin
          Naeste := (NonGruppeListe.IndexOf(ZQueryMedlem.FieldByName('Medlemsnr').AsString) = -1);
        End;
      // ** BS
      If (Not Naeste and (CheckBS.Checked)) Then
        Begin
          // AftaleNr fra
          Naeste := (ZQueryMedlem.FieldByName('PBSAftaleNr').AsFloat <= StrToFloat(EditAftaleNrFra.Text));
          // AftaleNr til
          If Not Naeste Then
            Begin
              Naeste := (ZQueryMedlem.FieldByName('PBSAftaleNr').AsFloat >= StrToFloat(EditAftaleNrTil.Text));
            End;
          // Check PBS status
          If (Not Naeste and CheckPBSStatus.Checked) Then
            Begin
              Naeste := Not (RadioPBSStatus.ItemIndex = ZQueryMedlem.FieldByName('PBSStatus').AsInteger);
            End;
        End;
   *)
      // Indsæt evt.
      If Not Naeste Then // Opfylder alle kriterier
        Begin
          HelpStr := '';
          // Indsæt i listen over fundne
          New(HelpData);
          HelpData^.MedlemsNr := ZQueryMedlem.FieldByName('MedlemsNr').AsInteger;
          HelpData^.Gruppe := TStringList.Create;
          ResultListe.Add(HelpData);
        End;
      ZQueryMedlem.Next;
      Naeste := False;
    End;

  Cursor := crHourGlass;
  { Check if instance of for exists }
(*  if not Assigned(ShowFindForm) then
    { Create the form instance }
    ShowFindForm := TShowFindForm.Create(Self);*)
  ShowFindForm := TShowFindForm.Create(Self);
//  ShowFindForm.SortAdresse := (MedlemSortering.ItemIndex = 2);
  ShowFindForm.IndlaesIGrid(1);
  ShowFindForm.ShowModal;
  ShowFindForm.Free;
  Cursor := crDefault;
End;

end.

