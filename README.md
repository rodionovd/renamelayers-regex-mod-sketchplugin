## ReNaMeLaYeRs.sketchplugin

Adds support for uppercase/lowercase/capitalize transformations for RegEx capture groups in the "Rename All..." panel:

<img width="818" alt="Screenshot 2025-05-18 at 11 23 58" src="https://github.com/user-attachments/assets/cb9b684d-9e65-4677-add1-d6d4d273d1f5" />

### Usage

The plugin starts working automatically once installed.

Say, you have a regex `(.+)` that captures the entire layer name as a single group (`$1`, or in case also `$0`). Here're the new options available in the pattern field:

| Input | Template | Output | Description
| --- | --- | --- | --- |
| "Rectangle" | `$1` | "Rectangle" | The original behavior, no changes here
| "Rectangle" | `$^1` | "RECTANGLE" | Makes the entire capture group uppercased
| "Rectangle" | `$.1` | "rectangle" | Makes the entire capture group lowercased
| "my layer" | `$-1` | "My Layer" | Capitalizes the entire capture group
