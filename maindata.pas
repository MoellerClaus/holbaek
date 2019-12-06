//***************************************************************************//
//  Holbæk                                                                   //
//  Copyright by Claus Moeller 2013-2016                                     //
//  Main data                                                                //
//  Version                                                                  //
//  07.12.16                                                                 //
//***************************************************************************//
unit maindata;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqlite3conn, sqldb, db, FileUtil, Controls, ZConnection,
  ZDataset;

type

  { TMainDataModule }

  TMainDataModule = class(TDataModule)
    DataSource1: TDataSource;
    ImageList1: TImageList;
    ZConnection1: TZConnection;
    ZQuery1: TZQuery;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  MainDataModule: TMainDataModule;

implementation

{$R *.lfm}

end.

