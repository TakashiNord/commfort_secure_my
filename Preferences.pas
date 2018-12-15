unit Preferences;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, IniFiles;

type
  TFormPreferences = class(TForm)
    GroupBoxOptions: TGroupBox;
    Label1: TLabel;
    cbxCipher: TComboBox;
    Label2: TLabel;
    cbxHash: TComboBox;
    cbxLevel: TComboBox;
    Label3: TLabel;
    ePassphase: TEdit;
    btButGen: TButton;
    Label4: TLabel;
    cbPrivate: TCheckBox;
    Label5: TLabel;
    edtiniFile: TEdit;
    cbMain: TCheckBox;
    cbClose: TButton;
    procedure btButGenClick(Sender: TObject);
    procedure cbCloseClick(Sender: TObject);
    procedure cbMainClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormPreferences: TFormPreferences;

implementation

{$R *.dfm}

procedure TFormPreferences.btButGenClick(Sender: TObject);
// таблица символов, используемых в пароле
const StrTable: string =
'ABCDEFGHIJKLMabcdefghijklm' +
'0123456789' +
'NOPQRSTUVWXYZnopqrstuvwxyz' ; // + '!#$%&/()=?@<>|{[]}\*~+#;:.-_' ;
var
  N, K, X, Y: integer;
  PWlen : integer ;
  cPwd : string;
begin

PWlen:=35 ; // длина ключа
K := PWLen;
if (PWlen > Length(StrTable)) then K := Length(StrTable)-1 ;
SetLength(cPwd, K); // устанавливаем длину конечной строки
Y := Length(StrTable); // Длина Таблицы для внутреннего цикла
N := 0; // начальное значение цикла
while N < K do begin // цикл для создания K символов
   X := Random(Y) + 1; // берём следующий случайный символ
   // проверяем присутствие этого символа в конечной строке
   if (pos(StrTable[X], cPwd) = 0) then begin
     inc(N); // символ не найден
     cPwd[N] := StrTable[X]; // теперь его сохраняем
   end;
end;

 ePassphase.Text := Trim(cPwd) ; //  ключ

end;

procedure TFormPreferences.cbCloseClick(Sender: TObject);
var
  Ini: TInifile;
begin
  if ((cbMain.Checked=True) And (Trim(ePassphase.Text)='')) then begin
    ShowMessage('Set - passphase, it is Empty');
	Exit ;
  end ;
  Ini:=TIniFile.Create(edtiniFile.Text);
  Ini.WriteInteger('Options','Cipher',cbxCipher.ItemIndex);
  Ini.WriteInteger('Options','Hash',cbxHash.ItemIndex );
  Ini.WriteString('Options', 'Passphase', Trim(ePassphase.Text));
  Ini.WriteInteger('Options','cbPrivate',Integer(cbPrivate.Checked) );
  Ini.WriteInteger('Options','LevelZip', cbxLevel.ItemIndex );
  Ini.WriteInteger('Main','cbMain',Integer(cbMain.Checked));
  Ini.Free;

  Close;
end;

procedure TFormPreferences.cbMainClick(Sender: TObject);
begin
 GroupBoxOptions.Enabled:=cbMain.Checked ;
end;

procedure TFormPreferences.FormShow(Sender: TObject);
var
  Ini: TInifile;
  i : integer ;
  firstPass : string ;
begin
  if (Not FileExists(edtiniFile.Text)) then
        firstPass:='rHQmHVGYZHkLjhJn6nOqH4iIzoEPqonXEeN' ;

  Ini:=TIniFile.Create(edtiniFile.Text);
  cbxCipher.ItemIndex:=Ini.ReadInteger('Options','Cipher',0);
  cbxHash.ItemIndex:=Ini.ReadInteger('Options','Hash',2 );
  ePassphase.Text:=Ini.ReadString('Options', 'Passphase', firstPass);
  i:= Ini.ReadInteger('Options','cbPrivate', 1 );
  cbPrivate.Checked:= True;
  if (i=0) then cbPrivate.Checked:= False;
  cbxLevel.ItemIndex:= Ini.ReadInteger('Options','LevelZip', 0 );
  i:= Ini.ReadInteger('Main','cbMain',1);
  cbMain.Checked:= False ;
  if (i<>0) then cbMain.Checked:= True;
  Ini.Free;

  Randomize;
  //cbMain.Checked:=False ;
  cbMainClick(Sender);
end;

end.
