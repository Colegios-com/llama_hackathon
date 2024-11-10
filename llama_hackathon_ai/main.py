# Init
from init.fast_api import app

# Utilities
from utilities.parsing import chunk_data, repair_json_response
from utilities.embedding import embed_data
from utilities.storage import save_data, get_data, delete_data, query_data
from utilities.transformer import prepare_for_embedding, stream_response, stream_document

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


@app.websocket('/channel/')
async def websocket_channel(websocket: WebSocket):
    await websocket.accept()
    try:
        while True:
            json_data = await websocket.receive_json()
            if json_data:
                if json_data['action'] == 'ask_question':
                    query = Query(**json_data)
                    context = query.context
                    raw_response = await stream_response(websocket, query, context)
                elif json_data['action'] == 'generate_document':
                    instruction = json_data['instruction']
                    image = json_data['image']
                    raw_response = await stream_document(websocket, instruction, image)
                
            if raw_response:
                response = json.dumps({'action': json_data['action'], 'content': raw_response})
                await websocket.send_text(response)
            else:
                response = json.dumps({'status': 'END_OF_RESPONSE'})
                await websocket.send_text(response)

    except Exception as e:
        print(f'WebSocket error: {e}')
    finally:
        await websocket.close()