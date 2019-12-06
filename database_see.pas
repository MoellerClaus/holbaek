//***************************************************************************//
//  Holbæk                                                                   //
//  Copyright by Claus Moeller 2013-2016                                     //
//  Database see                                                             //
//  Version                                                                  //
//  05.12.16                                                                 //
//***************************************************************************//
unit database_see;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  Menus, ActnList, ExtCtrls, DBGrids, EditBtn, StdCtrls, Grids, DbCtrls,
  ZDataset, ZConnection, db, sqldb, MainData;

type

  { TDatabaseSeeForm }

  TDatabaseSeeForm = class(TForm)
    Genindlaes: TAction;
    DeleteTable: TAction;
    ActionList1: TActionList;
    DBGrid1: TDBGrid;
    DBNavigator1: TDBNavigator;
    FileNameEdit1: TFileNameEdit;
    Help: TAction;
    ImageList1: TImageList;
    Label1: TLabel;
    Luk: TAction;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    PageControl1: TPageControl;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    PopupMenu1: TPopupMenu;
    StringGrid1: TStringGrid;
    StringGrid2: TStringGrid;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    Udskriv: TAction;
    procedure DeleteTableExecute(Sender: TObject);
    procedure FileNameEdit1AcceptFileName(Sender: TObject; var Value: String);
    procedure FormCreate(Sender: TObject);
    procedure GenindlaesExecute(Sender: TObject);
    procedure LukExecute(Sender: TObject);
    procedure StringGrid1Click(Sender: TObject);
    procedure UdskrivExecute(Sender: TObject);
  private
    { private declarations }
    Tabeller : TStringList;
    procedure IndlaesDatabasen;
    procedure IndstilGrid2;
    procedure IndstilGrid1;
  public
    { public declarations }
  end;

var
  DatabaseSeeForm: TDatabaseSeeForm;

implementation

{$R *.lfm}

Uses Holbaekconst, typInfo;

{ TDatabaseSeeForm }

//**********************************************************
// Create
//**********************************************************
procedure TDatabaseSeeForm.FormCreate(Sender: TObject);
begin
  Position := poDesigned;
  (*Top := 10;
  Left := 30;*)
  // Farver
  ToolBar1.Color                 := H_Menu_knapper_Farve;
//  StatusBar1.Color  := H_Menu_knapper_Farve;;
  Color                          := H_Window_Baggrund;
  Panel1.Color                   := H_Panel_Afstemning;

  // Database
  MainDataModule.ZQuery1.Connection := MainDataModule.ZConnection1;
  MainDataModule.ZConnection1.Reconnect;

  // Indstil
  FileNameEdit1.Text := DatabaseFile;
  IndstilGrid1;
  IndstilGrid2;
  DBGrid1.Color                   := H_Grid_BackColor;
  DBGrid1.AlternateColor          := H_Grid_AlternateColor;
  DBGrid1.SelectedColor           := H_Grid_Cell_Selected;
  DBGrid1.FocusColor              := H_Grid_Cell_FocusColor;
  DBGrid1.DefaultRowHeight        := 19;
  DBGrid1.Font.Color              := clBlack;
  DBGrid1.DataSource              := MainDataModule.Datasource1;
  DBNavigator1.DataSource         := MainDataModule.Datasource1;
  IndlaesDatabasen;
end;

//**********************************************************
// Gen indlæs
//**********************************************************
procedure TDatabaseSeeForm.GenindlaesExecute(Sender: TObject);
begin
  IndlaesDatabasen;
end;

//**********************************************************
// Indstil Grid1
//**********************************************************
procedure TDatabaseSeeForm.IndstilGrid1;
Begin
  Indstil_StringGrid_NonEdit(StringGrid1);
  StringGrid1.Columns.Clear;
  StringGrid1.Columns.Add;
  StringGrid1.Columns[0].Title.Caption     := 'Nr';
  StringGrid1.Columns[0].Width             := 100;
  StringGrid1.Columns[0].Alignment         := taLeftJustify;
End;

//**********************************************************
// Indstil Grid2
//**********************************************************
procedure TDatabaseSeeForm.IndstilGrid2;
Begin
  Indstil_StringGrid_NonEdit(StringGrid2);
  StringGrid2.Columns.Clear;
  StringGrid2.Columns.Add;
  StringGrid2.Columns.Add;
  StringGrid2.Columns.Add;
  StringGrid2.Columns.Add;
  StringGrid2.Columns[0].Title.Caption     := 'Nr';
  StringGrid2.Columns[0].Width             := 80;
  StringGrid2.Columns[0].Alignment         := taRightJustify;

  StringGrid2.Columns[1].Title.Caption     := 'Name';
  StringGrid2.Columns[1].Width             := 100;
  StringGrid2.Columns[1].Alignment         := taLeftJustify;

  StringGrid2.Columns[2].Title.Caption     := 'Type';
  StringGrid2.Columns[2].Width             := 100;
  StringGrid2.Columns[2].Alignment         := taLeftJustify;

  StringGrid2.Columns[3].Title.Caption     := 'Size';
  StringGrid2.Columns[3].Width             := 90;
  StringGrid2.Columns[3].Alignment         := taRightJustify;
End;

//**********************************************************
// Ny database valgt
//**********************************************************
procedure TDatabaseSeeForm.FileNameEdit1AcceptFileName(Sender: TObject;
  var Value: String);
begin
  Try
    If MainDataModule.ZConnection1.Connected Then
      MainDataModule.ZConnection1.Connected:=False;
    MainDataModule.ZConnection1.Database:=Value;
    MainDataModule.ZConnection1.Connected:=True;
  Except
    ShowMessage('Opdater database!');
  end;
end;

//**********************************************************
// Slet tabel
//**********************************************************
procedure TDatabaseSeeForm.DeleteTableExecute(Sender: TObject);
begin
  If MessageDlg('Slet tabel ' + StringGrid1.Cells[0,StringGrid1.Row] + '?',
    mtConfirmation,[mbYes,mbNo],0) <> MrYes Then Exit;
  With MainDataModule.ZQuery1.SQL do
    Begin
      Clear;
      Add('Drop table ' + StringGrid1.Cells[0,StringGrid1.Row]);
    End;
  Try
    MainDataModule.ZQuery1.ExecSQL;
//    MainDataModule.ZConnection1.Commit;
  Except
    on E: EDatabaseError do
      begin
        MessageDlg('Error', 'A database error has occurred. Technical error message: ' +
            E.Message, mtError, [mbOK], 0);
      end;
  end;
  IndlaesDatabasen;
end;

//**********************************************************
// Close
//**********************************************************
procedure TDatabaseSeeForm.LukExecute(Sender: TObject);
begin
  Close;
end;

//**********************************************************
// StringGrid click
//**********************************************************
procedure TDatabaseSeeForm.StringGrid1Click(Sender: TObject);
Var A : Integer;
begin
  If (StringGrid1.Row > 0) and (StringGrid1.RowCount > 1) Then
    Begin
      MainDataModule.ZQuery1.Close;
      With MainDataModule.ZQuery1.SQL do
        Begin
          Clear;
          Add('Select * from ' + StringGrid1.Cells[0,StringGrid1.Row]);
        End;
      MainDataModule.ZQuery1.Open;
//      MainDataModule.ZQuery1.ExecSQL;
    end;
  // Opdater struktur
  A := 0;
  StringGrid2.RowCount := 1;
  StringGrid2.BeginUpdate;
  While A < MainDataModule.ZQuery1.FieldDefs.Count Do
    Begin
      StringGrid2.RowCount := StringGrid2.RowCount + 1;
      StringGrid2.Cells[0,StringGrid2.RowCount-1] := IntToStr(A);
      StringGrid2.Cells[1,StringGrid2.RowCount-1] :=
        MainDataModule.ZQuery1.FieldDefs.Items[A].Name;
      StringGrid2.Cells[2,StringGrid2.RowCount-1] :=
        GetEnumName(TypeInfo(TFieldType),integer(MainDataModule.ZQuery1.FieldDefs.Items[A].DataType));
      If MainDataModule.ZQuery1.FieldDefs.Items[A].Size > 0 Then
        Begin
          StringGrid2.Cells[3,StringGrid2.RowCount-1] :=
            IntToStr(MainDataModule.ZQuery1.FieldDefs.Items[A].Size div 4);
        end
      Else
        Begin
          StringGrid2.Cells[3,StringGrid2.RowCount-1] := '';
        end;
      Inc(A);
    end;
  StringGrid2.EndUpdate;
  // Opdater DBGrid
  DBGrid1.Repaint;

end;

procedure TDatabaseSeeForm.UdskrivExecute(Sender: TObject);
begin

end;

//**********************************************************
// Indlaes databasen
//**********************************************************
procedure TDatabaseSeeForm.IndlaesDatabasen;
Var A : Integer;
begin
  // Check if tables are there
  Tabeller := TStringList.Create;
//  MainDataModule.ZQuery1.Open;
  MainDataModule.ZConnection1.GetTableNames('',Tabeller);
  // sqllite sequence skal tages ud
  If Tabeller.IndexOf('sqlite_sequence') <> -1 Then
    Begin // Der bør ikke rettes i denne index fil
      Tabeller.Delete(Tabeller.IndexOf('sqlite_sequence'));
    end;
  A := 0;
  StringGrid1.RowCount := 1;
  While A < Tabeller.Count Do
    Begin
      StringGrid1.RowCount := StringGrid1.RowCount + 1;
      StringGrid1.Cells[0,StringGrid1.RowCount-1] := Tabeller.Strings[A];
      Inc(A);
    end;
  Stringgrid1.Row := 1;
  StringGrid1Click(Self);
end;

end.

