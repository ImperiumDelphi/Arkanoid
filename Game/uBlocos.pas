unit uBlocos;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects, FMX.Controls.Presentation, FMX.StdCtrls,
  FMX.Ani, FMX.Layouts, FMX.InertialMovement, FMX.ExtCtrls, FMX.Media,

  uItens;

Type
   TTipoBloco    = (SemBloco,     BlocoAzul,     BlocoVermelho,    BlocoVerde,       BlocoAmarelo, BlocoLaranja,
                    BlocoBranco,  JoiaAzul,      JoiaVermelha,     JoiaVerde,        JoiaAmarela,  JoiaLaranja,
                    JoiaBranca,   EspecialRoxo,  EspecialAzul,     EspecialVermelho, EspecialRosa, EspecialCinza);

   TBloco        = Class(TRectangle)
      Type
         TMatrizBlocos = Array[0..6, 0..11] of TBloco;
      Private
         Class Var FMatrizBlocos : TMatrizBlocos;
         Class Var FWidth        : Single;
         Class Var FHeight       : Single;
      Public
         Class Procedure CriaBloco(X, Y, aVida, aPontos : Integer; aTipoBloco : TTipoBloco; aTipoItem : TTipoItem);
         Class Function  EstaVivo(X, Y : Integer) : Boolean;
         Class Procedure MostraMatrizBlocos(Local : TFMXObject);
         Class Procedure Clear;
         Class Property  MatrizBlocos    : TMatrizBlocos Read FMatrizBlocos Write FMatrizBlocos;
         Class Property  BlocoWidth      : Single        Read FWidth        Write FWidth;
         Class Property  BlocoHeight     : Single        Read FHeight       Write FHeight;
      Private
         FVida     : Integer;
         FPontos   : Integer;
         FVivo     : Boolean;
         FTipo     : TTipoBloco;
         FMorre    : TNotifyEvent;
         FItem     : TItem;
         Constructor Create(aOwner : TComponent; aVida, aPontos : Integer; aTipoBloco : TTipoBloco; aTipoItem : TTipoItem);  Reintroduce;
      Protected
         Procedure DoMorre; Virtual;
      Public
         Procedure Morre;
         Property OnMorre : TNotifyEvent  Read FMorre   Write FMorre;
         Property Vida    : Integer       Read FVida    Write FVida;
         Property Pontos  : Integer       Read FPontos  Write FPontos;
         Property Tipo    : TTipoBloco    Read FTipo    Write FTipo;
         Property Vivo    : Boolean       Read FVivo    Write FVivo;
      End;

implementation

Uses
   uResource,
   uAudio,
   uBola;

{ TBloco }

constructor TBloco.Create(aOwner: TComponent; aVida, aPontos: Integer; aTipoBloco : TTipoBloco; aTipoItem : TTipoItem);

   Function CriaItem(Tipo : TTipoItem) : TItem;
   Begin
   Result := Nil;
   if Tipo <> TTipoItem.tiSemItem then
      Begin
      Result := TItem.Create(aOwner, Tipo);
      End;
   End;

begin
Log.d('Create bloco');
Inherited Create(aOwner);
Visible := False;
case aTipoBloco of
   BlocoAzul        : Fill.Bitmap.Bitmap := TResource.GetBitmap('BlocoAzul');
   BlocoVermelho    : Fill.Bitmap.Bitmap := TResource.GetBitmap('BlocoVermelho');
   BlocoVerde       : Fill.Bitmap.Bitmap := TResource.GetBitmap('BlocoVerde');
   BlocoAmarelo     : Fill.Bitmap.Bitmap := TResource.GetBitmap('BlocoAmarelo');
   BlocoLaranja     : Fill.Bitmap.Bitmap := TResource.GetBitmap('BlocoLaranja');
   BlocoBranco      : Fill.Bitmap.Bitmap := TResource.GetBitmap('BlocoBranco');
   JoiaAzul         : Fill.Bitmap.Bitmap := TResource.GetBitmap('JoiaAzul');
   JoiaVermelha     : Fill.Bitmap.Bitmap := TResource.GetBitmap('JoiaVermelha');
   JoiaVerde        : Fill.Bitmap.Bitmap := TResource.GetBitmap('JoiaVerde');
   JoiaAmarela      : Fill.Bitmap.Bitmap := TResource.GetBitmap('JoiaAmarela');
   JoiaLaranja      : Fill.Bitmap.Bitmap := TResource.GetBitmap('JoiaLaranja');
   JoiaBranca       : Fill.Bitmap.Bitmap := TResource.GetBitmap('JoiaBranca');
   EspecialRoxo     : Fill.Bitmap.Bitmap := TResource.GetBitmap('EspecialRoxo');
   EspecialAzul     : Fill.Bitmap.Bitmap := TResource.GetBitmap('EspecialAzul');
   EspecialVermelho : Fill.Bitmap.Bitmap := TResource.GetBitmap('EspecialVermelho');
   EspecialRosa     : Fill.Bitmap.Bitmap := TResource.GetBitmap('EspecialRosa');
   EspecialCinza    : Fill.Bitmap.Bitmap := TResource.GetBitmap('EspecialCinza');
   end;
FItem                     := CriaItem(aTipoItem);
FTipo                     := aTipoBloco;
FVivo                     := False;
FPontos                   := aPontos;
FVida                     := aVida;
if FVida < 1 then FVida   := 1;
Self.Fill.Bitmap.WrapMode := TWrapMode.TileStretch;
Self.Fill.Kind            := TBrushKind.Bitmap;
Self.Stroke.Kind          := TBrushKind.None;
end;

procedure TBloco.Morre;
Begin
case FTipo of
   BlocoAzul        : Audio.PlayBlocoNormal;
   BlocoVermelho    : Audio.PlayBlocoNormal;
   BlocoVerde       : Audio.PlayBlocoNormal;
   BlocoAmarelo     : Audio.PlayBlocoNormal;
   BlocoLaranja     : Audio.PlayBlocoNormal;
   BlocoBranco      : Audio.PlayBlocoNormal;
   JoiaAzul         : Audio.PlayBlocoEspecial;
   JoiaVermelha     : Audio.PlayBlocoEspecial;
   JoiaVerde        : Audio.PlayBlocoEspecial;
   JoiaAmarela      : Audio.PlayBlocoEspecial;
   JoiaLaranja      : Audio.PlayBlocoEspecial;
   JoiaBranca       : Audio.PlayBlocoEspecial;
   EspecialRoxo     : Audio.PlayBlocoEspecial;
   EspecialAzul     : Audio.PlayBlocoEspecial;
   EspecialVermelho : Audio.PlayBlocoEspecial;
   EspecialRosa     : Audio.PlayBlocoEspecial;
   EspecialCinza    : Audio.PlayBlocoNormal;
   end;
Dec(FVida);
if FVida < 1 then
   Begin
   Self.FVivo := False;
   TThread.Queue(Nil,
      Procedure
      Begin
      TAnimator.AnimateFloat(Self, 'Width',      0,                       0.5);
      TAnimator.AnimateFloat(Self, 'Height',     0,                       0.5);
      TAnimator.AnimateFloat(Self, 'Position.X', Position.X + Width *0.5, 0.5);
      TAnimator.AnimateFloat(Self, 'Position.Y', Position.Y + Height*0.5, 0.5);
      End);
   if FItem <> Nil then
      Begin
      FItem.Lancar(Self.Position.X +(Self.Width - FItem.Width)/2 , Self.Position.Y);
      End;
   End;
end;

procedure TBloco.DoMorre;
begin
if Assigned(OnMorre) then OnMorre(Self);
end;

class procedure TBloco.MostraMatrizBlocos(Local : TFMXObject);
Var
   X, Y : Integer;
begin
if Local Is TForm then
   FWidth := (Local As TForm)   .ClientWidth / 9
Else
   FWidth := (Local As TControl).Width       / 9;
FHeight   := FWidth / 2;
for x := 0 to 6 do
   for Y := 0 to 11 do
      if Assigned(MatrizBlocos[X, Y]) then
         Begin
         if Local Is TForm then
            Begin
            MatrizBlocos[X, Y].Width := (Local As TForm).ClientWidth / 9;
            End
         Else
            Begin
            MatrizBlocos[X, Y].Width := (Local as TControl).Width / 9;
            End;
         MatrizBlocos[X, Y].Width      := FWidth;
         MatrizBlocos[X, Y].Height     := FHeight;
         MatrizBlocos[X, Y].Parent     := Local;
         MatrizBlocos[X, Y].Height     := MatrizBlocos[X, Y].Width / 2;
         MatrizBlocos[X, Y].Position.X := (X+1)  * FWidth;
         MatrizBlocos[X, Y].Position.Y := 110 + Y * FHeight;
         MatrizBlocos[X, Y].Visible    := True;
         MatrizBlocos[X, Y].FVivo      := True;
         //MatrizBlocos[X, Y].BringToFront;
         End;
end;

class procedure TBloco.CriaBloco(X, Y, aVida, aPontos: Integer; aTipoBloco : TTipoBloco; aTipoItem : TTipoItem);
begin
If ATipoBloco <> TTipoBloco.SemBloco Then FMatrizBlocos[X, Y] := Self.Create(Nil, aVida, aPontos, aTipoBloco, aTipoItem);
end;

Class function TBloco.EstaVivo(X, Y : Integer): Boolean;
begin
Result := (MatrizBlocos[X, Y] <> Nil) And MatrizBlocos[X, Y].Vivo;
end;

class procedure TBloco.Clear;
Var
   X, Y : Integer;
Begin
for x := 0 to 6 do
   for Y := 0 to 11 do
      If MatrizBlocos[X, Y] <> Nil then
         Begin
         FMatrizBlocos[X, Y].Free;
         FMatrizBlocos[X, Y] := Nil;
         End;
end;

end.
