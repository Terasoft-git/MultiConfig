
{$i multicfg.inc}

unit Terasoft_git.Framework.Initializer.Iface;

interface
  uses
    Classes, Windows, SysUtils,
    Terasoft_git.Framework.Types,
    //Terasoft_git.Framework.Texts,
    Terasoft_git.Framework.Cryptography,
    Terasoft_git.Framework.MultiConfig;
  type
    IMultiCfgCreator = interface
    ['{3094D3DA-1C57-4382-9955-26AD573EE6CB}']
      function defaultMultiConfigIniFile(crypted: boolean = false; crypter: ICryptografy = nil): IMultiConfig; stdcall;
      function createMultiConfig: IMultiConfig; stdcall;
      function createConfigIniFile(const filename: WideStringFramework = MULTICONFIG_DEFAULTINIFILE; const hint: WideStringFramework = ''; crypted: boolean = false; crypter: ICryptografy = nil): IConfigReaderWriter; stdcall;
      function createConfigIniString(const str: WideStringFramework=''; const hint: WideStringFramework = ''; crypted: boolean = false; crypter: ICryptografy = nil): IConfigReaderWriter; stdcall;
      function createConfigRegistry(const path: WideStringFramework = ''; rootkey: HKEY = 0; const hint: WideStringFramework = ''; crypted: boolean = false; crypter: ICryptografy = nil): IConfigReaderWriter; stdcall;
      function createConfigCmdLine(const prefix: WideStringFramework = ''; const hint: WideStringFramework = ''; crypted: boolean = false; crypter: ICryptografy = nil): IConfigReaderWriter; stdcall;
      function createConfigEnvVar(const prefix: WideStringFramework = ''; const hint: WideStringFramework = ''; crypted: boolean = false; crypter: ICryptografy = nil): IConfigReaderWriter; stdcall;

      function createCrypter(const hexSeed: WideStringFramework): ICryptografyEx;stdcall;
      function getGlobalCrypter: ICryptografyEx; stdcall;
      procedure setGlobalCrypter(const value: ICryptografyEx); stdcall;

      property globalCrypter: ICryptografyEx read getGlobalCrypter write setGlobalCrypter;
    end;


 {$if not defined(__CRYPTO_IMPL__)}


    const
      {$if defined(CPUX64)}
        DLL_NAME = 'MultiCfgIface64.dll';
      {$else}
        DLL_NAME = 'MultiCfgIface32.dll';
      {$ifend}
      {$if defined(DXE_UP)}
        DLL_BIN_NAME = '..\..\..\dll\out\' + DLL_NAME;
      {$else}
        DLL_BIN_NAME = '..\..\dll\out\' + DLL_NAME;
      {$ifend}

    var
      multiCfgdll_iface: IMultiCfgCreator;

    function createIfaceDllMultiCfg(const fileName: String = ''): IMultiCfgCreator;

  {$ifend}


implementation

{$if not defined(__CRYPTO_IMPL__)}

  type
    TInitProc = function (): IMultiCfgCreator;


  var
    HandleApp: HMODULE = 0;


function findFile(fName: String): String;
begin
  Result := fName;
  {$if defined(DEBUG)}
    if(Result = '') then
      Result := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + DLL_BIN_NAME;
      exit;
  {$else}
    if(Result = '') then
      Result := DLL_NAME;
    Result := ExpandFileName(Result);
    if FileExists(Result) then exit;
  {$ifend}
end;

function createIfaceDllMultiCfg(const fileName: String = ''): IMultiCfgCreator;
  var
    s: String;
    proc: TInitProc;
begin
  Result := multiCfgdll_iface;
  if(Result<>nil) then
    exit;

  s := fileName;

  if(fileName='') or not FileExists(fileName) then
    s := findFile(ExtractFileName(s));

  if(s='') or not FileExists(s) then
    raise Exception.Create('createIfaceDllMultiCfg: DLL not found');

  HandleApp := LoadLibrary(PChar(s));
  @proc := nil;
  if(HandleApp<>0) then
    @proc := GetProcAddress(HandleApp,'createMutiCfg');
  if(@proc<>nil) then
    multiCfgdll_iface := proc();

  Result := multiCfgdll_iface;

  if(Result = nil) then
    raise Exception.Create('createIfaceDllMultiCfg: Could not initialize interface.');

end;
{$ifend}


end.
