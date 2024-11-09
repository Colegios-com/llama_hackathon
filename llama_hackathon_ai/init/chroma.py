from chromadb import HttpClient
import os


chroma_key = os.environ.get('CHROMA_KEY')


chroma_client = HttpClient(
  ssl=True,
  host='api.trychroma.com',
  tenant='7b7098df-b1b9-4400-a500-e3706360b27c',
  database='test-0d3eb34c',
  headers={
      'x-chroma-token': chroma_key
  }
)