program MultiConfigTest;

 {$R *.res}

uses
  ShareMeM,
  Vcl.Forms,
  MultiConfigTest_Unit in 'MultiConfigTest_Unit.pas' {frmTest},
  Terasoft_git.Framework.Lock in '..\src\Lock\Terasoft_git.Framework.Lock.pas',
  Terasoft_git.Framework.Types in '..\src\Common\Terasoft_git.Framework.Types.pas',
  Terasoft_git.Framework.VisualMessage in '..\src\Common\Terasoft_git.Framework.VisualMessage.pas',
  Terasoft_git.Framework.Lock.Files in '..\src\Lock\Terasoft_git.Framework.Lock.Files.pas',
  Terasoft_git.Framework.Texts in '..\src\Common\Terasoft_git.Framework.Texts.pas',
  Terasoft_git.Framework.Timer.LR in '..\src\Timer\Terasoft_git.Framework.Timer.LR.pas',
  Terasoft_git.Framework.Timer in '..\src\Timer\Terasoft_git.Framework.Timer.pas',
  Terasoft_git.Framework.MultiConfig in '..\src\MultiConfig\Terasoft_git.Framework.MultiConfig.pas',
  Terasoft_git.Framework.Cryptography in '..\src\Common\Terasoft_git.Framework.Cryptography.pas',
  Terasoft_git.Framework.Bytes in '..\src\Common\Terasoft_git.Framework.Bytes.pas',
  Terasoft_git.Framework.Initializer.Iface in '..\src\dll\Terasoft_git.Framework.Initializer.Iface.pas';

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmTest, frmTest);
  Application.Run;
end.
