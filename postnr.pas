//***************************************************************************//
//  Holbæk                                                                   //
//  Copyright by Claus Moeller 2013-2016                                     //
//  Postnr                                                                   //
//  Version                                                                  //
//  18.01.14, 20-12-2016                                                     //
//***************************************************************************//
unit PostNr;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  Grids, Menus, ActnList, DbCtrls, clmCombobox, ZDataset;

type

  { TPostNrForm }

  TPostNrForm = class(TForm)
    Importer: TAction;
    Land: TAction;
    ActionList1: TActionList;
    LandCombo: TclmCombobox;
    Help: TAction;
    ImageList1: TImageList;
    Luk: TAction;
    MenuItem1: TMenuItem;
    Opret: TAction;
    PopupMenu1: TPopupMenu;
    Slet: TAction;
    StatusBar1: TStatusBar;
    StringGrid1: TStringGrid;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ZQuery1: TZQuery;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure ImporterExecute(Sender: TObject);
    procedure LandComboChange(Sender: TObject);
    procedure LandExecute(Sender: TObject);
    procedure LukExecute(Sender: TObject);
    procedure OpretExecute(Sender: TObject);
    procedure SletExecute(Sender: TObject);
    procedure StringGrid1EditingDone(Sender: TObject);
  private
    { private declarations }
    UpdateGrid : Boolean;
    procedure Indstil;
    procedure Indlaes;
    procedure IndlaesLand;
    Procedure GemRowTilTabel;
  public
    { public declarations }
  end;

var
  PostNrForm: TPostNrForm;

implementation

{$R *.lfm}

Uses HolbaekConst, MainData, Land; //ImporterPostNr;

Const
  ColPostNr : Integer = 0;
  ColPostBy : Integer = 1;
  ColPostId : Integer = 2;



//**********************************************************
// Create
//**********************************************************
procedure TPostNrForm.FormCreate(Sender: TObject);
begin
  Position := poDesigned;
  (*Top := 10;
  Left := 30;*)
  // Farver
  ToolBar1.Color    := H_Menu_knapper_Farve;
  StatusBar1.Color  := H_Menu_knapper_Farve;;
  Color             := H_Window_Baggrund;
  LandCombo.Color   := H_Combo_Color;
  // Database
  ZQuery1.Connection := MainData.MainDataModule.ZConnection1;

  // Init
  Indstil;
  // Indlaes
  IndlaesLand;
  Indlaes;
end;

//**********************************************************
// Importer
//**********************************************************
procedure TPostNrForm.ImporterExecute(Sender: TObject);
begin
  (*ImporterPostNrForm := TImporterPostNrForm.Create(Self);
  ImporterPostNrForm.ShowModal;
  ImporterPostNrForm.Free;
  Indlaes;*)
end;

//**********************************************************
// Landcombo: Change
//**********************************************************
procedure TPostNrForm.LandComboChange(Sender: TObject);
begin
  Indlaes;
end;

//**********************************************************
// Land
//**********************************************************
procedure TPostNrForm.LandExecute(Sender: TObject);
begin
  LandForm := TLandForm.Create(Self);
  LandForm.ShowModal;
  LandForm.Free;
end;

//**********************************************************
// Close
//**********************************************************
procedure TPostNrForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  ZQuery1.Close;
  CloseAction := caFree;
end;

//**********************************************************
// Indstil
//**********************************************************
procedure TPostNrForm.Indstil;
begin
  Indstil_StringGrid_Edit(StringGrid1);

  StringGrid1.Columns.Clear;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;

  StringGrid1.Columns[ColPostNr].Title.Caption        := 'PostNr';
  StringGrid1.Columns[ColPostNr].Width                := 70;
  StringGrid1.Columns[ColPostNr].Alignment            := taRightJustify;

  StringGrid1.Columns[ColPostBy].Title.Caption        := 'By';
  StringGrid1.Columns[ColPostBy].Width                := 200;
  StringGrid1.Columns[ColPostBy].Alignment            := taLeftJustify;

  StringGrid1.Columns[ColPostId].Title.Caption        := '*';
  StringGrid1.Columns[ColPostId].Width                := 50;
  StringGrid1.Columns[ColPostId].Visible              := False;


end;

//**********************************************************
// Luk
//**********************************************************
procedure TPostNrForm.LukExecute(Sender: TObject);
begin
  Close
end;

//**********************************************************
// Opret
//**********************************************************
procedure TPostNrForm.OpretExecute(Sender: TObject);
Var HelpNr : Integer;
begin
  // Indsæt
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
  Try
    ZQuery1.Append;
    ZQuery1.Edit;
    ZQuery1.FieldByName('id').AsInteger           := HelpNr;
    ZQuery1.FieldByName('LandKode').AsString      := LandCombo.Cells[2,LandCombo.ItemIndex];
    // Postnr
    ZQuery1.FieldByName('PostNr').AsString        := '4300';
    ZQuery1.FieldByName('Town').AsString          := 'Holbæk';
    // Gem
    ZQuery1.Post;
    ZQuery1.ApplyUpdates;
  Except
    MessageDlg('Postnr kunne ikke oprettes!',mtError,[mbOk],0);
    ZQuery1.CancelUpdates;
    Exit;
  end;
  Indlaes;
end;

//**********************************************************
// Slet
//**********************************************************
procedure TPostNrForm.SletExecute(Sender: TObject);
begin
  // Find Record
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from postnr where id = ' +
          StringGrid1.Cells[ColPostId,StringGrid1.Row]);
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount <> 1 Then
    Begin
      MessageDlg('Postnr kan ikke opdateres!',mtInformation,[mbOk],0);
      Exit;
    end;
  ZQuery1.First;
  Try
    ZQuery1.Delete;
  Except
    MessageDlg('Kan ikke fjerne postnr!',mtError,[mbOk],0);
    ZQuery1.CancelUpdates;
    Exit;
  End;
  Indlaes;
end;

//**********************************************************
// Grid: Editing done
//**********************************************************
procedure TPostNrForm.StringGrid1EditingDone(Sender: TObject);
begin
  GemRowTilTabel;
end;

//**********************************************************
// Indlaes
//**********************************************************
procedure TPostNrForm.Indlaes;
Var A : Integer;
Begin
  UpdateGrid := True;
  A                     := 1;
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from postnr where landkode = ' + IntToStr(LandCombo.ItemIndex+1));
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount = 0 Then
    Begin
      StringGrid1.RowCount  := 1;
      MessageDlg('Ingen postnr endnu!',mtInformation,[mbOk],0);
      Exit;
    end;
  ZQuery1.First;
  StringGrid1.RowCount  := 1;
  StringGrid1.BeginUpdate;
  While Not ZQuery1.EOF Do
    Begin
      StringGrid1.RowCount := StringGrid1.RowCount + 1;
      StringGrid1.Cells[ColPostNr,A]   := ZQuery1.FieldByName('PostNr').AsString;
      StringGrid1.Cells[ColPostBy,A]   := ZQuery1.FieldByName('Town').AsString;
      StringGrid1.Cells[ColPostId,A]   := ZQuery1.FieldByName('id').AsString;
      Inc(A);
      ZQuery1.Next;
    end;
  StringGrid1.EndUpdate;
  UpdateGrid := False;
end;

//**********************************************************
// IndlaesLand
//**********************************************************
procedure TPostNrForm.IndlaesLand;
Var A : Integer;
Begin
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from land'); //kassekladdedef where Afd = ' + CurrentAfd);
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount = 0 Then
    Begin
      StringGrid1.RowCount  := 1;
      MessageDlg('Ingen lande endnu!',mtError,[mbOk],0);
      Exit;
    end;
  A                     := 0;
  ZQuery1.First;
  While not ZQuery1.EOF Do
    Begin
      LandCombo.AddRow;
      LandCombo.Cells[0,A] := ZQuery1.FieldByName('Land').AsString;
      LandCombo.Cells[1,A] := ZQuery1.FieldByName('LandForKort').AsString;
      LandCombo.Cells[2,A] := ZQuery1.FieldByName('Landkode').AsString;
      Inc(A);
      ZQuery1.Next;
    end;
  LandCombo.ItemIndex:=0;
end;

//**********************************************************
// Gem row til tabel
//**********************************************************
Procedure TPostNrForm.GemRowTilTabel;
Begin
  If UpdateGrid Then Exit;
  // Find Record
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from postnr where id = ' +
           StringGrid1.Cells[ColPostId,StringGrid1.Row]);
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount <> 1 Then
    Begin
      MessageDlg('Postnr kan ikke opdateres!',mtInformation,[mbOk],0);
      Exit;
    end;
  ZQuery1.First;
  Try
    ZQuery1.Edit;
    // Postnr
    ZQuery1.FieldByName('PostNr').AsString          :=
      StringGrid1.Cells[ColPostNr,StringGrid1.Row];
    // By
    ZQuery1.FieldByName('Town').AsString       :=
      StringGrid1.Cells[ColPostBy,StringGrid1.Row];
    // Gem
    ZQuery1.Post;
    ZQuery1.ApplyUpdates;
  Except
    ZQuery1.CancelUpdates;
    MessageDlg('PostNr blev ikke gemt!',mtError,[mbOK],0);
    Exit;
  End
End;


end.

