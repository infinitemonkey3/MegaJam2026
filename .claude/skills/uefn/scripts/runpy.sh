#!/bin/bash
# Git Bash on Windows: keep /Game-style asset paths from being rewritten as file paths.
export MSYS_NO_PATHCONV=1 MSYS2_ARG_CONV_EXCL="*"
# Run a Python file in the UEFN editor (unreal module preloaded; top-level await allowed).
# usage: runpy.sh <script.py>
D="$(cd "$(dirname "$0")" && pwd)"
ARGS=$(python -c "import json,sys;print(json.dumps({'script':{'content':open(sys.argv[1],encoding='utf-8').read(),'language':'Python'}}))" "$1")
"$D/ct.sh" editor_toolset.toolsets.python_scripting.PythonScriptingTools execute_python "$ARGS" | python -c "
import json,sys
s=sys.stdin.read()
try: r=json.loads(s); print(r.get('returnValue', r))
except Exception: print(s)
"
