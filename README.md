# Floating ai avatar
 
A floating, voice-activated AI companion for Android (with partial iOS support) built in Flutter. The Avatar lives as an animated overlay that sits on top of other apps, listens when spoken to, responds out loud, and can carry out a small set of real-world actions on the user's behalf (e.g. sending a WhatsApp message, setting a timer).
 
> **Status:** Active development — frontend (this repo) is functional; backend/voice-intelligence service is maintained separately and will be documented once integrated here.
 
---
 
## Core Features
 
- **Floating Avatar Overlay** — A draggable, always-on-top widget (via a native system overlay) that renders an animated character built in Rive. The avatar's expression/animation state reflects what it's currently doing (idle, listening, thinking, speaking).
- **Hands-Free Voice Interaction** — Continuous microphone capture with on-device voice activity detection (VAD), so the assistant knows when the user starts and stops talking without manual start/stop button presses.
- **Conversational Backend Integration** — Captured audio is packaged and sent to a backend voice-processing service, which returns a spoken reply plus (optionally) a structured action to perform.
- **Text-to-Speech Responses** — Replies are spoken back to the user via on-device TTS, tuned for a natural pace/pitch.
- **Pluggable Action System** — A lightweight intent router dispatches backend-returned actions to independent, self-contained feature modules. Modules currently include:
  - **Overlay control** — dismiss/close the floating avatar on command.
  - **WhatsApp messaging** — resolves a spoken contact name against the device's contact list and opens WhatsApp with a pre-filled message.
  - **System timers** — sets or displays native Android timers via platform intents.
  - New capabilities can be added by implementing a single module interface — no changes needed elsewhere in the app.
- **Account System** — Supabase-backed authentication supporting email/password and Google Sign-In, managed through a predictable Bloc-driven state machine (loading / authenticated / unauthenticated / error).
- **Remote Configuration** — Key runtime behavior (backend gateway, maintenance mode, welcome messaging) is controlled via Firebase Remote Config, so behavior can be adjusted without shipping an app update.
- **App Integrity Protection** — Firebase App Check (Play Integrity on Android) helps ensure only genuine, untampered app installs can talk to backend services.
---
 
##  Architecture
 
The app is organized by **feature**, with a small shared **core** for cross-cutting concerns:
 
```
lib/
├── api/                      # Thin HTTP client(s) for backend services
├── core/
│   ├── network/               # Shared HTTP client configuration
│   └── ...                    # App bootstrap, remote config, environment setup
└── features/
    ├── avatar/                 # Avatar state machine, mic lifecycle, Rive-driven UI
    ├── action_router/
    │   ├── modules/             # One file per action (WhatsApp, Timer, Overlay, ...)
    │   └── models/               # Shared request/response contracts
    ├── auth/
    │   ├── data/                 # Repository wrapping the auth provider
    │   └── bloc/                  # Auth state management
    ├── overlay/                 # System overlay permission + lifecycle handling
    └── tts/                      # Text-to-speech wrapper
```
 
**Design principles in play:**
- **Separation of concerns** — voice capture, backend communication, speech output, and action execution are all independent pieces wired together by a provider, not tangled into one giant class.
- **Extensibility via modules** — the action router treats every capability (WhatsApp, timers, overlay control, future features) as an interchangeable plugin behind a common contract, so new actions don't require touching existing code.
- **Resilience** — timers guard against hung listening sessions and runaway recordings; failures during processing fall back gracefully to an idle state rather than leaving the user stuck.
- **Shared bootstrap** — the same initialization path is used whether the app is launched normally or running inside the overlay's separate isolate, keeping Firebase/Supabase/config setup consistent everywhere.
---
 
## Tech Stack
 
| Concern | Library / Service |
|---|---|
| Framework | Flutter (Dart) |
| App-level state | `provider` (avatar lifecycle) |
| Auth state | `flutter_bloc` |
| Avatar animation | Rive |
| Floating overlay | `flutter_overlay_window` |
| Audio capture | `record` |
| Voice activity detection | `vad` |
| Text-to-speech | `flutter_tts` |
| HTTP client | `dio` |
| Auth / backend-as-a-service | Supabase |
| Social sign-in | `google_sign_in` |
| Remote config & app integrity | Firebase (Remote Config, App Check) |
| Native Android actions | `android_intent_plus` |
| Contacts | `flutter_contacts` |
| Permissions | `permission_handler` |
| External app links | `url_launcher` |
 
---
 
## How a Voice Interaction Flows
 
1. User taps the avatar (or it's already listening) → mic activates.
2. VAD detects speech start → avatar switches to a "listening" state.
3. VAD detects speech end → recording stops, audio is encoded and sent to the backend.
4. Avatar enters a "thinking" state while awaiting a response.
5. Backend returns a spoken reply and, optionally, a structured action.
6. The reply is spoken aloud via TTS **while** the corresponding action module (if any) executes in parallel.
7. Avatar returns to idle, ready for the next interaction.
Safety nets in place: an idle timeout resets the session if the user goes silent after waking the mic, and a max-speech-duration timer prevents indefinitely long recordings.
 
---
 
##  Permissions Used
 
| Permission | Why it's needed |
|---|---|
| Microphone | Core voice interaction |
| Display over other apps (overlay) | Renders the floating avatar |
| Contacts (optional) | Resolves a spoken name to a phone number for the WhatsApp action — feature degrades gracefully if denied |
 
---

 

 
© 2026 — All rights reserved.
 

