unit Terasoft_git.Framework.Texts;

interface
  uses
    Terasoft_git.Framework.Types, Classes;

  type


    IStrings = interface
    ['{476CCBCD-4E43-4EA1-9AFA-A374DE9BD65D}']
      function getStrings: TStrings; stdcall;
      function getText: WideStringFramework; stdcall;
      procedure setText(const text: WideStringFramework); stdcall;

      property strings: TStrings read getStrings;
      property lines: TStrings read getStrings;
      property text: WideStringFramework read getText write setText;
    end;


  function createIStrings: IStrings;


implementation

function createIStrings: IStrings;
begin
  //
end;

end.
