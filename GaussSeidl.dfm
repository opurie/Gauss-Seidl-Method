object FormGUI: TFormGUI
  Left = 0
  Top = 0
  Hint = 
    'Program s'#322'u'#380'acy do obliczania uk'#322'adu r'#243'wna'#324' liniowych metod'#261' Gau' +
    'ssa Seidla'
  Anchors = [akLeft, akTop, akRight, akBottom]
  Caption = 'Gauss Seidl'
  ClientHeight = 425
  ClientWidth = 867
  Color = clBtnFace
  Constraints.MinHeight = 200
  Constraints.MinWidth = 300
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object PanelText: TPanel
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 646
    Height = 400
    Align = alLeft
    Anchors = [akLeft, akTop, akRight, akBottom]
    Caption = 'PanelText'
    TabOrder = 0
    object PageControl1: TPageControl
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 638
      Height = 392
      ActivePage = Dane
      Align = alClient
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindow
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      object Dane: TTabSheet
        Caption = 'Dane'
        ImageIndex = 3
        object DrawGridDane: TDrawGrid
          Left = 0
          Top = 0
          Width = 630
          Height = 364
          Align = alClient
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing, goTabs]
          ParentFont = False
          TabOrder = 0
          OnDrawCell = DrawGridDaneDrawCell
          OnGetEditText = DrawGridDaneGetEditText
          OnKeyPress = DrawGridDaneKeyPress
          OnSelectCell = DrawGridDaneSelectCell
          OnSetEditText = DrawGridDaneSetEditText
        end
      end
      object Przedzialowa: TTabSheet
        Caption = 'Przedzia'#322'owa'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ImageIndex = 2
        ParentFont = False
        object RichEditPrzedzialowa: TRichEdit
          Left = 0
          Top = 0
          Width = 630
          Height = 364
          Align = alClient
          Font.Charset = EASTEUROPE_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          Lines.Strings = (
            'RichEditPrzedzialowa')
          ParentFont = False
          ReadOnly = True
          ScrollBars = ssBoth
          TabOrder = 0
        end
      end
      object Zmiennoprzecinkowa: TTabSheet
        Caption = 'Zmiennoprzecinkowa'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ImageIndex = 1
        ParentFont = False
        object RichEditZmiennoprzecinkowa: TRichEdit
          Left = 0
          Top = 0
          Width = 630
          Height = 364
          Align = alClient
          Font.Charset = EASTEUROPE_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          Lines.Strings = (
            'RichEditZmiennoprzecinkowa')
          ParentFont = False
          ReadOnly = True
          ScrollBars = ssBoth
          TabOrder = 0
        end
      end
    end
  end
  object PanelControl: TPanel
    AlignWithMargins = True
    Left = 655
    Top = 3
    Width = 204
    Height = 400
    Align = alLeft
    TabOrder = 1
    object LabelLiczbaZmiennych: TLabel
      Left = 9
      Top = 84
      Width = 97
      Height = 14
      Caption = 'Liczba zmiennych:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object LabelLiczbaIteracji: TLabel
      Left = 16
      Top = 223
      Width = 75
      Height = 14
      Caption = 'Liczba iteracji:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object LabelDokladnosc: TLabel
      Left = 16
      Top = 250
      Width = 106
      Height = 14
      Caption = 'Dok'#322'adno'#347#263': 1*10^'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object UpDownLiczbaZmiennych: TUpDown
      Left = 177
      Top = 84
      Width = 15
      Height = 21
      Associate = EditLiczbaZmiennych
      Min = 1
      Max = 1000
      Position = 1
      TabOrder = 0
      Thousands = False
    end
    object EditLiczbaZmiennych: TEdit
      Left = 112
      Top = 84
      Width = 65
      Height = 21
      MaxLength = 4
      NumbersOnly = True
      TabOrder = 1
      Text = '1'
      OnChange = EditLiczbaZmiennychChange
    end
    object ButtonStworzTabele: TButton
      Left = 8
      Top = 53
      Width = 90
      Height = 25
      Caption = 'Stworz Tabele'
      TabOrder = 2
      OnClick = ButtonStworzTabeleClick
    end
    object ButtonDodajZmienna: TButton
      Left = 8
      Top = 111
      Width = 90
      Height = 25
      Caption = 'Dodaj Zmienn'#261
      TabOrder = 3
      OnClick = ButtonDodajZmiennaClick
    end
    object ButtonUsunZmienna: TButton
      Left = 103
      Top = 111
      Width = 90
      Height = 25
      Caption = 'Usu'#324' Zmienn'#261
      TabOrder = 4
      OnClick = ButtonUsunZmiennaClick
    end
    object ButtonWyczyscTabele: TButton
      Left = 103
      Top = 53
      Width = 90
      Height = 25
      Caption = 'Wyczysc Tabele'
      TabOrder = 5
      OnClick = ButtonWyczyscTabeleClick
    end
    object RadioGroupMetoda: TRadioGroup
      Left = 8
      Top = 142
      Width = 185
      Height = 75
      Caption = 'Wybierz metode oblicze'#324':'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      Items.Strings = (
        'Arytmetyka przedzia'#322'owa'
        'Arytmetyka zmiennoprzecinkowa')
      ParentFont = False
      TabOrder = 6
    end
    object ButtonOblicz: TButton
      Left = 8
      Top = 22
      Width = 75
      Height = 25
      Caption = 'Oblicz!'
      TabOrder = 7
      OnClick = ButtonObliczClick
    end
    object EditLiczbaIteracji: TEdit
      Left = 97
      Top = 223
      Width = 56
      Height = 21
      NumbersOnly = True
      TabOrder = 8
      Text = '10'
      OnChange = EditLiczbaIteracjiChange
    end
    object EditDokladnosc: TEdit
      Left = 128
      Top = 250
      Width = 57
      Height = 21
      NumbersOnly = True
      TabOrder = 9
      Text = '-14'
      OnChange = EditDokladnoscChange
    end
    object UpDownLiczbaIteracji: TUpDown
      Left = 153
      Top = 223
      Width = 16
      Height = 21
      Associate = EditLiczbaIteracji
      Min = 1
      Max = 1000
      Position = 10
      TabOrder = 10
    end
    object UpDownDokladnosc: TUpDown
      Left = 185
      Top = 250
      Width = 16
      Height = 21
      Associate = EditDokladnosc
      Min = -16
      Max = 6
      Position = -14
      TabOrder = 11
    end
    object ButtonPrzyklad: TButton
      Left = 9
      Top = 282
      Width = 104
      Height = 25
      Caption = 'Wczytaj przyk'#322'ad'
      TabOrder = 12
      OnClick = ButtonPrzykladClick
    end
    object EditPrzyklad: TEdit
      Left = 119
      Top = 284
      Width = 50
      Height = 21
      MaxLength = 1
      NumbersOnly = True
      TabOrder = 13
      Text = '1'
      OnChange = EditPrzykladChange
    end
    object UpDownPrzyklad: TUpDown
      Left = 169
      Top = 284
      Width = 16
      Height = 21
      Associate = EditPrzyklad
      Min = 1
      Max = 6
      Position = 1
      TabOrder = 14
    end
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 406
    Width = 867
    Height = 19
    Panels = <
      item
        Text = 'R:'
        Width = 80
      end
      item
        Text = 'X:'
        Width = 80
      end
      item
        Style = psOwnerDraw
        Text = 'ProgressBar'
        Width = 300
      end
      item
        Text = 'Gotowy!'
        Width = 80
      end>
  end
end
