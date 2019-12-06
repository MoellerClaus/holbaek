//***************************************************************************//
//  Holbæk                                                                   //
//  Copyright by Claus Moeller 2013-2014                                     //
//  Aktiviteter - Massetildeling                                             //
//  Version                                                                  //
//  09.02.14                                                                 //
//***************************************************************************//
unit Aktivitet_Masse;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  Grids, Menus, ActnList, ExtCtrls, StdCtrls, EditBtn, clmCombobox,
  JLabeledDateTimeEdit, ZDataset;

type

  { TAktivitetMasseForm }

  TAktivitetMasseForm = class(TForm)
    ComboMaerke: TclmCombobox;
    DateMaerke: TJLabeledDateTimeEdit;
    LabelComboMaerke: TLabel;
    MainMenu1: TMainMenu;
    Swap: TAction;
    AktivitetLabel: TLabel;
    PanelAktivitetHeader: TPanel;
    TagFraFra: TAction;
    OverfoerFraTil: TAction;
    ActionList1: TActionList;
    ComboAktivitet: TclmCombobox;
    ComboPrisKategori: TclmCombobox;
    Help: TAction;
    ImageList1: TImageList;
    LabelComboAktivitet: TLabel;
    LabelComboPrisKategori: TLabel;
    Luk: TAction;
    MenuItem1: TMenuItem;
    ToolBar3: TToolBar;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    VaelgAlle: TAction;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    PopupMenu1: TPopupMenu;
    VaelgIngen: TAction;
    StatusBar1: TStatusBar;
    StringGridFra: TStringGrid;
    StringGridTil: TStringGrid;
    ToolBar1: TToolBar;
    ToolBar2: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ZQuery1: TZQuery;
    ZQuery2: TZQuery;
    ZQueryAntal: TZQuery;
    procedure ComboAktivitetChange(Sender: TObject);
    procedure ComboMaerkeChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure HelpExecute(Sender: TObject);
    procedure LukExecute(Sender: TObject);
    procedure OverfoerFraTilExecute(Sender: TObject);
    procedure SwapExecute(Sender: TObject);
    procedure TagFraFraExecute(Sender: TObject);
    procedure VaelgAlleExecute(Sender: TObject);
    procedure VaelgIngenExecute(Sender: TObject);
    procedure StringGridFraEditingDone(Sender: TObject);
    procedure StringGridFraSelectEditor(Sender: TObject; aCol, aRow: Integer;
      var Editor: TWinControl);
  private
    { private declarations }
    UpdateGrid : Boolean;
    ShowAktivitet : Boolean;

    procedure Indstil;
    procedure IndstilTil;
    procedure IndlaesAktivitet;
    procedure IndlaesPrisKategori;
    procedure IndlaesTilAktivitet;
    procedure GemRowTilTabel;
    procedure IndlaesMaerker;
    procedure IndlaesTilMaerker;
    procedure OverfoerFraTilAktivitet;
    procedure OverfoerFraTilMaerker;
    procedure TagFraFraAktivitet;
    procedure TagFraFraMaerke;
  public
    { public declarations }
    ResultListe       : TStringList;
    procedure IndlaesTilFra;
    procedure IndlaesAlle;
  end;

var
  AktivitetMasseForm: TAktivitetMasseForm;

implementation

{$R *.lfm}

Uses HolbaekMain, HolbaekConst, MainData, DateUtils;

Const

  FormWidth             = 770;
  FormHeight            = 440;

  MasseCheck            : Integer = 0;
  MasseNr               : Integer = 1;
  MasseNavn             : Integer = 2;
  MasseAdr              : Integer = 3;
  MasseMedlemsNr        : Integer = 4;

  MasseTilCheck         : Integer = 0;
  MasseTilNr            : Integer = 1;
  MasseTilNavn          : Integer = 2;
  MasseTilAdr           : Integer = 3;
  MasseTilPris          : Integer = 4;
  MasseTilMedlemsNr     : Integer = 5;
  MasseTilPrisKategori  : Integer = 6;

  { TAktivitetMasseForm }

//**********************************************************
// Create
//**********************************************************
procedure TAktivitetMasseForm.FormCreate(Sender: TObject);
begin
  Position := poDesigned;
  Top      := 10;
  Left     := 30;
  Width    := FormWidth;
  Height   := FormHeight;

  // Farver
  ToolBar1.Color        := H_Menu_knapper_Farve;
  StatusBar1.Color      := H_Menu_knapper_Farve;;
  Color                 := H_Window_Baggrund;
  ComboAktivitet.Color  := H_Combo_Color;
  ComboAktivitet.Columns.Items[0].Color    := H_Combo_Color;;
  ComboPrisKategori.Color                  := H_Combo_Color;
  ComboPrisKategori.Columns.Items[0].Color := H_Combo_Color;;
  PanelAktivitetHeader.Color := H_Page_Color;
  DateMaerke.Color      := H_Combo_Color;
  ComboMaerke.Color     := H_Combo_Color;


  // Database
  ZQuery1.Connection := MainData.MainDataModule.ZConnection1;
  ZQuery2.Connection := MainData.MainDataModule.ZConnection1;
  ZQueryAntal.Connection := MainData.MainDataModule.ZConnection1;

  // Init

  UpdateGrid       := False;
  DateMaerke.Value := Now;
  ShowAktivitet    := True;
  Indstil;
  IndstilTil;

  IndlaesAktivitet;
  IndlaesMaerker;
  IndlaesPrisKategori;
  IndlaesTilAktivitet;


  // Indlaes
  // Initialiser
  ShowHint := True;
  ResultListe := TStringList.Create;
  ResultListe.Sorted := False;
//  IndlaesTilFra;
  ShowAktivitet      := False;
  SwapExecute(sender);
end;

//**********************************************************
// Comboaktivitet change
//**********************************************************
procedure TAktivitetMasseForm.ComboAktivitetChange(Sender: TObject);
begin
  IndlaesTilAktivitet;
end;

//**********************************************************
// Combo Maerke change
//**********************************************************
procedure TAktivitetMasseForm.ComboMaerkeChange(Sender: TObject);
begin
  IndlaesTilMaerker;
end;

//**********************************************************
// Destroy
//**********************************************************
procedure TAktivitetMasseForm.FormDestroy(Sender: TObject);
begin
  ResultListe.Free;
end;

//**********************************************************
// Resize
//**********************************************************
procedure TAktivitetMasseForm.FormResize(Sender: TObject);
begin
  If Width < FormWidth Then
    Begin
      Width := FormWidth;
    end;
  If Height < FormHeight Then
    Begin
      Height := FormHeight;
    end;
end;

//**********************************************************
// Hjælp
//**********************************************************
procedure TAktivitetMasseForm.HelpExecute(Sender: TObject);
begin
  ShowMessage('Hjælp');
end;


//**********************************************************
// Close
//**********************************************************
procedure TAktivitetMasseForm.LukExecute(Sender: TObject);
begin
  Close;
end;


//**********************************************************
// Overfoer fra til aktivitet
//**********************************************************
procedure TAktivitetMasseForm.OverfoerFraTilAktivitet;
Var A : Integer;
    AntalChecked : Integer;
    State        : Boolean;
    HelpStr      : String;
    Stop         : Boolean;
    HelpNr       : Integer;
Begin
  // Alle checkede skal overføres
  If StringGridFra.RowCount < 2 Then
    Begin
      Exit;
    End;
  AntalChecked := 0;
  A := 1;
  While A < StringGridFra.RowCount Do
    Begin
      If StringGridFra.Cells[MasseCheck,A] = '1' Then
        Begin
          Inc(AntalChecked);
        End;
      Inc(A);
    End;
  If (AntalChecked > 0) Then
    Begin
      If MessageDlg('Skal ' + IntToStr(AntalChecked) + ' medlemmer overføres til aktivitet?',
        mtConfirmation,[mbYes,mbNo],0) = MrYes Then
        Begin
          A := 1;
          While A < StringGridFra.RowCount Do
            Begin
              If StringGridFra.Cells[MasseCheck,A] = '1' Then
                Begin // Indsættes
                  // Undersøg om medlem er på aktivitet i forvejen
                  Stop := False;
                  With ZQuery1.SQL do
                    Begin
                      Clear;
                      Add('Select * from aktmed where (afd = ' + CurrentAfd +
                         ') and (medlemsnr = ' + StringGridFra.Cells[MasseMedlemsnr,A] +
                         ') and (banedefnr = ' + ComboAktivitet.Cells[1,ComboAktivitet.ItemIndex] +
                         ')');
                    End;
                  ZQuery1.Open;
                  If ZQuery1.RecordCount <> 0 Then
                    Begin
                      MessageDlg(StringGridFra.Cells[MasseNavn,A] + ' findes på ' +
                      ComboAktivitet.Cells[0,ComboAktivitet.ItemIndex] + ' i forvejen!',
                      mtInformation,[mbOK],0);
                      // Fjern markering
                      StringGridFra.Cells[MasseCheck,A] := '0';
                    End
                  Else
                    Begin
                      // Undersøg om der plads på aktiviten
                      With ZQuery2.SQL do
                        Begin
                          Clear;
                          Add('Select * from aktiviteter where (afd = ' + CurrentAfd +
                             ') and (banedefnr = ' + ComboAktivitet.Cells[1,ComboAktivitet.ItemIndex] +
                             ')');
                        End;
                      ZQuery2.Open;
                      If ZQuery2.RecordCount <> 0 Then
                        Begin // Aktivitet fundet
                          // Er der begrænsninger på aktiviteten ?
                          If Not ZQuery2.FieldByName('MaxOption').IsNull Then
                            Begin // der kan være begrænsinger
                              With ZQueryAntal.SQL do
                                Begin
                                  Clear;
                                  Add('Select * from aktmed where (afd = ' + CurrentAfd +
                                     ') and (banedefnr = ' + ComboAktivitet.Cells[1,ComboAktivitet.ItemIndex] +
                                     ')');
                                End;
                              ZQueryAntal.Open;
                              Case ZQuery2.FieldByName('MaxOption').AsInteger of
                                0 : Begin // Overskriv bare
                                    End;
                                1 : Begin // Tillad ikke flere
                                      // Er der ledige pladser ?
                                      If (ZQueryAntal.RecordCount >=
                                         ZQuery2.FieldByName('MaxAntal').AsInteger) Then
                                        Begin // Ingen pladser
                                          MessageDlg(ComboAktivitet.Cells[0,ComboAktivitet.ItemIndex]
                                             + ' er overtegnet!',mtInformation,[mbOk],0);
                                          Exit;
                                        End;
                                    End;
                                2 : Begin // Tilbyd næste
                                      // Er der ledige pladser ?
                                      If (ZQueryAntal.RecordCount >=
                                         ZQuery2.FieldByName('MaxAntal').AsInteger) Then
                                        Begin // Ingen pladser - tilbyd den næste
                                          // Er der en næste?
                                          If (ZQuery2.FieldByName('NaesteFelt').AsString = '') Then
                                            Begin
                                              MessageDlg('Der er ikke indstillet til en alternativ aktivitet!',mtInformation,[mbOK],0);
                                              Exit;
                                            End;
                                          HelpStr := ZQuery2.FieldByName('NaesteFelt').AsString;
                                          With ZQuery2.SQL do
                                            Begin
                                              Clear;
                                              Add('Select * from aktiviteter where (afd = ' + CurrentAfd +
                                                 ') and (banedefnr = ' + HelpStr + ')');
                                            End;
                                          ZQuery2.Open;
                                          If ZQuery2.RecordCount = 0 Then
                                            Begin
                                              MessageDlg('Alternativ aktivitet kan ikke findes!',mtError,[mbOk],0);
                                              Exit;
                                            End
                                          Else
                                            Begin // Fundet
                                              // Undersøg om der er ledige pladser her.
                                              With ZQueryAntal.SQL do
                                                Begin
                                                  Clear;
                                                  Add('Select * from aktmed where (afd = ' + CurrentAfd +
                                                     ') and (banedefnr = ' + HelpStr + ')');
                                                End;
                                              ZQueryAntal.Open;
                                              // Er der ledige pladser ?
                                              If ZQueryAntal.RecordCount >=
                                                  ZQuery2.FieldByName('MaxAntal').AsInteger Then
                                                Begin // Ingen pladser
                                                  MessageDlg('Aktivitet: ' + ZQuery2.FieldByName('Beskrivelse').AsString
                                                   + #10 + #13 + ' er overtegnet!',mtInformation,[mbOk],0);
                                                  Exit;
                                                End
                                              Else
                                                Begin // Der er pladser
                                                  ComboAktivitet.ItemIndex := ComboAktivitet.IndexInColumnOf(0,ZQuery2.FieldByName('Beskrivelse').AsString);
                                                  If Not MessageDlg('På alternativ aktivitet: ' + #10 + #13 +
                                                    ZQuery2.FieldByName('Beskrivelse').AsString + ' er der plads.' +  #13 + #10 +
                                                    'Skal ' + StringGridFra.Cells[MasseNavn,A] + ' indsættes her istedet?',mtConfirmation,[mbYes,mbNo],0) = mrYes Then
                                                      Begin
                                                        Exit;
                                                      End
                                                End;
                                             End;
                                        End;
                                    End;
                              Else
                                Begin
                                  MessageDlg('Fejl: Maxoption ikke defineret!',mtError,[mbOk],0);
                                  Exit;
                                End;
                              End; // End Case
                            End;   // Undersøg om der plads på aktiviten
                        End
                      Else
                        Begin
                          Begin
                            MessageDlg('Fejl: Aktivitet kunne ikke findes - afbryder',mtError,[mbOk],0);
                            Exit;
                          End;
                        End;
                      Try
                        // Find id
                        With ZQuery2.SQL do
                          Begin
                            Clear;
                            Add('Select * from aktmed order by id');
                          End;
                        ZQuery2.Open;
                        If ZQuery2.RecordCount = 0 Then
                          Begin
                            HelpNr := 1;
                          end
                        Else
                          Begin
                            ZQuery2.Last;
                            HelpNr := ZQuery2.FieldByName('id').AsInteger + 1;
                          end;
                        // Gem
                        ZQuery1.Open;
                        ZQuery1.Append;
                        // Id
                        ZQuery1.FieldByName('Id').AsInteger := HelpNr;
                        // Afd
                        ZQuery1.FieldByName('Afd').AsString := CurrentAfd;
                        // PrisType
                        ZQuery1.FieldByName('PrisType').AsString :=
                          ComboPrisKategori.Cells[2,ComboPrisKategori.ItemIndex];
                        // BaneDefNr
                         ZQuery1.FieldByName('BaneDefNr').AsString :=
                          ComboAktivitet.Cells[1,ComboAktivitet.ItemIndex];
                        // MedlemsNr
                        ZQuery1.FieldByName('MedlemsNr').AsString :=
                          StringGridFra.Cells[MasseMedlemsNr,A];
                        // Akt Dato
                        ZQuery1.FieldByName('Dato').AsFloat := DateTimeToJulianDate(Now);
                        ZQuery1.Post;
                        // Opdater visning
                        // IndlaesFraAktivitet;
                        // Fjern markering
                        StringGridFra.Cells[MasseCheck,A] := '0';
                      Except
                        ZQuery1.Cancel;
                        MessageDlg(StringGridFra.Cells[MasseNavn,A] + ' findes i forvejen på aktivitet',mtInformation,[mbOk],0);
                        Exit;
                      End;
                    End;
                End;
              Inc(A);
            End;
        End
      Else
        Begin
          Exit;
        End;
    End;
  IndlaesTilAktivitet;
end;

//**********************************************************
// Overfoer fra til maerker
//**********************************************************
procedure TAktivitetMasseForm.OverfoerFraTilMaerker;
Var A : Integer;
    AntalChecked : Integer;
    State        : Boolean;
    HelpStr      : String;
    Stop         : Boolean;
    HelpNr       : Integer;
Begin
  // Alle checkede skal overføres
  If StringGridFra.RowCount < 2 Then
    Begin
      Exit;
    End;
  AntalChecked := 0;
  A := 1;
  While A < StringGridFra.RowCount Do
    Begin
      If StringGridFra.Cells[MasseCheck,A] = '1' Then
        Begin
          Inc(AntalChecked);
        End;
      Inc(A);
    End;
  If (AntalChecked > 0) Then
    Begin
      If MessageDlg('Skal ' + IntToStr(AntalChecked) + ' medlemmer overføres til mærke?',
        mtConfirmation,[mbYes,mbNo],0) = MrYes Then
        Begin
          A := 1;
          While A < StringGridFra.RowCount Do
            Begin
              If StringGridFra.Cells[MasseCheck,A] = '1' Then
                Begin // Indsættes
                  // Undersøg om medlem har mærke i forvejen
                  Stop := False;
                  With ZQuery1.SQL do
                    Begin
                      Clear;
                      Add('Select * from marks where (medlemsnr = ' + StringGridFra.Cells[MasseMedlemsnr,A] +
                         ') and (Markid = ' + ComboMaerke.Cells[1,ComboMaerke.ItemIndex] +
                         ')');
                    End;
                  ZQuery1.Open;
                  If ZQuery1.RecordCount <> 0 Then
                    Begin
                      MessageDlg(StringGridFra.Cells[MasseNavn,A] + ' har ' +
                      ComboMaerke.Cells[0,ComboMaerke.ItemIndex] + ' i forvejen!',
                      mtInformation,[mbOK],0);
                    End
                  Else
                    Begin
                      Try
                        // Find id
                        With ZQuery2.SQL do
                          Begin
                            Clear;
                            Add('Select * from marks order by id');
                          End;
                        ZQuery2.Open;
                        If ZQuery2.RecordCount = 0 Then
                          Begin
                            HelpNr := 1;
                          end
                        Else
                          Begin
                            ZQuery2.Last;
                            HelpNr := ZQuery2.FieldByName('id').AsInteger + 1;
                          end;
                        // Gem
                        ZQuery2.Open;
                        ZQuery2.Append;
                        // Id
                        ZQuery2.FieldByName('Id').AsInteger := HelpNr;
                        // Marksid
                        ZQuery2.FieldByName('MarkId').AsString    := ComboMaerke.Cells[1,ComboMaerke.ItemIndex];
                        // MedlemsNr
                        ZQuery2.FieldByName('MedlemsNr').AsString := StringGridFra.Cells[MasseMedlemsnr,A];
                        // Dato
                        ZQuery2.FieldByName('Dato').AsFloat := DateTimeToJulianDate(DateMaerke.Value);
                        ZQuery2.Post;
                        // Opdater visning
                        IndlaesTilMaerker;
                        // Fjern markering
                        StringGridFra.Cells[MasseCheck,A] := '0';
                      Except
                        ZQuery2.Cancel;
                        MessageDlg(StringGridFra.Cells[MasseNavn,A] + ' findes i forvejen på aktivitet',mtInformation,[mbOk],0);
                        Exit;
                      End;
                    End;
                End;
              Inc(A);
            End;
        End
      Else
        Begin
          Exit;
        End;
    End;
  IndlaesTilMaerker;
end;

//**********************************************************
// Overfoer fra til
//**********************************************************
procedure TAktivitetMasseForm.OverfoerFraTilExecute(Sender: TObject);
begin
  If ShowAktivitet Then
    Begin
      OverfoerFraTilAktivitet
    End
  Else
    Begin
      OverfoerFraTilMaerker;
    End;
end;

//**********************************************************
// Swap
//**********************************************************
procedure TAktivitetMasseForm.SwapExecute(Sender: TObject);
begin
  If ShowAktivitet Then
    Begin
      ShowAktivitet := False;
      LabelComboAktivitet.Visible    := False;
      ComboAktivitet.Visible         := False;
      LabelComboPrisKategori.Visible := False;
      ComboPrisKategori.Visible      := False;
      ComboMaerke.Visible            := True;
      DateMaerke.Visible             := True;
      LabelComboMaerke.Visible       := True;

      IndstilTil;
      IndlaesTilMaerker;
    end
  Else
    Begin
      ShowAktivitet := True;
      LabelComboAktivitet.Visible    := True;
      ComboAktivitet.Visible         := True;
      LabelComboPrisKategori.Visible := True;
      ComboPrisKategori.Visible      := True;
      ComboMaerke.Visible            := False;
      DateMaerke.Visible             := False;
      LabelComboMaerke.Visible       := False;

      IndstilTil;
      IndlaesTilAktivitet;
    end;
end;

//**********************************************************
// Tag fra aktivitet
//**********************************************************
procedure TAktivitetMasseForm.TagFraFraAktivitet;
Var A             : Integer;
    AntalChecked  : Integer;
    State         : Boolean;
Begin
  // Alle checkede skal overføres
  If StringGridTil.RowCount < 1 Then
    Begin
      Exit;
    End;
  AntalChecked := 0;
  A := 1;
  While A < StringGridTil.RowCount Do
    Begin
      If StringGridTil.Cells[MasseTilCheck,A] = '1' Then
        Begin
          Inc(AntalChecked);
        End;
      Inc(A);
    End;
  If (AntalChecked > 0) Then
    Begin
      If MessageDlg('Skal ' + IntToStr(AntalChecked) + ' medlemmer fjernes fra aktivitet?',
        mtConfirmation,[mbYes,mbNo],0) = MrYes Then
        Begin
          A := 1;
          While A < StringGridTil.RowCount Do
            Begin
              If StringGridTil.Cells[MasseTilCheck,A] = '1' Then
                Begin // Fjernes
                  // Find aktivitet i aktmed
                  Try
                    With ZQuery2.SQL do
                      Begin
                        Clear;
                        Add('Select * from aktmed where (afd = ' + CurrentAfd +
                         ') and (PrisType = '  + StringGridTil.Cells[MasseTilPrisKategori,A] +
                         ') and (MedlemsNr = ' + StringGridTil.Cells[MasseTilMedlemsNr,A] +
                         ') and (BaneDefNr = ' + ComboAktivitet.Cells[1,ComboAktivitet.ItemIndex] +
                         ')');
                      End;
                    ZQuery2.Open;
                    If ZQuery2.RecordCount = 0 Then
                      Begin
                        MessageDlg('Ikke fundet medlem',mtError,[mbOK],0);
                      end
                    Else
                      Begin
                        ZQuery2.Delete;
                      end;
                  Except
                    MessageDlg('Medlem: ' + StringGridTil.Cells[MasseTilNavn,A] +
                      ' kunne ikke tages af aktivitet!',mtError,[mbOK],0);
                  End;
                End;
              Inc(A);
            End;
          IndlaesTilAktivitet;
        End
      Else
        Begin
          Exit;
        End;
    End;
end;

//**********************************************************
// Tag fra mærke
//**********************************************************
procedure TAktivitetMasseForm.TagFraFraMaerke;
Var A             : Integer;
    AntalChecked  : Integer;
    State         : Boolean;
Begin
  // Alle checkede skal overføres
  If StringGridTil.RowCount < 1 Then
    Begin
      Exit;
    End;
  AntalChecked := 0;
  A := 1;
  While A < StringGridTil.RowCount Do
    Begin
      If StringGridTil.Cells[MasseTilCheck,A] = '1' Then
        Begin
          Inc(AntalChecked);
        End;
      Inc(A);
    End;
  If (AntalChecked > 0) Then
    Begin
      If MessageDlg('Skal ' + IntToStr(AntalChecked) + ' medlemmer(s) mærke fjernes?',
        mtConfirmation,[mbYes,mbNo],0) = MrYes Then
        Begin
          A := 1;
          While A < StringGridTil.RowCount Do
            Begin
              If StringGridTil.Cells[MasseTilCheck,A] = '1' Then
                Begin // Fjernes
                  // Find aktivitet i aktmed
                  Try
                    With ZQuery2.SQL do
                      Begin
                        Clear;
                        Add('Select * from marks where (medlemsnr = ' +
                          StringGridTil.Cells[MasseTilMedlemsNr,A] +
                         ') and (markid = ' + StringGridTil.Cells[MasseTilPrisKategori,A] +
                         ')');
                      End;
                    ZQuery2.Open;
                    If ZQuery2.RecordCount = 0 Then
                      Begin
                        MessageDlg('Ikke fundet medlem!',mtError,[mbOK],0);
                      end
                    Else
                      Begin
                        ZQuery2.Delete;
                      end;
                  Except
                    MessageDlg('For medlem: ' + StringGridTil.Cells[MasseTilNavn,A] +
                      ' kunne mærke ikke fjernes!',mtError,[mbOK],0);
                  End;
                End;
              Inc(A);
            End;
          IndlaesTilMaerker;
        End
      Else
        Begin
          Exit;
        End;
    End;
end;

//**********************************************************
// Tag fra
//**********************************************************
procedure TAktivitetMasseForm.TagFraFraExecute(Sender: TObject);
Begin
  If ShowAktivitet Then
    Begin
      TagFraFraAktivitet;
    End
  Else
    Begin
      TagFraFraMaerke;
    End;
end;

//**********************************************************
// Vaelg Alle
//**********************************************************
procedure TAktivitetMasseForm.VaelgAlleExecute(Sender: TObject);
Var A    : Integer;

begin
  For A := 1 to StringGridFra.RowCount-1 do
    Begin
      StringGridFra.Cells[MasseCheck,A] := '1';
    end;

  (*  // Indsæt
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from aktiviteter order by id');
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount = 0 Then
    Begin
      HelpNr := 1;
    end
  Else
    Begin
      ZQuery1.Last;
      HelpNr := ZQuery1.FieldByName('id').AsInteger + 1;
    end;
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from aktiviteter where afd = ' + CurrentAfd +  ' order by banedefnr');
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount = 0 Then
    Begin
      BaneDefNr := 1;
    end
  Else
    Begin
      ZQuery1.Last;
      BaneDefNr := ZQuery1.FieldByName('banedefnr').AsInteger + 1;
    end;
  Try
    ZQuery1.Append;
    ZQuery1.Edit;
    ZQuery1.FieldByName('Id').AsInteger           := HelpNr;
    ZQuery1.FieldByName('Afd').AsString           := CurrentAfd;
    ZQuery1.FieldByName('BaneDefNr').AsInteger    := BaneDefNr;
    ZQuery1.FieldByName('Beskrivelse').AsString   := 'Aktivitet';
    ZQuery1.FieldByName('ExInfo').AsString        := '';
    ZQuery1.FieldByName('Vis').AsString           := '1';
    ZQuery1.FieldByName('Konto').Clear;
    ZQuery1.FieldByName('ModKonto').Clear;
    ZQuery1.FieldByName('MaxAntal').Clear;
    ZQuery1.FieldByName('MaxOption').Clear;
    ZQuery1.FieldByName('NaesteFelt').Clear;
    // Gem
    ZQuery1.Post;
    ZQuery1.ApplyUpdates;
  Except
    MessageDlg('Aktivitet kunne ikke oprettes!',mtError,[mbOk],0);
    ZQuery1.CancelUpdates;
    Exit;
  end;
  Indlaes;*)
end;

//**********************************************************
// VaelgIngen
//**********************************************************
procedure TAktivitetMasseForm.VaelgIngenExecute(Sender: TObject);
Var A : Integer;
begin
  For A := 1 to StringGridFra.RowCount-1 do
    Begin
      StringGridFra.Cells[MasseCheck,A] := '0';
    end;
end;

//**********************************************************
// Stringgrid Editing done
//**********************************************************
procedure TAktivitetMasseForm.StringGridFraEditingDone(Sender: TObject);
begin
  GemRowTilTabel;
end;

//**********************************************************
// Stringgrid select editor
//**********************************************************
procedure TAktivitetMasseForm.StringGridFraSelectEditor(Sender: TObject; aCol,
  aRow: Integer; var Editor: TWinControl);
begin
  If      aCol = MasseCheck Then
    Begin
      Editor := StringGridFra.EditorByStyle(cbsCheckboxColumn);
    end
  Else If acol = MasseNr Then
    Begin
      Editor := StringGridFra.EditorByStyle(cbsAuto);
    end
  Else If acol = MasseNavn Then
    Begin
      Editor := StringGridFra.EditorByStyle(cbsAuto);
    end
  Else If acol = MasseAdr Then
    Begin
      Editor := StringGridFra.EditorByStyle(cbsAuto);
    end;
end;

//**********************************************************
// Indstil
//**********************************************************
procedure TAktivitetMasseForm.Indstil;
begin
  Indstil_StringGrid_Edit(StringGridFra);

  StringGridFra.Columns.Clear;
  StringGridFra.Columns.Add;
  StringGridFra.Columns.Add;
  StringGridFra.Columns.Add;
  StringGridFra.Columns.Add;
  StringGridFra.Columns.Add;

  StringGridFra.Columns[MasseCheck].Title.Caption          := '*';
  StringGridFra.Columns[MasseCheck].Width                  := 30;
  StringGridFra.Columns[MasseCheck].Alignment              := taCenter;
  StringGridFra.Columns[MasseCheck].ButtonStyle            := cbsCheckboxColumn;

  StringGridFra.Columns[MasseNr].Title.Caption             := 'Nr';
  StringGridFra.Columns[MasseNr].Width                     := 40;
  StringGridFra.Columns[MasseNr].Alignment                 := taRightJustify;
  StringGridFra.Columns[MasseNr].ReadOnly                  := True;

  StringGridFra.Columns[MasseNavn].Title.Caption           := 'Navn';
  StringGridFra.Columns[MasseNavn].Width                   := 120;
  StringGridFra.Columns[MasseNavn].Alignment               := taLeftJustify;
  StringGridFra.Columns[MasseNavn].ReadOnly                := True;

  StringGridFra.Columns[MasseAdr].Title.Caption            := 'Adr';
  StringGridFra.Columns[MasseAdr].Width                    := 120;
  StringGridFra.Columns[MasseAdr].Alignment                := taLeftJustify;
  StringGridFra.Columns[MasseAdr].ReadOnly                 := True;

  StringGridFra.Columns[MasseMedlemsNr].Title.Caption      := 'Id';
  StringGridFra.Columns[MasseMedlemsNr].Width              := 70;
  StringGridFra.Columns[MasseMedlemsNr].Visible            := False;
  StringGridFra.Columns[MasseMedlemsNr].ReadOnly           := True;
end;


//**********************************************************
// Indstil Grid til
//**********************************************************
procedure TAktivitetMasseForm.IndstilTil;
begin
  Indstil_StringGrid_Edit(StringGridTil);

  StringGridTil.Columns.Clear;
  StringGridTil.Columns.Add;
  StringGridTil.Columns.Add;
  StringGridTil.Columns.Add;
  StringGridTil.Columns.Add;
  StringGridTil.Columns.Add;
  StringGridTil.Columns.Add;
  StringGridTil.Columns.Add;

  StringGridTil.Columns[MasseTilCheck].Title.Caption       := '*';
  StringGridTil.Columns[MasseTilCheck].Width               := 30;
  StringGridTil.Columns[MasseTilCheck].Alignment           := taCenter;
  StringGridTil.Columns[MasseTilCheck].ButtonStyle         := cbsCheckboxColumn;

  StringGridTil.Columns[MasseTilNr].Title.Caption          := 'Nr';
  StringGridTil.Columns[MasseTilNr].Width                  := 30;
  StringGridTil.Columns[MasseTilNr].Alignment              := taRightJustify;
  StringGridTil.Columns[MasseTilNr].ReadOnly               := True;

  StringGridTil.Columns[MasseTilNavn].Title.Caption        := 'Navn';
  StringGridTil.Columns[MasseTilNavn].Width                := 120;
  StringGridTil.Columns[MasseTilNavn].Alignment            := taLeftJustify;
  StringGridTil.Columns[MasseTilNavn].ReadOnly             := True;

  StringGridTil.Columns[MasseTilAdr].Title.Caption         := 'Adr';
  StringGridTil.Columns[MasseTilAdr].Width                 := 120;
  StringGridTil.Columns[MasseTilAdr].Alignment             := taLeftJustify;
  StringGridTil.Columns[MasseTilAdr].ReadOnly              := True;

  If ShowAktivitet Then
    Begin
      StringGridTil.Columns[MasseTilPris].Title.Caption        := 'Pris';
      StringGridTil.Columns[MasseTilPris].Width                := 80;
      StringGridTil.Columns[MasseTilPris].Alignment            := taRightJustify;
      StringGridTil.Columns[MasseTilPris].ReadOnly             := True;
    end
  Else
    Begin
      StringGridTil.Columns[MasseTilPris].Title.Caption        := 'Dato';
      StringGridTil.Columns[MasseTilPris].Width                := 80;
      StringGridTil.Columns[MasseTilPris].Alignment            := taRightJustify;
      StringGridTil.Columns[MasseTilPris].ReadOnly             := True;
    end;

  StringGridTil.Columns[MasseTilMedlemsNr].Title.Caption   := 'Id';
  StringGridTil.Columns[MasseTilMedlemsNr].Width           := 70;
  StringGridTil.Columns[MasseTilMedlemsNr].Visible         := False;
  StringGridTil.Columns[MasseTilMedlemsNr].ReadOnly        := True;

  StringGridTil.Columns[MasseTilPrisKategori].Title.Caption:= 'Id';
  StringGridTil.Columns[MasseTilPrisKategori].Width        := 70;
  StringGridTil.Columns[MasseTilPrisKategori].Visible      := False;
  StringGridTil.Columns[MasseTilPrisKategori].ReadOnly     := True;
end;


//**********************************************************
// Indlæs alle
//**********************************************************
procedure TAktivitetMasseForm.IndlaesAlle;
Var A : Integer;
begin
  A := 1;
  ZQuery1.Close;
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from medlem');
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount = 0 Then
    Begin
      StringGridFra.RowCount  := 1;
      MessageDlg('Ingen medlemmer endnu!',mtInformation,[mbOk],0);
      Exit;
    end;
  ZQuery1.First;
  While Not ZQuery1.EOF Do
    Begin
      ResultListe.Add(ZQuery1.FieldByName('MedlemsNr').AsString);
      ZQuery1.Next;
    End;
  IndlaesTilFra;
end;

//**********************************************************
// Indlæs til fra
//**********************************************************
procedure TAktivitetMasseForm.IndlaesTilFra;
Var A      : Integer;
Begin
  UpdateGrid := True;
  A := 1;
  StringGridFra.RowCount  := 1;
  StringGridFra.BeginUpdate;
  While A <= ResultListe.Count Do
    Begin
      With ZQuery1.SQL do
        Begin
          Clear;
          Add('Select * from medlem where medlemsnr = ' + ResultListe.Strings[A-1]);
        End;
      ZQuery1.Open;
      If ZQuery1.RecordCount = 0 Then
        Begin
          StringGridFra.RowCount  := 1;
          MessageDlg('Ingen medlemmer endnu!',mtInformation,[mbOk],0);
          Exit;
        end;
      StringGridFra.RowCount := StringGridFra.RowCount + 1;
      StringGridFra.Cells[MasseCheck,A]     := '0';
      StringGridFra.Cells[MasseNr,A]        := ZQuery1.FieldByName('BrugerMedlemsNr').AsString;
      StringGridFra.Cells[MasseNavn,A]      := ZQuery1.FieldByName('Fornavn').AsString +
        ' ' + ZQuery1.FieldByName('Efternavn').AsString;
      StringGridFra.Cells[MasseAdr,A]       := ZQuery1.FieldByName('Adr1').AsString;
      StringGridFra.Cells[MasseMedlemsNr,A] := ZQuery1.FieldByName('MedlemsNr').AsString;
      Inc(A);
    end;
  StringGridFra.EndUpdate;
  UpdateGrid := False;
end;


//**********************************************************
// Indlæs til aktivitet
//**********************************************************
procedure TAktivitetMasseForm.IndlaesTilAktivitet;
Var A      : Integer;
    HelpNr : Integer;
Begin
  UpdateGrid := True;
  Try
    AktivitetLabel.Caption := ComboAktivitet.Cells[0,ComboAktivitet.ItemIndex];
    A := 1;
    ZQuery1.Close;
    With ZQuery1.SQL do
      Begin
        Clear;
        Add('Select * from aktmed where (afd = ' + CurrentAfd +
          ') and (banedefnr = ' + ComboAktivitet.Cells[1,ComboAktivitet.ItemIndex] +
          ')');
      End;
    ZQuery1.Open;
    If ZQuery1.RecordCount = 0 Then
      Begin
        StringGridTil.RowCount  := 1;
        (*MessageDlg('Ingen på aktiviteten: ' +
          ComboAktivitet.Cells[0,ComboAktivitet.ItemIndex] + ' endnu!',mtInformation,[mbOk],0);*)
        Exit;
      end;
    ZQuery1.First;
    StringGridTil.RowCount  := 1;
    StringGridTil.BeginUpdate;
    While Not ZQuery1.EOF Do // Aktmed
      Begin
        With ZQuery2.SQL do // Medlem
          Begin
            Clear;
            Add('Select * from medlem where medlemsnr = ' +
              ZQuery1.FieldByName('MedlemsNr').AsString);
          End;
        ZQuery2.Open;
        If ZQuery2.RecordCount = 0 Then
          Begin
            MessageDlg('Medlem kan ikke findes!',mtError,[mbOk],0);
            Exit;
          end
        Else
          Begin
            // Pris skal findes
            With ZQueryAntal.SQL do  // Priskategori
              Begin
                Clear;
                Add('Select * from priskategori where pristype = ' +
                  ZQuery1.FieldByName('PrisType').AsString);
              end;
            ZQueryAntal.Open;
            If ZQueryAntal.RecordCount = 0 Then
              Begin
                MessageDlg('Priskategori kan ikke findes!',mtError,[mbOk],0);
                Exit;
              end;
            StringGridTil.RowCount := StringGridTil.RowCount + 1;
            StringGridTil.Cells[MasseTilCheck,A]     := '0';
            StringGridTil.Cells[MasseTilNr,A]        := ZQuery2.FieldByName('BrugerMedlemsNr').AsString;
            StringGridTil.Cells[MasseTilNavn,A]      := ZQuery2.FieldByName('Fornavn').AsString +
              ' ' + ZQuery2.FieldByName('Efternavn').AsString;
            StringGridTil.Cells[MasseTilAdr,A]       := ZQuery2.FieldByName('Adr1').AsString;
            StringGridTil.Cells[MasseTilPris,A]      :=
              FloatToStrF(ZQueryAntal.FieldByName('Pris').AsCurrency,ffNumber,18,2);
            StringGridTil.Cells[MasseTilMedlemsNr,A] := ZQuery1.FieldByName('MedlemsNr').AsString;
            StringGridTil.Cells[MasseTilPrisKategori,A] := ZQuery1.FieldByName('PrisType').AsString;
            Inc(A);
            ZQuery1.Next;
          end;
      end;
    StringGridTil.EndUpdate;
    UpdateGrid := False;
  finally
  end;
end;


//**********************************************************
// Indlæs til mærker
//**********************************************************
procedure TAktivitetMasseForm.IndlaesTilMaerker;
Var A      : Integer;
    HelpNr : Integer;
Begin
  UpdateGrid := True;
  AktivitetLabel.Caption := ComboMaerke.Cells[0,ComboMaerke.ItemIndex];
  A := 1;
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from marks where markid = ' + ComboMaerke.Cells[1,ComboMaerke.ItemIndex]);
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount = 0 Then
    Begin
      StringGridTil.RowCount  := 1;
      Exit;
    end;
  ZQuery1.First;
  StringGridTil.RowCount  := 1;
  StringGridTil.BeginUpdate;
  While Not ZQuery1.EOF Do // Marks
    Begin
      With ZQuery2.SQL do // Medlem
        Begin
          Clear;
          Add('Select * from medlem where medlemsnr = ' +
            ZQuery1.FieldByName('MedlemsNr').AsString);
        End;
      ZQuery2.Open;
      If ZQuery2.RecordCount = 0 Then
        Begin
          MessageDlg('Medlem kan ikke findes!',mtError,[mbOk],0);
          Exit;
        end
      Else
        Begin
          StringGridTil.RowCount := StringGridTil.RowCount + 1;
          StringGridTil.Cells[MasseTilCheck,A]     := '0';
          StringGridTil.Cells[MasseTilNr,A]        := ZQuery2.FieldByName('BrugerMedlemsNr').AsString;
          StringGridTil.Cells[MasseTilNavn,A]      := ZQuery2.FieldByName('Fornavn').AsString +
            ' ' + ZQuery2.FieldByName('Efternavn').AsString;
          StringGridTil.Cells[MasseTilAdr,A]       := ZQuery2.FieldByName('Adr1').AsString;
          StringGridTil.Cells[MasseTilPris,A]      := DateToStr(JulianDateToDateTime(ZQuery1.FieldByName('dato').AsFloat));
          StringGridTil.Cells[MasseTilMedlemsNr,A] := ZQuery1.FieldByName('MedlemsNr').AsString;
          StringGridTil.Cells[MasseTilPrisKategori,A] := ZQuery1.FieldByName('MarkId').AsString;
          Inc(A);
          ZQuery1.Next;
        end;
    end;
  StringGridTil.EndUpdate;
  UpdateGrid := False;
end;


//**********************************************************
// Indlæs aktivitet
//**********************************************************
procedure TAktivitetMasseForm.IndlaesAktivitet;
Var A      : Integer;
    HelpNr : Integer;
Begin
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from aktiviteter where afd = ' + CurrentAfd);
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount = 0 Then
    Begin
      MessageDlg('Ingen aktiviteter defineret endnu!',mtInformation,[mbOk],0);
      Exit;
    end;
  A := 0;
  ZQuery1.First;
  While Not ZQuery1.EOF Do
    Begin
      ComboAktivitet.AddRow;
      ComboAktivitet.Cells[0,A] := ZQuery1.FieldByName('Beskrivelse').asString;
      ComboAktivitet.Cells[1,A] := ZQuery1.FieldByName('BaneDefNr').asString;
      Inc(A);
      ZQuery1.Next;
    end;
  If ComboAktivitet.Items.Count > 0 Then
    ComboAktivitet.ItemIndex := 0;
end;

//**********************************************************
// Indlæs priskategori
//**********************************************************
procedure TAktivitetMasseForm.IndlaesPrisKategori;
Var A      : Integer;
    HelpNr : Integer;
Begin
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from priskategori where afd = ' + CurrentAfd);
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount = 0 Then
    Begin
      MessageDlg('Ingen priskategori defineret endnu!',mtInformation,[mbOk],0);
      Exit;
    end;
  A := 0;
  ZQuery1.First;
  While Not ZQuery1.EOF Do
    Begin
      ComboPrisKategori.AddRow;
      ComboPrisKategori.Cells[0,A] := ZQuery1.FieldByName('Beskrivelse').asString;
      ComboPrisKategori.Cells[1,A] := FloatToStrF(ZQuery1.FieldByName('Pris').AsCurrency,ffNumber,18,2);
      ComboPrisKategori.Cells[2,A] := ZQuery1.FieldByName('PrisType').asString;
      Inc(A);
      ZQuery1.Next;
    end;
  If ComboPrisKategori.Items.Count > 0 Then
    ComboPrisKategori.ItemIndex := 0;
end;

//**********************************************************
// Indlæs maerker
//**********************************************************
procedure TAktivitetMasseForm.IndlaesMaerker;
Var A      : Integer;
    HelpNr : Integer;
Begin
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from markdef');
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount = 0 Then
    Begin
      MessageDlg('Ingen mærker defineret endnu!',mtInformation,[mbOk],0);
      Exit;
    end;
  A := 0;
  ComboMaerke.Items.Clear;
  ZQuery1.First;
  While Not ZQuery1.EOF Do
    Begin
      ComboMaerke.AddRow;
      ComboMaerke.Cells[0,A] := ZQuery1.FieldByName('Beskrivelse').asString;
      ComboMaerke.Cells[1,A] := ZQuery1.FieldByName('Id').asString;
      Inc(A);
      ZQuery1.Next;
    end;
  If ComboMaerke.Items.Count > 0 Then
    ComboMaerke.ItemIndex := 0;
end;

//**********************************************************
// Gem row til tabel
//**********************************************************
procedure TAktivitetMasseForm.GemRowTilTabel;
Var HelpNr : Integer;
Begin
(*  If UpdateGrid Then Exit;
  // Find Record
  With ZQuery1.SQL do
    Begin
      Clear;
      Add('Select * from aktiviteter where id = ' +
           StringGridFra.Cells[BaneId,StringGridFra.Row]);
    End;
  ZQuery1.Open;
  If ZQuery1.RecordCount <> 1 Then
    Begin
      MessageDlg('Aktivitet kan ikke opdateres ;-)!',mtInformation,[mbOk],0);
      Exit;
    end;
  ZQuery1.First;
  Try
    ZQuery1.Edit;
    ZQuery1.FieldByName('BaneDefNr').AsString := StringGridFra.Cells[BaneNr,StringGridFra.Row];
    ZQuery1.FieldByName('Beskrivelse').AsString := StringGridFra.Cells[BaneBesk,StringGridFra.Row];
    ZQuery1.FieldByName('ExInfo').AsString      := StringGridFra.Cells[BaneEx,StringGridFra.Row];
    ZQuery1.FieldByName('Vis').AsString         := StringGridFra.Cells[BaneVis,StringGridFra.Row];
    // Konto
    HelpNr := KontoBeskListe.IndexOf(StringGridFra.Cells[BaneKonto,StringGridFra.Row]);
    If HelpNr = -1 Then
      ZQuery1.FieldByName('Konto').Clear
    Else
      ZQuery1.FieldByName('Konto').AsInteger := HelpNr;
    // Modkonto
    HelpNr := KontoBeskListe.IndexOf(StringGridFra.Cells[BaneModKonto,StringGridFra.Row]);
    If HelpNr = -1 Then
      ZQuery1.FieldByName('ModKonto').Clear
    Else
      ZQuery1.FieldByName('ModKonto').AsInteger := HelpNr;
    // MaxOption
    HelpNr := MaxOptionListe.IndexOf(StringGridFra.Cells[BaneMaxOption,StringGridFra.Row]);
    If HelpNr = -1 Then
      ZQuery1.FieldByName('MaxOption').Clear
    Else
      ZQuery1.FieldByName('MaxOption').AsInteger := HelpNr;
    // Naestefelt
    HelpNr := NaesteBeskListe.IndexOf(StringGridFra.Cells[BaneNaesteFelt,StringGridFra.Row]);
    If HelpNr = -1 Then
      ZQuery1.FieldByName('NaesteFelt').Clear
    Else
      ZQuery1.FieldByName('NaesteFelt').AsInteger := HelpNr;
    // Id
    ZQuery1.FieldByName('Id').AsString          := StringGridFra.Cells[BaneId,StringGridFra.Row];
    // Gem
    ZQuery1.Post;
    ZQuery1.ApplyUpdates;
  Except
    ZQuery1.CancelUpdates;
    MessageDlg('Aktivitet blev ikke gemt!',mtError,[mbOK],0);
    Exit;
  End;*)
end;

end.

