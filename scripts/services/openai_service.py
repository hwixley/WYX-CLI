import os, sys
import openai
from logger import error, info

class OpenAIService:

    FILE_PATH = os.path.dirname(os.path.abspath(__file__))
    REPO_PATH = FILE_PATH.replace("/scripts/services", "")
    LOCAL_PATH = os.getcwd()
    KEY_PATH = f"{REPO_PATH}/.wix-cli-data/.env"
    KEY_NAME="OPENAI_API_KEY"
    ENGINE="gpt-3.5-turbo"

    def __init__(self):
        self.API_KEY = os.environ.get(self.KEY_NAME)
        if self.API_KEY == None:
            if os.path.exists(f"{self.KEY_PATH}"):
                with open(f"{self.KEY_PATH}", "r") as f:
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
    
    def get_git_diff(self):
        cd_cmd = f"cd {self.REPO_PATH}"
        return f"`git diff` output: {os.popen(f'{cd_cmd} && git diff').read()}. `git status` output: {os.popen(f'{cd_cmd} && git status').read()}."
    
    def get_commit_title(self):
        title_prompt = f"Write a 1 line commit message (less than or equal to 60 characters) using the following bash git outputs. {self.get_git_diff()} You do not need to mention anything about the branch these changes were made on, and you should mention the reasoning for the modifications not just what files changed."
        title_response = self.get_response(title_prompt)
        return f"GPT-commit: {title_response}"
    
    def get_commit_description(self):
        title = self.get_commit_title()
        description_prompt = f"Write a 2 line commit message using the following bash git outputs: {self.get_git_diff()}, and elaborates on the commit title: \"{title}\". You should mention the reasoning for the modifications not just what files changed."
        description_response = self.get_response(description_prompt)
        return (title, description_response)
    
    def get_smart_commit(self):
        title, description = self.get_commit_description()
        return f"\"{title}\" -m \"{description}\""


if __name__ == "__main__":
    openai_service = OpenAIService()
    if len(sys.argv) > 1:
        if sys.argv[1] == "title":
            print(openai_service.get_commit_title())
        elif sys.argv[1] == "description":
            print(openai_service.get_commit_description()[1])
        elif sys.argv[1] == "smart":
            print(openai_service.get_smart_commit())
        else:
            print(openai_service.get_response(sys.argv[1]))
        sys.exit()

