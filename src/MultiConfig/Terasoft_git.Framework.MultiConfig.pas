unit Terasoft_git.Framework.MultiConfig;

interface
  uses
    Classes, Terasoft_git.Framework.Types,Spring.Collections,
    Terasoft_git.Framework.Cryptography,Windows,
    Terasoft_git.Framework.Texts,IniFiles;


  const
    SESSION_INTERNALUSE = 'session';
    MULTICONFIG_DEFAULTINIFILE = '@';

  type

    TListSource = IList<WideStringFramework>;

    IMultiConfig = interface;

    IConfigReader = interface
      ['{3BF00900-8FE6-462B-82C5-48C9C228B03A}']
      function ReadString(const Section, Ident: WideStringFramework; const default: WideStringFramework = ''; decrypt: boolean = false; translate: boolean = true; decrypter: ICryptografy = nil): WideStringFramework;
      function ReadInteger(const Section, Ident: WideStringFramework; const Default: Integer = 0; decrypt: boolean = false; translate: boolean = true; decrypter: ICryptografy = nil): Integer;
      procedure populateIni(ini: TCustomIniFile; translate: boolean = true; printSource: boolean = false);
      function printSource(list: TListSource=nil): TListSource;
      function getSource: WideStringFramework;
    end;

    IConfigWriter = interface
      ['{BC0DF9D9-3F9E-413E-B917-A4387B9D8340}']
      procedure WriteString(const Section, Ident, value: WideStringFramework; crypt: boolean = false; crypter: ICryptografy = nil);
      procedure WriteInteger(const Section, Ident: WideStringFramework; const value: Integer; crypt: boolean = false; crypter: ICryptografy = nil);
      procedure deleteKey(const Section: WideStringFramework = ''; const Ident: WideStringFramework = '');
      function printSource(list: TListSource=nil): TListSource;
    end;

    IConfigReaderWriter = interface
      ['{B4F9734D-95AA-4BF5-ACD2-948E875783AF}']
      function getReader: IConfigReader;
      function getWriter: IConfigWriter;

      property reader: IConfigReader read getReader;
      property writer: IConfigWriter read getWriter;

    end;

    IMultiConfig = interface
    ['{9B2816FB-F6FE-422C-ABF6-AD80B4CE61AB}']
      function getMultiReader: IConfigReader;
      function getMultiWriter: IConfigWriter;
      function addReaderWriter(readerWriter: IConfigReaderWriter; position: Integer = MAXINT): IMultiConfig;

      procedure populateIni(ini: TCustomIniFile; translate: boolean = true; printSource: boolean = false);

      //for Readers
      function ReadString(const Section, Ident: WideStringFramework; const Default: WideStringFramework = ''; decrypt: boolean = false; translate: boolean = true; decrypter: ICryptografy = nil): WideStringFramework;
      function ReadInteger(const Section, Ident: WideStringFramework; const Default: Integer = 0; decrypt: boolean = false; translate: boolean = true; decrypter: ICryptografy = nil): Integer;
      function ReadInt64(const Section, Ident: WideStringFramework; const Default: Int64 = 0; decrypt: boolean = false; translate: boolean = true; decrypter: ICryptografy = nil): Int64;
      function ReadDateTime(const Section, Ident: WideStringFramework; const Default: TDateTime = 0; decrypt: boolean = false; translate: boolean = true; decrypter: ICryptografy = nil): TDateTime;
      function ReadBool(const Section, Ident: WideStringFramework; const Default: boolean = false; decrypt: boolean = false; translate: boolean = true; decrypter: ICryptografy = nil): boolean;
      function ReadExtended(const Section, Ident: WideStringFramework; const Default: Extended = 0; crypt: boolean = false; translate: boolean = true; decrypter: ICryptografy = nil): Extended;

      //Writer
      procedure WriteString(const Section, Ident, value: WideStringFramework; crypt: boolean = false; crypter: ICryptografy = nil);
      procedure WriteInteger(const Section, Ident: WideStringFramework; const value: Integer; crypt: boolean = false; crypter: ICryptografy = nil);
      procedure WriteInt64(const Section, Ident: WideStringFramework; const value: Int64; crypt: boolean = false; crypter: ICryptografy = nil);
      procedure WriteDateTime(const Section, Ident: WideStringFramework; const value: TDateTime; crypt: boolean = false; crypter: ICryptografy = nil);
      procedure WriteBool(const Section, Ident: WideStringFramework; const value: boolean; crypt: boolean = false; crypter: ICryptografy = nil);
      procedure WriteExtended(const Section, Ident: WideStringFramework; const value: Extended; crypt: boolean = false; crypter: ICryptografy = nil);

      procedure ReadSectionValues(const Section: WideStringFramework; Strings: TStrings);
      procedure ReadSections(Strings: TStrings);

      procedure deleteKey(const Section: WideStringFramework = ''; const Ident: WideStringFramework = '');

      function getDefaultReaderWriter: IConfigReaderWriter; stdcall;
      procedure setDefaultReaderWriter(const value: IConfigReaderWriter); stdcall;
      function setLastAsDefaultReaderWriter: IMultiConfig; stdcall;
      function translate(const text: WideStringFramework; const initMark: WideStringFramework = ''; const endMark: WideStringFramework = ''): WideStringFramework;
      function toString(traduzir: boolean = true; printSource: boolean = false): WideStringFramework;
      property defaultReaderWriter: IConfigReaderWriter read getDefaultReaderWriter write setDefaultReaderWriter;
      function ReadSectionsList(lista: IStrings = nil): IStrings;
      function ReadSectionValuesList(const Section: WideStringFramework; list: IStrings = nil): IStrings;

      function valueExists(const Section, Ident: WideStringFramework): boolean;

      function printSource(list: TListSource=nil): TListSource;

      property multiReader: IConfigReader read getMultiReader;
      property multiWriter: IConfigWriter read getMultiWriter;

    end;

  function defaultMultiConfigIniFile: IMultiConfig;

  function createMultiConfig: IMultiConfig;
  function createConfigIniFile(const filename: String; const hint: String = ''): IConfigReaderWriter;
  function createConfigIniString(const str: String=''; const hint: String = ''): IConfigReaderWriter;
  function createConfigIniStrings(const strings: TStrings = nil; const hint: String = ''): IConfigReaderWriter;
  function createConfigRegistry(const path: String = ''; rootkey: HKEY = 0; const hint: String = ''): IConfigReaderWriter;
  function createConfigCmdLine(const prefix: String = ''; const hint: String = ''): IConfigReaderWriter;
  function createConfigEnvVar(const prefix: String = ''; const hint: String = ''): IConfigReaderWriter;

  function checkListSource(var list: TListSource): TListSource;




implementation
  uses
    SysUtils, Math, StrUtils, Terasoft_git.Framework.MultiConfig.INI;

  type
    TMultiConfig = class(TInterfacedObject, IMultiConfig, IConfigReader, IConfigWriter)
    protected
      fCount: Integer;
      fList: array of IConfigReaderWriter;
      fDefaultReaderWriter: IConfigReaderWriter;
      function getMultiReader: IConfigReader;
      function getMultiWriter: IConfigWriter;
      function addReaderWriter(readerWriter: IConfigReaderWriter; position: Integer = MAXINT): IMultiConfig;

      function ReadString(const Section, Ident: WideStringFramework; const Default: WideStringFramework = ''; decrypt: boolean = false; translate: boolean = true; decrypter: ICryptografy = nil): WideStringFramework;
      function ReadInteger(const Section, Ident: WideStringFramework; const Default: Integer = 0; decrypt: boolean = false; translate: boolean = true; decrypter: ICryptografy = nil): Integer;
      function ReadInt64(const Section, Ident: WideStringFramework; const Default: Int64 = 0; decrypt: boolean = false; translate: boolean = true; decrypter: ICryptografy = nil): Int64;
      function ReadDateTime(const Section, Ident: WideStringFramework; const Default: TDateTime = 0; decrypt: boolean = false; translate: boolean = true; decrypter: ICryptografy = nil): TDateTime;
      function ReadBool(const Section, Ident: WideStringFramework; const Default: boolean = false; decrypt: boolean = false; translate: boolean = true; decrypter: ICryptografy = nil): boolean;
      function ReadExtended(const Section, Ident: WideStringFramework; const Default: Extended = 0; decrypt: boolean = false; translate: boolean = true; decrypter: ICryptografy = nil): Extended;

      procedure WriteString(const Section, Ident, value: WideStringFramework; crypt: boolean = false; crypter: ICryptografy = nil);
      procedure WriteInteger(const Section, Ident: WideStringFramework; const value: Integer; crypt: boolean = false; crypter: ICryptografy = nil);
      procedure WriteInt64(const Section, Ident: WideStringFramework; const value: Int64; crypt: boolean = false; crypter: ICryptografy = nil);
      procedure WriteDateTime(const Section, Ident: WideStringFramework; const value: TDateTime; crypt: boolean = false; crypter: ICryptografy = nil);
      procedure WriteBool(const Section, Ident: WideStringFramework; const value: boolean; crypt: boolean = false; crypter: ICryptografy = nil);
      procedure WriteExtended(const Section, Ident: WideStringFramework; const value: Extended; crypt: boolean = false; crypter: ICryptografy = nil);

      procedure populateIni(ini: TCustomIniFile; translate: boolean = true; printSource: boolean = false);
      procedure ReadSectionValues(const Section: WideStringFramework; Strings: TStrings);
      procedure ReadSections(Strings: TStrings);
      procedure deleteKey(const Section: WideStringFramework = ''; const Ident: WideStringFramework = '');

      function getDefaultReaderWriter: IConfigReaderWriter; stdcall;
      procedure setDefaultReaderWriter(const value: IConfigReaderWriter); stdcall;
      function setLastAsDefaultReaderWriter: IMultiConfig; stdcall;
      function toString(translate: boolean = true; printSource: boolean = false): WideStringFramework;
      function translate(const text: WideStringFramework; const initMark: WideStringFramework = ''; const endMark: WideStringFramework = ''): WideStringFramework;
      function ReadSectionsList(list: IStrings = nil): IStrings;
      function ReadSectionValuesList(const Section: WideStringFramework; list: IStrings = nil): IStrings;

      function valueExists(const Section, Ident: WideStringFramework): boolean;
      function getSource: WideStringFramework;
      function printSource(list: TListSource=nil): TListSource;

    public
      constructor Create;
    end;

  const
    invalidStr = '++;;;---@@';


function createMultiConfig: IMultiConfig;
begin
  Result := TMultiConfig.Create;
end;

function createConfigIniFile(const filename: String; const hint: String = ''): IConfigReaderWriter;
begin
  Result := Terasoft_git.Framework.MultiConfig.INI.createConfigIniFile(filename,hint);
end;

function defaultMultiConfigIniFile: IMultiConfig;
begin
  //adds cmd line parameters + envvars + exe.ini
  Result := createMultiConfig.addReaderWriter(createConfigCmdLine).addReaderWriter(createConfigEnvVar).addReaderWriter(createConfigIniFile(ChangeFileExt(paramStr(0),'.ini')));
end;

function createConfigIniString(const str: String=''; const hint: String = ''): IConfigReaderWriter;
begin
  Result := Terasoft_git.Framework.MultiConfig.INI.createConfigIniString(str,hint);
end;

function createConfigIniStrings(const strings: TStrings = nil; const hint: String = ''): IConfigReaderWriter;
begin
  Result := Terasoft_git.Framework.MultiConfig.INI.createConfigIniStrings(strings, hint);
end;

function createConfigRegistry(const path: String = ''; rootkey: HKEY = 0; const hint: String = ''): IConfigReaderWriter;
begin
  Result := Terasoft_git.Framework.MultiConfig.INI.createConfigRegistry(path,rootkey,hint);
end;

function createConfigCmdLine(const prefix: String = ''; const hint: String = ''): IConfigReaderWriter;
begin
  Result := Terasoft_git.Framework.MultiConfig.INI.createConfigCmdLine(prefix,hint);
end;

function createConfigEnvVar(const prefix: String = ''; const hint: String = ''): IConfigReaderWriter;
begin
  Result := Terasoft_git.Framework.MultiConfig.INI.createConfigEnvVar(prefix,hint);
end;

{ TMultiConfig }

function TMultiConfig.addReaderWriter(readerWriter: IConfigReaderWriter; position: Integer): IMultiConfig;
  var
    i: Integer;
    save: IConfigReaderWriter;
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

procedure TMultiConfig.deleteKey(const Section, Ident: WideStringFramework);
  var
    w: IConfigWriter;
    r: IConfigReader;
    i: Integer;
begin
  if(section<>'') and (ident<>'') then begin
    {
      vamos procurar o reader que contem o valor para alterar.. caso contrario, gravamos no ultimo
    }
    w := nil;
    r := nil;
    for i := Low(fList) to High(fList) do begin
      r := fList[i].reader;
      w := fList[i].writer;
      if(r.ReadString(section,Ident,invalidStr)<>invalidStr) then
        break;
      if(fDefaultReaderWriter<>nil) then
        w := nil;
    end;
    if(w=nil) then
      w := fDefaultReaderWriter.writer;
    if (w = nil ) then
      raise Exception.Create('TMultiConfig.deleteKey: Writer não definido...');
    w.deleteKey(Section,Ident);
  end else begin
    {
      vamos apagar de todos
    }
    for i := Low(fList) to High(fList) do
      fList[i].writer.deleteKey(section,ident);
  end;
end;

function TMultiConfig.getDefaultReaderWriter: IConfigReaderWriter;
begin
  Result := fDefaultReaderWriter;
end;

function TMultiConfig.getMultiReader: IConfigReader;
begin
  Result := self;
end;

function TMultiConfig.getMultiWriter: IConfigWriter;
begin
  Result := self;
end;

function TMultiConfig.getSource: WideStringFramework;
  var
    p: WideStringFramework;
    l: TListSource;
begin
  Result := '';
  for p in l do
    Result := Result + p + #10;
end;

procedure TMultiConfig.populateIni(ini: TCustomIniFile; translate, printSource: boolean);
  var
    i,j: Integer;
    listaSec, listaIdent: IStrings;
begin
  if(ini=nil) then exit;
  for i := High(fList) downto Low(fList) do
    fList[i].reader.populateIni(ini,false,printSource);
  if(translate) then begin
    listaSec := createIStrings;;
    listaIdent := createIStrings;
    ini.ReadSections(listaSec.strings);
    for i := 0 to listaSec.strings.Count - 1 do begin
      listaIdent.Clear;
      ini.ReadSection(listaSec.Strings[i],listaIdent.strings);
      for j := 0 to listaIdent.strings.Count - 1 do begin
        ini.WriteString(listaSec.Strings[i], listaIdent.Strings[j],
            self.translate(ini.ReadString(listaSec.Strings[i], listaIdent.Strings[j],'')));
      end;
    end;
  end;
end;

function TMultiConfig.ReadBool(const Section, Ident: WideStringFramework; const Default: boolean; decrypt, translate: boolean; decrypter: ICryptografy): boolean;
  var
    s: String;
begin
  s := ifThen(default,'S','N');
  s := ReadString(Section,Ident,s,decrypt,translate,decrypter);
  Result := not ( stringInArray(s,['N','0','F'], [ osna_CaseInsensitive ]));
end;

function TMultiConfig.ReadDateTime(const Section, Ident: WideStringFramework; const Default: TDateTime; decrypt, translate: boolean; decrypter: ICryptografy): TDateTime;
begin
  Result := StrToDateTimeDef( ReadString(Section, Ident, DateTimeToStr(default), decrypt, translate, decrypter ), Default );
end;

function TMultiConfig.ReadExtended(const Section, Ident: WideStringFramework; const Default: Extended; decrypt, translate: boolean; decrypter: ICryptografy): Extended;
begin
  Result := StrToFloatDef( ReadString(Section,ident,FloatToStr(Default),decrypt,translate,decrypter), default );
end;

function TMultiConfig.ReadInt64(const Section, Ident: WideStringFramework; const Default: Int64; decrypt, translate: boolean; decrypter: ICryptografy): Int64;
begin
  Result := StrToInt64Def( ReadString(Section,ident,IntToStr(Default),decrypt,translate,decrypter), default );
end;

function TMultiConfig.ReadInteger(const Section, Ident: WideStringFramework; const default: Integer; decrypt, translate: boolean; decrypter: ICryptografy): Integer;
begin
  Result := StrToIntDef( ReadString(Section,ident,IntToStr(Default),decrypt,translate,decrypter), default );
end;

procedure TMultiConfig.ReadSections(Strings: TStrings);
  var
    f: TMemIniFile;
begin
  if(Strings=nil) then
    exit;
  f := TMemIniFile.Create('');
  try
    populateIni(f);
    f.ReadSections(Strings);
  finally
    f.free;
  end;
end;

function TMultiConfig.ReadSectionsList(list: IStrings): IStrings;
begin
  if(list=nil) then
    list := createIStrings;
  Result := list;
  ReadSections(result.strings);
end;

procedure TMultiConfig.ReadSectionValues(const Section: WideStringFramework; Strings: TStrings);
  var
    f: TMemIniFile;
begin
  if(Strings=nil) then
    exit;
  f := TMemIniFile.Create('');
  try
    populateIni(f);
    f.ReadSectionValues(Section,Strings);
  finally
    f.free;
  end;
end;

function TMultiConfig.ReadSectionValuesList(const Section: WideStringFramework; list: IStrings): IStrings;
begin
  if(list=nil) then
    list := createIStrings;
  Result := list;
  ReadSectionValues(section, result.strings);
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

procedure TMultiConfig.setDefaultReaderWriter(const value: IConfigReaderWriter);
begin
  fDefaultReaderWriter := value;
end;

function TMultiConfig.setLastAsDefaultReaderWriter: IMultiConfig;
begin
  if Length(fList)>0 then
    fDefaultReaderWriter := fList[High(fList)]
  else
    fDefaultReaderWriter := nil;
end;

function TMultiConfig.toString(translate, printSource: boolean): WideStringFramework;
  var
    l: TMemIniFile;
    text: IStrings;
begin
  l := TMemIniFile.Create('');
  try
    populateIni(l,translate,printSource);
    text := createIStrings;
    l.GetStrings(text.strings);
    Result :=text.text;
  finally
    l.Free;
  end;
end;

function TMultiConfig.translate(const text: WideStringFramework; const initMark: WideStringFramework; const endMark: WideStringFramework): WideStringFramework;
  var
    s: String;
    index: Integer;
    counter: Integer;
    value: String;
    steps: Integer;
    section, ident: String;
    position: Integer;
    cripto: boolean;
    initTag: String;
    endTag: String;

  const
    ___CONST_DefaultSection = 'variables';
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
      section := ___CONST_DefaultSection;
      ident := s;
    end else begin
      section := copy(s,1,position-1);
      ident := copy(s,position+1,maxint);
    end;
    if(ident[Length(ident)] = '*') then begin
      cripto := true;
      SetLength(ident,length(ident)-1);
    end else
      cripto := false;
    value := ReadString(section,ident,s,cripto,false);
    if(value<>s)then begin
      Result := StringReplace(Result,initTag+s+endTag,value,[ rfReplaceAll, rfIgnoreCase ]);
      index := 1;
      counter := 0;
      steps := 0;
    end;
  end;
end;

function TMultiConfig.valueExists(const Section, Ident: WideStringFramework): boolean;
begin
  Result := ReadString(section,Ident,invalidStr)<>invalidStr;
end;

procedure TMultiConfig.WriteBool(const Section, Ident: WideStringFramework; const value: boolean; crypt: boolean; crypter: ICryptografy);
begin
  WriteString(Section, Ident, ifThen(value,'S','N'),crypt,crypter);
end;

procedure TMultiConfig.WriteDateTime(const Section, Ident: WideStringFramework; const value: TDateTime; crypt: boolean; crypter: ICryptografy);
begin
  WriteString(Section, Ident, DateTimeToStr(value),crypt,crypter);
end;

procedure TMultiConfig.WriteExtended(const Section, Ident: WideStringFramework; const value: Extended; crypt: boolean; crypter: ICryptografy);
begin
  WriteString(section,Ident,FloatToStr(value),crypt,crypter);
end;

procedure TMultiConfig.WriteInt64(const Section, Ident: WideStringFramework; const value: Int64; crypt: boolean; crypter: ICryptografy);
begin
  WriteString(section,Ident,IntToStr(value),crypt,crypter);
end;

procedure TMultiConfig.WriteInteger(const Section, Ident: WideStringFramework; Const value: Integer; crypt: boolean; crypter: ICryptografy);
begin
  WriteString(section,Ident,IntToStr(value),crypt,crypter);
end;

procedure TMultiConfig.WriteString(const Section, Ident, value: WideStringFramework; crypt: boolean; crypter: ICryptografy);
  var
    p: IConfigReaderWriter;
    w: IConfigWriter;
    r: IConfigReader;
    i: Integer;
begin
  w := nil;
  r := nil;
  for p in fList do begin
    r := p.reader;
    w := p.writer;
    if(r.ReadString(section,Ident,invalidStr,crypt,false,crypter)<>invalidStr) then
      break;
    if(fDefaultReaderWriter<>nil) then
      w := nil;
  end;
  if(w=nil) then
    w := fDefaultReaderWriter.writer;
  if (w = nil ) then
    raise Exception.Create('TMultiConfig.WriteString: Writer not defined.');
  w.WriteString(Section,Ident,value,crypt,crypter);
end;

function TMultiConfig.printSource(list: TListSource): TListSource;
  var
    p: IConfigReaderWriter;
begin
  Result := checkListSource(list);
  for p in fList do
    p.reader.printSource(list);
end;

function checkListSource(var list: TListSource): TListSource;
begin
  if(list=nil) then
    list := TCollections.CreateList<WideStringFramework>;
  Result := list;
end;


end.
