unit uResource;

interface

Uses
   System.Classes,
   System.Types,
   FMX.Graphics;


type
   TResource = class
      public
      class Function GetBitmap(Name : string) : TBitmap;
      end;

implementation

{ TResource }

class function TResource.GetBitmap(Name: string): TBitmap;
   var
      ResStr : TResourceStream;
begin
Result := Nil;
if Name <> '' then
   Begin
   Result := TBitmap.Create;
   ResStr := TResourceStream.Create(HInstance, Name, RT_RCDATA);
   Result.LoadFromStream(ResStr);
   ResStr.Free;
   End;
end;

end.
