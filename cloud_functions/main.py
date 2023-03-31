import functions_framework
import openai

openai.organization = "[YOUR ORGANIZATION HERE KEY HERE]"
openai.api_key = "[YOUR SECRET KEY HERE]"

@functions_framework.http
def use_chatgpt(request):
    """HTTP Cloud Function.
    Args:
        request (flask.Request): The request object.
        <https://flask.palletsprojects.com/en/1.1.x/api/#incoming-request-data>
    Returns:
        The response text, or any set of values that can be turned into a
        Response object using `make_response`
        <https://flask.palletsprojects.com/en/1.1.x/api/#flask.make_response>.
    """
    # Set CORS headers for the preflight request
    if request.method == 'OPTIONS':
        # Allows GET requests from any origin with the Content-Type
        # header and caches preflight response for an 3600s
        headers = {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET',
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Max-Age': '3600'
        }

        return ('', 204, headers)

    request_json = request.get_json(silent=True)
    request_args = request.args

    try:
        systemUtterances = request_json["systemUtterances"][::-1]
        userUtterances = request_json["userUtterances"][::-1]

        msgs = []
        for i in range(len(systemUtterances) + len(userUtterances)):
            if (i % 2 == 0):
                msgs.append({"role": "system", "content": systemUtterances.pop()})
            else:
                msgs.append({"role": "system", "content": userUtterances.pop()})

        thing = openai.ChatCompletion.create(
            model="gpt-4",
            messages=msgs
        )

        response = thing["choices"][0]["message"]["content"]
        promptTokens = thing["usage"]["prompt_tokens"]
        completionTokens = thing["usage"]["completion_tokens"]


        # Set CORS headers for the main request
        headers = {
            'Access-Control-Allow-Origin': '*'
        }
        body =  {"response": response, "promptTokens": promptTokens, "completionTokens": completionTokens}
        return (body, 200, headers)
    except Exception as e:
        print("ERROR: ", e)
        return {"response": ":("}
