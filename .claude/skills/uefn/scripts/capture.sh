#!/bin/bash
# Git Bash on Windows: keep /Game-style asset paths from being rewritten as file paths.
export MSYS_NO_PATHCONV=1 MSYS2_ARG_CONV_EXCL="*"
# Render the editor world from a camera and save a PNG (engine coordinates, cm / degrees).
# usage: capture.sh <out.png> <x> <y> <z> <pitch> <yaw> [fov]
D="$(cd "$(dirname "$0")" && pwd)"
OUT="$1"; shift
WORLD=$("$D/ct.sh" EditorToolset.LevelToolset GetCurrentLevel | python -c "import json,sys;p=json.load(sys.stdin)['returnValue'];print(p+'.'+p.rsplit('/',1)[1])")
ARGS=$(python -c "import json,sys;x,y,z,p,yw=map(float,sys.argv[2:7]);f=float(sys.argv[7]) if len(sys.argv)>7 else 75.0;print(json.dumps({'world':{'refPath':sys.argv[1]},'camera':{'location':{'x':x,'y':y,'z':z},'rotation':{'pitch':p,'yaw':yw,'roll':0},'fOV':f},'mode':'Lit','options':{'width':1280,'height':720}}))" "$WORLD" "$@")
"$D/ct.sh" SceneCaptureToolset.SceneCaptureToolset Capture "$ARGS" | python -c "
import sys,re,base64
s=sys.stdin.read(); m=re.search(r'([A-Za-z0-9+/=]{2000,})',s)
if m: open(sys.argv[1],'wb').write(base64.b64decode(m.group(1))); print('saved', sys.argv[1])
else: print(s[:800]); sys.exit(1)
" "$OUT"
