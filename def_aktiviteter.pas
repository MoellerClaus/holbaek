//***************************************************************************//
//  Holbæk                                                                   //
//  Copyright by Claus Moeller 2013-2014                                     //
//  Aktiviteter                                                              //
//  Version                                                                  //
//  03.02.14                                                                 //
//***************************************************************************//
unit def_aktiviteter;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  Grids, Menus, ActnList, ZDataset, StdCtrls;

type

  { TDefAktiviteterForm }

  TDefAktiviteterForm = class(TForm)
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
    procedure StringGrid1EditingDone(Sender: TObject);
    procedure StringGrid1SelectEditor(Sender: TObject; aCol, aRow: Integer;
      var Editor: TWinControl);
    procedure StringGrid1ValidateEntry(sender: TObject; aCol, aRow: Integer;
      const OldValue: string; var NewValue: String);
  private
    { private declarations }
    UpdateGrid : Boolean;
    KontoBeskListe     : TStringList;
    KontiListeNr       : TStringList;
    BrugerListeNr      : TStringList;
    MaxOptionListe     : TStringList;
    NaesteBeskListe    : TStringList;
    NaesteIdListe      : TStringList;
    procedure Indstil;
    procedure Indlaes;
    procedure IndlaesKonti;
    procedure IndlaesOption;
    procedure IndlaesNaeste;
    procedure GemRowTilTabel;
  public
    { public declarations }
  end;

var
  DefAktiviteterForm: TDefAktiviteterForm;

implementation

{$R *.lfm}

Uses MainData, HolbaekConst;

Const
  BaneNr         = 0;
  BaneBesk       = 1;
  BaneEx         = 2;
  BaneVis        = 3;
  BaneKonto      = 4;
  BaneModKonto   = 5;
  BaneMaxAntal   = 6;
  BaneMaxOption  = 7;
  BaneNaesteFelt = 8;
  BaneId         = 9;

  { TDefAktiviteterForm }

//**********************************************************
// Create
//**********************************************************
procedure TDefAktiviteterForm.FormCreate(Sender: TObject);
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
  KontoBeskListe                 := TStringList.Create;
  KontoBeskListe.Sorted          := False;
  KontiListeNr                   := TStringList.Create;
  KontiListeNr.Sorted            := False;
  BrugerListeNr                  := TStringList.Create;
  BrugerListeNr.Sorted           := False;
  MaxOptionListe                 := TStringList.Create;
  MaxOptionListe.Sorted          := False;
  NaesteBeskListe                := TStringList.Create;
  NaesteBeskListe.Sorted         := False;
  NaesteIdListe                  := TStringList.Create;
  NaesteIdListe.Sorted           := False;

  IndlaesNaeste;
  IndlaesOption;
  IndlaesKonti;
  Indlaes;

end;

//**********************************************************
// Destroy
//**********************************************************
procedure TDefAktiviteterForm.FormDestroy(Sender: TObject);
begin
  NaesteIdListe.Free;
  NaesteBeskListe.Free;
  MaxOptionListe.Free;
  KontoBeskListe.Free;
  KontiListeNr.Free;
  BrugerListeNr.Free;
end;

//**********************************************************
// Hjælp
//**********************************************************
procedure TDefAktiviteterForm.HelpExecute(Sender: TObject);
begin
  ShowMessage('Hjælp');
end;

//**********************************************************
// Indlæs konti
//**********************************************************
procedure TDefAktiviteterForm.IndlaesKonti;
Var Nr : LongInt;
Begin
  Try
    With ZQuery1.SQL do
      Begin
        Clear;
        Add('Select * from kontobes where Afd = ' + CurrentAfd);
      End;
    ZQuery1.Open;
    KontoBeskListe.Sorted := False;
    KontoBeskListe.Clear;
    KontoBeskListe.Add(''); // dummy for ingenting
    KontiListeNr.Clear;
    KontiListeNr.Add('');
    BrugerListeNr.Clear;
    BrugerListeNr.Add('');
    While not ZQuery1.EOF Do
      Begin
        Nr := KontoBeskListe.Add(ZQuery1.FieldByName('Beskrivelse').AsString);
        KontiListeNr.Insert(Nr,ZQuery1.FieldByName('Id').AsString);
        BrugerListeNr.Insert(Nr,ZQuery1.FieldByName('BrugerKonto').AsString);
        ZQuery1.Next;
      end;
  Except
  End;
end;

//**********************************************************
// Close
//**********************************************************
procedure TDefAktiviteterForm.LukExecute(Sender: TObject);
begin
  Close;
end;

//**********************************************************
// Opret
//**********************************************************
procedure TDefAktiviteterForm.OpretExecute(Sender: TObject);
Var BaneDefNr : Integer;
begin
  // Indsæt
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from aktiviteter where afd = ' + CurrentAfd +  ' order by banedefnr');
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount = 0 Then
    Begin
      BaneDefNr := 1;
    end
  Else
    Begin
      ZQuery1.Last;
      BaneDefNr := ZQuery1.FieldByName('banedefnr').AsInteger + 1;
    end;
  Try
    ZQuery1.Append;
    ZQuery1.Edit;
    ZQuery1.FieldByName('Afd').AsString           := CurrentAfd;
    ZQuery1.FieldByName('BaneDefNr').AsInteger    := BaneDefNr;
    ZQuery1.FieldByName('Beskrivelse').AsString   := 'Aktivitet';
    ZQuery1.FieldByName('ExInfo').AsString        := '';
    ZQuery1.FieldByName('Vis').AsString           := '1';
    ZQuery1.FieldByName('Konto').Clear;
    ZQuery1.FieldByName('ModKonto').Clear;
    ZQuery1.FieldByName('MaxAntal').Clear;
    ZQuery1.FieldByName('MaxOption').Clear;
    ZQuery1.FieldByName('NaesteFelt').Clear;
    // Gem
    ZQuery1.Post;
    ZQuery1.ApplyUpdates;
  Except
    MessageDlg('Aktivitet kunne ikke oprettes!',mtError,[mbOk],0);
    ZQuery1.CancelUpdates;
    Exit;
  end;
  Indlaes;
end;

//**********************************************************
// Slet
//**********************************************************
procedure TDefAktiviteterForm.SletExecute(Sender: TObject);
begin
  // Find Record
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from aktiviteter where id = ' +
          StringGrid1.Cells[BaneId,StringGrid1.Row]);
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount <> 1 Then
    Begin
      MessageDlg('Aktivitet kan ikke findes!',mtInformation,[mbOk],0);
      Exit;
    end;
  ZQuery1.First;
  Try
    ZQuery1.Delete;
  Except
    MessageDlg('Kan ikke fjerne aktivitet!',mtError,[mbOk],0);
    ZQuery1.CancelUpdates;
    Exit;
  End;
  Indlaes;
end;

//**********************************************************
// Stringgrid Editing done
//**********************************************************
procedure TDefAktiviteterForm.StringGrid1EditingDone(Sender: TObject);
begin
  GemRowTilTabel;
end;

//**********************************************************
// Stringgrid select editor
//**********************************************************
procedure TDefAktiviteterForm.StringGrid1SelectEditor(Sender: TObject; aCol,
  aRow: Integer; var Editor: TWinControl);
begin
  If      aCol = BaneBesk Then
    Begin
      Editor := StringGrid1.EditorByStyle(cbsAuto);
    end
  Else If acol = BaneEx Then
    Begin
      Editor := StringGrid1.EditorByStyle(cbsAuto);
    end
  Else If acol = BaneVis Then
    Begin
      Editor := StringGrid1.EditorByStyle(cbsCheckboxColumn);
    end
  Else If acol = BaneKonto Then
    Begin
      Editor := StringGrid1.EditorByStyle(cbsPickList);
      TCustomComboBox(Editor).Items.Clear;
      TCustomComboBox(Editor).Items.AddStrings(KontoBeskListe);
      TCustomComboBox(Editor).Style := csDropDownList;
      // TCustomComboBox(Editor).Perform(352,150, 0); // CB_SETDROPPEDWIDTH
    end
  Else If acol = BaneModKonto Then
    Begin
      Editor := StringGrid1.EditorByStyle(cbsPickList);
      TCustomComboBox(Editor).Items.Clear;
      TCustomComboBox(Editor).Items.AddStrings(KontoBeskListe);
      TCustomComboBox(Editor).Style := csDropDownList;
    end
  Else If acol = BaneMaxAntal Then
    Begin
      Editor := StringGrid1.EditorByStyle(cbsAuto);
    end
  Else If acol = BaneMaxOption Then
    Begin
      Editor := StringGrid1.EditorByStyle(cbsPickList);
      TCustomComboBox(Editor).Items.Clear;
      TCustomComboBox(Editor).Items.AddStrings(MaxOptionListe);
      TCustomComboBox(Editor).Style := csDropDownList;
    end
  Else If acol = BaneNaesteFelt Then
    Begin
      Editor := StringGrid1.EditorByStyle(cbsPickList);
      TCustomComboBox(Editor).Items.Clear;
      TCustomComboBox(Editor).Items.AddStrings(NaesteBeskListe);
      TCustomComboBox(Editor).Style := csDropDownList;
    end;
end;

//**********************************************************
// Validate entry
//**********************************************************
procedure TDefAktiviteterForm.StringGrid1ValidateEntry(sender: TObject; aCol,
  aRow: Integer; const OldValue: string; var NewValue: String);
Var Str : String;
    Tal : Integer;
    Code : Integer;
begin
  Case ACol of
    BaneMaxAntal : Begin
          Val(NewValue,Tal,Code);
          If Code > 0 Then
            Begin
              MessageDlg('Maxantal: ' + NewValue +' er ikke et tal!',mtError,[mbOk],0);
              NewValue := OldValue;
            end;
      end;
  end;
end;

//**********************************************************
// Indstil
//**********************************************************
procedure TDefAktiviteterForm.Indstil;
begin
  Indstil_StringGrid_Edit(StringGrid1);

  StringGrid1.Columns.Clear;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;

  StringGrid1.Columns[BaneNr].Title.Caption          := 'Nr';
  StringGrid1.Columns[BaneNr].Width                  := 30;
  StringGrid1.Columns[BaneNr].Alignment              := taRightJustify;
  StringGrid1.Columns[BaneNr].ReadOnly               := True;

  StringGrid1.Columns[BaneBesk].Title.Caption        := 'Beskrivelse';
  StringGrid1.Columns[BaneBesk].Width                := 80;
  StringGrid1.Columns[BaneBesk].Alignment            := taLeftJustify;

  StringGrid1.Columns[BaneEx].Title.Caption          := 'Ekstra info.';
  StringGrid1.Columns[BaneEx].Width                  := 80;
  StringGrid1.Columns[BaneEx].Alignment              := taLeftJustify;

  StringGrid1.Columns[BaneVis].Title.Caption         := 'Vis';
  StringGrid1.Columns[BaneVis].Width                 := 30;
  StringGrid1.Columns[BaneVis].ButtonStyle           := cbsCheckboxColumn;

  StringGrid1.Columns[BaneKonto].Title.Caption       := 'Konto';
  StringGrid1.Columns[BaneKonto].Width               := 90;
  StringGrid1.Columns[BaneKonto].Alignment           := taLeftJustify;

  StringGrid1.Columns[BaneModKonto].Title.Caption    := 'Modkonto';
  StringGrid1.Columns[BaneModKonto].Width            := 90;
  StringGrid1.Columns[BaneModKonto].Alignment        := taLeftJustify;

  StringGrid1.Columns[BaneMaxAntal].Title.Caption    := 'Max';
  StringGrid1.Columns[BaneMaxAntal].Width            := 40;
  StringGrid1.Columns[BaneMaxAntal].Alignment        := taRightJustify;

  StringGrid1.Columns[BaneMaxOption].Title.Caption   := 'Option';
  StringGrid1.Columns[BaneMaxOption].Width           := 90;
  StringGrid1.Columns[BaneMaxOption].Alignment       := taLeftJustify;

  StringGrid1.Columns[BaneNaesteFelt].Title.Caption  := 'Næste akt.';
  StringGrid1.Columns[BaneNaesteFelt].Width          := 70;
  StringGrid1.Columns[BaneNaesteFelt].Alignment      := taLeftJustify;

  StringGrid1.Columns[BaneId].Title.Caption          := 'Id';
  StringGrid1.Columns[BaneId].Width                  := 70;
  StringGrid1.Columns[BaneId].Visible                := False;

end;

//**********************************************************
// Indlæs
//**********************************************************
procedure TDefAktiviteterForm.Indlaes;
Var A      : Integer;
    HelpNr : Integer;
Begin
  UpdateGrid := True;
  A := 1;
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from aktiviteter where Afd = ' + CurrentAfd);
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount = 0 Then
    Begin
      StringGrid1.RowCount  := 1;
      MessageDlg('Inten aktivitet endnu!',mtInformation,[mbOk],0);
      Exit;
    end;
  ZQuery1.First;
  StringGrid1.RowCount  := 1;
  StringGrid1.BeginUpdate;
  While Not ZQuery1.EOF Do
    Begin
      StringGrid1.RowCount := StringGrid1.RowCount + 1;
      StringGrid1.Cells[BaneNr,A]         := ZQuery1.FieldByName('BaneDefNr').AsString;
      StringGrid1.Cells[BaneBesk,A]       := ZQuery1.FieldByName('Beskrivelse').AsString;
      StringGrid1.Cells[BaneEx,A]         := ZQuery1.FieldByName('ExInfo').AsString;
      StringGrid1.Cells[BaneVis,A]        := ZQuery1.FieldByName('Vis').AsString;
      // Konto
      HelpNr := KontiListeNr.IndexOf(ZQuery1.FieldByName('Konto').AsString);
      If HelpNr = -1 Then
        StringGrid1.Cells[BaneKonto,A] := ''
      Else
        StringGrid1.Cells[BaneKonto,A]    := KontoBeskListe.Strings[HelpNr];
      // Modkonto
      HelpNr := KontiListeNr.IndexOf(ZQuery1.FieldByName('ModKonto').AsString);
      If HelpNr = -1 Then
        StringGrid1.Cells[BaneModKonto,A] := ''
      Else
        StringGrid1.Cells[BaneModKonto,A] := KontoBeskListe.Strings[HelpNr];
      // Max antal
      StringGrid1.Cells[BaneMaxAntal,A]   := ZQuery1.FieldByName('MaxAntal').AsString;
      // MaxOption
      StringGrid1.Cells[BaneMaxOption,A]  := MaxOptionListe.Strings[
          ZQuery1.FieldByName('MaxOption').AsInteger];
      // NaesteFelt
      StringGrid1.Cells[BaneNaesteFelt,A] := NaesteBeskListe.Strings[
        ZQuery1.FieldByName('NaesteFelt').AsInteger];
      // Id
      StringGrid1.Cells[BaneId,A]         := ZQuery1.FieldByName('Id').AsString;
      Inc(A);
      ZQuery1.Next;
    end;
  StringGrid1.EndUpdate;
  UpdateGrid := False;
end;

//**********************************************************
// Indlæs Naeste
//**********************************************************
procedure TDefAktiviteterForm.IndlaesNaeste;
Var Nr : Integer;
Begin
  Try
    With ZQuery1.SQL do
      Begin
        Clear;
        Add('Select * from aktiviteter where Afd = ' + CurrentAfd);
      End;
    ZQuery1.Open;
    NaesteBeskListe.Clear;
    NaesteIdListe.Clear;
    NaesteBeskListe.Add(''); // dummy for nothing
    NaesteIdListe.Add('0');
    While not ZQuery1.EOF Do
      Begin
        Nr := NaesteBeskListe.Add(ZQuery1.FieldByName('Beskrivelse').AsString);
        NaesteIdListe.Insert(Nr,ZQuery1.FieldByName('BaneDefNr').AsString);
        ZQuery1.Next;
      end;
  Except
  End;
end;

//**********************************************************
// Indlæs Option
//**********************************************************
procedure TDefAktiviteterForm.IndlaesOption;
Begin
  MaxOptionListe.Clear;
  MaxOptionListe.Add('');
  MaxOptionListe.Add('Overskriv');
  MaxOptionListe.Add('Ikke flere');
  MaxOptionListe.Add('Næste tilbydes');
end;

//**********************************************************
// Gem row til tabel
//**********************************************************
procedure TDefAktiviteterForm.GemRowTilTabel;
Var HelpNr : Integer;
Begin
  If UpdateGrid Then Exit;
  // Find Record
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from aktiviteter where id = ' +
           StringGrid1.Cells[BaneId,StringGrid1.Row]);
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount <> 1 Then
    Begin
      MessageDlg('Aktivitet kan ikke opdateres ;-)!',mtInformation,[mbOk],0);
      Exit;
    end;
  ZQuery1.First;
  Try
    ZQuery1.Edit;
    ZQuery1.FieldByName('BaneDefNr').AsString := StringGrid1.Cells[BaneNr,StringGrid1.Row];
    ZQuery1.FieldByName('Beskrivelse').AsString := StringGrid1.Cells[BaneBesk,StringGrid1.Row];
    ZQuery1.FieldByName('ExInfo').AsString      := StringGrid1.Cells[BaneEx,StringGrid1.Row];
    ZQuery1.FieldByName('Vis').AsString         := StringGrid1.Cells[BaneVis,StringGrid1.Row];
    // Konto
    HelpNr := KontoBeskListe.IndexOf(StringGrid1.Cells[BaneKonto,StringGrid1.Row]);
    If HelpNr = -1 Then
      ZQuery1.FieldByName('Konto').Clear
    Else
      ZQuery1.FieldByName('Konto').AsInteger := HelpNr;
    // Modkonto
    HelpNr := KontoBeskListe.IndexOf(StringGrid1.Cells[BaneModKonto,StringGrid1.Row]);
    If HelpNr = -1 Then
      ZQuery1.FieldByName('ModKonto').Clear
    Else
      ZQuery1.FieldByName('ModKonto').AsInteger := HelpNr;
    // Max antal
    ZQuery1.FieldByName('MaxAntal').AsString := StringGrid1.Cells[BaneMaxAntal,StringGrid1.Row];
    // MaxOption
    HelpNr := MaxOptionListe.IndexOf(StringGrid1.Cells[BaneMaxOption,StringGrid1.Row]);
    If HelpNr = -1 Then
      ZQuery1.FieldByName('MaxOption').Clear
    Else
      ZQuery1.FieldByName('MaxOption').AsInteger := HelpNr;
    // Naestefelt
    HelpNr := NaesteBeskListe.IndexOf(StringGrid1.Cells[BaneNaesteFelt,StringGrid1.Row]);
    If HelpNr = -1 Then
      ZQuery1.FieldByName('NaesteFelt').Clear
    Else
      ZQuery1.FieldByName('NaesteFelt').AsInteger := HelpNr;
    // Id
    ZQuery1.FieldByName('Id').AsString          := StringGrid1.Cells[BaneId,StringGrid1.Row];
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

