A golang script (compiled) to execute a langchain based
agentic workflow for clearing newsletters from my inbox.

- Uses env variables for keys
- Uses openai api
- uses langchaingo


Techstack:
- email authentication google OAuth 2.0

Please provide a helpful message for authentication when there are any problems

This script must run and execute without any intervention from the user. 

Newsletter clearing logic is basically the following:

- Is the email a newsletter?
- No? -> do nothing
- If it is a newsletter, is it one the user signed up for?
    - query the email for similar
- No? -> add unsubscribe label
- Yes? -> add newsletter label
