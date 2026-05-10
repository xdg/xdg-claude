# jira-cli

A Claude Code plugin that adds a knowledge skill for managing Jira issues from the command line via the `jira-cli` tool.

## What it does

Ships a single Type 1 (knowledge) skill that teaches Claude how to drive `jira-cli` for common workflows: reading issues, querying by filter, creating and updating issues, adding comments, and closing issues after work completion.

The skill loads only when Claude detects a Jira-related task. Detailed command reference lives in `skills/jira-cli/reference/jira-cli-reference.md` and is consulted on demand rather than loaded upfront.

## Prerequisites

Requires [`jira-cli`](https://github.com/ankitpokhrel/jira-cli) installed and authenticated against your Jira instance. The plugin does not bundle or configure the binary.

## Installation

```bash
claude plugin install jira-cli@xdg-claude
```

Requires the `xdg-claude` marketplace to be added first; see the [top-level README](../README.md#installation).
