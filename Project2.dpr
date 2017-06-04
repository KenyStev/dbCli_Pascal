program dbCli_Pascal;

{$APPTYPE CONSOLE}

uses
  Classes, Sysutils;

const
  C_FNAME = 'binarydata.bin';
  C_ROOT = 'databases\';
  C_EXT = '.dbCli';

  C_CREATE_DB_OPTION_MSG = '1. Create Database.';
  C_DROP_DB_OPTION_MSG = '2. Drop Database.';

var
  fsOut    : TFileStream;
  ChrBuffer: array[0..2] of integer;
  Value: Integer;

procedure CreateDatabase;
var
  dbName : string;
  dbSize : integer;
begin
  dbSize := 10;
  write('Insert database name: ');
  readln(dbName);
  dbName := C_ROOT + dbName + C_EXT;
  write('Insert database size: ');
  readln(dbSize);

  // Catch errors in case the file cannot be created
  try
    // Create the file stream instance, write to it and free it to prevent memory leaks
    fsOut := TFileStream.Create( dbName, fmCreate);
    fsOut.size := dbSize * 1024*1024;
    fsOut.Free;

    writeln('Database has beed created succsessfuly');

  // Handle errors
  except
    on E:Exception do
      writeln('Database ', dbName, ' could not be created because: ', E.Message);
  end;
end;

procedure DropDatabase;
var
  dbName : string;
begin
  write('Insert database to delete: ');
  readln(dbName);
  dbName := C_ROOT + dbName + C_EXT;
  // Now delete the file
  if deletefile(dbName)
  then writeln(dbName+' deleted OK')
  else writeln(dbName+' not deleted');
end;

procedure MainMenu;
var
  option : integer;
begin
  option := 0;
  repeat
    writeln(C_CREATE_DB_OPTION_MSG);
    writeln(C_DROP_DB_OPTION_MSG);
    writeln('-1. Exit');
    write('select option: ');
    readln(option);
    case option of
      1: CreateDatabase;
      2: DropDatabase;
    else writeln('Not valid option.');
    end;
  until option = -1;
end;

begin
  MainMenu;
  // Set up some random data that will get stored
  ChrBuffer[0] := 8;
  ChrBuffer[1] := 5;
  ChrBuffer[2] := 4;
  Value := 0;
 
  // Catch errors in case the file cannot be created
  try
    // Create the file stream instance, write to it and free it to prevent memory leaks
    fsOut := TFileStream.Create( C_FNAME, fmCreate);
    fsOut.Write(ChrBuffer, sizeof(ChrBuffer));

    fsOut.Seek(0,soBeginning);
    fsOut.Read(Value, SizeOf(Value));//read a 4 byte integer

    write('Valor: ');
    writeln(Value);
    fsOut.Free;

  // Handle errors
  except
    on E:Exception do
      writeln('File ', C_FNAME, ' could not be created because: ', E.Message);
  end;

  // Give feedback and wait for key press
  writeln('File ', C_FNAME, ' created if all went ok. Press Enter to stop.');
  readln;
end.



//Escribiendo y leyendo en files

//Main
var
  tryfsOut : TFileStream;
  valor : longword;
  // buff : array[0..3] of Byte absolute valor;
begin
  // valor := 5242880;
  // tryfsOut := TFileStream.Create( C_FNAME, fmCreate);
  // writeln('pos: ',tryfsOut.Position);
  // writeln('sizeof(valor): ',sizeof(valor));
  // tryfsOut.Write(valor, sizeof(valor));
  // writeln('pos: ',tryfsOut.Position);
  // writeln('sizeof(valor): ',sizeof(valor));
  // tryfsOut.Free;

  valor := 0;
  // try
  tryfsOut := TFileStream.Create( C_FNAME, fmOpenReadWrite);
  writeln('pos: ',tryfsOut.Position);
  tryfsOut.Read(valor,SizeOf(valor));
  writeln('valor: ',valor);
  // writeln('pos: ',tryfsOut.Position);//---
  // writeln('buff[0]: ',buff[0]);//---
  // writeln('buff[1]: ',buff[1]);//---
  // writeln('buff[2]: ',buff[2]);//---
  // writeln('buff[3]: ',buff[3]);//---
  // tryfsOut.Read(valor,SizeOf(longword));
  // writeln('valor: ',valor);
  // writeln('pos: ',tryfsOut.Position);
  // tryfsOut.Read(valor,SizeOf(longword));
  // writeln('valor: ',valor);
  // writeln('pos: ',tryfsOut.Position);
  // tryfsOut.Read(valor,SizeOf(longword));
  // writeln('valor: ',valor);
  // writeln('pos: ',tryfsOut.Position);
  tryfsOut.Free;//---
  // except
  //   on E:Exception do
  //     writeln('File ', C_FNAME, ' could not be created because: ', E.Message);
  // end;
end.