//***************************************************************************//
//  Holbæk                                                                   //
//  Copyright by Claus Moeller 2013-2016                                     //
//  Definition af rabbatter                                                  //
//  Version                                                                  //
//  10.11.14, 10-12-2016                                                     //
//***************************************************************************//
unit RabatDef;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  ActnList, Menus, Grids, EditBtn, ZDataset;

type

  { TRabatDefForm }

  TRabatDefForm = class(TForm)
    DateEdit1: TDateEdit;
    Help: TAction;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    Slet: TAction;
    Opret: TAction;
    ActionList1: TActionList;
    ImageList1: TImageList;
    Luk: TAction;
    MenuItem1: TMenuItem;
    PopupMenu1: TPopupMenu;
    StringGrid1: TStringGrid;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ZQuery1: TZQuery;
    procedure DateEdit1Exit(Sender: TObject);
    procedure DateEdit1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure HelpExecute(Sender: TObject);
    procedure LukExecute(Sender: TObject);
    procedure OpretExecute(Sender: TObject);
    procedure SletExecute(Sender: TObject);
    procedure StringGrid1EditingDone(Sender: TObject);
    procedure StringGrid1GetCellHint(Sender: TObject; ACol, ARow: Integer;
      var HintText: String);
    procedure StringGrid1PickListSelect(Sender: TObject);
    procedure StringGrid1SelectEditor(Sender: TObject; aCol, aRow: Integer;
      var Editor: TWinControl);
  private
    { private declarations }
    TypeListe      : TStringList;
    KrProcentListe : TStringList;
    MarkNrListe    : TStringList;
    MarkBeskListe  : TStringList;
    PeriodeListe   : TStringList;
    procedure Indstil;
    procedure IndlaesMarkLister;
    procedure IndlaesIGrid;
  public
    { public declarations }
  end;

var
  RabatDefForm: TRabatDefForm;

implementation

{$R *.lfm}

Uses HolbaekConst, MainData, StdCtrls, DateUtils;

Const
  RabatBesk     : Integer = 0;
  RabatType     : Integer = 1;
  RabatParam1   : Integer = 2;
  RabatParam2   : Integer = 3;
  RabatParam3   : Integer = 4;
  RabatDato1    : Integer = 5;
  RabatDato2    : Integer = 6;
  RabatNr       : Integer = 7;

{ TRabatDefForm }

//**********************************************************
// Create
//**********************************************************
procedure TRabatDefForm.FormCreate(Sender: TObject);
begin
  Top  := 10;
  Left := 30;
  ShowHint               := True;
  // Farver
  Color                  := H_Window_Baggrund;
  ToolBar1.Color         := H_Menu_knapper_Farve;

  // Database
  ZQuery1.Connection      := MainDataModule.ZConnection1;

  // Lists
  TypeListe := TStringList.Create;
  TypeListe.Add('Nedskrivning');
  TypeListe.Add('Indmeldelsesgebyr');
  TypeListe.Add('Mængderabat');
  TypeListe.Add('Aldersrabat');
  TypeListe.Add('Mærkerabat');
  TypeListe.Add('Ungdomsrabat');
  TypeListe.Add('Fastrabat');

  KrProcentListe := TStringList.Create;
  KrProcentListe.Add('%');
  KrProcentListe.Add('Kr');

  PeriodeListe := TStringList.Create;
  PeriodeListe.Add('Følger periode');
  PeriodeListe.Add('Følger dags dato');
  PeriodeListe.Add('Følger datoer');

  MarkNrListe   := TStringList.Create;
  MarkNrListe.Sorted := False;
  MarkBeskListe := TStringList.Create;
  MarkBeskListe.Sorted := False;
  // Indstil
  Indstil;
  IndlaesMarkLister;
  // Indlæs
  IndlaesIGrid;
end;

//**********************************************************
// Date Key down
//**********************************************************
procedure TRabatDefForm.DateEdit1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key=9 then
    begin
      StringGrid1.EditorMode := false;
      if StringGrid1.Col < StringGrid1.ColCount then
         StringGrid1.Col := StringGrid1.Col + 1
      Else
        StringGrid1.Col := 0;
      StringGrid1.SetFocus;
    end;
end;

//**********************************************************
// Date edit : Exit
//**********************************************************
procedure TRabatDefForm.DateEdit1Exit(Sender: TObject);
begin
  StringGrid1.Cells[StringGrid1.Col,StringGrid1.Row] := DateToStr(DateEdit1.Date);
end;

//**********************************************************
// Indlæs mark lister
//**********************************************************
procedure TRabatDefForm.IndlaesMarkLister;
Var Nr : Integer;
begin
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from MarkDef order by beskrivelse');
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount = 0 Then
    Begin
      MessageDlg('Ingen mærker defineret!',mtInformation,[mbOk],0);
      Exit;
    end;
  ZQuery1.First;
  While Not ZQuery1.Eof Do
    Begin
      Nr := MarkBeskListe.Add(ZQuery1.FieldByName('Beskrivelse').AsString);
      MarkNrListe.Insert(Nr,ZQuery1.FieldByName('Id').AsString);
      ZQuery1.Next;
    End;
end;

//**********************************************************
// Destroy
//**********************************************************
procedure TRabatDefForm.FormDestroy(Sender: TObject);
begin
  MarkNrListe.Free;
  MarkBeskListe.Free;
  PeriodeListe.Free;
  TypeListe.Free;
  KrProcentListe.Free;
  RabatDefForm := Nil;
end;

//**********************************************************
// Hjælp
//**********************************************************
procedure TRabatDefForm.HelpExecute(Sender: TObject);
begin
  ShowMessage('Help');
end;

//**********************************************************
// Luk
//**********************************************************
procedure TRabatDefForm.LukExecute(Sender: TObject);
begin
  Close;
end;

//**********************************************************
// Opret
//**********************************************************
procedure TRabatDefForm.OpretExecute(Sender: TObject);
Var HelpNr : String;
begin
  Try
    ZQuery1.Append;
    ZQuery1.Edit;
    ZQuery1.FieldByName('Afd').AsString           := CurrentAfd;
    ZQuery1.FieldByName('Beskrivelse').AsString   := 'Ingen beskrivelse';
    ZQuery1.FieldByName('Type').AsString          := '0';
    ZQuery1.FieldByName('Param1').AsString        := '5';
    ZQuery1.FieldByName('Param2').AsString        := '5';
    ZQuery1.FieldByName('Param3').Clear;
    ZQuery1.FieldByName('ParamDate1').Clear;
    ZQuery1.FieldByName('ParamDate2').Clear;
    ZQuery1.Post;
    IndlaesIGrid;
    HelpNr := ZQuery1.FieldByName('Id').AsString;
    StringGrid1.Row := StringGrid1.Cols[RabatNr].IndexOf(HelpNr);
  Except
    MessageDlg('Rabat kunne ikke oprettes!',mtError,[mbOk],0);
    ZQuery1.CancelUpdates;
    Exit;
  end;
end;

//**********************************************************
// Slet
//**********************************************************
procedure TRabatDefForm.SletExecute(Sender: TObject);
Var OldRow : Integer;
begin
  OldRow := StringGrid1.Row;
  If MessageDlg('Skal rabat: ' + StringGrid1.Cells[RabatBesk,StringGrid1.Row] +
    ' slettes ?',mtConfirmation,[mbYes,mbNo],0) <> MrYes Then
    Begin
      Exit;
    End;
  // Se om denne rabat bruges
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from RabatKategori where (Afd = ' + CurrentAfd + ') and (Nr = ' +
        StringGrid1.Cells[RabatNr,StringGrid1.Row] + ')');
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount > 0 Then
    Begin // Den benyttes
      MessageDlg('Denne rabat benyttes - tilknytninger skal slettes først!',mtWarning,[mbOk],0);
      Exit;
    end;
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from RabatDef where Id = ' +
        StringGrid1.Cells[RabatNr,StringGrid1.Row]);
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount > 0 Then
    Begin
      // Slet den
      Try
        ZQuery1.Delete;
      Except
        MessageDlg('Rabatten kunne ikke slettes!',mtWarning,[mbOk],0);
      end;
      IndlaesIGrid;
      If StringGrid1.RowCount > 1 Then
        Begin
          If ((OldRow-1) < StringGrid1.RowCount) And (OldRow-1 > 1) Then
            Begin
              StringGrid1.Row := OldRow - 1;
            End
          Else
            Begin
              StringGrid1.Row := 1;
            End;
        End;
    end
  Else
    Begin
      MessageDlg('Rabatten kan ikke slettes - en fejl',mtError,[mbOk],0);
      Exit;
    end;
end;

//**********************************************************
// Grid: Editing done
//**********************************************************
procedure TRabatDefForm.StringGrid1EditingDone(Sender: TObject);
begin
  If StringGrid1.RowCount = 1 Then Exit;
  // Nu skal ændringer gemmes
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from RabatDef where (Afd = ' + CurrentAfd + ') and (Id = ' +
        StringGrid1.Cells[RabatNr,StringGrid1.Row] + ')');
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount > 0 Then
    Begin
      ZQuery1.Edit;
      ZQuery1.FieldByName('Beskrivelse').AsString :=
        StringGrid1.Cells[RabatBesk,StringGrid1.Row];
      ZQuery1.FieldByName('Type').AsInteger :=
        TypeListe.IndexOf(StringGrid1.Cells[RabatType,StringGrid1.Row]);
      Case TypeListe.IndexOf(StringGrid1.Cells[RabatType,StringGrid1.Row]) Of
        0: Begin // Nedskrivning
             ZQuery1.FieldByName('Param1').AsString :=
               StringGrid1.Cells[RabatParam1,StringGrid1.Row];
             ZQuery1.FieldByName('Param2').AsString :=
               StringGrid1.Cells[RabatParam2,StringGrid1.Row];
             If PeriodeListe.IndexOf(
                StringGrid1.Cells[RabatParam3,StringGrid1.Row]) <> -1 Then
               Begin
                 ZQuery1.FieldByName('Param3').AsInteger :=
                   PeriodeListe.IndexOf(
                       StringGrid1.Cells[RabatParam3,StringGrid1.Row]);
                 If PeriodeListe.IndexOf(StringGrid1.Cells[
                   RabatParam3,StringGrid1.Row]) = 2 Then
                   Begin // Datoer
                     If StringGrid1.Cells[RabatDato1,StringGrid1.Row] <> '' Then
                       Begin
                         ZQuery1.FieldByName('ParamDate1').AsFloat :=
                           DateTimeToJulianDate(StrToDate(StringGrid1.Cells[RabatDato1,StringGrid1.Row]));
                       End
                     Else
                       Begin
                         ZQuery1.FieldByName('ParamDate1').AsFloat := DateTimeToJulianDate(Now);
                       End;
                     If StringGrid1.Cells[RabatDato2,StringGrid1.Row] <> '' Then
                       Begin
                         ZQuery1.FieldByName('ParamDate2').AsFloat :=
                           DateTimeToJulianDate(StrToDate(StringGrid1.Cells[RabatDato2,StringGrid1.Row]));
                       End
                     Else
                       Begin
                         ZQuery1.FieldByName('ParamDate2').AsFloat := DateTimeToJulianDate(Now + 180);
                       End;
                   End
                 Else
                   Begin
                     ZQuery1.FieldByName('ParamDate1').AsString := '';
                     ZQuery1.FieldByName('ParamDate2').AsString := '';
                   End;
               End
             Else
               Begin
                 ZQuery1.FieldByName('Param3').AsString := '';
                 ZQuery1.FieldByName('ParamDate1').AsString := '';
                 ZQuery1.FieldByName('ParamDate2').AsString := '';
               End;
           End;
        1: Begin // Indmeldelsesgebyr
             ZQuery1.FieldByName('Param1').Clear;
             ZQuery1.FieldByName('Param2').AsString :=
               StringGrid1.Cells[RabatParam2,StringGrid1.Row];
             If PeriodeListe.IndexOf(
                StringGrid1.Cells[RabatParam3,StringGrid1.Row]) <> -1 Then
               Begin
                 ZQuery1.FieldByName('Param3').AsInteger :=
                   PeriodeListe.IndexOf(
                       StringGrid1.Cells[RabatParam3,StringGrid1.Row]);
                 If PeriodeListe.IndexOf(StringGrid1.Cells[
                   RabatParam3,StringGrid1.Row]) = 2 Then
                   Begin // Datoer
                     If StringGrid1.Cells[RabatDato1,StringGrid1.Row] <> '' Then
                       Begin
                         ZQuery1.FieldByName('ParamDate1').AsFloat :=
                           DateTimeToJulianDate(StrToDate(StringGrid1.Cells[RabatDato1,StringGrid1.Row]));
                       End
                     Else
                       Begin
                         ZQuery1.FieldByName('ParamDate1').AsDateTime := DateTimeToJulianDate(Now);
                       End;
                     If StringGrid1.Cells[RabatDato2,StringGrid1.Row] <> '' Then
                       Begin
                         ZQuery1.FieldByName('ParamDate2').AsFloat :=
                           DateTimeToJulianDate(StrToDate(StringGrid1.Cells[RabatDato2,StringGrid1.Row]));
                       End
                     Else
                       Begin
                         ZQuery1.FieldByName('ParamDate2').AsFloat := DateTimeToJulianDate(Now + 180);
                       End;
                   End
                 Else
                   Begin
                     ZQuery1.FieldByName('ParamDate1').AsString := '';
                     ZQuery1.FieldByName('ParamDate2').AsString := '';
                   End;
               End
             Else
               Begin
                 ZQuery1.FieldByName('Param3').AsString := '';
                 ZQuery1.FieldByName('ParamDate1').AsString := '';
                 ZQuery1.FieldByName('ParamDate2').AsString := '';
               End;
           End;
        2,3,5,6: Begin // Mængderabat, aldersrabat, ungdomsrabat, fastrabat
             ZQuery1.FieldByName('Param1').AsInteger :=
               KrProcentListe.IndexOf(StringGrid1.Cells[RabatParam1,StringGrid1.Row]);
             ZQuery1.FieldByName('Param2').AsString :=
               StringGrid1.Cells[RabatParam2,StringGrid1.Row];
             ZQuery1.FieldByName('Param3').AsString :=
               StringGrid1.Cells[RabatParam3,StringGrid1.Row];
             ZQuery1.FieldByName('ParamDate1').AsString := '';
             ZQuery1.FieldByName('ParamDate2').AsString := '';
           End;
        4 : Begin // Mærkerabat
             ZQuery1.FieldByName('Param1').AsInteger :=
               KrProcentListe.IndexOf(StringGrid1.Cells[RabatParam1,StringGrid1.Row]);
             ZQuery1.FieldByName('Param2').AsString :=
               StringGrid1.Cells[RabatParam2,StringGrid1.Row];
             If MarkBeskListe.IndexOf(
                StringGrid1.Cells[RabatParam3,StringGrid1.Row]) <> -1 Then
               Begin
                 ZQuery1.FieldByName('Param3').AsString :=
                   MarkNrListe.Strings[
                     MarkBeskListe.IndexOf(
                       StringGrid1.Cells[RabatParam3,StringGrid1.Row])];
               End
             Else
               Begin
                 ZQuery1.FieldByName('Param3').AsString := '';
               End;
             ZQuery1.FieldByName('ParamDate1').AsString := '';
             ZQuery1.FieldByName('ParamDate2').AsString := '';
           End;
      End; // End case
      ZQuery1.Post;
    End
  Else
    Begin
      ZQuery1.Cancel;
      MessageDlg('Data kunne ikke gemmes !',mtError,[mbOk],0);
      Exit;
    end;
end;

//**********************************************************
// Grid: Cell hint
//**********************************************************
procedure TRabatDefForm.StringGrid1GetCellHint(Sender: TObject; ACol,
  ARow: Integer; var HintText: String);
begin
  If (ARow > 0) and (ACol > RabatType) Then
    Begin
      // ATitle := StringGrid1.Cells[RabatType,ARow];
      Case TypeListe.IndexOf(StringGrid1.Cells[RabatType,ARow]) of
        0 : Begin // Nedskrivning
              If ACol = RabatParam1 Then
                Begin
                  HintText := 'Opdeling i dage af nedskrivningsperiode';
                End
              Else If ACol = RabatParam2 Then
                Begin
                  HintText := 'Beløbet afrundes til nærmeste X kr. f.eks 10 for 10 kr.';
                End
              Else If ACol = RabatParam3 Then
                Begin
                  HintText := 'Bestemmer om gebyret skal tilpasses perioden';
                End
              Else If ACol = RabatDato1 Then
                Begin
                  If (PeriodeListe.IndexOf(StringGrid1.Cells[RabatParam3,ARow]) = 2) Then
                    Begin
                      HintText := 'Periode start';
                    End
                  Else
                    Begin
                      HintText := 'Bruges ikke';
                    End
                End
              Else If ACol = RabatDato2 Then
                Begin
                  If (PeriodeListe.IndexOf(StringGrid1.Cells[RabatParam3,ARow]) = 2) Then
                    Begin
                      HintText := 'Periode slut';
                    End
                  Else
                    Begin
                      HintText := 'Bruges ikke';
                    End
                End
            End;
        1 : Begin // Indmeldelsesgenyr
              If ACol = RabatParam1 Then
                Begin
                  HintText := 'Bruges ikke';
                End
              Else If ACol = RabatParam2 Then
                Begin
                  HintText := 'Gebyrets størrelse';
                End
              Else If ACol = RabatParam3 Then
                Begin
                  HintText := 'Bestemmer om gebyret skal tilpasses perioden';
                End
              Else If ACol = RabatDato1 Then
                Begin
                  If (PeriodeListe.IndexOf(StringGrid1.Cells[RabatParam3,ARow]) = 2) Then
                    Begin
                      HintText := 'Periode start';
                    End
                  Else
                    Begin
                      HintText := 'Bruges ikke';
                    End
                End
              Else If ACol = RabatDato2 Then
                Begin
                  If (PeriodeListe.IndexOf(StringGrid1.Cells[RabatParam3,ARow]) = 2) Then
                    Begin
                      HintText := 'Periode slut';
                    End
                  Else
                    Begin
                      HintText := 'Bruges ikke';
                    End
                End
            End;
        2 : Begin // Mængderabat
              If ACol = RabatParam1 Then
                Begin
                  HintText := 'Rabat i % eller kroner';
                End
              Else If ACol = RabatParam2 Then
                Begin
                  HintText := 'Hvor stor rabat';
                End
              Else If ACol = RabatParam3 Then
                Begin
                  HintText := 'Indtil hvormange aktiviteter gives der rabat';
                End
              Else If ACol = RabatDato1 Then
                Begin
                  HintText := 'Bruges ikke';
                End
              Else If ACol = RabatDato2 Then
                Begin
                  HintText := 'Bruges ikke';
                End
            End;
        3 : Begin // Aldersrabat
              If ACol = RabatParam1 Then
                Begin
                  HintText := 'Rabat i % eller kroner';
                End
              Else If ACol = RabatParam2 Then
                Begin
                  HintText := 'Hvor stor rabat';
                End
              Else If ACol = RabatParam3 Then
                Begin
                  HintText := 'Startalder. F.eks alle ældre end 50 år';
                End
              Else If ACol = RabatDato1 Then
                Begin
                  HintText := 'Bruges ikke';
                End
              Else If ACol = RabatDato2 Then
                Begin
                  HintText := 'Bruges ikke';
                End
            End;
        4 : Begin // Mærkerabat
              If ACol = RabatParam1 Then
                Begin
                  HintText := 'Rabat i % eller kroner';
                End
              Else If ACol = RabatParam2 Then
                Begin
                  HintText := 'Hvor stor rabat';
                End
              Else If ACol = RabatParam3 Then
                Begin
                  HintText := 'Mærket';
                End
              Else If ACol = RabatDato1 Then
                Begin
                  HintText := 'Bruges ikke';
                End
              Else If ACol = RabatDato2 Then
                Begin
                  HintText := 'Bruges ikke';
                End
            End;
        5 : Begin // Ungdomsrabat
              If ACol = RabatParam1 Then
                Begin
                  HintText := 'Rabat i % eller kroner';
                End
              Else If ACol = RabatParam2 Then
                Begin
                  HintText := 'Hvor stor rabat';
                End
              Else If ACol = RabatParam3 Then
                Begin
                  HintText := '< alder for at få ungdomsrabat. F.eks alle yngre end 14 år';
                End
              Else If ACol = RabatDato1 Then
                Begin
                  HintText := 'Bruges ikke';
                End
              Else If ACol = RabatDato2 Then
                Begin
                  HintText := 'Bruges ikke';
                End
            End;
        6 : Begin // Fastrabat
              If ACol = RabatParam1 Then
                Begin
                  HintText := 'Rabat i % eller kroner';
                End
              Else If ACol = RabatParam2 Then
                Begin
                  HintText := 'Hvor stor rabat';
                End
              Else If ACol = RabatParam3 Then
                Begin
                  HintText := 'Indtil hvormange aktiviteter gives der rabat';
                End
              Else If ACol = RabatDato1 Then
                Begin
                  HintText := 'Bruges ikke';
                End
              Else If ACol = RabatDato2 Then
                Begin
                  HintText := 'Bruges ikke';
                End
            End;
      End; // End Case
    End;
end;

//**********************************************************
// StringGrid: Pick list
//**********************************************************
procedure TRabatDefForm.StringGrid1PickListSelect(Sender: TObject);
begin
  If StringGrid1.Col = RabatType Then
    Begin
      Case TCustomComboBox(StringGrid1.Editor).ItemIndex of
      0 : Begin // Nedskrivning
            StringGrid1.Cells[RabatParam1,StringGrid1.Row] := '5';
            StringGrid1.Cells[RabatParam2,StringGrid1.Row] := '5';
            StringGrid1.Cells[RabatParam3,StringGrid1.Row] := PeriodeListe.Strings[0];
            StringGrid1.Cells[RabatDato1,StringGrid1.Row]  := '';
            StringGrid1.Cells[RabatDato2,StringGrid1.Row]  := '';
          End;
      1 : Begin // Indmeldelsesgebyr
            StringGrid1.Cells[RabatParam1,StringGrid1.Row] := '';
            StringGrid1.Cells[RabatParam2,StringGrid1.Row] := '50';
            StringGrid1.Cells[RabatParam3,StringGrid1.Row] := PeriodeListe.Strings[0];
            StringGrid1.Cells[RabatDato1,StringGrid1.Row]  := '';
            StringGrid1.Cells[RabatDato2,StringGrid1.Row]  := '';
          End;
      2 : Begin // Mængderabat
            StringGrid1.Cells[RabatParam1,StringGrid1.Row] := '%';
            StringGrid1.Cells[RabatParam2,StringGrid1.Row] := '5';
            StringGrid1.Cells[RabatParam3,StringGrid1.Row] := '2';
            StringGrid1.Cells[RabatDato1,StringGrid1.Row]  := '';
            StringGrid1.Cells[RabatDato2,StringGrid1.Row]  := '';
          End;
      3 : Begin // Aldersrabat
            StringGrid1.Cells[RabatParam1,StringGrid1.Row] := '%';
            StringGrid1.Cells[RabatParam2,StringGrid1.Row] := '5';
            StringGrid1.Cells[RabatParam3,StringGrid1.Row] := '60';
            StringGrid1.Cells[RabatDato1,StringGrid1.Row]  := '';
            StringGrid1.Cells[RabatDato2,StringGrid1.Row]  := '';
          End;
      4 : Begin // Mærkerabat
            StringGrid1.Cells[RabatParam1,StringGrid1.Row] := '%';
            StringGrid1.Cells[RabatParam2,StringGrid1.Row] := '5';
            StringGrid1.Cells[RabatParam3,StringGrid1.Row] := MarkBeskListe.Strings[0];
            StringGrid1.Cells[RabatDato1,StringGrid1.Row]  := '';
            StringGrid1.Cells[RabatDato2,StringGrid1.Row]  := '';
          End;
      5 : Begin // Ungdomsrabat
            StringGrid1.Cells[RabatParam1,StringGrid1.Row] := '%';
            StringGrid1.Cells[RabatParam2,StringGrid1.Row] := '5';
            StringGrid1.Cells[RabatParam3,StringGrid1.Row] := '14';
            StringGrid1.Cells[RabatDato1,StringGrid1.Row]  := '';
            StringGrid1.Cells[RabatDato2,StringGrid1.Row]  := '';
          End;
      6 : Begin // Fastrabat
            StringGrid1.Cells[RabatParam1,StringGrid1.Row] := '%';
            StringGrid1.Cells[RabatParam2,StringGrid1.Row] := '10';
            StringGrid1.Cells[RabatParam3,StringGrid1.Row] := '10';
            StringGrid1.Cells[RabatDato1,StringGrid1.Row]  := '';
            StringGrid1.Cells[RabatDato2,StringGrid1.Row]  := '';
          End;
      End; // End Case
    End;
  If StringGrid1.Col = RabatParam3 Then
    Begin // Periode
      If PeriodeListe.IndexOf(StringGrid1.Cells[RabatParam3,StringGrid1.Row]) <> 2 Then
        Begin
          StringGrid1.Cells[RabatDato1,StringGrid1.Row]  := '';
          StringGrid1.Cells[RabatDato2,StringGrid1.Row]  := '';
        End
      Else
        Begin
          If ZQuery1.FieldByName('ParamDate1').AsFloat <> 0 Then
            Begin
              StringGrid1.Cells[RabatDato1,StringGrid1.Row]  :=
                DateToStr(JulianDateToDateTime(ZQuery1.FieldByName('ParamDate1').AsFloat));
            end;
          If ZQuery1.FieldByName('ParamDate2').AsFloat <> 0 Then
            Begin
              StringGrid1.Cells[RabatDato2,StringGrid1.Row]  :=
                DateToStr(JulianDateToDateTime(ZQuery1.FieldByName('ParamDate2').AsFloat));
            end;
        end;
    End;
end;

//**********************************************************
// StringGrid: Select Editor
//**********************************************************
procedure TRabatDefForm.StringGrid1SelectEditor(Sender: TObject; aCol,
  aRow: Integer; var Editor: TWinControl);
begin
(*  RabatBesk     : Integer = 0;
  RabatType     : Integer = 1;
  RabatParam1   : Integer = 2;
  RabatParam2   : Integer = 3;
  RabatParam3   : Integer = 4;
  RabatDato1    : Integer = 5;
  RabatDato2    : Integer = 6;
  RabatNr       : Integer = 7;
  *)


  If      aCol = RabatBesk Then
    Begin
      Editor := StringGrid1.EditorByStyle(cbsAuto);
    end
  Else If acol = RabatType Then
    Begin
      Editor := StringGrid1.EditorByStyle(cbsPickList);
      TCustomComboBox(Editor).Items.Clear;
      TCustomComboBox(Editor).Items.AddStrings(TypeListe);
    end
  Else if ACol = RabatParam1 Then
    Begin
      Case TypeListe.IndexOf(StringGrid1.Cells[RabatType,ARow]) of
      0: Begin // Nedskrivning
           Editor := StringGrid1.EditorByStyle(cbsAuto);
         End;
      1: Begin // Indmeldelsesgebyr
           Editor := StringGrid1.EditorByStyle(cbsAuto);
         End;
      2,3,4,5,6 : Begin // Mængderabat, Mærkerabat, Ungdomsrabat, fastrabat
           Editor := StringGrid1.EditorByStyle(cbsPickList);
           TCustomComboBox(Editor).Items.Clear;
           TCustomComboBox(Editor).Items.AddStrings(KrProcentListe);
         End;
      End; // End case
    End
  Else if ACol = RabatParam2 Then
    Begin
      Case TypeListe.IndexOf(StringGrid1.Cells[RabatType,ARow]) of
      0,1,2,3,4,5: Begin
           Editor := StringGrid1.EditorByStyle(cbsAuto);
         End;
      End; // End case
    End
  Else If acol = RabatParam3 Then
    Begin
      Case TypeListe.IndexOf(StringGrid1.Cells[RabatType,ARow]) of
      0,1: Begin
           Editor := StringGrid1.EditorByStyle(cbsPickList);
           TCustomComboBox(Editor).Items.Clear;
           TCustomComboBox(Editor).Items.AddStrings(PeriodeListe);
         End
       Else
         Begin
           Editor := StringGrid1.EditorByStyle(cbsAuto);
         End;
      End; // End Case
    end
  Else If (acol = RabatDato1) or (aCol = RabatDato2) Then
    Begin
      Case TypeListe.IndexOf(StringGrid1.Cells[RabatType,ARow]) of
        0,1: Begin // Dato indsættes
         If PeriodeListe.IndexOf(StringGrid1.Cells[RabatParam3,ARow]) = 2 Then
           Begin
             try
               DateEdit1.BoundsRect := StringGrid1.CellRect(aCol,aRow);
               If StringGrid1.Cells[StringGrid1.Col,StringGrid1.Row] <> '' Then
                 DateEdit1.Date := StrToDate(StringGrid1.Cells[StringGrid1.Col,StringGrid1.Row]);
               Editor := DateEdit1;
             Except
             end;
           End
         Else
           Begin
             Editor := StringGrid1.EditorByStyle(cbsNone);
           End;
         End
       Else
         Begin
           Editor := StringGrid1.EditorByStyle(cbsNone);
         End;
      End; // End Case
    end;
end;

//**********************************************************
// Indstil
//**********************************************************
procedure TRabatDefForm.Indstil;
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

  StringGrid1.Columns.Clear;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;
  StringGrid1.Columns[RabatBesk].Width           := 200;
  StringGrid1.Columns[RabatBesk].Title.Caption   := 'Beskrivelse';
  StringGrid1.Columns[RabatBesk].Alignment       := taLeftJustify;

  StringGrid1.Columns[RabatType].Width           := 120;
  StringGrid1.Columns[RabatType].Title.Caption   := 'Type';
  StringGrid1.Columns[RabatType].Alignment       := taLeftJustify;

  StringGrid1.Columns[RabatParam1].Width         := 60;
  StringGrid1.Columns[RabatParam1].Title.Caption := '1';
  StringGrid1.Columns[RabatParam1].Alignment     := taLeftJustify;

  StringGrid1.Columns[RabatParam2].Width         := 60;
  StringGrid1.Columns[RabatParam2].Title.Caption := '2';
  StringGrid1.Columns[RabatParam2].Alignment     := taLeftJustify;

  StringGrid1.Columns[RabatParam3].Width         := 100;
  StringGrid1.Columns[RabatParam3].Title.Caption := '3';
  StringGrid1.Columns[RabatParam2].Alignment     := taLeftJustify;

  StringGrid1.Columns[RabatDato1].Width          := 80;
  StringGrid1.Columns[RabatDato1].Title.Caption  := 'Dato1';
  StringGrid1.Columns[RabatDato1].Alignment      := taLeftJustify;

  StringGrid1.Columns[RabatDato2].Width          := 80;
  StringGrid1.Columns[RabatDato2].Title.Caption  := 'Dato2';
  StringGrid1.Columns[RabatDato2].Alignment      := taLeftJustify;

  StringGrid1.Columns[RabatNr].Width             := 50;
  StringGrid1.Columns[RabatNr].Title.Caption     := '*';
  StringGrid1.Columns[RabatNr].Visible           := False;

  StringGrid1.Options:=StringGrid1.Options+[goCellHints];
  StringGrid1.ShowHint:=True;
End;

//**********************************************************
// Indlæs i Grid
//**********************************************************
procedure TRabatDefForm.IndlaesIGrid;
Var A : Integer;
begin
  // Find rabattter
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from rabatdef where (afd = ' + CurrentAfd + ')');
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount = 0 Then
    Begin
      MessageDlg('Ingen rabatter er defineret!',mtInformation,[mbOk],0);
      Exit;
    end;
  StringGrid1.RowCount                           := 1;
  A := 1;
  ZQuery1.First;
  While not ZQuery1.Eof Do
    Begin
      // Filter er sat på current Afd
      With StringGrid1 Do
        Begin
          RowCount := RowCount + 1;
          Cells[RabatNr,A]   := ZQuery1.FieldByName('Id').AsString;
          Cells[RabatBesk,A] := ZQuery1.FieldByName('Beskrivelse').AsString;
          Cells[RabatType,A] := TypeListe.Strings[ZQuery1.FieldByName('Type').AsInteger];
          Case  ZQuery1.FieldByName('Type').AsInteger of
          0: Begin // Nedskrivning
               Cells[RabatParam1,A] := ZQuery1.FieldByName('Param1').AsString;
               Cells[RabatParam2,A] :=
                  FloatToStrF(ZQuery1.FieldByName('Param2').AsCurrency,ffNumber,18,2);
               // Andele af gebyr; periode start - hele gebyr; dage tilbage.
               If Not ZQuery1.FieldByName('Param3').IsNull And
                 (PeriodeListe.Count >= ZQuery1.FieldByName('Param3').AsInteger + 1) Then
                 Begin
                   Cells[RabatParam3,A] :=
                     PeriodeListe.Strings[ZQuery1.FieldByName('Param3').AsInteger];
                   If ZQuery1.FieldByName('Param3').AsInteger = 2 Then
                     Begin // Datoer
                       Cells[RabatDato1,A]  := DateToStr(JulianDateToDateTime(ZQuery1.FieldByName('ParamDate1').AsFloat));
                       Cells[RabatDato2,A]  := DateToStr(JulianDateToDateTime(ZQuery1.FieldByName('ParamDate2').AsFloat));
                     End
                   Else
                     Begin
                       Cells[RabatDato1,A]  := '';
                       Cells[RabatDato2,A]  := '';
                     End;
                 End
               Else
                 Begin
                   // Sæt default
                   Cells[RabatParam3,A] :=
                     PeriodeListe.Strings[0];
                   Cells[RabatDato1,A]  := '';
                   Cells[RabatDato2,A]  := '';
                 End;
             End;
          1: Begin // Indmeldelsesgebyr
               Cells[RabatParam1,A] := '';
               // Gebyr
               Cells[RabatParam2,A] :=
                  FloatToStrF(ZQuery1.FieldByName('Param2').AsCurrency,ffNumber,18,2);
               // Andele af gebyr; periode start - hele gebyr; dage tilbage.
               If Not ZQuery1.FieldByName('Param3').IsNull And
                 (PeriodeListe.Count >= ZQuery1.FieldByName('Param3').AsInteger + 1) Then
                 Begin
                   Cells[RabatParam3,A] :=
                     PeriodeListe.Strings[ZQuery1.FieldByName('Param3').AsInteger];
                   If ZQuery1.FieldByName('Param3').AsInteger = 2 Then
                     Begin // Datoer
                       Cells[RabatDato1,A]  := ZQuery1.FieldByName('ParamDate1').AsString;
                       Cells[RabatDato2,A]  := ZQuery1.FieldByName('ParamDate2').AsString;
                     End
                   Else
                     Begin
                       Cells[RabatDato1,A]  := '';
                       Cells[RabatDato2,A]  := '';
                     End;
                 End
               Else
                 Begin
                   MessageDlg('Fejl: Indlæsning af indmeldelsesrabat',mtError,[mbOK],0);
                   Exit;
                 End;
             End;
          2,3,5,6: Begin // Mængderabat, Alder, Ungdom, Fast
               Cells[RabatParam1,A] := KrProcentListe.Strings[
                 ZQuery1.FieldByName('Param1').AsInteger];
               Cells[RabatParam2,A] :=
                 FloatToStrF(ZQuery1.FieldByName('Param2').AsCurrency,ffNumber,18,2);
               Cells[RabatParam3,A] := ZQuery1.FieldByName('Param3').AsString;
               Cells[RabatDato1,A]  := '';
               Cells[RabatDato2,A]  := '';
             End;
          4 : Begin // Mærkerabat
               Cells[RabatParam1,A] := KrProcentListe.Strings[
                 ZQuery1.FieldByName('Param1').AsInteger];
               Cells[RabatParam2,A] :=
                 FloatToStrF(ZQuery1.FieldByName('Param2').AsCurrency,ffNumber,18,2);
               If MarkNrListe.IndexOf(ZQuery1.FieldByName('Param3').AsString) <> -1 Then
                 Begin
                   Cells[RabatParam3,A] :=
                     MarkBeskListe.Strings[
                     MarkNrListe.IndexOf(ZQuery1.FieldByName('Param3').AsString)];
                 End
               Else
                 Begin
                   MessageDlg('Fejl: Indlæsning af mærkerabat',mtError,[mbOK],0);
                   Exit;
                 End;
               Cells[RabatDato1,A]  := '';
               Cells[RabatDato2,A]  := '';
             End;
          End; // End case
          Inc(A);
        End;
      ZQuery1.Next;
    End;
  //StringGrid1.EndUpdate;
  StringGrid1.Col := RabatBesk;
End;



end.

