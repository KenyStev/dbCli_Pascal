const
    C_INSERT_INTO_TABLE_MSG = '3. Insert Into Table';
    C_SELECT_TABLE_MSG = '4. Select From Table';

procedure InserIntoTable;
var
    i : Integer;
    offset : longword;
    registerSize : longword;
    tableToInsert : string;
    readingString : string;
    readingDouble : Double;
    readingInteger : Integer;
begin
    write('Inserte Nombre de Tabla: ');
    readln(tableToInsert);
    if existTable(tableToInsert) then
    begin
        registerSize := 0;
        readCurrentTableEntry;
        readFieldsForCurrentTable;
        for i := 0 to (Length(fieldsCurrentTable)-1) do
            registerSize := registerSize + fieldsCurrentTable[i].Size;

        offset := lastBlock*sizeOfBlock + usedSpaceOfLastBlock;
        fsOut := openFile(databaseName);
        fsOut.Seek(offset,soBeginning);
        
        for i := 0 to (Length(fieldsCurrentTable)-1) do
        begin
            write('Ingrese ',fieldsCurrentTable[i].Nombre,': ');

            case fieldsCurrentTable[i].Tipo of
                1: begin
                    readln(readingInteger);
                    fsOut.Write(readingInteger,sizeof(readingInteger));
                end;
                2: begin
                    readln(readingDouble);
                    fsOut.Write(readingDouble,sizeof(readingDouble));
                end;
                3: begin
                    readln(readingString);
                    fsOut.Write(pointer(readingString)^,Length(readingString));
                    fsOut.Seek(fieldsCurrentTable[i].Size-Length(readingString),soCurrent);
                end;
            end;
        end;
        cantRegisters := cantRegisters + 1;
        usedSpaceOfLastBlock := usedSpaceOfLastBlock + registerSize;
        fsOut.free;
        saveTableEntry;
    end
    else writeln('Table ',tableToInsert,' Not Exist!');
end;

procedure SelectFromTable;
var
    i : Integer;
    offset : longword;
    currentRow : longword;
    readingString : string;
    readingDouble : Double;
    readingInteger : Integer;
    fromTableName : string;
begin
    write('Ingreste Nombre de Tabla: ');
    readln(fromTableName);
    if existTable(fromTableName) then
    begin
        currentRow := 0;
        readCurrentTableEntry;
        readFieldsForCurrentTable;
        offset := lastBlock*sizeOfBlock + usedSpaceForFields;
        fsOut := openFile(databaseName);
        fsOut.Seek(offset,soBeginning);
        
        for i := 0 to (Length(fieldsCurrentTable)-1) do
        begin
            write(Format('%10s',[fieldsCurrentTable[i].Nombre]));
        end;
        writeln('');

        while currentRow < cantRegisters do
        begin
            for i := 0 to (Length(fieldsCurrentTable)-1) do
            begin
                case fieldsCurrentTable[i].Tipo of
                    1: begin
                        fsOut.Read(readingInteger,sizeof(readingInteger));
                        write(Format('%10d',[readingInteger]));
                    end;
                    2: begin
                        fsOut.Read(readingDouble,sizeof(readingDouble));
                        write(Format('%10f',[readingDouble]));
                    end;
                    3: begin
                        SetLength(readingString,fieldsCurrentTable[i].Size);
                        fsOut.Read(pointer(readingString)^,Length(readingString));
                        write(Format('%10s',[readingString]));
                    end;
                end;
            end;
            writeln('');
            currentRow := currentRow + 1;
        end;

        fsOut.free;
    end
    else writeln('Table ',fromTableName,' Not Exist!');
end;