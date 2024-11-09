from init.cohere import cohere_client
from cohere import ClassifyExample


def classify(query):
    examples = [ClassifyExample(text=example['text'], label=example['label']) for example in query.examples]
    response = cohere_client.classify(
            inputs=[query.query],
            examples=examples,
        )
    top_result = response.classifications[0]
    if top_result.confidence >= 0.8:
        return top_result.prediction
    return 'aldous_bot'