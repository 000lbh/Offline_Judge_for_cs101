unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Menus,
  Process;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    OpenDialog1: TOpenDialog;
    OpenDialog2: TOpenDialog;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    fileSelected,dirSelected:boolean;
    processA:TProcess;
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  fileSelected:=false;
  dirSelected:=false;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  if OpenDialog1.Execute then begin
    fileSelected:=true;
    Edit1.Text:=OpenDialog1.FileName;
    if dirSelected then Button3.Enabled:=true;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  if SelectDirectoryDialog1.Execute then begin
    dirSelected:=true;
    Edit2.Text:=SelectDirectoryDialog1.FileName;
    if fileSelected then Button3.Enabled:=true;
  end;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  Button3.Enabled:=false;
  processA:=TProcess.Create(nil);
  processA.Executable:=Edit3.Text;
  processA.Parameters.Add('OfflineJudge for cs101\OfflineJudge_for_cs101.py');
  processA.Parameters.Add(Edit1.Text);
  processA.Parameters.Add(Edit2.Text);
  processA.Options:=processA.Options+[poWaitOnExit,poNewConsole];
  processA.ShowWindow:=swoShow;
  processA.Execute;
  processA.Free;
  Button3.Enabled:=true;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  if OpenDialog2.Execute then Edit3.Text:=OpenDialog2.FileName;
end;

end.

