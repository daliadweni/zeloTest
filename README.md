# Address Database Manager

This Delphi application provides a clean and user-friendly interface for managing an address database. It allows you to load data from CSV files and provides filtering capabilities for easy data navigation.

## Features

- **Data Import**: Load address data from CSV files
- **Data Display**: View address data in a clean grid layout
- **Filtering**: Filter data by Name, Telephone Number, or Postcode
- **Data Editing**: Edit or delete existing records
- **Responsive UI**: The grid updates automatically as you type in the filter fields

## How to Use

1. **Starting the Application**: Open the application by running the compiled executable or by opening the project in Delphi and pressing F9.

2. **Importing Data**: 
   - Click the "Import Database" button
   - Select a CSV file containing address data
   - The application expects data in the format: Name, Telephone, Postcode (with or without a header row)

3. **Filtering Data**:
   - Type in any of the filter fields (Name, Telephone, Postcode)
   - The grid will update in real-time to show only matching records
   - Click "Clear Filters" to reset all filters

4. **Editing Records**:
   - Select a record in the grid
   - Click the "Edit" button or the "Edit" cell in the row
   - Enter new values in the dialog boxes

5. **Deleting Records**:
   - Select a record in the grid
   - Click the "Delete" button or the "Delete" cell in the row
   - Confirm the deletion when prompted

## Technical Details

- Built with standard Delphi VCL components
- Uses TStringGrid for data display
- Implements responsive filtering with immediate grid updates
- Handles both CSV files with or without headers
- Includes status messages to provide feedback on operations

## Project Structure

- `AddressManager.dpr`: Main project file
- `MainForm.pas`: Main form unit containing all the application logic
- `MainForm.dfm`: Form design file

## Compilation

To compile the project, open `AddressManager.dpr` in Delphi and build the project (Shift+F9) or run it (F9).
"# zeloTest" 
"# zeloTest" 
