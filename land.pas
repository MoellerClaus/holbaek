//***************************************************************************//
//  Holbæk                                                                   //
//  Copyright by Claus Moeller 2013-2016                                     //
//  Land                                                                     //
//  Version                                                                  //
//  18.01.14, 20.12.16                                                       //
//***************************************************************************//
unit land;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  Grids, Menus, ActnList, DbCtrls, clmCombobox, ZDataset, StdCtrls;

type

  { TLandForm }

  TLandForm = class(TForm)
    ActionList1: TActionList;
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
    ZQuery1: TZQuery;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure LukExecute(Sender: TObject);
    procedure OpretExecute(Sender: TObject);
    procedure SletExecute(Sender: TObject);
    procedure StringGrid1EditingDone(Sender: TObject);
    procedure StringGrid1SelectEditor(Sender: TObject; aCol, aRow: Integer;
      var Editor: TWinControl);
    procedure StringGrid1ValidateEntry(sender: TObject; aCol, aRow: Integer;
      const OldValue: string; var NewValue: String);
  private
    { private declarations }
    UpdateGrid : Boolean;
    LandTypeList : TStringList;
    procedure Indstil;
    procedure Indlaes;
    Procedure GemRowTilTabel;
    procedure IndlaesType;
  public
    { public declarations }
  end;

var
  LandForm: TLandForm;

implementation

{$R *.lfm}

Uses HolbaekConst, MainData;

Const
  LandBesk    : Integer = 0;
  LandForKort : Integer = 1;
  LandCifre   : Integer = 2;
  LandType    : Integer = 3;
  LandKode    : Integer = 4;


//**********************************************************
// Create
//**********************************************************
procedure TLandForm.FormCreate(Sender: TObject);
begin
  Position := poDesigned;
  (*Top := 10;
  Left := 30;*)
  // Farver
  ToolBar1.Color    := H_Menu_knapper_Farve;
  StatusBar1.Color  := H_Menu_knapper_Farve;;
  Color             := H_Window_Baggrund;
  // Database
  ZQuery1.Connection := MainData.MainDataModule.ZConnection1;

  // Init
  LandTypeList := TStringList.Create;


  Indstil;
  // Indlaes
  IndlaesType;
  Indlaes;
end;

//**********************************************************
// Close
//**********************************************************
procedure TLandForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  LandTypeList.Free;
  ZQuery1.Close;
  CloseAction := caFree;
end;

//**********************************************************
// Indstil
//**********************************************************
procedure TLandForm.Indstil;
begin
  Indstil_StringGrid_Edit(StringGrid1);

  StringGrid1.Columns.Clear;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;

  StringGrid1.Columns[LandBesk].Title.Caption        := 'Land';
  StringGrid1.Columns[LandBesk].Width                := 150;
  StringGrid1.Columns[LandBesk].Alignment            := taLeftJustify;

  StringGrid1.Columns[LandForKort].Title.Caption     := 'Forkort.';
  StringGrid1.Columns[LandForKort].Width             := 50;
  StringGrid1.Columns[LandForKort].Alignment         := taLeftJustify;

  StringGrid1.Columns[LandCifre].Title.Caption       := 'Cifre';
  StringGrid1.Columns[LandCifre].Width               := 50;
  StringGrid1.Columns[LandCifre].Alignment           := taRightJustify;

  StringGrid1.Columns[LandType].Title.Caption        := 'Type';
  StringGrid1.Columns[LandType].Width                := 100;
  StringGrid1.Columns[LandType].Alignment            := taLeftJustify;

  StringGrid1.Columns[LandKode].Title.Caption        := '*';
  StringGrid1.Columns[LandKode].Width                := 50;
  StringGrid1.Columns[LandKode].Visible              := False;
end;

//**********************************************************
// Luk
//**********************************************************
procedure TLandForm.LukExecute(Sender: TObject);
begin
  Close
end;

//**********************************************************
// Opret
//**********************************************************
procedure TLandForm.OpretExecute(Sender: TObject);
Var HelpNr : Integer;
begin
  // Indsæt
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from land order by landkode');
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount = 0 Then
    Begin
      HelpNr := 1;
    end
  Else
    Begin
      ZQuery1.Last;
      HelpNr := ZQuery1.FieldByName('landkode').AsInteger + 1;
    end;
  Try
    ZQuery1.Append;
    ZQuery1.Edit;
    ZQuery1.FieldByName('LandKode').AsInteger     := HelpNr;
    // Land
    ZQuery1.FieldByName('Land').AsString          := 'Land';
    ZQuery1.FieldByName('LandForKort').AsString   := 'XYZ';
    ZQuery1.FieldByName('Cifre').AsString         := '4';
    ZQuery1.FieldByName('Type').AsString          := '0';
    // Gem
    ZQuery1.Post;
    ZQuery1.ApplyUpdates;
  Except
    MessageDlg('Land kunne ikke oprettes!',mtError,[mbOk],0);
    ZQuery1.CancelUpdates;
    Exit;
  end;
  Indlaes;
end;

//**********************************************************
// Slet
//**********************************************************
procedure TLandForm.SletExecute(Sender: TObject);
begin
  // Find Record
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from land where id = ' +
          StringGrid1.Cells[LandKode,StringGrid1.Row]);
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount <> 1 Then
    Begin
      MessageDlg('Land kan ikke opdateres!',mtInformation,[mbOk],0);
      Exit;
    end;
  ZQuery1.First;
  Try
    ZQuery1.Delete;
  Except
    MessageDlg('Kan ikke fjerne land ;-) !',mtError,[mbOk],0);
    ZQuery1.CancelUpdates;
    Exit;
  End;
  Indlaes;
end;

//**********************************************************
// Grid: Editing done
//**********************************************************
procedure TLandForm.StringGrid1EditingDone(Sender: TObject);
begin
  GemRowTilTabel;
end;

//**********************************************************
// Grid: Select Editor
//**********************************************************
procedure TLandForm.StringGrid1SelectEditor(Sender: TObject; aCol,
  aRow: Integer; var Editor: TWinControl);
begin
  If      aCol = LandBesk Then
    Begin
      Editor := StringGrid1.EditorByStyle(cbsAuto);
    end
  Else If acol = LandForkort Then
    Begin
      Editor := StringGrid1.EditorByStyle(cbsAuto);
    end
  Else If acol = LandCifre Then
    Begin
      Editor := StringGrid1.EditorByStyle(cbsAuto);
    end
  Else If acol = LandType Then
    Begin
      Editor := StringGrid1.EditorByStyle(cbsPickList);
      TCustomComboBox(Editor).Items.Clear;
      TCustomComboBox(Editor).Items.AddStrings(LandTypeList);
      TCustomComboBox(Editor).Style := csDropDownList;
    end;
end;

//**********************************************************
// Grid: Validate entry
//**********************************************************
procedure TLandForm.StringGrid1ValidateEntry(sender: TObject; aCol,
  aRow: Integer; const OldValue: string; var NewValue: String);
Var Help40 : String[40];
    Help3  : String[3];
    Tal    : Integer;
    TestStr: String;
begin
  If      aCol = LandBesk Then
    Begin // Bogstaver
      If Length(NewValue) > 39 Then
        Begin
          Help40 := NewValue;
          NewValue := Help40;
        End;
    end
  Else If acol = LandForkort Then
    Begin
      If Length(NewValue) > 3 Then
        Begin
          Help3 := NewValue;
          NewValue := Help3;
        End;
    end
  Else If acol = LandCifre Then
    Begin
      Try
        Tal := StrToInt(NewValue);
      Except
        Raise Exception.Create('Cifre er ikke et tal!');
      End;
    end
  Else If acol = LandType Then
    Begin
      // NewValue := LnIntToStr(TCustomComboBox(StringGrid1.Editor).ItemIndex);
    end
end;

//**********************************************************
// Indlaes
//**********************************************************
procedure TLandForm.Indlaes;
Var A : Integer;
Begin
  UpdateGrid := True;
  A                     := 1;
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from land'); //kassekladdedef where Afd = ' + CurrentAfd);
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount = 0 Then
    Begin
      StringGrid1.RowCount  := 1;
      MessageDlg('Intet land endnu!',mtInformation,[mbOk],0);
      Exit;
    end;
  ZQuery1.First;
  StringGrid1.RowCount  := 1;
  StringGrid1.BeginUpdate;
  While Not ZQuery1.EOF Do
    Begin
      StringGrid1.RowCount := StringGrid1.RowCount + 1;
      StringGrid1.Cells[LandBesk,A]    := ZQuery1.FieldByName('Land').AsString;
      StringGrid1.Cells[LandForKort,A] := ZQuery1.FieldByName('LandForKort').AsString;
      StringGrid1.Cells[LandCifre,A]   := ZQuery1.FieldByName('Cifre').AsString;
      StringGrid1.Cells[LandType,A]    := LandTypeList.Strings[ZQuery1.FieldByName('Type').AsInteger];
      StringGrid1.Cells[LandKode,A]    := ZQuery1.FieldByName('LandKode').AsString;
      Inc(A);
      ZQuery1.Next;
    end;
  StringGrid1.EndUpdate;
  UpdateGrid := False;
end;


//**********************************************************
// Gem row til tabel
//**********************************************************
Procedure TLandForm.GemRowTilTabel;
Begin
  If UpdateGrid Then Exit;
  // Find Record
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from land where landkode = ' +
           StringGrid1.Cells[LandKode,StringGrid1.Row]);
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount <> 1 Then
    Begin
      MessageDlg('Land kan ikke opdateres ;-)!',mtInformation,[mbOk],0);
      Exit;
    end;
  ZQuery1.First;
  Try
    ZQuery1.Edit;
    // Land
    ZQuery1.FieldByName('Land').AsString          :=
      StringGrid1.Cells[LandBesk,StringGrid1.Row];
    // Forkortelse
    ZQuery1.FieldByName('LandForkort').AsString       :=
      StringGrid1.Cells[LandForKort,StringGrid1.Row];
    // Cifre
    ZQuery1.FieldByName('Cifre').AsString       :=
      StringGrid1.Cells[LandCifre,StringGrid1.Row];
    // Type
    ZQuery1.FieldByName('Type').AsInteger       :=
      LandTypeList.IndexOf(StringGrid1.Cells[LandType,StringGrid1.Row]);
    // Gem
    ZQuery1.Post;
    ZQuery1.ApplyUpdates;
  Except
    ZQuery1.CancelUpdates;
    MessageDlg('Land blev ikke gemt!',mtError,[mbOK],0);
    Exit;
  End
End;

//**********************************************************
// IndlaesType
//**********************************************************
Procedure TLandForm.IndlaesType;
Begin
//  LandTypeList.Clear;
  LandTypeList.Add('Ingen 9');
  LandTypeList.Add('0 foran');
end;

end.

