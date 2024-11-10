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
    workspace: str
    query: str
    context: dict
    history: Optional[list] = None
    document_text: Optional[str] = None
