//***************************************************************************//
//  Holbæk                                                                   //
//  Copyright by Claus Moeller 2013-2014                                     //
//  Importer potnr                                                           //
//  Version                                                                  //
//  19.01.14                                                                 //
//***************************************************************************//
unit ImporterPostNr;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Menus,
  ActnList, ComCtrls, ExtCtrls, StdCtrls, EditBtn, Grids, CheckLst, Buttons,
  clmCombobox, ZDataset, charencstreams;

type

  { TImporterPostNrForm }

  TImporterPostNrForm = class(TForm)
    Slet: TAction;
    Importer: TAction;
    Ned: TAction;
    Op: TAction;
    ActionList1: TActionList;
    CheckListBox1: TCheckListBox;
    LandCombo: TclmCombobox;
    FileNameEdit1: TFileNameEdit;
    GroupBox1: TGroupBox;
    Help: TAction;
    ImageList1: TImageList;
    Label1: TLabel;
    Label2: TLabel;
    Luk: TAction;
    MenuItem1: TMenuItem;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    PopupMenu1: TPopupMenu;
    StringGrid1: TStringGrid;
    ToolBar1: TToolBar;
    ToolBar2: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ZQuery1: TZQuery;
    ZQuery2: TZQuery;
    procedure CheckListBox1ClickCheck(Sender: TObject);
    procedure FileNameEdit1AcceptFileName(Sender: TObject; var Value: String);
    procedure FormCreate(Sender: TObject);
    procedure HelpExecute(Sender: TObject);
    procedure ImporterExecute(Sender: TObject);
    procedure LukExecute(Sender: TObject);
    procedure NedExecute(Sender: TObject);
    procedure OpExecute(Sender: TObject);
    procedure SletExecute(Sender: TObject);
  private
    { private declarations }
    fCES: TCharEncStream;
    procedure Indstil;
    procedure LoadGridFromCSVFile(Grid: TStringGrid;AFilename: string;
      ADelimiter:Char=','; WithHeader:boolean=true;AddRows:boolean=true);
    Procedure UpdateChecked;
  public
    { public declarations }
  end;

var
  ImporterPostNrForm: TImporterPostNrForm;

implementation

{$R *.lfm}

{ TImporterPostNrForm }

Uses HolbaekMain, HolbaekConst, CSVDocument;

Const
  Town_Databasename   : String = 'Town';
  PostNr_Databasename : String = 'PostNr';


//**********************************************************
// Create
//**********************************************************
procedure TImporterPostNrForm.FormCreate(Sender: TObject);
begin
  Position := poDesigned;
  (*Top := 10;
  Left := 30;*)
  // Farver
  ToolBar1.Color    := H_Menu_knapper_Farve;
//  StatusBar1.Color  := H_Menu_knapper_Farve;;
  Color             := H_Window_Baggrund;
  LandCombo.Color   := H_Combo_Color;
  // Database
//  ZQuery1.Connection := MainForm.ZConnection1;
//  ZQuery2.Connection := MainForm.ZConnection1;

  // Init
  Indstil;
  Indstil_StringGrid_Edit(StringGrid1);
  StringGrid1.Options:=[goFixedVertLine,goFixedHorzLine,goVertLine,goHorzLine,goRangeSelect,goColMoving,goEditing,goSmoothScroll];
  // Indlaes
//  IndlaesType;
//  Indlaes;
end;

//**********************************************************
// Hjælp
//**********************************************************
procedure TImporterPostNrForm.HelpExecute(Sender: TObject);
begin
  ShowMessage('Hjælp');
end;

//**********************************************************
// Importer
//**********************************************************
procedure TImporterPostNrForm.ImporterExecute(Sender: TObject);
Var A         : Integer;
    Stop      : Boolean;
    RowNr     : Integer;
    ColNr     : Integer;
    HelpNr    : Integer;
    PostNrKol : Integer;
    AntalInd  : Integer;
begin
  // Er der check i felter
  A := 0;
  Stop := False;
  While (A < CheckListbox1.Count) and not Stop Do
    Begin
      Stop := CheckListbox1.Checked[A];
      Inc(A);
    end;
  If Not Stop Then
    Begin
      MessageDlg('Ingen valgt',mtError,[mbOk],0);
      Exit;
    end;
  // Er der indlæst data?
  If StringGrid1.RowCount < 2 Then
    Begin
      MessageDlg('Intet at importere!',mtError,[mbOk],0);
      Exit;
    end;
  // Er de nødvendige felter til stede
    // Town
    ColNr := 0;
    Stop  := False;
    While (ColNr < StringGrid1.ColCount) and Not Stop Do
      Begin
        Stop := StringGrid1.Columns.Items[ColNr].Title.Caption = Town_Databasename;
        Inc(ColNr);
      end;
    If not Stop Then
      Begin
        MessageDlg('Kolonne med by (Town) skal importeres! - der afbrydes', mtInformation, [mbOK],0);
        Exit;
      end;
    // PostNr
    ColNr := 0;
    Stop  := False;
    While (ColNr < StringGrid1.ColCount) and Not Stop Do
      Begin
        Stop := StringGrid1.Columns.Items[ColNr].Title.Caption = PostNr_DatabaseName;
        PostNrKol := ColNr;
        Inc(ColNr);
      end;
    If not Stop Then
      Begin
        MessageDlg('Kolonne med Postnr skal importeres! - der afbrydes', mtInformation, [mbOK],0);
        Exit;
      end;
  // Start indlæsning til database
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from postnr order by id');
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount = 0 Then
    Begin
      HelpNr := 1;
    end
  Else
    Begin
      ZQuery1.Last;
      HelpNr := ZQuery1.FieldByName('id').AsInteger + 1;
    end;
    With ZQuery1.SQL do
      Begin
        Clear;
        Add('Select * from postnr order by id');
      End;
  // Run through Grid and import
  AntalInd := 0;
  RowNr    := 1;
  Stop     := False;
  While (RowNr < StringGrid1.RowCount) and not Stop Do
    Begin
      // Sidste check: Findes postnr i forvejen
      With ZQuery2.SQL do
        Begin
          Clear;
          Add('Select * from postnr where (postnr = ' + StringGrid1.Cells[PostNrKol,RowNr] +
              ') and (landkode = ' + LandCombo.Cells[2,LandCombo.ItemIndex]+ ')');
        End;
      ZQuery2.Open;
      If ZQuery2.RecordCount = 0 Then
        Begin // Skal oprettes
          // Løb igennem cols
          Try
            With ZQuery1.SQL do
              Begin
                Clear;
                Add('Select * from postnr order by id');
              End;
            ZQuery1.Open;
            ZQuery1.Append;
            ZQuery1.Edit;
            ZQuery1.FieldByName('id').AsInteger           := HelpNr;
            ZQuery1.FieldByName('LandKode').AsString      := LandCombo.Cells[2,LandCombo.ItemIndex];
            ColNr := 0;
            While ColNr < StringGrid1.ColCount Do
              Begin
                ZQuery1.FieldByName(StringGrid1.Columns.Items[ColNr].Title.Caption).AsString :=
                  StringGrid1.Cells[ColNr,RowNr];
                Inc(ColNr);
              end;
            // Gem
            ZQuery1.Post;
            ZQuery1.ApplyUpdates;
            Inc(AntalInd);
          Except
            MessageDlg('Postnr kunne ikke oprettes!',mtError,[mbOk],0);
            ZQuery1.CancelUpdates;
            Exit;
          end;
          Inc(HelpNr);
        End;
      Inc(RowNr);
    end;
  MessageDlg('Importeret ' + IntToStr(AntalInd) + ' postnr!',mtInformation,[mbOk],0);
end;

//**********************************************************
// Luk
//**********************************************************
procedure TImporterPostNrForm.LukExecute(Sender: TObject);
begin
  Close;
end;

//**********************************************************
// Ned
//**********************************************************
procedure TImporterPostNrForm.NedExecute(Sender: TObject);
Var HelpStr : String;
    OldIndex : Integer;
    Checked  : Boolean;
begin
  If (CheckListBox1.ItemIndex < (CheckListBox1.Items.Count-1)) and
     (CheckListBox1.ItemIndex <> - 1) Then
    Begin
      CheckListBox1.Visible := False;
      Checked  := CheckListBox1.Checked[CheckListBox1.ItemIndex];
      HelpStr := CheckListBox1.Items[CheckListBox1.ItemIndex];
      OldIndex := CheckListBox1.ItemIndex;
      CheckListBox1.Items.Delete(CheckListBox1.ItemIndex);
      CheckListBox1.Items.Insert(OldIndex+1, HelpStr);
      CheckListBox1.ItemIndex := OldIndex+1;
      CheckListBox1.Checked[CheckListBox1.ItemIndex] := Checked;
      CheckListBox1.Visible := True;
      UpdateChecked;
    End;
end;

//**********************************************************
// Op
//**********************************************************
procedure TImporterPostNrForm.OpExecute(Sender: TObject);
Var HelpStr : String;
    OldIndex : Integer;
    Checked  : Boolean;
begin
  If CheckListBox1.ItemIndex > 0 Then
    Begin
      CheckListBox1.Visible := False;
      Checked  := CheckListBox1.Checked[CheckListBox1.ItemIndex];
      HelpStr  := CheckListBox1.Items[CheckListBox1.ItemIndex];
      OldIndex := CheckListBox1.ItemIndex;
      CheckListBox1.Items.Delete(CheckListBox1.ItemIndex);
      CheckListBox1.Items.Insert(OldIndex - 1, HelpStr);
      CheckListBox1.ItemIndex := OldIndex - 1;
      CheckListBox1.Checked[CheckListBox1.ItemIndex] := Checked;
      CheckListBox1.Visible := True;
      UpdateChecked;
    End;
end;

//**********************************************************
// Slet
//**********************************************************
procedure TImporterPostNrForm.SletExecute(Sender: TObject);
begin
  // Slet postnr
  // Kald til database
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from postnr where landkode = ' + LandCombo.Cells[2,LandCombo.ItemIndex]);
    End;
  ZQuery1.Open;
  If MessageDlg('Ønsker du at slette ' +  IntToStr(Zquery1.RecordCount) +
    ' postnr for ' + LandCombo.Text + '?',mtConfirmation,[mbYes,mbNo],0) <> mrYes Then Exit;
  While Not Zquery1.EOF Do
    Begin;
      Try
        ZQuery1.Delete;
      Except
      end;
    end;
  ZQuery1.Close;
end;

//**********************************************************
// Update Checked
//**********************************************************
Procedure TImporterPostNrForm.UpdateChecked;
Var A : Integer;
    FeltNr : Integer;
Begin
  A := 0;
  FeltNr := 0;
  //StringGrid1.Columns.Clear;
  While A  < CheckListBox1.Items.Count Do
    Begin
      If CheckListBox1.Checked[A] Then
        Begin
          StringGrid1.Columns.Items[FeltNr].Title.Caption:=CheckListBox1.Items[A];
          If FeltNr < StringGrid1.ColCount Then
            Begin
              Inc(FeltNr);
            End;
        End;
      Inc(A);
    End;
(*  For A := FeltNr To StringGrid1.ColCount - 1 Do
    Begin
      StringGrid1.Columns.Items[FeltNr].Title.Caption:=CheckListBox1.Items[A];
    End;*)
End;


//**********************************************************
// Filename: Edit
//**********************************************************
procedure TImporterPostNrForm.FileNameEdit1AcceptFileName(Sender: TObject;
  var Value: String);
begin
  LoadGridFromCSVFile(StringGrid1,Value,',',true,true);
end;

//**********************************************************
// Checklistbox: Check
//**********************************************************
procedure TImporterPostNrForm.CheckListBox1ClickCheck(Sender: TObject);
begin
  UpdateChecked;
end;

//**********************************************************
// Indstil
//**********************************************************
procedure TImporterPostNrForm.Indstil;
Var A : Integer;
Begin
  CheckListBox1.Clear;
  CheckListBox1.Color := H_Grid_BackColor;
  CheckListBox1.Items.Add(PostNr_Databasename);
  CheckListBox1.Items.Add(Town_Databasename);
  A                     := 1;
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
      LandCombo.Cells[0,A] := ZQuery1.FieldByName('Land').asString;
      LandCombo.Cells[1,A] := ZQuery1.FieldByName('LandForKort').asString;
      LandCombo.Cells[2,A] := ZQuery1.FieldByName('LandKode').asString;
      Inc(A);
      ZQuery1.Next;
    end;
  LandCombo.ItemIndex := 0;
end;


//**********************************************************
// LoadGridFromCSV File
//**********************************************************
procedure TImporterPostNrForm.LoadGridFromCSVFile(Grid: TStringGrid;AFilename: string;
  ADelimiter:Char=','; WithHeader:boolean=true;AddRows:boolean=true);
const
  DefaultRowCount=10; //Number of rows to show by default
var
  FileStream: TFileStream;
  Parser: TCSVParser;
  RowOffset: integer;
  A          : Integer;
  I          : Integer;
  HelpStrings : TStringList;

begin
  Grid.BeginUpdate;
  // Reset the grid:
//  Grid.Clear;
  Grid.RowCount:=DefaultRowCount;
//  Grid.ColCount:=6; //Vaguely sensible
  if not(FileExistsUTF8(AFileName)) then exit;

  Parser:=TCSVParser.Create;
  fCES := TCharEncStream.Create;
  fCES.LoadFromFile(AFileName);
  try
    Parser.Delimiter:=ADelimiter;
    Parser.SetSource(fCES.UTF8Text);

    // If the grid has fixed rows, those will not receive data, so we need to
    // calculate the offset
    RowOffset:=Grid.FixedRows;
    // However, if we have a header row in our CSV data, we need to
    // discount that
    if WithHeader then RowOffset:=RowOffset-1;

    while Parser.ParseNextCell do
    begin
      // Stop if we've filled all existing rows. Todo: check for fixed grids etc, but not relevant for our case
      if AddRows=false then
        if Parser.CurrentRow+1>Grid.RowCount then break; //VisibleRowCount doesn't seem to work.

      // Widen grid if necessary. Slimming the grid will come after import done.
      if Grid.Columns.Enabled then
      begin
        if Grid.Columns.VisibleCount<Parser.CurrentCol+1 then Grid.Columns.Add;
      end
      else
      begin
        if Grid.ColCount<Parser.CurrentCol+1 then Grid.ColCount:=Parser.CurrentCol+1;
      end;

      // If header data found, and a fixed row is available, set the caption
      if (WithHeader) and
        (Parser.CurrentRow=0) and
        (Parser.CurrentRow<Grid.FixedRows-1) then
      begin
        // Assign header data to the first fixed row in the grid:
        Grid.Columns[Parser.CurrentCol].Title.Caption:=Parser.CurrentCellText;
      end;

      // Actual data import into grid cell, minding fixed rows and header
      if Grid.RowCount<Parser.CurrentRow+1 then
        Grid.RowCount:=Parser.CurrentRow+1;
      Grid.Cells[Parser.CurrentCol,Parser.CurrentRow+RowOffset]:=
        Parser.CurrentCellText;

    end;

    // Now we know the widest row in the import, we can snip the grid's
    // columns if necessary.
    if Grid.Columns.Enabled then
    begin
      while Grid.Columns.VisibleCount>Parser.MaxColCount do
      begin
        Grid.Columns.Delete(Grid.Columns.Count-1);
      end;
    end
    else
    begin
      if Grid.ColCount>Parser.MaxColCount then
        Grid.ColCount:=Parser.MaxColCount;
    end;

  finally
    Parser.Free;
    Grid.EndUpdate;
    Grid.AutoSizeColumns;
  end;
end;

end.

