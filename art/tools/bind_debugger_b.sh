#!/usr/bin/env bash
# Adds UW_DebuggerB's Verse fields and binds each to its widgets (after build_debugger_b.py).
# message fields drive Text, float fields drive RenderOpacity (on/off states), PageIndex drives
# the Pages switcher. Field names differ from widget names: a field named like a widget clashes.
set -uo pipefail
CT="C:/Users/Chip/.claude/plugins/cache/agent-kit/agent-kit/0.26.0/skills/uefn/scripts/ct.sh"
W="/76e8e788-bf61-4537-8f86-b062e519fb2d/DreamDebugger/UW_DebuggerB.UW_DebuggerB"
export MSYS_NO_PATHCONV=1

add() {   # add <field> <type> <default>
  bash "$CT" VerseFieldsToolset.VerseFieldsToolset AddVerseField "{\"widgetBlueprint\":{\"refPath\":\"$W\"},\"fieldName\":\"$1\",\"spec\":{\"type\":\"$2\",\"defaultValue\":\"$3\",\"visibility\":\"Public\",\"writeAccess\":\"\",\"bIsVar\":true}}" | head -c 200
  echo "  <- add $1"
}
bind() {  # bind <field> <widget> <property>
  bash "$CT" VerseFieldsToolset.VerseFieldsToolset BindWidgetPropertyToVerseField "{\"widgetBlueprint\":{\"refPath\":\"$W\"},\"verseFieldName\":\"$1\",\"targetWidget\":{\"refPath\":\"$W:WidgetTree.$2\"},\"widgetPropertyPath\":\"$3\"}" | head -c 200
  echo "  <- bind $1 -> $2.$3"
}
msg() {   # msg <field> <widget>...
  local f="$1"; shift
  add "$f" message ""
  for w in "$@"; do bind "$f" "$w" Text; done
}
opa() {   # opa <field> <default> <widget>
  add "$1" float "$2"
  bind "$1" "$3" RenderOpacity
}

msg PatientNameText PatientName
msg PatientAkaText PatientAka
msg PatientInfoText PatientInfo
msg LayerText LayerNumber
msg LayerTitleText LayerTitle
msg TakeText TakeNumber
msg MainTitleText MainTitle
msg MainBadgeText MainBadge
opa MainBadgeOpacity 0.0 MainBadgeWrap
for i in 0 1 2 3; do
  msg "Tag${i}Text" "Tag${i}"
  msg "Entry${i}Text" "Entry${i}"
done
msg MoreCountText MoreButtonCount MoreButtonInkCount
msg FileButtonLabel FileButtonText FileButtonInkText
msg LogPrevText LogPrev
msg LogCurrentText LogCurrent
msg SpeakAskText SpeakAsk
msg MenuIntroText MenuIntro
for i in 0 1 2 3 4; do
  msg "Option${i}Label" "Option${i}Text" "Option${i}InkText"
done
msg FooterFileText FooterFile
msg FooterHintText FooterHint

opa LumiOpacity 0.0 LumiOn
for i in 0 1 2; do opa "Vital${i}Opacity" 0.0 "Vital${i}"; done
opa MoreOpacity 0.0 MoreButton
opa MoreFocusOpacity 0.0 MoreButtonFocus
opa FileFocusOpacity 1.0 FileButtonFocus
opa ContinueOpacity 0.0 Continue
opa SpeakOpacity 0.0 Speak
for i in 0 1 2 3 4; do
  opa "Option${i}Opacity" 0.0 "Option${i}"
  opa "Option${i}FocusOpacity" 0.0 "Option${i}Focus"
done

add PageIndex int 0
bind PageIndex Pages ActiveWidgetIndex

bash "$CT" UMGToolSet.UMGToolSet CompileWidgetBlueprint "{\"widgetBlueprint\":{\"refPath\":\"$W\"}}" | head -c 600; echo
