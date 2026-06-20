const AUDIO_TRANSCRIPTION_URL = 'https://api.groq.com/openai/v1/audio/transcriptions'

export async function transcribeAudio(
    audio: Blob,
    filename: string,
    apiKey: string,
    model: string
): Promise<string> {
    const form = new FormData()
    form.append('file', audio, filename)
    form.append('model', model)
    form.append('response_format', 'json')
    form.append('language', 'en')

    const res = await fetch(
        AUDIO_TRANSCRIPTION_URL,
        {
            method: 'POST',
            headers: { Authorization: `Bearer ${apiKey}` },
            body: form,
        },
    )

    if (!res.ok) {
        const detail = await res.text()
        throw new Error(`Groq transcription failed ${res.status}: ${detail}`)
    }

    const { text } = (await res.json()) as { text: string }
    return text.trim()
}