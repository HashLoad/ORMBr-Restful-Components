unit Server.Forms.Main;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls,
  ExtCtrls,
  Vcl.Imaging.pngimage,

  ormbr.factory.interfaces,
  ormbr.factory.firedac,
//  ormbr.server.dw,

  uRESTDWBase,
  uDWAbout,
  uRESTDWServerEvents, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs, FireDAC.VCLUI.Wait,
  FireDAC.Comp.UI, Data.DB, FireDAC.Comp.Client;

type
  TServerForm = class(TForm)
    RESTServicePooler1: TRESTServicePooler;
    lbLocalFiles: TListBox;
    Image1: TImage;
    cbEncode: TCheckBox;
    edPasswordDW: TEdit;
    Label3: TLabel;
    Bevel1: TBevel;
    Label7: TLabel;
    edUserNameDW: TEdit;
    Label2: TLabel;
    edPortaDW: TEdit;
    Label4: TLabel;
    ButtonStart: TButton;
    Label13: TLabel;
    Bevel2: TBevel;
    cbPoolerState: TCheckBox;
    FDConnection1: TFDConnection;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink;
    procedure FormCreate(Sender: TObject);
    procedure ButtonStartClick(Sender: TObject);
  private
    { Private declarations }
//    RESTServerDW: TRESTServerDW;
//    FConnection: IDBConnection;
  public
    { Public declarations }
  end;

var
  ServerForm: TServerForm;

implementation

uses
  Server.DataModule;

{$R *.dfm}

procedure TServerForm.ButtonStartClick(Sender: TObject);
begin
  if not RESTServicePooler1.Active Then
  begin
    RESTServicePooler1.ServerParams.HasAuthentication := True;
    RESTServicePooler1.ServerParams.UserName := edUserNameDW.Text;
    RESTServicePooler1.ServerParams.Password := edPasswordDW.Text;
    RESTServicePooler1.ServicePort := StrToIntDef(edPortaDW.Text, 211);
    RESTServicePooler1.Active := True;
    if not RESTServicePooler1.Active Then
      Exit;
    ButtonStart.Caption := 'Desativar';
  end
  else
  begin
    RESTServicePooler1.Active := False;
    ButtonStart.Caption := 'Ativar';
    lbLocalFiles.Clear;
  end;
end;

procedure TServerForm.FormCreate(Sender: TObject);
begin
  RESTServicePooler1.ServerMethodClass := TServerDataModule;

//  FConnection := TFactoryFireDAC.Create(FDConnection1, dnSQLite);

//  RESTServerDW := TRESTServerDW.Create(Self);
//  RESTServerDW.RESTServicePooler := RESTServicePooler1;
//  RESTServerDW.Connection := FConnection;
end;

end.
