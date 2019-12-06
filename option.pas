//***************************************************************************//
//  Holbæk                                                                   //
//  Copyright by Claus Moeller 2013-2014                                     //
//  Option                                                                   //
//  Version                                                                  //
//  13.12.13                                                                 //
//***************************************************************************//
unit option;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  Menus, ActnList, StdCtrls, EditBtn, FileCtrl, ZDataset;

type

  { TOptionForm }

  TOptionForm = class(TForm)
    ActionList1: TActionList;
    FileNameEdit1: TFileNameEdit;
    Help: TAction;
    ImageList1: TImageList;
    Label1: TLabel;
    Luk: TAction;
    MenuItem1: TMenuItem;
    PageControl1: TPageControl;
    PopupMenu1: TPopupMenu;
    Generelt: TTabSheet;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ZQuery1: TZQuery;
    procedure FormCreate(Sender: TObject);
    procedure HelpExecute(Sender: TObject);
    procedure LukExecute(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  OptionForm: TOptionForm;

implementation

{$R *.lfm}

Uses HolbaekConst, HolbaekMain;

{ TOptionForm }

//**********************************************************
// Create
//**********************************************************
procedure TOptionForm.FormCreate(Sender: TObject);
begin
  // Farver
  ToolBar1.Color         := H_Menu_knapper_Farve;
  PageControl1.Color     := H_Page_Color;
  // Database
//  ZQuery1.Connection     := Mainform.ZConnection1;
  //Indstil
  FileNameEdit1.Text     := DatabaseFile;
end;

//**********************************************************
// Hjælp
//**********************************************************
procedure TOptionForm.HelpExecute(Sender: TObject);
begin
  ShowMessage('hjælp');
end;

//**********************************************************
// Luk
//**********************************************************
procedure TOptionForm.LukExecute(Sender: TObject);
begin
  Close;
end;



end.

