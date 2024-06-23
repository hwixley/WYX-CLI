import os, sys
from openai import OpenAI
from logger import error, info
from termcolor import colored


def read_file(file_path):
    with open(file_path, "r") as f:
        return f.read()

def get_git_diff():
    return f"`git diff` output: {os.popen('git diff').read()}, and `git status` output: {os.popen('git status').read()}."

def format_message(role, message):
    return { "role": role, "content": message }


class Prompt:
    title: str
    description: str

    def __init__(self):
        self.title = self.gen_title()
        self.description = self.gen_description()

    def gen_title(self) -> str:
        return self.prompt_eng(
            instr_prefix="Write a 1 line commit message less than or equal to 50 characters technically describing the following bash git outputs."
        )
    
    def gen_description(self) -> str:
        return self.prompt_eng(
            instr_prefix="Write a 2 line commit message technically describing the following bash git outputs.",
            instr_suffix=f"Do not repeat the title \"{self.title}\"."
        )

    def prompt_eng(self, instr_prefix: str, instr_suffix: str = "") -> str:
        context = f"CONTEXT:\nYou are in a team of developers working on a project. You are using Git source control and need to write succinct yet informative commit messages for the changes that have been made by understanding the passed `git diff` and `git status` outputs."
        instructions = f"INSTRUCTIONS:\n{instr_prefix} {get_git_diff()}\n\n{instr_suffix} Do not mention anything about the branch these changes were made on, however, you can use the branch name as a hint to for the desired commit message contents if it is relevant. Mention specifically which functions, classes or variables were modified/created/deleted and why."
        return context + "\n"*2 + instructions


class OpenAIService:

    FILE_PATH = os.path.dirname(os.path.abspath(__file__))
    REPO_PATH = FILE_PATH.replace("/src/commands/scripts/services", "")
    LOCAL_PATH = os.getcwd()
    LOCAL_README_PATH = f"{LOCAL_PATH}/.github/README.md" if os.path.exists(f"{LOCAL_PATH}/.github/README.md") else (f"{LOCAL_PATH}/README.md" if os.path.exists(f"{LOCAL_PATH}/README.md") else "")
    LOCAL_README = ("\n\nFor context this is the repository's README file: \n" + read_file(LOCAL_README_PATH)) if os.path.exists(LOCAL_README_PATH) else ""
    KEY_PATH = f"{REPO_PATH}/.wyx-cli-data/.env"
    KEY_NAME="OPENAI_API_KEY"
    ENGINE="gpt-3.5-turbo"
    ASSISTANT_MESSAGE_DEV = { "role": "system", "content": f"You are the WYX-CLI Smart Commit bot. You must write an informative yet succinct commit message for the changes you can see have been made from the specified 'git ...' command outputs. Ignore cache files and mention specifically which functions, classes or variables were modified/created/deleted and why.{LOCAL_README}"}
    ASSISTANT_MESSAGE = { "role": "system", "content": f"Your name is the WYX-CLI bot, you were created by Harry Wixley for a bash CLI project. You are an assistant setup on a command line to help developers with any queries they may have developer related or otherwise."}
    SEPARATOR="-"*110
    MAX_TOKENS=4097

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
        
        self.client = OpenAI(api_key=self.API_KEY)

    def get_response(self, prompt, chat_history: list = []):
        history = chat_history + [format_message("user", prompt[:self.MAX_TOKENS])]
        completion = self.client.chat.completions.create(model=self.ENGINE,
        messages=history)
        response = completion.choices[0].message.content
        return response

    def get_commit_title(self, title_prompt: str):
        chat_history = [self.ASSISTANT_MESSAGE_DEV]
        title_response = self.get_response(title_prompt, chat_history)
        return f"GPT-commit: {title_response}"

    def get_commit_description(self, prompt: Prompt = Prompt()):
        chat_history = [self.ASSISTANT_MESSAGE_DEV]
        title = self.get_commit_title(title_prompt=prompt.title)
        description_response = self.get_response(prompt.description, chat_history)
        return (title, description_response)

    def get_smart_commit(self):
        title, description = self.get_commit_description()
        return f"{title}\n{description}"

    def conversate(self):
        print(colored("\n" + self.SEPARATOR + "\nStarting a conversation with ChatGPT. Type \"quit\", \"exit\", or \"q\" to exit, or \"save\" to save the conversation to a txt file.\n" + self.SEPARATOR, "blue"))
        latest_question = ""
        chat_history = [self.ASSISTANT_MESSAGE]

        while True:
            latest_question = input(colored("\nYou: ", "green"))

            if latest_question in ["quit", "exit", "q"]:
                print(colored("\n\nQuitting conversation...\n","yellow"))
                break

            elif latest_question == "save" and len(chat_history) > 1:
                self.save_chat_history(chat_history[1:])
                print(colored("\n\nSaving conversation...\n","yellow"))

            else:
                question_response = self.get_response(latest_question, chat_history)

                chat_history.append(format_message("user", latest_question))
                chat_history.append(format_message("assistant", question_response))

                print(colored("\n🤖:", "blue") + f" {question_response}")

            print(colored("\n" + self.SEPARATOR, "blue"))

    def save_chat_history(self, chat_history: list):
        file_name = input(colored("\n\nEnter the name of your txt file to save the chat history to: ", "yellow"))
        with open(f"{self.LOCAL_PATH}/{file_name}.txt", "w") as f:
            f.write("Chat history:\n")
            for message in chat_history:
                f.write(f"\n{message['role']}: {message['content']}\n")


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

