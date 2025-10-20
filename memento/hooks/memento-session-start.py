#!/usr/bin/env python3
"""
Memento SessionStart hook - generates dynamic context to address context rot
"""
import json
import os
import sys

def get_plugin_root():
    """Get plugin root from environment variable"""
    return os.environ.get('CLAUDE_PLUGIN_ROOT', os.path.dirname(os.path.abspath(__file__)))

def load_boilerplate():
    """Load static boilerplate content from references"""
    plugin_root = get_plugin_root()
    boilerplate_path = os.path.join(plugin_root, 'hooks', 'references', 'memento-session-start.md')

    try:
        with open(boilerplate_path, 'r') as f:
            return f.read()
    except FileNotFoundError:
        return ""

def generate_dynamic_context():
    """Generate dynamic context based on current state"""
    # TODO: Implement dynamic context generation
    return ""

def main():
    """Main entry point for SessionStart hook"""
    boilerplate = load_boilerplate()
    dynamic_context = generate_dynamic_context()

    # Combine boilerplate and dynamic content
    content = boilerplate
    if dynamic_context:
        content += "\n\n" + dynamic_context

    # Output in SessionStart hook format
    output = {
        "hookSpecificOutput": {
            "hookEventName": "SessionStart",
            "additionalContext": content
        }
    }

    print(json.dumps(output))
    return 0

if __name__ == "__main__":
    sys.exit(main())
