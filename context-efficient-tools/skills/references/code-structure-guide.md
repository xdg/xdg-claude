# Code Structure Exploration

**Goal: Get outline/index of large files without reading entire file.**

## Strategy: Tiered Approach

Try tools in this order (stop when you get what you need):
1. **ast-grep** - Targeted pattern extraction (fastest when pattern known)
2. **Language-specific tools** - Best quality, language-aware
3. **ctags** - Universal fallback, simple
4. **Read file** - Last resort (but now you know it's worth it)

---

# Method 1: ast-grep (Targeted Extraction)

**Best when:** You know what patterns to look for

## JavaScript/TypeScript

### List all exported functions
```bash
ast-grep -l typescript -p 'export function $NAME($$$)' file.ts
```

### List all class definitions
```bash
ast-grep -l typescript -p 'export class $NAME { $$$ }' file.ts
```

### List all interface definitions
```bash
ast-grep -l typescript -p 'interface $NAME { $$$ }' file.ts
```

### List all type definitions
```bash
ast-grep -l typescript -p 'type $NAME = $$$' file.ts
```

### Find all imports
```bash
ast-grep -l typescript -p 'import $WHAT from $WHERE' file.ts
```

### Combine patterns for full outline
```bash
# Get exports, classes, interfaces, types in one go
ast-grep -l typescript -p 'export function $NAME($$$)' file.ts
ast-grep -l typescript -p 'export class $NAME' file.ts
ast-grep -l typescript -p 'interface $NAME' file.ts
ast-grep -l typescript -p 'type $NAME' file.ts
```

## Python

### List all function definitions
```bash
ast-grep -l python -p 'def $NAME($$$):' file.py
```

### List all class definitions
```bash
ast-grep -l python -p 'class $NAME:' file.py
ast-grep -l python -p 'class $NAME($$$):' file.py  # With inheritance
```

### List all imports
```bash
ast-grep -l python -p 'import $NAME' file.py
ast-grep -l python -p 'from $MODULE import $$$' file.py
```

## Go

### List all function definitions
```bash
ast-grep -l go -p 'func $NAME($$$) $$$ { $$$ }' file.go
```

### List all type definitions
```bash
ast-grep -l go -p 'type $NAME struct { $$$ }' file.go
ast-grep -l go -p 'type $NAME interface { $$$ }' file.go
```

### List all exported functions (capitalized)
```bash
ast-grep -l go -p 'func $NAME($$$)' file.go | rg -e '^[A-Z]'
```

## Rust

### List all function definitions
```bash
ast-grep -l rust -p 'fn $NAME($$$) { $$$ }' file.rs
ast-grep -l rust -p 'pub fn $NAME($$$) { $$$ }' file.rs  # Public only
```

### List all struct definitions
```bash
ast-grep -l rust -p 'struct $NAME { $$$ }' file.rs
```

### List all trait definitions
```bash
ast-grep -l rust -p 'trait $NAME { $$$ }' file.rs
```

---

# Method 2: Language-Specific Tools

**Best when:** Available and well-supported for the language

## Go: go doc

### List package contents
```bash
go doc ./path/to/package
```

### List specific file symbols
```bash
go doc -all ./path/to/package | rg -e '^func|^type'
```

This is ideal for Go - uses actual compiler, understands exports, very reliable.

## Python: Language-specific options

### Using Python's inspect module (if interactive)
```bash
python3 -c "import ast; import sys; tree = ast.parse(open('file.py').read()); print([node.name for node in ast.walk(tree) if isinstance(node, (ast.FunctionDef, ast.ClassDef))])"
```

More complex but accurate.

## JavaScript/TypeScript: Language Server (if available)

Some projects have LSP tooling that can extract symbols. Variable availability.

---

# Method 3: ctags/universal-ctags (Universal Fallback)

**Best when:** Need quick universal solution across languages

## Basic Usage

### Generate tags for single file
```bash
ctags -f - file.js
```
Output format: `symbol<tab>file<tab>line<tab>type`

### Common output (shows functions, classes, etc.)
```bash
ctags -f - file.ts | grep -v '^!' | cut -f1,4
```
Shows symbol names and types.

### Filter by type
```bash
# Functions only
ctags -f - file.py --kinds-Python=f

# Classes only
ctags -f - file.py --kinds-Python=c

# Functions and classes
ctags -f - file.py --kinds-Python=fc
```

### Language-specific kinds

Common types:
- `f` - functions
- `c` - classes
- `m` - methods
- `v` - variables
- `i` - interfaces (TypeScript)
- `t` - types (TypeScript/Go)

### Pretty output
```bash
ctags -f - --fields=+n file.ts | grep -v '^!' | awk '{print $4 " " $1 " (line " $3 ")"}'
```
Shows: type, name, line number

## Limitations

- May miss some language-specific constructs
- Doesn't understand semantic context
- But works across many languages with simple interface

---

# Integration Strategy

## Use Case: Explore Large Unknown File

**Step 1: Get quick outline**
```bash
# Try ast-grep with common patterns first
ast-grep -l typescript -p 'export function $NAME' file.ts
ast-grep -l typescript -p 'export class $NAME' file.ts

# Or use ctags for quick overview
ctags -f - file.ts | grep -v '^!' | cut -f1,4 | sort -u
```

**Step 2: Decide what to investigate**
Based on names, pick interesting functions/classes.

**Step 3: Use ast-grep for targeted search**
```bash
# Found "processData" function, now see how it's called
ast-grep -l typescript -p 'processData($$$)' .
```

**Step 4: Read selectively**
Now read just the relevant sections, not the entire file.

## Use Case: "What does this file export?"

```bash
# JavaScript/TypeScript
ast-grep -l typescript -p 'export $WHAT' file.ts

# Python
ast-grep -l python -p 'def $NAME($$$):' file.py | rg -e '^[^_]'  # Non-private

# Go (exported = capitalized)
go doc ./path/to/package
```

## Use Case: "What classes/interfaces are available?"

```bash
# TypeScript
ast-grep -l typescript -p 'interface $NAME { $$$ }' file.ts
ast-grep -l typescript -p 'class $NAME { $$$ }' file.ts

# Python
ast-grep -l python -p 'class $NAME' file.py

# Go
ast-grep -l go -p 'type $NAME struct { $$$ }' file.go
```

---

# Decision Flow

```
Need to understand large file?
│
├─ Know what patterns to look for? (exports, classes, etc.)
│  → Use ast-grep with specific patterns
│  → Fast, targeted, precise
│
├─ Go language file?
│  → Use `go doc` for package/file
│  → Best quality, compiler-aware
│
├─ Need universal quick outline?
│  → Use ctags
│  → Simple, works across languages
│
├─ Need detailed understanding?
│  → Read file (selectively based on outline)
│  → Use outline to guide what sections to read
│
└─ Exploring multiple files?
   → Combine: get outline of each, identify relevant ones, read those
```

---

# Best Practices

## 1. Start with Cheapest Tool
```bash
# Fast: ast-grep with known pattern
ast-grep -l typescript -p 'export function $NAME' file.ts

# Medium: ctags for overview
ctags -f - file.ts | cut -f1

# Expensive: Read entire file
# Only after outline shows it's relevant
```

## 2. Combine with grep for Filtering
```bash
# Get all functions, filter to exported (capitalized in Go)
ast-grep -l go -p 'func $NAME($$$)' file.go | rg -e '^func [A-Z]'

# Get ctags output, filter to public methods
ctags -f - file.py | rg -e '\tm\t' | rg -e '^[^_]'
```

## 3. Use Outline to Guide Detailed Reading
Don't read blindly. Get outline, identify relevant sections, then read those.

## 4. Cache Results for Large Explorations
If exploring many files:
```bash
# Generate tags for entire directory
ctags -R -f .tags .

# Query as needed
grep 'functionName' .tags
```

## 5. Verify with Read When Needed
Outlines give structure but not implementation. When you need details, read the specific section.

---

# Common Workflows

## "What's in this 2000-line file?"
```bash
# Quick outline
ast-grep -l typescript -p 'export function $NAME' large-file.ts
ast-grep -l typescript -p 'export class $NAME' large-file.ts

# Or ctags
ctags -f - large-file.ts | grep -v '^!' | cut -f1,4 | sort
```

## "Find all API endpoints in this file"
```bash
# Express.js
ast-grep -l javascript -p 'router.$METHOD($$$)' routes.js

# Or search for specific pattern
ast-grep -l javascript -p 'app.get($$$)' app.js
```

## "What classes are in this Python module?"
```bash
ast-grep -l python -p 'class $NAME:' module.py
```

## "What does this Go package export?"
```bash
go doc ./path/to/package
```

---

# Limitations and Fallbacks

## When Tools Fail

**ast-grep**: Requires knowing patterns
- Fallback: Try ctags or Read

**ctags**: May miss complex constructs
- Fallback: Use ast-grep with specific patterns or Read

**Language tools**: May not be available
- Fallback: Try ctags or ast-grep

## When to Just Read

Sometimes reading is the right answer:
- File is <500 lines
- Outline doesn't give enough context
- Need to understand implementation
- Tools don't support the language/construct

**The outline told you it's worth reading** - that's still a win.

---

# Summary

**Primary strategy: ast-grep for targeted extraction**
```bash
ast-grep -l LANG -p 'export function $NAME' file
```

**Universal fallback: ctags**
```bash
ctags -f - file | grep -v '^!' | cut -f1,4
```

**Go-specific: go doc**
```bash
go doc ./path/to/package
```

**Key principle:**
**Get outline → Decide what's relevant → Read selectively**

**Don't read 1000-line files blind. Use structure tools to guide your reading.**
