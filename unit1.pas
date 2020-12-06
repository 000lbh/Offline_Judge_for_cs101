unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Menus,
  ActnList, DBCtrls, Process, unit2, UDropDialog, XMLRead, XMLUtils,XMLReader,
  XMLTextReader, DOM, {$IFDEF Windows}Windows{$ELSE}Unix{$ENDIF};

type

  { TJudgeThread }

  TJudgeThread = class(TThread)
  private
    OutputStr:string;
    procedure EnableGUI;
    procedure DisableGUI;
    procedure WriteOutput;
  protected
    procedure Execute;override;
  public
    constructor Create(CreateSuspended:boolean);
  end;

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
  processA: TProcess;
  JudgeThread: TJudgeThread;

implementation

{$R *.lfm}
{$IFDEF Windows}{$R Settings.rc}{$ENDIF}

{ TJudgeThread }

procedure TJudgeThread.EnableGUI;
begin
  Form1.Enabled:=true;
end;

procedure TJudgeThread.DisableGUI;
begin
  Form1.Enabled:=false;
end;

procedure TJudgeThread.WriteOutput;
begin
  Form1.OutputArea.Lines.Add(OutputStr);
end;

procedure TJudgeThread.Execute;
var
  StringList:TStringList;
  ecode:integer;
begin
  with Form1 do begin
    Synchronize(@DisableGUI);
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
      OutputStr:='Judging for '+Edit1.Text;
      Synchronize(@WriteOutput);
      processA.Execute;
      try
        StringList:=TStringList.Create;
        StringList.LoadFromStream(processA.Output);
        if CheckBox1.Checked then
          OutputArea.Lines.AddStrings(StringList);
        ecode:=processA.ExitCode;
        writestr(OutputStr,'Judge''s exit code is ',ecode);
        Synchronize(@WriteOutput);
        case ecode of
          0:OutputStr:='Verdict:Accept';
          4002:OutputStr:='Verdict:Wrong Answer';
          4003:OutputStr:='Verdict:Runtime Error';
          4004:OutputStr:='Verdict:Time Limit Exceeded';
          4005:OutputStr:='Verdict:Memory Limit Exceeded';
          4001:OutputStr:='Verdict:Compile Error';
          else OutputStr:='Verdict:Unexpected Error';
        end;
        Synchronize(@WriteOutput);
      finally
        FreeAndNil(StringList);
      end;
    except
      on E:EProcess do begin
        ShowMessage('Cannot run.Check if your python interpreter exists!Maybe you should choose it manually.');
        OutputStr:='Cannot start judging process!';
        Synchronize(@WriteOutput);
      end;
      on E:EStringListError do begin
        ShowMessage('Choose a script,instead of input one');
        OutputStr:='Illegal script!';
        Synchronize(@WriteOutput);
      end
      else begin end;
    end;
    processA.Free;
    Synchronize(@EnableGUI);
  end;
  exit;
end;

constructor TJudgeThread.Create(CreateSuspended: boolean);
begin
  FreeOnTerminate:=true;
  inherited Create(CreateSuspended);
end;

{ EXMLFormatError }

constructor EXMLFormatError.Create(const msg:string);
begin
  inherited Create(msg);
end;

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
var
  i:integer;
  SettingFile:TResourceStream;
begin
  Edit3.Text:={$IFDEF Windows}'py'{$ELSE}{$IFDEf Unix}'/usr/bin/python3'{$ENDIF}{$ENDIF};
  fileSelected:=false;
  dirSelected:=false;
  ScriptSrcs:=TStringList.Create;
  if not FileExists('Settings.xml') then begin{$IFDEF Windows}
    OutputArea.Lines.Add('Automatically created Settings.xml at '+ExpandFileName('Settings.xml'));
    SettingFile:=TResourceStream.Create(HInstance,'SETTINGS',RT_RCDATA);
    SettingFile.SaveToFile('Settings.xml');
    SettingFile.Free;{$ENDIF}
  end;
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
  JudgeThread:=TJudgeThread.Create(false);
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

