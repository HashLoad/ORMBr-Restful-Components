{
      ORM Brasil � um ORM simples e descomplicado para quem utiliza Delphi

                   Copyright (c) 2016, Isaque Pinheiro
                          All rights reserved.
}

{
  @abstract(REST Componentes)
  @created(20 Jun 2018)
  @author(Isaque Pinheiro <isaquepsp@gmail.com>)
  @author(Skype : ispinheiro)
  @abstract(Website : http://www.ormbr.com.br)
  @abstract(Telagram : https://t.me/ormbr)
}

{$INCLUDE ..\..\ormbr.inc}

unit ormbr.session.rest;

interface

uses
  DB,
  Rtti,
  TypInfo,
  Classes,
  Variants,
  SysUtils,
  StrUtils,
  Generics.Collections,
  {$IFDEF DELPHI15_UP}
  JSON,
  {$ELSE}
  DBXJSON,
  {$ENDIF}
  /// orm
  ormbr.mapping.explorerstrategy,
  ormbr.dataset.base.adapter,
  ormbr.session.abstract,
  ormbr.factory.interfaces,
  ormbr.client.methods,
  ormbr.client.interfaces,
  ormbr.restdataset.adapter;

type
  /// <summary>
  ///   M - Sess�o RESTFull
  /// </summary>
  TSessionRest<M: class, constructor> = class(TSessionAbstract<M>)
  private
    FOwner: TRESTDataSetAdapter<M>;
    FConnection: IRESTConnection;
    FResource: String;
    FSubResource: String;
    FServerUse: Boolean;
    function NextPacketMethod: TObjectList<M>; overload;
    function NextPacketMethod(AWhere, AOrderBy: String): TObjectList<M>; overload;
    function ParseOperator(AParams: String): string;
  public
    constructor Create(const AConnection: IRESTConnection;
      const AOwner: TRESTDataSetAdapter<M>; const APageSize: Integer = -1); overload;
    destructor Destroy; override;
    procedure Insert(const AObject: M); overload; override;
    procedure Update(const AObjectList: TObjectList<M>); overload; override;
    procedure Delete(const AID: Integer); overload; override;
    procedure Delete(const AObject: M); overload; override;
    procedure RefreshRecord(const AColumns: TParams); override;
    procedure NextPacketList(const AObjectList: TObjectList<M>); overload; override;
    function NextPacketList: TObjectList<M>; overload; override;
    function Find: TObjectList<M>; overload; override;
    function Find(const AID: Integer): M; overload; override;
    function Find(const AID: String): M; overload; override;
    function FindWhere(const AWhere: string; const AOrderBy: string = ''): TObjectList<M>; override;
    function ExistSequence: Boolean; override;
    function Find(const AMethodName: String;
      const AParams: array of string): TObjectList<M>; overload; override;
  end;

implementation

uses
  ormbr.objects.helper,
  ormbr.rest.json,
  ormbr.mapping.classes,
  ormbr.mapping.explorer,
  ormbr.mapping.rttiutils,
  ormbr.mapping.attributes,
  ormbr.json.utils,
  ormbr.core.consts;

{ TSessionRest<M> }

constructor TSessionRest<M>.Create(const AConnection: IRESTConnection;
  const AOwner: TRESTDataSetAdapter<M>; const APageSize: Integer = -1);
var
  LObject: TObject;
  LTable: TCustomAttribute;
  LResource: TCustomAttribute;
  LSubResource: TCustomAttribute;
  LNotServerUse: TCustomAttribute;
begin
  inherited Create(APageSize);
  FOwner := AOwner;
  FConnection := AConnection;
  FPageSize := APageSize;
  FPageNext := 0;
  FFindWhereUsed := False;
  FFindWhereRefreshUsed := False;
  FResource := '';
  FSubResource := '';
  FServerUse := False;
  /// <summary>
  ///   Pega o nome do recurso e subresource definidos na classe
  /// </summary>
  LObject := TObject(M.Create);
  try
    if FConnection.ServerUse then
    begin
      /// <summary>
      ///   Valida se tem o atributo NotServerUse para n�o usar o server
      /// </summary>
      LNotServerUse := LObject.GetNotServerUse;
      if LNotServerUse <> nil then
      begin
        FServerUse := False;
        FConnection.SetClassNotServerUse(True);
      end
      else
      begin
        FServerUse := True;
        FConnection.SetClassNotServerUse(False);
      end;
      LTable := LObject.GetTable;
      if LTable <> nil then
        FResource := Table(LTable).Name;
    end
    else
    begin
      /// <summary>
      ///   Nome do Recurso
      /// </summary>
      LResource := LObject.GetResource;
      if LResource <> nil then
        FResource := Resource(LResource).Name;

      /// <summary>
      ///   Nome do SubRecurso
      /// </summary>
      LSubResource := LObject.GetSubResource;
      if LSubResource <> nil then
        FSubResource := Resource(LSubResource).Name;
    end;
  finally
    LObject.Free;
  end;
end;

destructor TSessionRest<M>.Destroy;
begin
  inherited;
end;

function TSessionRest<M>.ExistSequence: Boolean;
var
  LSequence: TSequenceMapping;
begin
  LSequence := TMappingExplorer
                 .GetInstance
                   .GetMappingSequence(TClass(M));
  if LSequence <> nil then
    Result := True
  else
    Result := False;
end;

procedure TSessionRest<M>.Delete(const AObject: M);
var
  LColumn: TColumnMapping;
  LPrimaryKey: TPrimaryKeyColumnsMapping;
//  LSubResource: String;
//  LURI: String;
//  LResult: String;
//  LResource: String;
//  LWhere: String;
begin
//  if not FServerUse then
//  begin
    LPrimaryKey := TMappingExplorer
                     .GetInstance
                       .GetMappingPrimaryKeyColumns(AObject.ClassType);
    if LPrimaryKey = nil then
      raise Exception.Create(cMESSAGEPKNOTFOUND);

    LColumn := LPrimaryKey.Columns.Items[0];
    Delete(LColumn.ColumnProperty.GetValue(TObject(AObject)).AsInteger);
//    Exit;
//  end;

  /// <summary> Executa de forma diferente unsado ORMBr Server </summary>
//  LWhere := '';
//  for LColumn in AObject.GetPrimaryKey do
//  begin
//    LWhere := LWhere + '(' + LColumn.ColumnName
//                     + '=' + VarToStr(LColumn.PropertyRtti.GetValue(TObject(AObject)).AsVariant) + ') AND ';
//  end;
//  LWhere := Copy(LWhere, 1, Length(LWhere) -5);
//
//  if FServerUse then
//    LResource := FResource;
//
//  LSubResource := ifThen(Length(FConnection.MethodDELETE) > 0, FConnection.MethodDELETE, FSubResource);
//  LResult := FConnection.Execute(LResource,
//                                 LSubResource,
//                                 rtDELETE,
//                                 procedure
//                                 begin
//                                   if not FServerUse then
//                                     FConnection.AddParam(LWhere)
//                                   else
//                                     FConnection.AddQueryParam('$filter=' + ParseOperator(LWhere));
//                                 end);
//  /// <summary> Mostra no monitor a URI completa </summary>
//  if FConnection.CommandMonitor <> nil then
//  begin
//    LURI := FConnection.BaseURL + '/' + LResource;
//    if Length(LSubResource) > 0 then
//      LURI := LURI + '/' + LSubResource;
//
//    FConnection.CommandMonitor.Command('URI    : ' + LURI + sLineBreak +
//                                       'Filtro : ' + LWhere + sLineBreak +
//                                       'M�todo : DELETE' + sLineBreak +
//                                       'Result : ' + LResult, nil);
//  end;
end;

procedure TSessionRest<M>.Delete(const AID: Integer);
var
  LSubResource: String;
  LURI: String;
  LResult: String;
  LResource: String;
begin
  LResource := FResource;
  if FServerUse then
    LResource := LResource + '(' + IntToStr(AID) + ')';
  LSubResource := ifThen(Length(FConnection.MethodDELETE) > 0, FConnection.MethodDELETE, FSubResource);
  LResult := FConnection.Execute(LResource,
                                 LSubResource,
                                 rtDELETE,
                                 procedure
                                 begin
                                   if not FServerUse then
                                     FConnection.AddParam(IntToStr(AID));
                                 end);
  /// <summary>
  ///   Mostra no monitor a URI completa
  /// </summary>
  if FConnection.CommandMonitor <> nil then
  begin
    LURI := FConnection.BaseURL + '/' + LResource;
    if Length(LSubResource) > 0 then
      LURI := LURI + '/' + LSubResource;

    FConnection.CommandMonitor.Command('URI    : ' + LURI + sLineBreak +
                                       'ID     : ' + IntToStr(AID) + sLineBreak +
                                       'M�todo : DELETE' + sLineBreak +
                                       'Result : ' + LResult, nil);
  end;
end;

function TSessionRest<M>.FindWhere(const AWhere, AOrderBy: string): TObjectList<M>;
var
  LSubResource: String;
  LJSON: string;
  LURI: String;
begin
  FFindWhereUsed := True;
  FFetchingRecords := False;
  FWhere := AWhere;
  FOrderBy := AOrderBy;
  /// <summary>
  ///   S� busca por pagina��o se n�o for um RefreshRecord
  /// </summary>
  if not FFindWhereRefreshUsed then
  begin
    if FPageSize > -1 then
    begin
      FPageNext := 0 - FPageSize;
      Result := NextPacketMethod(FWhere, FOrderBy);
      Exit;
    end;
  end;
  if not FServerUse then
    LSubResource := ifThen(Length(FConnection.MethodGETWhere) > 0, FConnection.MethodGETWhere, FSubResource)
  else
    LSubResource := '';

  LJSON := FConnection.Execute(FResource,
                               LSubResource,
                               rtGET,
                               procedure
                               begin
                                 if not FServerUse then
                                 begin
                                   FConnection.AddParam(FWhere);
                                   FConnection.AddParam(IfThen(FOrderBy = '', 'None', FOrderBy));
                                 end
                                 else
                                 begin
                                   FConnection.AddQueryParam('$filter=' + ParseOperator(FWhere));
                                   if Length(FOrderBy) > 0 then
                                     FConnection.AddQueryParam('$orderby=' + FOrderBy);
                                 end;
                               end);
  /// <summary>
  ///   Mostra no monitor a URI completa
  /// </summary>
  if FConnection.CommandMonitor <> nil then
  begin
    LURI := FConnection.BaseURL + '/' + FResource;
    if Length(FConnection.MethodGETWhere) > 0 then
      LURI := LURI + '/' + FConnection.MethodGETWhere;

    FConnection.CommandMonitor.Command('URI    : ' + LURI + sLineBreak +
                                       'Where  : ' + AWhere + sLineBreak +
                                       'OrderBy: ' + AOrderBy + sLineBreak +
                                       'M�todo : GET' + sLineBreak +
                                       'Json   : ' + LJSON, nil);
  end;
  /// <summary>
  ///   Caso o JSON retornado n�o seja um array, � tranformado em um.
  /// </summary>
  if LJSON[1] = '{' then
    LJSON := '[' + LJSON + ']';
  /// <summary>
  ///   Transforma o JSON recebido populando em uma lista de objetos
  /// </summary>
  Result := TORMBrJson.JsonToObjectList<M>(LJSON);
end;

function TSessionRest<M>.Find(const AID: Integer): M;
begin
  /// <summary>
  ///   Transforma o JSON recebido populando o objeto
  /// </summary>
  FFindWhereUsed := False;
  FFetchingRecords := False;
  Result := Find(IntToStr(AID));
end;

function TSessionRest<M>.Find(const AID: string): M;
var
  LResource: String;
  LSubResource: String;
  LJSON: String;
  LURI: String;
begin
  FFindWhereUsed := False;
  FFetchingRecords := False;
  LResource := FResource;
  if not FServerUse then
    LSubResource := FConnection.MethodGETId
  else
  begin
    LResource := LResource + '(' + AID + ')';
    LSubResource := '';
  end;
  LJSON := FConnection.Execute(LResource,
                               LSubResource,
                               rtGET,
                               procedure
                               begin
                                 if not FServerUse then
                                   FConnection.AddParam(AID)
                               end);
  /// <summary>
  ///   Mostra no monitor a URI completa
  /// </summary>
  if FConnection.CommandMonitor <> nil then
  begin
    LURI := FConnection.BaseURL + '/' + LResource;
    if Length(FConnection.MethodGETId) > 0 then
      LURI := LURI + '/' + FConnection.MethodGETId;

    FConnection.CommandMonitor.Command('URI    : ' + LURI + sLineBreak +
                                       'ID     : ' + AID  + sLineBreak +
                                       'M�todo : GET' + sLineBreak +
                                       'Json   : ' + LJSON, nil);
  end;
  /// <summary>
  ///   Transforma o JSON recebido populando o objeto
  /// </summary>
  Result := TORMBrJson.JsonToObject<M>(LJSON);
end;

function TSessionRest<M>.Find: TObjectList<M>;
var
  LJSON: string;
  LSubResource: String;
  LURI: String;
begin
  FFetchingRecords := False;
  FFindWhereUsed := False;
  if FPageSize > -1 then
  begin
    FPageNext := 0 - FPageSize;
    Result := NextPacketMethod;
    Exit;
  end;
  if not FServerUse then
    LSubResource := ifThen(Length(FConnection.MethodGET) > 0, FConnection.MethodGET, FSubResource)
  else
    LSubResource := '';

  LJSON := FConnection.Execute(FResource, LSubResource, rtGET);

  /// <summary>
  ///   Mostra no monitor a URI completa
  /// </summary>
  if FConnection.CommandMonitor <> nil then
  begin
    LURI := FConnection.BaseURL + '/' + FResource;
    if Length(LSubResource) > 0 then
      LURI := LURI + '/' + LSubResource;

    FConnection.CommandMonitor.Command('URI    : ' + LURI + sLineBreak +
                                       'M�todo : GET' + sLineBreak +
                                       'Json   : ' + LJSON, nil);
  end;
  /// <summary>
  ///   Caso o JSON retornado n�o seja um array, � tranformado em um.
  /// </summary>
  if LJSON[1] = '{' then
    LJSON := '[' + LJSON + ']';
  /// <summary>
  ///   Transforma o JSON recebido populando uma lista de objetos
  /// </summary>
  Result := TORMBrJson.JsonToObjectList<M>(LJSON);
end;

procedure TSessionRest<M>.Insert(const AObject: M);
var
  LJSON: String;
  LSubResource: String;
  LURI: String;
  LResult: String;
  LParamsObject: TJSONObject;
  LParamsArray: TJSONArray;
  LValuesObject: TJSONObject;
  LFor: Integer;
  LPar: Integer;
begin
  LSubResource := ifThen(Length(FConnection.MethodPOST) > 0, FConnection.MethodPOST, FSubResource);
  LJSON := TORMBrJson.ObjectToJsonString(AObject);
  LResult := FConnection.Execute(FResource,
                                 LSubResource,
                                 rtPOST,
                                 procedure
                                 begin
                                   FConnection.AddParam(LJSON);
                                 end);
  FResultParams.Clear;
  /// <summary>
  ///   Gera lista de params com o retorno, se existir o elemento "params" no JSON.
  /// </summary>
  LParamsObject := TORMBrJSONUtil.JSONStringToJSONObject(LResult);
  LParamsArray := LParamsObject.Values['params'] as TJSONArray;
  try
    if LParamsArray <> nil then
    begin
      for LFor := 0 to LParamsArray.Count -1 do
      begin
        LValuesObject := LParamsArray.Items[LFor] as TJSONObject;
        with FResultParams.Add as TParam do
        begin
          for LPar := 0 to LValuesObject.Count -1 do
          begin
            Name := LValuesObject.Pairs[LPar].JsonString.Value;
            DataType := ftString;
            Value := LValuesObject.Pairs[LPar].JsonValue.Value
          end;
        end;
      end;
    end;
  finally
    LParamsObject.Free;
  end;
  /// <summary>
  ///   Mostra no monitor a URI completa
  /// </summary>
  if FConnection.CommandMonitor <> nil then
  begin
    LURI := FConnection.BaseURL + '/' + FResource;
    if Length(LSubResource) > 0 then
      LURI := LURI + '/' + LSubResource;

    FConnection.CommandMonitor.Command('URI    : ' + LURI + sLineBreak +
                                       'M�todo : POST' + sLineBreak +
                                       'Result : ' + LResult + sLineBreak +
                                       'Json   : ' + LJSON, nil);
  end;
end;

function TSessionRest<M>.NextPacketList: TObjectList<M>;
begin
  inherited;
  if FFindWhereUsed then
    Result := NextPacketMethod(FWhere, FOrderBy)
  else
    Result := NextPacketMethod;

  if Result <> nil then
    if Result.Count = 0 then
      FFetchingRecords := True;
end;

procedure TSessionRest<M>.NextPacketList(const AObjectList: TObjectList<M>);
var
  LObjectList: TObjectList<M>;
  LFor: Integer;
  LObject: TObject;
begin
  if FFindWhereUsed then
    LObjectList := NextPacketMethod(FWhere, FOrderBy)
  else
    LObjectList := NextPacketMethod;

  if LObjectList <> nil then
  begin
    if LObjectList.Count = 0 then
      FFetchingRecords := True;
    try
      for LFor := 0 to LObjectList.Count -1 do
      begin
        LObject := TRttiSingleton.GetInstance.Clone(LObjectList.Items[LFor]);
        AObjectList.Add(LObject);
      end;
    finally
      LObjectList.Clear;
      LObjectList.Free;
    end;
  end;
end;

function TSessionRest<M>.NextPacketMethod(AWhere, AOrderBy: String): TObjectList<M>;
var
  LJSON: string;
  LSubResource: String;
  LURI: String;
begin
  if not FFindWhereRefreshUsed then
    FPageNext := FPageNext + FPageSize;

  if not FServerUse then
    LSubResource := ifThen(Length(FConnection.MethodGETNextPacketWhere) > 0, FConnection.MethodGETNextPacketWhere, FSubResource)
  else
    LSubResource := '';

  LJSON := FConnection.Execute(FResource,
                               LSubResource,
                               rtGET,
                               procedure
                               begin
                                 if not FServerUse then
                                 begin
                                   FConnection.AddParam(AWhere);
                                   FConnection.AddParam(IfThen(AOrderBy = '', 'None', AOrderBy));
                                   FConnection.AddParam(IntToStr(FPageSize));
                                   FConnection.AddParam(IntToStr(FPageNext));
                                 end
                                 else
                                 begin
                                   FConnection.AddQueryParam('$filter='  + ParseOperator(AWhere));
                                   FConnection.AddQueryParam('$orderby=' + AOrderBy);
                                   FConnection.AddQueryParam('$top='     + IntToStr(FPageSize));
                                   FConnection.AddQueryParam('$skip='    + IntToStr(FPageNext));
                                 end;
                               end);
  /// <summary>
  ///   Mostra no monitor a URI completa
  /// </summary>
  if FConnection.CommandMonitor <> nil then
  begin
    LURI := FConnection.BaseURL + '/' + FResource;
    if Length(LSubResource) > 0 then
      LURI := LURI + '/' + LSubResource;

    FConnection.CommandMonitor.Command('URI    : ' + LURI + sLineBreak +
                                       'M�todo : GET' + sLineBreak +
                                       'Json   : ' + LJSON, nil);
  end;
  /// <summary>
  ///   Transforma o JSON recebido populando o objeto
  /// </summary>
  Result := TORMBrJson.JsonToObjectList<M>(LJSON);
end;

function TSessionRest<M>.NextPacketMethod: TObjectList<M>;
var
  LJSON: string;
  LSubResource: String;
  LURI: String;
begin
  FPageNext := FPageNext + FPageSize;
  if not FServerUse then
    LSubResource := ifThen(Length(FConnection.MethodGETNextPacket) > 0, FConnection.MethodGETNextPacket, FSubResource)
  else
    LSubResource := '';

  LJSON := FConnection.Execute(FResource,
                               LSubResource,
                               rtGET,
                               procedure
                               begin
                                 if not FServerUse then
                                 begin
                                   FConnection.AddParam(IntToStr(FPageSize));
                                   FConnection.AddParam(IntToStr(FPageNext));
                                 end
                                 else
                                 begin
                                   FConnection.AddQueryParam('$top='  + IntToStr(FPageSize));
                                   FConnection.AddQueryParam('$skip=' + IntToStr(FPageNext));
                                 end;
                               end);
  /// <summary>
  ///   Mostra no monitor a URI completa
  /// </summary>
  if FConnection.CommandMonitor <> nil then
  begin
    LURI := FConnection.BaseURL + '/' + FResource;
    if Length(LSubResource) > 0 then
      LURI := LURI + '/' + LSubResource;

    FConnection.CommandMonitor.Command('URI    : ' + LURI + sLineBreak +
                                       'M�todo : GET' + sLineBreak +
                                       'Json   : ' + LJSON, nil);
  end;
  /// <summary>
  ///   Transforma o JSON recebido populando o objeto
  /// </summary>
  Result := TORMBrJson.JsonToObjectList<M>(LJSON);
end;

procedure TSessionRest<M>.Update(const AObjectList: TObjectList<M>);
var
  LJSON: String;
  LSubResource: String;
  LURI: String;
  LResult: String;
  LFor: Integer;
  LResource: String;
begin
  LJSON := '';
  try
    LSubResource := ifThen(Length(FConnection.MethodPUT) > 0, FConnection.MethodPUT, FSubResource);
    LResource := FResource;
    for LFor := 0 to AObjectList.Count -1 do
    begin
      LJSON := TORMBrJson.ObjectToJsonString(AObjectList.Items[LFor]);
      LResult := FConnection.Execute(LResource,
                                     LSubResource,
                                     rtPUT,
                                     procedure
                                     begin
                                       FConnection.AddParam(LJSON);
                                     end);
    end;
  finally
    /// <summary>
    ///   Mostra no monitor a URI completa
    /// </summary>
    if FConnection.CommandMonitor <> nil then
    begin
      LURI := FConnection.BaseURL + '/' + LResource;
      if Length(LSubResource) > 0 then
        LURI := LURI + '/' + LSubResource;

      FConnection.CommandMonitor.Command('URI    : ' + LURI + sLineBreak +
                                         'M�todo : PUT' + sLineBreak +
                                         'Result : ' + LResult + sLineBreak +
                                         'Json   : ' + LJSON, nil);
    end;
  end;
end;

procedure TSessionRest<M>.RefreshRecord(const AColumns: TParams);
var
  LObjectList: TObjectList<M>;
  LFindWhere: String;
  LWhereOld: String;
  LOrderByOld: String;
  LFor: Integer;
begin
  inherited;
  FFindWhereRefreshUsed := True;
  LWhereOld := FWhere;
  LOrderByOld := FOrderBy;
  try
    LFindWhere := '';
    for LFor := 0 to AColumns.Count -1 do
    begin
      LFindWhere := LFindWhere + AColumns[LFor].Name + '=' + AColumns[LFor].AsString;
      if LFor < AColumns.Count -1 then
        LFindWhere := LFindWhere + ' AND ';
    end;
    LObjectList := FindWhere(LFindWhere, '');
    if LObjectList <> nil then
    begin
      try
        FOwner.RefreshRecordInternal(LObjectList.First);
      finally
        LObjectList.Clear;
        LObjectList.Free;
      end;
    end;
  finally
    FWhere := LWhereOld;
    FOrderBy := LOrderByOld;
    FFindWhereRefreshUsed := False;
  end;
end;

function TSessionRest<M>.Find(const AMethodName: String;
  const AParams: array of string): TObjectList<M>;
var
  LJSONArray: TJSONArray;
  LFor: Integer;
  LJSON: string;
  LURI: String;
begin
  FFindWhereUsed := False;
  FFetchingRecords := False;
  LJSONArray := TJSONArray.Create;
  try
    try
      for LFor := Low(AParams) to High(AParams) do
        LJSONArray.Add(AParams[LFor]);

      LJSON := FConnection.Execute(FResource,
                                   AMethodName,
                                   rtGET,
                                   procedure
                                   begin
                                     FConnection.AddParam(LJSONArray.ToJSON);
                                   end);
    except
      on E: Exception do
      begin
        LJSONArray.Free;
        raise Exception.Create(E.Message);
      end;
    end;
    /// <summary>
    ///   Mostra no monitor a URI completa
    /// </summary>
    if FConnection.CommandMonitor <> nil then
    begin
      LURI := FConnection.BaseURL + '/' + FResource;
      if Length(AMethodName) > 0 then
        LURI := LURI + '/' + AMethodName;

      FConnection.CommandMonitor.Command('URI    : ' + LURI + sLineBreak +
                                         'M�todo : GET' + sLineBreak +
                                         'Json   : ' + LJSON, nil);
    end;
    /// <summary>
    ///   Transforma o JSON recebido populando o objeto
    /// </summary>
    Result := TORMBrJson.JsonToObjectList<M>(LJSON);
  finally
    LJSONArray.Free;
  end;
end;

function TSessionRest<M>.ParseOperator(AParams: String): string;
begin
  Result := AParams;
  Result := StringReplace(Result, ' = ' , ' eq ' , [rfReplaceAll]);
  Result := StringReplace(Result, ' <> ', ' ne ' , [rfReplaceAll]);
  Result := StringReplace(Result, ' > ' , ' gt ' , [rfReplaceAll]);
  Result := StringReplace(Result, ' >= ', ' ge ' , [rfReplaceAll]);
  Result := StringReplace(Result, ' < ' , ' lt ' , [rfReplaceAll]);
  Result := StringReplace(Result, ' <= ', ' le ' , [rfReplaceAll]);
  Result := StringReplace(Result, ' + ' , ' add ', [rfReplaceAll]);
  Result := StringReplace(Result, ' - ' , ' sub ', [rfReplaceAll]);
  Result := StringReplace(Result, ' * ' , ' mul ', [rfReplaceAll]);
  Result := StringReplace(Result, ' / ' , ' div ', [rfReplaceAll]);
end;

end.
