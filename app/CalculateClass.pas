unit CalculateClass;

interface

uses
  SysUtils, Stack;

type
  //先声明计算机类，否则状态类的函数参数无法使用Calcutor类作为参数
  TCalculator = Class;

  //状态基类
  TState = class
  //不能使用private，private只能用于当前类所在的文件
  protected
    FOwner: TCalCulator;
  public
    //在当前状态下即将要做的工作(同时也会发生状态改变)
    procedure handleNumber(num: Integer); virtual;
    procedure handleOperator(opr: Char); virtual;
    procedure handleDecimalDot; virtual;
    procedure handleResult; virtual;
    procedure handleClear; virtual;
    constructor Create(AOwner: TCalCulator); virtual;
  end;

  //下一个状态，用于Calculator类中的SetNewState
  NextState = (
    neNumberState,
    neOperatorState,
    neDecimalDotState,
    neResultState,
    neClearState
  );

    //数字状态类
  TNumberState = class(TState)
    procedure handleNumber(num: Integer); override;
    procedure handleOperator(opr: Char); override;
    procedure handleDecimalDot; override;
    procedure handleResult; override;
  end;
  //运算符状态类
  TOperatorState = class(TState)
    procedure handleNumber(num: Integer); override;
    procedure handleOperator(opr: Char); override;
    procedure handleDecimalDot; override;
  end;
  //小数点状态类
  TDecimalDotState = class(TState)
    procedure handleNumber(num: Integer); override;
  end;

  //显示结果状态类
  TResultState = class(TState)
    procedure handleNumber(num: Integer); override;
    procedure handleResult; override;
  end;

  //清空状态类
  TClearState = class(TState)
    procedure handleNumber(num: Integer); override;
  end;




  TCalculator = class
  protected
    FBuffer: string;
    //成员状态
    NumberState: TNumberState;
    OperatorState: TOperatorState;
    DecimalDotState: TDecimalDotState;
    ResultState: TResultState;
    ClearState: TClearState;
    //当前状态
    CurrentState:  TState;
  public
    NumberStack: TNumberStack;
    OperatorStack: TOperatorStack;
    ResultNum: Real;
    procedure SetNewState(NewState: NextState);
    property Buffer: string read FBuffer write FBuffer;
    constructor Create;
    destructor Destroy; override;
    function CalculateResult: Real;
    procedure RealCalculate(Ch: Char);
    procedure ProcessEvent(AChar: Char);
    //计算时判断符号优先级
    function SymbolCompare(UpChar, DownChar: Char): Boolean;
    function TwoNumberDeal(num1, num2: Real; symbol: Char): Real;
  end;





implementation

//状态基类
procedure TState.handleNumber(num: Integer);
begin

end;

procedure TState.handleOperator;
begin

end;

procedure TState.handleDecimalDot;
begin

end;

procedure TState.handleResult;
begin

end;

constructor TState.Create(AOwner: TCalCulator);
begin
  inherited Create;        //调用父亲的构造函数
  FOwner := AOwner;
end;

procedure TState.handleClear;
begin

end;

//数字状态类
procedure TNumberState.handleNumber(num: Integer);
begin
  with FOwner do
  begin
    buffer := buffer + IntToStr(num);
    SetNewState(neNumberState);
  end;
end;

//进行计算的逻辑，将此时栈里可以计算的全部计算
procedure TNumberState.handleOperator(opr: Char);
begin
  with FOwner do
  begin
    NumberStack.Push(StrToFloat(buffer));
    buffer := opr;              //delphi支持string:=char
    RealCalculate(opr);
    SetNewState(neOperatorState);
  end;
end;

procedure TNumberState.handleDecimalDot;
begin
  with FOwner do
  begin
    buffer := buffer + '.';
    SetNewState(neDecimalDotState);
  end;
end;

//按了"等于"号,要切换到“等于显示结果”状态
procedure TNumberState.handleResult;
begin
  with FOwner do
  begin
//    RealCalculate(opr);
    buffer := '';
    SetNewState(neResultState);
  end;
end;

//运算符状态类
procedure TOperatorState.handleNumber(num: Integer);
begin
  with FOwner do
  begin
    //OperatorStack.Push(buffer[1]);
    buffer := IntToStr(num)  ;
    SetNewState(neNumberState);
  end;
end;

//替换当前的符号
procedure TOperatorState.handleOperator(opr: Char);
begin
  with FOwner do
  begin
    buffer := opr;
    SetNewState(neOperatorState);
  end;
end;

procedure TOperatorState.handleDecimalDot;
begin
  with FOwner do
  begin
    OperatorStack.Push(buffer[1]);
    buffer := '.';
    SetNewState(neDecimalDotState);
  end;
end;


//小数点状态类
procedure TDecimalDotState.handleNumber(num: Integer);
begin
  with FOwner do
  begin
    buffer := buffer + IntToStr(num);
    SetNewState(neNumberState);
  end;
end;

//“等于”结果显示类
procedure TResultState.handleNumber(num: Integer);
begin
  with FOwner do
  begin
    buffer := buffer + IntToStr(num);
    SetNewState(neNumberState);
  end;
end;

procedure TResultState.handleResult;
begin
  inherited;

end;


//清屏状态类
procedure TClearState.handleNumber(num: Integer);
begin
  with FOwner do
  begin
    buffer := buffer + IntToStr(num);
    SetNewState(neNumberState);
  end;
end;

//计算机类
constructor TCalculator.Create;
begin
  inherited;
  NumberStack := TNumberStack.Create;
  OperatorStack := TOperatorStack.Create;
  buffer := ' ';
  ResultNum := 0;
  NumberState := TNumberState.Create(Self);
  OperatorState := TOperatorState.Create(Self);
  DecimalDotState := TDecimalDotState.Create(Self);
  ResultState := TResultState.Create(Self);
  ClearState := TClearState.Create(Self);
  //SetNewState(neClearState);
  CurrentState := NumberState;
end;

destructor TCalculator.Destroy;
begin
  FreeAndNil(NumberStack);
  FreeAndNil(OperatorStack);
  FreeAndNil(NumberState);
  FreeAndNiL(OperatorState);
  FreeAndNil(DecimalDotState);
  FreeAndNil(ResultState);
  FreeAndNil(ClearState);
end;

//接收从显示界面按钮控件传来的信号，在计算器内部进行相应的处理
procedure TCalculator.ProcessEvent(AChar: Char);
begin
  if ('0' <= AChar) and (Achar <= '9') then
    CurrentState.handleNumber(Ord(AChar)-Ord('0'));
  if (AChar = '+') or (AChar = '-') or (AChar = '*') or (AChar = '/') or (AChar = '(') or (AChar = ')') then
    CurrentState.handleOperator(Achar);
  if AChar = '.' then
    CurrentState.handleDecimalDot;
  if AChar = '=' then
    CurrentState.handleResult;
  if AChar = 'C' then
    CurrentState.handleClear;


end;


//从当前的状态在按一个按键之后，跳转到下一个状态
procedure TCalculator.SetNewState(NewState: NextState);
begin
  case NewState of
    neNumberState: CurrentState := NumberState;
    neOperatorState: CurrentState := OperatorState;
    neDecimalDotState: CurrentState := DecimalDotState;
    neResultState: CurrentState := ResultState;
    neClearState: CurrentState := ClearState;
  end;
end;


function TCalculator.CalculateResult: Real;
var
  num1, num2: Real;
  opr: Char;
begin
  num1 := NumberStack.Pop;
  num2 := NumberStack.Pop;
  opr := OperatorStack.Pop;
  if opr = '+' then
    Result := num1 + num2
  else if opr = '-' then
    Result := num2 - num1
  else if opr = '*' then
    Result := num2 * num1
  else
    Result := num2 / num1;
end;

procedure TCalculator.RealCalculate(Ch: Char);
var
  Num1, Num2: Real;
  Symbol: Char;
begin
    //如果符号栈为空或者想入栈的符号是'('，或者优先级比栈顶的元素优先级高
    if (OperatorStack.isEmpty) or (Ch = '(') or (SymbolCompare(Ch, OperatorStack.Peek)) then
      OperatorStack.Push(Ch)
    //如果此时的符号为')'，直到左括号的元素都要出栈，最后入栈的元素是要显示出来在第二行的元素(Result)
    else if Ch = ')' then
    begin
      while OperatorStack.Peek <> '(' do
      begin
        Num1 := NumberStack.Pop;
        Num2 := NumberStack.Pop;
        Symbol := OperatorStack.Pop;
        NumberStack.Push(TwoNumberDeal(Num1, Num2, Symbol));
      end;
      OperatorStack.Pop;
    end
    //如果此时想入栈的符号优先级小于 等于 栈顶里的符号的优先级
    else if SymbolCompare(Ch, OperatorStack.Peek) = False then
    begin
      while (not OperatorStack.isEmpty) and (SymbolCompare(Ch, OperatorStack.Peek) = False) do
      begin
        Num1 := NumberStack.Pop;
        Num2 := NumberStack.Pop;
        Symbol := OperatorStack.Pop;
        NumberStack.Push(TwoNumberDeal(Num1, Num2, Symbol));
      end;
      OperatorStack.Push(Ch);
    end;
    ResultNum := NumberStack.Peek;
end;


function TCalculator.SymbolCompare(UpChar, DownChar: Char): Boolean;
begin
  if UpChar = '(' then
    Exit(True)
  else if ((UpChar = '*') or (UpChar = '/')) and ((DownChar = '+') or (DownChar = '-') or (DownChar = '('))  then
    Exit(True)
  else if ((UpChar = '+') or (UpChar = '-')) and (DownChar = '(') then
    Exit(True)
  else
    Exit(False);
end;

function  TCalculator.TwoNumberDeal(Num1, Num2: Real; Symbol: Char): Real;
begin
  if Symbol = '+' then
    Result := Num2 + Num1
  else if Symbol = '-' then
    Result := Num2 - Num1
  else if Symbol = '*' then
    Result := Num2 * Num1
  else if Symbol = '/' then
    Result := Num2 / Num1;
end;

end.
