# 🏗️ Akaravalam Architecture & System Overview

## System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                     TAMIL LEARNING APP (Flutter)                │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                    UI SCREENS                            │   │
│  ├──────────────────────────────────────────────────────────┤   │
│  │                                                           │   │
│  │  ┌─────────────────┐  ┌──────────────────┐              │   │
│  │  │ Family Tree     │  │ Riddle Game      │              │   │
│  │  │ Screen          │  │ Screen           │              │   │
│  │  └────────┬────────┘  └────────┬─────────┘              │   │
│  │           │                    │                        │   │
│  │  ┌────────┴────────┐  ┌────────┴─────────┐             │   │
│  │  │ Scan & Learn    │  │ Story Generator  │             │   │
│  │  │ Screen          │  │ Screen           │             │   │
│  │  └────────┬────────┘  └────────┬─────────┘             │   │
│  │           │                    │                        │   │
│  │  ┌────────┴────────────────────┴─────────┐             │   │
│  │  │ Spoken vs Written Tamil Screen        │             │   │
│  │  └────────┬─────────────────────────────┘             │   │
│  │           │                                            │   │
│  └───────────┼────────────────────────────────────────────┘   │
│              │                                                  │
│  ┌───────────▼────────────────────────────────────────────┐   │
│  │         CLAUDE API SERVICE                             │   │
│  │  (claude_api_service.dart)                             │   │
│  ├────────────────────────────────────────────────────────┤   │
│  │                                                         │   │
│  │  ┌──────────────────────────────────────────────────┐  │   │
│  │  │ _callClaude()                                    │  │   │
│  │  │ - Handles HTTP requests                          │  │   │
│  │  │ - Manages API authentication                     │  │   │
│  │  │ - Parses JSON responses                          │  │   │
│  │  │ - Error handling                                 │  │   │
│  │  └──────────────────────────────────────────────────┘  │   │
│  │                                                         │   │
│  │  ┌──────────────────────────────────────────────────┐  │   │
│  │  │ Feature Methods:                                 │  │   │
│  │  │ • getKinshipWord()                               │  │   │
│  │  │ • explainScannedText()                           │  │   │
│  │  │ • convertTamil()                                 │  │   │
│  │  │ • generateRiddle()                               │  │   │
│  │  │ • generateStory()                                │  │   │
│  │  └──────────────────────────────────────────────────┘  │   │
│  │                                                         │   │
│  └────────────────────────┬────────────────────────────────┘   │
│                           │                                     │
│  ┌────────────────────────▼────────────────────────────────┐   │
│  │         ENVIRONMENT CONFIGURATION                       │   │
│  │  (flutter_dotenv)                                       │   │
│  ├─────────────────────────────────────────────────────────┤   │
│  │                                                          │   │
│  │  .env file:                                             │   │
│  │  CLAUDE_API_KEY=sk-ant-xxxxxxxxxxxxx                    │   │
│  │                                                          │   │
│  └────────────────────────┬────────────────────────────────┘   │
│                           │                                     │
└───────────────────────────┼─────────────────────────────────────┘
                            │
                            │ HTTPS
                            │
        ┌───────────────────▼──────────────────┐
        │   ANTHROPIC CLAUDE API               │
        │   https://api.anthropic.com/v1/...   │
        │                                      │
        │   • Model: claude-sonnet-4-20250514  │
        │   • Max tokens: 1500                 │
        │   • Response: JSON                   │
        │                                      │
        └──────────────────────────────────────┘
```

---

## Data Flow Diagram

### Feature 1: Family Tamil Tree

```
User selects relation
        │
        ▼
┌──────────────────────────────────┐
│ FamilyTamilTreeScreen            │
│ - Shows relation options         │
│ - Calls getKinshipWord()         │
└──────────────┬───────────────────┘
               │
               ▼
┌──────────────────────────────────┐
│ ClaudeApiService                 │
│ .getKinshipWord(                 │
│   relation: "Mother's sister"    │
│   childAge: 8                    │
│ )                                │
└──────────────┬───────────────────┘
               │
               ▼
┌──────────────────────────────────┐
│ HTTP POST Request                │
│ - System prompt: Kinship expert  │
│ - User message: Relation + age   │
│ - Model: claude-sonnet-4         │
└──────────────┬───────────────────┘
               │
               ▼
┌──────────────────────────────────┐
│ Claude API Response              │
│ {                                │
│   "tamil_word": "சித்தி",        │
│   "transliteration": "Chitti",   │
│   "meaning_english": "...",      │
│   "quiz": [...]                  │
│ }                                │
└──────────────┬───────────────────┘
               │
               ▼
┌──────────────────────────────────┐
│ Parse JSON & Display             │
│ - Show Tamil word                │
│ - Show meaning                   │
│ - Display quiz                   │
└──────────────────────────────────┘
```

### Feature 5: Story Generator

```
User selects:
- Hero: குரங்கு
- Place: விண்வெளி
- Problem: தொலைந்துவிட்டது
        │
        ▼
┌──────────────────────────────────┐
│ StoryGeneratorScreen             │
│ - Shows selection UI             │
│ - Calls generateStory()          │
└──────────────┬───────────────────┘
               │
               ▼
┌──────────────────────────────────┐
│ ClaudeApiService                 │
│ .generateStory(                  │
│   hero: "குரங்கு"                │
│   place: "விண்வெளி"              │
│   problem: "தொலைந்துவிட்டது"    │
│   childName: "Arjun"             │
│   childAge: 8                    │
│ )                                │
└──────────────┬───────────────────┘
               │
               ▼
┌──────────────────────────────────┐
│ HTTP POST Request                │
│ - System prompt: Story writer    │
│ - User message: Hero, place, etc │
│ - Model: claude-sonnet-4         │
└──────────────┬───────────────────┘
               │
               ▼
┌──────────────────────────────────┐
│ Claude API Response              │
│ {                                │
│   "story_title_tamil": "...",    │
│   "scenes": [                    │
│     {                            │
│       "scene_number": 1,         │
│       "text_tamil": "...",       │
│       "image_prompt": "..."      │
│     },                           │
│     ...6 scenes total            │
│   ],                             │
│   "quiz": [...],                 │
│   "moral_tamil": "..."           │
│ }                                │
└──────────────┬───────────────────┘
               │
               ▼
┌──────────────────────────────────┐
│ Display Story                    │
│ - Show title                     │
│ - Navigate through 6 scenes      │
│ - Show quiz at end               │
│ - Display moral & new words      │
└──────────────────────────────────┘
```

---

## Component Interaction Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    FLUTTER APP                              │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ main.dart                                            │   │
│  │ - Initialize dotenv                                  │   │
│  │ - Load .env file                                     │   │
│  │ - Set CLAUDE_API_KEY                                 │   │
│  └──────────────────────────────────────────────────────┘   │
│                           │                                  │
│                           ▼                                  │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ ClaudeAIFeaturesHub                                  │   │
│  │ - Navigation hub                                     │   │
│  │ - Routes to all 5 features                           │   │
│  └──────────────────────────────────────────────────────┘   │
│           │        │        │        │        │             │
│           ▼        ▼        ▼        ▼        ▼             │
│      ┌────────┐┌────────┐┌────────┐┌────────┐┌────────┐    │
│      │Feature1││Feature2││Feature3││Feature4││Feature5│    │
│      │Family  ││Scan &  ││Spoken  ││Riddle  ││Story   │    │
│      │Tree    ││Learn   ││Written ││Game    ││Gen     │    │
│      └────┬───┘└────┬───┘└────┬───┘└────┬───┘└────┬───┘    │
│           │         │         │         │         │         │
│           └─────────┴─────────┴─────────┴─────────┘         │
│                     │                                        │
│                     ▼                                        │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ ClaudeApiService                                     │   │
│  │ - getKinshipWord()                                   │   │
│  │ - explainScannedText()                               │   │
│  │ - convertTamil()                                     │   │
│  │ - generateRiddle()                                   │   │
│  │ - generateStory()                                    │   │
│  │ - _callClaude() [private]                            │   │
│  └──────────────────────────────────────────────────────┘   │
│                     │                                        │
│                     ▼                                        │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ flutter_dotenv                                       │   │
│  │ - Load environment variables                         │   │
│  │ - Access CLAUDE_API_KEY                              │   │
│  └──────────────────────────────────────────────────────┘   │
│                     │                                        │
│                     ▼                                        │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ http package                                         │   │
│  │ - Make HTTP POST requests                            │   │
│  │ - Handle responses                                   │   │
│  │ - Error handling                                     │   │
│  └──────────────────────────────────────────────────────┘   │
│                     │                                        │
└─────────────────────┼────────────────────────────────────────┘
                      │
                      │ HTTPS
                      │
        ┌─────────────▼──────────────┐
        │  Anthropic Claude API      │
        │  api.anthropic.com         │
        └────────────────────────────┘
```

---

## Request/Response Flow

### Request Structure

```
POST https://api.anthropic.com/v1/messages

Headers:
{
  "Content-Type": "application/json",
  "x-api-key": "sk-ant-xxxxxxxxxxxxx",
  "anthropic-version": "2023-06-01"
}

Body:
{
  "model": "claude-sonnet-4-20250514",
  "max_tokens": 1500,
  "system": "You are a Tamil kinship expert...",
  "messages": [
    {
      "role": "user",
      "content": "Relation: Mother's younger sister\nChild age: 8"
    }
  ]
}
```

### Response Structure

```
{
  "id": "msg_xxxxxxxxxxxxx",
  "type": "message",
  "role": "assistant",
  "content": [
    {
      "type": "text",
      "text": "{\"tamil_word\": \"சித்தி\", ...}"
    }
  ],
  "model": "claude-sonnet-4-20250514",
  "stop_reason": "end_turn",
  "stop_sequence": null,
  "usage": {
    "input_tokens": 250,
    "output_tokens": 450
  }
}
```

---

## Error Handling Flow

```
User Action
    │
    ▼
Call ClaudeApiService
    │
    ├─ Network Error?
    │  └─ Show: "Check internet connection"
    │
    ├─ API Key Missing?
    │  └─ Show: "Configuration error"
    │
    ├─ 401 Unauthorized?
    │  └─ Show: "Invalid API key"
    │
    ├─ 429 Too Many Requests?
    │  └─ Show: "Too many requests, try again later"
    │
    ├─ Invalid JSON Response?
    │  └─ Show: "Unexpected response format"
    │
    └─ Success?
       └─ Parse JSON & Display
```

---

## State Management Flow

```
┌─────────────────────────────────────────┐
│ Screen State                            │
├─────────────────────────────────────────┤
│                                         │
│ isLoading: false                        │
│ data: null                              │
│ error: null                             │
│                                         │
└────────────────┬────────────────────────┘
                 │
                 ▼
        User clicks button
                 │
                 ▼
┌────────────────────────────────────────┐
│ setState(() => isLoading = true)       │
│ Show loading indicator                 │
└────────────────┬───────────────────────┘
                 │
                 ▼
        Call API Service
                 │
        ┌────────┴────────┐
        │                 │
        ▼                 ▼
    Success          Error
        │                 │
        ▼                 ▼
┌──────────────┐  ┌──────────────┐
│ setState(()  │  │ setState(()   │
│   data=...   │  │   error=...   │
│   loading=   │  │   loading=    │
│   false)     │  │   false)      │
│              │  │               │
│ Display data │  │ Show error    │
└──────────────┘  └──────────────┘
```

---

## Security Architecture

```
┌─────────────────────────────────────────────────────────┐
│                  SECURITY LAYERS                        │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  Layer 1: Environment Variables                         │
│  ┌────────────────────────────────────────────────────┐ │
│  │ .env file (NOT in git)                             │ │
│  │ CLAUDE_API_KEY=sk-ant-xxxxxxxxxxxxx                │ │
│  │ .gitignore includes .env                           │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
│  Layer 2: Runtime Loading                              │
│  ┌────────────────────────────────────────────────────┐ │
│  │ flutter_dotenv loads at app startup                │ │
│  │ Key never hardcoded in source                       │ │
│  │ Key only in memory during runtime                  │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
│  Layer 3: HTTPS Communication                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │ All API calls use HTTPS                            │ │
│  │ Encrypted in transit                               │ │
│  │ Certificate validation                             │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
│  Layer 4: Error Handling                               │
│  ┌────────────────────────────────────────────────────┐ │
│  │ No sensitive data in error messages                │ │
│  │ API key not logged                                 │ │
│  │ User-friendly error messages                       │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

## Deployment Architecture

```
Development
    │
    ├─ .env (local, not committed)
    ├─ CLAUDE_API_KEY=sk-ant-dev-key
    └─ flutter run
         │
         ▼
    Testing
         │
         ├─ Test all 5 features
         ├─ Verify error handling
         └─ Check API usage
              │
              ▼
         Staging
              │
              ├─ .env (staging key)
              ├─ CLAUDE_API_KEY=sk-ant-staging-key
              └─ Internal testing
                   │
                   ▼
              Production
                   │
                   ├─ .env (production key)
                   ├─ CLAUDE_API_KEY=sk-ant-prod-key
                   ├─ Monitor API usage
                   ├─ Set up alerts
                   └─ Track costs
```

---

## Performance Considerations

```
┌─────────────────────────────────────────────────────────┐
│              PERFORMANCE OPTIMIZATION                   │
├─────────────────────────────────────────────────────────┤
│                                                          │
│ 1. Response Caching                                     │
│    ┌──────────────────────────────────────────────────┐ │
│    │ Cache kinship words (rarely change)              │ │
│    │ Cache riddles (avoid repeats)                    │ │
│    │ Reduce API calls by 30-40%                       │ │
│    └──────────────────────────────────────────────────┘ │
│                                                          │
│ 2. Request Debouncing                                  │
│    ┌──────────────────────────────────────────────────┐ │
│    │ Prevent rapid duplicate requests                 │ │
│    │ Debounce user input (500ms)                      │ │
│    │ Reduce unnecessary API calls                     │ │
│    └──────────────────────────────────────────────────┘ │
│                                                          │
│ 3. Lazy Loading                                        │
│    ┌──────────────────────────────────────────────────┐ │
│    │ Load features on demand                          │ │
│    │ Don't preload all screens                        │ │
│    │ Faster app startup                               │ │
│    └──────────────────────────────────────────────────┘ │
│                                                          │
│ 4. Token Optimization                                  │
│    ┌──────────────────────────────────────────────────┐ │
│    │ Concise system prompts                           │ │
│    │ Efficient user messages                          │ │
│    │ Reduce token usage by 20%                        │ │
│    └──────────────────────────────────────────────────┘ │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

## Scalability Path

```
Current (Single User)
    │
    ├─ Direct API calls
    ├─ No caching
    └─ ~$0.016 per session
         │
         ▼
    Scale to 100 Users
         │
         ├─ Add response caching
         ├─ Implement debouncing
         └─ ~$240/month
              │
              ▼
         Scale to 1000 Users
              │
              ├─ Add backend service
              ├─ Implement request queuing
              ├─ Add rate limiting
              └─ ~$2400/month
                   │
                   ▼
              Scale to 10000+ Users
                   │
                   ├─ Dedicated backend
                   ├─ Load balancing
                   ├─ Advanced caching
                   └─ Custom pricing
```

---

**Architecture Version**: 1.0
**Last Updated**: 2024
**Status**: Production Ready ✅
