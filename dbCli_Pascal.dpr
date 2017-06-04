program dbCli_Pascal;

{$APPTYPE CONSOLE}
uses
  Classes, Sysutils, MATH, SharedGlobals;

{$I 'dbManagerFunc.dpr'}

procedure MainMenu;
var
  option : integer;
begin
  option := 0;
  repeat
    writeln(C_CREATE_DB_OPTION_MSG);
    writeln(C_DROP_DB_OPTION_MSG);
    writeln(C_CONNECT_DB_OPTION_MSG);
    writeln('-1. Exit');
    write('select option: ');
    readln(option);
    try
      case option of
        1: CreateDatabase;
        2: DropDatabase;
        3: UseDatabase;
        -1: writeln('bye bye!');
      else writeln('Not valid option.');
      end;
    except
      on E:Exception do
        writeln('Database could not be created because: ', E.Message);
      end;
  until option = -1;
end;

//Main
begin
  sizeOfBlock := 4*1024;
  MainMenu;
  readln;
end.
