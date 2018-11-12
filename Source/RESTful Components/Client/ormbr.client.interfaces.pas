{
      ORM Brasil � um ORM simples e descomplicado para quem utiliza Delphi

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
}

unit ormbr.client.interfaces;

interface

uses
  SysUtils,
  ormbr.client.methods,
  ormbr.monitor;

type
  IRESTConnection = interface
    ['{A5974AAA-1B36-46F2-AF8D-51C4E69BC072}']
    function GetBaseURL: String;
    function GetUsername: String;
    function GetPassword: String;
    function GetMethodGET: String;
    function GetMethodGETId: String;
    function GetMethodGETWhere: String;
    function GetMethodPOST: String;
    function GetMethodPUT: String;
    function GetMethodDELETE: String;
    function GetMethodGETNextPacket: String;
    function GetMethodGETNextPacketWhere: String;
    function GetMethodToken: String;
    function GetServerUse: Boolean;
    ///
    procedure SetCommandMonitor(AMonitor: ICommandMonitor);
    procedure SetClassNotServerUse(const Value: Boolean);
    function CommandMonitor: ICommandMonitor;
    function Execute(const AResource, ASubResource: String;
      const ARequestMethod: TRESTRequestMethodType; const AParams: TProc = nil): String; overload;
    function Execute(const AResource: String; const ARequestMethod: TRESTRequestMethodType;
      const AParams: TProc = nil): String; overload;
    procedure AddParam(AValue: String);
    procedure AddQueryParam(AValue: String);
    property BaseURL: String read GetBaseURL;
    property Username: String read GetUsername;
    property Password: String read GetPassword;
    property MethodGET: String read GetMethodGET;
    property MethodGETId: String read GetMethodGETId;
    property MethodGETWhere: String read GetMethodGETWhere;
    property MethodPOST: String read GetMethodPOST;
    property MethodPUT: String read GetMethodPUT;
    property MethodDELETE: String read GetMethodDELETE;
    property MethodGETNextPacket: String read GetMethodGETNextPacket;
    property MethodGETNextPacketWhere: String read GetMethodGETNextPacketWhere;
    property MethodToken: String read GetMethodToken;
    property ServerUse: Boolean read GetServerUse;
  end;

implementation

end.
