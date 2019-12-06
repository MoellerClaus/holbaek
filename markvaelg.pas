//***************************************************************************//
//  Holbæk                                                                   //
//  Copyright by Claus Moeller 2013-2017                                     //
//  Vig Foreningsprogram  - Mærker vælg                                      //
//  21.01.17
//***************************************************************************//
unit markvaelg;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  Menus, ActnList, StdCtrls, ExtCtrls, Buttons, ZDataset, clmCombobox,
  JLabeledDateEdit;

type

  { TMark_Vaelg }

  TMark_Vaelg = class(TForm)
    BitBtn2: TBitBtn;
    FjernBtn: TAction;
    MenuItem1: TMenuItem;
    SaetBtn: TAction;
    ActionList1: TActionList;
    BitBtn1: TBitBtn;
    clmCombobox1: TclmCombobox;
    GroupBox1: TGroupBox;
    Help: TAction;
    ImageList1: TImageList;
    Label1: TLabel;
    MaskDato: TJLabeledDateEdit;
    Luk: TAction;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    PopupMenu1: TPopupMenu;
    MarkOption: TRadioGroup;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton3: TToolButton;
    ZQuery1: TZQuery;
    ZQueryMedlem: TZQuery;
    procedure FjernBtnExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure HelpExecute(Sender: TObject);
    procedure LukExecute(Sender: TObject);
    procedure SaetBtnExecute(Sender: TObject);
  private
    { private declarations }
    procedure IndlaesMaerker;
  public
    { public declarations }
  end;

var
  Mark_Vaelg: TMark_Vaelg;

implementation

{$R *.lfm}

Uses MainData, HolbaekConst, ShowFind;

{ TMark_Vaelg }


//**********************************************************
// Create
//**********************************************************
procedure TMark_Vaelg.FormCreate(Sender: TObject);
begin
  Top  := 10;
  Left := 30;
  // Farver
  Color                   := H_Window_Baggrund;
  ToolBar1.Color          := H_Menu_knapper_Farve;
  clmCombobox1.Color      := H_Combo_Color;
  MaskDato.Color          := H_Edit_Baggrund;

  // Database
  ZQueryMedlem.Connection := MainData.MainDataModule.ZConnection1;
  ZQuery1.Connection      := MainData.MainDataModule.ZConnection1;

(*  // Lister
  ResultDefListe := TList.Create;
  // Data til visning af liste
  ReadData;
  *)
  // Init
  MaskDato.Value := Now;

  // Opdater
  IndlaesMaerker;

end;

//**********************************************************
// Destroy
//**********************************************************
procedure TMark_Vaelg.FormDestroy(Sender: TObject);
begin
  Mark_Vaelg := Nil;
end;

//**********************************************************
// Fjern Mærker
//**********************************************************
procedure TMark_Vaelg.FjernBtnExecute(Sender: TObject);
Var A         : Integer;
    KodeValgt : String;
    Nr        : Integer;
begin
  // KodeValgt
  KodeValgt := clmCombobox1.Cells[1,clmCombobox1.ItemIndex];
  For A := 1 To ShowFindForm.StringGrid1.RowCount - 1 do
    Begin
      With ZQuery1.SQL do
        Begin
          Clear;
          Add('Select * from marks medlem where (medlemsnr = ' +
            ShowFindForm.StringGrid1.Cells[0,A] + ') and (markid = ' +
            KodeValgt + ')');
        End;
      ZQuery1.Open;
      If ZQuery1.RecordCount <> 0 Then
        Begin // Mærke findes på medlem
          Case MarkOption.ItemIndex Of
          0 : Begin { Slet }
                ZQuery1.Delete;
              End;
          1,2 : Begin { spørges ved hver opdatering }
                // Find medlem
                With ZQueryMedlem.SQL do
                  Begin
                    Clear;
                    Add('Select * from medlem where medlemsnr = ' +
                      ShowFindForm.StringGrid1.Cells[0,A]);
                  End;
                ZQueryMedlem.Open;
                If ZQueryMedlem.RecordCount = 0 Then
                  Begin
                    MessageDlg('Medlem ikke fundet!',mtInformation,[mbOk],0);
                    Exit;
                  end
                Else
                  Begin
                    // Spørg om der skal opdateres
                    If MessageDlg('Skal mærke for ' +
                      ZQueryMedlem.FieldByName('Fornavn').AsString + ' ' +
                      ZQueryMedlem.FieldByName('Efternavn').AsString +
                      ' slettes?',
                      mtConfirmation,[mbYes,mbNo],0) = mrYes Then
                      Begin // Opdateres med ny dato
                        ZQuery1.Delete;
                      End;
                  end;
               End;
           End; { End Case }
         End;
    End;
//  Close;
end;

//**********************************************************
// Hjælp
//**********************************************************
procedure TMark_Vaelg.HelpExecute(Sender: TObject);
begin
  ShowMessage('Help');
end;

//**********************************************************
// Luk
//**********************************************************
procedure TMark_Vaelg.LukExecute(Sender: TObject);
begin
  Close;
end;

//**********************************************************
// OK
//**********************************************************
procedure TMark_Vaelg.SaetBtnExecute(Sender: TObject);
Var A         : Integer;
    KodeValgt : String;
    Nr        : Integer;
begin
  // KodeValgt
  KodeValgt := clmCombobox1.Cells[1,clmCombobox1.ItemIndex];
  For A := 1 To ShowFindForm.StringGrid1.RowCount - 1 do
    Begin
      With ZQuery1.SQL do
        Begin
          Clear;
          Add('Select * from marks medlem where (medlemsnr = ' +
            ShowFindForm.StringGrid1.Cells[0,A] + ') and (markid = ' +
            KodeValgt + ')');
        End;
      ZQuery1.Open;
      If ZQuery1.RecordCount <> 0 Then
        Begin // Mærke findes i forvejen
          Case MarkOption.ItemIndex Of
          0 : Begin { undlades opdatering }
              End;
          1 : Begin { indsættes ny dato automatisk }
                ZQuery1.Edit;
                ZQuery1.FieldByName('Dato').AsDateTime := MaskDato.Value;
                ZQuery1.Post;
              End;
          2 : Begin { spørges ved hver opdatering }
                // Find medlem
                With ZQueryMedlem.SQL do
                  Begin
                    Clear;
                    Add('Select * from medlem where medlemsnr = ' +
                      ShowFindForm.StringGrid1.Cells[0,A]);
                  End;
                ZQueryMedlem.Open;
                If ZQueryMedlem.RecordCount = 0 Then
                  Begin
                    MessageDlg('Medlem ikke fundet!',mtInformation,[mbOk],0);
                    Exit;
                  end
                Else
                  Begin
                    // Spørg om der skal opdateres
                    If MessageDlg('Mærke for ' +
                      ZQueryMedlem.FieldByName('Fornavn').AsString + ' ' +
                      ZQueryMedlem.FieldByName('Efternavn').AsString +
                      ' findes i forvejen. Skal ny dato indsættes?',
                      mtConfirmation,[mbYes,mbNo],0) = mrYes Then
                      Begin // Opdateres med ny dato
                        ZQuery1.Edit;
                        ZQuery1.FieldByName('Dato').AsDateTime := MaskDato.Value;
                        ZQuery1.Post;
                      End;
                  end;
               End;
           End; { End Case }
         End
       Else
         Begin  { Mærke findes ikke }
           Try
             With ZQuery1.SQL do
               Begin
                 Clear;
                 Add('Select * from marks order by id');
               End;
             ZQuery1.Open;
             ZQuery1.Last;
             Nr := ZQuery1.FieldByName('Id').AsInteger;
             ZQuery1.Edit;
             ZQuery1.Insert;
             ZQuery1.FieldByName('Id').AsInteger := Nr + 1;
             ZQuery1.FieldByName('Markid').AsString := KodeValgt;
             ZQuery1.FieldByName('MedlemsNr').AsString :=
               ShowFindForm.StringGrid1.Cells[0,A];
             ZQuery1.FieldByName('Dato').AsDateTime  := MaskDato.Value;
             ZQuery1.Post;
           Except
             MessageDlg('Dette mærke kan ikke tilknyttes',mtError,[mbOk],0);
           End;
         End;
    End;
//  Close;
End;

//**********************************************************
// Indlæs mærker
//**********************************************************
procedure TMark_Vaelg.IndlaesMaerker;
Var A : Integer;
begin
  //ColumnComboBox1.BeginUpdate;
  clmComboBox1.Columns.Clear;
  clmComboBox1.Columns.Add;
  clmComboBox1.Columns.Add;
  clmComboBox1.Columns.Items[0].Width   := clmComboBox1.Width;
  clmComboBox1.Columns.Items[1].Visible :=False;
  // Find mærker
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from markdef');
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount = 0 Then
    Begin
      MessageDlg('Ingen mærker er defineret!',mtInformation,[mbOk],0);
      Exit;
    end;
  // Combo gøres klar
  ZQuery1.First;
  A := 0;
  While not ZQuery1.EOF Do
    Begin
      clmComboBox1.AddRow;
      clmComboBox1.Cells[0,A] := ZQuery1.FieldByName('Beskrivelse').AsString;
      clmComboBox1.Cells[1,A] := ZQuery1.FieldByName('id').AsString;
      Inc(A);
      ZQuery1.Next;
    End;
  clmComboBox1.ItemIndex := 0; {Default den første}
end;


end.

