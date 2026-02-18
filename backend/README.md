# Tamil App Backend API

This is a FastAPI backend for the Tamil Learning App.

## Setup

1.  **Create a virtual environment**:
    ```bash
    python -m venv venv
    .\venv\Scripts\activate
    ```

2.  **Install dependencies**:
    ```bash
    pip install -r requirements.txt
    ```

3.  **Run the server**:
    ```bash
    uvicorn app.main:app --reload
    ```

The API will be available at `http://127.0.0.1:8000`.
Documentation (Swagger UI) is available at `http://127.0.0.1:8000/docs`.
