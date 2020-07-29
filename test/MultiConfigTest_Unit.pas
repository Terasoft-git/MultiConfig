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
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
  private
    lock: ILock;
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
  Terasoft_git.Framework.Timer;

procedure TfrmTest.BitBtn1Click(Sender: TObject);
  var
    msg: String;
    lock2: ILock;
begin

  mm.Lines.Clear;

  lock  := FileILock('');
  if lock.lock<>ltExclusive then
    msg := 'Not exclusive.'
  else
    msg := 'Locked';

  mm.Lines.Add(format('Lock 1: %s', [ msg ]));

  lock2 := FileILock('');
  if lock2.lock(ltExclusive,10000)<>ltExclusive then
    msg := 'Not Locked'
  else
    msg := 'Locked';

  mm.Lines.Add(format('Lock 2: %s', [ msg ]));

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

end.
