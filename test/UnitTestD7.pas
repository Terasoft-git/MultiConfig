
{$i multicfg.inc}

unit UnitTestD7;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls;


  { This Test uses DLL mode of MUltiConfig }

type
  TForm1 = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    mm: TMemo;
    Button1: TButton;
    editSeed: TLabeledEdit;
    editToEncrypt: TLabeledEdit;
    editCrypted: TLabeledEdit;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation
  uses
    Terasoft_git.Framework.Cryptography, Terasoft_git.Framework.Bytes,
  Terasoft_git.Framework.Types, Terasoft_git.Framework.VisualMessage;

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
  var
    crypt: ICryptografy;
    s: String;
begin
  crypt := createCrypter(stringToBytes(editSeed.Text));
  s := crypt.encryptStringToBase64(editToEncrypt.Text);
  mm.lines.add(Format('Encrypted text: %s', [ s ] ));
  editCrypted.Text := s;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  editSeed.Text := CRYPTO_DUMMY_SEED;
  editToEncrypt.Text := 'This is a text to encrypt.';
end;

procedure TForm1.Button2Click(Sender: TObject);
  var
    crypt: ICryptografy;
    s: String;
begin
  if(editCrypted.Text='') then
    ShowError('Nothing to decrypt.');
  crypt := createCrypter(stringToBytes(editSeed.Text));
  s := crypt.decryptBase64ToString(editCrypted.Text);
  mm.lines.add(Format('Decrypted text: %s', [ s ] ));
  editToEncrypt.Text := s;
end;

end.

