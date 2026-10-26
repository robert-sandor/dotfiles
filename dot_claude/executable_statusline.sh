#!/bin/sh
# Claude Code status line: model (effort) | dir | ctx% | 5h% | 7d%
exec jq -r --arg home "$HOME" '
  def pct($label): if . == null then empty else "\($label): \(round)%" end;
  (.effort.level // "") as $effort
  | [
      .model.display_name + (if $effort != "" then " (\($effort))" else "" end),
      ((.workspace.current_dir // .cwd) | if startswith($home) then "~" + .[($home | length):] else . end),
      (.context_window.used_percentage    | pct("ctx")),
      (.rate_limits.five_hour.used_percentage | pct("5h")),
      (.rate_limits.seven_day.used_percentage | pct("7d"))
    ]
  | join(" | ")
'
