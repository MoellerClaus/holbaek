//***************************************************************************//
//  Holbæk                                                                   //
//  Copyright by Claus Moeller 2013-2014                                     //
//  Pris kategori                                                            //
//  Version                                                                  //
//  09.02.14                                                                 //
//***************************************************************************//
unit def_priskategori;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  Grids, Menus, ActnList, ZDataset, StdCtrls;

type

  { TDefPrisKategoriForm }

  TDefPrisKategoriForm = class(TForm)
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
    procedure StringGrid1ButtonClick(Sender: TObject; aCol, aRow: Integer);
    procedure StringGrid1EditingDone(Sender: TObject);
    procedure StringGrid1SelectEditor(Sender: TObject; aCol, aRow: Integer;
      var Editor: TWinControl);
    procedure StringGrid1ValidateEntry(sender: TObject; aCol, aRow: Integer;
      const OldValue: string; var NewValue: String);
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
  DefPrisKategoriForm: TDefPrisKategoriForm;

implementation

{$R *.lfm}

Uses MainData, HolbaekConst, RabatKategori;

Const
  PrisNr         = 0;
  PrisBesk       = 1;
  PrisPris       = 2;
  PrisVis        = 3;
  PrisRabat      = 4;
  PrisId         = 5;

  { TDefPrisKategoriForm }

//**********************************************************
// Create
//**********************************************************
procedure TDefPrisKategoriForm.FormCreate(Sender: TObject);
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
procedure TDefPrisKategoriForm.FormDestroy(Sender: TObject);
begin
end;

//**********************************************************
// Hjælp
//**********************************************************
procedure TDefPrisKategoriForm.HelpExecute(Sender: TObject);
begin
  ShowMessage('Hjælp');
end;


//**********************************************************
// Close
//**********************************************************
procedure TDefPrisKategoriForm.LukExecute(Sender: TObject);
begin
  Close;
end;

//**********************************************************
// Opret
//**********************************************************
procedure TDefPrisKategoriForm.OpretExecute(Sender: TObject);
Var PrisType  : Integer;
begin
  // Indsæt
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from priskategori where afd = ' + CurrentAfd +  ' order by pristype');
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount = 0 Then
    Begin
      PrisType := 1;
    end
  Else
    Begin
      ZQuery1.Last;
      PrisType := ZQuery1.FieldByName('pristype').AsInteger + 1;
    end;
  Try
    ZQuery1.Append;
    ZQuery1.Edit;
    ZQuery1.FieldByName('Afd').AsString           := CurrentAfd;
    ZQuery1.FieldByName('PrisType').AsInteger     := PrisType;
    ZQuery1.FieldByName('Beskrivelse').AsString   := 'Pris';
    ZQuery1.FieldByName('Vis').AsString           := '1';
    ZQuery1.FieldByName('Special').AsString       := '';
    // Gem
    ZQuery1.Post;
    ZQuery1.ApplyUpdates;
  Except
    MessageDlg('Priskategori kunne ikke oprettes!',mtError,[mbOk],0);
    ZQuery1.CancelUpdates;
    Exit;
  end;
  Indlaes;
end;

//**********************************************************
// Slet
//**********************************************************
procedure TDefPrisKategoriForm.SletExecute(Sender: TObject);
begin
  // Find Record
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from aktiviteter where id = ' +
          StringGrid1.Cells[PrisId,StringGrid1.Row]);
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount <> 1 Then
    Begin
      MessageDlg('Priskategori kan ikke findes!',mtInformation,[mbOk],0);
      Exit;
    end;
  ZQuery1.First;
  Try
    ZQuery1.Delete;
  Except
    MessageDlg('Kan ikke fjerne priskategori!',mtError,[mbOk],0);
    ZQuery1.CancelUpdates;
    Exit;
  End;
  Indlaes;
end;

//**********************************************************
// Stringgrid Button click
//**********************************************************
procedure TDefPrisKategoriForm.StringGrid1ButtonClick(Sender: TObject; aCol,
  aRow: Integer);
begin
  If aCol = PrisRabat Then
    Begin
      RabatKategoriForm :=TRabatKategoriForm.Create(Self);
      RabatKategoriForm.PrisType := StrToInt(StringGrid1.Cells[PrisNr,aRow]);
      RabatKategoriForm.LabelPrisKategori.Caption := StringGrid1.Cells[PrisBesk,aRow];
      RabatKategoriForm.IndlaesIGrid;
      RabatKategoriForm.ShowModal;
      RabatKategoriForm.Free;
    end;
end;


//**********************************************************
// Stringgrid Editing done
//**********************************************************
procedure TDefPrisKategoriForm.StringGrid1EditingDone(Sender: TObject);
begin
  GemRowTilTabel;
end;

//**********************************************************
// Stringgrid select editor
//**********************************************************
procedure TDefPrisKategoriForm.StringGrid1SelectEditor(Sender: TObject; aCol,
  aRow: Integer; var Editor: TWinControl);
begin
  If      aCol = PrisBesk Then
    Begin
      Editor := StringGrid1.EditorByStyle(cbsAuto);
    end
  Else If acol = PrisVis Then
    Begin
      Editor := StringGrid1.EditorByStyle(cbsCheckboxColumn);
    end
  Else If acol = PrisPris Then
    Begin
      Editor := StringGrid1.EditorByStyle(cbsAuto);
    end
  Else If acol = PrisRabat Then
    Begin
      Editor := StringGrid1.EditorByStyle(cbsButtonColumn);
    end;
end;

//**********************************************************
// Grid: ValidateEntry
//**********************************************************
procedure TDefPrisKategoriForm.StringGrid1ValidateEntry(sender: TObject; aCol,
  aRow: Integer; const OldValue: string; var NewValue: String);
Var TestStr : String;
    Tal     : Real;
begin
  If      aCol = PrisBesk Then
    Begin
    end
  Else If acol = PrisPris Then
    Begin // Check new value er tal
      Try
        TestStr := NewValue;
        FjernPunktum(TestStr);
        Tal := StrToFloat(TestStr)
      Except
        Raise Exception.Create('Beløb er ikke et tal!');
      End;
    end
end;

//**********************************************************
// Indstil
//**********************************************************
procedure TDefPrisKategoriForm.Indstil;
begin
  Indstil_StringGrid_Edit(StringGrid1);

  StringGrid1.Columns.Clear;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;

  StringGrid1.Columns[PrisNr].Title.Caption          := 'Nr';
  StringGrid1.Columns[PrisNr].Width                  := 30;
  StringGrid1.Columns[PrisNr].Alignment              := taRightJustify;
  StringGrid1.Columns[PrisNr].ReadOnly               := True;

  StringGrid1.Columns[PrisBesk].Title.Caption        := 'Beskrivelse';
  StringGrid1.Columns[PrisBesk].Width                := 150;
  StringGrid1.Columns[PrisBesk].Alignment            := taLeftJustify;

  StringGrid1.Columns[PrisPris].Title.Caption        := 'Pris';
  StringGrid1.Columns[PrisPris].Width                := 80;
  StringGrid1.Columns[PrisPris].Alignment            := taRightJustify;

  StringGrid1.Columns[PrisVis].Title.Caption         := 'Vis';
  StringGrid1.Columns[PrisVis].Width                 := 30;
  StringGrid1.Columns[PrisVis].ButtonStyle           := cbsCheckboxColumn;

  StringGrid1.Columns[PrisRabat].Title.Caption       := 'Rabat';
  StringGrid1.Columns[PrisRabat].Width               := 90;
  StringGrid1.Columns[PrisRabat].Alignment           := taCenter;
  StringGrid1.Columns[PrisRabat].ButtonStyle         := cbsButtonColumn;

  StringGrid1.Columns[PrisId].Title.Caption          := 'Id';
  StringGrid1.Columns[PrisId].Width                  := 70;
  StringGrid1.Columns[PrisId].Visible                := False;
end;

//**********************************************************
// Indlæs
//**********************************************************
procedure TDefPrisKategoriForm.Indlaes;
Var A      : Integer;
    HelpNr : Integer;
Begin
  UpdateGrid := True;
  A := 1;
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from priskategori where Afd = ' + CurrentAfd);
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount = 0 Then
    Begin
      StringGrid1.RowCount  := 1;
      MessageDlg('Ingen priser endnu!',mtInformation,[mbOk],0);
      Exit;
    end;
  ZQuery1.First;
  StringGrid1.RowCount  := 1;
  StringGrid1.BeginUpdate;
  While Not ZQuery1.EOF Do
    Begin
      StringGrid1.RowCount := StringGrid1.RowCount + 1;
      StringGrid1.Cells[PrisNr,A]         := ZQuery1.FieldByName('PrisType').AsString;
      StringGrid1.Cells[PrisBesk,A]       := ZQuery1.FieldByName('Beskrivelse').AsString;
      StringGrid1.Cells[PrisVis,A]        := ZQuery1.FieldByName('Vis').AsString;
      // Pris
      StringGrid1.Cells[PrisPris,A]     :=
         FloatToStrF(ZQuery1.FieldByName('Pris').AsCurrency,ffNumber,18,2);
      // Rabat
      StringGrid1.Cells[PrisRabat,A]      := 'Rabat';
      // Id
      StringGrid1.Cells[PrisId,A]         := ZQuery1.FieldByName('Id').AsString;
      Inc(A);
      ZQuery1.Next;
    end;
  StringGrid1.EndUpdate;
  UpdateGrid := False;
end;


//**********************************************************
// Gem row til tabel
//**********************************************************
procedure TDefPrisKategoriForm.GemRowTilTabel;
Var HelpStr : String;
Begin
  If UpdateGrid Then Exit;
  // Find Record
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from priskategori where id = ' +
           StringGrid1.Cells[PrisId,StringGrid1.Row]);
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount <> 1 Then
    Begin
      MessageDlg('Priskategori kan ikke opdateres ;-)!',mtInformation,[mbOk],0);
      Exit;
    end;
  ZQuery1.First;
  Try
    ZQuery1.Edit;
    ZQuery1.FieldByName('PrisType').AsString    := StringGrid1.Cells[PrisNr,StringGrid1.Row];
    ZQuery1.FieldByName('Beskrivelse').AsString := StringGrid1.Cells[PrisBesk,StringGrid1.Row];
    ZQuery1.FieldByName('Vis').AsString         := StringGrid1.Cells[PrisVis,StringGrid1.Row];
    // Pris
    HelpStr := StringGrid1.Cells[PrisPris,StringGrid1.Row];
    ZQuery1.FieldByName('Pris').AsCurrency     :=
       StrToCurr(FjernPunktum(HelpStr));
    // Id
    ZQuery1.FieldByName('Id').AsString          := StringGrid1.Cells[PrisId,StringGrid1.Row];
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

