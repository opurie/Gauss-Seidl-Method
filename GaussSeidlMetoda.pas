unit GaussSeidlMetoda;

interface

uses
  SysUtils,
  OwnType, IntervalArithmetic32and64;

function ZStworzMacierzA(data: matrixString): matrix;
procedure ZWypiszMacierz(data: matrix);
function ZStworzVectorB(data: matrixString): vector;
function ZStworzVectorX(data: matrixString): vector;
procedure ZWypiszVector(data: vector);
procedure ZGaussSeidel(n: Integer; var a: matrix; var b: vector; mit: Integer;
  eps: extended; var x: vector; var it, st: Integer);

function iZStworzMacierzA(data: matrixString): imatrix;
procedure iZWypiszMacierz(data: imatrix);
function iZStworzVectorB(data: matrixString): ivector;
function iZStworzVectorX(data: matrixString): ivector;
procedure iZWypiszVector(data: ivector);
procedure iZGaussSeidel(n: Integer; var a: imatrix; var b: ivector;
  mit: Integer; eps: interval; var x: ivector; var it, st: Integer);

implementation

function ZliczZnakString(source: String; x: Char): Integer;
var
  c: Char;
begin
  Result := 0;
  for c in source do
    if c = x then
      Inc(Result);
end;

function UtworzInterval(input: string): interval;
var
  iter: cardinal;
  temp, left, right: string;
  output: interval;
  c : char;
begin
  temp := '';
  if (ZliczZnakString(input, ';') = 0) then
  begin
    output := int_read(input);
  end else begin
    for c in input do
    begin
      if (c = ';') then
      begin
        left := temp;
        temp := '';
      end else begin
        temp := temp + c;
      end;
    end;
    right := temp;
    output.a := left_read(left);
    output.b := right_read(right);
  end;
  Result := output;
end;

function ZStworzMacierzA(data: matrixString): matrix;
var
  i, j, n, m: cardinal;
begin
  n := Length(data) - 1;
  m := Length(data[0]) - 1;
  SetLength(Result, n, m);
  for i := 1 to n do
    for j := 1 to m do
    begin
      Result[i - 1, j - 1] := StrToFloat(data[j, i]);
    end;
end;

function iZStworzMacierzA(data: matrixString): imatrix;
var
  i, j, n, m: cardinal;
begin
  n := Length(data) - 1;
  m := Length(data[0]) - 1;
  SetLength(Result, n, m);
  for i := 1 to n do
    for j := 1 to m do
    begin
      Result[i - 1, j - 1] := UtworzInterval(data[j, i]);
    end;
end;

procedure ZWypiszMacierz(data: matrix);
var
  i, j, n, m: cardinal;
begin
  n := Length(data) - 1;
  m := Length(data[0]) - 1;
  for i := 0 to n do
    for j := 0 to m do
    begin
      Writeln(Format('%d %d => %e', [i, j, data[i][j]]));
    end;
end;

procedure iZWypiszMacierz(data: imatrix);
var
  i, j, n, m: cardinal;
  l, r: string;
begin
  n := Length(data) - 1;
  m := Length(data[0]) - 1;
  for i := 0 to n do
    for j := 0 to m do
    begin
      iends_to_strings(data[i][j], l, r);
      Writeln(Format('%d %d => %s ; %s', [i+1, j+1, l, r]));
    end;
end;

function ZStworzVectorB(data: matrixString): vector;
var
  i, n: cardinal;
begin
  n := Length(data[0]) - 1;
  SetLength(Result, n);
  for i := 1 to n do
  begin
    Result[i - 1] := StrToFloat(data[0, i]);
  end;
end;

function iZStworzVectorB(data: matrixString): ivector;
var
  i, n: cardinal;
begin
  n := Length(data[0]) - 1;
  SetLength(Result, n);
  for i := 1 to n do
  begin
    Result[i - 1] := UtworzInterval(data[0, i]);
  end;
end;

function ZStworzVectorX(data: matrixString): vector;
var
  i, n: cardinal;
begin
  n := Length(data) - 1;
  SetLength(Result, n);
  for i := 1 to n do
  begin
    Result[i - 1] := StrToFloat(data[i, 0]);
  end;
end;

function iZStworzVectorX(data: matrixString): ivector;
var
  i, n: cardinal;
begin
  n := Length(data) - 1;
  SetLength(Result, n);
  for i := 1 to n do
  begin
    Result[i - 1] := UtworzInterval(data[i, 0]);
  end;
end;

procedure ZWypiszVector(data: vector);
var
  i, n: cardinal;
begin
  n := Length(data) - 1;
  for i := 0 to n do
  begin
    Writeln(Format('%d => %e', [i, data[i]]));
  end;
end;

procedure iZWypiszVector(data: ivector);
var
  i, n: cardinal;
  l, r: string;
begin
  n := Length(data) - 1;
  for i := 0 to n do
  begin
    iends_to_strings(data[i], l, r);
    Writeln(Format('%d => %s ; %s', [i, l, r]));
  end;
end;

procedure ZGaussSeidel(n: Integer; var a: matrix; var b: vector; mit: Integer;
  eps: extended; var x: vector; var it, st: Integer);
{ --------------------------------------------------------------------------- }
{ }
{ The procedure GaussSeidel solves a system of linear equations by the }
{ Gauss-Seidel iterative method. }
{ Data: }
{ n   - number of equations = number of unknowns, }
{ a   - a two-dimensional array containing elements of the matrix of the }
{ system (changed on exit), }
{ b   - a one-dimensional array containing free terms of the system }
{ (changed on exit), }
{ mit - maximum number of iterations in the Gauss-Seidel method, }
{ eps - relative accuracy of the solution, }
{ x   - an array containing an initial approximation to the solution }
{ (changed on exit). }
{ Results: }
{ x  - an array containing the solution, }
{ it - number of iterations. }
{ Other parameters: }
{ st - a variable which within the procedure GaussSeidel is assigned the }
{ value of: }
{ 1, if n<1, }
{ 2, if the matrix of the system is singular, }
{ 3, if the desired accuracy of the solution is not achieved in }
{ mit iteration steps, }
{ 0, otherwise. }
{ Note: If st=1 or st=2, then the elements of array x are not }
{ changed on exit. If st=3, then x contains the last }
{ approximation to the solution. }
{ Unlocal identifiers: }
{ vector - a type identifier of extended array [q1..qn], where q1<=1 and }
{ qn>=n, }
{ matrix - a type identifier of extended array [q1..qn,q1..qn], where }
{ q1<=1 and qn>=n. }
{ }
{ --------------------------------------------------------------------------- }
var
  i, ih, k, kh, khh, lz1, lz2: Integer;
  max, r: extended;
  cond: Boolean;
  x1: vector;
begin
  SetLength(x1, n);
  if n < 1 then
    st := 1
  else
  begin
    st := 0;
    cond := true;
    for k := 1 to n do
      x1[k - 1] := 0;
    repeat
      lz1 := 0;
      khh := 0;
      for k := 1 to n do
      begin
        lz2 := 0;
        if a[k - 1, k - 1] = 0 then
        begin
          kh := k;
          for i := 1 to n do
            if a[i - 1, k - 1] = 0 then
              lz2 := lz2 + 1;
          if lz2 > lz1 then
          begin
            lz1 := lz2;
            khh := kh
          end
        end
      end;
      if khh = 0 then
        cond := false
      else
      begin
        max := 0;
        for i := 1 to n do
        begin
          r := abs(a[i - 1, khh - 1]);
          if (r > max) and (x1[i - 1] = 0) then
          begin
            max := r;
            ih := i
          end
        end;
        if max = 0 then
          st := 2
        else
        begin
          for k := 1 to n do
          begin
            r := a[khh - 1, k - 1];
            a[khh - 1, k - 1] := a[ih - 1, k - 1];
            a[ih - 1, k - 1] := r
          end;
          r := b[khh - 1];
          b[khh - 1] := b[ih - 1];
          b[ih - 1] := r;
          x1[khh - 1] := 1
        end
      end;
    until not cond or (st = 2);
    if not cond then
    begin
      it := 0;
      repeat
        it := it + 1;
        if it > mit then
        begin
          st := 3;
          it := it - 1
        end else begin
          for i := 1 to n do
          begin
            r := b[i - 1];
            for k := 1 to i - 1 do
              r := r - a[i - 1, k - 1] * x[k - 1];
            for k := i + 1 to n do
              r := r - a[i - 1, k - 1] * x1[k - 1];
            x1[i - 1] := r / a[i - 1, i - 1]
          end;
          cond := true;
          i := 0;
          repeat
            i := i + 1;
            max := abs(x[i - 1]);
            r := abs(x1[i - 1]);
            if max < r then
              max := r;
            if max <> 0 then
              if abs(x[i - 1] - x1[i - 1]) / max >= eps then
                cond := false;
          until (i = n) or not cond;
          for i := 1 to n do
            x[i - 1] := x1[i - 1]
        end;
      until (st = 3) or cond;
    end
  end
end;

(*
  ****************************************
  ***************!INTERVAL!***************
  ****************************************
*)

procedure iZGaussSeidel(n: Integer; var a: imatrix; var b: ivector;
  mit: Integer; eps: interval; var x: ivector; var it, st: Integer);
{ ---------------------------------------------------------------------------

  The procedure GaussSeidel solves a system of linear equations by the
  Gauss-Seidel iterative method.
  Data:
  n   - number of equations = number of unknowns,
  a   - a two-dimensional array containing elements of the matrix of the
  system (changed on exit),
  b   - a one-dimensional array containing free terms of the system
  (changed on exit),
  mit - maximum number of iterations in the Gauss-Seidel method,
  eps - relative accuracy of the solution,
  x   - an array containing an initial approximation to the solution
  (changed on exit).
  Results:
  x  - an array containing the solution,
  it - number of iterations.
  Other parameters:
  st - a variable which within the procedure GaussSeidel is assigned the
  value of:
  1, if n<1,
  2, if the matrix of the system is singular,
  3, if the desired accuracy of the solution is not achieved in
  mit iteration steps,
  0, otherwise.
  Note: If st=1 or st=2, then the elements of array x are not
  changed on exit. If st=3, then x contains the last
  approximation to the solution.
  Unlocal identifiers:
  vector - a type identifier of interval array [q1..qn], where q1<=1 and
  qn>=n,
  matrix - a type identifier of interval array [q1..qn,q1..qn], where
  q1<=1 and qn>=n.

  --------------------------------------------------------------------------- }

var
  i, ih, k, kh, khh, lz1, lz2: Integer;
  max, r: interval;
  cond: Boolean;
  x1: ivector;
  _0, _1: interval;
begin

  _0 := int_read('0');
  _1 := int_read('1');
  SetLength(x1, n);
  if n < 1 then
    st := 1
  else
  begin
    st := 0;
    cond := true;
    for k := 1 to n do
      x1[k - 1] := _0;
    repeat
      lz1 := 0;
      khh := 0;
      for k := 1 to n do
      begin
        lz2 := 0;
        if a[k - 1, k - 1] = _0 then
        begin
          kh := k;
          for i := 1 to n do
            if a[i - 1, k - 1] = _0 then
              lz2 := lz2 + 1;
          if lz2 > lz1 then
          begin
            lz1 := lz2;
            khh := kh
          end
        end
      end;
      if khh = 0 then
        cond := false
      else
      begin
        max := _0;
        for i := 1 to n do
        begin
          r := iabs(a[i - 1, khh - 1]);
          if (r > max) and (x1[i - 1] = _0) then
          begin
            max := r;
            ih := i
          end
        end;
        if max = _0 then
          st := 2
        else
        begin
          for k := 1 to n do
          begin
            r := a[khh - 1, k - 1];
            a[khh - 1, k - 1] := a[ih - 1, k - 1];
            a[ih - 1, k - 1] := r
          end;
          r := b[khh - 1];
          b[khh - 1] := b[ih - 1];
          b[ih - 1] := r;
          x1[khh - 1] := _1;
        end
      end;
    until not cond or (st = 2);
    if not cond then
    begin
      it := 0;
      repeat
        it := it + 1;
        if it > mit then
        begin
          st := 3;
          it := it - 1
        end else begin
          for i := 1 to n do
          begin
            r := b[i - 1];
            for k := 1 to i - 1 do
              r := r - a[i - 1, k - 1] * x[k - 1];
            for k := i + 1 to n do
              r := r - a[i - 1, k - 1] * x1[k - 1];
            x1[i - 1] := r / a[i - 1, i - 1]
          end;
          cond := true;
          i := 0;
          repeat
            i := i + 1;
            max := iabs(x[i - 1]);
            r := iabs(x1[i - 1]);
            if max < r then
              max := r;
            if NotZero(max) then
              if iabs(x[i - 1] - x1[i - 1]) / max >= eps then
                cond := false;
          until (i = n) or not cond;
          for i := 1 to n do
            x[i - 1] := x1[i - 1]
        end;
      until (st = 3) or cond;
    end
  end

end;

end.
