object ServerDataModule: TServerDataModule
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Encoding = esASCII
  Height = 233
  Width = 267
  object FDConnection1: TFDConnection
    Params.Strings = (
      'DriverID=SQLite'
      'Database=..\..\..\Data\Database\database.db3')
    LoginPrompt = False
    Left = 68
    Top = 42
  end
  object Master: TDWServerEvents
    IgnoreInvalidParams = False
    Events = <
      item
        DWParams = <>
        JsonMode = jmPureJSON
        Name = 'select'
        OnReplyEvent = MasterEventsselectReplyEvent
      end
      item
        DWParams = <>
        JsonMode = jmPureJSON
        Name = 'selectid'
        OnReplyEvent = MasterEventsselectidReplyEvent
      end
      item
        DWParams = <>
        JsonMode = jmPureJSON
        Name = 'selectwhere'
        OnReplyEvent = MasterEventsselectwhereReplyEvent
      end
      item
        DWParams = <>
        JsonMode = jmPureJSON
        Name = 'insert'
        OnReplyEvent = MasterEventsinsertReplyEvent
      end
      item
        DWParams = <>
        JsonMode = jmPureJSON
        Name = 'update'
        OnReplyEvent = MasterEventsupdateReplyEvent
      end
      item
        DWParams = <>
        JsonMode = jmPureJSON
        Name = 'delete'
        OnReplyEvent = MasterEventsdeleteReplyEvent
      end
      item
        DWParams = <>
        JsonMode = jmPureJSON
        Name = 'nextpacket'
        OnReplyEvent = MasterEventsnextpacketReplyEvent
      end
      item
        DWParams = <>
        JsonMode = jmPureJSON
        Name = 'nextpacketwhere'
        OnReplyEvent = MasterEventsnextpacketwhereReplyEvent
      end>
    ContextName = 'master'
    Left = 32
    Top = 162
  end
  object Lookup: TDWServerEvents
    IgnoreInvalidParams = False
    Events = <
      item
        DWParams = <>
        JsonMode = jmPureJSON
        Name = 'select'
        OnReplyEvent = LookupEventsselectReplyEvent
      end>
    ContextName = 'lookup'
    Left = 204
    Top = 160
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
end
