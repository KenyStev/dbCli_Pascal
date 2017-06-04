var
    bitmap : array of Byte;
    bitmapLength : longword;
    usedBlocks : longword;

//get if a particular bit is 1
function GetBlock(block: longword): Boolean;
var
    cluster : longword;
    offset : longword;
begin
    cluster := Floor(block/8);
    offset := Floor(block mod 8);
    Result := (bitmap[cluster] and (1 shl offset)) <> 0;
end;
 
//set a particular bit as 1
procedure SetUsedBlock(block: longword);
var
    cluster : longword;
    offset : longword;
begin
    cluster := Floor(block/8);
    offset := Floor(block mod 8);
    bitmap[cluster] := bitmap[cluster] or (1 shl offset);
    freeBlocks := freeBlocks - 1;
end;
 
//set a particular bit as 0
procedure ClearUsedBlock(block: longword);
var
    cluster : longword;
    offset : longword;
begin
    cluster := Floor(block/8);
    offset := Floor(block mod 8);
    bitmap[cluster] := bitmap[cluster] and not (1 shl offset);
    freeBlocks := freeBlocks + 1;
end;

function GetNextFreeBlock : longword;
var
    i : longword;
begin
    Result := 0;
    for i := 0 to cantBlocks do
    begin
        if not GetBlock(i) then
        begin
            Result := i;
            exit;
        end;
    end;
end;

procedure readBitmapBlocks;
begin
    writeln('readBitmapBlocks: ',databaseName);
    writeln('readBitmapBlocks Length: ',Length(databaseName));
    fsOut := openFile(databaseName);
    bitmapLength := Ceil(cantBlocks/8);
    SetLength(bitmap,bitmapLength);
    fsOut.Seek(bitmapBlock,soBeginning);
    fsOut.Read(bitmap[0],bitmapLength);
    fsOut.free;
end;

procedure saveBitmapBlocks;
begin
    writeln('saveBitmapBlocks: ',databaseName);
    writeln('saveBitmapBlocks Length: ',Length(databaseName));
    fsOut := openFile(databaseName);
    fsOut.Seek(bitmapBlock,soBeginning);
    fsOut.Write(bitmap[0],bitmapLength);
    fsOut.free;
end;

procedure initBitmapBlocks;
var
    i : longword;
begin
    readBitmapBlocks;
    usedBlocks := cantBlocks - freeBlocks;
    for i := 0 to usedBlocks do
    begin
        SetUsedBlock(i);
    end;
    saveBitmapBlocks;
end;