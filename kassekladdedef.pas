//***************************************************************************//
//  Holbæk                                                                   //
//  Copyright by Claus Moeller 2013-2016                                     //
//  Kassekladde definition                                                   //
//  Version                                                                  //
//  02.11.16                                                                 //
//***************************************************************************//
unit kassekladdedef;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  ActnList, Menus, Grids, ZDataset;

type

  { TKassekladdeDefForm }

  TKassekladdeDefForm = class(TForm)
    ActionList1: TActionList;
    Help: TAction;
    Luk: TAction;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
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
  KassekladdeDefForm: TKassekladdeDefForm;

implementation

Uses HolbaekConst, MainData;

Const
  KasBesk      : Integer = 0;
  KasToemmes   : Integer = 1;
  KasNr        : Integer = 2;

  {$R *.lfm}

{ TKassekladdeDefForm }


//**********************************************************
// Create
//**********************************************************
procedure TKassekladdeDefForm.FormCreate(Sender: TObject);
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
procedure TKassekladdeDefForm.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  ZQuery1.Close;
  CloseAction := caFree;
end;

//**********************************************************
// Gem row til tabel
//**********************************************************
Procedure TKassekladdeDefForm.GemRowTilTabel;
Var Stop : Boolean;
Begin
  If UpdateGrid Then Exit;
  // Find Record
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from kassekladdedef where Afd = ' + CurrentAfd +
          ' and nr = ' + StringGrid1.Cells[KasNr,StringGrid1.Row]);
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount <> 1 Then
    Begin
      MessageDlg('Kassekladde definition kan ikke opdateres!',mtInformation,[mbOk],0);
      Exit;
    end;
  ZQuery1.First;
  Try
    ZQuery1.Edit;
    // Toemmes
    ZQuery1.FieldByName('Toemmes').AsString       :=
      StringGrid1.Cells[KasToemmes,StringGrid1.Row];
    // Beskrivelse 40 tegn
    ZQuery1.FieldByName('Beskrivelse').AsString   :=
      StringGrid1.Cells[KasBesk,StringGrid1.Row];
    // Gem
    ZQuery1.Post;
    ZQuery1.ApplyUpdates;
  Except
    ZQuery1.CancelUpdates;
    MessageDlg('Kassekladde definition blev ikke gemt!',mtError,[mbOK],0);
    Exit;
  End
End;

//**********************************************************
// Destroy
//**********************************************************
procedure TKassekladdeDefForm.FormDestroy(Sender: TObject);
begin
end;

//**********************************************************
// Hjælp
//**********************************************************
procedure TKassekladdeDefForm.HelpExecute(Sender: TObject);
begin
  ShowMessage('Hjælp');
end;

//**********************************************************
// Luk
//**********************************************************
procedure TKassekladdeDefForm.LukExecute(Sender: TObject);
begin
  Close;
end;

//**********************************************************
// Opret
//**********************************************************
procedure TKassekladdeDefForm.OpretExecute(Sender: TObject);
begin
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from kassekladdedef');
    End;
  ZQuery1.Open;
  Try
    ZQuery1.Append;
    ZQuery1.Edit;
    ZQuery1.FieldByName('Afd').AsString           := CurrentAfd;
    // Tømmes
    ZQuery1.FieldByName('Toemmes').AsString       := '1';
    // Beskrivelse 40 tegn
    ZQuery1.FieldByName('Beskrivelse').AsString   := 'Kassekladde x';
    // Gem
    ZQuery1.Post;
    ZQuery1.ApplyUpdates;
  Except
    MessageDlg('Kassekladde definition kunne ikke oprettes!',mtError,[mbOk],0);
    ZQuery1.CancelUpdates;
    Exit;
  end;
  Indlaes;
end;

//**********************************************************
// Slet
//**********************************************************
procedure TKassekladdeDefForm.SletExecute(Sender: TObject);
Var Stop : Boolean;
begin
  If StringGrid1.RowCount = 2 Then
    Begin
      MessageDlg('Der skal min. være defineret en kassekladde!',mtInformation,[mbOk],0);
      Exit;
    end;
  // Find Record
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from kassekladdedef where Afd = ' + CurrentAfd +
          ' and nr = ' + StringGrid1.Cells[KasNr,StringGrid1.Row]);
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount <> 1 Then
    Begin
      MessageDlg('Kassekladde kan ikke opdateres!',mtInformation,[mbOk],0);
      Exit;
    end;
  ZQuery1.First;
  { TODO : Check om momskode kan fjernes }
  Try
    ZQuery1.Delete;
  Except
    MessageDlg('Kan ikke fjerne kassekladde!',mtError,[mbOk],0);
    ZQuery1.CancelUpdates;
    Exit;
  End;
  Indlaes;
end;

//**********************************************************
// Stringgrid CompareCells
//**********************************************************
procedure TKassekladdeDefForm.StringGrid1CompareCells(Sender: TObject; ACol, ARow,
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
procedure TKassekladdeDefForm.StringGrid1EditingDone(Sender: TObject);
begin
  GemRowTilTabel;
end;

//**********************************************************
// StringGrid Select editor
//**********************************************************
procedure TKassekladdeDefForm.StringGrid1SelectEditor(Sender: TObject; aCol,
  aRow: Integer; var Editor: TWinControl);
begin
  If  aCol = KasBesk Then
    Begin
      Editor := StringGrid1.EditorByStyle(cbsAuto);
    end
  Else If acol = KasToemmes Then
    Begin
      Editor := StringGrid1.EditorByStyle(cbsCheckboxColumn);
    end;
end;

//**********************************************************
// StringGrid Validate entry
//**********************************************************
procedure TKassekladdeDefForm.StringGrid1ValidateEntry(sender: TObject; aCol,
  aRow: Integer; const OldValue: string; var NewValue: String);
Var HelpInt : Integer;
    Code    : Word;
begin
  If      aCol = KasBesk Then
    Begin
    end
  Else If acol = KasToemmes Then
    Begin // Check new value er tal
    end
end;


//**********************************************************
// Indstil
//**********************************************************
procedure TKassekladdeDefForm.Indstil;
begin
  Indstil_StringGrid_Edit(StringGrid1);

  StringGrid1.Columns.Clear;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;

  StringGrid1.Columns[KasBesk].Title.Caption        := 'Beskrivelse';
  StringGrid1.Columns[KasBesk].Width                := 150;
  StringGrid1.Columns[KasBesk].Alignment            := taLeftJustify;

  StringGrid1.Columns[KasToemmes].Title.Caption     := 'Tømmes';
  StringGrid1.Columns[KasToemmes].Width             := 80;
  StringGrid1.Columns[KasToemmes].ButtonStyle       := cbsCheckboxColumn;
  StringGrid1.Columns[KasToemmes].ValueChecked      := '1';
  StringGrid1.Columns[KasToemmes].ValueUnchecked    := '0';

  StringGrid1.Columns[KasNr].Title.Caption          := 'Id';
  StringGrid1.Columns[KasNr].Width                  := 50;
  StringGrid1.Columns[KasNr].Visible                := False;

End;

//**********************************************************
// Indlæs
//**********************************************************
Procedure TKassekladdeDefForm.Indlaes;
Var A : Integer;
Begin
  UpdateGrid := True;
  A                     := 1;
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from kassekladdedef where Afd = ' + CurrentAfd);
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount = 0 Then
    Begin
      StringGrid1.RowCount  := 1;
      MessageDlg('Ingen kassekladder endnu!',mtInformation,[mbOk],0);
      Exit;
    end;
  ZQuery1.First;
  StringGrid1.RowCount  := 1;
  StringGrid1.BeginUpdate;
  While Not ZQuery1.EOF Do
    Begin
      StringGrid1.RowCount := StringGrid1.RowCount + 1;
      StringGrid1.Cells[KasBesk,A]         := ZQuery1.FieldByName('Beskrivelse').AsString;
      StringGrid1.Cells[KasToemmes,A]      := ZQuery1.FieldByName('Toemmes').AsString;
      StringGrid1.Cells[KasNr,A]           := ZQuery1.FieldByName('Nr').AsString;
      Inc(A);
      ZQuery1.Next;
    end;
  StringGrid1.EndUpdate;
  UpdateGrid := False;
end;


end.

