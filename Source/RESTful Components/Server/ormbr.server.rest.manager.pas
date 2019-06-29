{
      ORM Brasil é um ORM simples e descomplicado para quem utiliza Delphi

                   Copyright (c) 2016, Isaque Pinheiro
                          All rights reserved.
}

{ 
  @abstract(REST Componentes)
  @created(20 Jul 2016)
  @author(Isaque Pinheiro <isaquepsp@gmail.com>)
  @author(Skype : ispinheiro)
  @abstract(Website : http://www.ormbr.com.br)
  @abstract(Telagram : https://t.me/ormbr)
}

unit ormbr.server.rest.manager;

interface

uses
  DB,
  Rtti,
  Types,
  Classes,
  SysUtils,
  Variants,
  Generics.Collections,
  /// ormbr
  ormbr.types.mapping,
  ormbr.mapping.classes,
  ormbr.command.factory,
  ormbr.factory.interfaces,
  ormbr.mapping.explorer,
  ormbr.objects.manager.abstract,
  ormbr.mapping.explorerstrategy;

type
  TRESTObjectManager = class
  private
    FOwner: TObject;
    FObjectInternal: TObject;
    procedure FillAssociation(const AObject: TObject);
    procedure FillAssociationLazy(const AOwner, AObject: TObject);
  protected
    FConnection: IDBConnection;
    FFetchingRecords: Boolean;
    /// <summary>
    ///   Instancia a class que mapea todas as class do tipo Entity
    /// </summary>
    FExplorer: IMappingExplorerStrategy;
    /// <summary>
    ///   Fábrica de comandos a serem executados
    /// </summary>
    FDMLCommandFactory: TDMLCommandFactoryAbstract;
    /// <summary>
    ///   Controle de paginação vindo do banco de dados
    /// </summary>
    FPageSize: Integer;
    procedure ExecuteOneToOne(AObject: TObject; AProperty: TRttiProperty;
      AAssociation: TAssociationMapping);
    procedure ExecuteOneToMany(AObject: TObject; AProperty: TRttiProperty;
      AAssociation: TAssociationMapping);
    function FindSQLInternal(const ASQL: String): TObjectList<TObject>;
    function SelectInternalWhere(const AWhere: string;
      const AOrderBy: string): string;
  public
    constructor Create(const AOwner: TObject; const AConnection: IDBConnection;
      const AClassType: TClass; const APageSize: Integer);
    destructor Destroy; override;
    /// <summary>
    ///   Procedures
    /// </summary>
    procedure InsertInternal(const AObject: TObject);
    procedure UpdateInternal(const AObject: TObject; const AModifiedFields: TDictionary<string, string>);
    procedure DeleteInternal(const AObject: TObject);
    procedure LoadLazy(const AOwner, AObject: TObject);
    procedure NextPacketList(const AObjectList: TObjectList<TObject>;
      const APageSize, APageNext: Integer); overload;
    procedure NextPacketList(const AObjectList: TObjectList<TObject>;
      const AWhere, AOrderBy: String; const APageSize, APageNext: Integer); overload;
    function NextPacketList: TObjectList<TObject>; overload;
    function NextPacketList(const APageSize, APageNext: Integer): TObjectList<TObject>; overload;
    function NextPacketList(const AWhere, AOrderBy: String;
      const APageSize, APageNext: Integer): TObjectList<TObject>; overload;
    /// <summary>
    ///   Functions
    /// </summary>
    function GetDMLCommand: string;
    function ExistSequence: Boolean;
    /// <summary>
    ///   DataSet
    /// </summary>
    function SelectInternalAll: IDBResultSet;
    function SelectInternalID(const AID: Variant): IDBResultSet;
    function SelectInternal(const ASQL: String): IDBResultSet;
    function NextPacket: IDBResultSet; overload;
    function NextPacket(const APageSize, APageNext: Integer): IDBResultSet; overload;
    function NextPacket(const AWhere, AOrderBy: String;
      const APageSize, APageNext: Integer): IDBResultSet; overload;
    /// <summary>
    ///   ObjectSet
    /// </summary>
    function Find: TObjectList<TObject>; overload;
    function Find(const AID: Variant): TObject; overload;
    function FindWhere(const AWhere: string; const AOrderBy: string): TObjectList<TObject>;
    function FindOne(const AWhere: string): TObject;
    ///
    property FetchingRecords: Boolean read FFetchingRecords write FFetchingRecords;
  end;

implementation

uses
  ormbr.objectset.bind,
  ormbr.objects.helper,
  ormbr.rtti.helper,
  ormbr.server.rest.session;

{ TRESTObjectManager<M> }

constructor TRESTObjectManager.Create(const AOwner: TObject; const AConnection: IDBConnection;
  const AClassType: TClass; const APageSize: Integer);
begin
  FOwner := AOwner;
  FPageSize := APageSize;
  if not (AOwner is TRESTObjectSetSession) then
    raise Exception
            .Create('O Object Manager não deve ser instânciada diretamente, use as classes TRESTObjectSetSession');
  FConnection := AConnection;
  FExplorer := TMappingExplorer.GetInstance;
  FObjectInternal := AClassType.Create;
  /// <summary>
  ///   Fabrica de comandos SQL
  /// </summary>
  FDMLCommandFactory := TDMLCommandFactory.Create(FObjectInternal,
                                                  AConnection,
                                                  AConnection.GetDriverName);
end;

destructor TRESTObjectManager.Destroy;
begin
  FExplorer := nil;
  FDMLCommandFactory.Free;
  FObjectInternal.Free;
  inherited;
end;

procedure TRESTObjectManager.DeleteInternal(const AObject: TObject);
begin
  FDMLCommandFactory.GeneratorDelete(AObject);
end;

function TRESTObjectManager.SelectInternalAll: IDBResultSet;
begin
  Result := FDMLCommandFactory.GeneratorSelectAll(FObjectInternal.ClassType, FPageSize);
end;

function TRESTObjectManager.SelectInternalID(const AID: Variant): IDBResultSet;
begin
  Result := FDMLCommandFactory.GeneratorSelectID(FObjectInternal.ClassType, AID);
end;

function TRESTObjectManager.SelectInternalWhere(const AWhere: string;
  const AOrderBy: string): string;
begin
  Result := FDMLCommandFactory
              .GeneratorSelectWhere(FObjectInternal.ClassType, AWhere, AOrderBy, FPageSize);
end;

procedure TRESTObjectManager.FillAssociation(const AObject: TObject);
var
  LAssociationList: TAssociationMappingList;
  LAssociation: TAssociationMapping;
begin
  /// <summary>
  ///   Se o driver selecionado for do tipo de banco NoSQL,
  ///   o atributo Association deve ser ignorado.
  /// </summary>
  if FConnection.GetDriverName = dnMongoDB then
    Exit;

  LAssociationList := FExplorer.GetMappingAssociation(AObject.ClassType);
  if LAssociationList = nil then
    Exit;

  for LAssociation in LAssociationList do
  begin
     if LAssociation.Lazy then
       Continue;

     if LAssociation.Multiplicity in [OneToOne, ManyToOne] then
        ExecuteOneToOne(AObject, LAssociation.PropertyRtti, LAssociation)
     else
     if LAssociation.Multiplicity in [OneToMany, ManyToMany] then
        ExecuteOneToMany(AObject, LAssociation.PropertyRtti, LAssociation);
  end;
end;

procedure TRESTObjectManager.FillAssociationLazy(const AOwner, AObject: TObject);
var
  LAssociationList: TAssociationMappingList;
  LAssociation: TAssociationMapping;
begin
  /// <summary>
  ///   Se o driver selecionado for do tipo de banco NoSQL,
  ///   o atributo Association deve ser ignorado.
  /// </summary>
  if FConnection.GetDriverName = dnMongoDB then
    Exit;

  LAssociationList := FExplorer.GetMappingAssociation(AOwner.ClassType);
  if LAssociationList = nil then
    Exit;

  for LAssociation in LAssociationList do
  begin
     if not LAssociation.Lazy then
       Continue;

     if Pos(LAssociation.ClassNameRef, AObject.ClassName) = 0 then
       Continue;

     if LAssociation.Multiplicity in [OneToOne, ManyToOne] then
        ExecuteOneToOne(AOwner, LAssociation.PropertyRtti, LAssociation)
     else
     if LAssociation.Multiplicity in [OneToMany, ManyToMany] then
        ExecuteOneToMany(AOwner, LAssociation.PropertyRtti, LAssociation);
  end;
end;

procedure TRESTObjectManager.ExecuteOneToOne(AObject: TObject; AProperty: TRttiProperty;
  AAssociation: TAssociationMapping);
var
  LResultSet: IDBResultSet;
  LObjectValue: TObject;
begin
  LResultSet := FDMLCommandFactory
                  .GeneratorSelectOneToOne(AObject,
                                           AProperty.PropertyType.AsInstance.MetaclassType,
                                           AAssociation);
  try
    while LResultSet.NotEof do
    begin
      LObjectValue := AProperty.GetNullableValue(AObject).AsObject;
      /// <summary>
      /// Preenche o objeto com os dados do ResultSet
      /// </summary>
      TBindObject.GetInstance.SetFieldToProperty(LResultSet, LObjectValue);
      /// <summary>
      /// Alimenta registros das associações existentes 1:1 ou 1:N
      /// </summary>
      FillAssociation(LObjectValue);
    end;
  finally
    LResultSet.Close;
  end;
end;

procedure TRESTObjectManager.ExecuteOneToMany(AObject: TObject;
  AProperty: TRttiProperty; AAssociation: TAssociationMapping);
var
  LPropertyType: TRttiType;
  LObjectCreate: TObject;
  LObjectList: TObject;
  LResultSet: IDBResultSet;
begin
  LPropertyType := AProperty.PropertyType;
  LPropertyType := AProperty.GetTypeValue(LPropertyType);
  LResultSet := FDMLCommandFactory
                  .GeneratorSelectOneToMany(AObject,
                                            LPropertyType.AsInstance.MetaclassType,
                                            AAssociation);
  try
    while LResultSet.NotEof do
    begin
      /// <summary>
      ///   Instancia o objeto do tipo definido na lista
      /// </summary>
      LObjectCreate := LPropertyType.AsInstance.MetaclassType.Create;
      LObjectCreate.MethodCall('Create', []);
      /// <summary>
      ///   Popula o objeto com os dados do ResultSet
      /// </summary>
      TBindObject
        .GetInstance
          .SetFieldToProperty(LResultSet, LObjectCreate);
      /// <summary>
      ///   Alimenta registros das associações existentes 1:1 ou 1:N
      /// </summary>
      FillAssociation(LObjectCreate);
      /// <summary>
      ///   Adiciona o objeto a lista
      /// </summary>
      LObjectList := AProperty.GetNullableValue(AObject).AsObject;
      if LObjectList <> nil then
        LObjectList.MethodCall('Add', [LObjectCreate]);
    end;
  finally
    LResultSet.Close;
  end;
end;

function TRESTObjectManager.ExistSequence: Boolean;
begin
  Result := FDMLCommandFactory.ExistSequence;
end;

function TRESTObjectManager.GetDMLCommand: string;
begin
  Result := FDMLCommandFactory.GetDMLCommand;
end;

function TRESTObjectManager.NextPacket: IDBResultSet;
begin
  Result := FDMLCommandFactory.GeneratorNextPacket;
  if Result.FetchingAll then
    FFetchingRecords := True;
end;

function TRESTObjectManager.NextPacket(const APageSize, APageNext: Integer): IDBResultSet;
begin
  Result := FDMLCommandFactory
              .GeneratorNextPacket(FObjectInternal.ClassType, APageSize, APageNext);
  if Result.FetchingAll then
    FFetchingRecords := True;
end;

function TRESTObjectManager.NextPacketList: TObjectList<TObject>;
var
 LResultSet: IDBResultSet;
 LObjectList: TObjectList<TObject>;
 LObject: TObject;
begin
  LObjectList := TObjectList<TObject>.Create;
  LObjectList.TrimExcess;
  LResultSet := NextPacket;
  try
    while LResultSet.NotEof do
    begin
      LObject := FObjectInternal.ClassType.Create;
      LObject.MethodCall('Create', []);
      LObjectList.Add(LObject);
      TBindObject
        .GetInstance
          .SetFieldToProperty(LResultSet, LObjectList.Last);
      /// <summary>
      ///   Alimenta registros das associações existentes 1:1 ou 1:N
      /// </summary>
      FillAssociation(LObjectList.Last);
    end;
    Result := LObjectList;
  finally
    LResultSet.Close;
  end;
end;

function TRESTObjectManager.NextPacket(const AWhere, AOrderBy: String;
  const APageSize, APageNext: Integer): IDBResultSet;
begin
  Result := FDMLCommandFactory
              .GeneratorNextPacket(FObjectInternal.ClassType,
                                   AWhere,
                                   AOrderBy,
                                   APageSize,
                                   APageNext);
  if Result.FetchingAll then
    FFetchingRecords := True;
end;

function TRESTObjectManager.NextPacketList(const AWhere, AOrderBy: String;
  const APageSize, APageNext: Integer): TObjectList<TObject>;
var
 LResultSet: IDBResultSet;
 LObjectList: TObjectList<TObject>;
 LObject: TObject;
begin
  LObjectList := TObjectList<TObject>.Create;
  LObjectList.TrimExcess;
  LResultSet := NextPacket(AWhere, AOrderBy, APageSize, APageNext);
  try
    while LResultSet.NotEof do
    begin
      LObject := FObjectInternal.ClassType.Create;
      LObject.MethodCall('Create', []);
      LObjectList.Add(LObject);
      TBindObject
        .GetInstance
          .SetFieldToProperty(LResultSet, LObjectList.Last);
      /// <summary>
      ///   Alimenta registros das associações existentes 1:1 ou 1:N
      /// </summary>
      FillAssociation(LObjectList.Last);
    end;
    Result := LObjectList;
  finally
    LResultSet.Close;
  end;
end;

procedure TRESTObjectManager.NextPacketList(const AObjectList: TObjectList<TObject>;
  const AWhere, AOrderBy: String; const APageSize, APageNext: Integer);
var
 LResultSet: IDBResultSet;
 LObject: TObject;
begin
  LResultSet := NextPacket(AWhere, AOrderBy, APageSize, APageNext);
  try
    while LResultSet.NotEof do
    begin
      LObject := FObjectInternal.ClassType.Create;
      LObject.MethodCall('Create', []);
      AObjectList.Add(LObject);
      TBindObject
        .GetInstance
          .SetFieldToProperty(LResultSet, AObjectList.Last);
      /// <summary>
      ///   Alimenta registros das associações existentes 1:1 ou 1:N
      /// </summary>
      FillAssociation(AObjectList.Last);
    end;
  finally
    LResultSet.Close;
  end;
end;

procedure TRESTObjectManager.NextPacketList(const AObjectList: TObjectList<TObject>;
  const APageSize, APageNext: Integer);
var
 LResultSet: IDBResultSet;
 LObject: TObject;
begin
  LResultSet := NextPacket(APageSize, APageNext);
  try
    while LResultSet.NotEof do
    begin
      LObject := FObjectInternal.ClassType.Create;
      LObject.MethodCall('Create', []);
      AObjectList.Add(LObject);
      TBindObject
        .GetInstance
          .SetFieldToProperty(LResultSet, AObjectList.Last);
      /// <summary>
      ///   Alimenta registros das associações existentes 1:1 ou 1:N
      /// </summary>
      FillAssociation(AObjectList.Last);
    end;
  finally
    LResultSet.Close;
  end;
end;

function TRESTObjectManager.NextPacketList(const APageSize, APageNext: Integer): TObjectList<TObject>;
var
  LResultSet: IDBResultSet;
  LObjectList: TObjectList<TObject>;
  LObject: TObject;
begin
  LObjectList := TObjectList<TObject>.Create;
  LObjectList.TrimExcess;
  LResultSet := NextPacket(APageSize, APageNext);
  try
    while LResultSet.NotEof do
    begin
      LObject := FObjectInternal.ClassType.Create;
      LObject.MethodCall('Create', []);
      LObjectList.Add(LObject);
      TBindObject
        .GetInstance
          .SetFieldToProperty(LResultSet, LObjectList.Last);
      /// <summary>
      ///   Alimenta registros das associações existentes 1:1 ou 1:N
      /// </summary>
      FillAssociation(LObjectList.Last);
    end;
    Result := LObjectList;
  finally
    LResultSet.Close;
  end;
end;

function TRESTObjectManager.SelectInternal(const ASQL: String): IDBResultSet;
begin
  Result := FDMLCommandFactory.GeneratorSelect(ASQL, FPageSize);
end;

procedure TRESTObjectManager.UpdateInternal(const AObject: TObject;
  const AModifiedFields: TDictionary<string, string>);
begin
  FDMLCommandFactory.GeneratorUpdate(AObject, AModifiedFields);
end;

procedure TRESTObjectManager.InsertInternal(const AObject: TObject);
begin
  FDMLCommandFactory.GeneratorInsert(AObject);
end;

procedure TRESTObjectManager.LoadLazy(const AOwner, AObject: TObject);
begin
  FillAssociationLazy(AOwner, AObject);
end;

function TRESTObjectManager.FindSQLInternal(const ASQL: String): TObjectList<TObject>;
var
 LResultSet: IDBResultSet;
 LObject: TObject;
begin
  Result := TObjectList<TObject>.Create;
  Result.TrimExcess;
  if ASQL = '' then
    LResultSet := SelectInternalAll
  else
    LResultSet := SelectInternal(ASQL);
  try
    while LResultSet.NotEof do
    begin
      LObject := FObjectInternal.ClassType.Create;
      LObject.MethodCall('Create', []);
      TBindObject
        .GetInstance
          .SetFieldToProperty(LResultSet, Result.Items[Result.Add(LObject)]);
      /// <summary>
      ///   Alimenta registros das associações existentes 1:1 ou 1:N
      /// </summary>
      FillAssociation(Result.Items[Result.Count -1]);
    end;
  finally
    LResultSet.Close;
  end;
end;

function TRESTObjectManager.Find: TObjectList<TObject>;
begin
  Result := FindSQLInternal('');
end;

function TRESTObjectManager.Find(const AID: Variant): TObject;
var
  LResultSet: IDBResultSet;
begin
  LResultSet := SelectInternalID(AID);
  try
    if LResultSet.RecordCount = 1 then
    begin
      Result := FObjectInternal.ClassType.Create;
      Result.MethodCall('Create', []);
      TBindObject
        .GetInstance
          .SetFieldToProperty(LResultSet, Result);
      /// <summary>
      ///   Alimenta registros das associações existentes 1:1 ou 1:N
      /// </summary>
      FillAssociation(Result);
    end
    else
      Result := nil;
  finally
    LResultSet.Close;
  end;
end;

function TRESTObjectManager.FindOne(const AWhere: string): TObject;
var
 LResultSet: IDBResultSet;
 LObject: TObject;
begin
  LResultSet := SelectInternal(SelectInternalWhere(AWhere, ''));
  try
    if LResultSet.RecordCount > 0 then
    begin
      LObject := FObjectInternal.ClassType.Create;
      LObject.MethodCall('Create', []);
      TBindObject
        .GetInstance
          .SetFieldToProperty(LResultSet, LObject);
      /// <summary>
      ///   Alimenta registros das associações existentes 1:1 ou 1:N
      /// </summary>
      FillAssociation(LObject);
      Result := LObject;
    end
    else
      Result := nil;
  finally
    LResultSet.Close;
  end;
end;

function TRESTObjectManager.FindWhere(const AWhere: string;
  const AOrderBy: string): TObjectList<TObject>;
begin
  Result := FindSQLInternal(SelectInternalWhere(AWhere, AOrderBy));
end;

end.

