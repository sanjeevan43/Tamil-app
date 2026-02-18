from typing import List, Optional, Dict, Any
from pydantic import BaseModel

class Word(BaseModel):
    tamil: str
    english: str
    emoji: str

class Category(BaseModel):
    name: str
    words: List[Word]

class SentencePart(BaseModel):
    tamil: List[str]
    english: str
    hint: str

class Lesson(BaseModel):
    id: int
    title: str
    level: str
    locked: bool

class Game(BaseModel):
    id: int
    name: str
    icon: str
    description: str

class QuizOption(BaseModel):
    question: str
    letter: Optional[str] = None
    options: List[str]
    correct: int

class Scene(BaseModel):
    content: str
    image: Optional[str] = None

class Story(BaseModel):
    title: str
    moral: Optional[str] = None
    scenes: List[Scene]
    questions: Optional[List[QuizOption]] = None

class RhymeLine(BaseModel):
    content: str
    image: Optional[str] = None

class Rhyme(BaseModel):
    title: str
    lines: List[RhymeLine]

class Fact(BaseModel):
    country: str
    flag: Optional[str] = None
    fact: str

class FillBlankWord(BaseModel):
    word: str
    english: str
    emoji: str
