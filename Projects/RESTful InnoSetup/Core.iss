#define MyAppVersion "1.0"
#define MyAppPublisher "ORMBr"
#define MyAppURL "http://www.ormbr.com/"

[Setup]
PrivilegesRequired=admin
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName=C:\ORMBr\
SetupIconFile=D:\ORMBr\Projects\RESTful Install\ORMBrInstall_Icon.ico
Compression=lzma/max
SolidCompression=yes
AppCopyright=Copyright (C) 2018-2018 Isaque Pinhero, Inc.
AppContact=Isaque Pinheiro (isaquesp@gmail.com)
UserInfoPage = yes

[Languages]
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"

[Messages]
SelectDirBrowseLabel=Pra continuar, clique em Próximo. Informe a pasta que o ORMBr está instalado clicando em Procurar.
WizardUserInfo=Informação do Usuário
UserInfoDesc=Por favor insira suas informações.
UserInfoName=&E-Mail:
UserInfoOrg=&CNPJ (sem ponto):
UserInfoSerial=&Serial:
UserInfoNameRequired=Você deve inserir os dados solicitados.

[Code]
function ValidateEmail(strEmail: String): boolean;
var
  strTemp: String;
  nSpace: Integer;
  nAt: Integer;
  nDot: Integer;
begin
  strEmail := Trim(strEmail);
  nSpace := Pos(' ', strEmail);
  nAt := Pos('@', strEmail);
  strTemp := Copy(strEmail, nAt + 1, Length(strEmail) - nAt + 1);
  nDot := Pos('.', strTemp) + nAt;
  Result := ((nSpace = 0) and (1 < nAt) and (nAt + 1 < nDot) and (nDot < Length(strEmail)));
end;

function CheckSerial(Serial: String): Boolean;
begin
  Result := (Serial <> '') and (WizardForm.UserInfoOrgEdit.Text <> '') and (WizardForm.UserInfoNameEdit.Text <> '');
end;

function NextButtonClick(CurPageID: Integer): Boolean;
var
  WinHttpReq: Variant;
  Url: string;
begin
  Result := True;
  if CurPageID = wpUserInfo then
  begin
    if not ValidateEmail(WizardForm.UserInfoNameEdit.Text) then
    begin
      MsgBox('E-mail Inválido', mbError, MB_OK);
      Result := False;
      Exit;
    end
    else
    begin
      if WizardForm.UserInfoSerialEdit.Text = '0E0B8FA8-94B4-46FA-A0E2-FD2054AD8F59' then
      begin
        if (WizardForm.UserInfoNameEdit.Text <> 'antoniocmoura@gmail.com') or 
           (WizardForm.UserInfoOrgEdit.Text  <> '02583177958') then
        begin
          Result := False;
        end;
      end
      else
      if WizardForm.UserInfoSerialEdit.Text = 'DA1C5EB4-EB02-400F-A8F7-27689D8134F7' then
      begin
        if (WizardForm.UserInfoNameEdit.Text <> 'jesus@controlware.com.br') or 
           (WizardForm.UserInfoOrgEdit.Text  <> '12204805840') then
        begin
          Result := False;
        end;
      end
      else
      if WizardForm.UserInfoSerialEdit.Text = '53D7C169-50FC-4407-AE86-5ACDF06BD067' then
      begin
        if (WizardForm.UserInfoNameEdit.Text <> 'administrativo@genesistech.com.br') or 
           (WizardForm.UserInfoOrgEdit.Text  <> '12506781000170') then
        begin
          Result := False;
        end;
      end
      else
      if WizardForm.UserInfoSerialEdit.Text = 'BDE9291E-1A70-4BDD-9C3D-5D30E4E0DFDD' then
      begin
        if (WizardForm.UserInfoNameEdit.Text <> 'ma.pileggi@gmail.com') or 
           (WizardForm.UserInfoOrgEdit.Text  <> '11111169000135') then
        begin
          Result := False;
        end;
      end
      else
      if WizardForm.UserInfoSerialEdit.Text = '311CCE0C-291F-493E-85E6-80B7E75D646F' then
      begin
        if (WizardForm.UserInfoNameEdit.Text <> 'rui_zoomtec@hotmail.com') or 
           (WizardForm.UserInfoOrgEdit.Text  <> '97504204000157') then
        begin
          Result := False;
        end;
      end
      else
        Result := False;
    end;
    if not Result then
      MsgBox('Dados Inválidos. Favor redigitar!', mbError, MB_OK);
  end;
end;