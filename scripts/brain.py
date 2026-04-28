#!/usr/bin/env python3
"""Phase 1 brain helper. Protocol lives in <brain>/CLAUDE.md."""

import argparse
import hashlib
import json
import re
import shutil
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path


def find_brain() -> Path:
    cwd = Path.cwd()
    for parent in [cwd, *cwd.parents]:
        claude_md = parent / "CLAUDE.md"
        if not claude_md.exists():
            continue
        for line in claude_md.read_text().splitlines():
            m = re.match(r"^\s*brain:\s*(\S+)\s*$", line)
            if not m:
                continue
            brain = (parent / m.group(1)).resolve()
            if not brain.exists():
                sys.exit(f"brain path resolved to {brain} but it doesn't exist")
            if not (brain / "brain.json").exists():
                sys.exit(f"{brain} has no brain.json — not a brain repo")
            return brain
    sys.exit("no `brain:` line found in CLAUDE.md (searched current dir and parents)")


def find_author(brain: Path) -> str:
    claude_md = brain / "CLAUDE.md"
    if claude_md.exists():
        for line in claude_md.read_text().splitlines():
            m = re.match(r"^\s*me:\s*(\S+)\s*$", line)
            if m:
                return m.group(1)
    try:
        name = subprocess.check_output(
            ["git", "config", "user.name"], text=True, stderr=subprocess.DEVNULL
        ).strip()
        return slugify(name) or "unknown"
    except subprocess.CalledProcessError:
        return "unknown"


def slugify(text: str) -> str:
    s = re.sub(r"[^a-z0-9-]+", "-", text.lower()).strip("-")
    return s or "untitled"


def now_filename_ts() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H%M%S")


def now_iso() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def stage(brain: Path, *paths: Path) -> None:
    rels = [str(p.relative_to(brain)) for p in paths]
    subprocess.check_call(["git", "-C", str(brain), "add", "--", *rels])


def build_entry(type_: str, gist: str, body: str, author: str, importance: str, keywords: list[str]) -> tuple[str, str]:
    kw = ", ".join(keywords)
    payload_for_hash = f"{type_}|{author}|{gist}|{body}".encode()
    full_hash = hashlib.sha256(payload_for_hash).hexdigest()
    frontmatter = (
        "---\n"
        f"id: {full_hash}\n"
        f"type: {type_}\n"
        f"author: {author}\n"
        f"created: {now_iso()}\n"
        f"importance: {importance}\n"
        f"keywords: [{kw}]\n"
        "---\n"
    )
    text = f"{frontmatter}\n# {gist}\n\n{body}\n"
    return text, full_hash


def cmd_write(args) -> None:
    brain = find_brain()
    author = find_author(brain)
    body = sys.stdin.read().strip()
    if not body:
        sys.exit("body is empty (read from stdin) — pass content via pipe")
    keywords = [k.strip() for k in args.keywords.split(",") if k.strip()]

    type_ = {"decisions": "decision", "context": "context", "todos": "todo"}[args.topic]
    target_dir = brain / args.topic / "open" if args.topic == "todos" else brain / args.topic
    if not target_dir.exists():
        sys.exit(f"topic dir missing: {target_dir.relative_to(brain)}")

    text, full_hash = build_entry(type_, args.gist, body, author, args.importance, keywords)
    short = full_hash[:8]

    existing = list(target_dir.glob(f"*-{author}-{short}.md"))
    if existing:
        print(f"already recorded: {existing[0].relative_to(brain)} (same content) — skipping")
        return

    fname = f"{now_filename_ts()}-{author}-{short}.md"
    path = target_dir / fname
    path.write_text(text)
    stage(brain, path)
    print(f"wrote {path.relative_to(brain)}")


def cmd_glossary(args) -> None:
    brain = find_brain()
    author = find_author(brain)
    body = sys.stdin.read().strip()
    if not body:
        sys.exit("definition is empty (read from stdin)")

    slug = slugify(args.term)
    path = brain / "glossary" / f"{slug}.md"

    if path.exists():
        existing = path.read_text()
        m = re.search(r"^created:\s*(\S+)\s*$", existing, re.MULTILINE)
        original_created = m.group(1) if m else now_iso()
    else:
        original_created = now_iso()

    full_hash = hashlib.sha256(f"glossary|{slug}|{body}".encode()).hexdigest()
    frontmatter = (
        "---\n"
        f"id: {full_hash}\n"
        "type: glossary\n"
        f"author: {author}\n"
        f"created: {original_created}\n"
        f"updated: {now_iso()}\n"
        "importance: high\n"
        f"keywords: [{slug}]\n"
        "---\n"
    )
    path.write_text(f"{frontmatter}\n# {args.term}\n\n{body}\n")
    stage(brain, path)
    print(f"wrote glossary/{slug}.md")


def cmd_done_todo(args) -> None:
    brain = find_brain()
    author = find_author(brain)
    open_dir = brain / "todos" / "open"
    done_dir = brain / "todos" / "done"
    done_dir.mkdir(parents=True, exist_ok=True)

    q = args.query.lower()
    matches = []
    for p in open_dir.glob("*.md"):
        haystack = (p.name + "\n" + p.read_text()).lower()
        if q in haystack:
            matches.append(p)

    if not matches:
        sys.exit(f"no open todo matches: {args.query!r}")
    if len(matches) > 1:
        listing = "\n  ".join(p.name for p in matches)
        sys.exit(f"multiple open todos match {args.query!r}:\n  {listing}\nbe more specific")

    src = matches[0]
    dst = done_dir / src.name
    text = src.read_text()
    closed_block = f"closed: {now_iso()}\nclosed_by: {author}\n"
    text = re.sub(r"(\n)(---\n)", lambda m: f"\n{closed_block}{m.group(2)}", text, count=1)
    dst.write_text(text)
    src.unlink()
    stage(brain, src, dst)
    print(f"closed {src.name} → todos/done/")


def cmd_sync(args) -> None:
    brain = find_brain()
    print(f"pulling {brain}...")
    subprocess.check_call(["git", "-C", str(brain), "pull", "--rebase", "--autostash"])
    if shutil.which("icm"):
        try:
            bj = json.loads((brain / "brain.json").read_text())
        except (FileNotFoundError, json.JSONDecodeError):
            bj = {}
        for topic in bj.get("topics", ["decisions", "glossary", "context", "todos"]):
            d = brain / topic
            if d.exists():
                subprocess.call(["icm", "import", str(d)])
        print("imported into icm")
    else:
        print("icm not installed — skipping import (Layer 2 optional)")


def main() -> None:
    p = argparse.ArgumentParser(prog="brain", description="Phase 1 brain helper")
    sub = p.add_subparsers(dest="cmd", required=True)

    pw = sub.add_parser("write", help="write a decision/context/todo (body from stdin)")
    pw.add_argument("topic", choices=["decisions", "context", "todos"])
    pw.add_argument("--gist", required=True)
    pw.add_argument("--importance", default="medium", choices=["critical", "high", "medium", "low"])
    pw.add_argument("--keywords", default="")
    pw.set_defaults(func=cmd_write)

    pg = sub.add_parser("glossary", help="write/update a glossary term (body from stdin)")
    pg.add_argument("term")
    pg.set_defaults(func=cmd_glossary)

    pd = sub.add_parser("done-todo", help="move an open todo to done")
    pd.add_argument("query", help="filename, id, or substring of gist/body")
    pd.set_defaults(func=cmd_done_todo)

    ps = sub.add_parser("sync", help="git pull the brain + (if icm present) import")
    ps.set_defaults(func=cmd_sync)

    args = p.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
