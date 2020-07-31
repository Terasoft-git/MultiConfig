object frmTest: TfrmTest
  Left = 0
  Top = 0
  Caption = 'Multiconfig Test'
  ClientHeight = 593
  ClientWidth = 866
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 866
    Height = 593
    ActivePage = TabSheet1
    Align = alClient
    TabOrder = 0
    object TabSheet1: TTabSheet
      Caption = 'Tests'
      object BitBtn1: TBitBtn
        Left = 16
        Top = 24
        Width = 75
        Height = 25
        Caption = 'Test LOCK'
        TabOrder = 0
        OnClick = BitBtn1Click
      end
      object BitBtn2: TBitBtn
        Left = 128
        Top = 24
        Width = 75
        Height = 25
        Caption = 'Test LRTimer'
        TabOrder = 1
        OnClick = BitBtn2Click
      end
      object mm: TMemo
        Left = 0
        Top = 296
        Width = 858
        Height = 269
        Align = alBottom
        Lines.Strings = (
          'mm')
        TabOrder = 2
      end
      object BitBtn3: TBitBtn
        Left = 680
        Top = 128
        Width = 75
        Height = 21
        Caption = 'Encrypt'
        TabOrder = 3
        OnClick = BitBtn3Click
      end
      object editSeed: TLabeledEdit
        Left = 16
        Top = 72
        Width = 633
        Height = 21
        EditLabel.Width = 24
        EditLabel.Height = 13
        EditLabel.Caption = 'Seed'
        TabOrder = 4
      end
      object editTextToEncrypt: TLabeledEdit
        Left = 16
        Top = 128
        Width = 633
        Height = 21
        EditLabel.Width = 75
        EditLabel.Height = 13
        EditLabel.Caption = 'Text to Encrypt'
        TabOrder = 5
      end
      object editEncrypted: TLabeledEdit
        Left = 16
        Top = 168
        Width = 633
        Height = 21
        EditLabel.Width = 74
        EditLabel.Height = 13
        EditLabel.Caption = 'Encrypted Text'
        TabOrder = 6
      end
      object BitBtn4: TBitBtn
        Left = 680
        Top = 168
        Width = 75
        Height = 21
        Caption = 'Decrypt'
        TabOrder = 7
        OnClick = BitBtn4Click
      end
    end
  end
end
