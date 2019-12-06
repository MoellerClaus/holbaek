//***************************************************************************//
//  Holbæk                                                                   //
//  Copyright by Claus Moeller 2013-2016                                     //
//  Mærke                                                                    //
//  Version                                                                  //
//  11.02.14, 10-12-2016                                                     //
//***************************************************************************//
unit def_maerker;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  Grids, Menus, ActnList, ZDataset;

type

  { TDefMaerkeForm }

  TDefMaerkeForm = class(TForm)
    ActionList1: TActionList;
    Help: TAction;
    ImageList1: TImageList;
    Land: TAction;
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
    ToolButton4: TToolButton;
    ToolButton6: TToolButton;
    ZQuery1: TZQuery;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure HelpExecute(Sender: TObject);
    procedure LukExecute(Sender: TObject);
    procedure OpretExecute(Sender: TObject);
    procedure SletExecute(Sender: TObject);
    procedure StringGrid1EditingDone(Sender: TObject);
    procedure StringGrid1SelectEditor(Sender: TObject; aCol, aRow: Integer;
      var Editor: TWinControl);
  private
    { private declarations }
    UpdateGrid : Boolean;
    procedure Indstil;
    procedure Indlaes;
    procedure GemRowTilTabel;
  public
    { public declarations }
  end;

var
  DefMaerkeForm: TDefMaerkeForm;

implementation

{$R *.lfm}

Uses MainData, HolbaekConst;

Const
  MarkId         = 0;
  MarkBesk       = 1;

  { TDefMaerkeForm }

//**********************************************************
// Create
//**********************************************************
procedure TDefMaerkeForm.FormCreate(Sender: TObject);
begin
  Position := poDesigned;
  (*Top := 10;
  Left := 30;*)
  // Farver
  ToolBar1.Color    := H_Menu_knapper_Farve;
  StatusBar1.Color  := H_Menu_knapper_Farve;;
  Color             := H_Window_Baggrund;
  // Database
  ZQuery1.Connection := MainDataModule.ZConnection1;

  // Init

  UpdateGrid := False;
  Indstil;
  // Indlaes

  Indlaes;

end;

//**********************************************************
// Destroy
//**********************************************************
procedure TDefMaerkeForm.FormDestroy(Sender: TObject);
begin
end;

//**********************************************************
// Hjælp
//**********************************************************
procedure TDefMaerkeForm.HelpExecute(Sender: TObject);
begin
  ShowMessage('Hjælp');
end;


//**********************************************************
// Close
//**********************************************************
procedure TDefMaerkeForm.LukExecute(Sender: TObject);
begin
  Close;
end;

//**********************************************************
// Opret
//**********************************************************
procedure TDefMaerkeForm.OpretExecute(Sender: TObject);
begin
  // Indsæt
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from markdef');
    End;
  ZQuery1.Open;
  Try
    ZQuery1.Append;
    ZQuery1.Edit;
    ZQuery1.FieldByName('Beskrivelse').AsString   := 'Mærke x';
    // Gem
    ZQuery1.Post;
    ZQuery1.ApplyUpdates;
  Except
    MessageDlg('Mærke kunne ikke oprettes!',mtError,[mbOk],0);
    ZQuery1.CancelUpdates;
    Exit;
  end;
  Indlaes;
end;

//**********************************************************
// Slet
//**********************************************************
procedure TDefMaerkeForm.SletExecute(Sender: TObject);
begin
  // Find Record
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from markdef where id = ' +
          StringGrid1.Cells[MarkId,StringGrid1.Row]);
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount <> 1 Then
    Begin
      MessageDlg('Mærke kan ikke findes!',mtInformation,[mbOk],0);
      Exit;
    end;
  ZQuery1.First;
  Try
    ZQuery1.Delete;
  Except
    MessageDlg('Kan ikke fjerne mærke!',mtError,[mbOk],0);
    ZQuery1.CancelUpdates;
    Exit;
  End;
  Indlaes;
end;

//**********************************************************
// Stringgrid Editing done
//**********************************************************
procedure TDefMaerkeForm.StringGrid1EditingDone(Sender: TObject);
begin
  GemRowTilTabel;
end;

//**********************************************************
// Stringgrid select editor
//**********************************************************
procedure TDefMaerkeForm.StringGrid1SelectEditor(Sender: TObject; aCol,
  aRow: Integer; var Editor: TWinControl);
begin
  If      aCol = MarkBesk Then
    Begin
      Editor := StringGrid1.EditorByStyle(cbsAuto);
    end;
end;


//**********************************************************
// Indstil
//**********************************************************
procedure TDefMaerkeForm.Indstil;
begin
  Indstil_StringGrid_Edit(StringGrid1);

  StringGrid1.Columns.Clear;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;

  StringGrid1.Columns[MarkId].Title.Caption          := 'Nr';
  StringGrid1.Columns[MarkId].Width                  := 30;
  StringGrid1.Columns[MarkId].Alignment              := taRightJustify;
  StringGrid1.Columns[MarkId].ReadOnly               := True;

  StringGrid1.Columns[MarkBesk].Title.Caption        := 'Beskrivelse';
  StringGrid1.Columns[MarkBesk].Width                := 150;
  StringGrid1.Columns[MarkBesk].Alignment            := taLeftJustify;

end;

//**********************************************************
// Indlæs
//**********************************************************
procedure TDefMaerkeForm.Indlaes;
Var A      : Integer;
    HelpNr : Integer;
Begin
  UpdateGrid := True;
  A := 1;
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from markdef');
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount = 0 Then
    Begin
      StringGrid1.RowCount  := 1;
      MessageDlg('Ingen mærker endnu!',mtInformation,[mbOk],0);
      Exit;
    end;
  ZQuery1.First;
  StringGrid1.RowCount  := 1;
  StringGrid1.BeginUpdate;
  While Not ZQuery1.EOF Do
    Begin
      StringGrid1.RowCount := StringGrid1.RowCount + 1;
      StringGrid1.Cells[MarkId,A]         := ZQuery1.FieldByName('id').AsString;
      StringGrid1.Cells[MarkBesk,A]       := ZQuery1.FieldByName('Beskrivelse').AsString;
      Inc(A);
      ZQuery1.Next;
    end;
  StringGrid1.EndUpdate;
  UpdateGrid := False;
end;


//**********************************************************
// Gem row til tabel
//**********************************************************
procedure TDefMaerkeForm.GemRowTilTabel;
Var HelpNr  : Integer;
    HelpStr : String;
Begin
  If UpdateGrid Then Exit;
  // Find Record
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from markdef where id = ' +
           StringGrid1.Cells[MarkId,StringGrid1.Row]);
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount <> 1 Then
    Begin
      MessageDlg('Mærke kan ikke opdateres ;-)!',mtInformation,[mbOk],0);
      Exit;
    end;
  ZQuery1.First;
  Try
    ZQuery1.Edit;
    ZQuery1.FieldByName('Beskrivelse').AsString := StringGrid1.Cells[MarkBesk,StringGrid1.Row];
    // Id
    ZQuery1.FieldByName('Id').AsString          := StringGrid1.Cells[MarkId,StringGrid1.Row];
    // Gem
    ZQuery1.Post;
    ZQuery1.ApplyUpdates;
  Except
    ZQuery1.CancelUpdates;
    MessageDlg('Aktivitet blev ikke gemt!',mtError,[mbOK],0);
    Exit;
  End;
end;

end.

