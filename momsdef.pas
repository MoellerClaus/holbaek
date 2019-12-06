//***************************************************************************//
//  Holbæk                                                                   //
//  Copyright by Claus Moeller 2013-2014                                     //
//  Moms definition                                                          //
//  Version                                                                  //
//  18.10.13                                                                 //
//***************************************************************************//
unit MomsDef;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  ActnList, Menus, Grids, StdCtrls, DBGrids, ZDataset, ZConnection, db;

type

  { TMomsDefForm }

  TMomsDefForm = class(TForm)
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
    KontiListe         : TStringList;
    KontiListeNr       : TStringList;
    KontiListeBrugerNr : TStringList;
    Procedure GemRowTilTabel;
    Procedure Indstil;
    Procedure Indlaes;
    Procedure IndlaesKonti;
  public
    { public declarations }
  end;

var
  MomsDefForm: TMomsDefForm;

implementation

Uses HolbaekConst, HolbaekMain, MainData;

Const
  MomsNavn     : Integer = 0;
  MomsProcent  : Integer = 1;
  MomsSalg     : Integer = 2;
  MomsKonto    : Integer = 3;
  MomsBesk     : Integer = 4;
  MomsNr       : Integer = 5;

  {$R *.lfm}

{ TMomsDefForm }


//**********************************************************
// Create
//**********************************************************
procedure TMomsDefForm.FormCreate(Sender: TObject);
begin
  Position := poDesigned;
  (*Top := 10;
  Left := 30;*)
  // Farver
  ToolBar1.Color    := H_Menu_knapper_Farve;
//  StatusBar1.Color  := H_Menu_knapper_Farve;;
  Color             := H_Window_Baggrund;
  // Database
  MainDataModule.ZQuery1.Connection := MainDataModule.ZConnection1;
  // Init
  KontiListe := TStringList.Create;
  KontiListe.Sorted := False;
  KontiListeNr := TStringList.Create;
  KontiListeNr.Sorted := False;
  KontiListeBrugerNr := TStringList.Create;
  KontiListeBrugerNr.Sorted := True;
  KontiListeBrugerNr.CustomSort(@CompareStringsAsIntegers);
  IndlaesKonti;
  Indstil;
  Indlaes;
  // Andet

end;

//**********************************************************
// Form close
//**********************************************************
procedure TMomsDefForm.FormClose(Sender: TObject; var CloseAction: TCloseAction
  );
begin
  MainDataModule.ZQuery1.Close;
  CloseAction := caFree;
end;

//**********************************************************
// Gem row til tabel
//**********************************************************
Procedure TMomsDefForm.GemRowTilTabel;
Var Stop : Boolean;
Begin
  If UpdateGrid Then Exit;
  // Find Record
  With MainDataModule.ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from momskode where Afd = ' + CurrentAfd +
          ' and nr = ' + StringGrid1.Cells[MomsNr,StringGrid1.Row]);
    End;
  MainDataModule.ZQuery1.Open;
  If MainDataModule.ZQuery1.RecordCount <> 1 Then
    Begin
      MessageDlg('Momskode kan ikke opdateres!',mtInformation,[mbOk],0);
      Exit;
    end;
  MainDataModule.ZQuery1.First;
  Try
    MainDataModule.ZQuery1.Edit;
    // Momskode 3 tegn
    MainDataModule.ZQuery1.FieldByName('Navn').AsString          :=
      StringGrid1.Cells[MomsNavn,StringGrid1.Row];
    // Procent
    MainDataModule.ZQuery1.FieldByName('Procent').AsString       :=
      StringGrid1.Cells[MomsProcent,StringGrid1.Row];
    // Salg
    MainDataModule.ZQuery1.FieldByName('SalgsMoms').AsString     :=
       StringGrid1.Cells[MomsSalg,StringGrid1.Row];
    // Konto
    If StringGrid1.Cells[MomsKonto,StringGrid1.Row] = '' Then
      MainDataModule.ZQuery1.FieldByName('MomsKonto').Clear
    Else
      MainDataModule.ZQuery1.FieldByName('MomsKonto').AsString     :=
        KontiListeNr.Strings[KontiListe.IndexOf(StringGrid1.Cells[MomsKonto,StringGrid1.Row])];
    // Beskrivelse 40 tegn
    MainDataModule.ZQuery1.FieldByName('Beskrivelse').AsString   :=
      StringGrid1.Cells[MomsBesk,StringGrid1.Row];
    // Gem
    MainDataModule.ZQuery1.Post;
    MainDataModule.ZQuery1.ApplyUpdates;
  Except
    MainDataModule.ZQuery1.CancelUpdates;
    MessageDlg('Momskode blev ikke gemt!',mtError,[mbOK],0);
    Exit;
  End
End;

//**********************************************************
// Destroy
//**********************************************************
procedure TMomsDefForm.FormDestroy(Sender: TObject);
begin
  KontiListeBrugerNr.Free;
  KontiListeNr.Free;
  KontiListe.Free;
end;

//**********************************************************
// Hjælp
//**********************************************************
procedure TMomsDefForm.HelpExecute(Sender: TObject);
begin
  ShowMessage('Hjælp');
end;

//**********************************************************
// Indlæs konti
//**********************************************************
procedure TMomsDefForm.IndlaesKonti;
Var A : Integer;
Begin
  With MainDataModule.ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from kontobes where Afd = ' + CurrentAfd);
    End;
  MainDataModule.ZQuery1.Open;
  A := 0;
  MainDataModule.ZQuery1.First;
  While Not MainDataModule.ZQuery1.EOF Do
    Begin
      If MainDataModule.ZQuery1.FieldByName('afd').AsString = CurrentAfd Then
        Begin
          A := KontiListeBrugerNr.Add(MainDataModule.ZQuery1.FieldByName('BrugerKonto').asString);
          KontiListeNr.Insert(A,MainDataModule.ZQuery1.FieldByName('id').asString);
          KontiListe.Insert(A,MainDataModule.ZQuery1.FieldByName('Beskrivelse').asString);
        end;
      MainDataModule.ZQuery1.Next;
    end;
end;

//**********************************************************
// Luk
//**********************************************************
procedure TMomsDefForm.LukExecute(Sender: TObject);
begin
  Close;
end;

//**********************************************************
// Opret
//**********************************************************
procedure TMomsDefForm.OpretExecute(Sender: TObject);
Var HelpNr : Integer;
begin
  MainDataModule.ZQuery1.Close;
  With MainDataModule.ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from momskode');
    End;
  MainDataModule.ZQuery1.Open;
(*  If MainDataModule.ZQuery1.RecordCount = 0 Then
    Begin
      HelpNr := 1;
    end
  Else
    Begin
      MainDataModule.ZQuery1.Last;
      HelpNr := MainDataModule.ZQuery1.FieldByName('Nr').AsInteger + 1;
    end;*)
  Try
    MainDataModule.ZQuery1.Append;
    MainDataModule.ZQuery1.Edit;
//    MainDataModule.ZQuery1.FieldByName('Nr').AsInteger           := HelpNr;
    MainDataModule.ZQuery1.FieldByName('Afd').AsString           := CurrentAfd;
    // Momskode 3 tegn
    MainDataModule.ZQuery1.FieldByName('Navn').AsString          := 'S25';
    // Procent
    MainDataModule.ZQuery1.FieldByName('Procent').AsString       := '25';
    // Salg
    MainDataModule.ZQuery1.FieldByName('SalgsMoms').AsString     := '1';
    // Konto
    MainDataModule.ZQuery1.FieldByName('MomsKonto').Clear;
    // Beskrivelse 40 tegn
    MainDataModule.ZQuery1.FieldByName('Beskrivelse').AsString   := 'Moms beskrivelse';
    // Gem
    MainDataModule.ZQuery1.Post;
    MainDataModule.ZQuery1.ApplyUpdates;
  Except
    MessageDlg('Momskode kunne ikke oprettes!',mtError,[mbOk],0);
    MainDataModule.ZQuery1.CancelUpdates;
    Exit;
  end;
  Indlaes;
end;

//**********************************************************
// Slet
//**********************************************************
procedure TMomsDefForm.SletExecute(Sender: TObject);
Var Stop : Boolean;
begin
  // Find Record
  With MainDataModule.ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from momskode where Afd = ' + CurrentAfd +
          ' and nr = ' + StringGrid1.Cells[MomsNr,StringGrid1.Row]);
    End;
  MainDataModule.ZQuery1.Open;
  If MainDataModule.ZQuery1.RecordCount <> 1 Then
    Begin
      MessageDlg('Momskode kan ikke opdateres!',mtInformation,[mbOk],0);
      Exit;
    end;
  MainDataModule.ZQuery1.First;
  { TODO : Check om momskode kan fjernes }
  Try
    MainDataModule.ZQuery1.Delete;
  Except
    MessageDlg('Kan ikke fjerne momskode!',mtError,[mbOk],0);
    MainDataModule.ZQuery1.CancelUpdates;
    Exit;
  End;
  Indlaes;
end;

//**********************************************************
// Stringgrid CompareCells
//**********************************************************
procedure TMomsDefForm.StringGrid1CompareCells(Sender: TObject; ACol, ARow,
  BCol, BRow: Integer; var Result: integer);
begin
  If ACol = MomsProcent Then
    Begin // Sorter integer
      Result := StrToIntDef(StringGrid1.Cells[ACol,ARow],0) - StrToIntDef(StringGrid1.Cells[BCol,BRow],0);
      If StringGrid1.SortOrder = soDescending Then
        Begin
          Result := -Result;
        end;
    end;
end;

//**********************************************************
// StringGrid Editing done
//**********************************************************
procedure TMomsDefForm.StringGrid1EditingDone(Sender: TObject);
begin
  GemRowTilTabel;
end;

//**********************************************************
// StringGrid Select editor
//**********************************************************
procedure TMomsDefForm.StringGrid1SelectEditor(Sender: TObject; aCol,
  aRow: Integer; var Editor: TWinControl);
begin
  If      aCol = MomsNavn Then
    Begin
      Editor := StringGrid1.EditorByStyle(cbsAuto);
    end
  Else If acol = MomsProcent Then
    Begin
      Editor := StringGrid1.EditorByStyle(cbsAuto);
    end
  Else If acol = MomsSalg Then
    Begin
      Editor := StringGrid1.EditorByStyle(cbsCheckboxColumn);
    end
  Else If acol = MomsKonto Then
    Begin
      Editor := StringGrid1.EditorByStyle(cbsPickList);
      TCustomComboBox(Editor).Items.Clear;
      TCustomComboBox(Editor).Items.AddStrings(KontiListe);
    end
  Else If acol = MomsSalg Then
    Begin
      Editor := StringGrid1.EditorByStyle(cbsAuto);
    end;
end;

//**********************************************************
// StringGrid Validate entry
//**********************************************************
procedure TMomsDefForm.StringGrid1ValidateEntry(sender: TObject; aCol,
  aRow: Integer; const OldValue: string; var NewValue: String);
Var HelpInt : Integer;
    Code    : Word;
begin
  If      aCol = MomsNavn Then
    Begin
    end
  Else If acol = MomsProcent Then
    Begin // Check new value er tal
      Val(NewValue,HelpInt,Code);
      If Code<>0 then
        Begin
          MessageDlg('Procent skal være helt tal!',mtError,[mbOK],0);
          NewValue := OldValue;
        end;
    end
  Else If acol = MomsSalg Then
    Begin
    end
  Else If acol = MomsKonto Then
    Begin
    end
  Else If acol = MomsSalg Then
    Begin
    end;

end;


//**********************************************************
// Indstil
//**********************************************************
procedure TMomsDefForm.Indstil;
begin
  Indstil_StringGrid_Edit(StringGrid1);

  StringGrid1.Columns.Clear;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;

  StringGrid1.Columns[MomsNavn].Title.Caption        := 'Moms';
  StringGrid1.Columns[MomsNavn].Width                := 50;
  StringGrid1.Columns[MomsNavn].Alignment            := taLeftJustify;

  StringGrid1.Columns[MomsProcent].Title.Caption     := '%';
  StringGrid1.Columns[MomsProcent].Width             := 40;
  StringGrid1.Columns[MomsProcent].Alignment         := taRightJustify;

  StringGrid1.Columns[MomsSalg].Title.Caption        := '+/-';
  StringGrid1.Columns[MomsSalg].Width                := 40;
  StringGrid1.Columns[MomsSalg].ButtonStyle          := cbsCheckboxColumn;

  StringGrid1.Columns[MomsKonto].Title.Caption       := 'Momskonto';
  StringGrid1.Columns[MomsKonto].Width               := 150;
  StringGrid1.Columns[MomsKonto].Alignment           := taLeftJustify;

  StringGrid1.Columns[MomsBesk].Title.Caption        := 'Beskrivelse';
  StringGrid1.Columns[MomsBesk].Width                := 150;
  StringGrid1.Columns[MomsBesk].Alignment            := taLeftJustify;

  StringGrid1.Columns[MomsNr].Title.Caption          := 'Id';
  StringGrid1.Columns[MomsNr].Width                  := 50;
  StringGrid1.Columns[MomsNr].Visible                := False;

End;

//**********************************************************
// Indlæs
//**********************************************************
Procedure TMomsDefForm.Indlaes;
Var A : Integer;
    HelpNr : Integer;
Begin
  UpdateGrid := True;
  A                     := 1;
  With MainDataModule.ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from momskode where Afd = ' + CurrentAfd);
    End;
  MainDataModule.ZQuery1.Open;
  If MainDataModule.ZQuery1.RecordCount = 0 Then
    Begin
      StringGrid1.RowCount  := 1;
      MessageDlg('Ingen momskoder endnu!',mtInformation,[mbOk],0);
      Exit;
    end;
  MainDataModule.ZQuery1.First;
  StringGrid1.RowCount  := 1;
  StringGrid1.BeginUpdate;
  While Not MainDataModule.ZQuery1.EOF Do
    Begin
      StringGrid1.RowCount := StringGrid1.RowCount + 1;
      StringGrid1.Cells[MomsNavn,A]        := MainDataModule.ZQuery1.FieldByName('Navn').AsString;
      StringGrid1.Cells[MomsProcent,A]     := MainDataModule.ZQuery1.FieldByName('Procent').AsString;
      StringGrid1.Cells[MomsSalg,A]        := MainDataModule.ZQuery1.FieldByName('salgsmoms').AsString;
      HelpNr := KontiListeNr.IndexOf(MainDataModule.ZQuery1.FieldByName('Momskonto').AsString);
      If HelpNr = -1 Then
        StringGrid1.Cells[MomsKonto,A] := ''
      Else
        StringGrid1.Cells[MomsKonto,A]     := KontiListe.Strings[KontiListeNr.IndexOf(MainDataModule.ZQuery1.FieldByName('Momskonto').AsString)];
      StringGrid1.Cells[MomsBesk,A]        := MainDataModule.ZQuery1.FieldByName('Beskrivelse').AsString;
      StringGrid1.Cells[MomsNr,A]          := MainDataModule.ZQuery1.FieldByName('Nr').AsString;
      Inc(A);
      MainDataModule.ZQuery1.Next;
    end;
  StringGrid1.EndUpdate;
  UpdateGrid := False;
end;


end.

