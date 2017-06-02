const
    C_TOTAL_SUPERBLOCK = 20+4*7;
    C_TOTAL_ITABLES = 20+4*3;

var //Metadata Database
    databaseName : string;          //20 bytes
    databaseSize : Longword;        // 4 bytes
    cantBlocks : integer;           // 4 bytes
    freeBlocks : integer;           // 4 bytes
    cantITables : integer;          // 4 bytes
    freeItables : integer;          // 4 bytes
    bitmapBlock : integer;          // 4 bytes
    bitmapITable : integer;         // 4 bytes
    reserverForITables : Longword;  

var //Metadata ITables
    tableName : string;             //20 bytes
    firstBlock : Longword;          // 4 bytes
    lastBlock : Longword;           // 4 bytes
    cantRegisters : Longword;       // 4 bytes

procedure saveSuperBlock;
begin
    fsOut := openFile(databaseName);
    fsOut.Write(databaseName, 20);
    fsOut.Write(databaseSize,sizeof(databaseSize));
    fsOut.Write(cantBlocks,sizeof(cantBlocks));
    fsOut.Write(freeBlocks,sizeof(freeBlocks));
    fsOut.Write(cantITables,sizeof(cantITables));
    fsOut.Write(freeITables,sizeof(freeITables));
    fsOut.Write(bitmapBlock,sizeof(bitmapBlock));
    fsOut.Write(bitmapITable,sizeof(bitmapITable));
    fsOut.free;
end;

procedure readSuperBlock;
begin
    fsOut := openFile(databaseName);
    fsOut.Read(databaseName, 20);
    fsOut.Read(databaseSize,sizeof(databaseSize));
    fsOut.Read(cantBlocks,sizeof(cantBlocks));
    fsOut.Read(freeBlocks,sizeof(freeBlocks));
    fsOut.Read(cantITables,sizeof(cantITables));
    fsOut.Read(freeITables,sizeof(freeITables));
    fsOut.Read(bitmapBlock,sizeof(bitmapBlock));
    fsOut.Read(bitmapITable,sizeof(bitmapITable));
    fsOut.free;
end;

procedure printSuperBlock;
begin
    //prints
    write('name: ');
    writeln(databaseName);
    write('size: ');
    writeln(databaseSize);
    write('cantBlocks: ');
    writeln(cantBlocks);
    write('freeBlocks: ');
    writeln(freeBlocks);
    write('cantITables: ');
    writeln(cantITables);
    write('freeITables: ');
    writeln(freeITables);
    write('bitmapBlock: ');
    writeln(bitmapBlock);
    write('bitmapITable: ');
    writeln(bitmapITable);
end;