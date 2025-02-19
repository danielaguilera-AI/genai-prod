# genai-prod

`genai-prod` is a project designed to deploy an Amazon Elastic Container Service (ECS) infrastructure that hosts a Large Language Model (LLM) accessible through a Gradio user interface. This setup enables users to interact with the LLM via a web-based interface, facilitating seamless AI-driven experiences.

## Table of Contents

- [Installation](#installation)
  - [Installing Python with pyenv](#installing-python-with-pyenv)
  - [Installing Poetry](#installing-poetry)
  - [Installing Project Dependencies](#installing-project-dependencies)
  - [Installing Terraform](#installing-terraform)
- [Usage](#usage)
  - [Running the Gradio Application](#running-the-gradio-application)
  - [Deploying Infrastructure with Terraform](#deploying-infrastructure-with-terraform)
- [Project Structure](#project-structure)
- [Contributing](#contributing)
- [License](#license)
- [Acknowledgments](#acknowledgments)

## Installation

### Installing Python with pyenv

To ensure compatibility, it's recommended to use the Python version specified in the `.python-version` file. `pyenv` simplifies the process of managing multiple Python versions.

1. **Install pyenv**:

   - **macOS**:

     Install Homebrew if it's not already installed:

     ```bash
     /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
     ```

     Then, install pyenv:

     ```bash
     brew update
     brew install pyenv
     ```

   - **Ubuntu**:

     Update system packages and install dependencies:

     ```bash
     sudo apt update
     sudo apt install -y make build-essential libssl-dev zlib1g-dev \
     libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
     libncurses5-dev libncursesw5-dev xz-utils tk-dev libffi-dev \
     liblzma-dev python-openssl git
     ```

     Install pyenv:

     ```bash
     curl https://pyenv.run | bash
     ```

     Add pyenv to your shell:

     ```bash
     echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
     echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
     echo -e 'if command -v pyenv 1>/dev/null 2>&1; then\n eval "$(pyenv init --path)"\nfi' >> ~/.bashrc
     source ~/.bashrc
     ```

   - **Windows**:

     Install `pyenv` using `pyenv-win`. Follow the instructions in the [pyenv-win GitHub repository](https://github.com/pyenv-win/pyenv-win).

2. **Install the required Python version**:

   Navigate to the project directory and run:

   ```bash
   pyenv install $(cat .python-version)
