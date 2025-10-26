---
name: jira-cli
description: Manage Jira issues via command line - read issues, query by filters, create/update issues, add comments, and close issues after work completion.
---

# jira-cli: Command-Line Jira Management

Use jira-cli when interacting with Jira. Assume jira-cli already installed/configured.

**Project flag:** Always use `-p PROJ` to specify project explicitly (don't rely on defaults)

## When to Use

**Use for:** Reading issues, querying (status/priority/assignee filters), creating/updating issues, adding comments, closing after work complete

**Ask user for web UI:** Attachments/images, visual board operations (can't do from CLI)

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

## When to Load Detailed Guide

Load [jira-cli reference guide](./reference/jira-cli-reference.md) for:
- Command syntax and flags
- Query patterns and JQL filtering
- Output format options
- User intent → command mapping
- Git integration patterns
