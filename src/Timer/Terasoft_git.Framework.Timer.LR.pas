unit Terasoft_git.Framework.Timer.LR;

interface
  uses
    Terasoft_git.Framework.Types, Terasoft_git.Framework.Timer;

  function getLRTimer: IRTimer;

implementation
  uses
    SysUtils, Windows, SyncObjs;

  type
    TLRTimer = class(TInterfacedObject, IRTimer)
    protected
      fTick: TRTimerData;
      olds: DWORD;
      function mark: TRTimerData; overload;
      function uSec(initial, _end: TRTimerData): TLargeInteger;
      function mSec(initial, _end: TRTimerData): TLargeInteger;
      function Sec(initial, _end: TRTimerData): TLargeInteger;
      function Minutes(initial, _end: TRTimerData): TLargeInteger;
      function Hours(initial, _end: TRTimerData): TLargeInteger;
      function getInitialTick: TRTimerData;
      function mark(ptr: PTRTimerData) : TRTimerData; overload;
      function secondstoTicks(const seconds: TLargeInteger) : TLargeInteger;
    public
      constructor Create;
    end;

    const
      Resolucao: TlargeInteger = 1000;

function getLRTimer: IRTimer;
begin
  Result := TLRTimer.Create;
end;

  var
    _old: Cardinal = 0;
    _counts: Cardinal = 0;
    cs: TCriticalSection;


{ TLRTimer }

constructor TLRTimer.Create;
begin
  fTick := mark;
end;

function TLRTimer.mark: TRTimerData;
begin
  Result := mark(@Result);
end;

function TLRTimer.getInitialTick: TRTimerData;
begin
  Result := fTick;
end;

function TLRTimer.Hours(initial, _end: TRTimerData): TLargeInteger;
begin
  Result := Minutes( initial, _end);
  Result := Result div 60;
end;

function TLRTimer.mark(ptr: PTRTimerData): TRTimerData;
  var
    dh: Cardinal;
//    count: Cardinal;
begin
  if(ptr=nil) then exit;
  ptr^.precision := tmrLowResolution;
  cs.Enter;
  try
    dh := GetTickCount;
    if(dh<_old) then begin
      _old := dh;
      inc(_counts);
    end else begin
      _old := dh;
      //count := _counts;
    end;
  finally
    cs.Leave;
  end;
  ptr.mark := (TLargeInteger(_counts) shl TLargeInteger(32)) + dh;
  Result := ptr^;
end;

function TLRTimer.Minutes(initial, _end: TRTimerData): TLargeInteger;
begin
  Result := Sec( initial, _end);
  Result := Result div 60;
end;

function TLRTimer.mSec(initial, _end: TRTimerData): TLargeInteger;
begin
  Result := ((_end.mark - initial.mark));
end;

function TLRTimer.Sec(initial, _end: TRTimerData): TLargeInteger;
begin
  Result := (_end.mark - initial.mark) div Resolucao;
end;

function TLRTimer.secondstoTicks(const seconds: TLargeInteger): TLargeInteger;
begin
  Result := seconds * Resolucao;
end;

function TLRTimer.uSec(initial, _end: TRTimerData): TLargeInteger;
begin
  Result := ((_end.mark - initial.mark) * 1000);
end;

procedure __init;
begin
  try
    cs := TCriticalSection.Create;
    LRTimerGlobal := getLRTimer;
  except
    LRTimerGlobal := nil;
  end;

end;

initialization
  __init;

finalization
  freeAndNil(cs);


end.
