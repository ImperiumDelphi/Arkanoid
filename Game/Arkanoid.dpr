program Arkanoid;

{$R 'ImagensEAudios.res' 'ImagensEAudios.rc'}

uses
  System.StartUpCopy,
  FMX.Forms,
  uArkanoid in 'uArkanoid.pas' {Arkanoid_Main},
  uBlocos in 'uBlocos.pas',
  uBola in 'uBola.pas',
  uFases in 'uFases.pas',
  uItens in 'uItens.pas',
  uLayouts in 'uLayouts.pas' {Layouts},
  uMeteoro in 'uMeteoro.pas',
  uPlacar in 'uPlacar.pas',
  uResource in 'uResource.pas',
  uVaus in 'uVaus.pas',
  uAudio in 'uAudio.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TArkanoid_Main, Arkanoid_Main);
  Application.Run;
end.
