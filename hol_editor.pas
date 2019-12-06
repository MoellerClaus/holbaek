//***************************************************************************//
//  Holbæk                                                                   //
//  Copyright by Claus Moeller 2013-2014                                     //
//  TekstEditor                                                              //
//  Version                                                                  //
//  15.12.14                                                                 //
//***************************************************************************//
unit Hol_Editor;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics,
  Dialogs, ComCtrls, DbCtrls, Menus, ActnList, StdCtrls, RichMemo,
  RichMemoUtils;

type

  { THol_Editor_Form }

  THol_Editor_Form = class(TForm)
    GemSom: TAction;
    Fileopen: TAction;
    RtfSaveDialog: TSaveDialog;
    SkriftFarve: TAction;
    JAalign: TAction;
    CenterAlign: TAction;
    RightAlign: TAction;
    LeftAlign: TAction;
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
    ToolButton12: TToolButton;
    ToolButton13: TToolButton;
    ToolButton14: TToolButton;
    ToolButton15: TToolButton;
    ToolButton16: TToolButton;
    ToolButton17: TToolButton;
    ToolButton19: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    Underline: TAction;
    Italic: TAction;
    Bold: TAction;
    SaetFont: TAction;
    ActionList1: TActionList;
    ColorDialog1: TColorDialog;
    FontDialog1: TFontDialog;
    Help: TAction;
    ImageList1: TImageList;
    Luk: TAction;
    MenuItem1: TMenuItem;
    MenuItem4: TMenuItem;
    PopupMenu1: TPopupMenu;
    RichMemo1: TRichMemo;
    RtfOpenDialog: TOpenDialog;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    procedure FileopenExecute(Sender: TObject);
    procedure GemSomExecute(Sender: TObject);
    procedure RichMemo1Change(Sender: TObject);
    procedure SkriftFarveExecute(Sender: TObject);
    procedure JAalignExecute(Sender: TObject);
    procedure CenterAlignExecute(Sender: TObject);
    procedure ItalicExecute(Sender: TObject);
    procedure BoldExecute(Sender: TObject);
    procedure LeftAlignExecute(Sender: TObject);
    procedure RightAlignExecute(Sender: TObject);
    procedure SaetFontExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure LukExecute(Sender: TObject);
    procedure UnderlineExecute(Sender: TObject);
  private
    { private declarations }
    procedure FontStyleModify(fs: TFontStyle);
  public
    { public declarations }
    IndholdAendret : Boolean;
  end;

var
  Hol_Editor_Form: THol_Editor_Form;

implementation

{$R *.lfm}

{ THol_Editor_Form }

Uses HolbaekConst;

//**********************************************************
// Close
//**********************************************************
procedure THol_Editor_Form.LukExecute(Sender: TObject);
begin
  Close;
end;

//**********************************************************
// Underline
//**********************************************************
procedure THol_Editor_Form.UnderlineExecute(Sender: TObject);
begin
  FontStyleModify(fsUnderline);
end;

//**********************************************************
// Create
//**********************************************************
procedure THol_Editor_Form.FormCreate(Sender: TObject);
begin
  Top  := 10;
  Left := 30;
  ShowHint               := True;
  // Farver
  Font.Color              := H_Window_Baggrund;
  ToolBar1.Color         := H_Menu_knapper_Farve;
  //
  IndholdAendret     := False;

(*  PageColor1.Color       := H_Panel_Overskrift;
  PageColor1.Align       := alClient;
  *)
end;

//**********************************************************
// SaetFont
//**********************************************************
procedure THol_Editor_Form.SaetFontExecute(Sender: TObject);
var
  f : TFontParams;
begin
  RichMemo1.GetTextAttributes(RichMemo1.SelStart, f);
  FontDialog1.Font.Name:=f.Name;
  FontDialog1.Font.Size:=f.Size;
  FontDialog1.Font.Style:=f.Style;
  FontDialog1.Font.Color:=f.Color;
  if FontDialog1.Execute then
    begin
      RichMemo1.SetRangeParams(RichMemo1.SelStart, RichMemo1.SelLength
        , [tmm_Color, tmm_Size, tmm_Name]
        , FontDialog1.Font.Name
        , FontDialog1.Font.Size
        , FontDialog1.Font.Color, [], []);
    end;
end;

//**********************************************************
// Bold
//**********************************************************
procedure THol_Editor_Form.BoldExecute(Sender: TObject);
begin
  FontStyleModify(fsBold);
end;

//**********************************************************
// Left align
//**********************************************************
procedure THol_Editor_Form.LeftAlignExecute(Sender: TObject);
begin
  RichMemo1.SetParaAlignment( RichMemo1.SelStart,
    RichMemo1.SelLength, paLeft);
end;

//**********************************************************
// Right align
//**********************************************************
procedure THol_Editor_Form.RightAlignExecute(Sender: TObject);
begin
  RichMemo1.SetParaAlignment( RichMemo1.SelStart,
    RichMemo1.SelLength, paRight);
end;

//**********************************************************
// Italic
//**********************************************************
procedure THol_Editor_Form.ItalicExecute(Sender: TObject);
begin
  FontStyleModify(fsItalic);
end;

//**********************************************************
// Center align
//**********************************************************
procedure THol_Editor_Form.CenterAlignExecute(Sender: TObject);
begin
  RichMemo1.SetParaAlignment( RichMemo1.SelStart,
    RichMemo1.SelLength, paCenter);
end;

//**********************************************************
// Ligesider align
//**********************************************************
procedure THol_Editor_Form.JAalignExecute(Sender: TObject);
begin
  RichMemo1.SetParaAlignment( RichMemo1.SelStart,
    RichMemo1.SelLength, paJustify);
end;

//**********************************************************
// Font SkriftFarve
//**********************************************************
procedure THol_Editor_Form.SkriftFarveExecute(Sender: TObject);
var
  f : TFontParams;
begin
  RichMemo1.GetTextAttributes(RichMemo1.SelStart, f);
  ColorDialog1.Color:=f.Color;
  if ColorDialog1.Execute then begin
    RichMemo1.SetRangeColor( RichMemo1.SelStart, RichMemo1.SelLength,
      ColorDialog1.Color);
  end;
end;

//**********************************************************
// Richmemo change
//**********************************************************
procedure THol_Editor_Form.RichMemo1Change(Sender: TObject);
begin
  IndholdAendret := True;
end;

//**********************************************************
// Åben fil
//**********************************************************
procedure THol_Editor_Form.FileopenExecute(Sender: TObject);
begin
  if RtfOpenDialog.Execute then
    LoadRTFFile( RichMemo1, RtfOpenDialog.FileName);
end;

//**********************************************************
// Gem som
//**********************************************************
procedure THol_Editor_Form.GemSomExecute(Sender: TObject);
var
  fs : TFileStream;
begin
  if RtfSaveDialog.Execute then
    begin
      fs := nil;
      try
        fs := TFileStream.Create( Utf8ToAnsi(RtfSaveDialog.FileName), fmCreate);
        RichMemo1.SaveRichText(fs);
      except
      end;
      fs.Free;
    end;
end;

//**********************************************************
// Font style modify
//**********************************************************
procedure THol_Editor_Form.FontStyleModify(fs: TFontStyle);
var
  f : TFontParams;
  rm  : TFontStyles;
  add : TFontStyles;
begin
  RichMemo1.GetTextAttributes(RichMemo1.SelStart, f);
  if fs in f.Style then begin
    rm:=[fs]; add:=[];
  end else begin
    rm:=[]; add:=[fs];
  end;
  RichMemo1.SetRangeParams(RichMemo1.SelStart, RichMemo1.SelLength
    , [tmm_Styles] , '', 0, 0, add, rm);
end;



end.

