"""The HTTP surface of the reader."""

import logging
from collections.abc import Callable

from fastapi import FastAPI, Header, Request
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field

from . import service
from .extract import HourCategory
from .gateway import Gateway

logger = logging.getLogger(__name__)


class ReadBody(BaseModel):
    path: str = Field(max_length=200)
    file_name: str = Field(max_length=255)


class ManualBody(BaseModel):
    path: str = Field(max_length=200)
    title: str
    category: HourCategory
    hours: int


def _bearer(authorization: str | None) -> str | None:
    if authorization and authorization.lower().startswith("bearer "):
        return authorization[7:].strip() or None
    return None


def _run[T](action: Callable[[], T]) -> T:
    """Runs [action]; anything but a refusal (settings missing, server down)
    becomes 503, logged by type only."""
    try:
        return action()
    except service.ReaderError:
        raise
    except Exception as error:
        logger.error("Reader unavailable: %s", type(error).__name__)
        raise service.ReaderError(503, "unavailable") from None


def _launched(result: service.Launched) -> JSONResponse:
    return JSONResponse(
        status_code=201,
        content={
            "title": result.title,
            "issuer": result.issuer,
            "category": result.category.value,
            "hours": result.hours,
        },
    )


def create_app(
    gateway: Callable[[], Gateway], allowed_origins: list[str] | None = None
) -> FastAPI:
    """The reader, talking to the server through [gateway] (built on first
    use, so importing the app reads no settings)."""
    app = FastAPI(docs_url=None, redoc_url=None, openapi_url=None)
    if allowed_origins:
        app.add_middleware(
            CORSMiddleware,
            allow_origins=allowed_origins,
            allow_methods=["POST"],
            allow_headers=["Authorization", "Content-Type"],
        )

    @app.exception_handler(service.ReaderError)
    def _refused(_: Request, error: service.ReaderError) -> JSONResponse:
        return JSONResponse(status_code=error.status, content={"error": error.code})

    @app.exception_handler(RequestValidationError)
    def _invalid(_: Request, __: RequestValidationError) -> JSONResponse:
        return JSONResponse(status_code=422, content={"error": "invalid"})

    @app.post("/api/certificates/read")
    def read(
        body: ReadBody, authorization: str | None = Header(default=None)
    ) -> JSONResponse:
        return _launched(
            _run(
                lambda: service.read_certificate(
                    gateway(), _bearer(authorization), body.path, body.file_name
                )
            )
        )

    @app.post("/api/certificates/manual")
    def manual(
        body: ManualBody, authorization: str | None = Header(default=None)
    ) -> JSONResponse:
        return _launched(
            _run(
                lambda: service.launch_manually(
                    gateway(),
                    _bearer(authorization),
                    body.path,
                    body.title,
                    body.category,
                    body.hours,
                )
            )
        )

    return app
