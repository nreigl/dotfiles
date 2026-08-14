import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { truncateTail, DEFAULT_MAX_BYTES, DEFAULT_MAX_LINES } from "@earendil-works/pi-coding-agent";
import { StringEnum } from "@earendil-works/pi-ai";
import { Type } from "typebox";

const actions = ["list", "start", "prompt", "read", "wait"] as const;
const kinds = [
  "pi", "claude", "codex", "gemini", "cursor", "devin", "agy", "cline",
  "omp", "mastracode", "opencode", "copilot", "kimi", "kiro", "droid",
  "amp", "grok", "hermes", "kilo", "qodercli", "maki",
] as const;

const Parameters = Type.Object({
  action: StringEnum(actions, { description: "Herdr operation" }),
  target: Type.Optional(Type.String({ description: "Unique agent name or pane ID for prompt/read/wait" })),
  name: Type.Optional(Type.String({ description: "Unique lowercase agent name for start" })),
  kind: Type.Optional(StringEnum(kinds, { description: "Agent kind for start; defaults to pi" })),
  task: Type.Optional(Type.String({ description: "Prompt for start or prompt" })),
  direction: Type.Optional(StringEnum(["right", "down"] as const, { description: "Split direction; inferred when omitted" })),
  timeoutMs: Type.Optional(Type.Integer({ minimum: 1_000, maximum: 600_000, description: "Wait timeout in milliseconds" })),
  lines: Type.Optional(Type.Integer({ minimum: 1, maximum: 2_000, description: "Transcript lines to read" })),
});

function requireValue(value: string | undefined, field: string): string {
  if (!value?.trim()) throw new Error(`${field} is required for this action`);
  return value.trim();
}

function parseJson(output: string): any {
  try {
    return JSON.parse(output.trim());
  } catch {
    throw new Error(`Herdr returned invalid JSON: ${output.slice(0, 500)}`);
  }
}

function defaultName(): string {
  return `helper-${Date.now().toString(36).slice(-7)}`;
}

export default function (pi: ExtensionAPI) {
  async function run(args: string[], signal?: AbortSignal, timeout = 30_000): Promise<string> {
    if (process.env.HERDR_ENV !== "1") {
      throw new Error("Herdr control is unavailable because Pi is not running inside a Herdr-managed pane");
    }

    const result = await pi.exec("herdr", args, { signal, timeout });
    if (result.code !== 0) {
      throw new Error((result.stderr || result.stdout || `herdr exited ${result.code}`).trim());
    }
    return result.stdout.trim();
  }

  async function inferDirection(signal?: AbortSignal): Promise<"right" | "down"> {
    const output = await run(["pane", "layout", "--current"], signal);
    const layout = parseJson(output)?.result?.layout;
    const paneId = process.env.HERDR_PANE_ID;
    const pane = layout?.panes?.find((candidate: any) => candidate.pane_id === paneId);
    const rect = pane?.rect ?? layout?.area;
    if (!rect) return "down";
    return rect.width >= 110 && rect.width / Math.max(rect.height, 1) >= 1.8 ? "right" : "down";
  }

  async function readAgent(target: string, lines: number, signal?: AbortSignal): Promise<string> {
    return run(
      ["agent", "read", target, "--source", "recent-unwrapped", "--lines", String(lines), "--format", "text"],
      signal,
    );
  }

  pi.registerTool({
    name: "herdr_agent",
    label: "Herdr Agent",
    description: "Inspect or coordinate coding agents in the current Herdr session. Can list agents, create a background sibling pane and start an agent, prompt an existing agent, wait, or read its transcript. Requires HERDR_ENV=1. Output is limited to 50KB/2000 lines.",
    promptSnippet: "Coordinate explicitly requested background agents through Herdr",
    promptGuidelines: [
      "Use herdr_agent only when the user explicitly mentions Herdr or explicitly requests delegation, sub-agents, background agents, or parallel agent work.",
      "When herdr_agent starts an agent, keep focus in the current pane and use the current working directory unless the user explicitly requests another topology or location.",
    ],
    parameters: Parameters,

    async execute(_toolCallId, params, signal, _onUpdate, ctx) {
      const timeout = params.timeoutMs ?? 120_000;
      let output: string;
      let details: Record<string, unknown> = { action: params.action };

      if (params.action === "list") {
        output = await run(["agent", "list"], signal);
      } else if (params.action === "read") {
        const target = requireValue(params.target, "target");
        output = await readAgent(target, params.lines ?? 120, signal);
        details.target = target;
      } else if (params.action === "wait") {
        const target = requireValue(params.target, "target");
        output = await run(["agent", "wait", target, "--timeout", String(timeout)], signal, timeout + 5_000);
        details.target = target;
      } else if (params.action === "prompt") {
        const target = requireValue(params.target, "target");
        const task = requireValue(params.task, "task");
        await run(["agent", "prompt", target, task, "--wait", "--timeout", String(timeout)], signal, timeout + 5_000);
        output = await readAgent(target, params.lines ?? 160, signal);
        details = { ...details, target };
      } else {
        const name = params.name?.trim() || defaultName();
        if (!/^[a-z][a-z0-9_-]{0,31}$/.test(name)) {
          throw new Error("name must match [a-z][a-z0-9_-]{0,31}");
        }

        const direction = params.direction ?? await inferDirection(signal);
        const splitOutput = await run(
          ["pane", "split", "--current", "--direction", direction, "--cwd", ctx.cwd, "--no-focus"],
          signal,
        );
        const paneId = parseJson(splitOutput)?.result?.pane?.pane_id;
        if (!paneId) throw new Error(`Unable to read pane ID from Herdr response: ${splitOutput}`);

        const kind = params.kind ?? "pi";
        await run(
          ["agent", "start", name, "--kind", kind, "--pane", paneId, "--timeout", "30000"],
          signal,
          35_000,
        );

        if (params.task?.trim()) {
          await run(
            ["agent", "prompt", name, params.task.trim(), "--wait", "--timeout", String(timeout)],
            signal,
            timeout + 5_000,
          );
          output = await readAgent(name, params.lines ?? 160, signal);
        } else {
          output = `Started ${kind} agent ${name} in pane ${paneId}.`;
        }
        details = { ...details, name, kind, paneId, direction };
      }

      const truncated = truncateTail(output, { maxBytes: DEFAULT_MAX_BYTES, maxLines: DEFAULT_MAX_LINES });
      const text = truncated.truncated
        ? `${truncated.content}\n\n[Herdr output truncated; use herdr_agent read with the target to inspect more.]`
        : truncated.content;
      return { content: [{ type: "text", text: text || "(no output)" }], details };
    },
  });

  pi.registerCommand("herdr-agents", {
    description: "List agents visible in the current Herdr session",
    handler: async (_args, ctx) => {
      try {
        const output = await run(["agent", "list"]);
        ctx.ui.notify(output.slice(0, 4_000), "info");
      } catch (error) {
        ctx.ui.notify(error instanceof Error ? error.message : String(error), "error");
      }
    },
  });
}
