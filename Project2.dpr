program dbCli_Pascal;

uses
  Classes, Sysutils;
 
const
  C_FNAME = 'binarydata.bin';
 
var
  fsOut    : TFileStream;
  ChrBuffer: array[0..2] of char;
 
begin
  // Set up some random data that will get stored
  ChrBuffer[0] := 'A';
  ChrBuffer[1] := 'B';
  ChrBuffer[2] := 'C';
 
  // Catch errors in case the file cannot be created
  try
    // Create the file stream instance, write to it and free it to prevent memory leaks
    fsOut := TFileStream.Create( C_FNAME, fmCreate);
    fsOut.Write(ChrBuffer, sizeof(ChrBuffer));
    fsOut.Free;
 
  // Handle errors
  except
    on E:Exception do
      writeln('File ', C_FNAME, ' could not be created because: ', E.Message);
  end;
 
  // Give feedback and wait for key press
  writeln('File ', C_FNAME, ' created if all went ok. Press Enter to stop.');
  readln;
end.
