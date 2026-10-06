"""Turns a stored PDF into a certificate of the student."""

import hashlib
import re
from dataclasses import dataclass

from .extract import (
    MAX_HOURS,
    MAX_TITLE,
    MIN_HOURS,
    HourCategory,
    classify,
    find_hours,
    find_issuer,
    find_title,
)
from .gateway import Gateway, Student
from .pdf_text import extract_text

MAX_BYTES = 10 * 1024 * 1024

_UUID = r"[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"


class ReaderError(Exception):
    """A refusal, with the HTTP status and the code the app reads. The code
    never carries the PDF text, a path or a stack trace."""

    def __init__(self, status: int, code: str) -> None:
        super().__init__(code)
        self.status = status
        self.code = code


@dataclass(frozen=True)
class Launched:
    title: str
    issuer: str | None
    category: HourCategory
    hours: int


@dataclass(frozen=True)
class _Pdf:
    student: Student
    path: str
    data: bytes
    text: str

    @property
    def sha256(self) -> str:
        return hashlib.sha256(self.data).hexdigest()


def _authorize(gateway: Gateway, token: str | None, path: str) -> Student:
    """The owner of [token], when [path] is a PDF in their own folder."""
    student = gateway.student_for(token) if token else None
    if student is None:
        raise ReaderError(401, "unauthorized")
    if not re.fullmatch(rf"{re.escape(student.id)}/{_UUID}\.pdf", path):
        raise ReaderError(403, "forbidden")
    return student


def _open(gateway: Gateway, student: Student, path: str) -> _Pdf:
    """The stored PDF at [path], checked: it exists, its size and its type."""
    data = gateway.download(path)
    if data is None:
        raise ReaderError(404, "not_found")
    if len(data) > MAX_BYTES:
        gateway.delete(path)
        raise ReaderError(413, "too_large")
    if not data.startswith(b"%PDF-"):
        gateway.delete(path)
        raise ReaderError(415, "not_pdf")
    return _Pdf(student=student, path=path, data=data, text=extract_text(data))


def _save(gateway: Gateway, pdf: _Pdf, launched: Launched, source: str) -> Launched:
    saved = gateway.insert_certificate(
        {
            "user_id": pdf.student.id,
            "title": launched.title,
            "issuer": launched.issuer,
            "category": launched.category.value,
            "hours": launched.hours,
            "file_path": pdf.path,
            "file_sha256": pdf.sha256,
            "source": source,
        }
    )
    if not saved:
        # The student already has this certificate: this upload is a copy.
        gateway.delete(pdf.path)
        raise ReaderError(409, "duplicate")
    return launched


def read_certificate(
    gateway: Gateway, token: str | None, path: str, file_name: str
) -> Launched:
    """Reads the hours of the PDF and saves the certificate. A PDF without
    text or without hours is kept, so the student can launch it by hand."""
    pdf = _open(gateway, _authorize(gateway, token, path), path)
    if not pdf.text:
        raise ReaderError(422, "no_text")
    hours = find_hours(pdf.text)
    if hours is None:
        raise ReaderError(422, "no_hours")
    launched = Launched(
        title=find_title(pdf.text, file_name),
        issuer=find_issuer(pdf.text, pdf.student.institution.upper()),
        category=classify(pdf.text),
        hours=hours,
    )
    return _save(gateway, pdf, launched, "extracted")


def launch_manually(
    gateway: Gateway,
    token: str | None,
    path: str,
    title: str,
    category: HourCategory,
    hours: int,
) -> Launched:
    """Saves the hours the student typed, only for a PDF the reader still
    cannot read: a readable PDF always counts what the reader found."""
    student = _authorize(gateway, token, path)
    title = re.sub(r"\s+", " ", title).strip()
    if not title or len(title) > MAX_TITLE or not MIN_HOURS <= hours <= MAX_HOURS:
        raise ReaderError(422, "invalid")
    pdf = _open(gateway, student, path)
    if pdf.text and find_hours(pdf.text) is not None:
        raise ReaderError(409, "readable")
    launched = Launched(title=title, issuer=None, category=category, hours=hours)
    return _save(gateway, pdf, launched, "manual")
