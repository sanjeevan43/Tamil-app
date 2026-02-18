from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from typing import List, Dict

from app.schemas import (
    Word, Category, Lesson, Game, Story, Rhyme, 
    QuizOption, Fact, SentencePart, FillBlankWord
)
from app import data

app = FastAPI(
    title="Tamil Learning App API",
    description="Backend API for the Tamil Learning App",
    version="1.0.0"
)

# CORS Configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # For development, allow all. Restrict in production.
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/", tags=["Health"])
async def read_root():
    return {"status": "online", "message": "Tamil Learning App API is running"}

@app.get("/api/content/letters/vowels", response_model=List[str], tags=["Content"])
async def get_vowels():
    return data.uyir_ezhuthukkal

@app.get("/api/content/letters/consonants", response_model=List[str], tags=["Content"])
async def get_consonants():
    return data.mei_ezhuthukkal

@app.get("/api/content/word-categories", response_model=List[Category], tags=["Content"])
async def get_word_categories():
    categories = []
    for name, words in data.word_categories.items():
        categories.append(Category(name=name, words=[Word(**w) for w in words]))
    return categories

@app.get("/api/content/lessons", response_model=List[Lesson], tags=["Content"])
async def get_lessons():
    return [Lesson(**l) for l in data.lessons]

@app.get("/api/content/games", response_model=List[Game], tags=["Content"])
async def get_games():
    return [Game(**g) for g in data.games]

@app.get("/api/content/rhymes", response_model=List[Rhyme], tags=["Content"])
async def get_rhymes():
    return [Rhyme(**r) for r in data.tamil_rhymes]

@app.get("/api/content/stories", response_model=List[Story], tags=["Content"])
async def get_stories():
    return [Story(**s) for s in data.tamil_stories]

@app.get("/api/content/achievements", response_model=List[str], tags=["Content"])
async def get_achievements():
    return data.achievements

@app.get("/api/content/quotes", response_model=List[str], tags=["Content"])
async def get_quotes():
    return data.motivational_quotes

@app.get("/api/content/quiz-questions", response_model=List[QuizOption], tags=["Games"])
async def get_quiz_questions():
    return [QuizOption(**q) for q in data.quiz_questions]

@app.get("/api/content/sentences", response_model=List[SentencePart], tags=["Games"])
async def get_shuffled_sentences():
    return [SentencePart(**s) for s in data.sentences]

@app.get("/api/content/fill-blanks-words", response_model=List[FillBlankWord], tags=["Games"])
async def get_fill_blanks_words():
    return [FillBlankWord(**w) for w in data.fill_blanks_words]

@app.get("/api/content/global-facts", response_model=List[Fact], tags=["Content"])
async def get_global_facts():
    return [Fact(**f) for f in data.global_facts]
