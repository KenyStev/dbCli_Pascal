const
  C_ROOT = 'databases\';
  C_EXT = '.dbCli';

  C_CREATE_DB_OPTION_MSG = '1. Create Database.';
  C_DROP_DB_OPTION_MSG = '2. Drop Database.';

var
  fsOut    : TFileStream;
  sizeOfBlock : integer;

function openFile(dbName:string) : TFileStream;
begin
    Result := TFileStream.Create( dbName, fmOpenWrite or fmOpenRead);
end;

procedure saveSuperBlock(dbName : string; dbSize : integer);
var
    dbNameLarge : string;
    cantBlocks : integer;
begin
    dbNameLarge := C_ROOT + dbName + C_EXT;
    fsOut := openFile(dbNameLarge);
    fsOut.Write(dbName, 20);
    fsOut.Write(dbSize,sizeof(dbSize));

    cantBlocks := Floor(dbSize/sizeOfBlock);

    fsOut.Write(cantBlocks,sizeof(cantBlocks));

    fsOut.free;
end;

procedure CreateDatabase;
var
  dbName : string;
  dbNameLarge : string;
  dbSize : integer;
  dbSizeInBytes : integer;
begin
  dbSize := 10;
  write('Insert database name: ');
  readln(dbName);
  dbNameLarge := C_ROOT + dbName + C_EXT;
  write('Insert database size: ');
  readln(dbSize);
  dbSizeInBytes := dbSize*1024*1024;

  // Catch errors in case the file cannot be created
  try
    if Length(dbName)>20 then
    begin
        raise Exception.Create('Name cannot be greather than 20 characters!');
    end;
    // Create the file stream instance, write to it and free it to prevent memory leaks
    fsOut := TFileStream.Create( dbNameLarge, fmCreate);
    fsOut.size := dbSizeInBytes;
    fsOut.Free;

    writeln('Database has beed created succsessfuly');
    saveSuperBlock(dbName,dbSizeInBytes);
  // Handle errors
  except
    on E:Exception do
      writeln('Database ', dbName, ' could not be created because: ', E.Message);
    end;
end;

procedure DropDatabase;
var
  dbName : string;
  dbNameLarge : string;
begin
  write('Insert database to delete: ');
  readln(dbName);
  dbNameLarge := C_ROOT + dbName + C_EXT;
  // Now delete the file
  if deletefile(dbNameLarge)
  then writeln(dbName+' deleted OK')
  else writeln(dbName+' not deleted');
end;