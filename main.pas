unit main;

interface

uses Windows, Classes, SysUtils, Dialogs ,
     Buttons, Graphics, Controls,
     CommCtrl, ComCtrls, StdCtrls,
     messages, Types,
     Clipbrd,
     DCPcrypt2,
     DCPhaval, DCPmd5 ,DCPsha512,
     DCPrc4 , DCPblowfish, DCPrijndael,
     IniFiles,
     Preferences,
     utilstream ;

type
  TCommFortProcess = procedure(dwPluginID : DWORD; dwID: DWORD; bOutBuffer : PAnsiChar; dwOutBufferSize : DWORD); stdcall;
  TCommFortGetData = function(dwPluginID : DWORD; dwID : DWORD; bInBuffer : PAnsiChar; dwInBufferSize : DWORD; bOutBuffer : PAnsiChar; dwOutBufferSize : DWORD): DWORD; stdcall;

  TSetLayeredWindowAttributes = function(hWnd : HWND; crKey : DWORD; bAlpha : Byte; dwFlags : DWORD) : BOOL; stdcall;

  TMyTrackBar = class(TTrackBar)
  published
    procedure CreateParams(var Params: TCreateParams); override;
   private
    class procedure MyOnMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
	end;

function  PluginStart(dwThisPluginID : DWORD; func1 : TCommFortProcess; func2 : TCommFortGetData) : Integer; cdecl; stdcall;
procedure PluginStop(); cdecl; stdcall;
procedure PluginShowOptions(); cdecl; stdcall;
procedure PluginShowAbout(); cdecl; stdcall;
procedure PluginProcess(dwID : DWORD; bInBuffer : PAnsiChar; dwInBufferSize : DWORD); cdecl; stdcall;
function  PluginGetData(dwID : DWORD; bInBuffer : PAnsiChar;
            dwInBufferSize : DWORD; bOutBuffer : PAnsiChar; dwOutBufferSize : DWORD): DWORD; cdecl; stdcall;
function  PluginPremoderation(dwID : DWORD; wText : PWideChar; var dwTextLength : DWORD):  Integer; cdecl; stdcall;

function  fReadInteger(bInBuffer : PAnsiChar; var iOffset : Integer): Integer;
function  fReadText(bInBuffer : PAnsiChar; var iOffset : Integer): WideString;
procedure fWriteInteger(var bOutBuffer : PAnsiChar; var iOffset  : Integer; iValue : Integer);
procedure fWriteText(bOutBuffer : PAnsiChar; var iOffset  : Integer; uValue : WideString);
function  fTextToAnsiString(uText : WideString) : AnsiString;
function  fIntegerToAnsiString(iValue : Integer) : AnsiString;

exports PluginStart, PluginStop, PluginProcess, PluginGetData, PluginShowOptions, PluginShowAbout, PluginPremoderation;

var
  dwPluginID : DWORD;
  CommFortProcess : TCommFortProcess;
  CommFortGetData : TCommFortGetData;

  MyTrackbar : TMyTrackbar;

  myIniPath  : AnsiString; // ini-file
  myMain  : Integer ; // 1 - on \ 0- off
  myPrivate : Integer ; // 1 - only private
  myCipher : Integer ; // methods Cipher
  myHash : Integer ; // methods hash
  myPassphase : AnsiString ; //  Passphase
  myLevelZip : Integer ; // ratio fo zip

  hIDLL : Cardinal ; // HINSTANCE ;
  hHook1 : HHOOK ; // HHOOK ;
  ChatWindow : HWND; //Главное окно чата
  ChannelEdit : HWND;

implementation

//---------------------------------------------------------------------------
function fReadInteger(bInBuffer : PAnsiChar; var iOffset : Integer): Integer; //вспомогательная функция для упрощения работы с чтением данных
begin
	CopyMemory(@Result, bInBuffer + iOffSet, 4);
	iOffset := iOffset + 4;
end;

function fReadText(bInBuffer : PAnsiChar; var iOffset : Integer): WideString; //вспомогательная функция для упрощения работы с чтением данных
 var iLength : Integer;
begin
	CopyMemory(@iLength, bInBuffer + iOffSet, 4);
	iOffset := iOffset + 4;
	SetLength(Result, iLength);
	CopyMemory(@Result[1], bInBuffer + iOffSet, iLength * 2);
	iOffset := iOffset + iLength * 2;
end;

//---------------------------------------------------------------------------
procedure fWriteInteger(var bOutBuffer : PAnsiChar; var iOffset  : Integer; iValue : Integer); //вспомогательная функция для упрощения работы с записью данных
begin
	CopyMemory(bOutBuffer + iOffSet, @iValue, 4);
	iOffset := iOffset + 4;
end;
//---------------------------------------------------------------------------
procedure fWriteText(bOutBuffer : PAnsiChar; var iOffset  : Integer; uValue : WideString); //вспомогательная функция для упрощения работы с записью данных
	var iLength : Integer;
begin
	iLength := Length(uValue);
	CopyMemory(bOutBuffer + iOffset, @iLength, 4);
	iOffset := iOffset + 4;

	CopyMemory(bOutBuffer + iOffSet, @uValue[1], iLength * 2);
	iOffset := iOffset + iLength * 2;
end;

//---------------------------------------------------------------------------
function fTextToAnsiString(uText : WideString) : AnsiString; //вспомогательная функция для упрощения работы с данными
	var iLength : Integer;
begin
	//функция предназначена для ознакомительных целей,
	//не рекомендуется для реального применения,
	//так как при ее использовании проявляется избыточное копирование данных
	iLength := Length(uText);

	SetLength(Result, 4 + iLength * 2);

	CopyMemory(@Result[1], @iLength, 4);
	CopyMemory(PAnsiChar(Result) + 4, @uText[1], iLength * 2);
end;
//---------------------------------------------------------------------------
function fIntegerToAnsiString(iValue : Integer) : AnsiString; //вспомогательная функция для упрощения работы с данными
begin
	//функция предназначена для ознакомительных целей,
	//не рекомендуется для реального применения,
	//так как при ее использовании проявляется избыточное копирование данных

	SetLength(Result, 4);
	CopyMemory(@Result[1], @iValue, 4);
end;
//---------------------------------------------------------------------------


{ процедура инициализирует переменные при первом запуске }
procedure DCfIniRead( );
var
  Ini: Tinifile; //необходимо создать объект, чтоб потом с ним работать
  firstPass : string ;
begin
  if (Not FileExists(myIniPath)) then
        firstPass:='rHQmHVGYZHkLjhJn6nOqH4iIzoEPqonXEeN' ;

  Ini:=TIniFile.Create(myIniPath);
  myCipher:=Ini.ReadInteger('Options','Cipher',0);
  myHash:=Ini.ReadInteger('Options','Hash',2 );
  myPassphase:=Ini.ReadString('Options', 'Passphase', firstPass);
  myPrivate:= Ini.ReadInteger('Options','cbPrivate', 1 );
  myLevelZip:= Ini.ReadInteger('Options','LevelZip', 0 );
  myMain:= Ini.ReadInteger('Main','cbMain',1);
  Ini.Free;
end ;

function DCfBase( InputString: UnicodeString; encryption:Boolean ):UnicodeString;
var
  smsg   : String ;
  str    : UnicodeString ;
  KeyStr : string;
  Cipher : TDCP_cipher;   // the cipher to use
  Level  : Integer;  //Compress level
begin
 Result := InputString;
 KeyStr:= myPassphase;

try
// initialize the cipher
// 0 - rc4,  1 - Blowfish,  2 - Rijndael
 case myCipher of
  0: Cipher:= TDCP_rc4.Create(nil); 
  1: Cipher:= TDCP_blowfish.Create(nil); 
  2: Cipher:= TDCP_rijndael.Create(nil);
 end ; 

// initialize the cipher with a hash of the passphrase
// 0 - Haval (5 pass, 256 bit),  1 - Md5, 2 - SHA-512
 case myHash of
  0: Cipher.InitStr(KeyStr,TDCP_haval);
  1: Cipher.InitStr(KeyStr,TDCP_md5);
  2: Cipher.InitStr(KeyStr,TDCP_sha512);
  end ;

    //----Enc is true encrypt the text
    if encryption = true then begin
	   Level := myLevelZip;
	   str := CompressString(InputString, TCompLevel(Level));
	   Result := Cipher.EncryptString(str) ;
	   end
	   else begin
	     str := Cipher.DecryptString(InputString);
	     Result := DeCompressString(str);
       if Result='' then begin
          Result := '[b]' + ' Text no crypt OR unknow methods: ' + '[/b]' + InputString ;
       end ;
	   end ;

	Cipher.Burn;   // important! get rid of keying information
	Cipher.Free;
//  finally
  except
    smsg := 'Ошибка при обработке Текста..!' + #13#10 +
     '  - Приходящие Сообщение либо не криптовано (Ваш собеседник посылает открытый текст).' +
	 #13#10 + '  - Либо Посылаемое Сообщение не криптуется.' ;
   // MessageDlg(smsg,mtError,[mbOK],0);
end;

end ;

{ Основная процедура}
procedure DCf( iMessageMode : integer );
var
    s , sc : UnicodeString ; // UnicodeString  WideString
    H: THandle;
    TWPtr: PWideChar;
    id : integer ;
    iReadOffset, iSenderIcon : Integer;
    aData : AnsiString;
    uSenderLogin, uSenderIP, uChannel, uText : WideString;
    iSize : Integer ;
    buff: array[0..255] of char; // Буфер
    NameClass: string;           // Класс окна
begin
  if (myMain=0) then Exit ; // крипт выкл для всех

 // получаем хендл текущего окна
  ChannelEdit := GetFocus() ;
  GetClassName( ChannelEdit, buff, SizeOf( buff ) );
  NameClass := StrPas( buff );
  if ( 0<>StrComp(PWideChar(NameClass), PWideChar('TRichViewEdit')) ) then Exit ;
  
  // Получаем Handle родительского окна 
  if ( ChatWindow <> GetParent( ChannelEdit ) ) then Exit ;
  
  // name canal - получаем название текущего канала
  iSize := CommFortGetData(dwPluginID, 14, nil, 0, nil, 0); //получаем объем буфера
  SetLength(aData, iSize);
  CommFortGetData(dwPluginID, 14, PAnsiChar(aData), iSize, nil, 0);//заполняем буфер

  iReadOffset := 0; 
  //Получаем данные о событии
  uChannel := fReadText(PAnsiChar(aData), iReadOffset);//канал, в который было отправлено сообщение
  
  id := 50 ; // public
  if (uChannel[1]='&') then begin
    id := 63 ; // private
    Delete(uChannel, 1, 1);
  end ;
 
  if ((myPrivate=1) And (id=50)) then Exit ;
  
  // Select all text in the RichEdit
  SendMessage(ChannelEdit, EM_SETSEL, 0, -1);
  // Copy to Clipboard
  SendMessage(ChannelEdit, WM_COPY, 0, 0);  // WM_COPY   WM_CUT   EM_GETTEXTRANGE

 if Clipboard.HasFormat(CF_BITMAP) then begin
  // Clear the Selection
  SendMessage(ChannelEdit, EM_SETSEL, -1, 0);
  Clipboard.clear ;
  Exit ;
 end;

  // WM_CLEAR
  SendMessage(ChannelEdit, WM_CLEAR, 0, 0);

  SetFocus(ChannelEdit);

  S:='' ;

  ClipBoard.Open;
try
 if Clipboard.HasFormat(CF_UNICODETEXT) then begin
   H := Clipboard.GetAsHandle(CF_UNICODETEXT);
   TWPtr := GlobalLock(H);
   S := WideCharToString(TWPtr);
   GlobalUnlock(H);
  end
  else begin
    if Clipboard.HasFormat(CF_TEXT) then S:=Clipboard.AsText ;
  end;
 finally
  Clipboard.clear ;
  Clipboard.Close;
end;
  
  if (Length(S)<>0) then begin
    sc := DCfBase( S , True ); // crypt
	
	// если как то индентифицировать шифрованное сообщение
	// то его легко премодерировать на сервере.

    //отправляем  криптованное сообщение на сервер
    aData := fTextToAnsiString(uChannel)+  //канал  или пользователь
       fIntegerToAnsiString(iMessageMode)+  //тип важности
       fTextToAnsiString(sc); //сообщение
    CommFortProcess(dwPluginID, id, PAnsiChar(aData), Length(aData)) ;
  end ;
  
end ;

{****************************************************************
  Процедура ловушки WH_KEYBOARD
 ****************************************************************}
function KeyboardProc(code: integer; wParam: word; lParam: longint) : longint; stdcall;
Begin
  if code < 0 then
  begin
    Result:= CallNextHookEx(hHook1, Code, wParam, lParam) ;
    exit ;
  end ;

  if (code =  HC_ACTION) then
  begin

    if Byte(LParam shr 24)<$80  then
    begin
      if (VK_RETURN = wParam) then begin
         DCf(0) ; {Result:=1 ; Exit ;}
      end ;
      if (VK_F9 = wParam) then begin
         DCf(1) ; {Result:=1 ; Exit ;}
      end ;
    end;

  end ;	 
	 
    Result:=CallNextHookEx(hHook1, Code, wParam, lParam);	 
end;


procedure TMyTrackBar.CreateParams(var Params: TCreateParams);
begin
inherited;
Params.Style := Params.Style and not TBS_ENABLESELRANGE;
end;

class procedure TMyTrackBar.MyOnMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
//class procedure TMyTrackBar.MyOnChange(Sender: TObject);
var
  i : integer ;
  W : HWND ;
  SetLayeredWindowAttributes : TSetLayeredWindowAttributes;
  hUser32 : HINST;
begin
  SetWindowLong(ChatWindow, GWL_EXSTYLE, GetWindowLong(ChatWindow, GWL_EXSTYLE) OR WS_EX_LAYERED);

  W := FindWindowEx(ChatWindow, 0, 'TMyTrackBar', nil);
  i := SendMessage (W, TBM_GETPOS, 0, 0); 

  hUser32 := LoadLibrary('user32.dll');
  if hUser32 <> 0 then
  begin
    try
      SetLayeredWindowAttributes := GetProcAddress(hUser32, 'SetLayeredWindowAttributes');
      if Assigned(@SetLayeredWindowAttributes) then begin
		  SetLayeredWindowAttributes(ChatWindow, 0, Byte(i), LWA_ALPHA);
	  end ;
    finally
      FreeLibrary(hUser32);
    end;
  end;
end;


{start plugin}
function PluginStart(dwThisPluginID : DWORD; func1 : TCommFortProcess; func2 : TCommFortGetData) : Integer;
var
   dwId : DWORD ;
   dwProcessId : DWORD ;
   iSize, iReadOffset  : integer ;
   aData : WideString ;
begin
	dwPluginID := dwThisPluginID;
	//При инициализации планину присваивается уникальный идентификатор
	//его необходимо обязательно сохранить, и указывать
	//в качестве первого параметра при инициировании событий
	CommFortProcess := func1;
        //указываем функцию обратного вызова,
	//с помощью которой плагин сможет инициировать события

	CommFortGetData := func2;
  //указываем функцию обратного вызова,
	//с помощью которой можно будет запрашивать необходимые данные от программы

  //Возвращаемые значения:
	//TRUE - запуск прошел успешно
	//FALSE - запуск невозможен
	Result := Integer(TRUE);

  //Находим нужные нам окна
  dwId := GetCurrentProcessId();
  ChatWindow := 0;
  while ( (dwId<>dwProcessId) And (ChatWindow=0) )  do begin
    ChatWindow := FindWindowExW(0, ChatWindow, 'TfChatClient', nil);
    GetWindowThreadProcessId(ChatWindow, @dwProcessId);
  end ;

  if (ChatWindow = 0) then
   begin Result := Integer(FALSE) ; exit ; end ;

  dwId := GetCurrentThreadId();
  hHook1 := SetWindowsHookEx(WH_KEYBOARD, @KeyboardProc, 0, dwId );   

  iSize := CommFortGetData(dwPluginID, 2010, nil, 0, nil, 0); //получаем объем буфера
  SetLength(aData, iSize);
  CommFortGetData(dwPluginID, 2010, PAnsiChar(aData), iSize, nil, 0);//заполняем буфер

  iReadOffset := 0;
  //Получаем данные о событии
  myIniPath := fReadText(PAnsiChar(aData), iReadOffset);//путь
  myIniPath := myIniPath + 'secure_my.ini' ;

  DCfIniRead () ; { инициализация переменных}

  if not Assigned(MyTrackBar) then
    begin
    MyTrackBar := TMyTrackbar.Create(nil);
      with MyTrackBar do
        begin
          ParentWindow := ChatWindow;
          Left := 150 ;
          Top := 1;
          Width := 100;
          Height := 20;
          ThumbLength:=15 ;
          Max := 255;
          Min := 30;
          Position:=255;
          Visible := true;
          OnMouseUp:= TMyTrackBar.MyOnMouseUp;
        end;
    end;

end;
//---------------------------------------------------------------------------
procedure PluginStop();
begin
  //данная функция вызывается при завершении работы плагина
  if( hHook1  <> 0 ) then UnhookWindowsHookEx(hHook1);
  hHook1:=0 ;
  if Assigned(MyTrackBar) then  FreeAndNil(MyTrackBar);
end;
//---------------------------------------------------------------------------
procedure PluginProcess(dwID : DWORD; bInBuffer : PAnsiChar; dwInBufferSize : DWORD);
begin
	//Функция приема событий
	//Параметры:
	//dwID - идентификатор события
	//bInBuffer - указатель на данные
	//dwInBufferSize - объем данных в байтах

end;
//---------------------------------------------------------------------------
function PluginGetData(dwID : DWORD; bInBuffer : PAnsiChar; dwInBufferSize : DWORD; bOutBuffer : PAnsiChar; dwOutBufferSize : DWORD): DWORD;
var iWriteOffset, iSize : Integer; //вспомогательные переменные для упрощения работы с блоком данных
    uName : WideString;
begin

  //функция передачи данных программе
	iWriteOffset := 0;

	//при значении dwOutBufferSize равным нулю функция должна вернуть объем данных, ничего не записывая

	if (dwID = 2800) then //предназначение плагина
	begin
		if (dwOutBufferSize = 0) then
			Result := 4 //объем памяти в байтах, которую необходимо выделить программе
		else
		begin
			fWriteInteger(bOutBuffer, iWriteOffset, 2); //плагин подходит только для клиента
			Result := 4;//объем заполненного буфера в байтах
		end;
	end
	else
	if (dwID = 2810) then //название плагина (отображается в списке)
	begin
		uName := 'Secure+ ';//название плагина
		iSize := Length(uName) * 2 + 4;

		if (dwOutBufferSize = 0) then
			Result := iSize //объем памяти в байтах, которую необходимо выделить программе
		else
		begin
			fWriteText(bOutBuffer, iWriteOffset, uName);
			Result := iSize;//объем заполненного буфера в байтах
		end;
	end
	else
		Result := 0;//возвращаемое значение - объем записанных данных
end;
//---------------------------------------------------------------------------
function PluginPremoderation(dwID : DWORD; wText : PWideChar; var dwTextLength : DWORD):  Integer;
var 
  uRet : WideString;
  S, sc : UnicodeString ;
begin
	Result := 0;//важно вернуть FALSE в случае если буфер не был модифицирован
	//функция пермодерации
    //если Ваш плагин не использует премодерацию, рекомендуем исключить функцию из исходного кода, это сэкономит вычислительные ресурсы

	//Важно! Буфер выделяется на 40000 символов. Нельзя вносить в него данные бОльшего объема.

	if (myMain=0) then Exit ;
	if ((myPrivate=1) And (dwID<=5)) then Exit ;
	
	// текст в общий канал\приват
	if ((dwID <> 5) And (dwID <> 20)) then 
	begin
        uRet:= DCfBase( wText , False );

	    CopyMemory(wText, @uRet[1], Length(uRet) * 2);
	    dwTextLength := Length(uRet);//корректируем количество символов
	    Result := 1;//TRUE означает что буфер был модифицирован
	end ;

end;
//---------------------------------------------------------------------------
procedure PluginShowOptions();
var
  Wnd: HWND;                   // Hahdle найденного окна
  Rect: TRect;                 // Координаты окна
begin
  Wnd := FindWindowEx(0, 0, 'TfOptions', nil); // FindWindowEx(ChatWindow, 0, 'TfOptions', nil)
  GetWindowRect( Wnd, Rect ); 
  FormPreferences := TFormPreferences.Create(nil);
  FormPreferences.Top:= Rect.Top + 60 ;
  FormPreferences.Left:= Rect.Left + 70 ;
  FormPreferences.edtiniFile.Text:= myIniPath ;
  try
  FormPreferences.ShowModal;
 finally
  FormPreferences.Free;
 end;
  DCfIniRead ;
end;

//---------------------------------------------------------------------------
procedure PluginShowAbout();
begin
	//данная функция вызывается при нажатии кнопки "О плагине" в списке плагинов
	ShowMessage('Плагин для приватного общения в каналах.'
	 + #13#10 + 'Created for CommFort software Ltd.'
	 + #13#10 + 'Delphi, by Che'
	);
end;

end.
