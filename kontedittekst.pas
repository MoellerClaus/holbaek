//***************************************************************************//
//  Holbæk                                                                   //
//  Copyright by Claus Moeller 2013-2016                                     //
//  Kontingent edit tekst                                                    //
//  Version                                                                  //
//  09.12.14, 11.12.2016                                                     //
//***************************************************************************//
unit KontEditTekst;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  Menus, ActnList, ExtCtrls, StdCtrls, DbCtrls, Buttons, ZDataset, db, RichMemo;

type

  { TKontEditPBSTekstForm }

  TKontEditPBSTekstForm = class(TForm)
    ActionList1: TActionList;
    Bevel1: TBevel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    BitBtnIndledning: TBitBtn;
    BitBtnAktivitet: TBitBtn;
    BitBtnAfslutning: TBitBtn;
    DataSource1: TDataSource;
    DBEdit1: TDBEdit;
    DBMemo1: TDBMemo;
    DBMemoHelp: TDBMemo;
    DBNavigator1: TDBNavigator;
    DBText1: TDBText;
    DBText2: TDBText;
    Help: TAction;
    ImageList1: TImageList;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Luk: TAction;
    MenuItem1: TMenuItem;
    MenuItem4: TMenuItem;
    PageColor1: TShape;
    Panel1: TPanel;
    PopupMenu1: TPopupMenu;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton3: TToolButton;
    ZQuery1: TZQuery;
    ZQueryKontEdit: TZQuery;
    procedure BitBtnAfslutningClick(Sender: TObject);
    procedure BitBtnAktivitetClick(Sender: TObject);
    procedure BitBtnIndledningClick(Sender: TObject);
    procedure DBNavigator1Click(Sender: TObject; Button: TDBNavButtonType);
    procedure FormCreate(Sender: TObject);
    procedure LukExecute(Sender: TObject);
  private
    { private declarations }
(*    function  GetRichMemoRTF(RichMemo: TRichMemo): string;
    procedure SetRichMemoRTF(Const RichMemo: TRichMemo; S: string);*)
    procedure HentEditor;
  public
    { public declarations }
  end;

var
  KontEditPBSTekstForm: TKontEditPBSTekstForm;

implementation

{$R *.lfm}

{ TKontEditPBSTekstForm }

Uses HolbaekConst, MainData, Hol_Editor, DateUtils;

//**********************************************************
// Create
//**********************************************************
procedure TKontEditPBSTekstForm.FormCreate(Sender: TObject);
begin
  Top  := 10;
  Left := 30;
  ShowHint               := True;
  // Farver
  Color                  := H_Window_Baggrund;
  ToolBar1.Color         := H_Menu_knapper_Farve;

  PageColor1.Color       := H_Panel_Color;
  PageColor1.Align       := alClient;
(*  PageColor2.Brush.Color := H_Panel_Overskrift;
  PageColor2.Align       := alClient;
  *)

//  ComboMedlem.Color      := H_Combo_Color;

(*  ComboPeriode.Color     := H_Combo_Color;
  MaskUdsendelse.Color   := H_Edit_Baggrund;
  MaskRettidig.Color     := H_Edit_Baggrund;
  EditDage.Color         := H_Edit_Baggrund;*)

  // Database
  ZQuery1.Connection          := MainDataModule.ZConnection1;
  ZQueryKontEdit.Connection   := MainDataModule.ZConnection1;
  DataSource1.DataSet         := ZQueryKontEdit;

  With ZQueryKontEdit.SQL do
    Begin
      Clear;
      Add('Select * from KontingentTekst where afd = ' + CurrentAfd);
    End;
  ZQueryKontEdit.Open;
  // Indstil

  // Indlæs

end;

//**********************************************************
// Close
//**********************************************************
procedure TKontEditPBSTekstForm.LukExecute(Sender: TObject);
begin
  Close;
end;

//**********************************************************
// Navigator click
//**********************************************************
procedure TKontEditPBSTekstForm.DBNavigator1Click(Sender: TObject;
  Button: TDBNavButtonType);
Var HelpNr : Integer;
begin
(*  TDBNavButtonType = (nbFirst, nbPrior, nbNext, nbLast,
                  nbInsert, nbDelete, nbEdit, nbPost, nbCancel, nbRefresh);*)
  If Button = nbInsert Then
    Begin
      With ZQuery1.SQL do
        Begin
          Clear;
          Add('Select * from KontingentTekst order by id');
        End;
      ZQuery1.Open;
      Try
        ZQuery1.Append;
        ZQuery1.Edit;
        ZQuery1.FieldByName('Afd').AsString           := CurrentAfd;
        ZQuery1.FieldByName('Overskrift').AsString    := 'Overskrift';
        ZQuery1.FieldByName('Datooprettet').AsFloat   := DateTimeToJulianDate(Now);
        ZQuery1.Post;
      finally
      end;
    end
  Else If Button = nbDelete Then
    Begin

    end
  Else If Button = nbPost Then
    Begin
      Try
        ZQueryKontEdit.Edit;
        ZQueryKontEdit.FieldByName('DatoSidstAendret').AsFloat := DateTimeToJulianDate(Now);
        ZQueryKontEdit.Post;
      Except
        ZQueryKontEdit.Cancel;
        Messagedlg('Kan ikke gemmes!',mtError,[mbOk],0);
        Exit;
      End;
    End;
end;


//**********************************************************
// Hent editor
//**********************************************************
procedure TKontEditPBSTekstForm.HentEditor;
Begin
  DBMemoHelp.Refresh;
  Hol_Editor_Form := THol_Editor_Form.Create(Self);
  Hol_Editor_Form.RichMemo1.Clear;
  // Hent data fra base og indsæt
  SetRichMemoRTF(Hol_Editor_Form.RichMemo1,DBMemoHelp.Text);
  Hol_Editor_Form.ShowModal;
  If Hol_Editor_Form.IndholdAendret Then
    Begin
      DBMemoHelp.DataSource.Edit;
      DBMemoHelp.Text := GetRichMemoRTF(Hol_Editor_Form.RichMemo1);
      //DBMemoHelp.EditingDone;
      DBNavigator1.BtnClick(nbPost);
    end;
  Hol_Editor_Form.Free;
End;

//**********************************************************
// Indledning
//**********************************************************
procedure TKontEditPBSTekstForm.BitBtnIndledningClick(Sender: TObject);
begin
  DBMemoHelp.DataField:= 'Tekst';
  HentEditor;
end;

//**********************************************************
// Aktivitet / Pris
//**********************************************************
procedure TKontEditPBSTekstForm.BitBtnAktivitetClick(Sender: TObject);
begin
  DBMemoHelp.DataField:= 'AktPrisTekst';
  HentEditor;
end;

//**********************************************************
// Afslutning
//**********************************************************
procedure TKontEditPBSTekstForm.BitBtnAfslutningClick(Sender: TObject);
begin
  DBMemoHelp.DataField:= 'AfslutningTekst';
  HentEditor;
end;


end.

