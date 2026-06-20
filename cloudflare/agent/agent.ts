import { ChatGroq } from "@langchain/groq"
import { ChatGoogleGenerativeAI } from "@langchain/google-genai"
import { z } from "zod"
import { tool } from "@langchain/core/tools"

// ---------------------------------------------------------------------------
// Tool definitions
//
// [REDACTED FOR PUBLIC REPO]
// The `description` field on each tool below — along with each schema
// field's `.describe()` text — is the part of this file that was actually
// tuned through iteration to get reliable, low-hallucination structured
// tool-calling out of the model. Names and parameter shapes are left
// in place since they're already implied by the client app; the wording
// that drives selection accuracy is not.
// ---------------------------------------------------------------------------

const overlayTool = tool(
    async () => "Success",
    {
        name: "OVERLAY_ACTION",
        description: "[redacted]",
        schema: z.object({
            command: z.string()
        })
    }
)

const whatsappTool = tool(
    async () => "Success",
    {
        name: "WHATSAPP_ACTION",
        description: "[redacted]",
        schema: z.object({
            message: z.string(),
            contact_name: z.string().nullable().optional()
        })
    }
)

const timerTool = tool(
    async () => "Success",
    {
        name: "TIMER_ACTION",
        description: "[redacted]",
        schema: z.object({
            action: z.enum(["start", "stop", "reset"]),
            duration_seconds: z.number().nullable().optional()
        })
    }
)

const mobileTools = [overlayTool, whatsappTool, timerTool]

/**
 * Resolves a transcript into a spoken reply plus an optional structured
 * action. Uses a primary LLM provider with an automatic fallback to a
 * secondary provider for resilience.
 *
 * [REDACTED FOR PUBLIC REPO] — the system prompt that defines persona,
 * tone constraints, and tool-selection guidance lives outside source
 * control in this version.
 */
export async function getAgentIntent(transcript: string, env: any) {
    const allTools = [...mobileTools];

    const primaryModel = new ChatGroq({ apiKey: env.GROQ_API_KEY, model: env.GROQ_MODEL, maxRetries: 1 }).bindTools(allTools)
    const fallbackModel = new ChatGoogleGenerativeAI({ apiKey: env.GEMINI_API_KEY, model: env.GEMINI_MODEL, maxRetries: 1 }).bindTools(allTools)
    const orchestrator = primaryModel.withFallbacks({ fallbacks: [fallbackModel] })

    const messages = [
        { role: "system", content: env.SYSTEM_PROMPT },
        { role: "user", content: transcript }
    ];

    const response = await orchestrator.invoke(messages)

    if (response.tool_calls && response.tool_calls.length > 0) {
        const action = response.tool_calls[0]
        if (mobileTools.find(t => t.name === action.name)) {
            return {
                response: sanitizeSpokenText(response.content),
                type: action.name,
                parameters: action.args
            }
        }
    }

    return {
        response: sanitizeSpokenText(response.content),
        type: null,
        parameters: {}
    }
}

function sanitizeSpokenText(content: any): string {
    if (typeof content === 'string' && content.trim() !== '') {
        return content;
    }
    return "Got it, handling that now.";
}