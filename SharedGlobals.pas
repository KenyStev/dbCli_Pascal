unit SharedGlobals;
    
interface
var //Metadata Database
    databaseNameSize : Longword;     // 4 bytes
    databaseName : string;           //20 bytes
    databaseSize : Longword;         // 4 bytes
    cantBlocks : Longword;           // 4 bytes
    freeBlocks : Longword;           // 4 bytes
    cantITables : Longword;          // 4 bytes
    freeItables : Longword;          // 4 bytes
    bitmapBlock : Longword;          // 4 bytes
    bitmapITable : Longword;         // 4 bytes
    cantTables : Longword;           // 4 bytes
    reserverForITables : Longword;  

var //Metadata ITables
    freeEntry : Byte;               // 1 bytes
    tableNameSize : Longword;       // 4 bytes
    tableName : string;             //20 bytes
    firstBlock : Longword;          // 4 bytes
    lastBlock : Longword;           // 4 bytes
    cantRegisters : Longword;       // 4 bytes
    freeSpaceOfLastBlock : Longword;// 4 bytes
    currentTable : Longword;
    
implementation
    
end.