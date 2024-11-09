from data.models import Artifact, Chunk
from json_repair import repair_json


def chunk_data(artifact: Artifact) -> list[Chunk]:
    chunks = []
    chunk_size = 500
    chunk_overlap = 100
    content_length = len(artifact.content)

    for chunk_start in range(0, content_length, chunk_size - chunk_overlap):
        chunk_end = min(chunk_start + chunk_size, content_length)
        chunk = artifact.content[chunk_start:chunk_end]
        chunks.append(Chunk(artifact=artifact, content=chunk))
    return chunks


def stitch_response(raw_response: str) -> str:
    response = ''.join(raw_response)
    return response


def repair_json_response(raw_response: str) -> str:
    response  = repair_json(raw_response)
    return response
