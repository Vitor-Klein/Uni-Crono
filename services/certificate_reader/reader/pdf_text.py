"""The text of a PDF."""

import io
import logging

from pypdf import PdfReader

MAX_PAGES = 10

logger = logging.getLogger(__name__)


def extract_text(data: bytes) -> str:
    """The text of the first pages, or "" when the PDF has none or cannot be
    read (scanned, damaged or encrypted)."""
    try:
        reader = PdfReader(io.BytesIO(data))
        pages = reader.pages[:MAX_PAGES]
        return "\n".join(page.extract_text() or "" for page in pages).strip()
    except Exception as error:  # noqa: BLE001 - any unreadable PDF has no text
        logger.info("PDF without readable text: %s", type(error).__name__)
        return ""
