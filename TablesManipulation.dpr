const
  C_CREATE_TABLE_MSG = '1. Create Table.';
  C_DROP_TABLE_MSG = '2. Drop Table.';
  C_PRINT_SUPERBLOCK_MSG = '7. Show Super Block.';
  C_PRINT_FIELDS_MSG = '8. Show Fields.';

  C_INT_TYPE = 1;
  C_DOUBLE_TYPE = 2;
  C_CHAR_TYPE = 3;

type
  TField = record
    Nombre : string[50];
    Tipo  : integer;
    Size : integer;
  end;

var
    usedSpaceForFields : longword;
    fieldsCurrentTable : array of TField;

function GetTypeName(typeNumber:integer) : string;
begin
    Result := 'Char';
    if typeNumber = C_INT_TYPE 
    then Result := 'Int'
    else if typeNumber = C_DOUBLE_TYPE then Result := 'Double';
end;

function GetNextFreeITable : integer;
var
    nextFreeITable : longword;
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
    nextTable, countTable : longword;
    nextRecord : longword;
    currentTableName : string;
    isFree : Byte;
begin
    nextTable := 0;
    countTable := 0;
    Result := false;
    fsOut := openFile(databaseName);
    fsOut.Seek(bitmapITable,soBeginning);
    while countTable < cantTables do
    begin
        fsOut.Read(isFree,sizeof(Byte));
        if not isFree = 0 then
        begin
            fsOut.Read(tableNameSize,sizeof(integer));
            SetLength(currentTableName,tableNameSize);
            fsOut.ReadBuffer(pointer(currentTableName)^,tableNameSize);
            if ansicomparestr(nameTable,currentTableName) = 0 then
            begin
                currentTable := nextTable;
                Result := true;
                fsOut.free;
                exit;
            end
            else countTable := countTable + 1;
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
    offsetName : longword;
begin
    offset := bitmapITable + currentTable*C_TOTAL_ITABLES;
    offsetName := offset + sizeof(Byte) + sizeof(integer) + C_MAX_LENGTH;
    fsOut := openFile(databaseName);
    fsOut.Seek(offset,soBeginning);
    fsOut.Write(freeEntry,sizeof(Byte));
    fsOut.Write(tableNameSize,sizeof(integer));
    fsOut.WriteBuffer(pointer(tableName)^,tableNameSize);
    fsOut.Seek(offsetName,soBeginning);
    fsOut.Write(firstBlock,sizeof(longword));
    fsOut.Write(lastBlock,sizeof(longword));
    fsOut.Write(cantRegisters,sizeof(longword));
    fsOut.Write(usedSpaceOfLastBlock,sizeof(longword));
    fsOut.free;
end;

procedure readCurrentTableEntry;
var
    offset : longword;
    offsetName : longword;
begin
    offset := bitmapITable + currentTable*C_TOTAL_ITABLES;
    offsetName := offset + sizeof(Byte) + sizeof(integer) + C_MAX_LENGTH;
    fsOut := openFile(databaseName);
    fsOut.Seek(offset,soBeginning);
    fsOut.Read(freeEntry,sizeof(Byte));
    fsOut.Read(tableNameSize,sizeof(integer));
    SetLength(tableName,tableNameSize);
    fsOut.ReadBuffer(pointer(tableName)^,tableNameSize);
    fsOut.Seek(offsetName,soBeginning);
    fsOut.Read(firstBlock,sizeof(longword));
    fsOut.Read(lastBlock,sizeof(longword));
    fsOut.Read(cantRegisters,sizeof(longword));
    fsOut.Read(usedSpaceOfLastBlock,sizeof(longword));
    fsOut.free;
end;

procedure setFieldsToTable;
var
    option : string;
    fieldName : string;
    typeField, lengthChar : integer;
    offset : longword;
    cantFields : integer;
    newField : TField;
begin
    readCurrentTableEntry;
    option := 'si';
    cantFields := 0;
    offset := firstBlock*sizeOfBlock;
    fsOut := openFile(databaseName);
    fsOut.Seek(offset+sizeof(integer),soBeginning);
    repeat
        write('Desea agregar un campo (si/no): ');
        readln(option);
        if ansicomparestr(option,'si') = 0 then
        begin
            write('Nombre del Campo: ');
            readln(fieldName);
            if (Length(fieldName) > 0) and (Length(fieldName) <= 50) Then
            begin
                newField.Nombre := fieldName;
                writeln('1. Int.');
                writeln('2. Double.');
                writeln('3. Char.');
                write('Seleccione Tipo de Campo: ');
                readln(typeField);

                case typeField of
                    1: newField.Size := 4;
                    2: newField.Size := 8;
                    3: begin
                        write('Cantidad de chars(0-255): ');
                        readln(lengthChar);
                        if (lengthChar >= 0) and (lengthChar < 256) then
                        begin
                            newField.Size := lengthChar;
                        end
                        else writeln('Char out of length');
                    end;
                    else writeln('Not Valid Type');
                end;
                case typeField of
                1,2,3: begin
                    newField.Tipo := typeField;
                    writeln('Writing field: ',newField.nombre,' ',GetTypeName(newField.Tipo),'(',newField.Size,')');
                    fsOut.WriteBuffer(newField,sizeof(TField));
                    cantFields := cantFields + 1;
                    usedSpaceOfLastBlock := usedSpaceOfLastBlock + sizeof(TField);
                    end;
                end;
            end;
        end
        else
        begin
            option := 'no';
        end;
    until (ansicomparestr(option,'no') = 0);
    fsOut.Seek(offset,soBeginning);
    fsOut.Write(cantFields,sizeof(integer));
    fsOut.free;
    usedSpaceOfLastBlock := usedSpaceOfLastBlock + sizeof(integer);
    saveTableEntry;
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
    if (indexTable >= 0) And (startBlock > 0) then
    begin
        clearMemoryOfBlock(startBlock);
        write('Insert Table Name: ');
        readln(newTableName);
        if not existTable(newTableName) then 
        begin
            tableNameSize := Length(newTableName);
            tableName := newTableName;
            freeEntry := $ff;
            firstBlock := startBlock;
            lastBlock := startBlock;
            cantRegisters := 0;
            currentTable := indexTable;
            usedSpaceOfLastBlock := 0;
            saveTableEntry;
            SetUsedBlock(startBlock);
            saveBitmapBlocks;
            cantTables := cantTables + 1;
            freeItables := freeItables - 1;
            saveSuperBlock;
            setFieldsToTable;
            writeln('Table: ',newTableName,' has been created!');
        end
        else writeln('Table: ',newTableName,' already exist!');
    end
    else
    begin
        writeln('Cannot create more tables');
    end;
end;

procedure freeUsedBlocks(block : longword);
var
    offset : longword;
    nextBlock : longword;
begin
    offset := block*sizeOfBlock + sizeOfBlock - sizeof(longword);
    fsOut := openFile(databaseName);
    fsOut.Seek(offset,soBeginning);
    fsOut.Read(nextBlock,sizeof(longword));
    if nextBlock <> 0 
    then freeUsedBlocks(nextBlock)
    else ClearUsedBlock(block);
    fsOut.free;
end;

procedure DropTable;
var
    tableNameToDrop : string;
begin
    write('Table to Drop: ');
    readln(tableNameToDrop);
    if existTable(tableNameToDrop) then
    begin
        readBitmapBlocks;
        readCurrentTableEntry;
        freeUsedBlocks(firstBlock);
        saveBitmapBlocks;
        freeEntry := 0;
        tableName := '';
        tableNameSize := Length(tableName);
        saveTableEntry;
        freeItables := freeItables + 1;
        cantTables := cantTables - 1;
        saveSuperBlock;
        writeln('Table: ',tableNameToDrop,' has been dropped!');
    end
    else writeln('Table: ',tableNameToDrop,' Not Exist!');
end;

procedure readFieldsForCurrentTable;
var
    i : integer;
    cantFields : integer;
    readingField : TField;
begin
    cantFields :=0;
    fsOut := openFile(databaseName);
    fsOut.Seek(firstBlock*sizeOfBlock,soBeginning);
    fsOut.Read(cantFields,sizeof(integer));
    SetLength(fieldsCurrentTable,cantFields);
    usedSpaceForFields := sizeof(integer) + cantFields*sizeof(TField);
    for i := 0 to (cantFields-1) do
    begin
        fsOut.ReadBuffer(readingField,sizeof(TField));
        fieldsCurrentTable[i] := readingField;
    end;
    fsOut.free;
end;

procedure printFieldsForTable;
var
    i : integer;
    tableNameToShowFields : string;
begin
    write('Ingrese nombre de tabla: ');
    readln(tableNameToShowFields);
    if existTable(tableNameToShowFields) then
    begin
        readCurrentTableEntry;
        readFieldsForCurrentTable;
        for i := 0 to (Length(fieldsCurrentTable)-1) do
            writeln(fieldsCurrentTable[i].Nombre,' ',GetTypeName(fieldsCurrentTable[i].Tipo),'(',fieldsCurrentTable[i].Size,')');
    end
    else writeln('Table: ',tableNameToShowFields,' Not Exist!');
end;