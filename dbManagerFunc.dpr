const
  C_ROOT = 'databases\';
  C_EXT = '.dbCli';

  C_CREATE_DB_OPTION_MSG = '1. Create Database.';
  C_DROP_DB_OPTION_MSG = '2. Drop Database.';
  C_CONNECT_DB_OPTION_MSG = '2. Connect Database.';

var
  fsOut    : TFileStream;
  sizeOfBlock : Longword;

function openFile(dbName:string) : TFileStream;
begin
    Result := TFileStream.Create( C_ROOT + dbName + C_EXT, fmOpenReadWrite);
end;

{$I 'DatabaseStruct.dpr'}
{$I 'BitmapManipulation.dpr'}
{$I 'TablesManipulation.dpr'}

procedure createSuperBlock(dbName : string; dbSize : integer);
begin
    databaseName := dbName;
    databaseSize := dbSize;
    cantBlocks := Floor(dbSize/sizeOfBlock);
    reserverForITables := Floor(dbSize*0.15);
    freeBlocks := cantBlocks - Ceil((C_TOTAL_SUPERBLOCK + reserverForITables + cantBlocks/8)/sizeOfBlock);
    cantITables := Floor(reserverForITables/C_TOTAL_ITABLES);
    freeITables := cantITables;
    bitmapBlock := C_TOTAL_SUPERBLOCK;
    bitmapITable := bitmapBlock + Ceil(cantBlocks/8);
    cantTables := 0;

    saveSuperBlock;
    printSuperBlock;
    writeln('----------------------------');
    readSuperBlock;
    printSuperBlock;
    initBitmapBlocks;
end;

procedure CreateDatabase;
var
  dbName : string;
  dbPath : string;
  dbSize : integer;
  dbSizeInBytes : integer;
  cantBlocks : integer;
begin
  dbSize := 10;
  write('Insert database name: ');
  readln(dbName);
  dbPath := C_ROOT + dbName + C_EXT;
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
    fsOut := TFileStream.Create( dbPath, fmCreate);
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
  dbPath : string;
begin
  write('Insert database to delete: ');
  readln(dbName);
  dbPath := C_ROOT + dbName + C_EXT;
  // Now delete the file
  if deletefile(dbPath)
  then writeln(dbName+' deleted OK')
  else writeln(dbName+' not deleted');
end;

procedure ConnectDatabase(dbName : string);
var
    option : integer;
begin
    databaseName := dbName;
    readSuperBlock;
    writeln('Using database: ',dbName);
    repeat
        writeln(C_CREATE_TABLE_MSG);
        writeln(C_DROP_TABLE_MSG);
        writeln(C_PRINT_SUPERBLOCK_MSG);
        writeln('-1. Disconnect.');
        write('select option: ');
        readln(option);

        case option of
        1: CreateTable;
        2: DropTable;
        7: printSuperBlock;
        -1: writeln('disconnecting: ',dbName,'!');
        else writeln('Not valid option.');
        end;
    until (option = -1);
end;

procedure UseDatabase;
var
    dbName : string;
    dbPath : string;
begin
    write('Insert database to use: ');
    readln(dbName);
    dbPath := C_ROOT + dbName + C_EXT;
    if fileexists(dbPath) 
    then ConnectDatabase(dbName)
    else writeln('Database not found!');
end;