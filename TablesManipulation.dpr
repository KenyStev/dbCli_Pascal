const
  C_CREATE_TABLE_MSG = '1. Create Table.';
  C_DROP_TABLE_MSG = '2. Drop Table.';
  C_PRINT_SUPERBLOCK_MSG = '7. Show Super Block.';

function GetNextFreeITable : integer;
var
    nextFreeITable : integer;
    isFree : Byte;
    nextRecord : longword;
begin
    Result := -1;
    nextFreeITable := 0;
    isFree := 0;
    fsOut := openFile(databaseName);
    fsOut.Seek(bitmapITable,soBeginning);
    while nextFreeITable < cantITables do
    begin
        fsOut.Read(isFree,sizeof(Byte));
        writeln('isFree; ',isFree);
        if isFree = 0 then
        begin
            Result := nextFreeITable;
            fsOut.free;
            exit;
        end;
        nextFreeITable := nextFreeITable + 1;
        nextRecord := bitmapITable + nextFreeITable*C_TOTAL_ITABLES;
        fsOut.Seek(nextRecord,soBeginning);
    end;
    fsOut.free;
end;

function existTable(nameTable:string) : Boolean;
var
    nextTable : longword;
    nextRecord : longword;
    currentTableName : string;
    isFree : Byte;
begin
    nextTable := 0;
    Result := false;
    fsOut := openFile(databaseName);
    fsOut.Seek(bitmapITable,soBeginning);
    while nextTable < cantTables do
    begin
        fsOut.Read(isFree,sizeof(Byte));
        if not isFree = 0 then
        begin
            fsOut.Read(currentTableName,20);
            if ansicomparestr(nameTable,currentTableName) = 0 then
            begin
                Result := true;
                exit;
            end;
        end;

        nextTable := nextTable + 1;
        nextRecord := bitmapITable + nextTable*C_TOTAL_ITABLES;
        fsOut.Seek(nextRecord,soBeginning);
    end;
    
    fsOut.free;
end;

procedure saveTableEntry;
var
    offset : longword;
begin
    offset := bitmapITable + currentTable*C_TOTAL_ITABLES;
    fsOut := openFile(databaseName);
    fsOut.Seek(offset,soBeginning);
    fsOut.Write(freeEntry,sizeof(Byte));
    fsOut.Write(tableName,sizeof(20));
    fsOut.Write(firstBlock,sizeof(integer));
    fsOut.Write(lastBlock,sizeof(integer));
    fsOut.Write(cantRegisters,sizeof(integer));
    fsOut.free;
end;

procedure CreateTable;
var
    indexTable : integer;
    startBlock : integer;
begin
    readBitmapBlocks;
    indexTable := GetNextFreeITable;
    startBlock := GetNextFreeBlock;
    writeln('indexTable: ',indexTable);
    writeln('startBlock: ',startBlock);
    if (indexTable >= 0) And (startBlock > 0) then
    begin
        write('Insert Table Name: ');
        readln(tableName);
        if not existTable(tableName) then 
        begin
            freeEntry := 1;
            firstBlock := startBlock;
            lastBlock := startBlock;
            cantRegisters := 0;
            currentTable := indexTable;
            saveTableEntry;
            SetUsedBlock(startBlock);
            saveBitmapBlocks;
            cantTables := cantTables + 1;
            freeItables := freeItables - 1;
            saveSuperBlock;
            writeln('Table: ',tableName,' has been created!');
        end
        else writeln('Table already exist!');
    end
    else
    begin
        writeln('Cannot create more tables');
    end;
end;

procedure DropTable;
begin
    
end;