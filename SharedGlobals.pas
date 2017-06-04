unit SharedGlobals;
    
interface
var //Metadata Database
    databaseNameSize : integer;     // 4 bytes
    databaseName : string;          //20 bytes
    databaseSize : Longword;        // 4 bytes
    cantBlocks : integer;           // 4 bytes
    freeBlocks : integer;           // 4 bytes
    cantITables : integer;          // 4 bytes
    freeItables : integer;          // 4 bytes
    bitmapBlock : integer;          // 4 bytes
    bitmapITable : integer;         // 4 bytes
    cantTables : integer;           // 4 bytes
    reserverForITables : Longword;  

var //Metadata ITables
    freeEntry : Byte;               // 1 bytes
    tableNameSize : integer;        // 4 bytes
    tableName : string;             //20 bytes
    firstBlock : Longword;          // 4 bytes
    lastBlock : Longword;           // 4 bytes
    cantRegisters : Longword;       // 4 bytes
    currentTable : Longword;
    
implementation
    
end.