unit StateClass;

interface

uses
  SysUtils, Stack, CalculatorClass;

type

  ///<summary>    数字状态类     </summary>
  TNumberState = class(TState)
    procedure handleNumber(opr: Char); override;
    procedure handleOperator(opr: Char); override;
    procedure handleDecimalDot; override;
    procedure handleBracket(opr: Char); override;
    procedure handleResult(opr: Char); override;
    procedure handleClear;
    procedure handleBack; override;
  end;

  ///<summary>    运算符状态类     </summary>
  TOperatorState = class(TState)
    procedure handleNumber(opr: Char); override;
    procedure handleOperator(opr: Char); override;
    procedure handleDecimalDot; override;
    procedure handleBracket(opr: Char); override;
    procedure handleResult(opr: Char); override;
  end;

  ///<summary>    小数点状态类     </summary>
  TDecimalDotState = class(TState)
    procedure handleNumber(opr: Char); override;
    procedure handleOperator(opr: Char); override;
    procedure handleBack; override;
    procedure handleResult(opr: Char); override;
  end;

  ///<summary>    括号状态类     </summary>
  TBracketState = class(TState)
    procedure handleNumber(opr: Char); override;
    procedure handleOperator(opr: Char); override;
    procedure handleDecimalDot; override;
    procedure handleBracket(opr: Char); override;
    procedure handleResult(opr: Char); override;
    procedure handleBack; override;
  end;

  ///<summary>    显示结果状态类     </summary>
  TResultState = class(TState)
    procedure handleNumber(opr: Char); override;
    procedure handleOperator(opr: Char); override;
    procedure handleDecimalDot; override;
    procedure handleBracket(opr: Char); override;
    procedure handleBack; override;
    procedure handleClear;
  end;

  ///<summary>    清空状态类     </summary>
  TClearState = class(TState)
    procedure handleNumber(opr: Char); override;
    procedure handleDecimalDot; override;
    procedure handleBracket(opr: Char); override;
    procedure handleBack; override;
  end;

implementation

procedure TNumberState.handleNumber(opr: Char);
begin
  with FOwner do
  begin
    Equation := Equation + opr;
    buffer := buffer + opr;
    ResultNum := buffer;
  end;
end;

procedure TNumberState.handleOperator(opr: Char);
begin
  //进行计算的逻辑，将此时栈里可以计算的全部计算
  with FOwner do
  begin
    Equation := Equation + opr;
    buffer := opr;
    RealCalculate(Equation);
  end;
end;

procedure TNumberState.handleBack;
begin
  inherited;
  with FOwner do
  begin
    Equation := Copy(Equation, 1, Length(Equation)-1);
    buffer := Copy(buffer, 1, Length(buffer)-1);
    ResultNum := buffer;
  end;
end;

procedure TNumberState.handleBracket(opr: Char);
begin
  //数字后只能加右括号
  with FOwner do
  begin
    if (opr = ')') and (BracketMatch > 0) then
    begin
      Equation := Equation + opr;
      buffer := opr;
      RealCalculate(Equation);
    end;
  end;
end;

procedure TNumberState.handleClear;
begin
  inherited;
end;

procedure TNumberState.handleDecimalDot;
var
  i: Integer;
begin
  with FOwner do
  begin
    for i := 1 to Length(buffer) do
      if buffer[i] = '.' then
        Exit;                                           //控制不输出第二个小数点
    Equation := Equation + '.';
    buffer := buffer + '.';
    ResultNum := buffer;
  end;
end;

procedure TNumberState.handleResult(opr: Char);
begin
  //按了"等于"号,要切换到“等于显示结果”状态
  with FOwner do
  begin
    Equation := Equation + opr;
    RealCalculate(Equation);
    buffer := '';
    Equation := ResultNum;
  end;
end;

procedure TOperatorState.handleNumber(opr: Char);
begin
  with FOwner do
  begin
    Equation := Equation + opr;
    buffer := opr;
    ResultNum := buffer;
  end;
end;

procedure TOperatorState.handleOperator(opr: Char);
begin
  with FOwner do
  begin
    Equation[length(Equation)] := opr;
    buffer := opr;
    RealCalculate(Equation);
  end;
end;

procedure TOperatorState.handleResult(opr: Char);
begin
  inherited;
  with FOwner do
  begin
    Equation[length(Equation)] := opr;
    RealCalculate(Equation);
    buffer := '';
    Equation := ResultNum;
  end;
end;

procedure TOperatorState.handleBracket(opr: Char);
begin
  //运算符后只能加左括号
  with FOwner do
  begin
    if opr = '(' then
    begin
      Equation := Equation + opr;
      Inc(BracketMatch);
      buffer := opr;                                    //delphi支持string:=char
    end;
  end;
end;

procedure TOperatorState.handleDecimalDot;
begin
  with FOwner do
  begin
    Equation := Equation + '0.';
    //这里添加0的话，可以在小数点状态转换到运算符状态时，有一个0*num的正确计算
    buffer := '0.';
    ResultNum := buffer;
  end;
end;

procedure TDecimalDotState.handleNumber(opr: Char);
begin
  with FOwner do
  begin
    Equation := Equation + opr;
    buffer := buffer + opr;
    ResultNum := buffer;
  end;
end;

procedure TDecimalDotState.handleResult(opr: Char);
begin
  with FOwner do
  begin
    Equation[length(Equation)] := opr;
    RealCalculate(Equation);
    buffer := '';
    Equation := ResultNum;
  end;
end;

procedure TDecimalDotState.handleOperator(opr: Char);
begin
  with FOwner do
  begin
    Equation[Length(Equation)] := opr;
    buffer := opr;
    RealCalculate(Equation);
  end;
end;

procedure TDecimalDotState.handleBack;
begin
  inherited;
  with FOwner do
  begin
    Equation := Copy(Equation, 1, Length(Equation)-1);
    buffer := copy(buffer, 1, Length(buffer)-1);
    ResultNum := buffer;
  end;
end;

//括号状态类
procedure TBracketState.handleNumber(opr: Char);
begin
  with FOwner do
  begin
    Equation := Equation + opr;
    buffer := opr;
    ResultNum := buffer;
  end;
end;

procedure TBracketState.handleOperator(opr: Char);
begin
  with FOwner do
  begin
    if buffer = ')' then
    begin
      Equation := Equation + opr;
      buffer := opr;
      RealCalculate(Equation);
    end;
  end;
end;

procedure TBracketState.handleDecimalDot;
begin
  with FOwner do
  begin
    Equation := Equation + '0.';
    buffer := '0.';
    ResultNum := buffer;
  end;
end;

procedure TBracketState.handleBracket(opr: Char);
begin
  with FOwner do
  begin
    if (opr = ')') and (buffer = '(') then
    begin
      handleBack;
    end
    else if (opr = '(') and (buffer = '(') then
    begin
      Equation := Equation + opr;
      buffer := opr;
    end
    else if (opr = ')') and (BracketMatch > 0) then
    begin
      Equation := Equation + opr;
      Buffer := ')';
      RealCalculate(Equation);
    end;
  end;
end;

procedure TBracketState.handleResult(opr: Char);
begin
  with FOwner do
  begin
    Equation := Equation + opr;
    RealCalculate(Equation);
    buffer := '';
    Equation := ResultNum;
  end;
end;

procedure TBracketState.handleBack;
begin
  with FOwner do
  begin
    Equation := Copy(Equation, 1, Length(Equation)-1);
    buffer := '';
  end;
end;

procedure TResultState.handleNumber(opr: Char);
begin
  //“等于”状态虽然和运算符状态一样都是计算，但不同的地方是“等于状态”在输入数字时，
  //应该是用新的数字直接替换旧的数字
  with FOwner do
  begin
    Equation := opr;
    buffer := opr;
    ResultNum := buffer;
  end;
end;

procedure TResultState.handleOperator(opr: Char);
begin
  with FOwner do
  begin
    Equation := Equation + opr;
    Buffer := opr;
    RealCalculate(Equation);
  end;
end;

procedure TResultState.handleDecimalDot;
begin
  with FOwner do
  begin
    Equation := '0.';
    buffer := '0.';
    ResultNum := buffer;
  end;
end;

procedure TResultState.handleBracket(opr: Char);
begin
  with FOwner do
  begin
    if opr = '(' then
    begin
      Equation := opr;
      Inc(BracketMatch);
      buffer :=  '(';
      ResultNum := '';
    end;
  end;
end;

procedure TResultState.handleBack;
begin
  handleClear;
end;

procedure TResultState.handleClear;
begin
  inherited;
end;

procedure TClearState.handleNumber(opr: Char);
begin
  with FOwner do
  begin
    Equation := opr;
    buffer := opr;
    ResultNum := buffer;
  end;
end;

procedure TClearState.handleBracket(opr: Char);
begin
  with FOwner do
  begin
    if opr = '(' then
    begin
      Equation := opr;
      Inc(BracketMatch);
      buffer :=  opr;
    end;
  end;
end;

procedure TClearState.handleDecimalDot;
begin
  with FOwner do
  begin
    Equation := '0.';
    buffer := '0.';
    ResultNum := buffer;
  end;
end;

procedure TClearState.handleBack;
begin
  with FOwner do
  begin
    Equation := '哎呦,你干嘛';
    ResultNum := '';
  end;
end;

end.

