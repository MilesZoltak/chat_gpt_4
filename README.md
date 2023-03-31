# ChatGPT-4

Basically what we have here is a very simply REPL type interface for interacting with the GPT-4 API I got access to.

It is hosted online [here](https://gpt4-chat-9f5ae.web.app/#/).  Note that this site is password protected since the API uses my secret key and I can't have that getting out for obvious reasons.  But check out the demo below!

![A GIF walkthrough of me using my GPT 4 app where I ask a few things and it responds.](https://firebasestorage.googleapis.com/v0/b/gpt4-chat-9f5ae.appspot.com/o/ChatGPT4-demo.gif?alt=media&token=8f6f57ef-972d-42ad-9f7d-f65876b465a6)

I also have two files in the `cloud_functions` folder, `main.py` and `requirements.txt` these two files together are what run in Google Cloud Functions in the backend to actually communicate with the GPT-4 API.

NOTE: You can absolutely clone this repo to get a mobile or web app that can communicate with GPT-4, but you'll need to go into `main.py` and change the organization key and the secret key.  Also, I love using ChatGPT for code.  This tool doesn't currenty do any nice code formatting, but I might add that in the future if I feel so inspired.
