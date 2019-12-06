//***************************************************************************//
//  Holbæk                                                                   //
//  Copyright by Claus Moeller 2013-2016                                     //
//  PerioDef                                                                 //
//  Version                                                                  //
//  18.10.13, 20-12-2016                                                     //
//***************************************************************************//
unit PeriodeDef;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ActnList,
  Menus, ComCtrls, ExtCtrls, Grids, EditBtn, StdCtrls, DBGrids, DbCtrls,
  ZDataset, db;

type

  { TPeriodeDefForm }

  TPeriodeDefForm = class(TForm)
    DateEdit1: TDateEdit;
    Slet: TAction;
    ActionList1: TActionList;
    Help: TAction;
    ImageList1: TImageList;
    Luk: TAction;
    MenuItem1: TMenuItem;
    Opret: TAction;
    PopupMenu1: TPopupMenu;
    StringGrid1: TStringGrid;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ZQuery1: TZQuery;
    procedure DateEdit1Exit(Sender: TObject);
    procedure DateEdit1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure HelpExecute(Sender: TObject);
    procedure LukExecute(Sender: TObject);
    procedure OpretExecute(Sender: TObject);
    procedure SletExecute(Sender: TObject);
    procedure StringGrid1CheckboxToggled(sender: TObject; aCol, aRow: Integer;
      aState: TCheckboxState);
    procedure StringGrid1EditingDone(Sender: TObject);
    procedure StringGrid1SelectEditor(Sender: TObject; aCol, aRow: Integer;
      var Editor: TWinControl);
  private
    { private declarations }
    UpdateGrid : Boolean;
    NextPeriodListe : TSTringList;
    procedure Indstil;
    procedure Indlaes;
    Procedure GemRowTilTabel;
  public
    { public declarations }
  end;

var
  PeriodeDefForm: TPeriodeDefForm;

implementation
{$R *.lfm}

Uses HolbaekConst, MainData, DateUtils;

Const
  PerBet        : Integer = 0;
  PerBesk       : Integer = 1;
  PerFra        : Integer = 2;
  PerTil        : Integer = 3;
  PerAfsluttet  : Integer = 4;
  PerNextPeriod : Integer = 5;
  PerOption     : Integer = 6;
  PerId         : Integer = 7;

{ TPeriodeDefForm }

//**********************************************************
// Create
//**********************************************************
procedure TPeriodeDefForm.FormCreate(Sender: TObject);
begin
  Position := poDesigned;
  (*Top := 10;
  Left := 30;*)
  // Farver
  ToolBar1.Color    := H_Menu_knapper_Farve;
//  StatusBar1.Color  := H_Menu_knapper_Farve;;
  Color             := H_Window_Baggrund;
  // Database
  ZQuery1.Connection := MainData.MainDataModule.ZConnection1;
  // Init
  NextPeriodListe := TStringlist.Create;
  Indstil;
  Indlaes;
  // Andet

end;

//**********************************************************
// Destroy
//**********************************************************
procedure TPeriodeDefForm.FormDestroy(Sender: TObject);
begin
  NextPeriodListe.Free;
end;

//**********************************************************
// Hjælp
//**********************************************************
procedure TPeriodeDefForm.HelpExecute(Sender: TObject);
begin
  MessageDlg('Hjælp',mtInformation,[mbOK],0);
end;

//**********************************************************
// Gem row til tabel
//**********************************************************
Procedure TPeriodeDefForm.GemRowTilTabel;
Var Stop : Boolean;
Begin
  If UpdateGrid Then Exit;
  // Find Record
  Try
    With MainDataModule.ZQuery1 do
      Begin
        SQL.Clear;
        SQL.Add('Select * from PeriodeDef where Afd = ' + CurrentAfd +
            ' and nr = ' + StringGrid1.Cells[PerId,StringGrid1.Row]);
        Open;
        If RecordCount <> 1 Then
          Begin
            MessageDlg('Periode kan ikke opdateres!',mtInformation,[mbOk],0);
            Exit;
          end;
        First;
        Edit;
        FieldByName('Periode').AsString     := StringGrid1.Cells[PerBet,StringGrid1.Row];
        FieldByName('Beskrivelse').AsString := StringGrid1.Cells[PerBesk,StringGrid1.Row];
        FieldByName('DatoFra').AsFloat      := DateTimeToJulianDate(StrToDate(StringGrid1.Cells[PerFra,StringGrid1.Row]));
        FieldByName('DatoTil').AsFloat      := DateTimeToJulianDate(StrToDate(StringGrid1.Cells[PerTil,StringGrid1.Row]));
        FieldByName('Afsluttet').AsString   := StringGrid1.Cells[PerAfsluttet,StringGrid1.Row];
        FieldByName('NextPeriod').AsString  := StringGrid1.Cells[PerNextPeriod,StringGrid1.Row];
        FieldByName('Option').AsString      := StringGrid1.Cells[PerOption,StringGrid1.Row];
        Post;
        ApplyUpdates;
      end;
  Except
    MainDataModule.ZQuery1.CancelUpdates;
    MessageDlg('Periode blev ikke gemt!',mtError,[mbOK],0);
    Exit;
  End
End;

//**********************************************************
// Indlæs
//**********************************************************
Procedure TPeriodeDefForm.Indlaes;
Var A : Integer;
Begin
  UpdateGrid := True;
  Try
    With MainDataModule.ZQuery1 do
      Begin
        SQL.Clear;
        SQL.Add('Select * from periodedef where Afd = ' + CurrentAfd);
        StringGrid1.RowCount  := 1;
        Open;
        If RecordCount = 0 Then
          Begin
            MessageDlg('Endnu ingen perioder defineret!',mtInformation,[mbOk],0);
            Exit;
          end;
        NextPeriodListe.Clear;
        A                     := 1;
        First;
        StringGrid1.BeginUpdate;
        While Not EOF Do
          Begin
            StringGrid1.RowCount := StringGrid1.RowCount + 1;
            StringGrid1.Cells[PerBet,A]        := FieldByName('Periode').AsString;
            NextPeriodListe.Add(FieldByName('Periode').AsString);
            StringGrid1.Cells[PerBesk,A]       := FieldByName('Beskrivelse').AsString;
            StringGrid1.Cells[PerFra,A]        := FieldByName('DatoFra').AsString;
            StringGrid1.Cells[PerTil,A]        := FieldByName('DatoTil').AsString;
            StringGrid1.Cells[PerAfsluttet,A]  := FieldByName('Afsluttet').AsString;
            StringGrid1.Cells[PerNextPeriod,A] := FieldByName('NextPeriod').AsString;
            StringGrid1.Cells[PerOption,A]     := FieldByName('Option').AsString;
            StringGrid1.Cells[PerId,A]         := FieldByName('Nr').AsString;
            Inc(A);
            Next;
          end;
        StringGrid1.EndUpdate;
        UpdateGrid := False;
      end
  Except
  end;
end;

//**********************************************************
// Date edit key down
//**********************************************************
procedure TPeriodeDefForm.DateEdit1KeyDown(Sender: TObject; var Key: Word;
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
procedure TPeriodeDefForm.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
//  ZQuery1.Close;
  CloseAction := caFree;
end;

//**********************************************************
// Date edit exit
//**********************************************************
procedure TPeriodeDefForm.DateEdit1Exit(Sender: TObject);
begin
  StringGrid1.Cells[StringGrid1.Col,StringGrid1.Row] := DateToStr(DateEdit1.Date);
end;

//**********************************************************
// Indstil
//**********************************************************
procedure TPeriodeDefForm.Indstil;
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

  StringGrid1.Columns[PerBet].Title.Caption        := 'Beteg.';
  StringGrid1.Columns[PerBet].Width                := 70;
  StringGrid1.Columns[PerBet].Alignment            := taLeftJustify;

  StringGrid1.Columns[PerBesk].Title.Caption       := 'Beskrivelse';
  StringGrid1.Columns[PerBesk].Width               := 150;
  StringGrid1.Columns[PerBesk].Alignment           := taLeftJustify;

  StringGrid1.Columns[PerFra].Title.Caption        := 'Fra';
  StringGrid1.Columns[PerFra].Width                := 70;
  StringGrid1.Columns[PerFra].Alignment            := taLeftJustify;

  StringGrid1.Columns[PerTil].Title.Caption        := 'Til';
  StringGrid1.Columns[PerTil].Width                := 70;
  StringGrid1.Columns[PerTil].Alignment            := taLeftJustify;

  StringGrid1.Columns[PerAfsluttet].Title.Caption  := 'Afsluttet';
  StringGrid1.Columns[PerAfsluttet].Width          := 50;
  StringGrid1.Columns[PerAfsluttet].ButtonStyle    := cbsCheckboxColumn;

  StringGrid1.Columns[PerNextPeriod].Title.Caption := 'Næste per.';
  StringGrid1.Columns[PerNextPeriod].Width         := 80;
  StringGrid1.Columns[PerNextPeriod].Alignment     := taLeftJustify;

  StringGrid1.Columns[PerOption].Title.Caption     := 'Option';
  StringGrid1.Columns[PerOption].Width             := 50;
  StringGrid1.Columns[PerOption].Alignment         := taLeftJustify;

  StringGrid1.Columns[PerId].Title.Caption         := 'Id';
  StringGrid1.Columns[PerId].Width                 := 50;
  StringGrid1.Columns[PerId].Visible               := False;
End;


//**********************************************************
// Luk
//**********************************************************
procedure TPeriodeDefForm.LukExecute(Sender: TObject);
begin
  Close;
end;

//**********************************************************
// Opret
//**********************************************************
procedure TPeriodeDefForm.OpretExecute(Sender: TObject);
Var HelpNr : Integer;
begin
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from PeriodeDef order by nr');
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
    // Periode betegnelse 4 tegn
    ZQuery1.FieldByName('Periode').AsString       := '2014';
    // Beskrivelse 40 tegn
    ZQuery1.FieldByName('Beskrivelse').AsString   := 'Periode beskrivelse';
    // Fra dato
    ZQuery1.FieldByName('DatoFra').AsString       := '01-01-1900';
    // Til dato
    ZQuery1.FieldByName('DatoTil').AsString       := '01-01-2100';
    // Afsluttet
    ZQuery1.FieldByName('Afsluttet').AsString     := '0';
    // Next period
    ZQuery1.FieldByName('NextPeriod').Clear;
    // Option
    ZQuery1.FieldByName('Option').Clear;
    // Gem
    ZQuery1.Post;
    ZQuery1.ApplyUpdates;
  Except
    MessageDlg('Periode kunne ikke oprettes!',mtError,[mbOk],0);
    ZQuery1.CancelUpdates;
    Exit;
  end;
  Indlaes;
end;

//**********************************************************
// Slet
//**********************************************************
procedure TPeriodeDefForm.SletExecute(Sender: TObject);
Begin
  If StringGrid1.RowCount = 2 Then
    Begin
      MessageDlg('Der skal min. være defineret en periode!',mtInformation,[mbOk],0);
      Exit;
    end;
  // Find Record
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from PeriodeDef where Afd = ' + CurrentAfd +
          ' and nr = ' + StringGrid1.Cells[PerId,StringGrid1.Row]);
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount <> 1 Then
    Begin
      MessageDlg('Periode kan ikke slettes!',mtInformation,[mbOk],0);
      Exit;
    end;
  ZQuery1.First;
   { TODO : Kan periode slettes? }
  Try
    ZQuery1.Delete;
  Except
    MessageDlg('Kan ikke fjerne perioden!',mtError,[mbOk],0);
    ZQuery1.CancelUpdates;
    Exit;
  End;
  Indlaes;
end;

//**********************************************************
// StringGrid: Checkbox
//**********************************************************
procedure TPeriodeDefForm.StringGrid1CheckboxToggled(sender: TObject; aCol,
  aRow: Integer; aState: TCheckboxState);
begin
  GemRowTilTabel;
end;

//**********************************************************
// StringGrid: Editing done
//**********************************************************
procedure TPeriodeDefForm.StringGrid1EditingDone(Sender: TObject);
begin
  GemRowTilTabel;
end;

//**********************************************************
// StringGrid: Select Editor
//**********************************************************
procedure TPeriodeDefForm.StringGrid1SelectEditor(Sender: TObject; aCol,
  aRow: Integer; var Editor: TWinControl);
begin
If      aCol = PerBet Then
  Begin
    Editor := StringGrid1.EditorByStyle(cbsAuto);
  end
Else If acol = PerBesk Then
  Begin
    Editor := StringGrid1.EditorByStyle(cbsAuto);
  end
Else If acol = PerFra Then
  Begin
    try
      DateEdit1.BoundsRect := StringGrid1.CellRect(aCol,aRow);
      If StringGrid1.Cells[StringGrid1.Col,StringGrid1.Row] <> '' Then
        DateEdit1.Date := StrToDate(StringGrid1.Cells[StringGrid1.Col,StringGrid1.Row]);
      Editor := DateEdit1;
    Except
    end;
  end
Else If acol = PerTil Then
  Begin
    try
      DateEdit1.BoundsRect := StringGrid1.CellRect(aCol,aRow);
      If StringGrid1.Cells[StringGrid1.Col,StringGrid1.Row] <> '' Then
        DateEdit1.Date := StrToDate(StringGrid1.Cells[StringGrid1.Col,StringGrid1.Row]);
      Editor := DateEdit1;
    Except
    end;
  end
Else If acol = PerAfsluttet Then
  Begin
    Editor := StringGrid1.EditorByStyle(cbsCheckboxColumn);
  end
Else If acol = PerNextPeriod Then
  Begin
    Editor := StringGrid1.EditorByStyle(cbsPickList);
    TCustomComboBox(Editor).Items.AddStrings(NextPeriodListe);
  end
Else If acol = PerOption Then
  Begin
    Editor := StringGrid1.EditorByStyle(cbsPickList);
    TCustomComboBox(Editor).Items.Clear;
    TCustomComboBox(Editor).Items.Add('Indsæt');
    TCustomComboBox(Editor).Items.Add('Spørg inden');
  end
end;

end.

