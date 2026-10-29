
"""ASGI entry point: run with uvicorn main:app --reload."""

from src.api import app

__all__ = ["app"]
