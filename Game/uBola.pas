unit uBola;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects, FMX.Controls.Presentation, FMX.StdCtrls,
  FMX.Ani, FMX.Layouts, FMX.InertialMovement, FMX.ExtCtrls, FMX.Media, FMX.Effects,

  uBlocos,
  uVaus,
  uResource;

Type
   TDirecao = (Cima, Direita, Baixo, Esquerda);
   TTipoBola = (tbJogo, tbExtra, tbLaser);

   [ComponentPlatformsAttribute (pidWin32 or pidWin64 or pidOSX32 or pidiOSDevice32 or pidiOSDevice64 or pidAndroidArm32)]
   TBola = Class(TImage)
      Private
         FMorreu      : TNotifyEvent;
         FMatouTodos  : TNotifyEvent;
         FParouJogo   : TNotifyEvent;
         FMatouBloco  : TNotifyEvent;
         FTipo        : TTipoBola;
         FDirH        : TDirecao;
         FDirV        : TDirecao;
         FX, FY       : Single;
         FVelX        : Single;
         FVelY        : Single;
         FCentroB     : Single;
         FCentroV     : Single;
         FTempoBola   : Cardinal;
         FNivel       : Integer;
         FPontos      : Integer;
         FVidas       : Integer;
         FPontosRec   : Integer;
         FGlow        : TGlowEffect;
         FCorrendo    : Boolean;
         FTodosMortos : Boolean;
         FSuper       : Boolean;
         FAnimando    : Boolean;
         procedure AnimaColisao;
         procedure SetSuperBola(const Value: Boolean);
         procedure MovimentaBola;
         Function HouveColisao : Boolean;
         Class Var FEliminar : Boolean;
         Class Var FForm     : TForm;
         Class var FVaus     : TVaus;
         Class Var FPause    : Boolean;
         Class Procedure Dispose(aBola : TBola);
      Public
         Class Property EliminarExtras : Boolean      Read FEliminar    Write FEliminar;
         Class Property Pause          : Boolean      Read FPause       Write FPause;
         Class Property Vaus           : TVaus        Read FVaus        Write FVaus;
         Class Property Form           : TForm        Read FForm        Write FForm;
      Protected
         Procedure DoMorreu; Virtual;
         Procedure DoTerminouJogo; Virtual;
         procedure DoMatouBloco; Virtual;
         procedure DoMatouTodos; Virtual;
      Public
         Constructor Create(aTipo : TTipoBola); Reintroduce;
         Procedure PosicionaBola;
         Procedure LancarBola;
         Procedure PararBola;
         Property OnMorreu       : TNotifyEvent Read FMorreu      Write FMorreu;
         Property OnMatouBloco   : TNotifyEvent Read FMatouBloco  Write FMatouBloco;
         Property OnTerminouJogo : TNotifyEvent Read FParouJogo   Write FParouJogo;
         Property OnMatouTodos   : TNotifyEvent Read FMatouTodos  Write FMatouTodos;
         Property Correndo       : Boolean      Read FCorrendo;
         Property DirecaoH       : TDirecao     Read FDirH        Write FDirH;
         Property DirecaoV       : TDirecao     Read FDirV        Write FDirV;
         Property VelH           : Single       Read FVelX        Write FVelX;
         Property VelV           : Single       Read FVelY        Write FVelY;
         Property Nivel          : Integer      Read FNivel       Write FNivel;
         Property Pontos         : Integer      Read FPontos      Write FPontos;
         Property Vidas          : Integer      Read FVidas       Write FVidas;
         Property SuperBola      : Boolean      Read FSuper       Write SetSuperBola;
      End;

implementation

Uses
   uAudio;

{ TBola }

class procedure TBola.Dispose(aBola : TBola);
begin
aBola.Visible := False;
TThread.CreateAnonymousThread(
   Procedure
   Begin
   Sleep(200);
   TThread.Queue(Nil,
      Procedure
      Begin
      aBola.Free;
      End);
   End).Start;
end;

procedure TBola.DoMorreu;
begin
TThread.Queue(Nil,
   Procedure
   Begin
   Log.d('Do Morreu');
   if Assigned(OnMorreu) then OnMorreu(Self);
   End);
end;

procedure TBola.DoTerminouJogo;
begin
TThread.Queue(Nil,
   Procedure
   Begin
   Log.d('Do TerminouJogo');
   if Assigned(OnTerminouJogo) then OnTerminouJogo(Self);
   End);
end;

procedure TBola.DoMatouBloco;
begin
TThread.Queue(Nil,
   Procedure
   Begin
   if Assigned(OnMatouBloco) then OnMatouBloco(Self);
   End);
end;

procedure TBola.DoMatouTodos;
begin
TThread.Queue(Nil,
   Procedure
   Begin
   Log.d('Do MatouTodos');
   if Assigned(OnMatouTodos) then OnMatouTodos(Self);
   End);
end;

Procedure TBola.AnimaColisao;
Begin
Log.d('AnimaColisao');
if Not FAnimando then
   Begin
   FAnimando := True;
   TThread.CreateAnonymousThread(
      Procedure
      Var
         Tempo : Single;
      Begin
      FGlow.Opacity  := 1;
      FGlow.Softness := 0.9;
      Tempo          := 0.2;
      if FSuper then Tempo := 0.1;
      Repeat
         TThread.Synchronize(TThread.CurrentThread, Procedure Begin TAnimator.AnimateFloat(FGlow, 'Opacity', 0,   Tempo); End);
         Sleep(Trunc(Tempo*1000)+10);
         if FSuper then
            Begin
            TThread.Synchronize(TThread.CurrentThread, Procedure Begin TAnimator.AnimateFloat(FGlow, 'Opacity', 1,   Tempo); End);
            Sleep(Trunc(Tempo*1000)+10);
            End;
         Until Not(FSuper) Or Not(FVaus.Vivo);
      FGlow.Opacity := 0;
      FAnimando     := False;
      End).Start;
   End;
End;

Procedure TBola.MovimentaBola;

      Procedure Aguarda;
      Var
         UltTick : Cardinal;
      Begin
      UltTick := TThread.GetTickCount;
      repeat
         Sleep(1);
         until TThread.GetTickCount - UltTick >= FTempoBola;
      End;

Begin
case FDirV of
   Cima  : FY := FY - FVelY;
   Baixo : FY := FY + FVelY;
   end;
if FY <= 0 then
   Begin
   FY        := 0;
   FDirV     := TDirecao.Baixo;
   FCorrendo := FTipo <> TTipoBola.tbLaser;
   End;
If FTipo <> TTipoBola.tbLaser Then
   Begin
   case FDirH of
      Esquerda : FX := FX - FVelX;
      Direita  : FX := FX + FVelX;
      end;
   if FX <= 0 then
      Begin
      FX    := 0;
      FDirH := TDirecao.Direita;
      End;
   if FX + Self.Width >= FForm.ClientWidth then
      Begin
      FX    := FForm.ClientWidth - Self.Width;
      FDirH := TDirecao.Esquerda;
      End;
   End;
TThread.Queue(Nil,
   Procedure
   Begin
   Self.Position.X := FX;
   Self.Position.Y := FY;
   End);
Aguarda;
End;

Function TBola.HouveColisao : Boolean;
Var
   Colisoes : Array[0..3] Of Boolean;
   Colidido : TRectF;
   Bloco    : TBloco;
   InvH     : Boolean;
   InvV     : Boolean;

   Procedure InverteVertical;
   Begin
   if DirecaoV = TDirecao.Cima then DirecaoV := TDirecao.Baixo Else DirecaoV := TDirecao.Cima;
   End;

   Procedure InverteHorizontal;
   Begin
   if DirecaoH = TDirecao.Direita then DirecaoH := TDirecao.Esquerda Else DirecaoH := TDirecao.Direita;
   if VelH < VelV * 0.5           then VelH     := VelV * 0.7;
   End;

   Function ColidiuNoBloco : Boolean;
   Var
      X, Y : Integer;

      Procedure TestaLinha;

         Procedure VerSeColidiu;
         Begin
         if TBloco.EstaVivo(X, Y) then
            Begin
            Bloco    := TBloco.MatrizBlocos[X, Y];
            Colidido := Bloco .AbsoluteRect;
            Result   := Self  .AbsoluteRect.IntersectsWith(Colidido);
            End;
         End;

      Begin
      if DirecaoH = Direita then
         Begin
         X := -1;
         While (X < 6) And Not Result Do
            Begin
            Inc(X);
            VerSeColidiu;
            End;
         End
      Else
         Begin
         X := 7;
         While (X > 0) And Not Result Do
            Begin
            Dec(X);
            VerSeColidiu;
            End;
         End;
      End;

   Begin
   Result := False;
   if DirecaoV = Cima then
      Begin
      Y := 12;
      While (Y > 0) And Not Result Do
         Begin
         Dec(Y);
         TestaLinha;
         End;
      End
   Else
      Begin
      Y := -1;
      While (Y < 11) And Not Result Do
         Begin
         Inc(Y);
         TestaLinha;
         End;
      End;
   End;

   Procedure TestaTodosMortos;
   Var
      X, Y : Integer;
   Begin
   FTodosMortos := True;
   for X := 0 to 6 do for Y := 0 to 11 do if TBloco.EstaVivo(X, Y) then FTodosMortos := False;
   End;

   Procedure TestaColisaoLateral;
   Begin
   if Colisoes[Integer(Direita)]  then
      Begin
      if DirecaoH = Direita then
         InvH := True
      Else
         InvV := True;
      End
   Else
   if Colisoes[Integer(Esquerda)] then
      Begin
      if DirecaoH = Esquerda then
         InvH := True
      Else
         InvV := True;
      End;
   End;

Begin
Result     := ColidiuNoBloco;
FPontosRec := 0;
InvH       := False;
InvV       := False;
If Result And (Self.FTipo <> TTipoBola.tbLaser) Then
   Begin
   Colisoes[Integer(Cima)]     := Colidido.Contains(TPointF.Create(FX+Width*0.5,  FY));
   Colisoes[Integer(Direita)]  := Colidido.Contains(TPointF.Create(FX+Width,      FY+Height*0.5));
   Colisoes[Integer(Baixo)]    := Colidido.Contains(TPointF.Create(FX+Width*0.5,  FY+Height));
   Colisoes[Integer(Esquerda)] := Colidido.Contains(TPointF.Create(FX,            FY+Height*0.5));
   if (DirecaoV = TDirecao.Cima) Then
      Begin
      if Colisoes[Integer(Cima)]     then InvV := True Else
      if Colisoes[Integer(Baixo)]    then InvH := True Else
      TestaColisaoLateral;
      End
   Else
   if (DirecaoV = TDirecao.Baixo) Then
      Begin
      if Colisoes[Integer(Baixo)] then InvV := True Else
      if Colisoes[Integer(Cima)]  then InvH := True Else
      TestaColisaoLateral;
      End;
   Result := InvH Or InvV;
   End;
if Not SuperBola then
   Begin
   if InvH then InverteHorizontal;
   if InvV then InverteVertical;
   End;
if Result Then
   Begin
   FPontosRec := Bloco.Pontos;
   Bloco.Morre;
   if FTipo <> TTipoBola.tbLaser then
      Repeat
         MovimentaBola;
         Until Not Self.AbsoluteRect.IntersectsWith(Colidido);
   End;
TestaTodosMortos;
end;

constructor TBola.Create(aTipo: TTipoBola);
begin
Inherited Create(nil);
case aTipo of
   tbJogo  : Self.Bitmap := TResource.GetBitmap('BolaJogo');
   tbExtra : Self.Bitmap := TResource.GetBitmap('BolaExtra');
   tbLaser : Self.Bitmap := TResource.GetBitmap('BolaLaser');
   end;
FTipo      := aTipo;
Parent     := FForm;
If aTipo = TBLaser Then
   Self.Width   := 10
Else
   Self.Width   := 20;
Height     := 20;
Visible    := False;
Pause      := False;
SuperBola  := False;
FAnimando  := False;
FGlow           := TGlowEffect.Create(Self);
FGlow.Parent    := Self;
FGlow.GlowColor := TAlphaColorRec.White;
FGlow.Softness  := 0.4;
FGlow.Opacity   := 0;
FGlow.Enabled   := True;
TThread.CreateAnonymousThread(
   Procedure

      Procedure TestaRebater;
      Var
         MulX : Single;
      Begin
      If FTipo = TTipoBola.tbLaser Then Exit;
      FCentroB := Self .Position.X + Self .Width/2;
      FCentroV := FVaus.XCenter;
      if FY+20 >= FVaus.Position.Y Then
        Begin
        If (FCentroB >= FVaus.AbsoluteRect.Left) And (FCentroB <= FVaus.AbsoluteRect.Right) then
           Begin
           Audio.PlayRebatida;
           AnimaColisao;
           MulX   := FCentroV - FCentroB;
           if FVelX = 0 then
              If MulX < 0 then
                 FDirH := TDirecao.Direita
              Else
                 FDirH := TDirecao.Esquerda;
           MulX  := (Abs(FCentroV - FCentroB) * 1.5) / (FVaus.Width/2);
           FVelX := FVelY * MulX;
           FDirV := TDirecao.Cima;
           End
        Else
           begin
           if FVaus.CampoDeForca then
              Begin
              Audio.PlayRebatida;
              AnimaColisao;
              FDirV := TDirecao.Cima;
              End;
           End;
        End;
      End;

      Procedure TestaColisaoBloco;
      Begin
      If HouveColisao Then
         Begin
         If FTipo <> TTipoBola.tbLaser Then AnimaColisao;
         DoMatouBloco;
         FPontos   := FPontos + FPontosRec;
         FCorrendo := FTipo <> TTipoBola.tbLaser;
         End;
      End;

   Begin
   Sleep(40);
   Repeat
      FCorrendo := FTipo <> TTipoBola.tbJogo;
      While Not FCorrendo Do Sleep(10);
      FX      := Position.X;
      FY      := Position.Y;
      FSuper  := False;
      case FNivel of
         1 : FTempoBola := 11;
         2 : FTempoBola := 7;
         3 : FTempoBola := 5;
         end;
      Repeat
         while Pause do Sleep(10);
         MovimentaBola;
         TestaRebater;
         TestaColisaoBloco;
         Until (FVidas < 1) Or FTodosMortos Or FEliminar Or Not(FCorrendo) Or ((FY > FVaus.Position.Y) And FCorrendo);
      if FTipo = TTipoBola.tbJogo then
         Begin
         Log.D('Saiu');
         FEliminar := True;
         if FCorrendo then
            Begin
            if FTodosMortos then
               DoMatouTodos
            Else
               Begin
               FDirV := TDirecao.Baixo;
               Repeat
                  MovimentaBola;
                  Until FY > FForm.ClientHeight;
               Dec(FVidas);
               if FVidas > 0 then
                  DoMorreu
               Else
                  DoTerminouJogo;
               End;
            End
         Else
            DoTerminouJogo;
         End;
      Until FTipo <> TTipoBola.tbJogo;
   Dispose(Self);
   End).Start;
end;

procedure TBola.PosicionaBola;
begin
FVelX := 0;
FVelY := 2;
FDirV := TDirecao.Baixo;
FDirH := TDirecao.Direita;
TThread.Queue(Nil,
   Procedure
   Begin
   Self.Visible    := True;
   Self.Position.X := FVaus.Width + Random(Trunc(FForm.ClientWidth-FVaus.Width*2));
   Self.Position.Y := FVaus.Position.Y - 120;
   End);
end;

procedure TBola.SetSuperBola(const Value: Boolean);
begin
Log.d('Setou SuperBola '+Value.ToString(True));
FSuper := Value;
If FSuper Then AnimaColisao;
end;

procedure TBola.LancarBola;
begin
FEliminar := False;
FCorrendo := True;
end;

procedure TBola.PararBola;
begin
FCorrendo := False;
end;


end.
