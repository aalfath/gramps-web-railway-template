"""Create the first Gramps Web account from OWNER_USERNAME / OWNER_PASSWORD if no user exists yet."""
import os
import sys

from gramps_webapi.app import create_app
from gramps_webapi.auth import add_user, get_number_users, user_db
from gramps_webapi.auth.const import ROLE_ADMIN

username = os.environ.get("OWNER_USERNAME", "owner").strip() or "owner"
password = os.environ.get("OWNER_PASSWORD", "")

app = create_app()
with app.app_context():
    user_db.create_all()
    if get_number_users() > 0:
        print("create_owner: users already exist, nothing to do")
        sys.exit(0)
    if not password:
        print(
            "create_owner: WARNING no OWNER_PASSWORD set and no user exists; "
            "the first visitor can claim the site with the setup wizard",
            file=sys.stderr,
        )
        sys.exit(0)
    add_user(
        name=username,
        password=password,
        fullname="Owner",
        email=os.environ.get("OWNER_EMAIL") or None,
        role=ROLE_ADMIN,
    )
    print(f"create_owner: created admin account '{username}'")
