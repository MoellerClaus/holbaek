//***************************************************************************//
//  Holbæk                                                                   //
//  Copyright by Claus Moeller 2013-2016                                     //
//  Pickkonto                                                                //
//  Afstemning                                                               //
//  11.12.16                                                                 //
//***************************************************************************//
unit PickKonto;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  Menus, ActnList, Grids, ZDataset;

type

  { TPickKontoForm }

  TPickKontoForm = class(TForm)
    ActionList1: TActionList;
    Help: TAction;
    Luk: TAction;
    MenuItem1: TMenuItem;
    StringGrid1: TStringGrid;
    Vaelg: TAction;
    PopupMenu1: TPopupMenu;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ZQuery1: TZQuery;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure HelpExecute(Sender: TObject);
    procedure LukExecute(Sender: TObject);
    procedure StringGrid1CompareCells(Sender: TObject; ACol, ARow, BCol,
      BRow: Integer; var Result: integer);
    procedure StringGrid1DblClick(Sender: TObject);
    procedure VaelgExecute(Sender: TObject);
  private
    { private declarations }
    Procedure IndstilGrid;
  public
    { public declarations }
    Valgt : String;
    Afstemningskonti : Boolean;
    Procedure IndlaesKonti;
  end;

var
  PickKontoForm: TPickKontoForm;

implementation

{$R *.lfm}

Uses HolbaekConst, MainData, kassekladde;

{ TPickKontoForm }

//**********************************************************
// Create
//**********************************************************
procedure TPickKontoForm.FormCreate(Sender: TObject);
begin
  // Farver
  Position := poDesigned;
  (*Top := 10;
  Left := 30;*)
  // Farver
  ToolBar1.Color    := H_Menu_knapper_Farve;
  Color             := H_Window_Baggrund;
  StringGrid1.Color := H_Grid_BackColor;
  // Database
  ZQuery1.Connection  := MainDataModule.ZConnection1;
  // Init
  Afstemningskonti  := False;
  Valgt := '';
  IndstilGrid;
  IndlaesKonti;
end;

//**********************************************************
// Form close
//**********************************************************
procedure TPickKontoForm.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  ZQuery1.Close;
  CloseAction := caFree;
end;

//**********************************************************
// Hjælp
//**********************************************************
procedure TPickKontoForm.HelpExecute(Sender: TObject);
begin
  ShowMessage('Help');
end;

//**********************************************************
// Luk
//**********************************************************
procedure TPickKontoForm.LukExecute(Sender: TObject);
begin
  ModalResult := mrClose;
end;

//**********************************************************
// StringGrid: Compare cells
//**********************************************************
procedure TPickKontoForm.StringGrid1CompareCells(Sender: TObject; ACol, ARow,
  BCol, BRow: Integer; var Result: integer);
begin
  If ACol = 0 Then
    Begin // Sorter integer
      Result := StrToIntDef(StringGrid1.Cells[ACol,ARow],0) - StrToIntDef(StringGrid1.Cells[BCol,BRow],0);
      If StringGrid1.SortOrder = soDescending Then
        Begin
          Result := -Result;
        end;
    end;

end;

//**********************************************************
// StringGrid: Double click
//**********************************************************
procedure TPickKontoForm.StringGrid1DblClick(Sender: TObject);
begin
  // Vælg
  Valgt := StringGrid1.Cells[0,StringGrid1.Row];
  ModalResult := mrOk;
end;

//**********************************************************
// Vælg
//**********************************************************
procedure TPickKontoForm.VaelgExecute(Sender: TObject);
begin
  Valgt := StringGrid1.Cells[0,StringGrid1.Row];
  ModalResult := mrOk;
end;

//**********************************************************
// Indlæs til Grid
//**********************************************************
Procedure TPickKontoForm.IndSTILGrid;

Begin
  StringGrid1.Columns.Clear;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;
  StringGrid1.Columns[0].Title.Caption := 'Kontonr';
  StringGrid1.Columns[0].Width         := 50;
  StringGrid1.Columns[0].Alignment     := taRightJustify;
  StringGrid1.Columns[1].Title.Caption := 'Beskrivelse';
  StringGrid1.Columns[1].Width         := 200;
  StringGrid1.Columns[1].Alignment     := taLeftJustify;
  StringGrid1.Columns[2].Title.Caption := 'Id';
  StringGrid1.Columns[2].Width         := 50;
  StringGrid1.Columns[2].Visible       := False;
end;

//**********************************************************
// Indlæs konto
//**********************************************************
Procedure TPickKontoForm.IndlaesKonti;
Var A : Integer;
Begin
  If AfstemningsKonti Then
    Begin
      Try
        With ZQuery1.SQL do
          Begin
            Clear;
            Add('Select * from Afstemningskonti where Afd = ' + CurrentAfd);
          End;
        ZQuery1.Open;
        StringGrid1.RowCount     := 1;
        A := 1;
        While not ZQuery1.EOF Do
          Begin
            StringGrid1.RowCount     := StringGrid1.RowCount + 1;
            StringGrid1.Cells[0,A]   := ZQuery1.FieldByName('BrugerKonto').AsString;
            StringGrid1.Cells[1,A]   :=
              KassekladdeForm.FindKontoBeskrivelse(ZQuery1.FieldByName('BrugerKonto').AsString);
            StringGrid1.Cells[2,A]   :=
              KassekladdeForm.FindKontoFraBruger(ZQuery1.FieldByName('BrugerKonto').AsString);
            //StringGrid1.Cells[1,A]   := ZQuery1.FieldByName('Beskrivelse').AsString;
            //StringGrid1.Cells[2,A]   := ZQuery1.FieldByName('Id').AsString;
            ZQuery1.Next;
            Inc(A);
          end;
        StringGrid1.SortColRow(True,0);
        StringGrid1.Row := 0;
      Except
      end;
    end
  Else
    Begin
      Try
        With ZQuery1.SQL do
          Begin
            Clear;
            Add('Select * from kontobes where Afd = ' + CurrentAfd);
          End;
        ZQuery1.Open;
        StringGrid1.RowCount     := 1;
        A := 1;
        While not ZQuery1.EOF Do
          Begin
            StringGrid1.RowCount     := StringGrid1.RowCount + 1;
            StringGrid1.Cells[0,A]   := ZQuery1.FieldByName('BrugerKonto').AsString;
            StringGrid1.Cells[1,A]   := ZQuery1.FieldByName('Beskrivelse').AsString;
            StringGrid1.Cells[2,A]   := ZQuery1.FieldByName('Id').AsString;
            ZQuery1.Next;
            Inc(A);
          end;
        StringGrid1.SortColRow(True,0);
        StringGrid1.Row := 0;
      Except
      end;
    end;
end;

end.

