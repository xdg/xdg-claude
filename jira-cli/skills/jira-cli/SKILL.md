---
name: jira-cli
description: Manage Jira issues via the jira-cli tool.
---

# jira-cli: Command-Line Jira Management

Assume jira-cli is installed and configured.

**Project flag:** Always use `-p PROJ` to specify project explicitly (don't rely on defaults)

## Limitation

Ask the user to use the web UI for attachments/images and visual board operations -- these can't be done from the CLI.

## Core Pattern: Work on Issue

```bash
jira issue view -p PROJ PROJ-123              # Read requirements
jira issue assign PROJ-123 $(jira me)         # Assign to user
# ... implement ...
jira issue comment add PROJ-123 "Fixed in $(git rev-parse --short HEAD)"
jira issue move PROJ-123 "Done"               # Close when complete
```

## Efficient Extraction

Extract only needed fields to minimize context usage:

```bash
# Get specific fields only
jira issue view -p PROJ PROJ-123 --raw | jq -r '.fields.status.name'

# List keys for iteration
jira issue list -p PROJ --plain --no-headers --columns KEY
```

## Detailed reference

See [jira-cli reference guide](./reference/jira-cli-reference.md) for command syntax, JQL, filter flags, output formats, and data extraction patterns.
