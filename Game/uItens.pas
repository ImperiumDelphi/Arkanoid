unit uItens;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects, FMX.Controls.Presentation, FMX.StdCtrls,
  FMX.Ani, FMX.Layouts, FMX.InertialMovement, FMX.ExtCtrls,

  uAudio,
  uVaus,
  uResource;

type

  TTipoItem = (tiSemItem, tiMaisVida, tiGrande, TiPequeno, tiCampoForca, tiMaisBolas, tiTiro,
               tiTiraVida, tiSuperBola);
  TItem = Class(TRectangle)
     private
        Class Var FRebatedor   : TVaus;
        Class Var FPause       : Boolean;
        Class Var FOnPegouItem : TNotifyEvent;
        Class Procedure Dispose(aItem : TItem);
     Public
        Class Property Rebatedor   : TVaus        Read FRebatedor   Write FRebatedor;
        Class Property Pause       : Boolean      Read FPause       Write FPause;
        Class Property OnPegouItem : TNotifyEvent Read FOnPegouItem write FOnPegouItem;
     Private
        FAni         : TBitmapListAnimation;
        FLancada     : Boolean;
        FLancamentoX : Single;
        FLancamentoY : Single;
        FTipo        : TTipoItem;
     protected
        procedure DoPegouItem; Virtual;
     public
        constructor Create(aOwner : TComponent; aTipo : TTipoItem); Reintroduce;
        procedure Lancar(X,Y : Single);
        Property Tipo        : TTipoItem    Read FTipo        Write FTipo;
        Property Lancada     : Boolean      Read FLancada     Write FLancada;
     end;



implementation

{ TItem }

class procedure TItem.Dispose(aItem: TItem);
begin
TThread.Queue(Nil,
   Procedure
   Begin
   aItem.Free;
   End);
end;

constructor TItem.Create(aOwner: TComponent; aTipo : TTipoItem);
Var
   ResName : String;
begin
inherited Create(aOwner);
Width       := 44;
Height      := 22;
Visible     := False;
Parent      := FRebatedor.Parent;
FLancada    := False;
FTipo       := aTipo;
Stroke.Kind := TBrushKind.None;
Fill  .Kind := TBrushKind.Bitmap;
Fill.Bitmap.WrapMode   := TWrapMode.Tile;
FAni                   := TBitmapListAnimation.Create(Self);
FAni.Parent            := Self;
FAni.PropertyName      := 'Fill.Bitmap.Bitmap';
FAni.AnimationCount    := 8;
FAni.AnimationRowCount := 1;
FAni.Loop              := True;
FAni.Duration          := 0.8;
case aTipo of
   tiMaisVida   : ResName := 'V';
   tiGrande     : ResName := 'G';
   tiPequeno    : ResName := 'P';
   tiCampoForca : ResName := 'C';
   tiMaisBolas  : ResName := 'B';
   tiTiro       : ResName := 'T';
   tiTiraVida   : ResName := 'M';
   tiSuperBola  : ResName := 'S';
   end;
FAni.AnimationBitmap := TResource.GetBitmap(ResName);
TThread.CreateAnonymousThread(
   procedure
   var
      X, Y   : Single;
      Pegou  : Boolean;
   begin
   repeat Sleep(20); Until FLancada;
   TThread.Synchronize(TThread.CurrentThread,
      Procedure
      Begin
      Self.Visible    := True;
      Self.Position.X := FLancamentoX;
      Self.Position.Y := FLancamentoY;
      Self.BringToFront;
      FAni.Enabled    := True;
      FAni.Start;
      End);
   X     := Self.Position.X;
   Y     := Self.Position.Y;
   repeat
      While FPause Do Sleep(20);
      Sleep(20);
      Y     := Y + 2;
      Pegou := Self.AbsoluteRect.IntersectsWith(FRebatedor.AbsoluteRect);
      TThread.Synchronize(Nil,
         procedure
         begin
         Self.Position.X := X;
         Self.Position.Y := Y;
         end);
      Until (Y > FRebatedor.Position.Y+FRebatedor.Height) Or Pegou Or Not(Rebatedor.Vivo);
   FLancada := False;
   If Pegou And FRebatedor.Vivo Then
      begin
      DoPegouItem;
      End;
   TThread.Queue(Nil,
      procedure
      begin
      FAni.Stop;
      FAni.Enabled    := False;
      Self.Visible    := False;
      Dispose(Self);
      End);
   End).Start;
end;

procedure TItem.DoPegouItem;
begin
Log.d('Do PegouItem');
Audio.PlayPegouItem;
TThread.Queue(Nil,
   procedure
   begin
   if Assigned(OnPegouItem) then OnPegouItem(Self);
   End);
end;

procedure TItem.Lancar(X, Y: Single);
begin
FLancamentoX := X;
FLancamentoY := Y;
Lancada      := True;
end;

end.
