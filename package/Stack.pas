unit Stack;

interface

type
  TStack<T> = class
  private
    FData: TArray<T>;
    FTop: Integer;
  public
    constructor Create;
    /// <summary>     入栈     </summary>
    procedure Push(const Item: T);
    /// <summary>     出栈     </summary>
    function Pop: T;
    /// <summary>     判断栈是否为空   </summary>
    function isEmpty: Boolean;
    /// <summary>     返回栈顶元素     </summary>
    function Peek: T;
    /// <summary>     清空栈内元素     </summary>
    procedure Clear;
  end;

implementation
uses
  SysUtils;

constructor TStack<T>.Create;
begin
  inherited;
  SetLength(FData, 10);
  FTop:= -1;                                                //空栈索引为-1
end;

procedure TStack<T>.Push(const Item: T);
begin
  if FTop = High(FData) then
  begin
    SetLength(FData, Length(FData) * 2);                    // 如果数组满了，需要扩容
  end;
  FTop := FTop + 1;                                         //相当于FTop:= FTop+1
  FData[FTop] := Item;
end;

function TStack<T>.Pop: T;
begin
  Result:= FData[FTop];
  Dec(FTop);
end;

function TStack<T>.isEmpty: Boolean;
begin
  Result := FTop = -1;
end;

function TStack<T>.Peek: T;
begin
  if isEmpty then
    raise Exception.Create('Peek operation failed: Stack is empty');
  Result := FData[FTop];
end;

procedure TStack<T>.Clear;
begin
  FTop := -1;
end;


end.
