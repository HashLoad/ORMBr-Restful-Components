object ServerDataModule: TServerDataModule
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Encoding = esASCII
  Height = 233
  Width = 267
  object FDConnection1: TFDConnection
    Params.Strings = (
      'Database=D:\ORMBr\Demo\Data\Database\database.db3'
      'DriverID=SQLite')
    LoginPrompt = False
    Left = 68
    Top = 42
  end
  object Master: TDWServerEvents
    IgnoreInvalidParams = False
    Events = <
      item
        Routes = [crAll]
        DWParams = <
          item
            TypeObject = toParam
            ObjectDirection = odINOUT
            ObjectValue = ovString
            ParamName = 'dwparam1'
            Encoded = True
          end
          item
            TypeObject = toParam
            ObjectDirection = odINOUT
            ObjectValue = ovString
            ParamName = 'dwparam2'
            Encoded = True
          end>
        JsonMode = jmPureJSON
        Name = 'select'
        OnReplyEvent = MasterEventsselectReplyEvent
      end
      item
        Routes = [crAll]
        DWParams = <>
        JsonMode = jmPureJSON
        Name = 'selectid'
        OnReplyEvent = MasterEventsselectidReplyEvent
      end
      item
        Routes = [crAll]
        DWParams = <>
        JsonMode = jmPureJSON
        Name = 'selectwhere'
        OnReplyEvent = MasterEventsselectwhereReplyEvent
      end
      item
        Routes = [crAll]
        DWParams = <>
        JsonMode = jmPureJSON
        Name = 'insert'
        OnReplyEvent = MasterEventsinsertReplyEvent
      end
      item
        Routes = [crAll]
        DWParams = <>
        JsonMode = jmPureJSON
        Name = 'update'
        OnReplyEvent = MasterEventsupdateReplyEvent
      end
      item
        Routes = [crAll]
        DWParams = <>
        JsonMode = jmPureJSON
        Name = 'delete'
        OnReplyEvent = MasterEventsdeleteReplyEvent
      end
      item
        Routes = [crAll]
        DWParams = <>
        JsonMode = jmPureJSON
        Name = 'nextpacket'
        OnReplyEvent = MasterEventsnextpacketReplyEvent
      end
      item
        Routes = [crAll]
        DWParams = <>
        JsonMode = jmPureJSON
        Name = 'nextpacketwhere'
        OnReplyEvent = MasterEventsnextpacketwhereReplyEvent
      end>
    ContextName = 'master'
    Left = 28
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
