object frmTest: TfrmTest
  Left = 0
  Top = 0
  Caption = 'Multiconfig Test'
  ClientHeight = 300
  ClientWidth = 635
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 635
    Height = 300
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
        Left = 16
        Top = 72
        Width = 75
        Height = 25
        Caption = 'Test LRTimer'
        TabOrder = 1
        OnClick = BitBtn2Click
      end
      object mm: TMemo
        Left = 0
        Top = 120
        Width = 627
        Height = 152
        Align = alBottom
        Lines.Strings = (
          'mm')
        TabOrder = 2
      end
    end
  end
end
