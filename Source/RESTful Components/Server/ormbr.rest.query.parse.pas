{
      ORM Brasil é um ORM simples e descomplicado para quem utiliza Delphi

                   Copyright (c) 2018, Isaque Pinheiro
                          All rights reserved.
}

{ 
  @abstract(REST Componentes)
  @created(20 Jun 2018)
  @author(Isaque Pinheiro <isaquepsp@gmail.com>)
  @author(Skype : ispinheiro)
  @abstract(Website : http://www.ormbr.com.br)
  @abstract(Telagram : https://t.me/ormbr)
  @abatract(oData : http://www.odata.org/getting-started/basic-tutorial/#queryData)
}

unit ormbr.rest.query.parse;

interface

uses
  Classes,
  SysUtils,
  StrUtils,
  Variants,
  Types,
  Generics.Collections;

type
  TRESTQuery = class
  private
    FPath: String;
    FQuery: String;
    FPathTokens: TArray<string>;
    FQueryTokens: TDictionary<string, string>;
    FResourceName: String;
    FID: Variant;
    function GetSelect: String;
    function GetFilter: String;
    function GetExpand: String;
    function GetSearch: String;
    function GetOrderBy: String;
    function GetSkip: Integer;
    function GetTop: Integer;
    function GetCount: Boolean;
    function GetResourceName: String;
    function ParseOperator(AParams: String): string;
    function ParseOperatorReverse(AParams: String): string;
    function ParsePathTokens(const APath: string): TArray<string>;
    function SplitString(const AValue, ADelimiters: string): TStringDynArray;
    procedure ParseClassNameAndID(const AValue: String);
    procedure ParseQueryTokens;
  protected
    const cPATH_SEPARATOR = '/';
    const cQUERY_SEPARATOR = '&';
    const cQUERY_INITIAL = '?';
  public
    constructor Create;
    destructor Destroy; override;
    procedure ParseQuery(const AURI: String);

    procedure SetSelect(Value: String);
    procedure SetExpand(Value: String);
    procedure SetFilter(Value: String);
    procedure SetSearch(Value: String);
    procedure SetOrderBy(Value: String);
    procedure SetSkip(Value: Variant);
    procedure SetTop(Value: Variant);
    procedure SetCount(Value: Variant);

    property Path: String read FPath;
    property Query: String read FQuery;
    property ResourceName: String read GetResourceName;
    property ID: Variant read FID;
    property Select: String read GetSelect;
    property Expand: String read GetExpand;
    property Filter: String read GetFilter;
    property Search: String read GetSearch;
    property OrderBy: String read GetOrderBy;
    property Skip: Integer read GetSkip;
    property Top: Integer read GetTop;
    property Count: Boolean read GetCount;
  end;

implementation

{ TRESTQuery }

constructor TRESTQuery.Create;
begin
  FQueryTokens := TDictionary<string, string>.Create;
  FResourceName := '';
  FID := Null;
end;

destructor TRESTQuery.Destroy;
begin
  FQueryTokens.Clear;
  FQueryTokens.Free;
  inherited;
end;

procedure TRESTQuery.SetExpand(Value: String);
begin
  if Value <> '' then
  begin
    if FQueryTokens.ContainsKey('$expand') then
      FQueryTokens.Items['$expand'] := Value
    else
      FQueryTokens.Add('$expand', Value);
  end;
end;

function TRESTQuery.GetCount: Boolean;
begin
  if FQueryTokens.ContainsKey('$count') then
    Result := FQueryTokens.Items['$count'] = 'True'
  else
    Result := False;
end;

function TRESTQuery.GetExpand: String;
begin
  if FQueryTokens.ContainsKey('$expand') then
    Result := FQueryTokens.Items['$expand']
  else
    Result := '';
end;

function TRESTQuery.GetFilter: String;
begin
  if FQueryTokens.ContainsKey('$filter') then
    Result := FQueryTokens.Items['$filter']
  else
    Result := '';
end;

function TRESTQuery.GetOrderBy: String;
begin
  if FQueryTokens.ContainsKey('$orderby') then
    Result := FQueryTokens.Items['$orderby']
  else
    Result := '';
end;

function TRESTQuery.GetResourceName: String;
begin
  Result := 'T' + FResourceName;
end;

function TRESTQuery.GetSearch: String;
begin
  if FQueryTokens.ContainsKey('$search') then
    Result := FQueryTokens.Items['$search']
  else
    Result := '';
end;

function TRESTQuery.GetSelect: String;
begin
  if FQueryTokens.ContainsKey('$select') then
    Result := FQueryTokens.Items['$select']
  else
    Result := '';
end;

function TRESTQuery.GetSkip: Integer;
begin
  if FQueryTokens.ContainsKey('$skip') then
    Result := StrToIntDef(FQueryTokens.Items['$skip'], 0)
  else
    Result := 0;
end;

function TRESTQuery.GetTop: Integer;
begin
  if FQueryTokens.ContainsKey('$top') then
    Result := StrToIntDef(FQueryTokens.Items['$top'], 0)
  else
    Result := 0;
end;

procedure TRESTQuery.ParseQuery(const AURI: String);
var
  LPos: Integer;
  LParams: String;
begin
  ParseClassNameAndID(AURI);

  FPath := AURI;
  LPos := Pos(cQUERY_INITIAL, FPath);
  if LPos > 0 then
  begin
    LParams := Copy(FPath, LPos +1, MaxInt);
    ///
    FPathTokens := ParsePathTokens(FPath);
//    LPos := Pos(cQUERY_INITIAL, FPathTokens[High(FPathTokens)]);
//    if LPos > 0 then
//      FResourceName := Copy(FPathTokens[High(FPathTokens)], 1, LPos -1);
    FQuery := ParseOperator(LParams);
    /// <summary> Dicionário </summary>
    ParseQueryTokens;
  end;
end;

procedure TRESTQuery.ParseClassNameAndID(const AValue: String);
var
  LChar: Char;
  LFor: Integer;
  LCommand: String;
  LLength: Integer;
begin
  LCommand := '';
  LLength := Length(AValue);
  LFor := 0;
  repeat
    Inc(LFor);
    LChar := Char(AValue[LFor]);
    case LChar of
      #0: Continue;
      '(':
        begin
          FResourceName := LCommand;
          /// <summary> Command Next </summary>
          if LFor +1 <= LLength then
            ParseClassNameAndID(Copy(AValue, LFor +1, LLength));
          Break;
        end;
      ')':
        begin
          FID := LCommand;
          /// <summary> Command Next </summary>
          if LFor +1 <= LLength then
            ParseClassNameAndID(Copy(AValue, LFor +1, LLength));
          Break;
        end;
      '?','$':
        begin
          Break;
        end;
    else
      LCommand := LCommand + LChar;
    end;
  until (LFor >= LLength );
  if Length(FResourceName) = 0 then
    FResourceName := LCommand;
end;

function TRESTQuery.ParseOperator(AParams: String): string;
begin
  Result := AParams;
  Result := StringReplace(Result, ' eq ' , ' = ' , [rfReplaceAll]);
  Result := StringReplace(Result, ' ne ' , ' <> ', [rfReplaceAll]);
  Result := StringReplace(Result, ' gt ' , ' > ' , [rfReplaceAll]);
  Result := StringReplace(Result, ' ge ' , ' >= ', [rfReplaceAll]);
  Result := StringReplace(Result, ' lt ' , ' < ' , [rfReplaceAll]);
  Result := StringReplace(Result, ' le ' , ' <= ', [rfReplaceAll]);
  Result := StringReplace(Result, ' add ', ' + ' , [rfReplaceAll]);
  Result := StringReplace(Result, ' sub ', ' - ' , [rfReplaceAll]);
  Result := StringReplace(Result, ' mul ', ' * ' , [rfReplaceAll]);
  Result := StringReplace(Result, ' div ', ' / ' , [rfReplaceAll]);
end;

function TRESTQuery.ParseOperatorReverse(AParams: String): string;
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

function TRESTQuery.ParsePathTokens(const APath: string): TArray<string>;
var
  LPath: string;
begin
  LPath := APath;
  Result := TArray<string>(SplitString(LPath, cPATH_SEPARATOR));

  while (Length(Result) > 0) and (Result[0] = '') do
    Result := Copy(Result, 1);
  while (Length(Result) > 0) and (Result[High(Result)] = '') do
    SetLength(Result, High(Result));
end;

procedure TRESTQuery.ParseQueryTokens;
var
  LQuery: string;
  LStrings: TStringList;
  LIndex: Integer;
begin
  FQueryTokens.Clear;
  FQueryTokens.TrimExcess;
  if FQuery <> '' then
  begin
    LQuery := FQuery;
    while StartsStr(LQuery, cQUERY_INITIAL) do
      LQuery := RightStr(LQuery, Length(LQuery) - 1);

    LStrings := TStringList.Create;
    try
      LStrings.Delimiter := cQUERY_SEPARATOR;
      LStrings.StrictDelimiter := True;
      LStrings.DelimitedText := LQuery;
      for LIndex := 0 to LStrings.Count - 1 do
        FQueryTokens.Add(LStrings.Names[LIndex], LStrings.ValueFromIndex[LIndex]);
    finally
      LStrings.Free;
    end;
  end;
end;

procedure TRESTQuery.SetCount(Value: Variant);
begin
  if Value <> '' then
  begin
    if FQueryTokens.ContainsKey('$count') then
      FQueryTokens.Items['$count'] := VarToStr(Value)
    else
      FQueryTokens.Add('$count', VarToStr(Value));
  end;
end;

procedure TRESTQuery.SetFilter(Value: String);
begin
  if Value <> '' then
  begin
    if FQueryTokens.ContainsKey('$filter') then
      FQueryTokens.Items['$filter'] := ParseOperator(Value)
    else
      FQueryTokens.Add('$filter', ParseOperator(Value));
  end;
end;

procedure TRESTQuery.SetTop(Value: Variant);
begin
  if Value <> '' then
  begin
    if FQueryTokens.ContainsKey('$top') then
      FQueryTokens.Items['$top'] := VarToStr(Value)
    else
      FQueryTokens.Add('$top', VarToStr(Value));
  end;
end;

procedure TRESTQuery.SetSearch(Value: String);
begin
  if Value <> '' then
  begin
    if FQueryTokens.ContainsKey('$search') then
      FQueryTokens.Items['$search'] := Value
    else
      FQueryTokens.Add('$search', Value);
  end;
end;

procedure TRESTQuery.SetSelect(Value: String);
begin
  if Value <> '' then
  begin
    if FQueryTokens.ContainsKey('$select') then
      FQueryTokens.Items['$select'] := Value
    else
      FQueryTokens.Add('$select', Value);
  end;
end;

procedure TRESTQuery.SetSkip(Value: Variant);
begin
  if Value <> '' then
  begin
    if FQueryTokens.ContainsKey('$skip') then
      FQueryTokens.Items['$skip'] := VarToStr(Value)
    else
      FQueryTokens.Add('$skip', VarToStr(Value));
  end;
end;

procedure TRESTQuery.SetOrderBy(Value: String);
begin
  if Value <> '' then
  begin
    if FQueryTokens.ContainsKey('$orderby') then
      FQueryTokens.Items['$orderby'] := Value
    else
      FQueryTokens.Add('$orderby', Value);
  end;
end;

function TRESTQuery.SplitString(const AValue, ADelimiters: string): TStringDynArray;
var
  LStartIdx: Integer;
  LFoundIdx: Integer;
  LSplitPoints: Integer;
  LCurrentSplit: Integer;
  LFor: Integer;
begin
  Result := nil;

  if AValue <> '' then
  begin
    LSplitPoints := 0;
    for LFor := 1 to AValue.Length do
      if IsDelimiter(ADelimiters, AValue, LFor) then
        Inc(LSplitPoints);

    SetLength(Result, LSplitPoints +1);

    LStartIdx := 1;
    LCurrentSplit := 0;
    repeat
      LFoundIdx := FindDelimiter(ADelimiters, AValue, LStartIdx);
      if LFoundIdx <> 0 then
      begin
        Result[LCurrentSplit] := Copy(AValue, LStartIdx, LFoundIdx - LStartIdx);
        Inc(LCurrentSplit);
        LStartIdx := LFoundIdx +1;
      end;
    until LCurrentSplit = LSplitPoints;

    Result[LSplitPoints] := Copy(AValue, LStartIdx, AValue.Length - LStartIdx +1);
  end;
end;

end.
