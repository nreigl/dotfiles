import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const dangerousPatterns: Array<{ pattern: RegExp; label: string }> = [
  // Any recursive flag, alone or combined: -r, -R, -rf, -fr, -r -f, --recursive.
  // The flag must follow whitespace, so "rm my-report.txt" does not match.
  // [^\n;&|] keeps the match inside one command of a chain.
  { pattern: /\brm\b[^\n;&|]*\s(?:-[a-z]*r[a-z]*\b|--recursive\b)/i, label: "recursive deletion" },
  { pattern: /\bsudo\b/i, label: "privileged command" },
  { pattern: /\bgit\s+reset\s+--hard\b/i, label: "destructive Git reset" },
  // -f, --force, --force-with-lease, --force-if-includes, and a +refspec.
  { pattern: /\bgit\s+push\b[^\n;&|]*\s(?:-[a-z]*f[a-z]*\b|--force|\+\S)/i, label: "Git force push" },
  { pattern: /\bgit\s+clean\s+[^\n]*-[^\s]*f/i, label: "destructive Git clean" },
  { pattern: /\bstow\s+[^\n]*--adopt\b/i, label: "Stow adopt" },
  { pattern: /\b(?:chmod|chown)\b[^\n]*\b777\b/i, label: "world-writable permissions" },
];

export default function (pi: ExtensionAPI) {
  pi.on("tool_call", async (event, ctx) => {
    if (event.toolName !== "bash") return;

    const command = String((event.input as { command?: unknown }).command ?? "");
    const match = dangerousPatterns.find(({ pattern }) => pattern.test(command));
    if (!match) return;

    if (!ctx.hasUI) {
      return { block: true, reason: `${match.label} blocked because no confirmation UI is available` };
    }

    const allowed = await ctx.ui.confirm(
      `Allow ${match.label}?`,
      command,
      { timeout: 30_000 },
    );
    if (!allowed) return { block: true, reason: `${match.label} blocked by user` };
  });
}
