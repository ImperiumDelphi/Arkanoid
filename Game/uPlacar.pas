unit uPlacar;

interface

uses
   System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
   FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects, FMX.Effects, FMX.Ani, FMX.Layouts,

   uResource;

   Type
      TPlacar = Class(TControl)
         Private
            Numeros : Array[0..9] Of TBitmap;
            FValor  : Integer;
            procedure SetValor(const Value: Integer);
         Protected
            Procedure Paint; Override;
         Public
            Constructor Create(aOwner : TComponent);  Reintroduce;
            Property Valor : Integer Read FValor Write SetValor;
         End;



implementation

{ TPlacar }

constructor TPlacar.Create(aOwner: TComponent);
begin
Inherited Create(aOwner);
Numeros[0] := TResource.GetBitmap('Num0');
Numeros[1] := TResource.GetBitmap('Num1');
Numeros[2] := TResource.GetBitmap('Num2');
Numeros[3] := TResource.GetBitmap('Num3');
Numeros[4] := TResource.GetBitmap('Num4');
Numeros[5] := TResource.GetBitmap('Num5');
Numeros[6] := TResource.GetBitmap('Num6');
Numeros[7] := TResource.GetBitmap('Num7');
Numeros[8] := TResource.GetBitmap('Num8');
Numeros[9] := TResource.GetBitmap('Num9');
FValor     := 0;
Width      := 120;
Height     := 30;
end;

procedure TPlacar.Paint;
Var
   N : Integer;
   V : String;
begin
inherited;
V := FormatFloat('000000', FValor);

for N := 0 to 5 do
   Begin
   Canvas.DrawBitmap(Numeros[StrToInt(V.Chars[N])], TRectF.Create(0, 0, Numeros[0].Width, Numeros[0].Height), TRectF.Create(N*20, 0, (N+1)*20+10, height), AbsoluteOpacity);
   End;
end;

procedure TPlacar.SetValor(const Value: Integer);
begin
FValor := Value;
Repaint;
end;

end.
