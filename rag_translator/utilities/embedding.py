from init.cohere import cohere_client
from data.models import Verse, Chunk, Embedding


def embed_data(verse: Verse, chunks: list[Chunk]) -> list[Embedding]:
    # Embed
    raw_embeddings = cohere_client.embed(texts=[chunk.content for chunk in chunks], model='embed-multilingual-v3.0', input_type='search_document')
    embeddings = [Embedding(verse=verse, vector=vector, content=chunks[index].content) for index, vector in enumerate(raw_embeddings.embeddings)] 
    return embeddings
