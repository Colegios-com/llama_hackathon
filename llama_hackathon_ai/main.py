# Init
from init.fast_api import app

# Utilities
from utilities.parsing import chunk_data, repair_json_response
from utilities.embedding import embed_data
from utilities.storage import save_data, get_data, delete_data, query_data
from utilities.transformer import prepare_for_embedding, stream_response

# Models
from data.models import Url, Artifact, Query
from fastapi import WebSocket

import json
import requests


@app.post('/embeddings/')
def post_embeddings(artifact: Artifact) -> str:
    artifact.content = prepare_for_embedding(text=artifact.content)
    chunks = chunk_data(artifact=artifact)
    embeddings = embed_data(artifact=artifact, chunks=chunks)
    save_data(chunks=chunks, embeddings=embeddings)
    return 'Data embedded successfully.'


@app.get('/embeddings/{workspace}/')
def get_embeddings(workspace: str) -> str:
    data = get_data(workspace)
    return 'Data retrieved successfully.'


@app.delete('/embeddings/{id}/')
def delete_embeddings(id: str) -> str:
    success = delete_data(id=id)
    return 'Data deleted successfully.' if success else 'Data deletion failed.'


@app.websocket('/ask/')
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    try:
        while True:
            json_data = await websocket.receive_json()
            if json_data:
                query = Query(**json_data)

            # context = await query_data(query=query)
            context = query.context

            raw_response = await stream_response(websocket, query, context)
            if raw_response:
                await websocket.send_text(raw_response)
            else:
                await websocket.send_text('END_OF_RESPONSE')

    except Exception as e:
        print(f'WebSocket error: {e}')
    finally:
        await websocket.close()
