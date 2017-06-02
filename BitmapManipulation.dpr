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
end;

procedure initBitmapBlocks;
var
    i : longword;
begin
    fsOut := openFile(databaseName);

    bitmapLength := Ceil(cantBlocks/8);
    SetLength(bitmap,bitmapLength);
    fsOut.Seek(bitmapBlock,soBeginning);
    fsOut.Read(bitmap[0],bitmapLength);

    fsOut.Seek(bitmapBlock,soBeginning);
    usedBlocks := cantBlocks - freeBlocks;
    
    for i := 0 to usedBlocks do
    begin
        SetUsedBlock(i);
    end;

    fsOut.Write(bitmap[0],bitmapLength);
    fsOut.free;
end;