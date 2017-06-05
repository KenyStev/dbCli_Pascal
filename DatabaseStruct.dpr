const
    C_TOTAL_SUPERBLOCK = 20+4*9;
    C_TOTAL_ITABLES = 21+4*5;
        
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
begin
    fsOut := openFile(databaseName);
    fsOut.Write(databaseNameSize,sizeof(longword));
    fsOut.WriteBuffer(pointer(databaseName)^, databaseNameSize);
    fsOut.Seek(20,soBeginning);
    fsOut.Write(databaseSize,sizeof(longword));
    fsOut.Write(cantBlocks,sizeof(longword));
    fsOut.Write(freeBlocks,sizeof(longword));
    fsOut.Write(cantITables,sizeof(longword));
    fsOut.Write(freeITables,sizeof(longword));
    fsOut.Write(bitmapBlock,sizeof(longword));
    fsOut.Write(bitmapITable,sizeof(longword));
    fsOut.Write(cantTables,sizeof(longword));
    fsOut.free;
end;

procedure readSuperBlock;
begin
    fsOut := openFile(databaseName);
    fsOut.Read(databaseNameSize,sizeof(longword));
    SetLength(databaseName,databaseNameSize);
    fsOut.ReadBuffer(pointer(databaseName)^, databaseNameSize);
    fsOut.Seek(20,soBeginning);
    fsOut.Read(databaseSize,sizeof(longword));
    fsOut.Read(cantBlocks,sizeof(longword));
    fsOut.Read(freeBlocks,sizeof(longword));
    fsOut.Read(cantITables,sizeof(longword));
    fsOut.Read(freeITables,sizeof(longword));
    fsOut.Read(bitmapBlock,sizeof(longword));
    fsOut.Read(bitmapITable,sizeof(longword));
    fsOut.Read(cantTables,sizeof(longword));
    fsOut.free;
end;