unit uLayouts;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects, FMX.Effects, FMX.Ani, FMX.Layouts, FMX.Media;

type
  TLayouts = class(TForm)
    PainelAbertura: TRectangle;
    ImgFac: TImage;
    LayoutAbertura: TLayout;
    ImgDif: TImage;
    ImgMed: TImage;
    Layout1: TLayout;
    QuadroDificuldade: TRectangle;
    BlurEffect2: TBlurEffect;
    NomeJogo: TImage;
    Opcoes: TRectangle;
    GlowEffect1: TGlowEffect;
    procedure ImgFacClick(Sender: TObject);
  private
    FOnDificuldade : TNotifyEvent;
    FNivel         : Integer;
    FForm          : TForm;
    { Private declarations }
  public
    { Public declarations }
    Procedure MostraEscolheNivel;
    Property OnDificuldade : TNotifyEvent Read FOnDificuldade Write FOnDificuldade;
    Property Nivel         : Integer      Read FNivel         Write FNivel;
    Property Form          : TForm        Read FForm          Write FForm;
  end;

var
  Layouts: TLayouts;

implementation

Uses
   uAudio,
   uBlocos;

{$R *.fmx}

procedure TLayouts.MostraEscolheNivel;
begin
Audio.InicializaAudioTelaInicial;
TThread.CreateAnonymousThread(
   Procedure
   Begin
   Sleep(500);
   Audio.PlaySomTelaInicio;
   End).Start;
ImgFac.Opacity := 1;
ImgMed.Opacity := 1;
ImgDif.Opacity := 1;
ImgFac.Position.X := 12; ImgFac.Position.Y :=  14; ImgFac.Width := 232; ImgFac.Height := 50;
ImgMed.Position.X := 12; ImgMed.Position.Y :=  64; ImgMed.Width := 232; ImgMed.Height := 50;
ImgDif.Position.X := 12; ImgDif.Position.Y := 114; ImgDif.Width := 232; ImgDif.Height := 50;
LayoutAbertura.Opacity := 1;
LayoutAbertura.Visible := True;
LayoutAbertura.Align   := TAlignLayout.Center;
LayoutAbertura.Parent  := Owner as TFmxObject;
LayoutAbertura.BringToFront;
//TAnimator.AnimateFloat(LayoutAbertura, 'Opacity', 1,  0.4);
end;

procedure TLayouts.ImgFacClick(Sender: TObject);
Var
   X, Y : Single;
   W, H : Single;
begin
Audio.PlaySomEscolheNivel;
X := ImgMed.Position.X;
Y := ImgMed.Position.Y;
W := ImgMed.Width;
H := ImgMed.Height;
(Sender As TImage).Align := TAlignLayout.None;
TAnimator.AnimateFloat((Sender As TImage), 'Position.X', X-600,  0.6);
TAnimator.AnimateFloat((Sender As TImage), 'Position.Y', Y-600,  0.6);
TAnimator.AnimateFloat((Sender As TImage), 'Width',      W+1200, 0.6);
TAnimator.AnimateFloat((Sender As TImage), 'Height',     H+1200, 0.6);
TAnimator.AnimateFloat(LayoutAbertura,     'Opacity',    0,      0.6);
TThread.CreateAnonymousThread(
   Procedure
   Begin
   Sleep(200);
   TThread.Synchronize(Nil, Procedure Begin TAnimator.AnimateFloat((Sender As TImage), 'Opacity',    0,      0.4); End);
   Sleep(1000);
   TThread.Synchronize(Nil,
      Procedure
      Begin
      LayoutAbertura.Parent  := Nil;
      LayoutAbertura.Visible := False;
      LayoutAbertura.Opacity := 1;
      ImgFac        .Opacity := 1;
      ImgMed        .Opacity := 1;
      ImgDif        .Opacity := 1;
      FNivel                 := (Sender As TImage).Tag;
      if Assigned(OnDificuldade) then OnDificuldade(Self);
      End);
   End).Start;
end;

end.
