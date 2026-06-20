import { Hono } from 'hono'
import { HTTPException } from 'hono/http-exception'
import { voiceHandler } from './handlers'
export type Env = {
    SUPABASE_URL: string
    FIREBASE_PROJECT_NUMBER: string
    GROQ_API_KEY: string
    GROQ_MODEL: string
    GROQ_AUDIO_MODEL: string
    GEMINI_MODEL: string
    GEMINI_API_KEY: string
    SYSTEM_PROMPT: string
}

const app = new Hono<{ Bindings: Env }>()

app.onError((err, c) => {
    if (err instanceof HTTPException) return err.getResponse()
    console.error(err)
    return c.json({ error: 'Internal server error' }, 500)
})

app.get('/health', (c) => c.json({ status: 'ok' }))

// app.use('/voice', authMiddlewares)
app.post('/voice', voiceHandler)

export default app