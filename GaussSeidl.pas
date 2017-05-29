unit GaussSeidl;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.ExtCtrls,
  Vcl.StdCtrls,
  Vcl.DBCtrls, Vcl.Grids, Vcl.DBGrids, Vcl.Mask,
  StrUtils,
  IntervalArithmetic32and64, OwnType;

type
  TFormGUI = class(TForm)
    PanelText: TPanel;
    PageControl1: TPageControl;
    Przedzialowa: TTabSheet;
    PanelControl: TPanel;
    StatusBar: TStatusBar;
    Zmiennoprzecinkowa: TTabSheet;
    UpDownLiczbaZmiennych: TUpDown;
    EditLiczbaZmiennych: TEdit;
    LabelLiczbaZmiennych: TLabel;
    ButtonStworzTabele: TButton;
    ButtonDodajZmienna: TButton;
    ButtonUsunZmienna: TButton;
    ButtonWyczyscTabele: TButton;
    Dane: TTabSheet;
    DrawGridDane: TDrawGrid;
    RadioGroupMetoda: TRadioGroup;
    ButtonOblicz: TButton;
    LabelLiczbaIteracji: TLabel;
    LabelDokladnosc: TLabel;
    EditLiczbaIteracji: TEdit;
    EditDokladnosc: TEdit;
    UpDownLiczbaIteracji: TUpDown;
    UpDownDokladnosc: TUpDown;
    ButtonPrzyklad: TButton;
    EditPrzyklad: TEdit;
    UpDownPrzyklad: TUpDown;
    RichEditPrzedzialowa: TRichEdit;
    RichEditZmiennoprzecinkowa: TRichEdit;
    procedure EditLiczbaZmiennychChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ButtonStworzTabeleClick(Sender: TObject);
    procedure ButtonDodajZmiennaClick(Sender: TObject);
    procedure ButtonUsunZmiennaClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure ButtonWyczyscTabeleClick(Sender: TObject);
    procedure DrawGridDaneDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure DrawGridDaneSetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: string);
    procedure DrawGridDaneGetEditText(Sender: TObject; ACol, ARow: Integer;
      var Value: string);
    procedure DrawGridDaneKeyPress(Sender: TObject; var Key: Char);
    procedure DrawGridDaneSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure ButtonObliczClick(Sender: TObject);
    procedure EditLiczbaIteracjiChange(Sender: TObject);
    procedure EditDokladnoscChange(Sender: TObject);
    procedure ButtonPrzykladClick(Sender: TObject);
    procedure EditPrzykladChange(Sender: TObject);

  private
    function SprawdzPoprawnoscDanych(): Boolean;
    function ZliczZnakString(source: String; x: Char): Integer;
    procedure UzupelnijTabele(przyklad: cardinal);
    procedure DodajElementData();
    procedure UsunElementData();
    procedure StworzTabele(n: Integer);
    procedure WyczyscTabele();
    procedure StatusSend(text: String);
    procedure DodajLinieRichEdit(RichEdit: TRichEdit; color: Tcolor;
      size: Integer; text: String);
    procedure ObliczZmiennoprzecinkowa();
    procedure ObliczPrzedzialowa();
  public
    { Public declarations }
  end;

const
  TEXT_PADDING = 5;
  STATUS_W_TOKU = 'W toku...';
  STATUS_GOTOWY = 'Gotowy!';
  TEXT_ZMIENNOPRZECINKOWA = 'Wyniki dla arytmetyki zmiennoprzecinkowej:';
  TEXT_PRZEDZIALOWA = 'Wyniki dla arytmetyki przedzia³owej:';
  DATA_NULL = '*****';

var
  FormGUI: TFormGUI;
  data: matrixString;
  vectorX: vector;
  mit: cardinal;
  eps: Extended;
  nGauss: Integer;

implementation

{$R *.dfm}

uses
  GaussSeidlMetoda;

procedure TFormGUI.FormCreate(Sender: TObject);
var
  ProgressBarStyle: Integer;
begin
  // Stworzenie poprawnej tabeli danych.
  StworzTabele(StrToInt(EditLiczbaZmiennych.text));
  UzupelnijTabele(2);
  // Zaznaczenie pierwszej opcji z wyboru metody
  RadioGroupMetoda.ItemIndex := 0;
  // ustawienie nazwy wyniku dla zmiennoprzecinkowej i przedzialowej
  PageControl1.Pages[2].Caption := TEXT_ZMIENNOPRZECINKOWA;
  RichEditZmiennoprzecinkowa.Clear;
  PageControl1.Pages[1].Caption := TEXT_PRZEDZIALOWA;
  RichEditPrzedzialowa.Clear;
  // ustawienie focusu na zakladke dane
  PageControl1.ActivePageIndex := 0;
end;

procedure TFormGUI.FormResize(Sender: TObject);
begin
  // obliczanie szerokoœci ProgressBara aby ³adnie wygl¹da³ przy resize
  StatusBar.Panels[2].Width := Width -
    (StatusBar.Panels[0].Width + StatusBar.Panels[1].Width + StatusBar.Panels[3]
    .Width + 20);
end;

procedure TFormGUI.StatusSend(text: String);
begin
  StatusBar.Panels[3].text := text;
  Application.ProcessMessages; // aby odœwie¿yæ tekst
end;

procedure TFormGUI.DodajLinieRichEdit(RichEdit: TRichEdit; color: Tcolor;
  size: Integer; text: String);
begin
  RichEdit.SelAttributes.color := color;
  RichEdit.SelAttributes.size := size;
  RichEdit.SelAttributes.Style := [];
  RichEdit.Lines.Add(text);
end;

function TFormGUI.SprawdzPoprawnoscDanych: Boolean;
var
  i, j, n, m, k: cardinal;
  liczby: TStringList;
begin
  n := Length(data) - 1;
  m := Length(data[0]) - 1;
  for i := 0 to n do
    for j := 0 to m do
    begin
      if (i = 0) and (j = 0) then
        Continue;
      liczby := TStringList.Create;
      // dzieli zawartoœæ komórki na osobne liczby oddzielone ';'
      ExtractStrings([';'], [' '], PChar(data[i][j]), liczby);
      if ((liczby.Count > 2) or (liczby.Count < 1)) then
      begin
        ShowMessage(Format('Znaleziono niepoprawne dane "%s"' + sLineBreak +
          'Równanie: %d' + sLineBreak + 'Zmienna: %d', [data[i, j], j, i]));
        Result := false;
        exit;
      end else begin
        try
          try
            if (liczby.Count = 1) then
            begin
              StrToFloat(liczby[0]);
            end else if (liczby.Count = 2) then
            begin
              if (StrToFloat(liczby[0]) > StrToFloat(liczby[1])) then
              begin
                ShowMessage
                  (Format('Nie poprawny przedzia³! Lewy koniec jest wiêkszy od prawego! "%s"'
                  + sLineBreak + 'Równanie: %d' + sLineBreak + 'Zmienna: %d',
                  [data[i, j], j, i]));
                Result := false;
                exit;
              end;
            end;
          except
            on EConvertError do
            begin
              ShowMessage(Format('Znaleziono niepoprawne dane "%s"' + sLineBreak
                + 'Równanie: %d' + sLineBreak + 'Zmienna: %d',
                [data[i, j], j, i]));
              Result := false;
              exit;
            end;
          end;
        finally
          liczby.Free;
        end;
      end;
    end;
  Result := true;
end;

function TFormGUI.ZliczZnakString(source: String; x: Char): Integer;
var
  c: Char;
begin
  Result := 0;
  for c in source do
    if c = x then
      Inc(Result);
end;

// Edycja liczby zmiennych
procedure TFormGUI.EditDokladnoscChange(Sender: TObject);
begin
  begin
    try
      // zapewnienie aby nie by³o mniej ni¿ 1
      if StrToFloat(EditLiczbaZmiennych.text) < -16 then
      begin
        EditLiczbaZmiennych.text := '-16';
      end else if (StrToInt(EditLiczbaZmiennych.text) > 6) then
      begin
        EditLiczbaZmiennych.text := '6';
      end
    except
      on EConvertError do
        ShowMessage('To nie jest w³aœciwa liczba! (<-16;6>)');
    end;
  end;
end;

procedure TFormGUI.EditLiczbaIteracjiChange(Sender: TObject);
begin
  try
    // zapewnienie aby nie by³o mniej ni¿ 1
    if StrToInt(EditLiczbaZmiennych.text) = 0 then
    begin
      EditLiczbaZmiennych.text := '1';
    end else if (StrToInt(EditLiczbaZmiennych.text) > 10000) then
    begin
      EditLiczbaZmiennych.text := '10000';
    end
  except
    on EConvertError do
      ShowMessage('To nie jest w³aœciwa liczba! (<1;10000>)');
  end;
end;

procedure TFormGUI.EditLiczbaZmiennychChange(Sender: TObject);
begin
  try
    // zapewnienie aby nie by³o mniej ni¿ 1
    if StrToInt(EditLiczbaZmiennych.text) = 0 then
    begin
      EditLiczbaZmiennych.text := '1';
    end else if (StrToInt(EditLiczbaZmiennych.text) > 1000) then
    begin
      EditLiczbaZmiennych.text := '1000';
    end
  except
    on EConvertError do
      ShowMessage('To nie jest w³aœciwa liczba! (<1;1000>)');
  end;
end;

procedure TFormGUI.EditPrzykladChange(Sender: TObject);
begin
  begin
    try
      // zapewnienie aby nie by³o mniej ni¿ 1
      if StrToFloat(EditPrzyklad.text) < UpDownPrzyklad.Min then
      begin
        EditPrzyklad.text := IntToStr(UpDownPrzyklad.Min);;
      end else if (StrToInt(EditPrzyklad.text) > UpDownPrzyklad.Max) then
      begin
        EditPrzyklad.text := IntToStr(UpDownPrzyklad.Max);
      end
    except
      on EConvertError do
        ShowMessage('To nie jest w³aœciwa liczba!');
    end;
  end;
end;

procedure TFormGUI.DodajElementData();
var
  n, m: cardinal;
begin
  n := Length(data) + 1;
  m := Length(data) + 1;
  SetLength(data, n, m);
  EditLiczbaZmiennych.text := IntToStr(n - 1);
  DrawGridDane.ColCount := DrawGridDane.ColCount + 1;
  DrawGridDane.RowCount := DrawGridDane.RowCount + 1;
  DrawGridDane.Invalidate;
end;

procedure TFormGUI.ButtonPrzykladClick(Sender: TObject);
begin
  UzupelnijTabele(StrToInt(EditPrzyklad.text));
  PageControl1.ActivePageIndex := 0;
end;

procedure TFormGUI.ButtonDodajZmiennaClick(Sender: TObject);
begin
  // dodanie zmiennej do tabeli
  StatusSend(STATUS_W_TOKU);
  DodajElementData();
  StatusSend(STATUS_GOTOWY);
end;

procedure TFormGUI.StworzTabele(n: Integer);
var
  i, j: Integer;
begin
  // ustawienie ProgressBara  i StatusBara
  StatusSend(STATUS_W_TOKU);
  // Wyczyszczenie zawartoœci tabeli
  WyczyscTabele();
  // usuniecie tabeli z danymi
  SetLength(data, 0, 0);
  // Stworzenie poprawnej tabeli danych.
  n := StrToInt(EditLiczbaZmiennych.text);
  SetLength(data, n + 1, n + 1);
  for i := 0 to n do
    for j := 0 to n do
    begin
      if (j = 0) and (i = 0) then
      begin
        data[i, j] := '-----';
      end else if ((j = 0) and (i <> 0)) then
      begin
        data[i, j] := '0';
      end
      else
        data[i, j] := '';
    end;

  DrawGridDane.DefaultColWidth := 80;
  DrawGridDane.DefaultRowHeight := 20;
  DrawGridDane.RowCount := n + 2;
  DrawGridDane.ColCount := n + 2;
  DrawGridDane.Invalidate;
  StatusSend(STATUS_GOTOWY);
end;

procedure TFormGUI.ObliczZmiennoprzecinkowa();
var
  macierzA: matrix;
  vectorB, vectorX: vector;
  it, st, i: Integer;
  prec: Integer;
begin

  // wlasciwa czesc
  macierzA := ZStworzMacierzA(data);
  ZWypiszMacierz(macierzA);
  vectorB := ZStworzVectorB(data);
  ZWypiszVector(vectorB);
  vectorX := ZStworzVectorX(data);
  ZWypiszVector(vectorX);
  mit := StrToInt(EditLiczbaIteracji.text);
  eps := StrToFloat('1e' + EditDokladnosc.text);
  prec := -StrToInt(EditDokladnosc.text);
  nGauss := StrToInt(EditLiczbaZmiennych.text);
  ZGaussSeidel(nGauss, macierzA, vectorB, mit, eps, vectorX, it, st);

  Writeln(Format('it=%d, st=%d', [it, st]));
  RichEditZmiennoprzecinkowa.Clear;
  if (st = 0) then
  begin
    for i := 0 to Length(vectorX) - 1 do
    begin
      DodajLinieRichEdit(RichEditZmiennoprzecinkowa, clGreen, 8,
        Format('X%d = %e', [i + 1, vectorX[i]]));
    end;
  end else if (st = 1) then
  begin
    DodajLinieRichEdit(RichEditZmiennoprzecinkowa, clRed, 14,
      'Za ma³a liczba zmiennych!');
    DodajLinieRichEdit(RichEditZmiennoprzecinkowa, clRed, 14, 'Brak wyniku!');
    ShowMessage('B³¹d danych!' + sLineBreak + 'Za ma³a liczba zmiennych!');
  end else if (st = 2) then
  begin
    DodajLinieRichEdit(RichEditZmiennoprzecinkowa, clRed, 14,
      'Macierz z danymi jest osobliwa!');
    DodajLinieRichEdit(RichEditZmiennoprzecinkowa, clRed, 14, 'Brak wyniku!');
    ShowMessage('B³¹d danych!' + sLineBreak +
      'Macierz z danymi jest osobliwa!');
  end else if (st = 3) then
  begin
    DodajLinieRichEdit(RichEditZmiennoprzecinkowa, clRed, 14,
      'Nieosi¹gniêto zadanej dok³adnoœci rozwi¹zania!');
    ShowMessage('B³¹d wyniku!' + sLineBreak +
      'Nieosi¹gniêto zadanej dok³adnoœci rozwi¹zania!!');
    for i := 0 to Length(vectorX) - 1 do
    begin
      DodajLinieRichEdit(RichEditZmiennoprzecinkowa, clBlue, 8,
        Format('X%d = %e', [i + 1, vectorX[i]]));

    end;
  end;

end;

procedure TFormGUI.ObliczPrzedzialowa();
var
  macierzA: imatrix;
  vectorB, vectorX: ivector;
  it, st, i: Integer;
  ieps: interval;
  l, r: string;
begin
  // wlasciwa czesc
  macierzA := iZStworzMacierzA(data);
  iZWypiszMacierz(macierzA);
  vectorB := iZStworzVectorB(data);
  iZWypiszVector(vectorB);
  vectorX := iZStworzVectorX(data);
  iZWypiszVector(vectorX);
  mit := StrToInt(EditLiczbaIteracji.text);
  eps := StrToFloat('1e' + EditDokladnosc.text);
  ieps := int_read(FloatToStr(eps));
  nGauss := StrToInt(EditLiczbaZmiennych.text);
  iZGaussSeidel(nGauss, macierzA, vectorB, mit, eps, vectorX, it, st);

  Writeln(Format('it=%d, st=%d', [it, st]));
  RichEditPrzedzialowa.Clear;
  if (st = 0) then
  begin
    for i := 0 to Length(vectorX) - 1 do
    begin
      iends_to_strings(vectorX[i], l, r);
      DodajLinieRichEdit(RichEditPrzedzialowa, clGreen, 8,
        Format('X%d = [%s' + #9'; %s]', [i + 1, l, r]));
    end;
  end else if (st = 1) then
  begin
    DodajLinieRichEdit(RichEditPrzedzialowa, clRed, 14,
      'Za ma³a liczba zmiennych!');
    DodajLinieRichEdit(RichEditPrzedzialowa, clRed, 14, 'Brak wyniku!');
    ShowMessage('B³¹d danych!' + sLineBreak + 'Za ma³a liczba zmiennych!');
  end else if (st = 2) then
  begin
    DodajLinieRichEdit(RichEditPrzedzialowa, clRed, 14,
      'Macierz z danymi jest osobliwa!');
    DodajLinieRichEdit(RichEditPrzedzialowa, clRed, 14, 'Brak wyniku!');
    ShowMessage('B³¹d danych!' + sLineBreak +
      'Macierz z danymi jest osobliwa!');
  end else if (st = 3) then
  begin
    DodajLinieRichEdit(RichEditPrzedzialowa, clRed, 14,
      'Nieosi¹gniêto zadanej dok³adnoœci rozwi¹zania!');
    ShowMessage('B³¹d wyniku!' + sLineBreak +
      'Nieosi¹gniêto zadanej dok³adnoœci rozwi¹zania!!');
    for i := 0 to Length(vectorX) - 1 do
    begin
      iends_to_strings(vectorX[i], l, r);
      DodajLinieRichEdit(RichEditPrzedzialowa, clBlue, 8,
        Format('X%d = [%s' + #9'; %s]', [i + 1, l, r]));
    end;
  end;

end;

procedure TFormGUI.ButtonObliczClick(Sender: TObject);

begin
  if (SprawdzPoprawnoscDanych) then
  begin
    if (RadioGroupMetoda.ItemIndex = 0) then
    begin
      StatusSend(STATUS_W_TOKU);
      RichEditPrzedzialowa.Clear;
      RichEditPrzedzialowa.SelAttributes.color := clBlack;
      RichEditPrzedzialowa.text := TEXT_PRZEDZIALOWA;
      ObliczPrzedzialowa;
      PageControl1.ActivePageIndex := 1;
      StatusSend(STATUS_GOTOWY);
    end else if (RadioGroupMetoda.ItemIndex = 1) then
    begin
      StatusSend(STATUS_W_TOKU);
      RichEditZmiennoprzecinkowa.Clear;
      RichEditZmiennoprzecinkowa.SelAttributes.color := clBlack;
      RichEditZmiennoprzecinkowa.text := TEXT_ZMIENNOPRZECINKOWA;
      ObliczZmiennoprzecinkowa;
      PageControl1.ActivePageIndex := 2;
      StatusSend(STATUS_GOTOWY);
    end;

  end

end;

procedure TFormGUI.ButtonStworzTabeleClick(Sender: TObject);
begin
  // Stworzenie poprawnej tabeli danych.
  StworzTabele(StrToInt(EditLiczbaZmiennych.text));
end;

procedure TFormGUI.UsunElementData();
var
  n, m: cardinal;
begin
  n := Length(data) - 1;
  m := Length(data) - 1;
  if (n < 2) or (m < 2) then
    exit;

  SetLength(data, n, m);
  EditLiczbaZmiennych.text := IntToStr(n - 1);
  DrawGridDane.ColCount := DrawGridDane.ColCount - 1;
  DrawGridDane.RowCount := DrawGridDane.RowCount - 1;
  DrawGridDane.Invalidate;
end;

procedure TFormGUI.ButtonUsunZmiennaClick(Sender: TObject);
begin
  StatusSend(STATUS_W_TOKU);
  UsunElementData();
  StatusSend(STATUS_GOTOWY);
end;

procedure TFormGUI.WyczyscTabele();
var
  n, m: Integer;
begin
  // czysci tabele z danymi
  n := DrawGridDane.ColCount;
  m := DrawGridDane.RowCount;
  SetLength(data, 0, 0);
  SetLength(data, n, m);
  DrawGridDane.Invalidate;
end;

procedure TFormGUI.ButtonWyczyscTabeleClick(Sender: TObject);
begin
  StatusSend(STATUS_W_TOKU);
  WyczyscTabele();
  StatusSend(STATUS_GOTOWY);
end;

procedure TFormGUI.DrawGridDaneDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  s: String; // co wpisaæ w pole
  grid: TDrawGrid;
begin
  if Length(data) = 0 then // gdy brak danych to wyjscie
  begin
    exit;
  end;
  grid := TDrawGrid(Sender); // castowanie sendera
  if (ACol = 0) and (ARow = 0) then // naroznik
  begin
    s := DATA_NULL;
    grid.Canvas.Font.color := clGray; // kolor
  end else if (ACol = 0) and (ARow = 1) then
  begin
    s := Format('Przybli¿enia', [ARow]);
    grid.Canvas.Font.color := clOlive; // kolor
  end else if (ACol = 0) and (ARow > 0) then // nag³ówki wierszy
  begin
    s := Format('R%d', [ARow - 1]);
    grid.Canvas.Font.color := clTeal; // kolor
  end else if (ARow = 0) and (ACol = 1) then // pierwsza kolumna
  begin
    s := 'Wynik';
    grid.Canvas.Font.color := clMaroon; // kolor
  end else if (ARow = 0) and (ACol > 1) then // nag³ówki kolumn
  begin
    s := Format('X%d', [ACol - 1]);
    grid.Canvas.Font.color := clTeal; // kolor
  end else if (ACol = 1) then
  begin
    grid.Canvas.Font.color := clMaroon; // kolor
    s := data[ACol - 1, ARow - 1]; // a jak nie to to co w data
  end else if (ARow = 1) then
  begin
    grid.Canvas.Font.color := clOlive; // kolor
    s := data[ACol - 1, ARow - 1]; // a jak nie to to co w data
  end
  else
    s := data[ACol - 1, ARow - 1]; // a jak nie to to co w data
  // ustawienie rysowania z paddingiem
  grid.Canvas.TextOut(Rect.Left + TEXT_PADDING, Rect.Top + TEXT_PADDING, s);
end;

procedure TFormGUI.DrawGridDaneGetEditText(Sender: TObject; ACol, ARow: Integer;
  var Value: string);
begin
  if (ACol = 1) and (ARow = 1) then
    Value := DATA_NULL;
  // ustawienie na to co by³o w tabeli
  Value := data[ACol - 1, ARow - 1];
end;

procedure TFormGUI.DrawGridDaneKeyPress(Sender: TObject; var Key: Char);
begin
  // nie pozwolenie na wpisanie innych klawiszy ni¿ numeryczne
  if not(CharInSet(Key, ['0' .. '9', ',', #8, #9, ';', '-'])) then
  begin
    Key := #27; // je¿eli inny to zast¹p go "ESC"
  end;
end;

procedure TFormGUI.DrawGridDaneSelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
begin

  // Uaktualnienie StatusBara dla R i X
  if not((ACol <> 0) and (ARow <> 0)) then
  begin
    StatusBar.Panels[0].text := 'R: nazwa'; // nag³owek wiersz
    StatusBar.Panels[1].text := 'X: nazwa'; // nag³owek kolumna
  end else if (ARow = 1) then
  begin
    StatusBar.Panels[0].text := 'Przybli¿enia';
    // numer przyblizenia
    if (ACol = 1) then
    begin
      StatusBar.Panels[1].text := '';
    end
    else
      StatusBar.Panels[1].text := 'X: ' + IntToStr(ACol - 1);
    // ktore przyblizenie
  end else if (ACol = 1) and (ARow > 0) then // dla pierwszej kolumny
  begin
    StatusBar.Panels[0].text := 'R: ' + IntToStr(ARow - 1); // numer równania
    StatusBar.Panels[1].text := 'Wynik'; // wynik
  end else if (ARow = 1) then
  begin
    StatusBar.Panels[0].text := 'Przybli¿enia';
    // numer przyblizenia
    StatusBar.Panels[1].text := 'X: ' + IntToStr(ACol - 1);
    // ktore przyblizenie
  end
  else // dla reszty
  begin
    StatusBar.Panels[0].text := 'R: ' + IntToStr(ARow - 1); // numer równania
    StatusBar.Panels[1].text := 'X: ' + IntToStr(ACol - 1); // numer zmiennej X
  end;
end;

procedure TFormGUI.DrawGridDaneSetEditText(Sender: TObject; ACol, ARow: Integer;
  const Value: string);
var
  liczby: TStringList;
  i: cardinal;
  czyZapisac: Boolean;
begin
  czyZapisac := true;
  i := 0;
  liczby := TStringList.Create;
  if (ACol = 1) and (ARow = 1) then
  begin
    data[ACol - 1, ARow - 1] := DATA_NULL;
    exit;
  end;
  try
    try
      // dla wierszy inne ni¿ nag³ówkowe
      if (ACol > 0) and (ARow > 0) then
        // dla nie pustych ci¹gów
        if (Value <> '') then
        begin
          // je¿eli wiêcej ni¿ 1 œrednik
          if (ZliczZnakString(Value, ';') > 1) then
          begin
            // usuniêcie nieprawid³owego znaku
            raise Exception.Create('Maksymalnie dwie liczby!')
          end else begin
            if (Value = ';') then
            begin
              // nie podano lewego konca przedzialu
              raise Exception.Create('Nie podano lewego przedzia³u!')
            end;
            // dzieli zawartoœæ komórki na osobne liczby oddzielone ';'
            ExtractStrings([';'], [' '], PChar(Value), liczby);
          end;

          // dla kazdej liczby sprawdzamy poprawnoœæ
          for i := 0 to liczby.Count - 1 do
          begin
            // zakladamy ze liczba jest zla
            czyZapisac := false;
            // jezeli pierwszy znak to '-' to nic nie rób
            if not(liczby[i] = '-') then
            begin
              // poprawna liczba
              czyZapisac := true;
              // proba konwersji na etapie wpisywania
              StrToFloat(liczby[i]);
            end;
          end;
          if (czyZapisac) then
          begin
            // aktualizacja tabeli
            data[ACol - 1, ARow - 1] := Value;
          end
          else
            data[ACol - 1, ARow - 1] := '';
        end
        else
          data[ACol - 1, ARow - 1] := Value;
    except
      on EConvertError do
      begin
        // pokazanie wiadomoœci
        ShowMessage('Wpisano z³¹ liczbê! (' + liczby[i] + ')');
      end;
    end;
  finally
    liczby.Free;
  end;
end;

procedure TFormGUI.UzupelnijTabele(przyklad: cardinal);
var
  i, j, n, m: cardinal;
begin
  case przyklad of
    1:
      begin
        n := 4 + 1;
        m := 4 + 1;
        nGauss := m - 1;
        EditLiczbaZmiennych.text := IntToStr(m - 1);
        SetLength(data, n, m);
        data[0][0] := DATA_NULL;
        data[0][1] := '1';
        data[0][2] := '1';
        data[0][3] := '1';
        data[0][4] := '1';

        data[1][0] := '0';
        data[1][1] := '0';
        data[1][2] := '2';
        data[1][3] := '7';
        data[1][4] := '0';

        data[2][0] := '0';
        data[2][1] := '0';
        data[2][2] := '1';
        data[2][3] := '3';
        data[2][4] := '5';

        data[3][0] := '0';
        data[3][1] := '1';
        data[3][2] := '0';
        data[3][3] := '0';
        data[3][4] := '0';

        data[4][0] := '0';
        data[4][1] := '2';
        data[4][2] := '2';
        data[4][3] := '1';
        data[4][4] := '0';

        EditLiczbaIteracji.text := '100';
        EditDokladnosc.text := '-14';
        DrawGridDane.ColCount := n + 1;
        DrawGridDane.RowCount := m + 1;
        DrawGridDane.Invalidate;
      end;
    2:
      begin
        n := 4 + 1;
        m := 4 + 1;
        nGauss := m - 1;
        EditLiczbaZmiennych.text := IntToStr(m - 1);
        SetLength(data, n, m);
        data[0][0] := DATA_NULL;
        data[0][1] := '0,956';
        data[0][2] := '51,5603';
        data[0][3] := '2';
        data[0][4] := '5,8';

        data[1][0] := '2';
        data[1][1] := '-12,235';
        data[1][2] := '1,229';
        data[1][3] := '0,5597';
        data[1][4] := '0';

        data[2][0] := '0,75';
        data[2][1] := '1,229';
        data[2][2] := '-6,78';
        data[2][3] := '0,765';
        data[2][4] := '0';

        data[3][0] := '-1';
        data[3][1] := '0,5597';
        data[3][2] := '0,765';
        data[3][3] := '91,0096';
        data[3][4] := '-2';

        data[4][0] := '0,9';
        data[4][1] := '0';
        data[4][2] := '0';
        data[4][3] := '2';
        data[4][4] := '5,5';
        EditLiczbaIteracji.text := '10';
        EditDokladnosc.text := '-14';
        DrawGridDane.ColCount := n + 1;
        DrawGridDane.RowCount := m + 1;
        DrawGridDane.Invalidate;
      end;
    3:
      begin
        n := 4 + 1;
        m := 4 + 1;
        nGauss := m - 1;
        EditLiczbaZmiennych.text := IntToStr(m - 1);
        SetLength(data, n, m);
        data[0][0] := DATA_NULL;
        data[0][1] := '0,956';
        data[0][2] := '51,5603';
        data[0][3] := '2';
        data[0][4] := '5,8';

        data[1][0] := '2';
        data[1][1] := '-12,235';
        data[1][2] := '1,229';
        data[1][3] := '0,5597';
        data[1][4] := '0';

        data[2][0] := '0,75';
        data[2][1] := '1,229';
        data[2][2] := '-6,78';
        data[2][3] := '0,765';
        data[2][4] := '0';

        data[3][0] := '-1';
        data[3][1] := '0,5597';
        data[3][2] := '0,765';
        data[3][3] := '91,0096';
        data[3][4] := '-2';

        data[4][0] := '0,9';
        data[4][1] := '0';
        data[4][2] := '0';
        data[4][3] := '2';
        data[4][4] := '5,5';
        EditLiczbaIteracji.text := '50';
        EditDokladnosc.text := '-14';
        DrawGridDane.ColCount := n + 1;
        DrawGridDane.RowCount := m + 1;
        DrawGridDane.Invalidate;
      end;
    4:
      begin
        n := 2 + 1;
        m := 2 + 1;
        nGauss := m - 1;
        EditLiczbaZmiennych.text := IntToStr(m - 1);
        SetLength(data, n, m);
        data[0][0] := DATA_NULL;
        data[0][1] := '8';
        data[0][2] := '10';

        data[1][0] := '1';
        data[1][1] := '3';
        data[1][2] := '2';

        data[2][0] := '1';
        data[2][1] := '2';
        data[2][2] := '6';

        EditLiczbaIteracji.text := '20';
        EditDokladnosc.text := '-3';
        DrawGridDane.ColCount := n + 1;
        DrawGridDane.RowCount := m + 1;
        DrawGridDane.Invalidate;
      end;
    5:
      begin
        n := 4 + 1;
        m := 4 + 1;
        nGauss := m - 1;
        EditLiczbaZmiennych.text := IntToStr(m - 1);
        SetLength(data, n, m);
        data[0][0] := DATA_NULL;
        data[0][1] := '1;1';
        data[0][2] := '1;1';
        data[0][3] := '1;1';
        data[0][4] := '1;1';

        data[1][0] := '0;0';
        data[1][1] := '0;0';
        data[1][2] := '2;2';
        data[1][3] := '7;7';
        data[1][4] := '0;0';

        data[2][0] := '0;0';
        data[2][1] := '0;0';
        data[2][2] := '1;1';
        data[2][3] := '3;3';
        data[2][4] := '5;5';

        data[3][0] := '0;0';
        data[3][1] := '1;1';
        data[3][2] := '0;0';
        data[3][3] := '0;0';
        data[3][4] := '0;0';

        data[4][0] := '0;0';
        data[4][1] := '2;2';
        data[4][2] := '2;2';
        data[4][3] := '1;1';
        data[4][4] := '0;0';
        EditLiczbaIteracji.text := '100';
        EditDokladnosc.text := '-14';
        DrawGridDane.ColCount := n + 1;
        DrawGridDane.RowCount := m + 1;
        DrawGridDane.Invalidate;
      end;
    6:
      begin
        n := 4 + 1;
        m := 4 + 1;
        nGauss := m - 1;
        EditLiczbaZmiennych.text := IntToStr(m - 1);
        SetLength(data, n, m);
        data[0][0] := DATA_NULL;
        data[0][1] := '1;1';
        data[0][2] := '1;1';
        data[0][3] := '1;1';
        data[0][4] := '1;1';

        data[1][0] := '0;0';
        data[1][1] := '0;0';
        data[1][2] := '2;2';
        data[1][3] := '7;7';
        data[1][4] := '0;0';

        data[2][0] := '0;0';
        data[2][1] := '0;0';
        data[2][2] := '1;1';
        data[2][3] := '3;3';
        data[2][4] := '5;5';

        data[3][0] := '0;0';
        data[3][1] := '1;1';
        data[3][2] := '0;0';
        data[3][3] := '0;0';
        data[3][4] := '0;0';

        data[4][0] := '0;0';
        data[4][1] := '2;2';
        data[4][2] := '2;2';
        data[4][3] := '1;1';
        data[4][4] := '0;0';
        EditLiczbaIteracji.text := '30';
        EditDokladnosc.text := '-14';
        DrawGridDane.ColCount := n + 1;
        DrawGridDane.RowCount := m + 1;
        DrawGridDane.Invalidate;
      end;
  end;
end;

end.
