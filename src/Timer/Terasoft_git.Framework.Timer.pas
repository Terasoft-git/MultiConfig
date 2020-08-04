unit Terasoft_git.Framework.Timer;

interface
  uses
    Classes, Windows, Terasoft_git.Framework.Types, SyncObjs, SysUtils;

  type
    TRTTimerPrecision = ( tmrNone, tmrLowResolution, tmrHighResolution );

    TRTimerData=record
      mark: TLargeInteger;
      precision: TRTTimerPrecision;
    end;
    PTRTimerData=^TRTimerData;

    IRTimer = interface
      ['{DB0FE153-911A-4B66-9B01-42DC3FB0AF3B}']
      function mark: TRTimerData; overload;stdcall;
      function uSec(initial, _end: TRTimerData): TLargeInteger;stdcall;
      function mSec(initial, _end: TRTimerData): TLargeInteger;stdcall;
      function Sec(initial, _end: TRTimerData): TLargeInteger;stdcall;
      function Minutes(initial, _end: TRTimerData): TLargeInteger;stdcall;
      function Hours(initial, _end: TRTimerData): TLargeInteger;stdcall;
      function getInitialTick: TRTimerData;stdcall;
      function mark(ptr: PTRTimerData) : TRTimerData; overload;stdcall;
      function secondsToTicks(const seconds: TLargeInteger) : TLargeInteger;stdcall;
      property initialTick: TRTimerData read getInitialTick;
    end;

  function getHRTimer: IRTimer;
  function getLRTimer: IRTimer;
  function getRTimer(const precision: TRTTimerPrecision = tmrNone): IRTimer;

  procedure waitMiliseconds(milisecons: Integer; initial: TRTimerData);


  function timer_Seconds(const initial: TRTimerData): TLargeInteger; overload;
  function timer_Seconds(const initial: TRTimerData; const _end: TRTimerData ): TLargeInteger; overload;

  var
    hrTimerGlobal: IRTimer;
    lrTimerGlobal: IRTimer;

implementation

function getHRTimer: IRTimer;
begin
  //TODO
  raise Exception.Create('Not implemented yet!!!');
end;

function getLRTimer: IRTimer;
begin
  //TODO
  raise Exception.Create('Not implemented yet!!!');
end;

function getRTimer(const precision: TRTTimerPrecision = tmrNone): IRTimer;
begin
  case precision of
    tmrHighResolution:
      Result := hrTimerGlobal;
    tmrLowResolution:
      Result := lrTimerGlobal
    else
      Result := nil
  end;
end;

function timer_Seconds(const initial: TRTimerData): TLargeInteger; overload;
  var
    tmr: IRTimer;
begin
  Result := 0;
  tmr := getRTimer(initial.precision);
  if(tmr=nil) then
    exit;
  Result := tmr.Sec(initial, tmr.mark);
end;

function timer_Seconds(const initial: TRTimerData; const _end: TRTimerData ): TLargeInteger; overload;
  var
    tmr: IRTimer;
begin
  Result := 0;
  tmr := getRTimer(initial.precision);
  if(tmr=nil) then
    exit;
  Result := tmr.Sec(initial, _end);
end;

procedure waitMiliseconds(milisecons: Integer; initial: TRTimerData);
begin
  while lrTimerGlobal.mSec(initial,lrTimerGlobal.mark) < milisecons do
    sleep(30);
end;

end.
