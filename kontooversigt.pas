//**********************************************************
// Kontooversigt
// 29.10.13
//**********************************************************
unit kontooversigt;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  ExtCtrls, Grids, ActnList, Buttons, StdCtrls;

type

  { TKontiForm }

  TKontiForm = class(TForm)
    BitBtn6: TBitBtn;
    CheckBox1: TCheckBox;
    Label1: TLabel;
    Label2: TLabel;
    SletAlle: TAction;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    BitBtn4: TBitBtn;
    BitBtn5: TBitBtn;
    Slet: TAction;
    Aendre: TAction;
    OK: TAction;
    Ny: TAction;
    Help: TAction;
    ImageList1: TImageList;
    Luk: TAction;
    ActionList1: TActionList;
    Panel1: TPanel;
    Panel2: TPanel;
    StringGrid1: TStringGrid;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    procedure AendreExecute(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure HelpExecute(Sender: TObject);
    procedure LukExecute(Sender: TObject);
    procedure OKExecute(Sender: TObject);
    procedure NyExecute(Sender: TObject);
    procedure SletAlleExecute(Sender: TObject);
    procedure SletExecute(Sender: TObject);
    procedure StringGrid1CompareCells(Sender: TObject; ACol, ARow, BCol,
      BRow: Integer; var Result: integer);
    procedure StringGrid1DblClick(Sender: TObject);
  private
    { private declarations }
    MomsKodeListe      : TStringList;
    MomsKodeNrListe    : TStringList;
    Procedure IndlaesMomsKoder;
    Procedure IndstilGrid;
    Procedure Indlaes;
  public
    { public declarations }
  end;

var
  KontiForm: TKontiForm;

implementation

{$R *.lfm}

{ TKontiForm }

Uses maindata, NyKonto, HolbaekConst;

Const
  KolKontoNr   = 0;
  KolKontoNavn = 1;
  KolType      = 2;
  KolMoms      = 3;
  KolGenvej    = 4;
  KolId        = 5;
  KolTypeNr    = 6;

//**********************************************************
// Create
//**********************************************************
procedure TKontiForm.FormCreate(Sender: TObject);
begin
  // Farver
  ToolBar1.Color := H_Menu_knapper_Farve;
  // Database
  MainDataModule.ZQuery1.Connection := MainData.MainDataModule.ZConnection1;
  //Indstil
  MomsKodeListe                  := TStringList.Create;
  MomsKodeListe.Sorted           := True;
  MomsKodeNrListe                := TStringList.Create;
  MomsKodeNrListe.Sorted         := False;
  IndstilGrid;
  //Indlæs
  IndlaesMomsKoder;
  Indlaes;
end;

//**********************************************************
// Destroy
//**********************************************************
procedure TKontiForm.FormDestroy(Sender: TObject);
begin
  MomsKodeNrListe.Free;
  MomsKodeListe.Free;
end;

//**********************************************************
// Activate
//**********************************************************
procedure TKontiForm.FormActivate(Sender: TObject);
begin
end;

//**********************************************************
// Form close
//**********************************************************
procedure TKontiForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  CloseAction := caFree;
end;

//**********************************************************
// Ændre
//**********************************************************
procedure TKontiForm.AendreExecute(Sender: TObject);
begin
  NyKontiForm := TNyKontiForm.Create(Self);
  NyKontiForm.VisOpret   := False;
  NyKontiForm.KontoNr    := StrToInt(StringGrid1.Cells[KolId,StringGrid1.Row]);
  NyKontiForm.GammelType := StrToInt(StringGrid1.Cells[KolTypeNr,StringGrid1.Row]);
  NyKontiForm.ShowModal;
  NyKontiForm.Free;
  Indlaes;
end;

//**********************************************************
// Hjælp
//**********************************************************
procedure TKontiForm.HelpExecute(Sender: TObject);
begin
  ShowMessage('Help');
end;

//**********************************************************
// Indstil grid
//**********************************************************
procedure TKontiForm.IndstilGrid;
Begin
  StringGrid1.Color := H_Grid_BackColor;

  StringGrid1.Columns.Clear;
  // Indsæt 5 + 1 kol
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;
  // Indstil
  StringGrid1.Columns[KolKontoNr].Title.Caption := 'Kontonr';
  StringGrid1.Columns[KolKontoNr].Width         := 60;
  StringGrid1.Columns[KolKontoNr].Alignment     := taRightJustify;

  StringGrid1.Columns[KolKontoNavn].Title.Caption := 'Beskrivelse';
  StringGrid1.Columns[KolKontoNavn].Width         := 170;
  StringGrid1.Columns[KolKontoNavn].Alignment     := taLeftJustify;

  StringGrid1.Columns[KolType].Title.Caption := 'Type';
  StringGrid1.Columns[KolType].Width         := 50;
  StringGrid1.Columns[KolType].Alignment     := taLeftJustify;

  StringGrid1.Columns[KolMoms].Title.Caption := 'Moms';
  StringGrid1.Columns[KolMoms].Width         := 50;
  StringGrid1.Columns[KolMoms].Alignment     := taLeftJustify;

  StringGrid1.Columns[KolGenvej].Title.Caption := 'Genvej';
  StringGrid1.Columns[KolGenvej].Width         := 70;
  StringGrid1.Columns[KolGenvej].Alignment     := taLeftJustify;

  StringGrid1.Columns[KolId].Title.Caption := 'Id';
  StringGrid1.Columns[KolId].Width         := 70;
  StringGrid1.Columns[KolId].Visible       := False;

  StringGrid1.Columns[KolTypeNr].Title.Caption := 'TypeNr';
  StringGrid1.Columns[KolTypeNr].Width         := 70;
  StringGrid1.Columns[KolTypeNr].Visible       := False;
end;

//**********************************************************
// Luk
//**********************************************************
procedure TKontiForm.LukExecute(Sender: TObject);
begin
  Close;
end;

//**********************************************************
// Ok
//**********************************************************
procedure TKontiForm.OKExecute(Sender: TObject);
begin
  ShowMessage('Hallo ok');
end;

//**********************************************************
// Ny
//**********************************************************
procedure TKontiForm.NyExecute(Sender: TObject);
begin
  NyKontiForm := TNyKontiForm.Create(Self);
  NyKontiForm.VisOpret := True;
  NyKontiForm.ShowModal;
  NyKontiForm.Free;
  Indlaes;
end;

//**********************************************************
// Slet alle
//**********************************************************
procedure TKontiForm.SletAlleExecute(Sender: TObject);
begin
  { TODO : Kontooversigt: Slet alle skal implementeres }
  ShowMessage('Slet alle');
end;

//**********************************************************
// Slet
//**********************************************************
procedure TKontiForm.SletExecute(Sender: TObject);
begin
  If StringGrid1.RowCount = 2 Then
    Begin
      MessageDlg('Der skal min. være defineret en konto!',mtInformation,[mbOk],0);
      Exit;
    end;
  // Find Record
  With MainDataModule.ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from kontobes where Afd = ' + CurrentAfd +
          ' and id = ' + StringGrid1.Cells[KolId,StringGrid1.Row]);
    End;
  MainDataModule.ZQuery1.Open;
  If MainDataModule.ZQuery1.RecordCount <> 1 Then
    Begin
      MessageDlg('Konto kan ikke findes!',mtInformation,[mbOk],0);
      Exit;
    end;
  MainDataModule.ZQuery1.First;
  { TODO : Check om konto kan slettes }
  Try
    MainDataModule.ZQuery1.Delete;
  Except
    MessageDlg('Kan ikke fjerne konto!',mtError,[mbOk],0);
    MainDataModule.ZQuery1.CancelUpdates;
    Exit;
  End;
  Indlaes;
end;

//**********************************************************
// Stringgrid: Compare cells
//**********************************************************
procedure TKontiForm.StringGrid1CompareCells(Sender: TObject; ACol, ARow, BCol,
  BRow: Integer; var Result: integer);
begin
  If ACol = KolKontoNr Then
    Begin // Sorter integer
      Result := StrToIntDef(StringGrid1.Cells[ACol,ARow],0) - StrToIntDef(StringGrid1.Cells[BCol,BRow],0);
      If StringGrid1.SortOrder = soDescending Then
        Begin
          Result := -Result;
        end;
    end;
end;

//**********************************************************
// Stringgrid: Double click
//**********************************************************
procedure TKontiForm.StringGrid1DblClick(Sender: TObject);
begin
  AendreExecute(Sender);
end;

//**********************************************************
// Indlaes
//**********************************************************
procedure TKontiForm.Indlaes;
Var A : Integer;
Begin
  Try
    MainDataModule.ZQuery1.Active := False;
    With MainDataModule.ZQuery1.SQL do
      Begin
        Clear;
        Add('Select * from KontoBes where Afd = ' + CurrentAfd);
      End;
    MainDataModule.ZQuery1.Active:=True;
    If MainDataModule.ZQuery1.RecordCount = 0 Then
      Begin
        StringGrid1.RowCount  := 1;
        MessageDlg('Ingen konti defineret!',mtInformation,[mbOk],0);
        Exit;
      end;
    StringGrid1.RowCount := 1;
    MainDataModule.ZQuery1.First;
    A := 1;
    While not MainDataModule.ZQuery1.EOF Do
      Begin
        StringGrid1.RowCount:=StringGrid1.RowCount+1;
        StringGrid1.Cells[KolKontoNr,A]   := MainDataModule.ZQuery1.FieldByName('BrugerKonto').AsString;
        StringGrid1.Cells[KolKontonavn,A] := MainDataModule.ZQuery1.FieldByName('Beskrivelse').AsString;
        If      MainDataModule.ZQuery1.FieldByName('Type').AsString = '0' Then
          StringGrid1.Cells[KolType,A] := 'Drift'
        Else If MainDataModule.ZQuery1.FieldByName('Type').AsString = '1' Then
          StringGrid1.Cells[KolType,A] := 'Status'
        Else If MainDataModule.ZQuery1.FieldByName('Type').AsString = '2' Then
          StringGrid1.Cells[KolType,A] := 'Sum'
        Else If MainDataModule.ZQuery1.FieldByName('Type').AsString = '3' Then
          StringGrid1.Cells[KolType,A] := 'Tekst';
        StringGrid1.Cells[KolMoms,A]      :=
          MomsKodeListe.Strings[MomsKodeNrListe.
            IndexOf(MainDataModule.ZQuery1.FieldByName('Momskode').AsString)];
        StringGrid1.Cells[KolGenvej,A]    := MainDataModule.ZQuery1.FieldByName('kgb').AsString;
        StringGrid1.Cells[KolId,A]        := MainDataModule.ZQuery1.FieldByName('id').AsString;
        StringGrid1.Cells[KolTypeNr,A]    := MainDataModule.ZQuery1.FieldByName('Type').AsString;
        MainDataModule.ZQuery1.Next;
        Inc(A);
      end;
    StringGrid1.SortColRow(True,KolKontoNr);
  Except
  end;
end;

//**********************************************************
// Indlæs momskoder
//**********************************************************
Procedure TKontiForm.IndlaesMomsKoder;
Var Nr : Integer;
Begin
  // Moms
  MomsKodeListe.Clear;
  MomsKodeListe.Add('');
  MomsKodeNrListe.Add('');
  MainDataModule.ZQuery1.Active := False;
  With MainDataModule.ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from Momskode where Afd = ' + CurrentAfd);
    End;
  MainDataModule.ZQuery1.Active := True;
  If MainDataModule.ZQuery1.RecordCount = 0 Then
    Begin
      Exit;
    end;
  MainDataModule.ZQuery1.First;
  While Not MainDataModule.ZQuery1.Eof Do
    Begin
      Nr := MomsKodeListe.Add(MainDataModule.ZQuery1.FieldByName('Navn').AsString);
      MomskodeNrListe.Insert(Nr,MainDataModule.ZQuery1.FieldByName('Nr').AsString);
      MainDataModule.ZQuery1.Next;
    End;
End;

end.

