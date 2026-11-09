#!/bin/bash
# Git Bash on Windows: keep /Game-style asset paths from being rewritten as file paths.
export MSYS_NO_PATHCONV=1 MSYS2_ARG_CONV_EXCL="*"
# Call a top-level tool on the UEFN editor MCP server.
# usage: mcp.sh <list_toolsets|describe_toolset|call_tool> '<json arguments>'
# Env: UEFN_MCP_URL (default http://127.0.0.1:8000/mcp)
U="${UEFN_MCP_URL:-http://127.0.0.1:8000/mcp}"
SID_FILE="${TMPDIR:-${TEMP:-/tmp}}/uefn_mcp_session_id"
H=(-H "Content-Type: application/json" -H "Accept: application/json, text/event-stream")

init() {
  local hdr; hdr=$(mktemp)
  curl -s -m 15 -D "$hdr" -X POST "$U" "${H[@]}" \
    -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"uefn-skill-curl","version":"1.0"}}}' >/dev/null \
    || { echo "ERROR: UEFN MCP server not reachable at $U (is UEFN open with the MCP server started?)" >&2; exit 2; }
  grep -i "mcp-session-id" "$hdr" | awk '{print $2}' | tr -d '\r' > "$SID_FILE"; rm -f "$hdr"
  curl -s -m 5 -X POST "$U" "${H[@]}" -H "Mcp-Session-Id: $(cat "$SID_FILE")" \
    -d '{"jsonrpc":"2.0","method":"notifications/initialized"}' >/dev/null
}

call() {
  local body
  body=$(python -c "import json,sys;print(json.dumps({'jsonrpc':'2.0','id':2,'method':'tools/call','params':{'name':sys.argv[1],'arguments':json.loads(sys.argv[2])}}))" "$1" "$2")
  curl -s -m 600 -X POST "$U" "${H[@]}" -H "Mcp-Session-Id: $(cat "$SID_FILE")" -d "$body"
}

[ -s "$SID_FILE" ] || init
OUT=$(call "$1" "${2:-{\}}")
# Re-handshake once if the editor restarted and the session id went stale.
if [ -z "$OUT" ] || echo "$OUT" | grep -qiE 'reinitialize|unknown session'; then init; OUT=$(call "$1" "${2:-{\}}"); fi
python -c "
import json,sys
s=sys.stdin.read()
try: r=json.loads(s)
except Exception: print(s); sys.exit()
if 'error' in r: print('ERROR', json.dumps(r['error'])); sys.exit(1)
res=r['result']
if res.get('isError'): print('TOOL ERROR')
for c in res.get('content',[]): print(c.get('text', json.dumps(c)))
" <<< "$OUT"
