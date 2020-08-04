unit Terasoft_git.Framework.Lock;

interface
  uses
    Terasoft_git.Framework.Types,Classes, System.Variants, SysUtils, WinApi.Windows,
    Terasoft_git.Framework.VisualMessage;

  type

    TLockType = (
      ltNone,
      ltExclusive,
      ltReadOnly
    );

    ILock = interface
    ['{1057F19E-9AFE-4BF6-9B2A-365AC42B3C4D}']
      function lock(timeOut: Int64): TLockType; overload; stdcall;

        //timeout in miliseconds
      function lock(_type: TLockType = ltExclusive; timeOut: Int64 = 1000; key: IAsyncKeyState=nil): TLockType; overload;stdcall;

      procedure releaseLock;stdcall;
      function getStatus: TLockType;stdcall;
      function getParameter: Variant;stdcall;
      procedure setParameter(const Value: Variant);stdcall;
      function getSaveUserdData: boolean; stdcall;
      procedure setSaveUserData(const value: boolean); stdcall;
      property saveUserData: boolean read getSaveUserdData write setSaveUserData;
      property status: TLockType read getStatus;
      property parameter: Variant read getParameter write setParameter;
    end;

  function FileILock(const fileName: String; const saveUserData: boolean = false): ILock;

implementation
  uses
    Terasoft_git.Framework.Lock.Files;

function FileILock(const fileName: String; const saveUserData: boolean = false): ILock;
begin
  Result := Terasoft_git.Framework.Lock.Files.FileILock(fileName,saveUserData);
end;


end.
