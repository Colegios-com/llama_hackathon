from data.models import Verse, Chunk
from json_repair import repair_json


def chunk_data(verse: Verse) -> list[Chunk]:
    chunks = []
    chunk_size = 2500
    chunk_overlap = 500
    content_length = len(verse.content)

    for chunk_start in range(0, content_length, chunk_size - chunk_overlap):
        chunk_end = min(chunk_start + chunk_size, content_length)
        chunk = verse.content[chunk_start:chunk_end]
        chunks.append(Chunk(verse=verse, content=chunk))
    return chunks


def stitch_response(raw_response: str) -> str:
    response = ''.join(raw_response)
    return response


def repair_json_response(raw_response: str) -> str:
    response  = repair_json(raw_response)
    return response
