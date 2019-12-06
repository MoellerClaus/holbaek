//**********************************************************
// Medlem email oversigt
// 21.01.17
// Claus Møller
//**********************************************************
unit medlememailoversigt;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Menus,
  ActnList, ComCtrls, Grids, ZDataset;

type

  { TMedlemEmailForm }

  TMedlemEmailForm = class(TForm)
    ActionList1: TActionList;
    Slet: TAction;
    Help: TAction;
    ImageList1: TImageList;
    Luk: TAction;
    MenuItem1: TMenuItem;
    Opret: TAction;
    PopupMenu1: TPopupMenu;
    StatusBar1: TStatusBar;
    StringGrid1: TStringGrid;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ZQuery1: TZQuery;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
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
    procedure Indstil;
    Procedure GemRowTilTabel;
    Function  IsValidEmail(Value : String) : Boolean;
  public
    { public declarations }
    MedlemsNr           : LongInt;
    MedlemNavn          : String;
    procedure IndlaesEmails;
  end;

var
  MedlemEmailForm: TMedlemEmailForm;

implementation

Uses HolbaekConst, MainData;

{$R *.lfm}

{ TMedlemEmailForm }

Const
EmailEmail     : Integer = 0;
EmailNr        : Integer = 1;


//**********************************************************
// Luk
//**********************************************************
procedure TMedlemEmailForm.LukExecute(Sender: TObject);
begin
  Close;
end;

//**********************************************************
// Opret
//**********************************************************
procedure TMedlemEmailForm.OpretExecute(Sender: TObject);
Var HelpNr : Integer;
begin
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from MedlemEmail order by nr');
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount = 0 Then
    Begin
      HelpNr := 1;
    end
  Else
    Begin
      ZQuery1.Last;
      HelpNr := ZQuery1.FieldByName('nr').AsInteger + 1;
    end;
  Try
    ZQuery1.Append;
    ZQuery1.Edit;
    ZQuery1.FieldByName('nr').AsInteger           := HelpNr;
    ZQuery1.FieldByName('medlemsnr').AsInteger    := MedlemsNr;
    ZQuery1.FieldByName('email').AsString         := '';
    // Gem
    ZQuery1.Post;
  Except
    MessageDlg('Email kunne ikke oprettes!',mtError,[mbOk],0);
    ZQuery1.Cancel;
    Exit;
  end;
  IndlaesEmails;
end;

//**********************************************************
// Slet
//**********************************************************
procedure TMedlemEmailForm.SletExecute(Sender: TObject);
Var Stop : Boolean;
Begin
  If StringGrid1.RowCount = 2 Then
    Begin
      MessageDlg('Der skal min. være defineret en email adr',mtInformation,[mbOk],0);
      Exit;
    end;
  // Find Record
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from MedlemEmail where nr = ' + StringGrid1.Cells[EmailNr,StringGrid1.Row]);
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount <> 1 Then
    Begin
      MessageDlg('Email kan ikke slettes!',mtInformation,[mbOk],0);
      Exit;
    end;
  ZQuery1.First;
   { TODO : Kan email slettes? }
  Try
    ZQuery1.Delete;
  Except
    MessageDlg('Kan ikke fjerne email!',mtError,[mbOk],0);
    ZQuery1.CancelUpdates;
    Exit;
  End;
  IndlaesEmails;
end;

//**********************************************************
// Grid: Editing done
//**********************************************************
procedure TMedlemEmailForm.StringGrid1EditingDone(Sender: TObject);
begin
  GemRowTilTabel;
end;

//**********************************************************
// Grid: Select editor
//**********************************************************
procedure TMedlemEmailForm.StringGrid1SelectEditor(Sender: TObject; aCol,
  aRow: Integer; var Editor: TWinControl);
begin
  If aCol = EmailEmail Then
    Begin
      Editor := StringGrid1.EditorByStyle(cbsAuto);
    end
end;

//**********************************************************
// Grid Validate
//**********************************************************
procedure TMedlemEmailForm.StringGrid1ValidateEntry(sender: TObject; aCol,
  aRow: Integer; const OldValue: string; var NewValue: String);
begin
  If Not IsValidEmail(NewValue) Then
    Begin
      MessageDlg('Email adr. ikke korrekt!',mtError,[mbOk],0);
      NewValue := OldValue;
    End
  Else
    Begin
      GemRowTilTabel;
    end;
end;

//**********************************************************
// Create
//**********************************************************
procedure TMedlemEmailForm.FormCreate(Sender: TObject);
begin
  Top  := 10;
  Left := 30;
  // Farver
  Color             := H_Window_Baggrund;
  ToolBar1.Color    := H_Menu_knapper_Farve;
  StatusBar1.Color  := H_Menu_knapper_Farve;
  // Database
  ZQuery1.Connection := MainData.MainDataModule.ZConnection1;
  // Indlæs
  Indstil;
end;

procedure TMedlemEmailForm.FormResize(Sender: TObject);
begin


end;


//**********************************************************
// Indstil
//**********************************************************
procedure TMedlemEmailForm.Indstil;
begin
  Indstil_StringGrid_Edit(StringGrid1);

  StringGrid1.Columns.Clear;
  StringGrid1.Columns.Add;
  StringGrid1.Columns.Add;

  StringGrid1.Columns[EmailEmail].Title.Caption      := 'Email';
  StringGrid1.Columns[EmailEmail].Width              := 300;
  StringGrid1.Columns[EmailEmail].Alignment          := taLeftJustify;

  StringGrid1.Columns[EmailNr].Title.Caption         := 'Nr';
  StringGrid1.Columns[EmailNr].Width                 := 100;
  StringGrid1.Columns[EmailNr].Alignment             := taLeftJustify;
  StringGrid1.Columns[EmailNr].Visible               := False;
end;

//**********************************************************
// Indlæs emails
//**********************************************************
procedure TMedlemEmailForm.IndlaesEmails;
Var A : Integer;
begin
  UpdateGrid := True;
  StringGrid1.RowCount := 1;
  A := 0;
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from medlememail where medlemsnr = ' + IntToStr(MedlemsNr));
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount = 0 Then
    Begin
      Exit;
    End;
  Caption := MedlemNavn + ' email(s)';
  Application.ProcessMessages;
  StringGrid1.RowCount := ZQuery1.RecordCount + 1;
  A := 0;
  While Not ZQuery1.Eof Do
    Begin
      Inc(A);
      StringGrid1.Cells[EmailEmail,A] :=
        ZQuery1.FieldByName('Email').AsString;
      StringGrid1.Cells[EmailNr,A] :=
        ZQuery1.FieldByName('Nr').AsString;
      ZQuery1.Next;
    End;
  UpdateGrid := False;
End;

//**********************************************************
// Gem row til tabel
//**********************************************************
Procedure TMedlemEmailForm.GemRowTilTabel;
Begin
  If UpdateGrid Then Exit;
  // Find Record
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from MedlemEmail where nr = ' + StringGrid1.Cells[EmailNr,StringGrid1.Row]);
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount <> 1 Then
    Begin
      MessageDlg('Email kan ikke opdateres!',mtInformation,[mbOk],0);
      Exit;
    end;
  ZQuery1.First;
  Try
    ZQuery1.Edit;
    ZQuery1.FieldByName('Email').AsString := StringGrid1.Cells[EmailEmail,StringGrid1.Row];
    ZQuery1.FieldByName('Nr').AsString    := StringGrid1.Cells[EmailNr,StringGrid1.Row];
    ZQuery1.Post;
    ZQuery1.ApplyUpdates;
  Except
    ZQuery1.CancelUpdates;
    MessageDlg('Email blev ikke gemt!',mtError,[mbOK],0);
    Exit;
  End
End;

//**********************************************************************
// CheckEmail
//**********************************************************************
Function TMedlemEmailForm.IsValidEmail(Value : String) : Boolean;
  function CheckAllowed(const s: string): boolean;
  var
    i: integer;
  begin
    Result:= false;
    for i:= 1 to Length(s) do
    begin
      // illegal char in s -> no valid address
      if not (s[i] in ['a'..'z','A'..'Z','0'..'9','_','-','.']) then
        Exit;
    end;
    Result:= true;
  end;
var
  i: integer;
  namePart, serverPart: string;
begin // of IsValidEmail
  Result:= false;
  i:= Pos('@', Value);
  if (i = 0) or (pos('..', Value) > 0) then
    Exit;
  namePart:= Copy(Value, 1, i - 1);
  serverPart:= Copy(Value, i + 1, Length(Value));
  if (Length(namePart) = 0)         // @ or name missing
    or ((Length(serverPart) < 4))   // name or server missing or
    then Exit;                      // too short
  i:= Pos('.', serverPart);
  // must have dot and at least 3 places from end
  if (i < 2) or (i > (Length(serverPart) - 2)) then
    Exit;
  Result:= CheckAllowed(namePart) and CheckAllowed(serverPart);
end;

end.

