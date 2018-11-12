object ServerDataModule: TServerDataModule
  OldCreateOrder = False
  Height = 303
  Width = 362
  object FDConnection1: TFDConnection
    Params.Strings = (
      'DriverID=SQLite'
      'Database=..\..\..\Data\Database\database.db3')
    LoginPrompt = False
    Left = 86
    Top = 48
  end
  object FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink
    Left = 172
    Top = 48
  end
  object FDGUIxWaitCursor1: TFDGUIxWaitCursor
    Provider = 'Forms'
    Left = 126
    Top = 134
  end
end
