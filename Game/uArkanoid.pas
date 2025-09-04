unit uArkanoid;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects, FMX.Controls.Presentation, FMX.StdCtrls,
  FMX.Ani, FMX.Layouts, FMX.InertialMovement, FMX.ExtCtrls, FMX.Media, FMX.Effects,

  uAudio,
  uLayouts,
  uPlacar,
  uBola,
  uItens,
  uBlocos,
  uVaus,
  uFases,
  uResource,
  uMeteoro;

type

  TArkanoid_Main = class(TForm)
    Dedo: TImage;
    Fundo: TImageViewer;
    FundoPainel: TRectangle;
    PainelJogo: TLayout;
    BolaVidas: TImage;
    QtdBolas: TLabel;
    GlowEffect2: TGlowEffect;
    PausePlay: TImage;
    CampoDeForca: TRectangle;
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure FormShow(Sender: TObject);
    procedure DedoMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure FormCreate(Sender: TObject);
    procedure PausePlayClick(Sender: TObject);
  private
    { Private declarations }
    Move            : Boolean;
    XVaus           : Single;
    BitmapScale     : Single;
    Meteoro1        : TMeteoro;
    Meteoro2        : TMeteoro;
    ImgPause        : TBitmap;
    ImgPlay         : TBitmap;
    Bola            : TBola;
    Vaus            : TVaus;
    Placar          : TPlacar;
    AniCampo        : TBitmapListAnimation;
    FTempoLaser     : Cardinal;
    FFaseAtual      : Integer;
    function GetFundoX: Single;
    function GetFundoY: Single;
    procedure SetFundoX(const Value: Single);
    procedure SetFundoY(const Value: Single);
    Procedure TerminouJogo(Sender : TObject);
    Procedure PassouDeFase(Sender : TObject);
    Procedure PerdeuUmaVida(Sender: TObject);
    procedure EscolheuONivel(Sender: TObject);
    procedure IniciaJogada(NovoJogo: Boolean);
    procedure SomouPontos(Sender: TObject);
    Procedure TelaEscolheNivel(Sender: TObject);
    Procedure PegouItem(Sender: TObject);
    Procedure MataRebatedor(Proc : TProc);
    Procedure AtualizaPainel;
    Procedure CriaBolaExtra(X, Y : SIngle; aDirecaoH : TDirecao);
    Procedure CriaBolaLaser(X, Y : SIngle; aDirecaoH : TDirecao);
  protected
  public
    { Public declarations }
    Property FundoX : Single   Read GetFundoX   Write SetFundoX;
    Property FundoY : Single   Read GetFundoY   Write SetFundoY;
  end;

var
  Arkanoid_Main: TArkanoid_Main;

implementation

{$R *.fmx}

procedure TArkanoid_Main.AtualizaPainel;
begin
QtdBolas.Text := 'X '+Bola.Vidas.ToString;
end;

procedure TArkanoid_Main.DedoMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
XVaus        := Vaus.Position.X + X;
Dedo.HitTest := False;
Move         := True;
end;

procedure TArkanoid_Main.FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
Var
   XP : Single;
   C  : Single;
begin
if Move then
   Begin
   C  := (Vaus.Width - Vaus.Comprimento)/2;
   XP := Vaus.Position.X + (X - XVaus);
   if XP < 0-C                      then XP := 0-C;
   if XP+Vaus.Width-C > ClientWidth then XP := ClientWidth-Vaus.Width+C;
   Vaus.Position.X := XP;
   Dedo.Position.X := XP;
   Dedo.Position.Y := ClientHeight-Dedo.Height-10;
   XVaus           := X;
   End;
end;

procedure TArkanoid_Main.FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);

   Procedure Atira;
   Begin
   If TThread.GetTickCount - FTempoLaser < 500 Then Exit;
   Audio.PlayTiro;
   CriaBolaLaser(Vaus.Position.X + 8,               Vaus.Position.Y-40, TDirecao.Esquerda);
   CriaBolaLaser(Vaus.Position.X + Vaus.Width - 18, Vaus.Position.Y-40, TDirecao.Direita);
   FTempoLaser := TThread.GetTickCount;
   End;

begin
if Move And Not Bola.Correndo then
   Begin
   Bola.LancarBola;
   End
Else
   Begin
   if Vaus.Tipo = TTipoVaus.Laser then Atira;
   End;
Dedo.HitTest := True;
Move         := False;
end;

procedure TArkanoid_Main.IniciaJogada(NovoJogo : Boolean);
begin
Log.d('Inicia Jogada');
TThread.CreateAnonymousThread(
   Procedure
   Begin
   Audio.InicializaAudioFase;
   Audio.PlayInicioJogo;
   QtdBolas.Text := '';
   Vaus.Position.X := (ClientWidth - Vaus.Width) / 2;
   Vaus.Position.Y := ClientHeight - 90;
   Vaus.Tamanho    := TTamanhoVaus.Medio;
   Vaus.Opacity    := 0;
   Vaus.Lancar;
   Bola.PosicionaBola;
   Dedo.Width        := Vaus.Width;
   Dedo.Position.X   := (ClientWidth - Dedo.Width) / 2;
   Dedo.Position.Y   := ClientHeight-Dedo.Height-10;
   Dedo.Opacity      := 0;
   Dedo.HitTest      := False;
   Placar.Position.Y := 1;
   Placar.Position.X := PainelJogo.Width-Placar.Width-8;
   PausePlay.Bitmap  := ImgPause;
   TBola.Pause       := False;
   CampoDeForca.Position.Y := Vaus.Position.Y + 10;
   TThread.Synchronize(TThread.CurrentThread,
      Procedure
      Begin
      If NovoJogo Then
         Begin
         TFases.MontaFase(FFaseAtual-1);
         TBloco.MostraMatrizBlocos(Self);
         End;
      PainelJogo  .Visible := True;
      Vaus        .Visible := True;
      CampoDeForca.Visible := False;
      Placar      .Visible := True;
      Dedo        .Visible := True;
      Dedo        .BringToFront;
      Vaus        .BringToFront;
      Bola        .BringToFront;
      TAnimator   .AnimateFloat(Vaus, 'Opacity', 1, 1);
      TAnimator   .AnimateFloat(Dedo, 'Opacity', 1, 1);
      AtualizaPainel;
      End);
   Sleep(2200);
   Audio.InicializaAudioJogo;
   Dedo.HitTest := True;
   End).Start;
end;

procedure TArkanoid_Main.MataRebatedor(Proc: TProc);
begin
Log.d('Matou rebatedor');
Move                := False;
Dedo.HitTest        := True;
TThread.CreateAnonymousThread(
   Procedure
   Begin
   Audio.InicializaAudioFase;
   Vaus.Morre;
   Audio.PlayMorre;
   TThread.Synchronize(Nil, Procedure Begin TAnimator.AnimateFloat(Dedo, 'Opacity', 0, 1); End);
   Sleep(1000);
   TThread.Queue(Nil,
      Procedure
      Begin
      Proc();
      End);
   End).Start;
end;

procedure TArkanoid_Main.SomouPontos(Sender: TObject);
begin
Placar.Valor := Bola.Pontos;
end;

procedure TArkanoid_Main.PassouDeFase(Sender: TObject);
begin
Log.d('Passou de Fase');
Move                      := False;
Bola      .Visible        := False;
Dedo      .Visible        := False;
Dedo      .HitTest        := True;
Vaus      .Visible        := False;
Vaus      .Vivo           := False;
Bola      .Pause          := False;
PainelJogo.Visible        := False;
PausePlay .Bitmap         := Nil;
TBloco.Clear;
TThread.CreateAnonymousThread(
   Procedure
   Begin
   Audio.InicializaAudioFase;
   Audio.PlayPassouFase;
   Sleep(2300);
   TThread.Queue(Nil,
      Procedure
      Begin
      Inc(FFaseAtual);
      if FFaseAtual > TFases.QtdFases then
         TerminouJogo(Sender)
      else
         IniciaJogada(True);
      End);
   End).Start;
end;

procedure TArkanoid_Main.PausePlayClick(Sender: TObject);
begin
Bola.Pause := Not Bola.Pause;
if Bola.Pause then
   PausePlay.Bitmap := ImgPlay
Else
   PausePlay.Bitmap := ImgPause;
TItem.Pause := Bola.Pause;
end;

procedure TArkanoid_Main.TerminouJogo(Sender: TObject);
begin
Log.d('Terminou Jogo');
PausePlay.Bitmap         := Nil;
Bola     .Pause          := False;
MataRebatedor(
   Procedure
   Begin
   Bola     .Visible := False;
   Dedo     .Visible := False;
   Vaus     .Visible := False;
   PausePlay.Bitmap  := Nil;
   TBloco.Clear;
//   TThread.CreateAnonymousThread(
//      Procedure
//      Begin
      PainelJogo.Visible := False;
      TelaEscolheNivel(Sender);
//      End).Start;
   End);
end;

procedure TArkanoid_Main.CriaBolaExtra(X, Y: SIngle; aDirecaoH : TDirecao);
Var
   Bola : TBola;
Begin
Log.d('Criando nova Bola');
Bola             := TBola.Create(TTipoBola.tbExtra);
Bola.Nivel       := Layouts.Nivel;
Bola.Position.X  := X;
Bola.Position.Y  := Y;
Bola.DirecaoH    := aDirecaoH;
Bola.DirecaoV    := TDirecao.Baixo;
Bola.Visible     := True;
Bola.VelH        := 0;
Bola.VelV        := 2;
Bola.Vidas       := 1;
end;

procedure TArkanoid_Main.CriaBolaLaser(X, Y: SIngle; aDirecaoH: TDirecao);
Var
   Bola : TBola;
Begin
Log.d('Criando Bola Laser');
Bola             := TBola.Create(TTipoBola.tbLaser);
Bola.Parent      := Self;
Bola.Nivel       := 3;
Bola.Position.X  := X;
Bola.Position.Y  := Y;
Bola.DirecaoH    := TDirecao.Cima;      // Não mexe no Eixo horizontal
Bola.DirecaoV    := TDirecao.Cima;
Bola.Visible     := True;
Bola.VelH        := 0;
Bola.VelV        := 4;
Bola.Vidas       := 1;
Bola.BringToFront;
end;

procedure TArkanoid_Main.PerdeuUmaVida(Sender: TObject);
begin
Log.d('Perdeu Vida');
MataRebatedor(
   Procedure
   Begin
   IniciaJogada(False)
   End);
End;

procedure TArkanoid_Main.EscolheuONivel(Sender: TObject);
Begin
Log.d('Escolheu o Nivel');
Layouts.LayoutAbertura.Parent  := Nil;
Layouts.LayoutAbertura.Visible := False;
FFaseAtual                     := 1;
Bola.Nivel  := Layouts.Nivel;
Bola.Pontos := 0;
Bola.Vidas  := 3;
IniciaJogada(True);
End;

procedure TArkanoid_Main.TelaEscolheNivel(Sender: TObject);
begin
Log.d('Tela Escolhe Nivel');
Layouts.MostraEscolheNivel;
end;

procedure TArkanoid_Main.PegouItem(Sender: TObject);

   Procedure MostraCampoDeForca;
   Begin
   Vaus.CampoDeForca       := True;
   CampoDeForca.Visible    := True;
   CampoDeForca.Position.Y := Vaus.Position.Y +2;
   CampoDeForca.Position.X := 0;
   CampoDeForca.Width      := ClientWidth;
   CampoDeForca.Height     := 22;
   CampoDeForca.Visible    := True;
   CampoDeForca.BringToFront;
   Dedo        .BringToFront;
   Vaus        .BringToFront;
   Bola        .BringToFront;
   AniCampo.Enabled := True;
   AniCampo.Start;
   TThread.CreateAnonymousThread(
      Procedure
      Var
         Tempo : Cardinal;
      Begin
      Tempo := TThread.GetTickCount;
      while (TThread.GetTickCount - Tempo < 15000) And Vaus.Visible do Sleep(20);
      TThread.Queue(Nil,
         Procedure
         Begin
         AniCampo    .Stop;
         AniCampo    .Enabled := False;
         CampoDeForca.Visible := False;
         End);
      End).Start;
   End;

   Procedure SuperBola;
   Begin
   TThread.CreateAnonymousThread(
      Procedure
      Var
         Tempo : Cardinal;
      Begin
      Bola.SuperBola := True;
      Tempo := TThread.GetTickCount;
      while (TThread.GetTickCount - Tempo < 15000) And Vaus.Visible do Sleep(20);
      Bola.SuperBola := False;
      End).Start;
   End;

   Procedure MaisBolas;
   Begin
   CriaBolaExtra(Vaus.AbsoluteRect.Right - 55, Vaus.Position.Y-24, TDirecao.Direita);
   CriaBolaExtra(Vaus.AbsoluteRect.Left  + 35, Vaus.Position.Y-24, TDirecao.Esquerda);
   End;

   Procedure Atirar;
   Begin
   TThread.CreateAnonymousThread(
      Procedure
      Var
         Tempo : Cardinal;
      Begin
      Vaus.Tipo   := TTipoVaus.Laser;
      FTempoLaser := TThread.GetTickCount;
      Tempo       := TThread.GetTickCount;
      while (TThread.GetTickCount - Tempo < 15000) And Vaus.Visible do Sleep(20);
      Vaus.Tipo := TTipoVaus.Normal;
      End).Start;
   End;

begin
Log.d('Pegou Item');
case (Sender As TItem).Tipo of
   tiMaisVida   : Bola.Vidas   := Bola.Vidas + 1;
   tiGrande     : Vaus.Tamanho := TTamanhoVaus.Grande;
   tiPequeno    : Vaus.Tamanho := TTamanhoVaus.Paqueno;
   tiCampoForca : MostraCampoDeForca;
   tiMaisBolas  : MaisBolas;
   tiTiro       : Atirar;
   tiTiraVida   : Bola.Vidas := Bola.Vidas - 1;
   tiSuperBola  : SuperBola;
   end;
AtualizaPainel;
end;

procedure TArkanoid_Main.FormCreate(Sender: TObject);
begin
{$IFNDEF MSWINDOWS}
Self.FullScreen := True;
{$ENDIF}
Audio                   := TAudio  .Create(Self);
Layouts                 := TLayouts.Create(Self);
Vaus                    := TVaus   .Create(Self);
Meteoro1                := TMeteoro.Create(Self, 'Meteoro1', 25);
Meteoro2                := TMeteoro.Create(Self, 'Meteoro2', 40);
Placar                  := TPlacar.Create(PainelJogo);
Placar  .Parent         := PainelJogo;
Placar  .Visible        := False;
Layouts .Form           := Self;
Layouts .OnDificuldade  := EscolheuONivel;
TBola   .Vaus           := Vaus;
TBola   .Form           := Self;
Bola                    := TBola.Create(TTipoBola.tbJogo);
Bola    .OnMorreu       := PerdeuUmaVida;
Bola    .OnTerminouJogo := TerminouJogo;
Bola    .OnMatouTodos   := PassouDeFase;
Bola    .OnMatouBloco   := SomouPontos;
Meteoro1.Size           := 250;
Meteoro2.Size           := 180;
TItem .Rebatedor        := Vaus;
TItem .OnPegouItem      := PegouItem;
ImgPause                := TResource.GetBitmap('Pause');
ImgPlay                 := TResource.GetBitmap('Play');
PausePlay.Bitmap        := Nil;
AniCampo                   := TBitmapListAnimation.Create(CampoDeForca);
AniCampo.Parent            := CampoDeForca;
AniCampo.Loop              := True;
AniCampo.AnimationBitmap   := TResource.GetBitmap('RaioH');
AniCampo.AnimationCount    := 8;
AniCampo.AnimationRowCount := 8;
AniCampo.PropertyName      := 'Fill.Bitmap.Bitmap';
AniCampo.Enabled           := False;
end;

procedure TArkanoid_Main.FormShow(Sender: TObject);

   Procedure IniciaImagemFundo;
   Var
      X, Y : Single;
   Begin
   Fundo.Bitmap      := TResource.GetBitmap('FundoTela');
   BitmapScale       := Fundo.Height * 1.5 / Fundo.Bitmap.Height;
   X                 := (Fundo.Bitmap.Width  * BitmapScale - Fundo.Width)  / 2;
   Y                 := (Fundo.Bitmap.Height * BitmapScale - Fundo.Height) / 2;
   Fundo.BitmapScale := BitmapScale;
   FundoX            := X;
   FundoY            := Y;
   TThread.CreateAnonymousThread(
      Procedure
      Var
         MaxHeight : Integer;
         MaxWidth  : Integer;
         Duration  : Integer;
      Begin
      Randomize;
      MaxWidth  := Trunc(Fundo.Bitmap.Width  * Fundo.BitmapScale - Fundo.Width);
      MaxHeight := Trunc(Fundo.Bitmap.Height * Fundo.BitmapScale - Fundo.Height);
      Repeat
         Duration := Random(10);
         Until Duration > 3;
      while True do
         Begin
         TThread.Queue(Nil,
            Procedure
            Begin
            TAnimator.AnimateFloat(Self, 'FundoX', Random(MaxWidth),  Duration);
            TAnimator.AnimateFloat(Self, 'FundoY', Random(MaxHeight), Duration);
            End);
         Sleep(Duration*1000);
         Sleep(Random(300));
         End;
      End).Start;
   End;

   Procedure IniciaObjetos;
   Begin
   BolaVidas .Bitmap  := TResource.GetBitmap('BolaJogo');
   Dedo      .Bitmap  := TResource.GetBitmap('Dedo');
   Vaus      .Visible := False;
   Dedo      .Visible := False;
   Bola      .Visible := False;
   PainelJogo.Visible := False;
   QtdBolas  .Text    := '';
   Meteoro1  .SendToBack;
   Meteoro2  .SendToBack;
   Fundo     .SendToBack;
   End;

Begin
IniciaImagemFundo;
IniciaObjetos;
TelaEscolheNivel(Nil);
end;

function TArkanoid_Main.GetFundoX: Single;
begin
Result := Fundo.ViewportPosition.X;
end;

function TArkanoid_Main.GetFundoY: Single;
begin
Result := Fundo.ViewportPosition.Y;
end;

procedure TArkanoid_Main.SetFundoX(const Value: Single);
begin
Fundo.ViewportPosition := TPointF.Create(Value, Fundo.ViewportPosition.Y);
end;

procedure TArkanoid_Main.SetFundoY(const Value: Single);
begin
Fundo.ViewportPosition := TPointF.Create(Fundo.ViewportPosition.X, Value);
end;


{
BlocoAzul
BlocoVermelho
BlocoVerde
BlocoAmarelo
BlocoLaranja
BlocoBranco
EspecialAzul
EspecialVermelho
EspecialRoxa
JoiaAzul
JoiaVermelha
JoiaVerde
JoiaAmarela
JoiaLaranja
JoiaBranca
EspecialCinza
EspecialRosa

}

end.



