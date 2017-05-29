program ProjectGaussSeidl;

uses
  Vcl.Forms,
  GaussSeidl in 'GaussSeidl.pas' {FormGUI},
  IntervalArithmetic32and64 in 'IntervalArithmetic32and64.pas',
  GaussSeidlMetoda in 'GaussSeidlMetoda.pas',
  OwnType in 'OwnType.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormGUI, FormGUI);
  Application.Run;
end.
