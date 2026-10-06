"""Rules that read a certificate's text: hours, category, title and issuer."""

import re
import unicodedata
from enum import StrEnum
from pathlib import PurePosixPath


class HourCategory(StrEnum):
    COMPLEMENTARY = "complementary"
    EXTENSION = "extension"


MIN_HOURS = 1
MAX_HOURS = 999
MAX_TITLE = 120


def normalize(text: str) -> str:
    """Lower case, without accents, with single spaces."""
    decomposed = unicodedata.normalize("NFKD", text)
    plain = "".join(c for c in decomposed if not unicodedata.combining(c))
    return re.sub(r"\s+", " ", plain).strip().lower()


# A number right after "carga horaria", with at most 40 other characters.
_WORKLOAD = re.compile(r"carga horaria\D{0,40}?(?<![\d/.,:])(\d{1,4})(?![\d/])")

# "8h", "10h30", "20 horas", "12 hrs", "40 (quarenta) horas".
_DURATION = re.compile(
    r"(?<![\d/.,:])(\d{1,4})\s*(?:\([^)\d]{1,30}\)\s*)?"
    r"(?:h(?:\d{2})?|horas?|hrs?)\b"
)

# Words that make "8h" a time of day: "as 14h", "das 8h", "ate as 12h".
_CLOCK_BEFORE = re.compile(r"\b(?:as|das|ate|partir das)\s*$")


def _in_range(hours: int) -> int | None:
    return hours if MIN_HOURS <= hours <= MAX_HOURS else None


def find_hours(text: str) -> int | None:
    """The workload of the certificate, or None when it is not stated.

    The number after "carga horária" wins; otherwise the first duration that
    is not a time of day. Minutes are dropped; outside 1-999 is no answer.
    """
    plain = normalize(text)
    workload = _WORKLOAD.search(plain)
    if workload:
        return _in_range(int(workload.group(1)))
    for match in _DURATION.finditer(plain):
        if _CLOCK_BEFORE.search(plain[: match.start()]):
            continue
        return _in_range(int(match.group(1)))
    return None


def classify(text: str) -> HourCategory:
    """Extension when the text speaks of extension; complementary otherwise."""
    plain = normalize(text)
    if re.search(r"\bextens(?:ao|ionista)", plain):
        return HourCategory.EXTENSION
    return HourCategory.COMPLEMENTARY


_MARKER = r"(?:participou d[oa]s?|concluiu o curso|evento)"
_QUOTED = re.compile(
    _MARKER + r"\s+(?:[^\s\"“”]+\s+)?[\"“]([^\"“”]{2,300})[\"”]", re.IGNORECASE
)
_UNQUOTED = re.compile(
    r"(?:participou d[oa]s?|concluiu o curso)\s+([^,.;\"“”]{2,300})",
    re.IGNORECASE,
)


def _clean_title(title: str) -> str:
    title = re.sub(r"\s+", " ", title).strip()
    if len(title) > MAX_TITLE:
        title = title[:MAX_TITLE].rsplit(" ", 1)[0] or title[:MAX_TITLE]
    return title[:1].upper() + title[1:]


def find_title(text: str, file_name: str) -> str:
    """What the certificate is for: the quoted name after the marker, else
    the text up to the next comma or period, else the file name."""
    flat = re.sub(r"\s+", " ", text)
    for pattern in (_QUOTED, _UNQUOTED):
        match = pattern.search(flat)
        if match:
            title = _clean_title(match.group(1))
            if title:
                return title
    return title_from_file_name(file_name)


def title_from_file_name(file_name: str) -> str:
    """`certificado-game-jam.pdf` -> "Certificado Game Jam"."""
    stem = PurePosixPath(file_name.replace("\\", "/")).stem
    words = re.sub(r"[-_]+", " ", stem).split()
    title = " ".join(word[:1].upper() + word[1:] for word in words)
    return _clean_title(title) or "Certificado"


def find_issuer(text: str, institution: str) -> str | None:
    """The student's institution, when the certificate names it."""
    if re.search(rf"\b{re.escape(institution)}\b", text, re.IGNORECASE):
        return institution
    return None
