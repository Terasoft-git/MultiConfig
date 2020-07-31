unit Terasoft_git.Framework.Lock.Files;

interface
  uses
    Terasoft_git.Framework.Lock, Terasoft_git.Framework.Texts,
    Terasoft_git.Framework.Types,
    Terasoft_git.Framework.VisualMessage;

  function FileILock(const fileName: String; const saveUserData: boolean = false): ILock;

implementation
  uses
    Windows, SysUtils, Terasoft_git.Framework.Timer;

  type
    TFileLock = class(TInterfacedObject, ILock)
    protected
      fStatus: TLockType;
      fFileName: String;
      fUserData: IStrings;

      fFileData: String;
      fHandle: THandle;
      fSaveUserData: boolean;

      procedure saveUserData;

      function lock(timeOut: Int64): TLockType; overload;
      function lock(_type: TLockType = ltExclusive; timeOut: Int64 = 1000; key: IAsyncKeyState=nil): TLockType; overload; //time in miliseconds
      procedure releaseLock;
      function getStatus: TLockType;
      function getParameter: Variant;
      procedure setParameter(const Value: Variant);
      function getSaveUserdData: boolean; stdcall;
      procedure setSaveUserData(const value: boolean); stdcall;
      property parameter: Variant read getParameter write setParameter;
    public
      constructor Create(const ASaveUserData: boolean = false);
      destructor Destroy; override;
    end;


function FileCreateMode(const FileName: string; Mode: LongWord; Rights: Integer): THandle;
const
  Exclusive: array[0..1] of LongWord = (
    CREATE_ALWAYS,
    CREATE_NEW);
  ShareMode: array[0..4] of LongWord = (
    0,
    0,
    FILE_SHARE_READ,
    FILE_SHARE_WRITE,
    FILE_SHARE_READ or FILE_SHARE_WRITE);
begin
  Result := INVALID_HANDLE_VALUE;
  if (Mode and $F0) <= fmShareDenyNone then
    Result := CreateFile(PChar(FileName), GENERIC_READ or GENERIC_WRITE,
      ShareMode[(Mode and $F0) shr 4], nil, Exclusive[(Mode and $0004) shr 2], FILE_ATTRIBUTE_NORMAL, 0);
end;

function FileILock(const fileName: String; const saveUserData: boolean = false): ILock;
begin
  Result := TFileLock.Create(saveUserData);
  Result.parameter := fileName;
end;

{ TFileLock }

constructor TFileLock.Create(const ASaveUserData: boolean);
begin
  inherited Create;
  fSaveUserData := ASaveUserData;
  fUserData := createIStrings;
  fHandle := INVALID_HANDLE_VALUE;
  fFileName:='[.]';
  parameter := '';
end;

destructor TFileLock.Destroy;
begin
  releaseLock;
  inherited;
end;

function TFileLock.getParameter: Variant;
begin
  Result := fFileName;
end;

function TFileLock.getSaveUserdData: boolean;
begin
  Result := fSaveUserData;
end;

function TFileLock.getStatus: TLockType;
begin
  Result := fStatus;
end;

function TFileLock.lock(timeOut: Int64): TLockType;
begin
  Result := lock(ltExclusive,timeOut);
end;

function TFileLock.lock(_type: TLockType; timeOut: Int64; key: IAsyncKeyState): TLockType;
  var
    mode: LongWord;
    timer: TRTimerData;
begin
  if(fStatus=_type) then begin
    Result := fStatus;
    exit;
  end;

  releaseLock;

  if(_type=ltNone) then begin
    Result := fStatus;
    exit;
  end;

  Timer := lrTimerGlobal.mark;

  Result := ltNone;
  while ( Result = ltNone ) do begin
    if ( FileExists ( fFileName ) ) then begin
      if ( _type = ltExclusive ) then
        mode := fmOpenReadWrite or fmShareExclusive
      else
        mode := fmOpenReadWrite or fmShareDenyNone;
      fHandle := FileOpen(fFileName, mode );
    end else begin
      if ( _type = ltExclusive ) then
        mode := fmShareExclusive
      else
        mode := fmShareDenyNone;
      fHandle := FileCreateMode(fFileName, mode, 0 );
    end;
    if(fHandle<>INVALID_HANDLE_VALUE) then begin
      fStatus := _type;
      result := fStatus;
      saveUserData;
      break;
    end;
    if ( (key<>nil) and key.ocurred ) or ( (timeOut > 0) and ( lrTimerGlobal.mSec(timer,lrTimerGlobal.mark) > timeOut )) then
      break;

    Sleep(100);
  end;
end;

procedure TFileLock.releaseLock;
begin
  try
    if ( fHandle <> INVALID_HANDLE_VALUE ) then begin
      FileClose(fHandle);
      if(fSaveUserData) and (fFileData<>'') then
        SysUtils.DeleteFile(fFileData);
    end;
  finally
    fStatus := ltNone;
    fHandle := INVALID_HANDLE_VALUE;
    SysUtils.DeleteFile(fFileName);
  end;
end;

procedure TFileLock.saveUserData;
begin
  // TODO
end;

procedure TFileLock.setParameter(const Value: Variant);
begin
  if(Value<>fFileName) then begin
    releaseLock;
    if(Value='') then begin
      fFileName:= ChangeFileExt(ParamStr(0),'.lock')
    end else
      fFileName := Value;
    fFileData:=fFileName + '.user'
  end;

end;

procedure TFileLock.setSaveUserData(const value: boolean);
begin
  fSaveUserData := value;
end;

end.
