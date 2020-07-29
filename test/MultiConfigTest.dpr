program MultiConfigTest;

uses
  Vcl.Forms,
  MultiConfigTest_Unit in 'MultiConfigTest_Unit.pas' {frmTest},
  Terasoft_git.Framework.Lock in '..\src\Lock\Terasoft_git.Framework.Lock.pas',
  Terasoft_git.Framework.Types in '..\src\Common\Terasoft_git.Framework.Types.pas',
  Terasoft_git.Framework.VisualMessage in '..\src\Common\Terasoft_git.Framework.VisualMessage.pas',
  Terasoft_git.Framework.Lock.Files in '..\src\Lock\Terasoft_git.Framework.Lock.Files.pas',
  Terasoft_git.Framework.Texts in '..\src\Common\Terasoft_git.Framework.Texts.pas',
  Terasoft_git.Framework.Timer in '..\src\Common\Terasoft_git.Framework.Timer.pas',
  Terasoft_git.Framework.Timer.LR in '..\src\Common\Terasoft_git.Framework.Timer.LR.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmTest, frmTest);
  Application.Run;
end.
