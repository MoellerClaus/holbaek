//***************************************************************************//
//  Holbæk                                                                   //
//  Copyright by Claus Moeller 2013-2014                                     //
//  Rabat kategori form                                                      //
//  Version                                                                  //
//  20.11.14                                                                 //
//***************************************************************************//
unit RabatKategori;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  Grids, Menus, ActnList, ExtCtrls, StdCtrls, ZDataset;

type

  { TRabatKategoriForm }

  TRabatKategoriForm = class(TForm)
    ActionList1: TActionList;
    Help: TAction;
    ImageList1: TImageList;
    Label1: TLabel;
    LabelPrisKategori: TLabel;
    Luk: TAction;
    MenuItem1: TMenuItem;
    Panel1: TPanel;
    PopupMenu1: TPopupMenu;
    StatusBar1: TStatusBar;
    StringGrid1: TStringGrid;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton6: TToolButton;
    ZQuery1: TZQuery;
    ZQueryRabatKategori: TZQuery;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure LukExecute(Sender: TObject);
    procedure StringGrid1CheckboxToggled(sender: TObject; aCol, aRow: Integer;
      aState: TCheckboxState);
    procedure StringGrid1EditingDone(Sender: TObject);
    procedure StringGrid1SelectEditor(Sender: TObject; aCol, aRow: Integer;
      var Editor: TWinControl);
  private
    { private declarations }
    procedure Indstil;
  public
    { public declarations }
    PrisType : Integer;
    procedure IndlaesIGrid;
  end;

var
  RabatKategoriForm: TRabatKategoriForm;

implementation

uses HolbaekConst, HolbaekMain, RabatDef;

{$R *.lfm}

Const
  RBVis      : Integer = 0;
  RBBesk     : Integer = 1;
  RBNr       : Integer = 2;

{ TRabatKategoriForm }

//**********************************************************
// Create
//**********************************************************
procedure TRabatKategoriForm.FormCreate(Sender: TObject);
begin
  Top  := 80;
  Left := 5;
  // Database
//  ZQuery1.Connection                            := MainForm.ZConnection1;
//  ZQueryRabatKategori.Connection                := MainForm.ZConnection1;

  // Indstillinger
  Indstil;
  StringGrid1.RowCount := 1;
  // Grid
//  IndlaesIGrid;
  // Hints
  //ShowHint := Options_Generelt_VisHints;
end;

//**********************************************************
// Close
//**********************************************************
procedure TRabatKategoriForm.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  CloseAction := CAFree;
end;


//**********************************************************
// Destroy
//**********************************************************
procedure TRabatKategoriForm.FormDestroy(Sender: TObject);
begin
  RabatKategoriForm := Nil;
end;


//**********************************************************
// Luk
//**********************************************************
procedure TRabatKategoriForm.LukExecute(Sender: TObject);
begin
  Close
end;

//**********************************************************
// StringGrid: Checkbox toggled
//**********************************************************
procedure TRabatKategoriForm.StringGrid1CheckboxToggled(sender: TObject; aCol,
  aRow: Integer; aState: TCheckboxState);
Var Nr : Real;
begin
  // Nu skal ændringer gemmes
  If ACol = RBVis Then
    Begin
      With ZQueryRabatKategori.SQL do
        Begin
          Clear;
          Add('Select * from RabatKategori where (Afd = ' + CurrentAfd +
          ') and (Nr = ' + StringGrid1.Cells[RBNr,aRow] +
          ') and (PrisType = ' + IntToStr(PrisType) + ')');
        End;
      ZQueryRabatKategori.Open;
      If ZQueryRabatKategori.RecordCount = 0 Then
        Begin
          If aState = cbChecked Then
            Begin // Indsæt record
              With ZQuery1.SQL do
                Begin
                  Clear;
                  Add('Select * from RabatKategori order by id');
                end;
              ZQuery1.Open;
              If ZQuery1.RecordCount = 0 Then
                Begin
                  Nr :=1;
                End
              Else
                Begin
                  ZQuery1.Last;
                  Nr := ZQuery1.FieldByName('Id').AsFloat + 1;
                End;
             Try
               ZQuery1.Append;
               ZQuery1.FieldByName('id').AsFloat        := Nr;
               ZQuery1.FieldByName('Afd').AsString      := CurrentAfd;
               ZQuery1.FieldByName('PrisType').AsInteger:= PrisType;
               ZQuery1.FieldByName('Nr').AsString       :=
                 StringGrid1.Cells[RBNr,aRow];
               ZQuery1.Post;
             Except
               MessageDlg('Rabatkategori kunne ikke opdateres',mtError,[mbOk],0);
               ZQuery1.Cancel;
               Exit;
             end;
            End;
        End
      Else If aState = cbUnChecked Then
        Begin // Fjern record
          Try
            ZQueryRabatKategori.Delete;
          Except
            MessageDlg('Kunne ikke slettes!',mtInformation,[mbOk],0);
            Exit;
          End;
        End;
    end;
end;

//**********************************************************
// StringGrid: Editing done
//**********************************************************
procedure TRabatKategoriForm.StringGrid1EditingDone(Sender: TObject);
Begin
end;

//**********************************************************
// StringGrid: Editor select
//**********************************************************
procedure TRabatKategoriForm.StringGrid1SelectEditor(Sender: TObject; aCol,
  aRow: Integer; var Editor: TWinControl);
begin
  If      aCol = RBBesk Then
    Begin
      Editor := StringGrid1.EditorByStyle(cbsAuto);
    end
  Else If acol = RBVis Then
    Begin
      Editor := StringGrid1.EditorByStyle(cbsCheckboxColumn);
    end
end;


//**********************************************************
// Indstil
//**********************************************************
procedure TRabatKategoriForm.Indstil;

Begin
  Indstil_StringGrid_Edit(StringGrid1);

  StringGrid1.Columns.Clear;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;

  StringGrid1.Columns[RBVis].Title.Caption          := 'Rabat';
  StringGrid1.Columns[RBVis].Width                  := 50;
  StringGrid1.Columns[RBVis].ButtonStyle           := cbsCheckboxColumn;
  StringGrid1.Columns[RBVis].Alignment              := taCenter;

  StringGrid1.Columns[RBBesk].Title.Caption         := 'Beskrivelse';
  StringGrid1.Columns[RBBesk].Width                 := 200;
  StringGrid1.Columns[RBBesk].Alignment             := taLeftJustify;
  StringGrid1.Columns[RBBesk].ReadOnly              := True;

  StringGrid1.Columns[RBNr].Title.Caption           := 'Nr';
  StringGrid1.Columns[RBNr].Width                   := 80;
  StringGrid1.Columns[RBNr].Alignment               := taRightJustify;
  StringGrid1.Columns[RBNr].Visible                 := False;
end;

//**********************************************************
// Indlæs i Grid
//**********************************************************
procedure TRabatKategoriForm.IndlaesIGrid;
Var A : Integer;
begin
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from RabatDef where Afd = ' + CurrentAfd);
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount = 0 Then
    Begin
      StringGrid1.RowCount  := 1;
      MessageDlg('Ingen rabatter defineret endnu!',mtInformation,[mbOk],0);
      Exit;
    end;
  ZQuery1.First;
  StringGrid1.RowCount  := 1;
  A := 1;
  While Not ZQuery1.EOF do
    Begin
      // Filter er sat på current Afd
      With StringGrid1 Do
        Begin
          StringGrid1.RowCount := StringGrid1.RowCount + 1;
          Cells[RBNr,A] := ZQuery1.FieldByName('Id').AsString;
          Cells[RBBesk,A] := ZQuery1.FieldByName('Beskrivelse').AsString;
          // Check om rabat er med
          With ZQueryRabatKategori.SQL do
            Begin
              Clear;
              Add('Select * from RabatKategori where (Afd = ' + CurrentAfd +
              ') and (PrisType = ' + IntToStr(PrisType) +
              ') and (Nr = ' + ZQuery1.FieldByName('Id').AsString + ')');
            End;
          ZQueryRabatKategori.Open;
          If ZQueryRabatKategori.RecordCount = 0 Then
            Begin // Ingen Check
              Cells[RBVis,A] := '0';
            End
          Else
            Begin // Checked
              Cells[RBVis,A] := '1';
            End;
          Inc(A);
        End;
      ZQuery1.Next;
    End;
  StringGrid1.Col := RBBesk;
End;





end.

