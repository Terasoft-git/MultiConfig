unit Terasoft_git.Framework.Texts;

interface
  uses
    Terasoft_git.Framework.Types, Classes;

  type

    TOptiontringInArray = (osna_CaseInsensitive, osna_NoAccentuation);
    TOptionsStringNoArray = set of TOptiontringInArray;


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
  function textBetweenTags ( Text, TagInicio, TagFim: String; PrimeiraOcorrencia: PInteger = nil; caseSensitive: boolean = true; posicaoInicial: PInteger = nil ): string;
  function textBetweenTagsXML ( Text, Tag: String; PrimeiraOcorrencia: PInteger = nil; caseSensitive: boolean = true ): string;
  function stringInArray(const str: String; values: Array of String; options: TOptionsStringNoArray = [] ): boolean; overload;
  function noAccentuation(const str: String): String;


implementation
  uses
    SysUtils, strUtils;

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

function textBetweenTagsXML ( Text, Tag: String; PrimeiraOcorrencia: PInteger; caseSensitive: boolean ): string;
begin
  Result := textBetweenTags(Text, '<' + tag + '>', '</' + tag + '>', PrimeiraOcorrencia, caseSensitive );
end;

function textBetweenTags ( Text, TagInicio, TagFim: String; PrimeiraOcorrencia: PInteger; caseSensitive: boolean; posicaoInicial: PInteger ): string;
  var
    first, last: Integer;
    textoCompleto: String;
    ocorrencias: Integer;
    inicioOcorrencia: Integer;
    finalizador: Integer;
begin
 try
  Result := '';
  if(caseSensitive)then
    textoCompleto := text
  else begin
    textoCompleto := LowerCase(Text);
    TagInicio := LowerCase(TagInicio);
    TagFim := LowerCase(TagFim);
  end;
	if (length(Text) < ( length(TagInicio) + length(TagFim) ) ) then exit;
  if(posicaoInicial<>nil) and (posicaoInicial^ > 0) then
      first := posicaoInicial^
  else
  	first := 1;
	if ( PrimeiraOcorrencia <> nil ) then begin
    first := PrimeiraOcorrencia^;
		PrimeiraOcorrencia^ := 0;
	end;
  ocorrencias := 0;
	if ( TagInicio = '' ) then
		first := 1
	else begin
		first := PosEx( TagInicio, textoCompleto, first );
		if ( first = 0 ) then exit;
		inc(first, length(TagInicio));
	end;
	if ( TagFim = '' ) then
		last := ( length(Text) - length(TagFim) ) + 1
	else begin
		last := PosEx ( TagFim, textoCompleto, first );
		if ( last = 0 ) then exit;
    inicioOcorrencia := first;
    if(TagInicio<>TagFim) then begin
      while(true) do begin
        inicioOcorrencia := PosEx(TagInicio,textoCompleto,inicioOcorrencia);
        if(inicioOcorrencia>last) or (inicioOcorrencia=0) then break;
        inc(inicioOcorrencia,length(TagInicio));
    		last := PosEx ( TagFim, textoCompleto, first + Length(TagFim) );
        if(last = 0) then exit;
      end;
    end;


	end;
	if ( ( last - first ) < 1 ) then exit;
	if ( ( PrimeiraOcorrencia <> nil ) and ( last > first ) ) then
		PrimeiraOcorrencia^ := first;
  Result := Copy ( Text, first, last - first );
 finally
   if(posicaoInicial<>nil) then
    posicaoInicial^:= first;
 end;
end;

function stringInArray(const str: String; values: Array of String; options: TOptionsStringNoArray ): boolean; overload;
  var
    i: Integer;
    lStr, vlr: String;
begin
  Result := true;
  lStr := str;
  if(osna_NoAccentuation in options) then
    lStr := noAccentuation(lStr);
  for i := low(values) to high(values) do begin
    vlr := values[i];
    if(osna_NoAccentuation in options) then
      vlr := noAccentuation(vlr);
    if(osna_CaseInsensitive in options) then begin
      if(CompareText(lStr,vlr )=0 ) then exit;
    end else if(lStr = vlr ) then
      exit;
  end;
  Result := false;
end;

function noAccentuation(const str: String): String;
  var
    x: Integer;
  const
    ComAcento = '‡‚ÍÙ˚„ı·ÈÌÛ˙Á¸¿¬ ‘€√’¡…Õ”⁄«‹' + #1 + #9;
    SemAcento = 'aaeouaoaeioucuAAEOUAOAEIOUCU' + #32 +#32;
begin;
  Result := Str;
  for x := 1 to Length(Str) do
    if Pos(Result[x],ComAcento) <> 0 then
      Result[x] := SemAcento[Pos(Result[x], ComAcento)];
end;



end.
