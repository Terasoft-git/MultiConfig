unit Terasoft_git.Framework.Initializer.Iface;

interface
  uses
    Classes, Windows,
    Terasoft_git.Framework.Types,
    Terasoft_git.Framework.Texts,
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
    end;

implementation

end.
