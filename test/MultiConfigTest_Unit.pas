
{$i multicfg.inc}

unit MultiConfigTest_Unit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Terasoft_git.Framework.Lock, Terasoft_git.Framework.MultiConfig,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ComCtrls,
  Vcl.ExtCtrls;

type
  TfrmTest = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    mm: TMemo;
    BitBtn3: TBitBtn;
    editSeed: TLabeledEdit;
    editTextToEncrypt: TLabeledEdit;
    editEncrypted: TLabeledEdit;
    BitBtn4: TBitBtn;
    BitBtn5: TBitBtn;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    Memo1: TMemo;
    Memo2: TMemo;
    Memo3: TMemo;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
    procedure BitBtn5Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    multi: IMultiConfig;
    lock1, lock2: ILock;
    procedure loadFile(fileName: String; strings: TStrings; load: boolean);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmTest: TfrmTest;

implementation

{$R *.dfm}

  uses
    Terasoft_git.Framework.Lock.Files, Terasoft_git.Framework.VisualMessage,
    Terasoft_git.Framework.Timer, Terasoft_git.Framework.Cryptography,
    IniFiles,
    Terasoft_git.Framework.Bytes;

procedure TfrmTest.BitBtn1Click(Sender: TObject);
  function lockIt(timeout: Integer = 2000): ILock;
    var
      msg: String;
  begin
    Result := FileILock('');
    if Result.lock(timeout)<>ltExclusive then
      msg := 'Not locked'
    else
      msg := 'Locked';
    mm.Lines.Add(format('Lock: %s', [ msg ]));
  end;
begin

  mm.Lines.Clear;

  lock1  := lockIt;
  lock2  := lockIt;

end;

procedure TfrmTest.BitBtn2Click(Sender: TObject);
  var
    initial: TRTimerData;
    i: Integer;
    j: Integer;
begin

  mm.Lines.Clear;

  for j := 1 to 10 do begin
    initial := lrTimerGlobal.mark;
    for i:=1 to 40 do
      sleep(3);

    mm.Lines.Add(format('Processing time: %dms', [ lrTimerGlobal.mSec(initial,lrTimerGlobal.mark) ]));
  end;

end;

procedure TfrmTest.BitBtn3Click(Sender: TObject);
  var
    s: String;
begin
  globalCrypter.setSeed(BytesOf(editSeed.Text));

  s := bytesToBase64String(globalCrypter.encryptString(editTextToEncrypt.Text));
  mm.Lines.Add(format('Encrypted Text: %s', [s]));
  editEncrypted.Text := s;

end;

procedure TfrmTest.BitBtn4Click(Sender: TObject);
  var
    b: TBytes;
    s: String;
begin
  if(editEncrypted.Text='') then
    ShowError('There is not text to decrypt!');

  b := base64StringToBytes(editEncrypted.Text);
  globalCrypter.setSeed(bytesOf(editSeed.Text));
  b := globalCrypter.decryptBytes(b);
  s := StringOf(b);
  editTextToEncrypt.Text := s;
  mm.Lines.Add(format('Decrypted Text: %s', [s]));
end;

procedure TfrmTest.BitBtn5Click(Sender: TObject);
  var
    ini: TMemIniFile;
    rw, reg: IConfigReaderWriter;
begin
  mm.Lines.Clear;
  if(globalCrypter=nil) then
    globalCrypter := createCrypter(bytesOf(editSeed.Text))
  else
    globalCrypter.setSeed(bytesOf(editSeed.Text));
  //We provided some comand lines too;
  //Default is to read from cmdlines, envvars and ini from exe.ini
  multi := defaultMultiConfigIniFile(true);
  //invert value
  multi.WriteBool('value','test',not multi.ReadBool('value','test',true));

  //invert value too but crypted
  multi.WriteBool('value','test2',not multi.ReadBool('value','test2',true,true),true);

  mm.Lines.Add(format('Last access: %s', [ DateTimeToStr(multi.ReadDateTime('config','last',0,true))] ));
  multi.WriteDateTime('config','last',Now,true);

  //Memo must have scroll bars on, or a long string may wrap and cause problems to key/value pair;

  reg := createConfigRegistry('\MyApp\MyTest');
  multi.addReaderWriter(reg);

  {$if defined(__MULTICFG_IMPL__)}
    multi.addReaderWriter(createConfigIniStrings(Memo1.Lines,'Memo1',true,nil));
    rw := createConfigIniStrings(Memo2.Lines,'Memo2');
    multi.addReaderWriter(rw);
    multi.WriteDateTime('config','app',now);
    multi.addReaderWriter(createConfigIniStrings(Memo3.Lines,'Memo3',true,nil));
  {$else}
    multi.addReaderWriter(createConfigIniString(Memo1.Lines.Text,'Memo1'));
    rw := createConfigIniString(Memo2.Lines.Text,'Memo2');
    multi.addReaderWriter(rw);
    multi.WriteDateTime('config','app',now);
    multi.addReaderWriter(createConfigIniString(Memo3.Lines.Text,'Memo3'));
  {$ifend}

  reg.writer.WriteString('in','value','test');

  multi.WriteBool('value','test',false);
  multi.WriteBool('value','test def',true);

  // This must go memo2
  multi.WriteString('test','value',editTextToEncrypt.Text, true);

  // This must go memo3
  multi.WriteString('test','value2',editTextToEncrypt.Text, true);

  if multi.ReadString('test','value','', true)<> editTextToEncrypt.Text then
    ShowError('Value encryped is not equal!');

  mm.Lines.Add(format('Value for vars.var04 no translation: %s', [ multi.ReadString('vars','var04','',false,false)]));
  mm.Lines.Add(format('Value for vars.var04 translated: %s', [ multi.ReadString('vars','var04')]));

  mm.Lines.Add(StringofChar('=',30));
  mm.Lines.Add('Dump of all chain as one single ini file');
  mm.Lines.Add(StringofChar('=',30));

  mm.Lines.Text := mm.Lines.Text + multi.toString(false);

  mm.Lines.Add(StringofChar('=',30));
  mm.Lines.Add('Dump of all chain as one single ini file + sources');
  mm.Lines.Add(StringofChar('=',30));

  mm.Lines.Text := mm.Lines.Text + multi.toString(false,true);

end;

procedure TfrmTest.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  loadFile('memo01.txt',Memo1.Lines,false);
  loadFile('memo02.txt',Memo2.Lines,false);
  loadFile('memo03.txt',Memo3.Lines,false);
end;

procedure TfrmTest.FormCreate(Sender: TObject);
begin
  editSeed.Text := CRYPTO_DUMMY_SEED;
  editTextToEncrypt.Text := 'This is a text to encrypt!!!';
end;

procedure TfrmTest.loadFile(fileName: String; strings: TStrings; load: boolean);
  var
    s: String;
begin
  s := ExpandFileName(ExtractFilePath(ParamStr(0)) + '..\..\' + fileName);
  if load then begin
    if FileExists(s) then
      strings.LoadFromFile(s);
  end else
    strings.SaveToFile(s);
end;

procedure TfrmTest.FormShow(Sender: TObject);
begin
  TabSheet1.Show;
  loadFile('memo01.txt',Memo1.Lines,true);
  loadFile('memo02.txt',Memo2.Lines,true);
  loadFile('memo03.txt',Memo3.Lines,true);
end;

end.
