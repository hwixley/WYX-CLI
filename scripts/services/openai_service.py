import os, sys
import openai
from logger import error, info

class OpenAIService:

    FILE_PATH = os.path.dirname(os.path.abspath(__file__))
    LOCAL_PATH = os.getcwd()
    KEY_FILE="../../.wix-cli-data/.env"
    KEY_NAME="OPENAI_API_KEY"
    ENGINE="gpt-3.5-turbo"

    def __init__(self):
        self.API_KEY = os.environ.get(self.KEY_NAME)
        if self.API_KEY == None:
            if os.path.exists(f"{self.FILE_PATH}/{self.KEY_FILE}"):
                with open(f"{self.FILE_PATH}/{self.KEY_FILE}", "r") as f:
                    self.API_KEY = f.read().replace(f"{self.KEY_NAME}=", "")
            else:
                error("No API key found.")
                sys.exit()
        
        openai.api_key = self.API_KEY

    def get_response(self, prompt):
        message = { "role": "user", "content": prompt }
        completion = openai.ChatCompletion.create(
            model=self.ENGINE,
            messages=[message]
        )
        response = completion.choices[0].message.content
        return response
    
    def get_commit_message(self):
        prompt = f"Write a 1 line commit message using the following bash git outputs. You do not need to mention anything about the branch these changes were made on, and you should mention the reasoning for the modifications not just what files changed. `git diff` output: {os.popen('git diff').read()}. `git status` output: {os.popen('git status').read()}."
        response = self.get_response(prompt)
        return f"GPT-commit: {response}"


if __name__ == "__main__":
    openai_service = OpenAIService()
    print(openai_service.get_commit_message())