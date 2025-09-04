unit uAudio;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, System.IOUtils,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Media, FMX.Ani;

type
  TAudio = class(TComponent)
  private
    Path      : String;
    Canal0    : TMediaPlayer;
    Canal1    : TMediaPlayer;
    Canal2    : TMediaPlayer;
    Canal3    : TMediaPlayer;
    Canal4    : TMediaPlayer;
    Canal5    : TMediaPlayer;
    Canal6    : TMediaPlayer;
    Procedure CarregaAudio(Canal : TmediaPlayer; Nome : String);
    Procedure Play(Canal : TmediaPlayer; Volume : Single);
  public
    Constructor Create(aOwner : TComponent); Override;
    Destructor Destroy; Override;
    Procedure FinalizaAudio;

    Procedure InicializaAudioTelaInicial;  // Tela Inicial
    Procedure PlaySomTelaInicio;
    Procedure PlaySomEscolheNivel;

    Procedure InicializaAudioJogo;         // Durante o jogo
    Procedure PlayRebatida;
    Procedure PlayBlocoNormal;
    Procedure PlayBlocoEspecial;
    Procedure PlayPegouItem;
    Procedure PlayTiro;

    Procedure InicializaAudioFase;
    Procedure PlayInicioJogo;
    Procedure PlayMorre;
    Procedure PlayPassouFase;

  end;

var
  Audio: TAudio;

implementation

procedure TAudio.CarregaAudio(Canal : TmediaPlayer; Nome: String);
begin
Try
   Log.d('Carrega Audio :'+Nome);
   Canal.Stop;
   Canal.FileName := Path+Nome;
   Canal.Volume   := 0.01;
Except
   End;
end;

constructor TAudio.Create(aOwner: TComponent);

   Procedure TestaAudio(Nome : String);
   Var
      ResStr : TResourceStream;
      Arq    : String;
   Begin
   Arq := Nome;
   if Not FileExists(Path+Nome) then
      Begin
      Nome   := Nome.Remove(Nome.IndexOf('.'));
      ResStr := TResourceStream.Create(HInstance, Nome, RT_RCDATA);
      ResStr.SaveToFile(Path+Arq);
      ResStr.Free;
      End;
   End;

Begin
inherited;
Path := GetHomePath+PathDelim+'arkanoid'+PathDelim;
If Not DirectoryExists(Path) Then
   CreateDir(Path);
TestaAudio('InicioJogo.mp3');
TestaAudio('TelaInicio.mp3');
TestaAudio('Rebatida.mp3');
TestaAudio('NivelEscolhido.mp3');
TestaAudio('BlocoNormal.mp3');
TestaAudio('BlocoEspecial.mp3');
TestaAudio('Morreu.mp3');
TestaAudio('PegouItem.mp3');
TestaAudio('PassouFase.mp3');
TestaAudio('Laser1.mp3');
Canal0    := TMediaPlayer.Create(Self);
Canal1    := TMediaPlayer.Create(Self);
Canal2    := TMediaPlayer.Create(Self);
Canal3    := TMediaPlayer.Create(Self);
Canal4    := TMediaPlayer.Create(Self);
Canal5    := TMediaPlayer.Create(Self);
Canal6    := TMediaPlayer.Create(Self);
end;

destructor TAudio.Destroy;
begin
Canal0.Free;
Canal1.Free;
Canal2.Free;
Canal3.Free;
Canal4.Free;
Canal5.Free;
Canal6.Free;
inherited;
end;

procedure TAudio.FinalizaAudio;
begin
Log.d('FinalizaAudio');
Canal0.Clear;
Canal1.Clear;
Canal2.Clear;
Canal3.Clear;
Canal4.Clear;
Canal5.Clear;
Canal6.Clear;
end;

procedure TAudio.Play(Canal: TmediaPlayer; Volume: Single);
begin
Try
   Canal.Volume      := Volume;
   Canal.CurrentTime := 0;
   Canal.Play;
Except
   End;
end;


//    Sons da tela inicial


procedure TAudio.InicializaAudioTelaInicial;
begin
FinalizaAudio;
CarregaAudio(Canal0, 'TelaInicio.mp3');
CarregaAudio(Canal1, 'NivelEscolhido.mp3');
end;

procedure TAudio.PlaySomTelaInicio;
begin
Log.d('Play TelaInicio');
Play(Canal0, 0.5);
end;

procedure TAudio.PlaySomEscolheNivel;
begin
Log.d('Play EscolheNivel');
Play(Canal1, 0.9);
TThread.Synchronize(Nil, Procedure Begin TAnimator.AnimateFloat(Canal0, 'Volume', 0, 0.2) End);
end;


// Sons do jogo


procedure TAudio.InicializaAudioJogo;
begin
FinalizaAudio;
CarregaAudio(Canal0, 'Rebatida.mp3');
CarregaAudio(Canal1, 'BlocoNormal.mp3');
CarregaAudio(Canal2, 'BlocoEspecial.mp3');
CarregaAudio(Canal3, 'PegouItem.mp3');
CarregaAudio(Canal4, 'Laser1.mp3');
end;

procedure TAudio.PlayRebatida;
begin
Log.d('Play Rebatida');
Play(Canal0, 1);
end;

procedure TAudio.PlayBlocoNormal;
begin
Log.d('Play Bloco Normal');
Play(Canal1, 1);
end;

procedure TAudio.PlayBlocoEspecial;
begin
Log.d('Play Bloco Especial');
Play(Canal2, 1);
end;

procedure TAudio.PlayPegouItem;
begin
Log.d('Play pegou Item');
Play(Canal3, 1);
end;

procedure TAudio.PlayTiro;
begin
Log.d('Play Tiro');
Play(Canal4, 1);
end;


//   Sons do final do Jogo;


procedure TAudio.InicializaAudioFase;
begin
FinalizaAudio;
CarregaAudio(Canal0, 'InicioJogo.mp3');
CarregaAudio(Canal1, 'Morreu.mp3');
CarregaAudio(Canal2, 'PassouFase.mp3');
end;

procedure TAudio.PlayInicioJogo;
begin
Log.d('Play Inicio Jogo');
Play(Canal0, 1);
end;

procedure TAudio.PlayMorre;
begin
Log.d('Play Morreu');
Play(Canal1, 1);
end;

procedure TAudio.PlayPassouFase;
begin
Log.d('Play Passou Fase');
Play(Canal2, 1);
end;


end.
