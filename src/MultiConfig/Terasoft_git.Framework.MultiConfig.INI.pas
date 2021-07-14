
{$i multicfg.inc}

{$if not defined(__MULTICFG_IMPL__)}
  {$message fatal 'Remove this unit from project'}
{$ifend}

unit Terasoft_git.Framework.MultiConfig.INI;

interface
  uses
    Terasoft_git.Framework.Types, Classes,
    Terasoft_git.Framework.Cryptography,
    Terasoft_git.Framework.MultiConfig, Windows;

  function createConfigIniFile(const filename: String = MULTICONFIG_DEFAULTINIFILE; const hint: String = ''; crypted: boolean = false; crypter: ICryptografy = nil ): IConfigReaderWriter;
  function createConfigRegistry(const path: String = ''; rootkey: HKEY = 0; const hint: String = ''; crypted: boolean = false; crypter: ICryptografy = nil): IConfigReaderWriter;
  function createConfigIniString(const str: WideStringFramework; const hint: WideStringFramework = ''; crypted: boolean = false; crypter: ICryptografy = nil): IConfigReaderWriter;
  function createConfigCmdLine(const prefix: String = ''; const hint: String = ''; crypted: boolean = false; crypter: ICryptografy = nil): IConfigReaderWriter;
  function createConfigEnvVar(const prefix: String = ''; const hint: String = ''; crypted: boolean = false; crypter: ICryptografy = nil): IConfigReaderWriter;
  function createConfigIniStrings(const strings: TStrings = nil; const hint: String = ''; crypted: boolean = false; crypter: ICryptografy = nil): IConfigReaderWriter;

implementation
  uses
    iniFiles, StrUtils, SysUtils, Registry, Terasoft_git.Framework.Lock,
    Terasoft_git.Framework.Texts;

  const
    PADDING = '=';

  type
    TIni = class(TInterfacedObject, IConfigReaderWriter, IConfigReader, IConfigWriter )
    private
      inif: TCustomIniFile;
      lck: Ilock;
      fHint: String;
      fStrings: TStrings;
      fCrypter: ICryptografy;
      fCrypted: boolean;
      fEnabled: boolean;
      function getReader: IConfigReader;stdcall;
      function getWriter: IConfigWriter;stdcall;
      function ReadString(const Section, Ident: WideStringFramework; const default: WideStringFramework = ''; decrypt: boolean = false; translate: boolean = true; decrypter: ICryptografy = nil): WideStringFramework;stdcall;
      function ReadInteger(const Section, Ident: WideStringFramework; const Default: Integer = 0; decrypt: boolean = false; translate: boolean = true; decrypter: ICryptografy = nil): Integer;stdcall;
      procedure WriteString(const Section, Ident, value: WideStringFramework; crypt: boolean = false; crypter: ICryptografy = nil);stdcall;
      procedure WriteInteger(const Section, Ident: WideStringFramework; const value: Integer; crypt: boolean = false; crypter: ICryptografy = nil);stdcall;
      procedure deleteKey(const Section: WideStringFramework = ''; const Ident: WideStringFramework = '');stdcall;
      procedure populateIni(ini: TCustomIniFile; translate: boolean = true; printSource: boolean = false);stdcall;
      function getCrypted: boolean;stdcall;
      procedure setCrypted(const value: boolean);stdcall;
      function getCrypter: ICryptografy;stdcall;
      procedure setCrypter(const value: ICryptografy);stdcall;
      function getSource: WideStringFramework;stdcall;
      function printSource(list: TListSource): TListSource;stdcall;
      procedure updateIniFile;stdcall;
      procedure loadData;stdcall;
      procedure setEnabled(const value: boolean);
      function getEnabled: boolean;
    public
      constructor Create(aInif: TCustomIniFile; const hint: String; strings: TStrings = nil; crypted: boolean = false; crypter: ICryptografy = nil);
      destructor Destroy; override;
    end;


function createConfigIniFile(const filename: String; const hint: String; crypted: boolean; crypter: ICryptografy): IConfigReaderWriter;
  var
    fName: String;
begin
  if(filename=MULTICONFIG_DEFAULTINIFILE)then
    fName := ChangeFileExt(ParamStr(0),'.ini')
  else
    fName := filename;
  fName := ExpandFileName(fName);
  Result := TIni.Create(TMemIniFile.Create(fName),hint,nil,crypted,crypter);
end;

function createConfigIniStrings(const strings: TStrings; const hint: String; crypted: boolean; crypter: ICryptografy): IConfigReaderWriter;
  var
    f: TMemIniFile;
begin
  if(strings=nil) then begin
    Result := createConfigIniString('',hint,crypted,crypter);
    exit;
  end;
  f := TMemIniFile.Create('');
  f.SetStrings(strings);
  Result := TIni.Create(f,hint,strings,crypted,crypter);
end;

function createConfigRegistry(const path: String; rootkey: HKEY; const hint: String; crypted: boolean; crypter: ICryptografy): IConfigReaderWriter;
  const
    defaultPath =
      {$if defined(__RELEASE__)}
              '\Software\MultiCfg\Config';
      {$else}
              '\Software\MultiCfg\Tests';
      {$ifend}
  var
    realPath: String;
    reg: TRegistryIniFile;
begin
  if(path='')then
    realPath := defaultPath
  else
    realPath := path;

  reg := TRegistryIniFile.Create(path);
  Result := TIni.Create(reg,'Registry: ' + realPath + ': '+ hint,nil,crypted,crypter);
  reg.RegIniFile.OpenKey(realPath,true);
end;

function createConfigIniString(const str: WideStringFramework; const hint: WideStringFramework; crypted: boolean; crypter: ICryptografy): IConfigReaderWriter;
  var
    f: TMemIniFile;
    s: TStrings;
begin
  f := TMemIniFile.Create('');
  s := TStringList.Create;
  try
    s.Text := str;
    f.SetStrings(s);
  finally
    s.Free;
  end;
  Result := TIni.Create(f,hint,nil,crypted,crypter);
end;

procedure addStrIni(ini: TCustomIniFile; const Str: String);
  var
    section, ident, value: String;
    position: Integer;
begin
    position := PosEx('=',str,1);
    if(position=0) then exit;
    value := copy(str,position+1,MaxInt);
    ident := copy(str,1,position-1);
    position := PosEx(':',ident,1);
    if(position<1)then
      position := PosEx('.',ident,1);
    if(position>0) then begin
      section := copy(ident,1,position-1);
      ident := copy(ident,position+1,MaxInt);
    end else
      section := '';

    ini.WriteString(section,ident,value);
end;


function createConfigEnvVar(const prefix: String; const hint: String; crypted: boolean; crypter: ICryptografy): IConfigReaderWriter;
  var
    realPrefix: String;
    ini: TMemIniFile;
    i: Integer;
    p: PChar;
    pStr: PChar;
    str: String;

  const
    defaulPrefix = 'MultiCfg.';

begin
  Result := nil;
  if(prefix='') then
    realPrefix := defaulPrefix
  else if(prefix='*') then
    realPrefix:=''
  else
    realPrefix := prefix + '.';

  p := GetEnvironmentStrings;
  if(p=nil) then exit;
  try
    pstr := p;
    repeat
      str := pstr;
      if CompareText(realPrefix,copy(str,1,length(realPrefix))) = 0 then begin
        if(Result = nil) then begin
          ini := TMemIniFile.Create('');
          Result := TIni.Create(ini,'EnvVar prefix ' + realPrefix + ': ' + hint,nil,crypted,crypter);
        end;
        if(realPrefix='') then
          str := 'envvar.' + str;
        addStrIni(ini,copy(str,length(realPrefix)+1,MaxInt) );
      end;

      while(pstr[0]<> #0) do
        inc(pstr);
      inc(pstr);

    until pstr[0] = #0;

  finally
    FreeEnvironmentStrings(p);
  end;
end;

function createConfigCmdLine(const prefix: String; const hint: String; crypted: boolean; crypter: ICryptografy): IConfigReaderWriter;
  var
    str: String;
    ini: TMemIniFile;
    i: Integer;
    l: Integer;
begin
  Result := nil;
  if(ParamCount<1) then exit;
  l := Length(prefix);
  for i := 1 to ParamCount do begin
    str := ParamStr(i);

    if(l>0) then begin
      if(CompareText(prefix + '.', copy(str,1,l+1))=0) then
        str := copy(str,l+2)
      else
        str := '';
    end;
    if(str='') or (str[1]='-') then continue;

    if(Result = nil) then begin
      ini := TMemIniFile.Create('');
      Result := TIni.Create(ini,'Command line parameters: ' + hint,nil,crypted,crypter);
    end;
    addStrIni(ini,str);
  end;
end;



{ TIni }

constructor TIni.Create(aInif: TCustomIniFile; const hint: String; strings: TStrings; crypted: boolean; crypter: ICryptografy);
begin
  inherited Create;
  fEnabled := true;
  fCrypted := crypted;
  fCrypter := crypter;
  fStrings := Strings;
  inif := aInif;
  fHint:=hint;
  if(ainif.FileName<>'') and (ainif is TMemIniFile) then
    lck := FileILock(inif.FileName + '.lock');
end;

function TIni.getEnabled: boolean;
begin
  Result := fEnabled;
end;

procedure TIni.setEnabled(const value: boolean);
begin
  fEnabled := value;
end;

procedure TIni.loadData;
  var
    l: IStrings;
  procedure getData;
  begin
    if l<>nil then
      exit;
    if(inif is TMemIniFile) then begin
      l := createIStrings;
      if (inif.FileName<>'') and FileExists(inif.FileName) then
        l.strings.LoadFromFile(inif.FileName)
      else if ( fStrings<>nil ) then
        l.text := fStrings.Text
      else
        l := nil;
      if(fCrypted) and (l<>nil) then
        try
          l.text := decryptBase64ToString(l.text,fCrypter);
        except
          // not great, but try to load uncrypted data too...
        end;
    end;
  end;

begin
  l := nil;
  if(lck<>nil) and (lck.lock<>ltExclusive) then
    raise Exception.CreateFmt('TIni.loadData: Not acquired exclusive access to file [%s]', [ inif.FileName ] );

  getData;
  if(l<>nil) and (inif is TMemIniFile) then
    TMemIniFile(inif).SetStrings(l.strings);

end;

procedure TIni.deleteKey(const Section, Ident: WideStringFramework);
  var
    i: Integer;
    list: TStrings;
begin
  try
    loadData;
    if(ident='') and (Section='') then begin
      if(inif is TMemIniFile) then
        (inif as TMemIniFile).clear
      else
        raise Exception.Create('TIni.deleteKey: TMemIniFile Not suported...');
    end else if(ident='') then begin
      // cleans all section
      inif.EraseSection(Section);
    end else if(Section='') then begin
      // cleans all idents
      list := TStringList.Create;
      try
        inif.ReadSections(list);
        for i := 0 to list.Count - 1 do
          inif.DeleteKey(list.Strings[i],Ident);
      finally
        list.Free;
      end;

    end else begin
      // clean ident only
      inif.DeleteKey(section,ident);
    end;
    updateIniFile;
  finally
    if(lck<>nil) then
      lck.releaseLock;
  end;
end;

destructor TIni.Destroy;
begin
  FreeAndNil(iniF);
  inherited;
end;

function TIni.getCrypted: boolean;
begin
  Result := fCrypted;
end;

function TIni.getCrypter: ICryptografy;
begin
  Result := fCrypter;
end;

function TIni.getReader: IConfigReader;
begin
  Result := self;
end;

function TIni.getSource: WideStringFramework;
  var
    txt: String;
begin
  txt := inif.ClassName + ': ';
  if(inif is  TRegistryIniFile)then begin
  end else if(inif is TCustomIniFile) then begin
    if(inif.FileName='') then
      txt := txt + 'String'
    else
      txt := txt + '@' + inif.FileName;
  end;
  if(fhint<>'')then
    txt := Format('%s (%s)', [ txt, fHint ]);
  Result := txt;
end;

function TIni.getWriter: IConfigWriter;
begin
  Result := self;
end;

procedure TIni.populateIni(ini: TCustomIniFile; translate, printSource: boolean);
  var
    i,j: Integer;
    listSec, listIdent: TStrings;
    ps: String;
begin
  if(ini = nil) then exit;
  if(printSource)then begin
    ps := getSource;
    if(ps<>'')then
      ps := ' [@(' + ps + ')]';
  end else
    ps := '';

  try
    loadData;
    listSec := TStringList.Create;
    listIdent := TStringList.Create;
    try
      inif.ReadSections(listSec);
      for i := 0 to listSec.Count - 1 do begin
        listIdent.Clear;
        inif.ReadSection(listSec.Strings[i],listIdent);
        for j := 0 to listIdent.Count - 1 do begin
          ini.WriteString(listSec.Strings[i], listIdent.Strings[j],
              ReadString(listSec.Strings[i], listIdent.Strings[j], '',false) + ps );
        end;
      end;
    finally
      listSec.Free;
      listIdent.Free;
    end;
  finally
    if(lck<>nil)then
      lck.releaseLock;
  end;
end;

function TIni.printSource(list: TListSource): TListSource;
begin
  Result := checkListSource(list);
  list.Add(getSource);
end;

function TIni.ReadInteger(const Section, Ident: WideStringFramework; const Default: Integer; decrypt, translate: boolean; decrypter: ICryptografy): Integer;
begin
  Result := StrToIntDef(ReadString(Section,Ident,IntToStr(Default), decrypt, translate, decrypter),Default);
end;

function TIni.ReadString(const Section, Ident, default: WideStringFramework; decrypt, translate: boolean; decrypter: ICryptografy): WideStringFramework;
begin
  try
    loadData;
    Result := inif.ReadString(Section,Ident,Default);
    if(decrypt) and (Result<>Default) then
      Result := decryptBase64ToString(Result,decrypter,PADDING);
  finally
    if(lck<>nil) then
      lck.releaseLock;
  end;
end;

procedure TIni.setCrypted(const value: boolean);
begin
  fCrypted := value;
end;

procedure TIni.setCrypter(const value: ICryptografy);
begin
  if(value<>fCrypter) then
    fCrypter := value;
end;

procedure TIni.updateIniFile;
  var
    l: IStrings;
  procedure getData;
  begin
    if(l<>nil) then exit;
    l := createIStrings;
    if(inif is TMemIniFile) then begin
      TMemIniFile(inif).GetStrings(l.strings);
      if(fCrypted) then
        l.text := encryptStringToBase64(l.text,true,fCrypter);
    end;
  end;

  procedure saveData;
  begin
    getData;
    if(inif.FileName<>'') then begin
      if (inif is TMemIniFile) then
        l.strings.SaveToFile(inif.FileName)
      else
        inif.UpdateFile;
    end;
  end;

begin
  l := nil;
  getData;
  if(fStrings<>nil) and (inif is TMemIniFile) and (l<>nil) then begin
    fStrings.Clear;
    fStrings.Text := l.text;
  end;
  try
    saveData;
    //inif.UpdateFile;
  except
    try
      sleep(300);
      saveData;
      //inif.UpdateFile;
    except
      sleep(300);
      saveData;
      //inif.UpdateFile;
    end;
  end;
end;

procedure TIni.WriteInteger(const Section, Ident: WideStringFramework; const value: Integer; crypt: boolean; crypter: ICryptografy);
begin
  WriteString(Section, Ident, IntToStr(value), crypt, crypter);
end;

procedure TIni.WriteString(const Section, Ident, value: WideStringFramework; crypt: boolean; crypter: ICryptografy);
  var
    localValue: String;
begin
  if(crypt)then begin
    localValue := encryptStringToBase64(value,false,crypter,PADDING)
  end else
    localValue := value;
  try
    loadData;
    inif.WriteString(Section,Ident,localValue);
    updateIniFile;
  finally
    if(lck<>nil) then
      lck.releaseLock;
  end;
end;

end.
