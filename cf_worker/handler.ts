import { Context } from 'hono'
import { HTTPException } from 'hono/http-exception'
import { transcribeAudio } from './agent/audio_transcribe'
import { getAgentIntent } from './agent/agent'

export async function voiceHandler(c: Context<any>) {
    const arrayBuffer = await c.req.arrayBuffer()
    if (!arrayBuffer || arrayBuffer.byteLength === 0) {
        throw new HTTPException(400, { message: 'Empty audio body' })
    }
    if (arrayBuffer.byteLength > 25 * 1024 * 1024) {
        throw new HTTPException(413, { message: 'Audio exceeds 25 MB limit' })
    }

    const audioBlob = new Blob([arrayBuffer], { type: 'audio/wav' })
    const transcript = await transcribeAudio(audioBlob, 'audio.wav', c.env.GROQ_API_KEY, c.env.GROQ_AUDIO_MODEL)

    if (!transcript) {
        return c.json({
            response: "I didn't catch that — could you try again?",
            type: null,
            parameters: {},
            transcript: ""
        })
    }

    const agentPayload = await getAgentIntent(transcript, c.env)
    return c.json({ ...agentPayload, transcript })
}