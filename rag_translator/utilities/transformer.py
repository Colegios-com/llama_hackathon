from init.together import together_client

from data.models import Translation

import json
import asyncio

llama405bt = 'meta-llama/Meta-Llama-3.1-405B-Instruct-Turbo'
llama90bt = 'meta-llama/Llama-3.2-90B-Vision-Instruct-Turbo'
llama70bt = 'meta-llama/Meta-Llama-3.1-70B-Instruct-Turbo'
llama8bt = 'meta-llama/Meta-Llama-3.1-8B-Instruct-Turbo'


def translate(translation: Translation, source_verses, target_verses) -> str:
    prompt = f'''
        Source Text: {translation.text}
        Source Language: {translation.source_language}
        Target Language: {translation.target_language}

        Translation Table:
        Source -> {source_verses}
        Trget -> {target_verses}

        Instructions:
        1. Analyze source text structure and meaning
        2. Review translation table for direct matches
        3. Follow these steps in order:
        a. Direct word/phrase matches from translation table
        b. Grammatical structure alignment
        c. Idiomatic expression handling
        d. Cultural context adaptation
        4. Maintain original:
        - Names
        - Numbers
        - Special characters
        - Technical terms (unless in translation table)
        5. Flag any untranslatable elements
        6. Note any ambiguous translations
        7. Provide confidence score (1-5) for translation accuracy

        Response Format:
        Translation: [translated_text]
        Confidence Score: [1-5]
        Translation Notes:
        - [Any special handling notes]
        - [Ambiguities encountered]
        - [Untranslatable elements]
        Used Translations:
        - [source_word] → [target_word]

        Alternative Translations (if applicable):
        - [alternative_1]
        - [alternative_2]
    '''
    raw_response = together_client.batch_response(prompt=prompt, model=llama405bt, max_tokens=2500)
    return raw_response
