# Init
from init.fast_api import app

# Utilities
from utilities.parsing import chunk_data, repair_json_response
from utilities.embedding import embed_data
from utilities.storage import save_data, get_data, delete_data, query_data
from utilities.transformer import translate

# Models
from data.models import Verse, Translation

import json
import requests


@app.post('/embeddings/')
def post_embeddings(verse: Verse) -> str:
    chunks = chunk_data(verse)
    print(chunks)
    embeddings = embed_data(verse=verse, chunks=chunks)
    print(embeddings)
    result = save_data(chunks=chunks, embeddings=embeddings)

    if result:
        return 'Data embedded successfully.'
    
    return 'Data embedding failed.'


@app.get('/embeddings/{language}/')
def get_embeddings(language: str) -> str:
    data = get_data(language)
    return json.dumps(data)


@app.delete('/embeddings/{id}/')
def delete_embeddings(id: str) -> str:
    success = delete_data(id=id)
    return 'Data deleted successfully.' if success else 'Data deletion failed.'


@app.post('/translate/')
async def post_translate(translation: Translation) -> str:
    source_verses, target_verses = await query_data(translation)
    translation = translate(translation=translation, source_verses=source_verses['documents'], target_verses=target_verses['documents'])
    return translation