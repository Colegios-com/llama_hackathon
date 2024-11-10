from pydantic import BaseModel
from typing import Optional


class Verse(BaseModel):
    id: str
    book: str
    chapter: int
    verse: int
    content: str
    text: str
    language: str
    version: Optional[str] = None


class Chunk(BaseModel):
    verse: Verse
    content: str


class Embedding(BaseModel):
    verse: Optional[Verse] = None
    vector: list
    content: str


class Translation(BaseModel):
    text: str
    source_language: str
    target_language: str
    score: int

