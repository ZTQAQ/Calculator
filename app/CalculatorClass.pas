unit CalculatorClass;

interface

uses
  SysUtils, Stack;

type
  /// <summary>  �������  </summary>
  TCalculator = Class;

  /// <summary>  ״̬����  </summary>
  TState = class
  protected
    FOwner: TCalCulator;
    procedure handleNumber(opr: Char); virtual;        //�ڵ�ǰ״̬�¼���Ҫ���Ĺ���(ͬʱ�ᷢ��״̬�ı�)
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
    FCurrentState:  TState;                                         //��ǰ״̬
    FNumberState: TState;                                           //��Ա״̬
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
    Equation: string;                                               //�ṩ��form���ʵĵ�һ����ʾʽ��
    ResultNum: string;                                              //�ṩ��form���ʵĵڶ�����ʾ��ǰ���ֻ��߽��
    BracketMatch: Integer;                                          //������ʽ������ƥ�䣬������+1��������-1
    constructor Create;
    destructor Destroy; override;
    procedure RealCalculate(Strings: string);                       //������ʽ
    procedure ProcessEvent(AChar: Char);                            //״̬��ת
    function SymbolCompare(UpChar, DownChar: Char): Boolean;        //�������ȼ��Ƚ�
    property Buffer: string read FBuffer write FBuffer;             //�����ڶ��е���ʾ
  end;

implementation

uses
  StateClass;

//״̬����
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
  inherited Create;        //���ø��׵Ĺ��캯��
  FOwner := AOwner;
end;

procedure TState.handleBack;
begin
//���ﲻ��ֱ��ɾ��һλEquation���ַ�����Ϊ�����ʱ�ַ�Ϊ�����������Ϊ������ɾ��
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

//�������
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
  //���մ���ʾ���水ť�ؼ��������źţ��ڼ������ڲ�������Ӧ�Ĵ���
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

  //��ת״̬
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
    else                                                       //��������ʱ�Ĵ���
    begin
      //�������ջΪ�ջ�������ջ�ķ�����'('���������ȼ����ڵ���ջ����Ԫ�����ȼ�
      if (OperatorStack.isEmpty) or (Ch = '(') or (SymbolCompare(Ch, OperatorStack.Peek)) then
        OperatorStack.Push(Ch)
      //�����ʱ�ķ���Ϊ')'��ֱ�������ŵ�Ԫ�ض�Ҫ��ջ�������ջ��Ԫ����Ҫ��ʾ�����ڵڶ��е�Ԫ��(Result)
      else if Ch = ')' then
      begin
        while OperatorStack.Peek <> '(' do
        begin
          Num1 := NumberStack.Pop;
          Num2 := NumberStack.Pop;
          Symbol := OperatorStack.Pop;
          NumberStack.Push(TwoNumberDeal(Num1, Num2, Symbol));
        end;
        OperatorStack.Pop;                                     //�����ų�ջ
      end
      //�����ʱ����ջ�ķ������ȼ�С��ջ����ķ��ŵ����ȼ�
      else if SymbolCompare(Ch, OperatorStack.Peek) = False then
      begin
        while (not OperatorStack.isEmpty) and (SymbolCompare(Ch, OperatorStack.Peek) = False) do
        begin
          if OperatorStack.Peek = '(' then                     //���ڴ���(1+3=������
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
          if (Ch = '=') and (OperatorStack.isEmpty) then  //�ǡ�=���Ļ��ٶ��⴦��
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


