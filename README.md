# Fileaway

## Configuration

The configuration file should be located in `~/.fileaway/destinations.json` and follow the format:

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
    ...
}
```
