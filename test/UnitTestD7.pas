
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
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
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
  Terasoft_git.Framework.Types;

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
  var
    crypt: ICryptografy;
    b: TBytes;
begin
  crypt := createCrypter(stringToBytes(editSeed.Text));
  b := crypt.encryptString(editToEncrypt.Text);


end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  editSeed.Text := CRYPTO_DUMMY_SEED;
  editToEncrypt.Text := 'This is a text to encrypt.';
end;

end.

