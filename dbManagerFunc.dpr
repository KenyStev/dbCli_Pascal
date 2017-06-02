const
  C_ROOT = 'databases\';
  C_EXT = '.dbCli';

  C_CREATE_DB_OPTION_MSG = '1. Create Database.';
  C_DROP_DB_OPTION_MSG = '2. Drop Database.';

var
  fsOut    : TFileStream;
  sizeOfBlock : Longword;

function openFile(dbName:string) : TFileStream;
begin
    Result := TFileStream.Create( dbName, fmOpenWrite or fmOpenRead);
end;

{$I 'DatabaseStruct.dpr'}

procedure createSuperBlock(dbName : string; dbSize : integer);
var
    dbNameLarge : string;
begin
    dbNameLarge := C_ROOT + dbName + C_EXT;
    databaseName := dbName;
    databaseSize := dbSize;
    cantBlocks := Floor(dbSize/sizeOfBlock);
    reserverForITables := Floor(dbSize*0.15);
    freeBlocks := cantBlocks - Ceil((C_TOTAL_SUPERBLOCK + reserverForITables + cantBlocks/8)/sizeOfBlock);
    cantITables := Floor(reserverForITables/C_TOTAL_ITABLES);
    freeITables := cantITables;
    bitmapBlock := C_TOTAL_SUPERBLOCK;
    bitmapITable := bitmapBlock + Ceil(cantBlocks/8);
    saveSuperBlock;
    printSuperBlock;
    writeln('----------------------------');
    readSuperBlock;
    printSuperBlock;
    // initBitmapBlocks;
end;

procedure CreateDatabase;
var
  dbName : string;
  dbNameLarge : string;
  dbSize : integer;
  dbSizeInBytes : integer;
  cantBlocks : integer;
begin
  dbSize := 10;
  write('Insert database name: ');
  readln(dbName);
  dbNameLarge := C_ROOT + dbName + C_EXT;
  write('Insert database size: ');
  readln(dbSize);
  dbSizeInBytes := dbSize*1024*1024;
  cantBlocks := Ceil(dbSizeInBytes/sizeOfBlock);
  dbSizeInBytes := cantBlocks*sizeOfBlock;

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
    createSuperBlock(dbName,dbSizeInBytes);
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