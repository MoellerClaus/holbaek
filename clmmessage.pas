unit clmMessage;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  Buttons, StdCtrls, ExtCtrls;

type
  { TclmMessageDlgForm }

  TclmMessageDlgForm = class(TForm)
    Image1: TImage;
    ImageList1: TImageList;
    Label1: TLabel;
    Label2: TLabel;
    Luk: TBitBtn;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure LukClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;



var
  clmMessageDlgForm: TclmMessageDlgForm;

function clmMessageDlg(aMsg: string; DlgType: TMsgDlgType;
            Buttons: TMsgDlgButtons; const HelpKeyword: string) : TModalResult; overload;

(*function MessageDlg(const aCaption, aMsg: string; DlgType: TMsgDlgType;
            Buttons: TMsgDlgButtons; const HelpKeyword: string): TModalResult; overload;*)


implementation


{ TclmMessageDlgForm }

Function clmMessageDlg(aMsg: string; DlgType: TMsgDlgType;
            Buttons: TMsgDlgButtons; const HelpKeyword: string) : TModalResult;
Begin
  clmMessageDlgForm := TclmMessageDlgForm.Create(Nil);
  Case DlgType of
    mtInformation : clmMessageDlgForm.Caption:= 'Information';
    mtError       : clmMessageDlgForm.Caption:= 'Fejl';
  End; // End case
  clmMessageDlgForm.Label1.Caption:= aMsg;

  clmMessageDlgForm.ShowModal;
  clmMessageDlgForm.Free;
end;

procedure TclmMessageDlgForm.FormCreate(Sender: TObject);
begin

end;

procedure TclmMessageDlgForm.LukClick(Sender: TObject);
begin
  Close;
end;

initialization
  { $I clmMessage.lrs}

end.

