# Bugz Deployment & Distribution Guide

This guide details how to deploy the Bugz backend to Google Cloud Platform (Cloud Run) and distribute the CLI to users as a standalone binary, similar to `claude-code`.

## Architecture Overview

- **Backend**: Python FastAPI service running on **Google Cloud Run**. This allows for auto-scaling (including scale-to-zero) and easy updates.
- **CLI**: Python Typer application packaged as a **standalone binary** using PyInstaller. Users download a single file and run it, without needing to manage Python environments.

---

## Part 1: Backend Deployment (Google Cloud Run)

### Prerequisites
- Google Cloud Platform account.
- `gcloud` CLI installed and authenticated. (user: shekhargowda@bugzidna.com)
- A project created in GCP (e.g., `bugz-cli`).

### 1. Setup GCP Project
```bash
# Set your project ID
export PROJECT_ID="your-project-id"
gcloud config set project $PROJECT_ID

# Enable necessary services
gcloud services enable run.googleapis.com containerregistry.googleapis.com cloudbuild.googleapis.com
```

### 2. Build and Push Docker Image
Navigate to the `backend` directory:
```bash
cd backend
```

Submit a build to Cloud Build (this builds the Docker image and stores it in Container Registry/Artifact Registry):
```bash
gcloud builds submit --tag gcr.io/$PROJECT_ID/bugz-backend
```

### 3. Deploy to Cloud Run
Deploy the service. Replace `YOUR_GEMINI_API_KEY` with your actual key, or better yet, use Secret Manager (see below).

```bash
gcloud run deploy bugz-backend \
  --image gcr.io/$PROJECT_ID/bugz-backend \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --set-env-vars GEMINI_API_KEY="YOUR_GEMINI_API_KEY"
```

**Note on Security**: `--allow-unauthenticated` makes the API public. Since the CLI is distributed to users, this is likely intended, but you may want to implement API key authentication or user authentication (OAuth) in the backend for production.

**Using Secrets (Recommended)**:
1. Create a secret: `echo -n "YOUR_KEY" | gcloud secrets create gemini-api-key --data-file=-`
2. Grant access: `gcloud secrets add-iam-policy-binding gemini-api-key --member=serviceAccount:YOUR_SERVICE_ACCOUNT --role=roles/secretmanager.secretAccessor`
3. Deploy with secret: `--set-secrets GEMINI_API_KEY=gemini-api-key:latest`

### 4. Get the Backend URL
After deployment, Cloud Run will output a URL (e.g., `https://bugz-backend-xyz-uc.a.run.app`). Copy this URL.

---

## Part 2: CLI Packaging & Distribution

### 1. Configure Backend URL
The CLI needs to know where the backend is.
**Option A (Environment Variable)**:
Modify `cli/repl.py` to look for an env var:
```python
BACKEND_URL = os.getenv("BUGZ_BACKEND_URL", "https://bugz-backend-xyz-uc.a.run.app")
```

**Option B (Build-time Config)**:
Hardcode the production URL in `cli/repl.py` before building the release binary.

### 2. Package with PyInstaller
PyInstaller creates a standalone executable that includes the Python interpreter and all dependencies.

1. Install PyInstaller:
   ```bash
   pip install pyinstaller
   ```

2. Build the binary (from the root directory):
   ```bash
   # Make sure you are in the root of the repo
   # Install cli dependencies first
   pip install -r cli/requirements.txt

   # Build
   pyinstaller --name bugz \
     --onefile \
     --add-data "cli:cli" \
     --hidden-import "rich" \
     --hidden-import "typer" \
     cli/main.py
   ```

   *Note: You might need to adjust hidden imports if some are missed.*

3. The binary will be in `dist/bugz`.

### 3. Distribution

#### Option A: One-Line Install Script (curl | bash)
We have created an `install.sh` script in the repository. You can host this or users can run it directly from GitHub.

**User Command:**
```bash
curl -sL https://raw.githubusercontent.com/Bugzidna-Labs/bugz/main/install.sh | bash
```

This script:
1. Detects the OS (macOS/Linux).
2. Fetches the latest release tag from GitHub API.
3. Downloads the appropriate binary (`bugz-macos` or `bugz-linux`).
4. Installs it to `/usr/local/bin/bugz`.

#### Option B: Homebrew (macOS)
(Optional) You can still set up a Homebrew tap if desired, but the script above is the quickest way to start.

### 4. Release Process
To release a new version of the CLI:

1.  **Prerequisite**: Ensure you have added a `PUBLIC_REPO_TOKEN` secret to your **private** repository (`bugz-agent-cli`).
    *   **Recommended**: Use a **Fine-grained Personal Access Token**.
        *   **Repository access**: Select only the public repository (`Bugzidna-Labs/bugz`).
        *   **Permissions**: Under "Repository permissions", select **Contents** and set it to **Read and write**.
    *   **Alternative**: Classic PAT with `repo` scope.

2.  **Tag & Release**:
    Commit your changes in the private repo and tag the commit:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

3.  **Automation**:
    The GitHub Action in the private repo will:
   - Build the binary.
   - Publish the release to the **public** repository (`Bugzidna-Labs/bugz`).

4.  **Public Repo Setup**:
    To update the `install.sh` or `README.md` in the public repo, run:
    ```bash
    ./public_setup.sh
    ```
