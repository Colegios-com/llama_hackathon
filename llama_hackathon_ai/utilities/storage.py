from init.chroma import chroma_client
from init.cohere import cohere_client
from data.models import Embedding, Query


collection = chroma_client.get_or_create_collection(name='documents', metadata={'hnsw:space': 'cosine'})


def save_data(chunks, embeddings):
    # Save
    result = collection.upsert(
        # List of Embeddings (Vectors)
        embeddings=[embedding.vector for embedding in embeddings],
        # List of corresponging Sources (String)
        documents=[chunk.content for chunk in chunks],
        # List of unique IDs per Vector/String pair
        ids=[f'{chunk.artifact.id} {count}' for count, chunk in enumerate(chunks)],
        # Additional Metadata
        metadatas=[{'id': chunk.artifact.id, 'workspace': chunk.artifact.workspace} for chunk in chunks]
    )
    return True


def get_data(workspace: str) -> list:
    return collection.get(where={'workspace': workspace})


def delete_data(id: str):
    try:
        collection.delete(where={'id': id})
        return True
    except:
        return False


async def query_data(query: Query) -> list:
    raw_embeddings = cohere_client.embed(texts=[query.query], model='embed-multilingual-v3.0', input_type='search_document')
    embeddings = [Embedding(artifact=None, vector=vector, content=query.query) for vector in raw_embeddings.embeddings]
    
    results = collection.query(
        query_embeddings=[embedding.vector for embedding in embeddings],
        where={'workspace': query.workspace},
        n_results=20,
    )

    context = '\n'.join(results['documents'][0])
    return context