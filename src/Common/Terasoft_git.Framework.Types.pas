
{$i MultiCfg.inc}

unit Terasoft_git.Framework.Types;

interface
  uses
    Classes, Sysutils;

  type
    WideStringFramework = WideString;

    {$if not defined(DXE_UP)}
      TBytes = array of Byte;
    {$ifend}

implementation

end.
