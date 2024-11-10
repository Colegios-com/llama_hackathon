from cohere import Client, ClassifyExample
import os


cohere_key = os.environ.get('COHERE_KEY')
cohere_client = Client(cohere_key)
