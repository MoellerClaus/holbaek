//***************************************************************************//
//  Holbæk                                                                   //
//  Copyright by Claus Moeller 2013-2014                                     //
//  Show Find vælg felter                                                    //
//  Version                                                                  //
//  03.11.14                                                                 //
//***************************************************************************//
unit ShowFind_Def;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  ActnList, Menus, ExtCtrls, CheckLst, Buttons, StdCtrls, ZDataset, IniFiles;

type

  { TShowFindDefForm }

  TShowFindDefForm = class(TForm)
    SpeedButton2: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedIngen: TAction;
    SpeedAlle: TAction;
    Saet6: TAction;
    Saet5: TAction;
    Saet4: TAction;
    Saet3: TAction;
    Saet2: TAction;
    Saet1: TAction;
    Indstil6: TAction;
    Indstil5: TAction;
    Indstil4: TAction;
    Indstil3: TAction;
    Indstil2: TAction;
    EnNed: TAction;
    EnOp: TAction;
    HelpEdit: TEdit;
    Indstil1: TAction;
    ActionList1: TActionList;
    CheckListBox: TCheckListBox;
    GroupBox1: TGroupBox;
    Help: TAction;
    ImageList1: TImageList;
    Luk: TAction;
    MenuItem1: TMenuItem;
    Panel1: TPanel;
    PopupMenu1: TPopupMenu;
    PageColor1: TShape;
    SpeedButton1: TSpeedButton;
    SpeedDefault4: TSpeedButton;
    SpeedButton11: TSpeedButton;
    SpeedButton12: TSpeedButton;
    SpeedButton13: TSpeedButton;
    SpeedButton14: TSpeedButton;
    SpeedDefault1: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedDefault2: TSpeedButton;
    SpeedButton5: TSpeedButton;
    SpeedDefault3: TSpeedButton;
    SpeedButton7: TSpeedButton;
    SpeedDefault6: TSpeedButton;
    SpeedDefault5: TSpeedButton;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton3: TToolButton;
    ZQuery1: TZQuery;
    procedure EnNedExecute(Sender: TObject);
    procedure EnOpExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure HelpExecute(Sender: TObject);
    procedure Indstil1Execute(Sender: TObject);
    procedure Indstil2Execute(Sender: TObject);
    procedure Indstil3Execute(Sender: TObject);
    procedure Indstil4Execute(Sender: TObject);
    procedure Indstil5Execute(Sender: TObject);
    procedure Indstil6Execute(Sender: TObject);
    procedure LukExecute(Sender: TObject);
    procedure Saet1Execute(Sender: TObject);
    procedure Saet2Execute(Sender: TObject);
    procedure Saet3Execute(Sender: TObject);
    procedure Saet4Execute(Sender: TObject);
    procedure Saet5Execute(Sender: TObject);
    procedure Saet6Execute(Sender: TObject);
    procedure SpeedAlleExecute(Sender: TObject);
    procedure SpeedIngenExecute(Sender: TObject);
  private
    { private declarations }
    IniFile        : TInifile;
    procedure ReadDataTilCheckBox;
    procedure Indstil(Nr : String);
    procedure Saet(Nr : String);
    procedure SaetHelp;
    Function  FindNrPrintNavn(PrintNavn : String) : String;
  public
    { public declarations }
  end;

var
  ShowFindDefForm: TShowFindDefForm;

implementation

{$R *.lfm}

Uses ShowFind, HolbaekConst, HolbaekMain;

{ TShowFindDefForm }

//**********************************************************
// Create
//**********************************************************
procedure TShowFindDefForm.FormCreate(Sender: TObject);
begin
  Top  := 10;
  Left := 30;
  // Farver
  Color                 := H_Window_Baggrund;
  ToolBar1.Color        := H_Menu_knapper_Farve;
  CheckListBox.Color    := H_Combo_Color;
  PageColor1.Color      := H_Page_Color;
  // Felter skal indlæses
  ReadDataTilCheckBox;
  // Sæt hjælp
  IniFile := TIniFile.Create(HolbaekIniFile);
  SaetHelp;
  // Default
  Indstil1Execute(Self);
  // Init
  PageColor1.Align      := alClient;
end;

//**********************************************************
// Destroy
//**********************************************************
procedure TShowFindDefForm.FormDestroy(Sender: TObject);
begin
  IniFile.Free;
end;

//**********************************************************
// Hjælp
//**********************************************************
procedure TShowFindDefForm.HelpExecute(Sender: TObject);
begin
  ShowMessage('Hjælp');
end;

//**********************************************************
// Speed en op
//**********************************************************
procedure TShowFindDefForm.EnOpExecute(Sender: TObject);
Var HelpStr : String;
    OldIndex : Integer;
begin
  If CheckListBox.ItemIndex > 0 Then
    Begin
      CheckListBox.Visible := False;
      HelpStr := CheckListBox.Items[CheckListBox.ItemIndex];
      OldIndex := CheckListBox.ItemIndex;
      CheckListBox.Items.Delete(CheckListBox.ItemIndex);
      CheckListBox.Items.Insert(OldIndex - 1, HelpStr);
      CheckListBox.ItemIndex := OldIndex - 1;
      CheckListBox.Checked[CheckListBox.ItemIndex] := True;
      CheckListBox.Visible := True;
    End;
end;

//**********************************************************
// Speed en ned
//**********************************************************
procedure TShowFindDefForm.EnNedExecute(Sender: TObject);
Var HelpStr : String;
    OldIndex : Integer;
begin
  If CheckListBox.ItemIndex < (CheckListBox.Items.Count-1) Then
    Begin
      CheckListBox.Visible := False;
      HelpStr := CheckListBox.Items[CheckListBox.ItemIndex];
      OldIndex := CheckListBox.ItemIndex;
      CheckListBox.Items.Delete(CheckListBox.ItemIndex);
      CheckListBox.Items.Insert(OldIndex+1, HelpStr);
      CheckListBox.ItemIndex := OldIndex+1;
      CheckListBox.Checked[CheckListBox.ItemIndex] := True;
      CheckListBox.Visible := True;
    End;
end;

//**********************************************************
// Read Data Til CheckBox;
//**********************************************************
procedure TShowFindDefForm.ReadDataTilCheckBox;
Var A : Integer;
    HelpData : PShowFindResultDefListType;
    HelpNr   : Integer;
begin
  CheckListBox.Clear;
  For A := 0 to ShowFindForm.ResultDefListe.Count - 1 Do
    Begin
      HelpData := ShowFindForm.ResultDefListe.Items[A];
      HelpNr := CheckListBox.Items.Add(HelpData^.Printnavn);
      If Helpdata^.Valgt Then
        Begin
          CheckListBox.Checked[HelpNr] := True;
        End;
    End;
end;

//**********************************************************
// Find Nr  på PrintNavn
//**********************************************************
Function TShowFindDefForm.FindNrPrintNavn(PrintNavn : String) : String;
Var Stop : Boolean;
    B    : Integer;
    HelpData   : PShowFindResultDefListType;
Begin
  //HelpData := Nil;
  Stop := False;
  B    := 0;
  While Not Stop and (B <= ShowFindForm.ResultDefListe.Count-1) Do
    Begin
      HelpData := ShowFindForm.ResultDefListe[B];
      Stop := (Helpdata^.PrintNavn = PrintNavn);
      If Not Stop Then Inc(B);
    End;
  If Stop Then
    Begin // Fundet nr
      FindNrPrintNavn := IntToStr(HelpData^.NrIDef) + ' ';
    End
  Else
    Begin
      FindNrPrintNavn := '';
    End;
End;

//**********************************************************
// Speed alle
//**********************************************************
procedure TShowFindDefForm.SpeedAlleExecute(Sender: TObject);
Var A : Integer;
begin
  CheckListBox.Visible := False;
  For A := 0 To CheckListBox.Items.Count-1 Do
    Begin
      CheckListBox.Checked[A] := True;
    end;
  CheckListBox.Visible := True;
end;

//**********************************************************
// Speed none all
//**********************************************************
procedure TShowFindDefForm.SpeedIngenExecute(Sender: TObject);
Var A : Integer;
begin
  CheckListBox.Visible := False;
  For A := 0 To CheckListBox.Items.Count-1 Do
    Begin
      CheckListBox.Checked[A] := False;
    end;
  CheckListBox.Visible := True;
end;


//**********************************************************
// Sæt Help
//**********************************************************
procedure TShowFindDefForm.SaetHelp;
Var HelpStr : String;
    A       : Integer;
Begin
  For A := 1 To 6 Do
    Begin
      HelpStr := IniFile.ReadString('ShowFindMed',IntToStr(A) + 'Help','');
      If HelpStr <> '' Then
        Begin
          Case A of
            1 : Begin
                  SpeedDefault1.Hint := HelpStr;
                End;
            2 : Begin
                  SpeedDefault2.Hint := HelpStr;
                End;
            3 : Begin
                  SpeedDefault3.Hint := HelpStr;
                End;
            4 : Begin
                  SpeedDefault4.Hint := HelpStr;
                End;
            5 : Begin
                  SpeedDefault5.Hint := HelpStr;
                End;
            6 : Begin
                  SpeedDefault6.Hint := HelpStr;
                End;
          End; // End Case
        End;
    End;
End;


//**********************************************************
// Indstil
//**********************************************************
procedure TShowFindDefForm.Indstil(Nr : String);
Var A : Integer;
    HelpStr : String;
    NrStr   : String;
    HelpData : PShowFindResultDefListType;
    HelpNr   : Integer;
    NrIndsat : Integer;

Begin
//  IniFile := TIniFile.Create(HolbaekIniFile);
  HelpStr := '';
  HelpStr := IniFile.ReadString('ShowFindMed',Nr + 'R','');
  If HelpStr = '' Then
    Begin // Sæt default
      CheckListBox.Clear;
      For A := 0 to ShowFindForm.ResultDefListe.Count - 1 Do
        Begin
          HelpData := ShowFindForm.ResultDefListe.Items[A];
          HelpNr := CheckListBox.Items.Add(HelpData^.Printnavn);
          If Helpdata^.Valgt Then
            Begin
              CheckListBox.Checked[HelpNr] := True;
            End;
        End;
    End
  Else
    Begin // Læs det gemte ind
      CheckListBox.Clear;
      While (Length(HelpStr) > 0) Do
        Begin
          If Pos(' ',HelpStr) > 0 Then
            Begin
              NrStr := Copy(HelpStr,1,Pos(' ',HelpStr)-1);
              Delete(HelpStr,1,Pos(' ',HelpStr));
            End
          Else
            Begin // Sidste tal
              NrStr := HelpStr;
              HelpStr := '';
            End;
          // Indsæt i checkdialog boks
          HelpNr := StrToInt(NrStr);
          A := 0;
          Try
            HelpData := ShowFindForm.ResultDefListe.Items[A];
            While Helpdata^.NrIDef <> Helpnr Do
              Begin
                Inc(A);
                HelpData := ShowFindForm.ResultDefListe.Items[A];
              End;
            CheckListBox.Items.Add(HelpData^.PrintNavn);
          Except
            //Indstil1Execute(Self);
          End;
        End;
       // Find de checkede
      HelpStr := IniFile.ReadString('ShowFindMed',Nr + 'C','');
      While (Length(HelpStr) > 0) Do
        Begin
          If Pos(' ',HelpStr) > 0 Then
            Begin
              NrStr := Copy(HelpStr,1,Pos(' ',HelpStr)-1);
              Delete(HelpStr,1,Pos(' ',HelpStr));
            End
          Else
            Begin // Sidste tal
              NrStr := HelpStr;
              HelpStr := '';
            End;
          // Fin nr i checklist boks og check det
          HelpNr := StrToInt(NrStr);
          A := 0;
          Try
            HelpData := ShowFindForm.ResultDefListe.Items[A];
            While Helpdata^.NrIDef <> Helpnr Do
              Begin
                Inc(A);
                HelpData := ShowFindForm.ResultDefListe.Items[A];
              End;
            // Navn I Dialog fundet
            NrIndsat := CheckListBox.Items.IndexOf(HelpData^.PrintNavn);
            CheckListBox.Checked[NrIndsat] := True;
          Except
          End;
        End;
    End;
  HelpEdit.Text := IniFile.ReadString('ShowFindMed',Nr + 'Help','Beskrivelse');
//  IniFile.Free;
End;

//**********************************************************
// Default 1
//**********************************************************
procedure TShowFindDefForm.Indstil1Execute(Sender: TObject);
begin
  Indstil('1');
end;

//**********************************************************
// Default 2
//**********************************************************
procedure TShowFindDefForm.Indstil2Execute(Sender: TObject);
begin
  Indstil('2');
end;

//**********************************************************
// Default 3
//**********************************************************
procedure TShowFindDefForm.Indstil3Execute(Sender: TObject);
begin
  Indstil('3');
end;

//**********************************************************
// Default 4
//**********************************************************
procedure TShowFindDefForm.Indstil4Execute(Sender: TObject);
begin
  Indstil('4');
end;

//**********************************************************
// Default 5
//**********************************************************
procedure TShowFindDefForm.Indstil5Execute(Sender: TObject);
begin
  Indstil('5');
end;

//**********************************************************
// Default 6
//**********************************************************
procedure TShowFindDefForm.Indstil6Execute(Sender: TObject);
begin
  Indstil('6');
end;

//**********************************************************
// Sæt
//**********************************************************
procedure TShowFindDefForm.Saet(Nr : String);
Var HelpStr : String;
    A       : Integer;

begin
//  IniFile := TIniFile.Create(HolbaekIniFile);
  // Sæt hjælp
  IniFile.WriteString('ShowFindMed',Nr + 'Help',HelpEdit.Text);
  SaetHelp;
  HelpStr := '';
  For A := 0 to CheckListBox.Items.Count - 1 Do
    Begin
      HelpStr := HelpStr + FindNrPrintNavn(CheckListBox.Items[A]);
    End;
  IniFile.WriteString('ShowFindMed',Nr + 'R',HelpStr);
  HelpStr := '';
  For A := 0 to CheckListBox.Items.Count - 1 Do
    Begin
      If CheckListBox.Checked[A] Then
        Begin
          HelpStr := HelpStr + FindNrPrintNavn(CheckListBox.Items[A]);
        End;
    End;
  IniFile.WriteString('ShowFindMed',Nr + 'C',HelpStr);
//  IniFile.Free;
end;


//**********************************************************
// Sæt 1
//**********************************************************
procedure TShowFindDefForm.Saet1Execute(Sender: TObject);
begin
  Saet('1');
end;

//**********************************************************
// Sæt 2
//**********************************************************
procedure TShowFindDefForm.Saet2Execute(Sender: TObject);
begin
  Saet('2');
end;

//**********************************************************
// Sæt 3
//**********************************************************
procedure TShowFindDefForm.Saet3Execute(Sender: TObject);
begin
  Saet('3');
end;

//**********************************************************
// Sæt 4
//**********************************************************
procedure TShowFindDefForm.Saet4Execute(Sender: TObject);
begin
  Saet('4');
end;

//**********************************************************
// Sæt 5
//**********************************************************
procedure TShowFindDefForm.Saet5Execute(Sender: TObject);
begin
  Saet('5');
end;

//**********************************************************
// Sæt 6
//**********************************************************
procedure TShowFindDefForm.Saet6Execute(Sender: TObject);
begin
  Saet('6');
end;



//**********************************************************
// Close
//**********************************************************
procedure TShowFindDefForm.LukExecute(Sender: TObject);
begin
  Close;
end;







end.

