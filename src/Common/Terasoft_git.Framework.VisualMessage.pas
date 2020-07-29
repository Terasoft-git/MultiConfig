unit Terasoft_git.Framework.VisualMessage;

interface
  uses
    Terasoft_git.Framework.Types;

  type
    IAsyncKeyState = interface
      ['{0E2E40B5-A4A0-4A65-8562-7E0FA6C4E150}']
      function getOcurred: boolean; stdcall;
      procedure reset; stdcall;
      property ocurred: boolean read getOcurred;
    end;

    procedure ShowWarning(const msg: String);
    procedure ShowError(const msg: String; doAbort: boolean = true);

    function isInteractive: boolean;
    procedure setInteractive(const value: boolean);

implementation
  uses
    Windows, Forms;

  type
    TKeyState=class(TInterfacedObject,IAsyncKeyState)
    protected
      key: Integer;
      lastState: SHORT;
      fOcurred: boolean;
      function getOcurred: boolean; stdcall;
      procedure reset; stdcall;
    public
      constructor Create(const vKey: Integer; const AState: SHORT);
    end;

  var
    interactive: boolean = true;

function isInteractive: boolean;
begin
  Result := interactive;
end;

procedure setInteractive(const value: boolean);
begin
  interactive := value;
end;

{ TkeyState }

constructor TKeyState.Create(const vKey: Integer; const AState: SHORT);
begin
  inherited Create;
  fOcurred:=false;
  key := vkey;
  lastState := AState;
end;

function TKeyState.getOcurred: boolean;
  var
    state: SHORT;
begin

  if not fOcurred then begin
    state := GetAsyncKeyState(key);
    fOcurred := ( lastState and state) <> 0;
  end;
  Result := fOcurred;
end;

procedure TKeyState.reset;
begin
  fOcurred := false;
end;

procedure ShowWarning(const msg: String);
begin
  if(interactive) then
    Application.MessageBox(pchar(msg),'');
end;

procedure ShowError(const msg: String; doAbort: boolean = true);
begin

end;


end.
