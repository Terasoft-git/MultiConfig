program TestD7;

uses
  Forms,
  UnitTestD7 in 'UnitTestD7.pas' {Form1},
  Terasoft_git.Framework.MultiConfig in '..\src\MultiConfig\Terasoft_git.Framework.MultiConfig.pas',
  Terasoft_git.Framework.Types in '..\src\Common\Terasoft_git.Framework.Types.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
