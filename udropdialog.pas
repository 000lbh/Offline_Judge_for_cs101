unit UDropDialog;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TDropDialog }

  TDropDialog = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormDropFiles(Sender: TObject; const FileNames: array of String);
    procedure FormShow(Sender: TObject);
  private
    flag:boolean;
  public
    rlt:string;
  end;

var
  DropDialog: TDropDialog;

implementation

{$R *.lfm}

{ TDropDialog }

procedure TDropDialog.Button1Click(Sender: TObject);
begin
  Close;
end;

procedure TDropDialog.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  if not flag then rlt:='';
end;

procedure TDropDialog.FormDropFiles(Sender: TObject;
  const FileNames: array of String);
begin
  if length(FileNames)>1 then begin
    ShowMessage('Not supported multifile yet');
    rlt:='';
  end else begin
    rlt:=FileNames[0];
    flag:=true;
  end;
  Close;
end;

procedure TDropDialog.FormShow(Sender: TObject);
begin
  flag:=false;
end;

end.

