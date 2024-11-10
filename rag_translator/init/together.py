from client_together.client import TogetherAiClient
import os


together_key = os.environ.get('TOGETHER_KEY')
together_client = TogetherAiClient(key=together_key)
