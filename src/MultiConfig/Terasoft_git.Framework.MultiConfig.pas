unit Terasoft_git.Framework.MultiConfig;

interface
  uses
    Classes, Terasoft_git.Framework.Types,
    Terasoft_git.Framework.Cryptography,
    Terasoft_git.Framework.Texts,IniFiles;

  type

    IMultiConfig = interface;


    IConfigReader = interface
      ['{50320F7C-8B4E-4A99-AF72-A393DC6E4682}']
      function ReadString(const Section, Ident: WideStringFramework; const default: WideStringFramework = ''; decrypt: boolean = false; translate: boolean = true; decrypter: ICryptografy = nil): WideStringFramework;
      {function ReadInteger(const Section, Ident: String; const Default: Integer = 0; decrypt: boolean = false; translate: boolean = true; descrypter: ICryptografy = nil): Integer;
      procedure populateIni(ini: TCustomIniFile; translate: boolean = true; printSource: boolean = false);
      function getSource: WideStringFramework;}
    end;

    IConfigWriter = interface
      ['{6CE68896-E3EA-4CF7-BC8C-064066CEE7E1}']
      {procedure WriteString(const Section, Ident, value: WideStringFramework; crypt: boolean = false; crypter: ICryptografy = nil);
      procedure WriteInteger(const Section, Ident: WideStringFramework; const value: Integer; crypt: boolean = false; crypter: ICryptografy = nil);
      procedure deleteKey(const Section: String = ''; const Ident: String = '');}
    end;

    IConfiguracaoReaderWriter = interface
      ['{30148BA2-36A2-4A8F-8307-2854A6EA17D0}']
      function getReader: IConfigReader;
      function getWriter: IConfigWriter;

      property reader: IConfigReader read getReader;
      property writer: IConfigWriter read getWriter;

    end;

    IMultiConfig = interface
    ['{90195B8C-5966-4804-9FD9-C5F7E00092E1}']
      function getMultiReader: IConfigReader;
      function getMultiWriter: IConfigWriter;
      function addReaderWriter(readerWriter: IConfiguracaoReaderWriter; position: Integer = MAXINT): IMultiConfig;

      function translate(const text: WideStringFramework; const initMark: WideStringFramework = ''; const endMark: WideStringFramework = ''): WideStringFramework;

      //for Readers
      function ReadString(const Section, Ident: WideStringFramework; const Default: WideStringFramework = ''; decrypt: boolean = false; translate: boolean = true; decrypter: ICryptografy = nil): WideStringFramework;
      {function ReadDateTime(const Section, Ident: WideStringFramework; const Default: TDateTime = 0; decrypt: boolean = false; translate: boolean = true): TDateTime;
      function ReadInteger(const Section, Ident: WideStringFramework; const Default: Integer = 0; crypt: boolean = false; translate: boolean = true; decrypter: ICryptografy = nil): Integer;

      procedure populateIni(ini: TCustomIniFile; traduzir: boolean = true; printSource: boolean = false);
      procedure ReadSectionValues(const Section: string; Strings: TStrings);
      procedure ReadSections(Strings: TStrings);
      function ReadBool(const Section, Ident: String; const Default: boolean = false; cripto: boolean = false; traduzir: boolean = true): boolean;

      //Writer
      procedure WriteString(const Section, Ident, valor: WideStringFramework; cripto: boolean = false; criptografador: ICryptografy = nil);
      procedure WriteInteger(const Section, Ident: WideStringFramework; const valor: Integer; cripto: boolean = false; criptografador: ICryptografy = nil);
      procedure deleteKey(const Section: WideStringFramework = ''; const Ident: WideStringFramework = '');
      procedure WriteDateTime(const Section, Ident: WideStringFramework; const valor: TDateTime; cripto: boolean = false);
      procedure WriteBool(const Section, Ident: WideStringFramework; const valor: boolean; cripto: boolean = false);

      property multiReader: IConfigReader read getMultiReader;
      property multiWriter: IConfigWriter read getMultiWriter;}

    end;

  function createMultiConfig: IMultiConfig;


implementation
  uses
    SysUtils;

  type
    TMultiConfig = class(TInterfacedObject, IMultiConfig, IConfigReader, IConfigWriter)
    protected
      fCount: Integer;
      fList: array of IConfiguracaoReaderWriter;
      function getMultiReader: IConfigReader;
      function getMultiWriter: IConfigWriter;
      function addReaderWriter(readerWriter: IConfiguracaoReaderWriter; position: Integer = MAXINT): IMultiConfig;

      function translate(const text: WideStringFramework; const initMark: WideStringFramework = ''; const endMark: WideStringFramework = ''): WideStringFramework;

      function ReadString(const Section, Ident: WideStringFramework; const Default: WideStringFramework = ''; decrypt: boolean = false; translate: boolean = true; decrypter: ICryptografy = nil): WideStringFramework;

    public
      constructor Create;
    end;

  const
    invalidStr = '++;;;---@@';


function createMultiConfig: IMultiConfig;
begin
  Result := TMultiConfig.Create;
end;

{ TMultiConfig }

function TMultiConfig.addReaderWriter(readerWriter: IConfiguracaoReaderWriter; position: Integer): IMultiConfig;
  var
    i: Integer;
    save: IConfiguracaoReaderWriter;
begin
  Result := self;
  if(readerWriter=nil)then exit;
  setLength(fList, fCount+1);
  fList[high(fList)] := readerWriter;
  inc(fCount);
  i:=fCount;
  if(position<0)then
    position := 0;
  while (i > position) and (i>1) do begin
    dec(i);
    save := fList[i-1];
    fList[i-1] := readerWriter;
    fList[i] := save;
  end;
end;

constructor TMultiConfig.Create;
begin
  inherited;
  fCount := 0;
end;

function TMultiConfig.getMultiReader: IConfigReader;
begin
  Result := self;
end;

function TMultiConfig.getMultiWriter: IConfigWriter;
begin
  Result := self;
end;

function TMultiConfig.ReadString(const Section, Ident, Default: WideStringFramework; decrypt, translate: boolean; decrypter: ICryptografy): WideStringFramework;
  var
    i: Integer;
    r: IConfigReader;
    v: String;
begin
  Result := Default;
  {
    iterate each reader to get the value from it...
  }
  for i := Low(fList) to High(fList) do begin
    r := fList[i].reader;
    v := r.ReadString(section,Ident,invalidStr,decrypt,false,decrypter);
    if(v<>invalidStr) then begin
      Result := v;
      break;
    end;
  end;
  if(translate) then
    Result:=self.translate(Result);
end;

function TMultiConfig.translate(const text: WideStringFramework; const initMark: WideStringFramework; const endMark: WideStringFramework): WideStringFramework;
  var
    s: String;
    index: Integer;
    counter: Integer;
    value: String;
    steps: Integer;
    secao, ident: String;
    position: Integer;
    cripto: boolean;
    initTag: String;
    endTag: String;

  const
    secaoDefault = 'variaveis';
    ___CONST_initTag = '%%(';
    ___CONST_endTag    = ')%%';

begin
  if(initMark='')then
    initTag := ___CONST_initTag
  else
    initTag := initMark;
  if(endMark='')then
    endTag := ___CONST_endTag
  else
    endTag := endMark;

  Result:=text;
  index := 1;
  counter := 0;
  steps := 0;
  while ( true )  do begin
    inc(steps);
    s := textBetweenTags(Result,initTag,endTag,@index);
    if(s='') then begin
      if(steps=1) then break;
      inc(counter);
      index := 1;
      if(counter>3)then break;
      continue;
    end;
    if(pos(String(initMark),s)>0) then continue;
    position := Pos('.',s);
    if(position = 0 ) then begin
      secao := secaoDefault;
      ident := s;
    end else begin
      secao := copy(s,1,position-1);
      ident := copy(s,position+1,maxint);
    end;
    if(ident[Length(ident)] = '*') then begin
      cripto := true;
      SetLength(ident,length(ident)-1);
    end else
      cripto := false;
    value := ReadString(secao,ident,s,cripto,false);
    if(value<>s)then begin
      Result := StringReplace(Result,initTag+s+endTag,value,[ rfReplaceAll, rfIgnoreCase ]);
      index := 1;
      counter := 0;
      steps := 0;
    end;
  end;
end;

end.
