unit CalculatorClass;

interface

uses
  SysUtils, Stack;

type
  /// <summary>  计算机类  </summary>
  TCalculator = Class;

  /// <summary>  状态基类  </summary>
  TState = class
  protected
    FOwner: TCalCulator;
    procedure handleNumber(opr: Char); virtual;        //在当前状态下即将要做的工作(同时会发生状态改变)
    procedure handleOperator(opr: Char); virtual;
    procedure handleDecimalDot; virtual;
    procedure handleBracket(opr: Char); virtual;
    procedure handleResult(opr: Char); virtual;
    procedure handleClear;
    constructor Create(AOwner: TCalCulator); virtual;
    procedure handleBack; virtual;
  end;

  TCalculator = class
  private
    FBuffer: string;
    FCurrentState:  TState;                                         //当前状态
    FNumberState: TState;                                           //成员状态
    FOperatorState: TState;
    FDecimalDotState: TState;
    FResultState: TState;
    FClearState: TState;
    FBracketState: TState;
    NumberStack: TStack<Double>;
    OperatorStack: TStack<Char>;
    function TwoNumberDeal(num1, num2: Double; symbol: Char): Double;
    function isDigit(Ch: Char): Boolean;
  public
    Equation: string;                                               //提供给form访问的第一行显示式子
    ResultNum: string;                                              //提供给form访问的第二行显示当前数字或者结果
    BracketMatch: Integer;                                          //处理表达式的括号匹配，左括号+1，右括号-1
    constructor Create;
    destructor Destroy; override;
    procedure RealCalculate(Strings: string);                       //计算表达式
    procedure ProcessEvent(AChar: Char);                            //状态跳转
    function SymbolCompare(UpChar, DownChar: Char): Boolean;        //符号优先级比较
    property Buffer: string read FBuffer write FBuffer;             //辅助第二行的显示
  end;

implementation

uses
  StateClass;

//状态基类
procedure TState.handleNumber(opr: Char);
begin

end;

procedure TState.handleOperator;
begin

end;

procedure TState.handleDecimalDot;
begin

end;

procedure TState.handleBracket(opr: Char);
begin

end;

procedure TState.handleResult(opr: Char);
begin

end;

constructor TState.Create(AOwner: TCalCulator);
begin
  inherited Create;        //调用父亲的构造函数
  FOwner := AOwner;
end;

procedure TState.handleBack;
begin
//这里不能直接删掉一位Equation的字符，因为如果此时字符为运算符，设置为不允许删除
end;

procedure TState.handleClear;
begin
  with FOwner do
  begin
    Equation := '';
    buffer := '';
    ResultNum := '0';
    NumberStack.Clear;
    OperatorStack.Clear;
  end;
end;

//计算机类
constructor TCalculator.Create;
begin
  inherited;
  NumberStack := TStack<Double>.Create;
  OperatorStack := TStack<Char>.Create;
  Equation := ' ';
  buffer := '';
  ResultNum := '0';
  BracketMatch := 0;
  FNumberState := TNumberState.Create(Self);
  FOperatorState := TOperatorState.Create(Self);
  FDecimalDotState := TDecimalDotState.Create(Self);
  FBracketState := TBracketState.Create(Self);
  FResultState := TResultState.Create(Self);
  FClearState := TClearState.Create(Self);
  FCurrentState := FClearState;
end;

destructor TCalculator.Destroy;
begin
  FreeAndNil(NumberStack);
  FreeAndNil(OperatorStack);
  FreeAndNil(FNumberState);
  FreeAndNil(FBracketState);
  FreeAndNiL(FOperatorState);
  FreeAndNil(FDecimalDotState);
  FreeAndNil(FResultState);
  FreeAndNil(FClearState);
end;

function TCalculator.isDigit(Ch: Char): Boolean;
begin
  Result := Ch in ['0'..'9'];
end;

procedure TCalculator.ProcessEvent(AChar: Char);
begin
  //接收从显示界面按钮控件传来的信号，在计算器内部进行相应的处理
  if ('0' <= AChar) and (Achar <= '9') then
    FCurrentState.handleNumber(AChar)
  else if CharInSet(AChar, ['+', '-', '/', '*']) then
    FCurrentState.handleOperator(Achar)
  else if CharInSet(AChar, ['(', ')']) then
    FCurrentState.handleBracket(AChar)
  else if AChar = '.' then
    FCurrentState.handleDecimalDot
  else if AChar = '=' then
  begin
    FCurrentState.handleResult(AChar);
    FCurrentState := FResultState;
  end
  else if AChar = 'C' then
    FCurrentState.handleClear
  else if AChar = 'B' then
    FCurrentState.handleBack;

  //跳转状态
  if Length(Equation) = 0 then
    FCurrentState := FClearState
  else if (AChar <> '=') and (Length(Equation)>0) then
  begin
    case Equation[Length(Equation)] of
      '.':
      FCurrentState := FDecimalDotState;
      '+', '-', '*', '/':
      FCurrentState := FOperatorState;
      '(', ')':
      FCurrentState := FBracketState;
      '=':
      FCurrentState := FResultState;
      '0'..'9':
      FCurrentState := FNumberState;
    end;
  end;
end;

procedure TCalculator.RealCalculate(Strings: string);
var
  Num1, Num2, Num: Double;
  Ch, Symbol: Char;
  I: Integer;
  Substr: string;
begin
  NumberStack.Clear;
  OperatorStack.Clear;
  I := 1;
  while I <= Length(Strings) do
  begin
    Ch := Strings[i];
    if (isDigit(Ch)) or (Ch = '.') then
    begin
      SubStr := ' ';
      while (i<=Length(Strings)) and (isDigit(Strings[i]) or (Strings[i] = '.')) do
      begin
        SubStr := SubStr + Strings[i];
        Inc(i);
      end;
      Num :=  StrToFloat(SubStr);
      NumberStack.Push(Num);
    end
    else                                                       //遇到符号时的处理
    begin
      //如果符号栈为空或者想入栈的符号是'('，或者优先级大于等于栈顶的元素优先级
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
        OperatorStack.Pop;                                     //左括号出栈
      end
      //如果此时想入栈的符号优先级小于栈顶里的符号的优先级
      else if SymbolCompare(Ch, OperatorStack.Peek) = False then
      begin
        while (not OperatorStack.isEmpty) and (SymbolCompare(Ch, OperatorStack.Peek) = False) do
        begin
          if OperatorStack.Peek = '(' then                     //用于处理(1+3=的输入
          begin
            OperatorStack.Pop;
            Dec(BracketMatch);
            if (BracketMatch <= 0) or OperatorStack.isEmpty then
              Exit;
          end;
          Num1 := NumberStack.Pop;
          Num2 := NumberStack.Pop;
          Symbol := OperatorStack.Pop;
          ResultNum := FloatToStr(TwoNumberDeal(Num1, Num2, Symbol));
          if (Ch = '=') and (OperatorStack.isEmpty) then  //是‘=‘的话再额外处理
            Exit;
          NumberStack.Push(StrToFloat(ResultNum));
        end;
        if Ch <> '=' then
          OperatorStack.Push(Ch);
      end;
      Inc(i);
    end;
  end;
  ResultNum := FloatToStr(NumberStack.Peek);
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

function TCalculator.TwoNumberDeal(Num1, Num2: Double; Symbol: Char): Double;
begin
  if Symbol = '+' then
    Result := Num2 + Num1
  else if Symbol = '-' then
    Result := Num2 - Num1
  else if Symbol = '*' then
    Result := Num2 * Num1
  else if Symbol = '/' then
    Result := Num2 / Num1
  else
    raise Exception.Create('Error Message');
end;

end.


