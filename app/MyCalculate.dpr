program MyCalculate;

uses
  Forms,
  SysUtils,
  CalculatorClass in 'CalculatorClass.pas',
  CalculateForm in 'CalculateForm.pas' {Form2},
  StateClass in 'StateClass.pas';

{$R *.res}

begin
//  try
//    { TODO -oUser -cConsole Main : Insert code here }
//  except
//    on E: Exception do
//      Writeln(E.ClassName, ': ', E.Message);
//  end;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
