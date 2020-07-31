unit MultiConfigTest_Unit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Terasoft_git.Framework.Lock,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ComCtrls;

type
  TfrmTest = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    mm: TMemo;
    BitBtn3: TBitBtn;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
  private
    lock1, lock2: ILock;
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
    key1, key2: TBytes;
    s: String;
begin
  key1 := BytesOf('Test it.');
  s :=   StringOf(key1);
  mm.Lines.Add(format('Original Text: %s', [s]));
  s := bytesToHexString(key1);
  s := bytesToBase64String(globalCrypter.encryptString('Test it.'),false);
  mm.Lines.Add(format('Base64 of Encrypted Text: %s', [s]));
  key1 := globalCrypter.encryptBytes(key1);
  mm.Lines.Add(format('Encrypted Text: %s', [stringOf(key1)]));
  key2 := base64StringToBytes(s);
  key1 := globalCrypter.decryptBytes(key2);
  s := StringOf(key1);
  mm.Lines.Add(format('Decrypted Text: %s', [s]));

end;

end.
