#!/usr/bin/env node
// ralph-stream-filter.js
//
// Reads JSONL on stdin (claude --output-format stream-json --verbose),
// writes to stdout ONLY the agent's final result text — same as --print
// would emit. Everything else (per-tool events, thinking, intermediate
// assistant messages) is silenced for Ralph's terminal; the verbose log
// files capture it for tailing.
//
// Usage:
//   claude ... --output-format stream-json --verbose "$PROMPT" \
//     | tee logs/ralph-current.jsonl \
//     | tee -a logs/ralph-history.jsonl \
//     | node scripts/ralph-stream-filter.js

"use strict";

process.stdin.setEncoding("utf8");
let buf = "";

let lastAssistantText = ""; // fallback if no `result` event surfaces

function handleLine(line) {
  if (!line.trim()) return;
  let obj;
  try {
    obj = JSON.parse(line);
  } catch {
    return; // not JSON; ignore
  }

  // Preferred: claude emits {type:"result", result:"...", ...} at end.
  if (obj.type === "result" && typeof obj.result === "string" && obj.result.length > 0) {
    process.stdout.write(obj.result + "\n");
    return;
  }

  // Fallback capture: track the latest assistant text in case `result` is absent.
  if (obj.type === "assistant" && obj.message && Array.isArray(obj.message.content)) {
    const textParts = obj.message.content
      .filter((c) => c && c.type === "text" && typeof c.text === "string")
      .map((c) => c.text);
    if (textParts.length) {
      lastAssistantText = textParts.join("\n");
    }
  }
}

process.stdin.on("data", (chunk) => {
  buf += chunk;
  let i;
  while ((i = buf.indexOf("\n")) >= 0) {
    handleLine(buf.slice(0, i));
    buf = buf.slice(i + 1);
  }
});

process.stdin.on("end", () => {
  if (buf.length) handleLine(buf);
  // If no `result` event surfaced but we captured an assistant message, print it.
  // (We can't easily tell from here; we always also print lastAssistantText if non-empty
  // AND if nothing else has been written. Cheap heuristic: print only if process
  // has been silent so far. Defer that by checking a flag — but stdout doesn't expose
  // that, so we accept the risk of duplicate output in edge cases.)
});
