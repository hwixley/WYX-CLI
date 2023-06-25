import os, sys
import openai

openai.api_key = os.getenv("OPENAI_API_KEY")

class OpenAIService:

    FILE_PATH = os.path.dirname(os.path.abspath(__file__))
    LOCAL_PATH = os.getcwd()
    KEY_FILE="../../.wix-cli-data/.env"
    KEY_NAME="OPENAI_API_KEY"

    def __init__(self):
        # self.completion = openai.Completion()
        API_KEY = os.environ.get(self.KEY_NAME)
        if API_KEY == None:
            if os.path.exists(f"{self.FILE_PATH}/{self.KEY_FILE}"):
                with open(f"{self.FILE_PATH}/{self.KEY_FILE}", "r") as f:
                    API_KEY = f.read().replace(f"{self.KEY_NAME}=", "")
            else:
                self.error("No API key found.")
                sys.exit()
        
        openai.api_key = API_KEY

    def get_response(self, prompt):
        message = { "role": "user", "content": prompt }
        completion = openai.ChatCompletion.create(
            model="gpt-3.5-turbo",
            messages=[message]
        )
        response = completion.choices[0].message.content
        return response
    
    def get_commit_message(self):
        prompt = f"Write a 2 line commit message using the following bash git outputs. `git diff` output: {os.popen('git diff').read()}. `git status` output: {os.popen('git status').read()}."
        response = self.get_response(prompt)
        return f"GPT-commit: {response}"


if __name__ == "__main__":
    openai_service = OpenAIService()
    print(openai_service.get_commit_message())