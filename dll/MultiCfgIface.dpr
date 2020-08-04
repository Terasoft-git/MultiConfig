library MultiCfgIface;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
  ShareMeM,
  System.SysUtils,
  System.Classes,
  Terasoft_git.Framework.Initializer.Iface in '..\src\dll\Terasoft_git.Framework.Initializer.Iface.pas',
  Terasoft_git.Framework.Initializer.Impl in '..\src\dll\Terasoft_git.Framework.Initializer.Impl.pas',
  Terasoft_git.Framework.MultiConfig in '..\src\MultiConfig\Terasoft_git.Framework.MultiConfig.pas',
  Terasoft_git.Framework.Cryptography in '..\src\Common\Terasoft_git.Framework.Cryptography.pas',
  Terasoft_git.Framework.Timer in '..\src\Timer\Terasoft_git.Framework.Timer.pas',
  Terasoft_git.Framework.Timer.LR in '..\src\Timer\Terasoft_git.Framework.Timer.LR.pas';

{$R *.res}

begin
end.
