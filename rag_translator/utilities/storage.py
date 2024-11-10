from init.chroma import chroma_client
from init.cohere import cohere_client
from data.models import Embedding, Translation


collection = chroma_client.get_or_create_collection(name='rag_translator', metadata={'hnsw:space': 'cosine'})


def save_data(chunks, embeddings):
    # Save
    result = collection.upsert(
        # List of Embeddings (Vectors)
        embeddings=[embedding.vector for embedding in embeddings],
        # List of corresponging Sources (String)
        documents=[chunk.verse.content for chunk in chunks],
        # List of unique IDs per Vector/String pair
        ids=[f'{chunk.verse.id} {count}' for count, chunk in enumerate(chunks)],
        # Additional Metadata
        metadatas=[{'id': chunk.verse.id, 'book': chunk.verse.book, 'chapter': chunk.verse.chapter, 'verse_number': chunk.verse.verse, 'language': chunk.verse.language} for chunk in chunks]
    )
    return True


def get_data(language: str) -> list:
    return collection.get(where={'language': language})


def delete_data(id: str):
    try:
        collection.delete(where={'id': id})
        return True
    except:
        return False


async def query_data(translation: Translation) -> list:
    raw_embeddings = cohere_client.embed(texts=[translation.text], model='embed-multilingual-v3.0', input_type='search_document')
    embeddings = [Embedding(verse=None, vector=vector, content=translation.text) for vector in raw_embeddings.embeddings]
    
    source_language_results = collection.query(
        query_embeddings=[embedding.vector for embedding in embeddings],
        where={'language': translation.source_language},
    )

    target_language_results = []

    for result in source_language_results['metadatas']:
        book = result[0]['book']
        chapter = result[0]['chapter']
        verse_number = result[0]['verse_number']
        metadata = {
                '$and': [
                    {
                        'language': {
                            '$eq': translation.target_language,
                        }
                    },
                    {
                        'book': {
                            '$eq': book,
                        }
                    },
                    {
                        'chapter': {
                            '$eq': chapter,
                        }
                    },
                    {
                        'verse_number': {
                            '$eq': verse_number,
                        }
                    },
                ]
            }

        target_language_results.append(collection.get(where={'language': translation.target_language}))

    return source_language_results, target_language_results