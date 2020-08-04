object Form1: TForm1
  Left = 192
  Top = 124
  Width = 1305
  Height = 675
  Caption = 'Tests via MultiCfgIface.dll'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 1289
    Height = 637
    ActivePage = TabSheet1
    Align = alClient
    TabOrder = 0
    object TabSheet1: TTabSheet
      Caption = 'Tests'
      object mm: TMemo
        Left = 0
        Top = 200
        Width = 1281
        Height = 409
        Align = alBottom
        Lines.Strings = (
          'mm')
        TabOrder = 0
      end
      object Button1: TButton
        Left = 472
        Top = 64
        Width = 75
        Height = 25
        Caption = 'Encrypt'
        TabOrder = 1
        OnClick = Button1Click
      end
      object editSeed: TLabeledEdit
        Left = 24
        Top = 16
        Width = 441
        Height = 21
        EditLabel.Width = 25
        EditLabel.Height = 13
        EditLabel.Caption = 'Seed'
        TabOrder = 2
      end
      object editToEncrypt: TLabeledEdit
        Left = 24
        Top = 64
        Width = 433
        Height = 21
        EditLabel.Width = 72
        EditLabel.Height = 13
        EditLabel.Caption = 'Text to Encrypt'
        TabOrder = 3
      end
      object editCrypted: TLabeledEdit
        Left = 24
        Top = 104
        Width = 433
        Height = 21
        EditLabel.Width = 72
        EditLabel.Height = 13
        EditLabel.Caption = 'Text to Encryot'
        TabOrder = 4
      end
      object Button2: TButton
        Left = 472
        Top = 104
        Width = 75
        Height = 25
        Caption = 'Decrypt'
        TabOrder = 5
        OnClick = Button2Click
      end
      object Button3: TButton
        Left = 600
        Top = 104
        Width = 177
        Height = 25
        Caption = 'Test MultiCfg DLL'
        TabOrder = 6
        OnClick = Button3Click
      end
    end
  end
end
