from pydantic import BaseModel
from typing import Optional


class Url(BaseModel):
    url: str


class Artifact(BaseModel):
    id: str
    workspace: str
    content: str


class Chunk(BaseModel):
    artifact: Artifact
    content: str


class Embedding(BaseModel):
    artifact: Optional[Artifact] = None
    vector: list
    content: str


class Query(BaseModel):
    context: dict
    workspace: str
    query: str
    history: Optional[list] = None
    examples: Optional[list] = None
