unit uTestes;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, System.IOUtils,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, uVaus, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects,
  FMX.Edit, FMX.ScrollBox, FMX.Memo, FMX.Ani,

  {$IFDEF ANDROID}
  Androidapi.Helpers,
  Androidapi.Jni.GraphicsContentViewText,
  Androidapi.JNI.App,
  FMX.Helpers.Android,
  {$ENDIF}

  FMX.Layouts, FMX.ISBaseButtons, FMX.ISBase, FMX.ISButtons, FMX.Effects, FMX.ISLayouts, FMX.ISPanel, FMX.ISMainMenu,
  FMX.ISEvents, System.Net.URLClient, System.Net.HttpClient, System.Net.HttpClientComponent, FMX.ISMenu, FMX.ISWait, FMX.ISBadge,
  FMX.ISCircleIcon, FMX.Memo.Types, FMX.ISControls, FMX.ISPath_Native, FMX.ISPath, FMX.ISObjects, FMX.ISBase.Presented;

type
  TForm37 = class(TForm)
    VausCenter: TImage;
    Button1: TButton;
    Voce: TImage;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    VausLaser: TImage;
    VausNormal: TImage;
    Button6: TButton;
    Memo1: TMemo;
    Edit1: TEdit;
    Button7: TButton;
    ISIconTextButton1: TISIconTextButton;
    ISIconTextButton2: TISIconTextButton;
    ISIconTextButton3: TISIconTextButton;
    Image1: TImage;
    GlowEffect1: TGlowEffect;
    ISChildrenLayout1: TISChildrenLayout;
    ISPanel1: TISPanel;
    ISIconTextButton4: TISIconTextButton;
    ISIconTextButton5: TISIconTextButton;
    ISIconTextButton6: TISIconTextButton;
    ISMainMenu1: TISMainMenu;
    ISMainMenu1_Option1: TISMainMenuItem;
    ISMainMenu1_Separator2: TISMainMenuSeparator;
    ISMainMenu1_Option3: TISMainMenuItem;
    ISMainMenu1_Option4: TISMainMenuItem;
    ISWaitLayout1: TISWaitLayout;
    ISCircleIcon1: TISCircleIcon;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button7Gesture(Sender: TObject; const EventInfo: TGestureEventInfo; var Handled: Boolean);
    procedure ISIconTextButton2Clicked(Sender: TObject);
  private
    { Private declarations }
   a : TVaus;
  public
    { Public declarations }
  end;

var
  Form37: TForm37;

implementation

{$R *.fmx}

procedure TForm37.Button1Click(Sender: TObject);
begin
A.Position.X := 10;
A.Position.Y := 80;
end;

procedure TForm37.Button2Click(Sender: TObject);
begin
A.Tamanho := TTamanhoVaus.Paqueno;
end;

procedure TForm37.Button3Click(Sender: TObject);
begin
A.Tamanho := TTamanhoVaus.Medio;
end;

procedure TForm37.Button4Click(Sender: TObject);
begin
A.Tamanho := TTamanhoVaus.Grande;
end;

procedure TForm37.Button5Click(Sender: TObject);
begin
case a.Tipo of
   Normal : A.Tipo := Laser;
   Laser  : A.Tipo := Normal;
   end;
end;

procedure TForm37.Button7Click(Sender: TObject);
Var
   xml : TStringList;
   Dir : String;
begin
//Dir := JStringToString(TAndroidHelper.Context.getApplicationInfo..sourceDir);
Dir := '/data/app/com.embarcadero.Testes/res/xml';
xml := TStringList.Create;
xml.LoadFromFile(Dir+pathDelim+'provider_paths.xml');

Memo1.Text := Xml.Text;
Xml.DisposeOf;

end;

procedure TForm37.Button7Gesture(Sender: TObject; const EventInfo: TGestureEventInfo; var Handled: Boolean);
begin
Memo1.Lines.Add('GESTURE');
end;

procedure TForm37.ISIconTextButton2Clicked(Sender: TObject);
begin
//ISEventContainer1.Clear;
//ISentContainer1.LoadFrom('teste.events');
end;

end.
