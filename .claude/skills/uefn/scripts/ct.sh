#!/bin/bash
# Git Bash on Windows: keep /Game-style asset paths from being rewritten as file paths.
export MSYS_NO_PATHCONV=1 MSYS2_ARG_CONV_EXCL="*"
# Call one toolset tool on the UEFN MCP server.
# usage: ct.sh <Toolset.Name> <ToolName> '<json args>'
# e.g.   ct.sh VerseToolset.VerseToolset BuildAll
D="$(cd "$(dirname "$0")" && pwd)"
A=$(python -c "import json,sys;print(json.dumps({'toolset_name':sys.argv[1],'tool_name':sys.argv[2],'arguments':json.loads(sys.argv[3])}))" "$1" "$2" "${3:-{\}}")
"$D/mcp.sh" call_tool "$A"
