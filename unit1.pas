unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Menus,
  ActnList, DBCtrls, Process, unit2, UDropDialog, XMLRead, XMLUtils,XMLReader,
  XMLTextReader, DOM;

type

  { EXMLFormatError }

  EXMLFormatError = class(Exception)
  private
  public
    constructor Create(const msg:string);
  end;

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button10: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    CheckBox1: TCheckBox;
    ComboBox1: TComboBox;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    OutputArea: TMemo;
    OpenDialog1: TOpenDialog;
    OpenDialog2: TOpenDialog;
    SaveDialog1: TSaveDialog;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    procedure Button10Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    fileSelected,dirSelected:boolean;
    processA:TProcess;
    Settings:TXMLDocument;
    Script:TDOMNode;
    ScriptList:TDOMNodeList;
    function getDropFileName:string;
  public
    ScriptSrcs:TStringList;
    ScriptNum:integer;
  end;

var
  Form1: TForm1;

function CreateJudgeThread(p:pointer):ptrint;

implementation

{$R *.lfm}

{ EXMLFormatError }

constructor EXMLFormatError.Create(const msg:string);
begin
  inherited Create(msg);
end;

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
var
  i:integer;
begin
  fileSelected:=false;
  dirSelected:=false;
  ScriptSrcs:=TStringList.Create;
  try
    ReadXMLFile(Settings,'Settings.xml');
    if lowercase(Settings.DocumentElement.NodeName)<>'settings' then
      raise EXMLFormatError.Create('Invalid XML format!');
    ScriptNum:=StrToInt(Settings.DocumentElement.GetAttribute('n'));
    ScriptList:=Settings.GetElementsByTagName('script');
    for i:=1 to ScriptNum do begin
        Script:=ScriptList[i-1];
        ComboBox1.Items.Add(Script.Attributes.GetNamedItem('id').NodeValue+'.'+Script.TextContent);
        ScriptSrcs.Add(Script.Attributes.GetNamedItem('src').NodeValue);
        //ShowMessage(Script.Attributes.GetNamedItem('id').NodeValue+Script.TextContent);
    end;
    ComboBox1.ItemIndex:=0;
  except
    on E:EXMLReadError do begin
      ShowMessage('Invalid XML format!');
      Application.Terminate;
      end;
  end;
end;

function TForm1.getDropFileName: string;
begin
  DropDialog.ShowModal;
  exit(DropDialog.rlt);
end;

function CreateJudgeThread(p:pointer): ptrint;
var
  t:string;
  StringList:TStringList;
  ecode:integer;
  //StringStream:TStringStream;
begin
  with Form1 do begin
    try
      processA:=TProcess.Create(nil);
      processA.Executable:=Edit3.Text;
      processA.Parameters.Add(ScriptSrcs[ComboBox1.ItemIndex]);
      processA.Parameters.Add(Edit1.Text);
      processA.Parameters.Add(Edit2.Text);
      processA.Parameters.Add(Edit4.Text);
      processA.PipeBufferSize:=65536;
      processA.Options:=[poUsePipes,poNoConsole,poWaitOnExit,poStderrToOutPut];
      processA.ShowWindow:=swoNone;
      OutputArea.Lines.Add('Judging for '+Edit1.Text);
      processA.Execute;
      try
        StringList:=TStringList.Create;
        StringList.LoadFromStream(processA.Output);
        if CheckBox1.Checked then
          OutputArea.Lines.AddStrings(StringList);
        ecode:=processA.ExitCode;
        writestr(t,'Judge''s exit code is ',ecode);
        OutputArea.Lines.Append(t);
        case ecode of
          0:t:='Verdict:Accept';
          4002:t:='Verdict:Wrong Answer';
          4003:t:='Verdict:Runtime Error';
          4004:t:='Verdict:Time Limit Exceeded';
          4005:t:='Verdict:Memory Limit Exceeded';
          4001:t:='Verdict:Compile Error';
          else t:='Verdict:Unexpected Error';
        end;
        OutputArea.Lines.Append(t);
      finally
        FreeAndNil(StringList);
      end;
    except
      on E:EProcess do begin
        ShowMessage('Cannot run.Check if your python interpreter exists!Maybe you should choose it manually.');
        OutputArea.Lines.Append('Cannot start judging process!');
      end;
      on E:EStringListError do begin
        ShowMessage('Choose a script,instead of input one');
        OutputArea.Lines.Append('Illegal script!');
      end
      else begin end;
    end;
    processA.Free;
    Enabled:=true;
  end;
  exit(0);
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  if OpenDialog1.Execute then begin
    fileSelected:=true;
    Edit1.Text:=OpenDialog1.FileName;
    if dirSelected then Button3.Enabled:=true;
  end;
end;

procedure TForm1.Button10Click(Sender: TObject);
var
  t:string;
begin
  t:=getDropFileName;
  if t<>'' then begin
    Edit2.Text:=t;
    dirSelected:=true;
    if fileSelected then Button3.Enabled:=true;
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
{const
  BUF_SIZE = 2048;}
begin
  Form1.Enabled:=false;
  BeginThread(@CreateJudgeThread,nil);
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

procedure TForm1.Button7Click(Sender: TObject);
begin
  Form2.ShowModal;
end;

procedure TForm1.Button8Click(Sender: TObject);
begin
  Edit3.Text:=getDropFileName;
end;

procedure TForm1.Button9Click(Sender: TObject);
var
  t:string;
begin
  t:=getDropFileName;
  if t<>'' then begin
    Edit1.Text:=t;
    fileSelected:=true;
    if dirSelected then Button3.Enabled:=true;
  end;
end;

end.

