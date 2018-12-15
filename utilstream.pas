{*************************************************************}
{            stream handling unit for                         }
{ Version:   1.1                                              }
{ Author:                                                  }
{ E-Mail:                                                     }
{ Homepage:                                                   }
{ Created:   Jun, 2010 - Rus -                                }
{*************************************************************}


unit utilstream;

interface

uses
  Classes, SysUtils, Zlib;

type TCompLevel = (clNone, clFastest, clDefault, clMax);//zlib compress level

function CompressStream(inStream, outStream :TStream;
          const Level :TCompLevel = clMax):Boolean;

function DeCompressStream(inStream, outStream :TStream):Boolean;

function CompressFile(const InputFile :string; const OutputFile :string;
         const Level :TCompLevel = clMax):Boolean;

function DeCompressFile(const InputFile :string;
         const OutputFile :string):Boolean;

function CompressString(sText :String; const Level:TCompLevel=clMax):String;
function DeCompressString(sText :String):String;

implementation

function CompressString(sText :String; const Level : TCompLevel = clMax):String;
var InStream, OutStream : TStringStream;
begin
  try
    InStream := TStringStream.Create(sText);
    try
      OutStream := TStringStream.Create('');
      try
        CompressStream(InStream, OutStream,TCompLevel(Level));
      finally
        InStream.Free;
      end;
    finally
      Result := OutStream.DataString;
      OutStream.Free;
    end;
  except Result := '';
  end;
end;

function DeCompressString(sText :String):String;
var InStream, OutStream : TStringStream;
begin
  try
    InStream := TStringStream.Create(sText);
    try
      OutStream := TStringStream.Create('');
      try
        DeCompressStream(InStream, OutStream);
      finally
        InStream.Free;
      end;
    finally
      Result := OutStream.DataString;
      OutStream.Free;
    end;
  except Result := '';
  end;
end;

function CompressFile(const InputFile :string; const OutputFile :string;
          const Level : TCompLevel = clMax):Boolean;
var
  InStream, OutStream: TFileStream;
begin
  Result:= False;
  try
    InStream:= TFileStream.Create(InputFile,fmOpenRead);
    try
      OutStream:= TFileStream.Create(OutputFile,fmCreate);
      try
        Result := CompressStream(inStream,outStream,TCompLevel(Level));
      finally
        OutStream.Free;
      end;
    finally
      InStream.Free;
    end;
  except end;
end;

function DeCompressFile(const InputFile :string;
         const OutputFile :string):Boolean;
var
  InStream, OutStream: TFileStream;
begin
  Result := False;
  try
    InStream:= TFileStream.Create(InputFile,fmOpenRead);
    try
      OutStream:= TFileStream.Create(OutputFile,fmCreate);
      try
        Result := DeCompressStream(inStream,outStream);
      finally
        OutStream.Free;
      end;
    finally
      InStream.Free;
    end;
  except end;
end;

function CompressStream(inStream, outStream :TStream;
          const Level : TCompLevel = clMax):Boolean;
begin
   Result := False;

   with TCompressionStream.Create( TCompressionLevel(Level) , outStream ) do
   try
     CopyFrom(inStream, 0);
     //flush;
     Free;
   finally
     Result := True;
   end;
end;

function DeCompressStream(inStream, outStream :TStream):Boolean;
var
  DeCompress: Tdecompressionstream;
  len: Integer;
  Buffer: array of Byte;
begin //uncompress stream
    SetLength(Buffer, $FFF);

    DeCompress := Tdecompressionstream.create(inStream);
    try
      len := DeCompress.Read(Buffer[0], $FFF);
      while len > 0 do begin
        outStream.Write(Buffer[0], len);
        try
          len := DeCompress.Read(Buffer[0], $FFF);
        except
            break;
        end;
      end;
    finally
      Result := True;
    end;
    DeCompress.Free;
end;

end.
