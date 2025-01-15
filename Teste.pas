unit Teste;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, REST.Client, REST.Types, System.JSON, System.NetEncoding;

type
  TForm2 = class(TForm)
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure TestarRequisicao;
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

procedure TForm2.FormCreate(Sender: TObject);
begin
  TestarRequisicao
end;

procedure TForm2.TestarRequisicao;
var
  json: string;
  ArraySigner: TJSONArray;
  ObjDoc, ObjSigner: TJSONObject;
  RESTClient: TRESTClient;
  Req: TRESTRequest;
  FileStream: TFileStream;
  Base64Stream: TStringStream;
begin
  ObjDoc := TJSONObject.Create;
  try
    ObjDoc.AddPair('name', 'Contrato de teste');

    Base64Stream := TStringStream.Create;
    try
      FileStream := TFileStream.Create('D:\teste.pdf', fmOpenRead or fmShareDenyWrite);
      try
        TNetEncoding.Base64.Encode(FileStream, Base64Stream);
        ObjDoc.AddPair('base64_pdf', Base64Stream.DataString);
      finally
        FileStream.Free;
      end;
    finally
      Base64Stream.Free;
    end;

    ArraySigner := TJSONArray.Create;

    ObjSigner := TJSONObject.Create;
    ObjSigner.AddPair('name', 'Kaique Barato Luiz');
    ObjSigner.AddPair('email', 'kaique_luiz1@hotmail.com');
    ObjSigner.AddPair('phone_country', '55');
    ObjSigner.AddPair('phone_number', '44999249953');
    // Opcional caso queira impedir alteração
    ObjSigner.AddPair('lock_name', TJSONTrue.Create);
    ObjSigner.AddPair('lock_email', TJSONTrue.Create);
    ObjSigner.AddPair('lock_phone', TJSONTrue.Create);

    ArraySigner.AddElement(ObjSigner);

    ObjDoc.AddPair('signers', ArraySigner);
    json := ObjDoc.ToString;

    RESTClient := TRESTClient.Create(nil);
    try
      RESTClient.BaseURL := 'https://sandbox.api.zapsign.com.br/api/v1/docs/?api_token=..token..';
      Req := TRESTRequest.Create(nil);
      try
        Req.Client := RESTClient;
        Req.Method := rmPOST;
        Req.AddBody(json, ContentTypeFromString('application/json'));
        Req.Execute;
        ShowMessage(Req.Response.Content);
      finally
        Req.Free;
      end;
    finally
      RESTClient.Free;
    end;
  finally
    ObjDoc.Free;
  end;
end;

end.

