from __future__ import annotations

from dataclasses import dataclass
from enum import StrEnum


class EvidenceClass(StrEnum):
    VERIFIED = "V"
    MEASURED = "M"
    QUOTED = "Q"
    CALCULATED = "C"
    ESTIMATED = "E"
    ASSUMED = "A"
    HISTORICAL = "H"
    UNKNOWN = "U"


@dataclass(frozen=True, slots=True)
class ValidationIssue:
    path: str
    message: str
    severity: str = "error"
