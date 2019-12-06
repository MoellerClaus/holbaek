//***************************************************************************//
//  Holbæk                                                                   //
//  Copyright by Claus Moeller 2013-2016                                     //
//  Definition af økomærker                                                  //
//  Version                                                                  //
//  10.11.14, 10-12-2016                                                     //
//***************************************************************************//
unit okomaerke;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  Grids, Menus, ActnList, ZDataset;

type

  { TOkoMaerkeForm }

  TOkoMaerkeForm = class(TForm)
    ActionList1: TActionList;
    Help: TAction;
    ImageList1: TImageList;
    Luk: TAction;
    MenuItem1: TMenuItem;
    Opret: TAction;
    PopupMenu1: TPopupMenu;
    Slet: TAction;
    StringGrid1: TStringGrid;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ZQuery1: TZQuery;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure HelpExecute(Sender: TObject);
    procedure LukExecute(Sender: TObject);
    procedure OpretExecute(Sender: TObject);
    procedure SletExecute(Sender: TObject);
    procedure StringGrid1CompareCells(Sender: TObject; ACol, ARow, BCol,
      BRow: Integer; var Result: integer);
    procedure StringGrid1EditingDone(Sender: TObject);
    procedure StringGrid1SelectEditor(Sender: TObject; aCol, aRow: Integer;
      var Editor: TWinControl);
    procedure StringGrid1ValidateEntry(sender: TObject; aCol, aRow: Integer;
      const OldValue: string; var NewValue: String);
  private
    { private declarations }
    UpdateGrid : Boolean;
    Procedure GemRowTilTabel;
    Procedure Indstil;
    Procedure Indlaes;
  public
    { public declarations }
  end;

var
  OkoMaerkeForm: TOkoMaerkeForm;

implementation

{$R *.lfm}

Uses HolbaekConst, MainData;

Const
  OkoBesk      : Integer = 0;
  OkoNr        : Integer = 1;

//**********************************************************
// Create
//**********************************************************
procedure TOkoMaerkeForm.FormCreate(Sender: TObject);
begin
  Position := poDesigned;
  (*Top := 10;
  Left := 30;*)
  // Farver
  ToolBar1.Color    := H_Menu_knapper_Farve;
//  StatusBar1.Color  := H_Menu_knapper_Farve;;
  Color             := H_Window_Baggrund;
  // Database
  ZQuery1.Connection := MainDataModule.ZConnection1;
  // Init
  Indstil;
  Indlaes;
  // Andet

end;

//**********************************************************
// Form close
//**********************************************************
procedure TOkoMaerkeForm.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  ZQuery1.Close;
  CloseAction := caFree;
end;

//**********************************************************
// Gem row til tabel
//**********************************************************
Procedure TOkoMaerkeForm.GemRowTilTabel;
Var Stop : Boolean;
Begin
  If UpdateGrid Then Exit;
  // Find Record
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from OkoMaerkeDef where Afd = ' + CurrentAfd +
          ' and nr = ' + StringGrid1.Cells[OkoNr,StringGrid1.Row]);
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount <> 1 Then
    Begin
      MessageDlg('Økomærke kan ikke opdateres!',mtInformation,[mbOk],0);
      Exit;
    end;
  ZQuery1.First;
  Try
    ZQuery1.Edit;
    // Beskrivelse
    ZQuery1.FieldByName('Beskrivelse').AsString          :=
      StringGrid1.Cells[OkoBesk,StringGrid1.Row];
    // Nr
    ZQuery1.FieldByName('Nr').AsString       :=
      StringGrid1.Cells[OkoNr,StringGrid1.Row];
    // Gem
    ZQuery1.Post;
    ZQuery1.ApplyUpdates;
  Except
    ZQuery1.CancelUpdates;
    MessageDlg('Økomærke blev ikke gemt!',mtError,[mbOK],0);
    Exit;
  End
End;

//**********************************************************
// Destroy
//**********************************************************
procedure TOkoMaerkeForm.FormDestroy(Sender: TObject);
begin
end;

//**********************************************************
// Hjælp
//**********************************************************
procedure TOkoMaerkeForm.HelpExecute(Sender: TObject);
begin
  ShowMessage('Hjælp');
end;

//**********************************************************
// Luk
//**********************************************************
procedure TOkoMaerkeForm.LukExecute(Sender: TObject);
begin
  Close;
end;

//**********************************************************
// Opret
//**********************************************************
procedure TOkoMaerkeForm.OpretExecute(Sender: TObject);
begin
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from OkomaerkeDef');
    End;
  ZQuery1.Open;
  Try
    ZQuery1.Append;
    ZQuery1.Edit;
    ZQuery1.FieldByName('Afd').AsString           := CurrentAfd;
    // Beskrivelse 40 tegn
    ZQuery1.FieldByName('Beskrivelse').AsString   := 'Økomærke beskrivelse';
    // Gem
    ZQuery1.Post;
    ZQuery1.ApplyUpdates;
  Except
    MessageDlg('Økomærke kunne ikke oprettes!',mtError,[mbOk],0);
    ZQuery1.CancelUpdates;
    Exit;
  end;
  Indlaes;
end;

//**********************************************************
// Slet
//**********************************************************
procedure TOkoMaerkeForm.SletExecute(Sender: TObject);
Var Stop : Boolean;
begin
  // Find Record
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from OkomaerkeDef where Afd = ' + CurrentAfd +
          ' and nr = ' + StringGrid1.Cells[OkoNr,StringGrid1.Row]);
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount <> 1 Then
    Begin
      MessageDlg('Økomærke kan ikke opdateres!',mtInformation,[mbOk],0);
      Exit;
    end;
  ZQuery1.First;
  { TODO : Check om momskode kan fjernes }
  Try
    ZQuery1.Delete;
  Except
    MessageDlg('Kan ikke fjerne økomærke!',mtError,[mbOk],0);
    ZQuery1.CancelUpdates;
    Exit;
  End;
  Indlaes;
end;

//**********************************************************
// Stringgrid CompareCells
//**********************************************************
procedure TOkoMaerkeForm.StringGrid1CompareCells(Sender: TObject; ACol, ARow,
  BCol, BRow: Integer; var Result: integer);
begin
(*  If ACol = MomsProcent Then
    Begin // Sorter integer
      Result := StrToIntDef(StringGrid1.Cells[ACol,ARow],0) - StrToIntDef(StringGrid1.Cells[BCol,BRow],0);
      If StringGrid1.SortOrder = soDescending Then
        Begin
          Result := -Result;
        end;
    end;*)
end;

//**********************************************************
// StringGrid Editing done
//**********************************************************
procedure TOkoMaerkeForm.StringGrid1EditingDone(Sender: TObject);
begin
  GemRowTilTabel;
end;

//**********************************************************
// StringGrid Select editor
//**********************************************************
procedure TOkoMaerkeForm.StringGrid1SelectEditor(Sender: TObject; aCol,
  aRow: Integer; var Editor: TWinControl);
begin
  If      aCol = OkoBesk Then
    Begin
      Editor := StringGrid1.EditorByStyle(cbsAuto);
    end
end;

//**********************************************************
// StringGrid Validate entry
//**********************************************************
procedure TOkoMaerkeForm.StringGrid1ValidateEntry(sender: TObject; aCol,
  aRow: Integer; const OldValue: string; var NewValue: String);
begin
end;


//**********************************************************
// Indstil
//**********************************************************
procedure TOkoMaerkeForm.Indstil;
begin
  Indstil_StringGrid_Edit(StringGrid1);

  StringGrid1.Columns.Clear;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;

  StringGrid1.Columns[OkoBesk].Title.Caption        := 'Beskrivelse';
  StringGrid1.Columns[OkoBesk].Width                := 150;
  StringGrid1.Columns[OkoBesk].Alignment            := taLeftJustify;

  StringGrid1.Columns[OkoNr].Title.Caption          := 'Id';
  StringGrid1.Columns[OkoNr].Width                  := 50;
  StringGrid1.Columns[OkoNr].Visible                := False;

End;

//**********************************************************
// Indlæs
//**********************************************************
Procedure TOkoMaerkeForm.Indlaes;
Var A : Integer;
    HelpNr : Integer;
Begin
  UpdateGrid := True;
  A                     := 1;
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from OkoMaerkeDef where Afd = ' + CurrentAfd);
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount = 0 Then
    Begin
      StringGrid1.RowCount  := 1;
      MessageDlg('Ingen økomærker endnu!',mtInformation,[mbOk],0);
      Exit;
    end;
  ZQuery1.First;
  StringGrid1.RowCount  := 1;
  StringGrid1.BeginUpdate;
  While Not ZQuery1.EOF Do
    Begin
      StringGrid1.RowCount := StringGrid1.RowCount + 1;
      StringGrid1.Cells[OkoBesk,A]        := ZQuery1.FieldByName('Beskrivelse').AsString;
      StringGrid1.Cells[OkoNr,A]          := ZQuery1.FieldByName('Nr').AsString;
      Inc(A);
      ZQuery1.Next;
    end;
  StringGrid1.EndUpdate;
  UpdateGrid := False;
end;






end.

