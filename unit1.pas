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
    Button5: TButton;
    Button6: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    OutputArea: TMemo;
    OpenDialog1: TOpenDialog;
    OpenDialog2: TOpenDialog;
    SaveDialog1: TSaveDialog;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
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
const
  BUF_SIZE = 2048;
var
  t:string;
  StringList:TStringList;
  //StringStream:TStringStream;
begin
  Button3.Enabled:=false;
  processA:=TProcess.Create(nil);
  processA.Executable:=Edit3.Text;
  processA.Parameters.Add('OfflineJudge for cs101\OfflineJudge_for_cs101.py');
  processA.Parameters.Add(Edit1.Text);
  processA.Parameters.Add(Edit2.Text);
  processA.PipeBufferSize:=65536;
  processA.Options:=[poUsePipes,poNoConsole,poWaitOnExit,poStderrToOutPut];
  processA.ShowWindow:=swoNone;
  processA.Execute;
  StringList:=TStringList.Create;
  StringList.LoadFromStream(processA.Output);
  OutputArea.Lines.AddStrings(StringList);
  writestr(t,'Judge''s exit code is ',processA.ExitCode);
  OutputArea.Lines.Append(t);
  processA.Free;
  FreeAndNil(StringList);
  Button3.Enabled:=true;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  if OpenDialog2.Execute then Edit3.Text:=OpenDialog2.FileName;
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  //ShowMessage(IntToStr(MessageDlg('Confirm','Are you sure to clear the board?',mtConfirmation,mbYesNo,0,mbNo)));
  if MessageDlg('Confirm','Are you sure to clear the board?',mtConfirmation,mbYesNo,0,mbNo)=6 then begin
    OutputArea.Clear;
  end;
end;

procedure TForm1.Button6Click(Sender: TObject);
var
  t:string;
begin
  if SaveDialog1.Execute then begin
    t:=SaveDialog1.FileName;
    OutputArea.Lines.SaveToFile(t,TEncoding.UTF8);
    ShowMessage('Succeed!');
  end;
end;

end.

