//***************************************************************************//
//  Holbæk                                                                   //
//  Copyright by Claus Moeller 2013-2014                                     //
//  Medlemsoplysninger                                                       //
//  Afstemning                                                               //
//  18.01.14                                                                 //
//***************************************************************************//
unit RedigerAfstemning;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Menus,
  ActnList, ComCtrls, Grids, ZDataset;

type

  { TAfstemningsKontiForm }

  TAfstemningsKontiForm = class(TForm)
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
  private
    { private declarations }
    UpdateGrid : Boolean;
    KontiListe         : TStringList;
    KontiListeNr       : TStringList;
    KontiListeBrugerNr : TStringList;
//    Procedure GemRowTilTabel;
    Procedure Indstil;
    Procedure Indlaes;
    Procedure IndlaesKonti;
  public
    { public declarations }
  end;

var
  AfstemningsKontiForm: TAfstemningsKontiForm;

implementation

{$R *.lfm}

Uses HolbaekConst, MainData, PickKonto;

Const
  RedKonto     : Integer = 0;
  RedBesk      : Integer = 1;
  RedNr        : Integer = 2;

{ TAfstemningsKontiForm }

//**********************************************************
// Create
//**********************************************************
procedure TAfstemningsKontiForm.FormCreate(Sender: TObject);
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
  KontiListe                     := TStringList.Create;
  KontiListe.Sorted              := False;
  KontiListeNr                   := TStringList.Create;
  KontiListeNr.Sorted            := False;
  KontiListeBrugerNr             := TStringList.Create;
  KontiListeBrugerNr.Sorted      := True;
  KontiListeBrugerNr.CustomSort(@CompareStringsAsIntegers);
  IndlaesKonti;
  Indstil;
  Indlaes;

end;

//**********************************************************
// Form close
//**********************************************************
procedure TAfstemningsKontiForm.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  ZQuery1.Close;
  CloseAction := caFree;
end;

//**********************************************************
// Destroy
//**********************************************************
procedure TAfstemningsKontiForm.FormDestroy(Sender: TObject);
begin
  KontiListeBrugerNr.Free;
  KontiListeNr.Free;
  KontiListe.Free;
end;

//**********************************************************
// Hjælp
//**********************************************************
procedure TAfstemningsKontiForm.HelpExecute(Sender: TObject);
begin
  ShowMessage('Hjælp');
end;

//**********************************************************
// Luk
//**********************************************************
procedure TAfstemningsKontiForm.LukExecute(Sender: TObject);
begin
  Close;
end;

//**********************************************************
// Opret
//**********************************************************
procedure TAfstemningsKontiForm.OpretExecute(Sender: TObject);
Var HelpNr : Integer;
begin
  PickKontoForm := TPickKontoForm.Create(Self);
  If PickKontoForm.ShowModal <> mrOk Then Exit;
  // Check om den findes i forvejen
  If StringGrid1.Cols[0].IndexOf(
    PickKontoForm.StringGrid1.Cells[0,PickKontoForm.StringGrid1.Row]) <> -1 Then
    Begin
      MessageDlg('Den valgte konto: ' +
       PickKontoForm.StringGrid1.Cells[0,PickKontoForm.StringGrid1.Row] +
       ' findes i forvejeb - der afbrydes',
       mtInformation,[mbOk],0);
      Exit;
    end;
  // Indsæt
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from afstemningskonti order by nr');
    End;
  ZQuery1.Open;
  Try
    ZQuery1.Append;
    ZQuery1.Edit;
    ZQuery1.FieldByName('Afd').AsString           := CurrentAfd;
    // Brugerkonto
    ZQuery1.FieldByName('brugerkonto').AsString   :=
      PickKontoForm.StringGrid1.Cells[0,PickKontoForm.StringGrid1.Row];
    // Gem
    ZQuery1.Post;
    ZQuery1.ApplyUpdates;
  Except
    MessageDlg('Afstemningskonto kunne ikke oprettes!',mtError,[mbOk],0);
    ZQuery1.CancelUpdates;
    PickKontoForm.Free;
    Exit;
  end;
  PickKontoForm.Free;
  Indlaes;
end;

//**********************************************************
// Slet
//**********************************************************
procedure TAfstemningsKontiForm.SletExecute(Sender: TObject);
begin
  // Find Record
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from afstemningskonti where Afd = ' + CurrentAfd +
          ' and nr = ' + StringGrid1.Cells[RedNr,StringGrid1.Row]);
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount <> 1 Then
    Begin
      MessageDlg('Redigeringskonti kan ikke opdateres!',mtInformation,[mbOk],0);
      Exit;
    end;
  ZQuery1.First;
  Try
    ZQuery1.Delete;
  Except
    MessageDlg('Kan ikke fjerne afstemningskonto!',mtError,[mbOk],0);
    ZQuery1.CancelUpdates;
    Exit;
  End;
  Indlaes;
end;

//**********************************************************
// Indlæs konti
//**********************************************************
procedure TAfstemningsKontiForm.IndlaesKonti;
Var A : Integer;
Begin
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from kontobes where Afd = ' + CurrentAfd);
    End;
  ZQuery1.Open;
  A := 0;
  ZQuery1.First;
  While Not ZQuery1.EOF Do
    Begin
      If ZQuery1.FieldByName('afd').AsString = CurrentAfd Then
        Begin
          A := KontiListeBrugerNr.Add(ZQuery1.FieldByName('BrugerKonto').asString);
          KontiListeNr.Insert(A,ZQuery1.FieldByName('id').asString);
          KontiListe.Insert(A,ZQuery1.FieldByName('Beskrivelse').asString);
        end;
      ZQuery1.Next;
    end;
end;

//**********************************************************
// Indstil
//**********************************************************
procedure TAfstemningsKontiForm.Indstil;
begin
  Indstil_StringGrid_NonEdit(StringGrid1);

  StringGrid1.Columns.Clear;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;

  StringGrid1.Columns[RedKonto].Title.Caption        := 'Kontonr';
  StringGrid1.Columns[RedKonto].Width                := 70;
  StringGrid1.Columns[RedKonto].Alignment            := taRightJustify;

  StringGrid1.Columns[RedBesk].Title.Caption         := 'Beskrivelse';
  StringGrid1.Columns[RedBesk].Width                 := 200;
  StringGrid1.Columns[RedBesk].Alignment             := taLeftJustify;

  StringGrid1.Columns[RedNr].Title.Caption           := '*';
  StringGrid1.Columns[RedNr].Width                   := 50;
  StringGrid1.Columns[RedNr].Visible                 := False;

End;

//**********************************************************
// Indlæs
//**********************************************************
Procedure TAfstemningsKontiForm.Indlaes;
Var A : Integer;
Begin
  UpdateGrid := True;
  A                     := 1;
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from afstemningskonti where Afd = ' + CurrentAfd);
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount = 0 Then
    Begin
      StringGrid1.RowCount  := 1;
      MessageDlg('Ingen afstemningskonti valgt endnu!',mtInformation,[mbOk],0);
      Exit;
    end;
  ZQuery1.First;
  StringGrid1.RowCount  := 1;
  StringGrid1.BeginUpdate;
  While Not ZQuery1.EOF Do
    Begin
      StringGrid1.RowCount := StringGrid1.RowCount + 1;
      StringGrid1.Cells[RedKonto,A]     := ZQuery1.FieldByName('BrugerKonto').AsString;
      StringGrid1.Cells[RedBesk,A]      := KontiListe.Strings[
        KontiListeBrugerNr.IndexOf(ZQuery1.FieldByName('BrugerKonto').AsString)];
      StringGrid1.Cells[RedNr,A]        := ZQuery1.FieldByName('Nr').AsString;
      Inc(A);
      ZQuery1.Next;
    end;
  StringGrid1.EndUpdate;
  UpdateGrid := False;
end;


end.

