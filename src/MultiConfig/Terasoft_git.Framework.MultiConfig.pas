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
      function ReadString(const Section, Ident: WideStringFramework; const default: WideStringFramework = '';
          decrypt: boolean = false; translate: boolean = true; decrypter: ICryptografy = nil): WideStringFramework;
      function ReadInteger(const Section, Ident: String; const Default: Integer = 0; decrypt: boolean = false; translate: boolean = true; descrypter: ICryptografy = nil): Integer;
      procedure populateIni(ini: TCustomIniFile; translate: boolean = true; printSource: boolean = false);
      function getSource: WideStringFramework;
    end;

    IConfigWriter = interface
      ['{6CE68896-E3EA-4CF7-BC8C-064066CEE7E1}']
      procedure WriteString(const Section, Ident, value: WideStringFramework; crypt: boolean = false; crypter: ICryptografy = nil);
      procedure WriteInteger(const Section, Ident: WideStringFramework; const value: Integer; crypt: boolean = false; crypter: ICryptografy = nil);
      procedure deleteKey(const Section: String = ''; const Ident: String = '');
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

      //for Readers
      function ReadDateTime(const Section, Ident: WideStringFramework; const Default: TDateTime = 0; decrypt: boolean = false; translate: boolean = true): TDateTime;
      function ReadString(const Section, Ident: WideStringFramework; const Default: WideStringFramework = ''; decrypt: boolean = false; translate: boolean = true; decrypter: ICryptografy = nil): WideStringFramework;
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
      property multiWriter: IConfigWriter read getMultiWriter;


    end;


implementation

end.
