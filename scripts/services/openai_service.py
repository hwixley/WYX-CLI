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
    ASSISTANT_MESSAGE = { "role": "system", "content": "You are a helpful assistant."}

    def __init__(self):
        self.API_KEY = os.environ.get(self.KEY_NAME)
        if self.API_KEY == None:
            if os.path.exists(f"{self.KEY_PATH}"):
                with open(f"{self.KEY_PATH}", "r") as f:
                    for l in f.read().split("\n"):
                        if l.startswith(self.KEY_NAME):
                            self.API_KEY = l.replace(f"{self.KEY_NAME}=", "")
                            break
            else:
                error("No API key found.")
                sys.exit()
        
        openai.api_key = self.API_KEY

    def format_message(self, role, message):
        return { "role": role, "content": message }

    def get_response(self, prompt, chat_history: list = []):
        history = chat_history + [self.format_message("user", prompt)]
        completion = openai.ChatCompletion.create(
            model=self.ENGINE,
            messages=history
        )
        response = completion.choices[0].message.content
        return response
    
    def get_git_diff(self):
        return f"`git diff` output: {os.popen('git diff').read()}. `git status` output: {os.popen('git status').read()}."
    
    def get_commit_title(self):
        title_prompt = f"Pretend you are in a team of developers working on a project. Write a 1 line commit message less than or equal to 50 characters technically describing the following bash git outputs. {self.get_git_diff()} Do not mention anything about the branch these changes were made on. Mention specifically which functions, classes or variables were modified/created/deleted and why."
        title_response = self.get_response(title_prompt)
        return f"GPT-commit: {title_response}"
    
    def get_commit_description(self):
        title = self.get_commit_title()
        description_prompt = f"Pretend you are in a team of developers working on a project. Write a 2 line commit message technically describing the following bash git outputs. {self.get_git_diff()} Do not repeat the title \"{title}\", and do not mention anything about the branch these changes were made on. Mention specifically which functions, classes or variables were modified/created/deleted and why."
        description_response = self.get_response(description_prompt)
        return (title, description_response)
    
    def get_smart_commit(self):
        title, description = self.get_commit_description()
        return f"{title}\n{description}"

    def conversate(self):
        print("Starting a conversation with OpenAI. Type \"quit\" to exit.")
        latest_question = ""
        chat_history = [self.ASSISTANT_MESSAGE]
        while True:
            latest_question = input("\n\nYou: ")
            if latest_question == "quit":
                break

            question_response = self.get_response(latest_question, chat_history)

            chat_history.append(self.format_message("user", latest_question))
            chat_history.append(self.format_message("assistant", question_response))

            print(f"\nOpenAI: {question_response}")



if __name__ == "__main__":
    openai_service = OpenAIService()
    if len(sys.argv) > 1:
        if sys.argv[1] == "title":
            print(openai_service.get_commit_title())
        elif sys.argv[1] == "description":
            print(openai_service.get_commit_description()[1])
        elif sys.argv[1] == "smart":
            print(openai_service.get_smart_commit())
        elif sys.argv[1] == "conversate":
            openai_service.conversate()
        else:
            print(openai_service.get_response(sys.argv[1]))
        sys.exit()

