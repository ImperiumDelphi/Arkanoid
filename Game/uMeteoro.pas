unit uMeteoro;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects, FMX.Controls.Presentation, FMX.StdCtrls,
  FMX.Ani, FMX.Layouts, FMX.InertialMovement, FMX.ExtCtrls,

  uResource;

type

  TMeteoro = Class(TImage)
     Private
        FAniX        : TFloatAnimation;
        FAniY        : TFloatAnimation;
        FAniR        : TFloatAnimation;
        ClientWidth  : Integer;
        ClientHeight : Integer;
        FDuration    : Integer;
        Procedure FimANimacao(Sender : TObject);
        procedure SetSize(const Value: Integer);
        function  GetSize: Integer;
     Public
        Constructor Create(aOwner : TComponent; aImagem: String; Frequencia : Integer);  Reintroduce;
        Property Duration : Integer  Read FDuration Write FDuration;
        Property Size     : Integer  Read GetSize   Write SetSize;
     End;

implementation

{ TAniMeteoro }

constructor TMeteoro.Create(aOwner : TComponent; aImagem: String; Frequencia : Integer);
begin
Inherited Create(aOwner);
if aOwner Is TForm then
   Parent  := (aOwner As TForm)
Else
   Parent  := (aOwner As TControl);
FAniX   := TFloatAnimation.Create(Self); FAniX.Parent := Self; FAniX.PropertyName := 'Position.X';
FAniY   := TFloatAnimation.Create(Self); FAniY.Parent := Self; FAniY.PropertyName := 'Position.Y';
FAniR   := TFloatAnimation.Create(Self); FAniR.Parent := Self; FAniR.PropertyName := 'RotationAngle';
FAniR.StartValue := 0;
FAniR.StopValue  := 360; FAniR.Loop := True;
FAniX.OnFinish   := FimAnimacao;
Width            := 250;
Height           := 250;
Bitmap           := TResource.GetBitmap(aImagem);
Position.Y       := -260;
ClientWidth      := (aOwner as TForm).ClientWidth;
ClientHeight     := (aOwner as TForm).ClientHeight;
FDuration        := 3;
HitTest          := False;
TThread.CreateAnonymousThread(
   Procedure
   Begin
   Repeat
      Randomize;
      Sleep(200);
      if Random(Frequencia) = 1 then
         Begin
         TThread.Synchronize(Nil,
            Procedure
            Var
               Xi, Xf : Integer;
            Begin
            if FAniX.Running then Exit;
            Xi               := Random(ClientWidth * 3)-ClientWidth;
            Xf               := Random(ClientWidth * 3)-ClientWidth;
            Position.X       := Xi;
            Position.Y       := -(Height+3);
            FAniX.StartValue := Xi;
            FAniX.StopValue  := Xf;
            FAniX.Duration   := FDuration;
            FAniY.StartValue := Position.Y;
            FAniY.StopValue  := ClientHeight+Height+3;
            FAniY.Duration   := FDuration;
            FAniR.Duration   := FDuration;
            FAniX.Start;
            FAniY.Start;
            FAniR.Start;
            End);
         End;
      Until False;
   end).Start;
end;

procedure TMeteoro.FimANimacao(Sender: TObject);
begin
end;

function TMeteoro.GetSize: Integer;
begin
Result := Trunc(Width);
end;

procedure TMeteoro.SetSize(const Value: Integer);
begin
Width  := Value;
Height := Value;
end;

end.
