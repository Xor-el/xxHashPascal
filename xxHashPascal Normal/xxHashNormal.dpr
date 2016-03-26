program xxHashNormal;

uses
  Vcl.Forms,
  xxHash32 in 'src\Main\xxHash32.pas',
  xxHash64 in 'src\Main\xxHash64.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Run;

end.
