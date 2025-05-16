unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Grids, ComCtrls,
  ExtCtrls, Buttons, LCLType, LCLIntf, Menus, Types;

type
  { TAddressRecord }
  TAddressRecord = record
    Name: string;
    Telephone: string;
    Postcode: string;
    Street: string;
  end;

  { TForm1 }
  TForm1 = class(TForm)
    btnImport: TButton;
    btnClearFilters: TButton;
    edtFilterName: TEdit;
    edtFilterTelephone: TEdit;
    edtFilterPostcode: TEdit;
    lblFilterName: TLabel;
    lblFilterTelephone: TLabel;
    lblFilterPostcode: TLabel;
    lblStatus: TLabel;
    pnlTop: TPanel;
    pnlFilters: TPanel;
    pnlGrid: TPanel;
    pnlStatus: TPanel;
    sgAddresses: TStringGrid;
    btnEdit: TButton;
    btnDelete: TButton;
    dlgOpen: TOpenDialog;
    pnlButtons: TPanel;
    procedure btnClearFiltersClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure btnImportClick(Sender: TObject);
    procedure edtFilterNameChange(Sender: TObject);
    procedure edtFilterTelephoneChange(Sender: TObject);
    procedure edtFilterPostcodeChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FAddressData: array of TAddressRecord;
    FFilteredData: array of Integer; // Indices into FAddressData
    procedure InitializeGrid;
    procedure LoadCSVFile(const AFilename: string);
    procedure ApplyFilters;
    procedure UpdateGrid;
    procedure SetStatus(const AMessage: string);
  public
    
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}



{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  InitializeGrid;
  SetStatus('Bereit. Klicken Sie auf "Datenbank importieren", um Adressdaten zu laden.');
end;

procedure TForm1.InitializeGrid;
begin
  with sgAddresses do
  begin
    // Set up grid columns
    ColCount := 4; // Name, Telephone, Postcode, Street
    RowCount := 1; // Just the header row initially
    
    // Set column headers
    Cells[0, 0] := 'Name';
    Cells[1, 0] := 'Telefon';
    Cells[2, 0] := 'PLZ';
    Cells[3, 0] := 'Straße';
    
    // Set column widths
    ColWidths[0] := 300; // Name
    ColWidths[1] := 200; // Telephone
    ColWidths[2] := 100; // Postcode
    ColWidths[3] := 300; // Street
    
    // Clean modern styling
    Font.Size := 10;
    TitleFont.Size := 10;
    DefaultRowHeight := 30;
    RowHeights[0] := 35; // Header row
    AlternateColor := $00F8F8F8; // Very light gray for alternating rows
    
    // Grid options
    Options := Options + [goRowSelect, goThumbTracking, goColSizing] - [goRangeSelect];
    FixedCols := 0;
    FixedRows := 1;
    TitleFont.Style := [fsBold];
    TitleFont.Size := 10;
  end;
end;

procedure TForm1.btnImportClick(Sender: TObject);
var
  OldCursor: TCursor;
begin
  dlgOpen.Filter := 'CSV-Dateien (*.csv)|*.csv|Alle Dateien (*.*)|*.*';
  dlgOpen.Title := 'Adressdatenbank-Datei auswählen';
  
  if dlgOpen.Execute then
  begin
    // Show loading
    OldCursor := Screen.Cursor;
    Screen.Cursor := crHourGlass;
    btnImport.Enabled := False;
    btnClearFilters.Enabled := False;
    btnEdit.Enabled := False;
    btnDelete.Enabled := False;
    
    SetStatus('Daten werden geladen, bitte warten...');
    Application.ProcessMessages;
    
    try
      // Load the data
      LoadCSVFile(dlgOpen.FileName);
      ApplyFilters;
      UpdateGrid;
      SetStatus(Format('Erfolgreich %d Adressen geladen.', [Length(FAddressData)]));
    except
      on E: Exception do
        SetStatus('Fehler beim Laden der Datei: ' + E.Message);
    end;
    
    // Restore normal cursor and enable buttons
    Screen.Cursor := OldCursor;
    btnImport.Enabled := True;
    btnClearFilters.Enabled := True;
    btnEdit.Enabled := True;
    btnDelete.Enabled := True;
  end;
end;

procedure TForm1.LoadCSVFile(const AFilename: string);
var
  FileLines: TStringList;
  Line, NameVal, TelVal, PlzVal, StreetVal: string;
  i, LineCount: Integer;
  NameCol, TelCol, PlzCol, StreetCol, VornameCol, VorwahlCol: Integer;
  Parts: array of string;
  j, PartCount: Integer;
  InQuote: Boolean;
  CurrentPart: string;
  c: Char;
begin
  // Clear existing data
  SetLength(FAddressData, 0);
  
  FileLines := TStringList.Create;
  try
    FileLines.LoadFromFile(AFilename);
    LineCount := FileLines.Count;
    
    if LineCount > 0 then
    begin


      NameCol := 2;     // Name  : 3 column
      TelCol := 6;      // Telefon : 7 column
      PlzCol := 4;      // PLZ : 5  column
      StreetCol := 5;   // Strasse :  6     column
      VornameCol := 8;  // Vorname : 9    column
      VorwahlCol := 9;  // Vorwahl : 10  column
      
      // skip header
      SetLength(FAddressData, LineCount - 1);
      
      for i := 1 to LineCount - 1 do
      begin
        Line := FileLines[i];
        
        // Parse the CSV line manually to handle quotes correctly
        SetLength(Parts, 0);
        InQuote := False;
        CurrentPart := '';
        
        for j := 1 to Length(Line) do
        begin
          c := Line[j];
          
          if c = '"' then
            InQuote := not InQuote
          else if (c = ';') and not InQuote then
          begin
            // End of field
            SetLength(Parts, Length(Parts) + 1);
            Parts[Length(Parts) - 1] := CurrentPart;
            CurrentPart := '';
          end
          else
            CurrentPart := CurrentPart + c;
        end;
        
        // Add the last part
        if CurrentPart <> '' then
        begin
          SetLength(Parts, Length(Parts) + 1);
          Parts[Length(Parts) - 1] := CurrentPart;
        end;
        
        PartCount := Length(Parts);
        

        if (PartCount > NameCol) and (PartCount > TelCol) and (PartCount > PlzCol) then
        begin

          NameVal := Parts[NameCol];
          if (PartCount > VornameCol) and (Parts[VornameCol] <> '') then
            NameVal := Parts[VornameCol] + ' ' + NameVal;
          

          TelVal := Parts[TelCol];
          if (PartCount > VorwahlCol) and (Parts[VorwahlCol] <> '') then
            TelVal := Parts[VorwahlCol] + ' ' + TelVal;
          

          PlzVal := Parts[PlzCol];
          

          if (PartCount > StreetCol) then
            StreetVal := Parts[StreetCol]
          else
            StreetVal := '';
          

          FAddressData[i - 1].Name := NameVal;
          FAddressData[i - 1].Telephone := TelVal;
          FAddressData[i - 1].Postcode := PlzVal;
          FAddressData[i - 1].Street := StreetVal;
        end
        else
        begin

          FAddressData[i - 1].Name := 'Row ' + IntToStr(i);
          FAddressData[i - 1].Telephone := '';
          FAddressData[i - 1].Postcode := '';
          FAddressData[i - 1].Street := '';
        end;
      end;
    end;
  finally
    FileLines.Free;
  end;
  
  // Debug info
  if Length(FAddressData) > 0 then
    SetStatus(Format('%d Adressen geladen. Erster Name: %s', [Length(FAddressData), FAddressData[0].Name]))
  else
    SetStatus('Keine Daten geladen');
end;



procedure TForm1.ApplyFilters;
var
  i: Integer;
  NameFilter, TelephoneFilter, PostcodeFilter: string;
  MatchesFilter: Boolean;
begin
  SetLength(FFilteredData, 0);
  
  NameFilter := LowerCase(Trim(edtFilterName.Text));
  TelephoneFilter := LowerCase(Trim(edtFilterTelephone.Text));
  PostcodeFilter := LowerCase(Trim(edtFilterPostcode.Text));
  
  for i := 0 to Length(FAddressData) - 1 do
  begin
    MatchesFilter := True;
    
    // name filter
    if (NameFilter <> '') and (Pos(NameFilter, LowerCase(FAddressData[i].Name)) = 0) then
      MatchesFilter := False;
      
    //  telephone filter
    if MatchesFilter and (TelephoneFilter <> '') and 
       (Pos(TelephoneFilter, LowerCase(FAddressData[i].Telephone)) = 0) then
      MatchesFilter := False;
      
    //  postcode filter
    if MatchesFilter and (PostcodeFilter <> '') and 
       (Pos(PostcodeFilter, LowerCase(FAddressData[i].Postcode)) = 0) then
      MatchesFilter := False;
      
    if MatchesFilter then
    begin
      SetLength(FFilteredData, Length(FFilteredData) + 1);
      FFilteredData[Length(FFilteredData) - 1] := i;
    end;
  end;
end;

procedure TForm1.UpdateGrid;
var
  i: Integer;
begin
  with sgAddresses do
  begin
    // Update row count
    if Length(FFilteredData) > 0 then
      RowCount := Length(FFilteredData) + 1
    else
      RowCount := 2; // Header + 'No data' row
      
    // Clear grid data
    for i := 1 to RowCount - 1 do
    begin
      Cells[0, i] := '';
      Cells[1, i] := '';
      Cells[2, i] := '';
      Cells[3, i] := '';
    end;
    
    // Fill grid with filtered data
    if Length(FFilteredData) > 0 then
    begin
      for i := 0 to Length(FFilteredData) - 1 do
      begin
        Cells[0, i + 1] := FAddressData[FFilteredData[i]].Name;
        Cells[1, i + 1] := FAddressData[FFilteredData[i]].Telephone;
        Cells[2, i + 1] := FAddressData[FFilteredData[i]].Postcode;
        Cells[3, i + 1] := FAddressData[FFilteredData[i]].Street;
      end;
    end
    else
    begin
      // empty search ùessage
      Cells[0, 1] := 'Keine passenden Datensätze gefunden';
    end;
    
    Invalidate;
  end;
end;

procedure TForm1.SetStatus(const AMessage: string);
begin
  lblStatus.Caption := AMessage;
  Application.ProcessMessages;
end;

procedure TForm1.edtFilterNameChange(Sender: TObject);
begin
  ApplyFilters;
  UpdateGrid;
end;

procedure TForm1.edtFilterTelephoneChange(Sender: TObject);
begin
  ApplyFilters;
  UpdateGrid;
end;

procedure TForm1.edtFilterPostcodeChange(Sender: TObject);
begin
  ApplyFilters;
  UpdateGrid;
end;

procedure TForm1.btnClearFiltersClick(Sender: TObject);
begin
  edtFilterName.Clear;
  edtFilterTelephone.Clear;
  edtFilterPostcode.Clear;
  
  ApplyFilters;
  UpdateGrid;
end;



procedure TForm1.btnEditClick(Sender: TObject);
var
  SelectedRow: Integer;
  DataIndex: Integer;
  NewName, NewTelephone, NewPostcode, NewStreet: string;
begin
  SelectedRow := sgAddresses.Row;
  
  // Check if a valid row is selected
  if (SelectedRow > 0) and (SelectedRow < sgAddresses.RowCount) and 
     (Length(FFilteredData) > 0) and (SelectedRow - 1 < Length(FFilteredData)) then
  begin
    DataIndex := FFilteredData[SelectedRow - 1];
    
    // Get current values
    NewName := FAddressData[DataIndex].Name;
    NewTelephone := FAddressData[DataIndex].Telephone;
    NewPostcode := FAddressData[DataIndex].Postcode;
    NewStreet := FAddressData[DataIndex].Street;
    
    //  input dialog for editing
    if InputQuery('Adresse bearbeiten', 'Name:', NewName) and
       InputQuery('Telefon bearbeiten', 'Telefon:', NewTelephone) and
       InputQuery('PLZ bearbeiten', 'PLZ:', NewPostcode) and
       InputQuery('Straße bearbeiten', 'Straße:', NewStreet) then
    begin
      // Update the data
      FAddressData[DataIndex].Name := NewName;
      FAddressData[DataIndex].Telephone := NewTelephone;
      FAddressData[DataIndex].Postcode := NewPostcode;
      FAddressData[DataIndex].Street := NewStreet;
      
      // Refresh the display
      ApplyFilters;
      UpdateGrid;
      SetStatus('Datensatz erfolgreich aktualisiert.');
    end;
  end
  else
    SetStatus('Bitte wählen Sie einen Datensatz zum Bearbeiten aus.');
end;

procedure TForm1.btnDeleteClick(Sender: TObject);
var
  SelectedRow, DataIndex, i: Integer;
begin
  SelectedRow := sgAddresses.Row;
  
  // Check if a valid row is selected
  if (SelectedRow > 0) and (SelectedRow < sgAddresses.RowCount) and 
     (Length(FFilteredData) > 0) and (SelectedRow - 1 < Length(FFilteredData)) then
  begin
    if MessageDlg('Bestätigen', 'Sind Sie sicher, dass Sie diesen Datensatz löschen möchten?', 
                  mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      DataIndex := FFilteredData[SelectedRow - 1];
      
      // Remove record
      for i := DataIndex to Length(FAddressData) - 2 do
        FAddressData[i] := FAddressData[i + 1];
        
      SetLength(FAddressData, Length(FAddressData) - 1);
      
      // Refresh grid
      ApplyFilters;
      UpdateGrid;
      SetStatus('Datensatz erfolgreich gelöscht.');
    end;
  end
  else
    SetStatus('Bitte wählen Sie einen Datensatz zum Löschen aus.');
end;

end.

