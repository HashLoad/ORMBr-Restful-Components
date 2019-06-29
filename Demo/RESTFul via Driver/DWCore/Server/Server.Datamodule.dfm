object ServerDataModule: TServerDataModule
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Encoding = esASCII
  Height = 286
  Width = 267
  object FDConnection1: TFDConnection
    Params.Strings = (
      'Database=D:\ORMBr\Demo\Data\Database\database.db3'
      'DriverID=SQLite')
    LoginPrompt = False
    Left = 68
    Top = 42
  end
  object FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink
    Left = 162
    Top = 40
  end
  object FDGUIxWaitCursor1: TFDGUIxWaitCursor
    Provider = 'Forms'
    Left = 118
    Top = 100
  end
  object Master: TDWServerEvents
    IgnoreInvalidParams = False
    Events = <
      item
        Routes = [crAll]
        DWParams = <>
        JsonMode = jmPureJSON
        Name = 'select'
      end
      item
        Routes = [crAll]
        DWParams = <>
        JsonMode = jmPureJSON
        Name = 'selectid'
      end
      item
        Routes = [crAll]
        DWParams = <>
        JsonMode = jmPureJSON
        Name = 'selectwhere'
      end
      item
        Routes = [crAll]
        DWParams = <>
        JsonMode = jmPureJSON
        Name = 'insert'
      end
      item
        Routes = [crAll]
        DWParams = <>
        JsonMode = jmPureJSON
        Name = 'update'
      end
      item
        Routes = [crAll]
        DWParams = <>
        JsonMode = jmPureJSON
        Name = 'delete'
      end
      item
        Routes = [crAll]
        DWParams = <>
        JsonMode = jmPureJSON
        Name = 'nextpacket'
      end
      item
        Routes = [crAll]
        DWParams = <>
        JsonMode = jmPureJSON
        Name = 'nextpacketwhere'
      end>
    ContextName = 'master'
    Left = 37
    Top = 158
  end
  object Lookup: TDWServerEvents
    IgnoreInvalidParams = False
    Events = <
      item
        Routes = [crAll]
        DWParams = <>
        JsonMode = jmPureJSON
        Name = 'select'
      end>
    ContextName = 'lookup'
    Left = 204
    Top = 160
  end
  object ServerEvents: TDWServerEvents
    IgnoreInvalidParams = False
    Events = <
      item
        Routes = [crAll]
        DWParams = <>
        JsonMode = jmPureJSON
        Name = 'api'
      end>
    ContextName = 'ormbr'
    Left = 130
    Top = 201
  end
end
