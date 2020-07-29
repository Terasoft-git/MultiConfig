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
      function clear: IStrings; stdcall;

      property strings: TStrings read getStrings;
      property lines: TStrings read getStrings;
      property text: WideStringFramework read getText write setText;
    end;


  function createIStrings(caseSensitive: boolean = false; const text: String = ''): IStrings;


implementation

  type
    TLocalStrings = class(TInterfacedObject, IStrings )
    protected
      fList: TStringList;
      function getStrings: TStrings; stdcall;
      function clear: IStrings; stdcall;
      function getText: WideStringFramework; stdcall;
      procedure setText(const value: WideStringFramework); stdcall;
      function getSelf: IStrings; stdcall;
      //function valorInLis(const value: WideStringFramework): boolean;
    public
      constructor Create;
      //destructor Destroy; override;
    end;

function createIStrings(caseSensitive: boolean; const text: String): IStrings;
begin
  Result := TLocalStrings.Create;
  TStringList(Result.strings).CaseSensitive := caseSensitive;
  Result.text := text;
end;

{ TStrings }

function TLocalStrings.clear: IStrings;
begin
  fList.clear;
end;

constructor TLocalStrings.Create;
begin
  inherited;
  fList := TStringList.Create;
end;

function TLocalStrings.getSelf: IStrings;
begin
  Result := self;
end;

function TLocalStrings.getStrings: TStrings;
begin
  Result := fList;
end;

function TLocalStrings.getText: WideStringFramework;
begin
  Result := fList.Text;
end;

procedure TLocalStrings.setText(const value: WideStringFramework);
begin
  fList.Text := value;
end;

end.
