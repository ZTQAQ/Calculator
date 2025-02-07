unit CalculateForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, CalculatorClass, Generics.Collections, RzButton,
  ImgList;

type
  TForm2 = class(TForm)
    Btn0: TButton;
    Btn1: TButton;
    Btn2: TButton;
    Btn3: TButton;
    Btn4: TButton;
    Btn5: TButton;
    Btn6: TButton;
    Btn7: TButton;
    Btn8: TButton;
    Btn9: TButton;
    BtnAdd: TButton;
    BtnSub: TButton;
    BtnMul: TButton;
    BtnDiv: TButton;
    BtnRes: TButton;
    BtnClear: TButton;
    BtnDot: TButton;
    BtnBack: TButton;
    RedtContent: TRichEdit;
    BtnLeft: TButton;
    BtnRight: TButton;
    procedure ButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

  private
    { Private declarations }
    MyCalculator: TCalculator;
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

procedure TForm2.FormCreate(Sender: TObject);
begin
  MyCalculator := TCalculator.Create;;
  RedtContent.Lines.Add('');                          // 第一行显示式子
  RedtContent.Lines.Add('');                          // 第二行显示输入和结果
  RedtContent.Lines[1] := MyCalculator.ResultNum;
end;

procedure TForm2.FormDestroy(Sender: TObject);
begin
  FreeAndNil(MyCalculator);
end;

procedure TForm2.ButtonClick(Sender: TObject);
var
  ch: Char;
begin
  if Sender is TButton then
  begin
    ch := TButton(Sender).Caption[1];
    MyCalculator.ProcessEvent(ch);                    // 处理计算器内部工作逻辑
    RedtContent.Lines[0] := MyCalculator.Equation;
    RedtContent.Lines[1] := MyCalculator.ResultNum;
  end;
end;

end.
