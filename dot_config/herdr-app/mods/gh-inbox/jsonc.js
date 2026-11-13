// Small JSONC reader: comments and trailing commas, with strings left untouched.
export function parseJsonc(text) {
  let clean = "";
  let inString = false;
  let escaped = false;
  let lineComment = false;
  let blockComment = false;

  for (let i = 0; i < text.length; i++) {
    const ch = text[i];
    const next = text[i + 1];
    if (lineComment) {
      if (ch === "\n") {
        lineComment = false;
        clean += ch;
      } else clean += " ";
      continue;
    }
    if (blockComment) {
      if (ch === "*" && next === "/") {
        blockComment = false;
        clean += "  ";
        i++;
      } else clean += ch === "\n" ? "\n" : " ";
      continue;
    }
    if (inString) {
      clean += ch;
      if (escaped) escaped = false;
      else if (ch === "\\") escaped = true;
      else if (ch === '"') inString = false;
      continue;
    }
    if (ch === '"') {
      inString = true;
      clean += ch;
    } else if (ch === "/" && next === "/") {
      lineComment = true;
      clean += "  ";
      i++;
    } else if (ch === "/" && next === "*") {
      blockComment = true;
      clean += "  ";
      i++;
    } else clean += ch;
  }
  if (blockComment) throw new Error("Unterminated block comment");

  let result = "";
  inString = false;
  escaped = false;
  for (let i = 0; i < clean.length; i++) {
    const ch = clean[i];
    if (inString) {
      result += ch;
      if (escaped) escaped = false;
      else if (ch === "\\") escaped = true;
      else if (ch === '"') inString = false;
      continue;
    }
    if (ch === '"') {
      inString = true;
      result += ch;
      continue;
    }
    if (ch === ",") {
      let j = i + 1;
      while (/\s/.test(clean[j] ?? "")) j++;
      if (clean[j] === "}" || clean[j] === "]") continue;
    }
    result += ch;
  }
  return JSON.parse(result);
}
