from init.together import together_client

from data.models import Query

import json
import asyncio

llama405bt = 'meta-llama/Meta-Llama-3.1-405B-Instruct-Turbo'
llama90bt = 'meta-llama/Llama-3.2-90B-Vision-Instruct-Turbo'
llama70bt = 'meta-llama/Meta-Llama-3.1-70B-Instruct-Turbo'
llama8bt = 'meta-llama/Meta-Llama-3.1-8B-Instruct-Turbo'


def prepare_for_embedding(text: str) -> str:
    print('Preparing for embedding...')
    prompt = f'''
    Analyze and modify the following text to optimize it for semantic search embeddings. Your task is to:

    1. Reorganize the content for clarity and coherence.
    2. Extend relevant points with additional context from within the text.
    3. Summarize verbose sections while maintaining key information.
    4. Emphasize important concepts and keywords.
    5. Ensure all information remains factual and based solely on the original content.
    6. Do not add any new information that is not present in the original text.
    7. Maintain the original meaning and intent of the text.

    Original text:
    {text}

    Instructions:
    - Provide only the modified text in your response.
    - Do not include any explanations or comments about your modifications.
    - Ensure the modified text is self-contained and coherent.

    Modified text:
    '''    
    raw_response = together_client.batch_response(prompt=prompt, model=llama90bt, max_tokens=2500)
    return raw_response


async def stream_response(websocket, query: Query, context: list = None):
    print('Generating response...')
    prompt = f'''
        History: {query.history}
        Question: {query.query}
        Context: {context}

        Instructions:
        1. Review history and context. Prioritize relevant information from history.
        2. Evaluate information relevance and sufficiency to answer the question.
        3. If information is limited, use your knowledge to provide the best possible answer.
        4. Maintain a friendly, conversational tone. Avoid robotic language.
        5. Respond in the question's language.
        6. Include disclaimers when necessary, phrased conversationally.
        7. Provide practical advice or step-by-step instructions if relevant.
        8. Suggest additional information needed if the question can't be fully answered.
        9. Assign a general category label (e.g., 'Technical Support', 'Product Information').
        10. Generate three potential follow-up questions.
        11. Provide an 'Answer Score' with brief reasoning.

        Use this XML format:
        <XML>
            <LABEL>label</LABEL>
            <ANSWER>conversational, informative answer</ANSWER>
            <ANSWER_SCORE>score</ANSWER_SCORE>
            <ANSWER_SCORE_REASONING>brief reasoning</ANSWER_SCORE_REASONING>
            <FOLLOW_UP_QUESTIONS>
                <FOLLOW_UP_QUESTION>question 1</FOLLOW_UP_QUESTION>
                <FOLLOW_UP_QUESTION>question 2</FOLLOW_UP_QUESTION>
                <FOLLOW_UP_QUESTION>question 3</FOLLOW_UP_QUESTION>
            </FOLLOW_UP_QUESTIONS>
        </XML>

        Aim for a natural, helpful, and engaging conversation.
    '''

    response_stream = together_client.stream_response(prompt=prompt, model=llama90bt, max_tokens=2500)
    
    for chunk in response_stream:
        response = json.dumps({'action': 'ask_question', 'content': chunk})
        await websocket.send_text(response)
        await asyncio.sleep(0.01)


async def stream_validation(websocket, query: Query, context: list = None, document_text: str = None):
    print('Validating document...')
    prompt = f'''
        Question: {query.query}
        Context: {context}
        Document: {document_text}

        Instructions:
        1. Compare document content directly to educational standard context
        2. Assess if document meets the standard's requirements (Yes/No)
        3. Identify specific alignments with the standard
        4. List any missing elements or gaps
        5. Evaluate the depth and clarity of content
        6. Check for age/grade level appropriateness
        7. Note any inaccuracies or misconceptions
        8. Provide a numerical rating (1-10) with explanation
        9. List 3 specific strengths
        10. List 3 areas for improvement
        11. Give actionable recommendations for enhancement

        Use this XML format:
        <XML>
            <LABEL>label</LABEL>
            <ANSWER>document analysys results, strengths, improvement areas and actionable recommendations</ANSWER>
            <ANSWER_SCORE>score</ANSWER_SCORE>
            <ANSWER_SCORE_REASONING>brief reasoning</ANSWER_SCORE_REASONING>
            <FOLLOW_UP_QUESTIONS>
                <FOLLOW_UP_QUESTION>question 1</FOLLOW_UP_QUESTION>
                <FOLLOW_UP_QUESTION>question 2</FOLLOW_UP_QUESTION>
                <FOLLOW_UP_QUESTION>question 3</FOLLOW_UP_QUESTION>
            </FOLLOW_UP_QUESTIONS>
        </XML>

        Aim for a natural, helpful, and engaging conversation.
    '''

    response_stream = together_client.stream_response(prompt=prompt, model=llama90bt, max_tokens=2500)
    
    for chunk in response_stream:
        response = json.dumps({'action': 'ask_question', 'content': chunk})
        await websocket.send_text(response)
        await asyncio.sleep(0.01)


async def stream_document(websocket, instruction: str, image: str = None):
    prompt = f'''
        Review my instructions and produce an appropriate academic document that:

        1. Matches the inherent complexity and scope of the subject matter
        2. Adapts the writing style and technical depth to the apparent subject domain
        3. Uses the most suitable citation style for the field (defaulting to APA if unclear)
        4. Structures the content with:
        - Appropriate section headings
        - Clear argumentative or explanatory flow
        - Evidence-based support
        - Field-specific terminology and conventions
        5. Includes relevant scholarly elements like methodology, theoretical framework, or analysis as determined by the content
        6. Maintains academic rigor while ensuring accessibility to the likely target audience
        7. Self-adjusts length based on topic complexity and natural development of ideas

        Before writing, briefly state the inferred:
        - Document type
        - Academic level
        - Target audience
        - Primary focus

        Your specific instruction is: {instruction}

        FORMAT:
        - The document must be in markdown format.
        - Make sure the language of the document is the same as the instruction.
    '''

    response_stream = together_client.stream_response(prompt=prompt, model=llama90bt, max_tokens=2500, image_base64=image)
    
    for chunk in response_stream:
        response = json.dumps({'action': 'generate_document', 'content': chunk})
        await websocket.send_text(response)
        await asyncio.sleep(0.01)
