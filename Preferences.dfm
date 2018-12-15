object FormPreferences: TFormPreferences
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Preferences'
  ClientHeight = 201
  ClientWidth = 307
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label5: TLabel
    Left = 8
    Top = 177
    Width = 39
    Height = 13
    Caption = 'Ini File='
  end
  object GroupBoxOptions: TGroupBox
    Left = 8
    Top = 0
    Width = 290
    Height = 137
    Caption = 'Options'
    TabOrder = 0
    object Label1: TLabel
      Left = 8
      Top = 16
      Width = 35
      Height = 13
      Caption = 'Cipher:'
    end
    object Label2: TLabel
      Left = 15
      Top = 43
      Width = 28
      Height = 13
      Caption = 'Hash:'
    end
    object Label3: TLabel
      Left = 8
      Top = 62
      Width = 55
      Height = 13
      Caption = 'Passphase:'
    end
    object Label4: TLabel
      Left = 135
      Top = 113
      Width = 79
      Height = 13
      Caption = 'Compress Level:'
    end
    object cbxCipher: TComboBox
      Left = 49
      Top = 13
      Width = 232
      Height = 21
      Hint = #1052#1077#1090#1086#1076' '#1096#1080#1092#1088#1086#1074#1072#1085#1080#1103' '#1090#1077#1082#1089#1090#1072
      Style = csDropDownList
      ItemIndex = 0
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      Text = 'RC4'
      Items.Strings = (
        'RC4'
        'Blowfish'
        'Rijndael')
    end
    object cbxHash: TComboBox
      Left = 49
      Top = 40
      Width = 232
      Height = 21
      Hint = #1052#1077#1090#1086#1076' '#1093#1077#1096#1080#1088#1086#1074#1072#1085#1080#1103' '#1087#1072#1088#1086#1083#1103
      Style = csDropDownList
      ItemIndex = 2
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      Text = 'SHA-512'
      Items.Strings = (
        'Haval (5 pass, 256 bit)'
        'MD5'
        'SHA-512')
    end
    object cbxLevel: TComboBox
      Left = 216
      Top = 110
      Width = 65
      Height = 21
      Hint = 
        #1055#1088#1080' '#1087#1086#1089#1099#1083#1082#1077' '#1082#1086#1088#1086#1090#1082#1080#1093' '#1089#1086#1086#1073#1097#1077#1085#1080#1081', '#1086#1090#1082#1083#1102#1095#1080#1090#1077' '#1088#1072#1073#1086#1090#1091' zip-'#1082#1086#1084#1087#1088#1077#1089#1089#1086#1088#1072 +
        '.   '
      Style = csDropDownList
      ItemIndex = 3
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
      Text = 'Max'
      Items.Strings = (
        'None'
        'Fastest'
        'Default'
        'Max')
    end
    object ePassphase: TEdit
      Left = 8
      Top = 81
      Width = 247
      Height = 21
      TabOrder = 3
    end
    object btButGen: TButton
      Left = 254
      Top = 79
      Width = 27
      Height = 25
      Hint = #1043#1077#1085#1077#1088#1080#1088#1086#1074#1072#1090#1100' '#1087#1089#1077#1074#1076#1086#1089#1083#1091#1095#1072#1081#1085#1099#1081' '#1087#1072#1088#1086#1083#1100
      Caption = 'Gen'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 4
      OnClick = btButGenClick
    end
    object cbPrivate: TCheckBox
      Left = 8
      Top = 112
      Width = 121
      Height = 17
      Hint = #1064#1080#1092#1088#1086#1074#1072#1085#1080#1077' '#1090#1086#1083#1100#1082#1086' '#1087#1088#1080#1074#1072#1090#1085#1099#1093' '#1082#1072#1085#1072#1083#1086#1074
      Caption = 'Only Private Canals'
      Checked = True
      ParentShowHint = False
      ShowHint = True
      State = cbChecked
      TabOrder = 5
    end
  end
  object edtiniFile: TEdit
    Left = 48
    Top = 174
    Width = 250
    Height = 21
    ReadOnly = True
    TabOrder = 1
  end
  object cbMain: TCheckBox
    Left = 8
    Top = 143
    Width = 97
    Height = 17
    Hint = #1042#1082#1083#1102#1095#1077#1085#1080#1077' \ '#1042#1099#1082#1083#1102#1095#1077#1085#1080#1077' '#1096#1080#1092#1088#1086#1074#1072#1085#1080#1103
    Caption = 'Crypt\Decrypt'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 2
    OnClick = cbMainClick
  end
  object cbClose: TButton
    Left = 214
    Top = 143
    Width = 75
    Height = 25
    Caption = 'Apply'
    TabOrder = 3
    OnClick = cbCloseClick
  end
end
