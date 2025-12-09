# Explicit Naming Convention Policy

## Core Philosophy
**Clarity > Brevity.**
You must strictly avoid shorthand, abbreviations, and acronyms in variable names, function names, arguments, and class definitions. All identifiers must be fully spelled out English words.

## Forbidden Patterns (Strict)
Do not use the following common abbreviations. You must use the full equivalent:

| Abbreviation (FORBIDDEN) | Full Term (REQUIRED) |
| :--- | :--- |
| `err` | `error` |
| `req` | `request` |
| `res`, `resp` | `response` |
| `ctx` | `context` |
| `cfg`, `conf` | `config`, `configuration` |
| `idx`, `ndx` | `index` |
| `elem`, `el` | `element` |
| `val` | `value` |
| `fn`, `func` | `function` |
| `arg` | `argument` |
| `param` | `parameter` |
| `auth` | `authentication` |
| `db` | `database` |
| `msg` | `message` |
| `ret` | `returnValue`, `result` |
| `btn` | `button` |
| `img` | `image` |

## Naming Rules

1.  **Descriptive Verbosity**: Variable names should describe *what* the variable holds, not just its type.
    * *Bad:* `const list = []`
    * *Good:* `const activeUserAccounts = []`

2.  **Booleans**: Must use clear prefixes.
    * *Bad:* `valid`, `done`, `open`
    * *Good:* `isValid`, `isFinished`, `isOpen`, `hasAccess`

3.  **Iterators**: Avoid single-letter variables in complex loops.
    * *Acceptable:* `i`, `j` (Only in loops spanning < 3 lines)
    * *Required:* `userIndex`, `rowIndex`, `itemIndex` (In nested or long loops)

## AI Behavior Instructions
1.  If you encounter existing shorthand in the codebase (e.g., `err`), you should refactor it to the full name (`error`) when modifying that block of code, unless explicitly instructed to preserve legacy style.
2.  When generating new code, never introduce new abbreviations.
3.  If a standard library usually uses shorthand (e.g., Go's `if err != nil`), you are overruled: use `if error != nil` or a specific error name like `validationError`.