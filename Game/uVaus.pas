unit uVaus;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects, FMX.Effects, FMX.Utils,
  FMX.Ani, FMX.Layouts, FMX.Media, FMX.Surfaces, System.Math.Vectors;

type
   TTipoVaus    = (Normal, Laser);
   TTamanhoVaus = (Paqueno, Medio, Grande);
   TVaus = class(TControl)
      private
         FCentro        : TBitmap;
         FNormal        : TBitmap;
         FLaser         : TBitmap;
         FNormalDir     : TBitmap;
         FLaserDir      : TBitmap;
         FBmp           : TBitmap;
         FBmpDir        : TBitmap;
         FTipoVaus      : TTipoVaus;
         FTamanhoVaus   : TTamanhoVaus;
         FOffSet        : Single;
         FVivo          : Boolean;
         FCampo         : Boolean;
         procedure SetTamanhoVaus(const Value: TTamanhoVaus);
         procedure SetTipoVaus   (const Value: TTipoVaus);
         procedure SetOffSet     (const Value: Single);
         function  GetPosX        : Integer;
         function  GetXCenter     : Single;
         function  GetComprimento : Integer;
      protected
         procedure Paint; override;
      public
         constructor Create(AOwner: TComponent); Override;
         Procedure Inicia;
         Procedure Morre;
         Procedure Lancar;
         property OffSet       : Single       Read FOffSet         write SetOffSet;
         property Tipo         : TTipoVaus    Read FTipoVaus       Write SetTipoVaus;
         Property Tamanho      : TTamanhoVaus Read FTamanhoVaus    Write SetTamanhoVaus;
         Property Comprimento  : Integer      Read GetComprimento;
         Property PosX         : Integer      Read GetPosX;
         Property XCenter      : Single       Read GetXCenter;
         Property Vivo         : Boolean      Read FVivo           Write FVivo;
         Property CampoDeForca : Boolean      Read FCampo          Write FCampo;
      end;


implementation

Uses
   uResource,
   uAudio;

{ TVaus }

Constructor TVaus.Create(AOwner: TComponent);
begin
inherited Create(AOwner);
Parent         := AOwner As TFmxObject;
FCentro        := TResource.GetBitmap('VausCenter');
FNormal        := TResource.GetBitmap('VausNormal');
FLaser         := TResource.GetBitmap('VausLaser');
FCampo         := False;
{$IFDEF MSWINDOWS}
FNormalDir     := TBitmap.Create; FNormalDir.Assign(FNormal); FNormalDir.FlipHorizontal;
FLaserDir      := TBitmap.Create; FLaserDir .Assign(FLaser);  FLaserDir .FlipHorizontal;
{$ENDIF}
FOffSet        := 0;
FTamanhoVaus   := TTamanhoVaus.Medio;
Tipo           := TTipoVaus.Normal;
Width          := 120;
Height         := 24;
end;

function TVaus.GetComprimento: Integer;
begin
Result := 0;
case FTamanhoVaus of
   Paqueno : Result :=  78;
   Medio   : Result :=  88;
   Grande  : Result := 118;
   end;
end;

function TVaus.GetPosX: Integer;
begin
Result := Trunc(Self.Position.X + (Width - GetComprimento)/2);
end;

function TVaus.GetXCenter: Single;
begin
Result := Position.X + Width/2;
end;

procedure TVaus.Inicia;
begin
Lancar;
FCampo := False;
end;

procedure TVaus.Lancar;
begin
FVivo  := True;
Fcampo := False;
end;

procedure TVaus.Morre;
begin
FVivo  := False;
FCampo := False;
TThread.Synchronize(Nil, Procedure begin TAnimator.AnimateFloat(Self, 'Opacity', 0, 1) End);
end;

procedure TVaus.Paint;
var
   Centro : Single;
begin
inherited;
Centro := Width /2;
Canvas.DrawBitmap(FCentro, TRectF.Create(0, 0, FCentro .Width-1, FCentro .Height-1), TRectF.Create(0,0, Self.Width-1, Self.Height-1), AbsoluteOpacity);
Canvas.DrawBitmap(FBmp,    TRectF.Create(0, 0, 44, 23), TRectF.Create(Centro-FOffset-44, 0, Centro-FOffSet,    Height-1), AbsoluteOpacity);
{$IFDEF  MSWINDOWS}
Canvas.DrawBitmap(FBmpDir, TRectF.Create(0, 0, 44, 23), TRectF.Create(Centro+FOffset,    0, Centro+FOffSet+44, Height-1), AbsoluteOpacity);  // Windows não inverte o bitmap ao inverter Left e right
{$ELSE}
Canvas.DrawBitmap(FBmp,    TRectF.Create(0, 0, 44, 23), TRectF.Create(Centro+FOffset+44, 0, Centro+FOffSet,    Height-1), AbsoluteOpacity);
{$ENDIF}
//Self.DrawDesignBorder;
end;

procedure TVaus.SetOffSet(const Value: Single);
begin
FOffSet := Value;
Repaint;
end;

procedure TVaus.SetTamanhoVaus(const Value: TTamanhoVaus);
begin
if Value <> FTamanhoVaus then
   Begin
   FTamanhoVaus := Value;
   case Value of
      Paqueno : TAnimator.AnimateFloat(Self, 'OffSet', -5, 0.1);
      Medio   : TAnimator.AnimateFloat(Self, 'OffSet',  0, 0.1);
      Grande  : TAnimator.AnimateFloat(Self, 'OffSet', 15, 0.1);
      end;
   end;
end;

procedure TVaus.SetTipoVaus(const Value: TTipoVaus);
begin
FTipoVaus := Value;
case Value of
   Normal : Begin FBmp := FNormal; FBmpDir := FNormalDir; End;
   Laser  : Begin FBmp := FLaser;  FBmpDir := FLaserDir;  End;
   end;
Repaint;
end;

end.
