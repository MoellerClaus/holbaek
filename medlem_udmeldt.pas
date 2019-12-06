//***************************************************************************//
//  Holbæk                                                                   //
//  Copyright by Claus Moeller 2013-2014                                     //
//  Medlem udmeldt                                                           //
//  Version                                                                  //
//  02.11.14                                                                 //
//***************************************************************************//
unit Medlem_Udmeldt;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  Menus, ActnList, StdCtrls, ExtCtrls, JLabeledDateEdit, ZDataset;

type

  { TMedlemUdmeldtForm }

  TMedlemUdmeldtForm = class(TForm)
    ActionList1: TActionList;
    AktivitetSpeedAll: TAction;
    AktivitetSpeedNone: TAction;
    Help: TAction;
    ImageList1: TImageList;
    DateEdit1: TJLabeledDateEdit;
    Luk: TAction;
    MenuItem1: TMenuItem;
    PopupMenu1: TPopupMenu;
    RadioGroup1: TRadioGroup;
    Soeg: TAction;
    SoegFlere: TAction;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ZQuery1: TZQuery;
    procedure FormCreate(Sender: TObject);
    procedure LukExecute(Sender: TObject);
    procedure SoegExecute(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  MedlemUdmeldtForm: TMedlemUdmeldtForm;

implementation

{$R *.lfm}

Uses HolbaekConst, HolbaekMain;

{ TMedlemUdmeldtForm }

//**********************************************************
// Create
//**********************************************************
procedure TMedlemUdmeldtForm.FormCreate(Sender: TObject);
begin
  Top  := 10;
  Left := 30;
  // Farver
  Color                   := H_Window_Baggrund;
  ToolBar1.Color          := H_Menu_knapper_Farve;
//  Sum_Panel_Color.Color   := H_Menu_knapper_Farve;
  DateEdit1.Color         := H_Edit_Baggrund;
  DateEdit1.EditLabel.Visible := False;

  // Init
  DateEdit1.Value         := Now;
  // Database
(*  ZTable1.Connection      := MainForm.ZConnection1;
  ZQueryMedlem.Connection := MainForm.ZConnection1;
  ZQuery1.Connection      := MainForm.ZConnection1;*)
end;

//**********************************************************
// Luk
//**********************************************************
procedure TMedlemUdmeldtForm.LukExecute(Sender: TObject);
begin
  Close;
end;

//**********************************************************
// Soeg
//**********************************************************
procedure TMedlemUdmeldtForm.SoegExecute(Sender: TObject);
begin
  ModalResult := MrOk;
end;




end.

