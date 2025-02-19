# genai-prod

`genai-prod` is a project designed to deploy an Amazon Elastic Container Service (ECS) infrastructure that hosts a Large Language Model (LLM) accessible through a Gradio user interface. This setup enables users to interact with the LLM via a web-based interface, facilitating seamless AI-driven experiences.

## Table of Contents

1. [Installation on Windows](#installation-on-windows)
   - [Installing Chocolatey](#installing-chocolatey)
   - [Installing Python with pyenv-win](#installing-python-with-pyenv-win)
   - [Installing Poetry](#installing-poetry)
   - [Installing Project Dependencies](#installing-project-dependencies)
   - [Installing AWS CLI](#installing-aws-cli)
   - [Installing Terraform](#installing-terraform)
2. [Usage](#usage)
   - [Deploying Infrastructure with Terraform](#deploying-infrastructure-with-terraform)
   - [Running the Gradio Application](#running-the-gradio-application)

## 1. Installation on Windows

### 1.1. Installing Chocolatey
Chocolatey is a package manager for Windows that simplifies software installation.

1. **Open PowerShell as Administrator** and run:
   ```powershell
   Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
   ```
2. **Verify Chocolatey installation**:
   ```powershell
   choco --version
   ```

### 1.2. Installing Python with pyenv-win
To manage multiple Python versions on Windows, `pyenv-win` is a reliable tool.

1. **Install pyenv-win**:
   ```powershell
   Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/pyenv-win/pyenv-win/master/pyenv-win/install-pyenv-win.ps1" -OutFile "$HOME\install-pyenv-win.ps1"; & "$HOME\install-pyenv-win.ps1"
   ```

2. **Install a specific Python version**:
   ```powershell
   pyenv install 3.10.11
   pyenv global 3.10.11
   pyenv local 3.10.11
   ```

### 1.3. Installing Poetry
Poetry is a Python tool for dependency management and packaging, enabling you to declare and manage libraries your project depends on, handling installation and updates automatically.

```powershell
Invoke-WebRequest -Uri https://install.python-poetry.org -UseBasicParsing | python -
```

After installation, add Poetry to your system's PATH by executing:
```powershell
$env:Path += ";$env:USERPROFILE\.poetry\bin"
```

Verify the installation:
```powershell
poetry --version
```

### 1.4. Installing Project Dependencies
Once Poetry is installed, navigate to the project's root directory and execute:
```powershell
poetry install
```
This command will create a virtual environment and install all necessary dependencies as specified in the `pyproject.toml` file.

### 1.5. Installing AWS CLI
AWS CLI is needed to interact with AWS services from the command line.

**Install AWS CLI using Chocolatey:**
```powershell
choco install awscli -y
```

**Configure AWS Credentials:**
```powershell
aws configure
```
You will be prompted to enter:
1. AWS Access Key ID
2. AWS Secret Access Key
3. Default region name (e.g., us-east-1)
4. Default output format (json, text, or table)

**Verify installation:**
```powershell
aws --version
```

### 1.6. Installing Terraform
Terraform is an open-source infrastructure as code tool developed by HashiCorp that enables users to define and provision data center infrastructure using a declarative configuration language.

**Install Terraform using Chocolatey:**
```powershell
choco install terraform -y
```

**Verify the installation:**
```powershell
terraform -v
```

## 2. GitHub Secrets Configuration

If a new project is created, ensure the following secrets are set in the GitHub repository under **Settings > Secrets and variables > Actions**:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION`
- `AWS_ACCOUNT_ID`

These secrets are needed for running GitHub actions (CI/CD)

## 3. Usage

### 2.1. Deploying Infrastructure with Terraform
To deploy the infrastructure, navigate to the Terraform directory and execute:

```powershell
cd terraform
terraform init
terraform plan
terraform apply -auto-approve
```

### 2.2. Running the Gradio Application
To start the Gradio UI locally, run:

```powershell
poetry run python app_gradio.py
```

The application will be accessible via the displayed local URL.








