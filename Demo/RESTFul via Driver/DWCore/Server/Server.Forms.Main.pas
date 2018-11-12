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
  uRESTDWBase,
  uDWAbout,
  uRESTDWServerEvents;

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
    procedure FormCreate(Sender: TObject);
    procedure ButtonStartClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ServerForm: TServerForm;

implementation

uses
  Server.Datamodule;

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
end;

end.
