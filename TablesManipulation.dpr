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

function existTable(const nameTable : string) : Boolean;
var
    nextTable : longword;
    nextRecord : longword;
    currentTableName : string;
    isFree : Byte;
    isStringEntry : UTF8String;
begin
    nextTable := 0;
    Result := false;
    fsOut := openFile(databaseName);
    fsOut.Seek(bitmapITable,soBeginning);
    writeln('nextTable: ',nextTable);
    writeln('cantTables: ',cantTables);
    while nextTable < cantTables do
    begin
        fsOut.Read(isFree,sizeof(Byte));
        writeln('isFree: ',isFree);
        if not isFree = 0 then
        begin
            isStringEntry := '';
            currentTableName := '';
            SetLength(isStringEntry,C_MAX_LENGTH);
            fsOut.ReadBuffer(isStringEntry[1],Length(isStringEntry));
            currentTableName := string(isStringEntry);
            writeln('currentTableName: ',currentTableName);
            if ansicomparestr(nameTable,currentTableName) = 0 then
            begin
                Result := true;
                fsOut.free;
                exit;
            end;
        end;

        nextTable := nextTable + 1;
        nextRecord := bitmapITable + nextTable*C_TOTAL_ITABLES;
        fsOut.Seek(nextRecord,soBeginning);

        writeln('nextTable: ',nextTable);
        writeln('cantTables: ',cantTables);
    end;
    
    fsOut.free;
end;

procedure saveTableEntry;
var
    offset : longword;
    osStringEntry : UTF8String;
begin
    writeln('saveEntry tableName: ',tableName);
    offset := bitmapITable + currentTable*C_TOTAL_ITABLES;
    fsOut := openFile(databaseName);
    fsOut.Seek(offset,soBeginning);
    writeln('pos: ',fsOut.Position);
    fsOut.Write(freeEntry,sizeof(Byte));
    writeln('pos: ',fsOut.Position);
    SetLength(tableName,C_MAX_LENGTH);
    writeln('saveEntry tableName: ',tableName);
    osStringEntry := UTF8String(tableName);
    writeln('saveEntry tableName: ',tableName);
    fsOut.WriteBuffer(osStringEntry[1],Length(tableName));
    writeln('pos: ',fsOut.Position);
    fsOut.Write(firstBlock,sizeof(integer));
    writeln('pos: ',fsOut.Position);
    fsOut.Write(lastBlock,sizeof(integer));
    writeln('pos: ',fsOut.Position);
    fsOut.Write(cantRegisters,sizeof(integer));
    writeln('pos: ',fsOut.Position);
    fsOut.free;
end;

procedure CreateTable;
var
    indexTable : integer;
    startBlock : integer;
    newTableName : string;
begin
    readBitmapBlocks;
    indexTable := GetNextFreeITable;
    startBlock := GetNextFreeBlock;
    writeln('indexTable: ',indexTable);
    writeln('startBlock: ',startBlock);
    if (indexTable >= 0) And (startBlock > 0) then
    begin
        write('Insert Table Name: ');
        readln(newTableName);
        if not existTable(newTableName) then 
        begin
            tableName := newTableName;
            freeEntry := $ff;
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
            writeln('Table: ',newTableName,' has been created!');
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