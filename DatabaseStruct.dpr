const
    C_TOTAL_SUPERBLOCK = 20+4*8;
    C_TOTAL_ITABLES = 21+4*3;
        
procedure printSuperBlock;
begin
    //prints
    writeln('name: ',databaseName);
    writeln('size: ',databaseSize);
    writeln('cantBlocks: ',cantBlocks);
    writeln('freeBlocks: ',freeBlocks);
    writeln('cantITables: ',cantITables);
    writeln('freeITables: ',freeITables);
    writeln('bitmapBlock: ',bitmapBlock);
    writeln('bitmapITable: ',bitmapITable);
    writeln('cantTables: ',cantTables);
end;

procedure saveSuperBlock;
var
    dbName : string;
    osString : UTF8String;
begin
    dbName := databaseName;
    SetLength(dbName,C_MAX_LENGTH);
    osString := UTF8String(dbName);
    writeln('writeSB dbName: ',dbName);
    writeln('writeSB: ',databaseName);
    fsOut := openFile(databaseName);
    writeln('writeSB dbName: ',dbName);
    fsOut.WriteBuffer(osString[1], Length(dbName));
    fsOut.Write(databaseSize,sizeof(longword));
    fsOut.Write(cantBlocks,sizeof(integer));
    fsOut.Write(freeBlocks,sizeof(integer));
    fsOut.Write(cantITables,sizeof(integer));
    fsOut.Write(freeITables,sizeof(integer));
    fsOut.Write(bitmapBlock,sizeof(integer));
    fsOut.Write(bitmapITable,sizeof(integer));
    fsOut.Write(cantTables,sizeof(integer));
    fsOut.free;
end;

procedure readSuperBlock;
// var
    // isString : UTF8String;
begin
    // SetLength(isString,C_MAX_LENGTH);
    // writeln('readSB: ',databaseName);
    fsOut := openFile(databaseName);
    // writeln('readSB: ',databaseName);
    // fsOut.ReadBuffer(isString[1], Length(isString));
    // databaseName := string(isString);
    // writeln('readSB databaseName: ',databaseName);
    fsOut.Seek(20,soBeginning);
    fsOut.Read(databaseSize,sizeof(longword));
    fsOut.Read(cantBlocks,sizeof(integer));
    fsOut.Read(freeBlocks,sizeof(integer));
    fsOut.Read(cantITables,sizeof(integer));
    fsOut.Read(freeITables,sizeof(integer));
    fsOut.Read(bitmapBlock,sizeof(integer));
    fsOut.Read(bitmapITable,sizeof(integer));
    fsOut.Read(cantTables,sizeof(integer));
    fsOut.free;
    printSuperBlock;
end;