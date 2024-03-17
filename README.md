#  Google Sheets Widget

## Data Model

We are working with `Spreadsheets`, each has some `Sheets` containing many `Cells`

```memaid
classDiagram
    Spreadsheet --> Sheet : has many
    Sheet --> Cell : has many
    class Spreadsheet{
        +String spreadsheetId
        +String name
    }
    class Sheet{
        +String title
    }
    class Cell{
        +String column
        +Int row
    }
```

## Views

- **MainView** displays list of cells we are tracking and their current values
- **FormView** displays a form allowing us to switch to different sheet and edit cells we are watching




