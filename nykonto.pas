//***************************************************************************//
//  Holbæk                                                                   //
//  Copyright by Claus Moeller 2013-2016                                     //
//  Ny konto                                                                 //
//  Version                                                                  //
//  06.12.2016                                                               //
//***************************************************************************//

unit NyKonto;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  ComCtrls, ExtCtrls, Grids, ActnList, Menus, StdCtrls, Buttons, DbCtrls,
  clmCombobox, db;

type

  { TNyKontiForm }

  TNyKontiForm = class(TForm)
    Aendre: TAction;
    Bevel1: TBevel;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    CheckDirekte: TCheckBox;
    CheckD: TCheckBox;
    CheckSpaerring: TCheckBox;
    CheckVisIkkeTekst: TCheckBox;
    CheckVisningDK: TCheckBox;
    CheckAfstembar: TCheckBox;
    ModCombobox: TclmCombobox;
    ComboFormaal: TComboBox;
    EditGenvej: TEdit;
    Help: TAction;
    CheckSumMed: TCheckBox;
    ComboMoms: TComboBox;
    ComboSumUdregnes: TComboBox;
    EditStandardTekst: TEdit;
    EditSumFra: TEdit;
    EditSumTil: TEdit;
    EditKontonavn: TEdit;
    EditKontoNr: TEdit;
    LabelSDK: TLabel;
    LabelDirekte: TLabel;
    LabelSpaerret: TLabel;
    LabelVisning: TLabel;
    LabelAfstembar: TLabel;
    LabelFormaal: TLabel;
    LabelGenvej: TLabel;
    LabelAfstemning: TLabel;
    LabelMoms: TLabel;
    LabelSumFraKonto: TLabel;
    LabelTil: TLabel;
    LabelSumUdregnes: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    LabelStandard: TLabel;
    Opret: TAction;
    ComboType: TComboBox;
    ImageList1: TImageList;
    Label1: TLabel;
    Luk: TAction;
    ActionList1: TActionList;
    MenuItem1: TMenuItem;
    PopupMenu1: TPopupMenu;
    StatusBar1: TStatusBar;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    procedure AendreExecute(Sender: TObject);
    procedure ComboTypeChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure HelpExecute(Sender: TObject);
    procedure LukExecute(Sender: TObject);
    procedure OpretExecute(Sender: TObject);
  private
    { private declarations }
    MomsKodeListe      : TStringList;
    MomsKodeNrListe    : TStringList;
    FormaalNrListe     : TStringList;
    Procedure Indstil;
    Procedure IndlaesModkonto;
    Procedure IndlaesMomsKoder;
    Procedure IndlaesOkoMaerker;
  public
    { public declarations }
    VisOpret   : Boolean;
    KontoNr    : Integer;
    GammelType : Integer;
  end;

var
  NyKontiForm: TNyKontiForm;

implementation

{$R *.lfm}

{ TNyKontiForm }

Uses HolbaekConst, HolbaekMain, MainData, PickKonto;

//**********************************************************
// Create
//**********************************************************
procedure TNyKontiForm.FormCreate(Sender: TObject);
begin
  Position := poDesigned;
  (*Top := 10;
  Left := 30;*)
  // Farver
  ToolBar1.Color    := H_Menu_knapper_Farve;
  StatusBar1.Color  := H_Menu_knapper_Farve;;
  EditKontoNr.Color := H_Edit_Baggrund;
  Color := H_Window_Baggrund;
  // Database
  MainDataModule.ZQuery1.Connection := MainDataModule.ZConnection1;
  // Indlæs
  MomsKodeListe                  := TStringList.Create;
  MomsKodeListe.Sorted           := True;
  MomsKodeNrListe                := TStringList.Create;
  MomsKodeNrListe.Sorted         := False;
  FormaalNrListe                 := TStringList.Create;
  FormaalNrListe.Sorted          := False;

  Indstil;
  IndlaesModKonto;
  IndlaesMomskoder;
  IndlaesOkoMaerker;

  // Andet
  ComboMoms.Items.Clear;
  ComboMoms.Items.AddStrings(MomskodeListe);
  ComboMoms.ItemIndex:=0;
  VisOpret := True;
end;

//**********************************************************
// Destroy
//**********************************************************
procedure TNyKontiForm.FormDestroy(Sender: TObject);
begin
  FormaalNrListe.Free;
  MomsKodeNrListe.Free;
  MomsKodeListe.Free;
end;

//**********************************************************
// Indstil
//**********************************************************
Procedure TNyKontiForm.Indstil;
Begin
  With ComboType.Items do
    Begin
      Clear;
      add('Drift');
      add('Status');
      add('Sum');
      add('Tekst');
    end;
  ComboType.ItemIndex := 0;
  ComboTypeChange(Self);
end;

//**********************************************************
// Hjælp
//**********************************************************
procedure TNyKontiForm.HelpExecute(Sender: TObject);
begin
  ShowMessage('Hjælp');
end;


//**********************************************************
// Form activate
//**********************************************************
procedure TNyKontiForm.FormActivate(Sender: TObject);
Var Found : Boolean;
begin
  If VisOpret Then
    Begin
      Caption := 'Opret konto';
      Aendre.Visible:= False;
    end
  Else
    Begin
      Caption := 'Ændre konto';
      Opret.Visible := False;
      MainDataModule.ZQuery1.Close;
      With MainDataModule.ZQuery1.SQL do
      Begin
        Clear;
        Add('Select * from kontobes where Afd = ' + CurrentAfd +
            ' and id = ' + IntToStr(KontoNr));
      End;
      MainDataModule.ZQuery1.Open;
      If MainDataModule.ZQuery1.RecordCount <> 1 Then
        Begin
          MessageDlg('Konto ikke fundet',mtInformation,[mbOk],0);
          Exit;
        end;
      ComboType.ItemIndex := MainDataModule.ZQuery1.FieldByName('Type').AsInteger;
      EditKontoNr.Text    := MainDataModule.ZQuery1.FieldByName('BrugerKonto').AsString;
      EditKontoNavn.Text  := MainDataModule.ZQuery1.FieldByName('beskrivelse').AsString;
      CheckVisIkkeTekst.Checked := MainDataModule.ZQuery1.FieldByName('visikketekst').AsBoolean;
      If MainDataModule.ZQuery1.FieldByName('momskode').IsNull Then
        Begin
          ComboMoms.ItemIndex := -1;
        end
      Else
        Begin
          ComboMoms.ItemIndex       :=
            MomskodeNrListe.IndexOf(MainDataModule.ZQuery1.FieldByName('momskode').AsString);
        end;
      EditSumFra.Text      := MainDataModule.ZQuery1.FieldByName('fra').AsString;
      EditSumTil.Text      := MainDataModule.ZQuery1.FieldByName('til').AsString;
      CheckSumMed.Checked  := MainDataModule.ZQuery1.FieldByName('summed').AsBoolean;
      If MainDataModule.ZQuery1.FieldByName('sumtype').IsNull Then
        Begin
          ComboSumUdregnes.ItemIndex := -1;
        end
      Else
        Begin
          ComboSumUdregnes.ItemIndex := ComboSumUdregnes.Items.IndexOf(
            MainDataModule.ZQuery1.FieldByName('sumtype').AsString);
        end;
      EditStandardTekst.Text   := MainDataModule.ZQuery1.FieldByName('DefaultTekst').AsString;
      CheckD.Checked           := MainDataModule.ZQuery1.FieldByName('Default_d').AsBoolean;
      CheckDirekte.Checked     := MainDataModule.ZQuery1.FieldByName('Direkte').AsBoolean;
      CheckSpaerring.Checked   := MainDataModule.ZQuery1.FieldByName('spaerret').AsBoolean;
      CheckAfstembar.Checked   := MainDataModule.ZQuery1.FieldByName('afstembar').AsBoolean;
      CheckVisningDK.Checked   := MainDataModule.ZQuery1.FieldByName('visningD_K').AsBoolean;
      If MainDataModule.ZQuery1.FieldByName('OkoNr').IsNull Then
        Begin
          ComboFormaal.ItemIndex := -1;
        end
      Else
        Begin
          ComboFormaal.ItemIndex := FormaalNrListe.IndexOf(
            MainDataModule.ZQuery1.FieldByName('OkoNr').AsString);
        end;
      EditGenvej.Text          := MainDataModule.ZQuery1.FieldByName('KGB').AsString;
      // ShowMessage(MainDataModule.ZQuery1.FieldByName('DefaultModkonto').AsString);
      If MainDataModule.ZQuery1.FieldByName('DefaultModkonto').IsNull Then
        Begin
          ModCombobox.ItemIndex := 0;
        end
      Else
        Begin
          Try
            ModCombobox.ItemIndex := ModCombobox.IndexInColumnOf(2,MainDataModule.ZQuery1.FieldByName('DefaultModkonto').AsString);
          except
          end;
        end;
    end;
end;

//**********************************************************
// Form close
//**********************************************************
procedure TNyKontiForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  CloseAction := caFree;
end;

//**********************************************************
// Combotype change
//**********************************************************
procedure TNyKontiForm.ComboTypeChange(Sender: TObject);
begin
  Case ComboType.ItemIndex of
    0 : Begin // Drift
          LabelSumFraKonto.Visible   := False;
          EditSumFra.Visible         := False;
          EditSumTil.Visible         := False;
          LabelTil.Visible           := False;
          CheckSumMed.Visible        := False;
          LabelSumUdregnes.Visible   := False;
          ComboSumUdregnes.Visible   := False;

          LabelMoms.Visible          := True;
          ComboMoms.Visible          := True;
          LabelStandard.Visible      := True;
          EditStandardTekst.Visible  := True;
          LabelSDK.Visible           := True;
          CheckD.Visible             := True;
          LabelDirekte.Visible       := True;
          CheckDirekte.Visible       := True;
          LabelSpaerret.Visible      := True;
          CheckSpaerring.Visible     := True;
          LabelAfstembar.Visible     := True;
          CheckAfstembar.Visible     := True;
          LabelVisning.Visible       := True;
          CheckVisningDK.Visible     := True;
          LabelFormaal.Visible       := True;
          ComboFormaal.Visible       := True;
          LabelGenvej.Visible        := True;
          EditGenvej.Visible        := True;
          LabelAfstemning.Visible    := True;
          CheckVisIkkeTekst.Visible  := False;
        End;
    1 : Begin // Status
          LabelSumFraKonto.Visible   := False;
          EditSumFra.Visible         := False;
          EditSumTil.Visible         := False;
          LabelTil.Visible           := False;
          CheckSumMed.Visible        := False;
          LabelSumUdregnes.Visible   := False;
          ComboSumUdregnes.Visible   := False;

          LabelMoms.Visible          := True;
          ComboMoms.Visible          := True;
          LabelStandard.Visible      := True;
          EditStandardTekst.Visible  := True;
          LabelSDK.Visible           := True;
          CheckD.Visible             := True;
          LabelDirekte.Visible       := True;
          CheckDirekte.Visible       := True;
          LabelSpaerret.Visible      := True;
          CheckSpaerring.Visible     := True;
          LabelAfstembar.Visible     := True;
          CheckAfstembar.Visible     := True;
          LabelVisning.Visible       := True;
          CheckVisningDK.Visible     := True;
          LabelFormaal.Visible       := True;
          ComboFormaal.Visible       := True;
          LabelGenvej.Visible        := True;
          EditGenvej.Visible         := True;
          LabelAfstemning.Visible    := True;

          CheckVisIkkeTekst.Visible  := False;
        End;
    2 : Begin // Sum
          LabelSumFraKonto.Visible   := True;
          EditSumFra.Visible         := True;
          EditSumTil.Visible         := True;
          LabelTil.Visible           := True;
          CheckSumMed.Visible        := True;
          LabelSumUdregnes.Visible   := True;
          ComboSumUdregnes.Visible   := True;
          LabelMoms.Visible          := False;
          ComboMoms.Visible          := False;
          LabelStandard.Visible      := False;
          EditStandardTekst.Visible  := False;
          LabelSDK.Visible           := False;
          CheckD.Visible             := False;
          LabelDirekte.Visible       := False;
          CheckDirekte.Visible       := False;
          LabelSpaerret.Visible      := False;
          CheckSpaerring.Visible     := False;
          LabelAfstembar.Visible     := False;
          CheckAfstembar.Visible     := False;
          LabelVisning.Visible       := False;
          CheckVisningDK.Visible     := False;
          LabelFormaal.Visible       := False;
          ComboFormaal.Visible       := False;
          LabelGenvej.Visible        := False;
          EditGenvej.Visible         := False;
          LabelAfstemning.Visible    := False;

          CheckVisIkkeTekst.Visible  := False;
        End;
    3 : Begin // Tekst
          LabelSumFraKonto.Visible   := False;
          EditSumFra.Visible         := False;
          EditSumTil.Visible         := False;
          LabelTil.Visible           := False;
          CheckSumMed.Visible        := False;
          LabelSumUdregnes.Visible   := False;
          ComboSumUdregnes.Visible   := False;
          LabelMoms.Visible          := False;
          ComboMoms.Visible          := False;
          LabelStandard.Visible      := False;
          EditStandardTekst.Visible  := False;
          LabelSDK.Visible           := False;
          CheckD.Visible             := False;
          LabelDirekte.Visible       := False;
          CheckDirekte.Visible       := False;
          LabelSpaerret.Visible      := False;
          CheckSpaerring.Visible     := False;
          LabelAfstembar.Visible     := False;
          CheckAfstembar.Visible     := False;
          LabelVisning.Visible       := False;
          CheckVisningDK.Visible     := False;
          LabelFormaal.Visible       := False;
          ComboFormaal.Visible       := False;
          LabelGenvej.Visible        := False;
          EditGenvej.Visible         := False;
          LabelAfstemning.Visible    := False;

          CheckVisIkkeTekst.Visible  := True;
        End;
  end;
end;

//**********************************************************************
// Ændre
//**********************************************************************
procedure TNyKontiForm.AendreExecute(Sender: TObject);
Var Stop    : Boolean;
begin
  Stop := False;
  // Undersøg om konto hvis konto ændres til sum eller tekst at der ikke er bilag
  If (GammelType <> ComboType.ItemIndex) and (ComboType.ItemIndex > 1) then
    Begin //Sum,tekst
      { TODO : Undersøg om bilag inden ændring af kontotype }
(*      BilagTabel.First;
      While (not stop) and (not BilagTabel.Eof) Do
        Begin
          Stop := (BilagTabel.FieldByName('Konto').AsInteger = NrPaaKonto);
          If Not Stop Then BilagTabel.Next;
        End;*)
    End;
  If Stop Then
    Begin
      MessageDlg('Der er konteret bilag og derfor kan der ikke ændres til ' +
        ComboType.Items[ComboType.ItemIndex],mtInformation,[mbOk],0);
      Exit;
    End;
  Try
    MainDataModule.ZQuery1.Close;
    With MainDataModule.ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from kontobes where Afd = ' + CurrentAfd +
          ' and id = ' + IntToStr(KontoNr));
    End;
    MainDataModule.ZQuery1.Open;
    MainDataModule.ZQuery1.Edit;
    MainDataModule.ZQuery1.FieldByName('Afd').AsString := CurrentAfd;
    MainDataModule.ZQuery1.FieldByName('Beskrivelse').AsString := EditKontoNavn.Text;
    If ComboMoms.Visible Then
      Begin
        If ComboMoms.Text = '' Then
          Begin
            MainDataModule.ZQuery1.FieldByName('Momskode').Clear;
          end
        else
          Begin
            MainDataModule.ZQuery1.FieldByName('Momskode').AsString  :=
            MomskodeNrListe.Strings[MomskodeLIste.IndexOf(ComboMoms.Text)];
          end;
      end;
    If EditGenvej.Visible Then
      Begin
        MainDataModule.ZQuery1.FieldByName('KGB').AsString := EditGenvej.Text;
      End;
    MainDataModule.ZQuery1.FieldByName('Type').AsInteger := ComboType.ItemIndex;
     If ComboType.Text = 'Sum' Then
      Begin
        MainDataModule.ZQuery1.FieldByName('Fra').AsString := EditSumFra.Text;
        MainDataModule.ZQuery1.FieldByName('Til').AsString := EditSumTil.Text;
        MainDataModule.ZQuery1.FieldByName('SumMed').AsBoolean := CheckSumMed.Checked;
        MainDataModule.ZQuery1.FieldByName('SumType').AsInteger := ComboSumUdregnes.ItemIndex;
        // Direkte
        MainDataModule.ZQuery1.FieldByName('Direkte').AsBoolean := False;
      End
    Else
      Begin
        MainDataModule.ZQuery1.FieldByName('Fra').Clear;
        MainDataModule.ZQuery1.FieldByName('Til').Clear;
        MainDataModule.ZQuery1.FieldByName('SumMed').AsBoolean := False;
        MainDataModule.ZQuery1.FieldByName('SumType').AsInteger := 0;
      End;
    // Direkte
    MainDataModule.ZQuery1.FieldByName('Direkte').AsBoolean := CheckDirekte.Checked;
    // D-K
    MainDataModule.ZQuery1.FieldByName('Default_D').AsBoolean := CheckD.Checked;
    // Default_tekst
    MainDataModule.ZQuery1.FieldByName('DefaultTekst').AsString := EditStandardTekst.Text;
    // Spærret
    MainDataModule.ZQuery1.FieldByName('Spaerret').AsBoolean := CheckSpaerring.Checked;
    // Afstembar
    MainDataModule.ZQuery1.FieldByName('Afstembar').AsBoolean := CheckAfstembar.Checked;
    // Visning D-K
    MainDataModule.ZQuery1.FieldByName('Visningd_k').AsBoolean := CheckVisningDK.Checked;
    // Default modkonto
    MainDataModule.ZQuery1.FieldByName('DefaultModkonto').AsString := ModCombobox.Cells[2,ModCombobox.ItemIndex];
    // Dato for rettelse
    MainDataModule.ZQuery1.FieldByName('RettetD').AsString  := DateToSTr(Now);
    If ComboType.Text = 'Tekst' Then
      Begin // Kun for tekst konti
        // Vis ikke tekst
        MainDataModule.ZQuery1.FieldByName('VisIkkeTekst').AsBoolean := CheckVisIkkeTekst.Checked;
      End;
    // Default formål
    If ComboFormaal.ItemIndex > 0 Then
      Begin
        MainDataModule.ZQuery1.FieldByName('OkoNr').AsString := FormaalNrListe.Strings[ComboFormaal.ItemIndex];
      end
    Else
      Begin
        MainDataModule.ZQuery1.FieldByName('OkoNr').Clear;
      end;
    // Gem
    MainDataModule.ZQuery1.Post;
    MainDataModule.ZQuery1.ApplyUpdates();
    ModalResult := mrOK;
  Except
    MessageDlg('Ændringer kunne ikke indsættes!',mtError,[mbOK],0);
    MainDataModule.ZQuery1.CancelUpdates;
    Exit;
  End;
  Close;
end;

//**********************************************************************
// Luk
//**********************************************************************
procedure TNyKontiForm.LukExecute(Sender: TObject);
begin
  Close;
end;


//**********************************************************************
// Opret
//**********************************************************************
procedure TNyKontiForm.OpretExecute(Sender: TObject);
begin
  Try
    With MainDataModule.ZQuery1 do
      Begin
        Close;
        SQL.Clear;
        SQL.Text := 'Select * from kontobes';
        Open;
        Append;
        Edit;
        FieldByName('Afd').AsString           := CurrentAfd;
        FieldByName('BrugerKonto').AsString   := EditKontoNr.Text;
        FieldByName('Beskrivelse').AsString   := EditKontoNavn.Text;
        If ComboType.Text = 'Drift' Then
          Begin
            FieldByName('Type').AsInteger := 0;
          End
        Else
          If ComboType.Text = 'Status' Then
            Begin
              FieldByName('Type').AsInteger := 1;
            End
          Else
            If ComboType.Text = 'Sum' Then
              Begin
                FieldByName('Type').AsInteger := 2;
              End
            Else
              If ComboType.Text = 'Tekst' Then
                Begin
                  FieldByName('Type').AsInteger := 3;
                End
              Else
                Begin // Default
                  FieldByName('Type').AsInteger := 0;
                end;
        If ComboMoms.Visible Then
          Begin
            If ComboMoms.Text = '' Then
              Begin
                FieldByName('Momskode').Clear;
              end
            else
              Begin
                FieldByName('Momskode').AsString  :=
                MomskodeNrListe.Strings[MomskodeLIste.IndexOf(ComboMoms.Text)];
              end;
          end;
        If EditSumFra.Visible Then
          Begin
            FieldByName('fra').AsString      := EditSumFra.Text;
            FieldByName('til').AsString      := EditSumTil.Text;
            FieldByName('summed').AsBoolean  := CheckSumMed.Checked;
            FieldByName('summed').AsBoolean  := CheckSumMed.Checked;
            // Direkte
            FieldByName('Direkte').AsBoolean := False;
          end
        Else
          Begin
            FieldByName('Fra').Clear;
            FieldByName('Til').Clear;
            FieldByName('SumMed').AsBoolean := False;
            FieldByName('SumType').AsInteger := 0;
            // Direkte
            FieldByName('Direkte').AsBoolean := CheckDirekte.Checked;
          End;
        // D-K
        FieldByName('Default_D').AsBoolean := CheckD.Checked;
        // Default_tekst
        FieldByName('DefaultTekst').AsString := EditStandardTekst.Text;
        // Spærret
        FieldByName('Spaerret').AsBoolean := CheckSpaerring.Checked;
        // Afstembar
        //FieldByName('Afstembar').AsBoolean := CheckAfstembar.Checked;
        // Dato for rettelse
        FieldByName('RettetD').AsString  := DateToStr(Now);
        // Visning D-K
        FieldByName('visningd_k').AsBoolean := CheckVisningDK.Checked;
        // Default modkonto
        FieldByName('DefaultModkonto').Clear;;
          //ComboDefaultMod.ColumnItems[ComboDefaultMod.ItemIndex,2];
        If ComboType.Text = 'Tekst' Then
          Begin // Kun for tekst konti
            // Vis ikke tekst
            FieldByName('VisIkkeTekst').AsBoolean := CheckVisIkkeTekst.Checked;
          End;
        // Default formål
        If ComboFormaal.ItemIndex > 0 Then
          Begin
            FieldByName('OkoNr').AsString := FormaalNrListe.Strings[ComboFormaal.ItemIndex];
          end
        Else
          Begin
            FieldByName('OkoNr').Clear;
          end;
        // Gem
        Post;
        ApplyUpdates;
        ModalResult := mrOk;
      End;
  Except
    MessageDlg('Konto kunne ikke oprettes!',mtError,[mbOk],0);
    MainDataModule.ZQuery1.CancelUpdates;
    Exit;
  end;
end;

//**********************************************************************
// Indlæs modkonti
//**********************************************************************
procedure TNyKontiForm.IndlaesModkonto;
Var Nr : LongInt;
Begin
  Try
    With MainDataModule.ZQuery1.SQL do
      Begin
        Clear;
        Add('Select * from kontobes where Afd = ' + CurrentAfd);
      End;
    MainDataModule.ZQuery1.Open;
    ModCombobox.Items.Clear;
    ModCombobox.AddRow;
    Nr := 0;
    While not MainDataModule.ZQuery1.EOF Do
      Begin
        ModCombobox.AddRow;
        ModCombobox.Cells[0,Nr] := MainDataModule.ZQuery1.FieldByName('BrugerKonto').AsString;
        ModCombobox.Cells[1,Nr] := MainDataModule.ZQuery1.FieldByName('Beskrivelse').AsString;
        ModCombobox.Cells[2,Nr] := MainDataModule.ZQuery1.FieldByName('id').AsString;
        Inc(Nr);
        MainDataModule.ZQuery1.Next;
      end;
  Except
  End;
end;

//**********************************************************
// Indlæs momskoder
//**********************************************************
Procedure TNyKontiForm.IndlaesMomsKoder;
Var Nr : Integer;
Begin
  // Moms
  MomsKodeListe.Clear;
  MomsKodeListe.Add('');
  MomsKodeNrListe.Add('');
//  MainDataModule.ZQuery1.Active:=False;
  MainDataModule.ZQuery1.Close;
  With MainDataModule.ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from Momskode where Afd = ' + CurrentAfd);
    End;
  MainDataModule.ZQuery1.Open;
//  MainDataModule.ZQuery1.ExecSQL;
//  MainDataModule.ZQuery1.Active:=True;
  If MainDataModule.ZQuery1.RecordCount = 0 Then
    Begin
      Exit;
    end;
  MainDataModule.ZQuery1.First;
  While Not MainDataModule.ZQuery1.Eof Do
    Begin
      Nr := MomsKodeListe.Add(MainDataModule.ZQuery1.FieldByName('Navn').AsString);
      MomskodeNrListe.Insert(Nr,MainDataModule.ZQuery1.FieldByName('Nr').AsString);
      MainDataModule.ZQuery1.Next;
    End;
End;

//**********************************************************
// Indlæs økomærker
//**********************************************************
procedure TNyKontiForm.IndlaesOkoMaerker;
Var A : Integer;
Begin
  ComboFormaal.Items.Clear;
  MainDataModule.ZQuery1.Close;
  With MainDataModule.ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from OkoMaerkeDef where Afd = ' + CurrentAfd);
    End;
  MainDataModule.ZQuery1.Open;
  If MainDataModule.ZQuery1.RecordCount = 0 Then
    Begin
      Exit;
    end;
  // Dummmy ind først
  ComboFormaal.Items.Add('');
  FormaalNrListe.Add('');
  MainDataModule.ZQuery1.First;
  While Not MainDataModule.ZQuery1.EOF Do
    Begin
      A := ComboFormaal.Items.Add(MainDataModule.ZQuery1.FieldByName('Beskrivelse').AsString);
      FormaalNrListe.Insert(A,MainDataModule.ZQuery1.FieldByName('Nr').AsString);
      MainDataModule.ZQuery1.Next;
    end;
  ComboFormaal.ItemIndex := 0;
End;


end.

