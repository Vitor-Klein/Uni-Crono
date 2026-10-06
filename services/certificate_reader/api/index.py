"""Entry point of the Vercel function."""

import os
from functools import cache

from reader.app import create_app
from reader.supabase_gateway import SupabaseGateway


@cache
def _gateway() -> SupabaseGateway:
    return SupabaseGateway.from_env()


app = create_app(
    _gateway,
    allowed_origins=[
        origin.strip()
        for origin in os.environ.get("ALLOWED_ORIGINS", "").split(",")
        if origin.strip()
    ],
)
