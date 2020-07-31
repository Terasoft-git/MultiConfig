unit Terasoft_git.Framework.MultiConfig.INI;

interface
  uses
    Terasoft_git.Framework.Types, Terasoft_git.Framework.MultiConfig, Windows;

  function createConfigIniFile(const filename: String; const hint: String = ''): IConfigReaderWriter;
  function createConfigRegistry(const path: String = ''; rootkey: HKEY = 0; const hint: String = ''): IConfigReaderWriter;
  function createConfigIniString(const str: String; const hint: String = ''): IConfigReaderWriter;
  function createConfigCmdLine(const hint: String = ''; const prefix: String = ''): IConfigReaderWriter;
  function createConfigEnvVar(const prefix: String = ''; const hint: String = ''): IConfigReaderWriter;


implementation
  uses
    iniFiles, StrUtils, SysUtils, Classes, Registry, Terasoft_git.Framework.Lock,
    Terasoft_git.Framework.Cryptography,
    Terasoft_git.Framework.Texts;

  type
    TIni = class(TInterfacedObject, IConfigReaderWriter, IConfigReader, IConfigWriter )
    private
      inif: TCustomIniFile;
      lck: Ilock;
      fHint: String;
      function getReader: IConfigReader;
      function getWriter: IConfigWriter;
      function ReadString(const Section, Ident: WideStringFramework; const default: WideStringFramework = ''; decrypt: boolean = false; translate: boolean = true; decrypter: ICryptografy = nil): WideStringFramework;
      function ReadInteger(const Section, Ident: WideStringFramework; const Default: Integer = 0; decrypt: boolean = false; translate: boolean = true; decrypter: ICryptografy = nil): Integer;
      procedure WriteString(const Section, Ident, value: WideStringFramework; crypt: boolean = false; crypter: ICryptografy = nil);
      procedure WriteInteger(const Section, Ident: WideStringFramework; const value: Integer; crypt: boolean = false; crypter: ICryptografy = nil);
      procedure deleteKey(const Section: WideStringFramework = ''; const Ident: WideStringFramework = '');
      procedure populateIni(ini: TCustomIniFile; translate: boolean = true; printSource: boolean = false);
      function getSource: WideStringFramework;
      function printSource(list: TListSource): TListSource;
      procedure updateIniFile;
    public
      constructor Create(aInif: TCustomIniFile; const hint: String);
      destructor Destroy; override;
    end;


function createConfigIniFile(const filename: String; const hint: String): IConfigReaderWriter;
  var
    fName: String;
begin
  if(filename=MULTICONFIG_DEFAULTINIFILE)then
    fName := ChangeFileExt(ParamStr(0),'.ini')
  else
    fName := filename;
  fName := ExpandFileName(fName);
  Result := TIni.Create(TMemIniFile.Create(fName),hint);
end;

function createConfigRegistry(const path: String = ''; rootkey: HKEY = 0; const hint: String = ''): IConfigReaderWriter;
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
  Result := TIni.Create(reg,'Registry: ' + realPath + ': '+ hint);
  reg.RegIniFile.OpenKey(realPath,true);
end;

function createConfigIniString(const str: String; const hint: String = ''): IConfigReaderWriter;
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
  Result := TIni.Create(f,hint);
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


function createConfigEnvVar(const prefix: String = ''; const hint: String = ''): IConfigReaderWriter;
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
          Result := TIni.Create(ini,'EnvVar prefix ' + realPrefix + ': ' + hint);
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

function createConfigCmdLine(const hint: String = ''; const prefix: String = ''): IConfigReaderWriter;
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
      Result := TIni.Create(ini,'Command line parameters: ' + hint);
    end;
    addStrIni(ini,str);
  end;
end;



{ TIni }

constructor TIni.Create(aInif: TCustomIniFile; const hint: String);
begin
  inherited Create;
  inif := aInif;
  fHint:=hint;
  if(ainif.FileName<>'') and (ainif is TMemIniFile) then
    lck := FileILock(inif.FileName + '.lock');
end;

procedure TIni.deleteKey(const Section, Ident: WideStringFramework);
  var
    i: Integer;
    list: TStrings;
begin
  if(lck<>nil)and (lck.lock<>ltExclusive) then
    raise Exception.CreateFmt('TIni.deleteKey: Not acquired exclusive access to file [%s]', [ inif.FileName ] );
  try
    if(inif.FileName<>'') and (inif is TMemIniFile) then
      (inif as TMemIniFile).Rename(inif.FileName,true);

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
  if(lck<>nil)and (lck.lock<>ltExclusive) then
    raise Exception.CreateFmt('TIni.populateIni Not acquired exclusive access to file [%s]', [ inif.FileName ] );
  try
    listSec := TStringList.Create;
    listIdent := TStringList.Create;
    try
      if(inif.FileName<>'') and (inif is TMemIniFile) then
        (inif as TMemIniFile).Rename(inif.FileName,true);
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
  if(lck<>nil)and (lck.lock<>ltExclusive) then
    raise Exception.CreateFmt('TIni.ReadString: Not acquired exclusive access to file [%s]', [ inif.FileName ] );
  try
    if(inif.FileName<>'') and (inif is TMemIniFile) then
      (inif as TMemIniFile).Rename(inif.FileName,true);
    Result := inif.ReadString(Section,Ident,Default);
    if(decrypt) and (Result<>Default) then begin
      if(decrypter=nil) then
        decrypter := globalCrypter;
      if(decrypter<>nil) then
        Result := decrypter.decryptBase64ToString(Result)
      else
        raise Exception.Create('TIni.ReadString: Decrypter not defined');
    end;
  finally
    if(lck<>nil) then
      lck.releaseLock;
  end;
end;

procedure TIni.updateIniFile;
begin
  if(inif.FileName<>'') then begin
    try
      inif.UpdateFile;
    except
      try
        sleep(100);
        inif.UpdateFile;
      except
        sleep(100);
        inif.UpdateFile;
      end;
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
    if(crypter=nil) then
      crypter := globalCrypter;
    if(crypter<>nil) then
      localValue := crypter.encryptStringToBase64(value,false)
    else
      raise Exception.Create('TIni.WriteString: crypter not defined');
  end else
    localValue := value;
  if(lck<>nil)and (lck.lock<>ltExclusive) then
    raise Exception.CreateFmt('TIni.WriteString: Not acquired exclusive access to file [%s]', [ inif.FileName ] );
  try
    if(inif.FileName<>'') and (inif is TMemIniFile) then
      (inif as TMemIniFile).Rename(inif.FileName,true);
    inif.WriteString(Section,Ident,localValue);
    updateIniFile
  finally
    if(lck<>nil) then
      lck.releaseLock;
  end;
end;

end.
