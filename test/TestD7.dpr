program TestD7;

uses
  Forms,
  UnitTestD7 in 'UnitTestD7.pas' {Form1},
  Terasoft_git.Framework.MultiConfig in '..\src\MultiConfig\Terasoft_git.Framework.MultiConfig.pas',
  Terasoft_git.Framework.Types in '..\src\Common\Terasoft_git.Framework.Types.pas',
  Terasoft_git.Framework.Bytes in '..\src\Common\Terasoft_git.Framework.Bytes.pas',
  Terasoft_git.Framework.Cryptography in '..\src\Common\Terasoft_git.Framework.Cryptography.pas',
  Terasoft_git.Framework.VisualMessage in '..\src\Common\Terasoft_git.Framework.VisualMessage.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
