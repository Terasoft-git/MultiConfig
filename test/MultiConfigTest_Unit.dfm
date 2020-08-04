object frmTest: TfrmTest
  Left = 0
  Top = 0
  Caption = 'Multiconfig Test'
  ClientHeight = 593
  ClientWidth = 866
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Verdana'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 16
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
        Width = 106
        Height = 25
        Caption = 'Test LOCK'
        TabOrder = 0
        OnClick = BitBtn1Click
      end
      object BitBtn2: TBitBtn
        Left = 128
        Top = 24
        Width = 106
        Height = 25
        Caption = 'Test LRTimer'
        TabOrder = 1
        OnClick = BitBtn2Click
      end
      object mm: TMemo
        Left = 0
        Top = 208
        Width = 858
        Height = 354
        Align = alBottom
        Anchors = [akLeft, akTop, akRight, akBottom]
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Verdana'
        Font.Style = []
        Lines.Strings = (
          'mm')
        ParentFont = False
        ScrollBars = ssBoth
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
        Height = 24
        EditLabel.Width = 33
        EditLabel.Height = 16
        EditLabel.Caption = 'Seed'
        TabOrder = 4
      end
      object editTextToEncrypt: TLabeledEdit
        Left = 16
        Top = 128
        Width = 633
        Height = 24
        EditLabel.Width = 105
        EditLabel.Height = 16
        EditLabel.Caption = 'Text to Encrypt'
        TabOrder = 5
      end
      object editEncrypted: TLabeledEdit
        Left = 16
        Top = 168
        Width = 633
        Height = 24
        EditLabel.Width = 102
        EditLabel.Height = 16
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
      object BitBtn5: TBitBtn
        Left = 240
        Top = 24
        Width = 121
        Height = 25
        Caption = 'Test MultiCfg'
        TabOrder = 8
        OnClick = BitBtn5Click
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Values 1'
      ImageIndex = 1
      object Memo1: TMemo
        Left = 0
        Top = 0
        Width = 858
        Height = 562
        Align = alClient
        Lines.Strings = (
          'Memo1')
        ScrollBars = ssBoth
        TabOrder = 0
      end
    end
    object TabSheet3: TTabSheet
      Caption = 'Values 2'
      ImageIndex = 2
      object Memo2: TMemo
        Left = 0
        Top = 0
        Width = 858
        Height = 562
        Align = alClient
        Lines.Strings = (
          
            'ZKvMN3zILqRSA8Ctu+w5fbyckgp99BBZ+hzvU++ejF30hOHrxQPJkduZVH4VthDQ' +
            'pUqfHeicVZXr'
          
            'o4bgz7VhQbpj1jaQtwiGlZoGExwhC7IfqnhKz9TS6Isszf2WU3WDKs+h1vOdjpJj' +
            'HKdAP1P/VF+3'
          
            'Tb1jjC6161yBLKgXmdlpBEGTjAw7B6i7sum2CtnPIExmAnKghiQvKj52OF7u7Imw' +
            '9UjbgqvvDc2o'
          'nfEPsG2hfEKR6NBDcoSETtKMyLTy')
        ScrollBars = ssBoth
        TabOrder = 0
      end
    end
    object TabSheet4: TTabSheet
      Caption = 'Values 3'
      ImageIndex = 3
      object Memo3: TMemo
        Left = 0
        Top = 0
        Width = 858
        Height = 562
        Align = alClient
        Lines.Strings = (
          
            'ZKvMN3zILqRSA8Ctu+w5fbyckgp99BBZ+hzvU++ejF30hOHrxQPJkduZVH4VthDQ' +
            'pUqfHeicVZXr'
          
            'o4bgz7VhQbpj1jaQtwiGlZoGExwhC7IfqnhKz9TS6Isszf2WU3WDKs+h1vOdjpJj' +
            'HKdAP1P/VF+3'
          
            'Tb1jjC6161yBLKgXmdlpBEGTjAw7B6i7sum2CtnPIExmAnKghiQvKj52OF7u7Imw' +
            '9UjbgqvvDc2o'
          'nfEPsG2hfEKR6NBDcoSETtKMyLTy')
        ScrollBars = ssBoth
        TabOrder = 0
      end
    end
  end
end
