# Fileaway

## Configuration

The configuration file should be located in `file-actions.json` in the root directory, and follow the format:

```json
{
    "Apple Developer Program Invoice": {
        "variables": [
            {"name": "Date", "type": "string"}
        ],
        "destination": [
            {"type": "text", "value": "InSeven Limited/Receipts/"},
            {"type": "variable", "value": "Date"},
            {"type": "text", "value": " Apple Distribution International Apple Developer Program Invoice"}
        ]
    },
    "test all": {
        "variables": [
            {"name": "AYearMonth", "type": "date", "dateParams": {"hasDay": false}},
            {"name": "ADate", "type": "date"},
            {"name": "AString", "type": "string"}
            ],
        "destination": [
            {"type": "text", "value": "all tests/"},
            {"type": "variable", "value": "AYearMonth"},
            {"type": "variable", "value": "ADate"},
            {"type": "variable", "value": "AString"},
            {"type": "text", "value": "testing all"}
        ]
    },
    ...
}
```
