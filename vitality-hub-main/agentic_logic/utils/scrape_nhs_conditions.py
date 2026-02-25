import json
import re
import time
import os
import pytz
import requests
from requests.adapters import HTTPAdapter
from datetime import datetime
from bs4 import BeautifulSoup, Tag
from urllib3.util.retry import Retry
from collections import defaultdict


HEAD_RE = re.compile(r"^h([1-6])$", re.I)

BASE = "https://www.nhs.uk"
IN_JSONL_PATH = os.path.join(os.path.dirname(__file__), "conditions", "nhs_conditions.jsonl")
OUT_JSONL_PATH = os.path.join(os.path.dirname(__file__), "conditions", "nhs_conditions_pages.jsonl")

# Be polite :)
SLEEP_SECONDS = 0.5
TIMEOUT = 30
TIMEOUT_TUPLE = (10, 30)

def cleaning_logic(raw_name: str) -> tuple:
    SEE_ALSO_REGEX = r", see .+$"
    return re.sub(SEE_ALSO_REGEX, "", raw_name).strip(), bool(re.search(SEE_ALSO_REGEX, raw_name))

def scrape_nhs_conditions():
    grouped_data = defaultdict(list)

    session = requests.Session()
    retry_strategy = Retry(
        total=5,  # Increased retries
        backoff_factor=2, # Wait longer between tries
        status_forcelist=[429, 500, 502, 503, 504],
    )
    adapter = HTTPAdapter(max_retries=retry_strategy)
    session.mount("https://", adapter)
    
    session.headers.update({
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
        'Accept-Language': 'en-GB,en;q=0.5',
    })
    
    # Connect to Conditions A to Z
    try:
        response = session.get(f"{BASE}/conditions/", timeout=TIMEOUT_TUPLE)
        response.raise_for_status()
    except Exception as e:
        print(f"Failed to connect: {e}")
        return

    soup = BeautifulSoup(response.content, "html.parser")
    main_content = soup.find('main') or soup.find('div', id='maincontent')
    
    if not main_content:
        print("Could not find the main content area.")
        return

    links = main_content.find_all('a', href=True)
    
    # Processing and cleaning data 
    for link in links:
        href = link['href']
        # Filter for actual condition pages
        if href.startswith('/conditions/') and len(href.split('/')) > 2 and '#' not in href:
            raw_name = link.get_text(strip=True)
            
            if "Back to" in raw_name or not raw_name:
                continue
            
            full_url = BASE + href if href.startswith('/') else href

            clean_name, is_cross_ref = cleaning_logic(raw_name)
            if clean_name not in [item[0] for item in grouped_data[full_url]]:
                grouped_data[full_url].append((clean_name, is_cross_ref))

    # Sort: Primary names (is_cross_ref=False) first, then alphabetical & Save
    with open(IN_JSONL_PATH, "w", encoding="utf-8") as out:
        for url, items in grouped_data.items():
            items.sort(key=lambda x: (x[1], x[0]))
            entry = {
                "condition": [item[0] for item in items],
                "url": url
            }
            out.write(json.dumps(entry) + "\n")

    print(f"Success! {IN_JSONL_PATH} file is clean and grouped.")

def clean_text(s: str) -> str:
    return re.sub(r"\s+", " ", s).strip()

def is_heading(tag: Tag) -> bool:
    return bool(tag.name and HEAD_RE.match(tag.name))

def heading_level(tag: Tag) -> int:
    m = HEAD_RE.match(tag.name or "")
    return int(m.group(1)) if m else 99

def get_content_root(soup: BeautifulSoup) -> Tag:
    return soup.select_one("#maincontent") or soup.select_one("main") or soup.body

def html_to_sections(html: str):
    soup = BeautifulSoup(html, "html.parser")
    root = get_content_root(soup)

    # Remove obvious non-content inside root
    for sel in ["header", "footer", "nav", "script", "style"]:
        for t in root.select(sel):
            t.decompose()

    sections = []
    current = {"title": None, "level": 0, "parts": []}

    def flush():
        title = current["title"] or "Intro"
        text = "\n".join([p for p in current["parts"] if p.strip()])
        text = clean_text(text)
        if text:
            sections.append({
                "title": clean_text(title),
                "level": current["level"],
                "text": text
            })

    for el in root.find_all(["h1","h2","h3","h4","h5","h6","p","li"], recursive=True):
        if not isinstance(el, Tag):
            continue

        if is_heading(el):
            flush()
            current = {
                "title": el.get_text(" ", strip=True),
                "level": heading_level(el),
                "parts": []
            }
            continue

        txt = clean_text(el.get_text(" ", strip=True))
        if not txt:
            continue

        # Drop page-review boilerplate (optional)
        if "Page last reviewed:" in txt or "Next review due:" in txt:
            continue

        current["parts"].append(txt)

    flush()
    return sections

def iter_jsonl(path: str):
    with open(path, "r", encoding="utf-8") as f:
        for line_no, line in enumerate(f, start=1):
            line = line.strip()
            if not line:
                continue
            try:
                yield line_no, json.loads(line)
            except json.JSONDecodeError:
                # Skip malformed lines rather than failing whole run
                continue

def fetch(url: str) -> str:
    headers = {
        "User-Agent": "Mozilla/5.0 (compatible; nhs-condition-scraper/1.0; +local-script)"
    }
    r = requests.get(url, headers=headers, timeout=TIMEOUT)
    r.raise_for_status()
    return r.text

def main():
    # Check if input file exists
    if not os.path.exists(IN_JSONL_PATH):
        print(f"Input file not found: {IN_JSONL_PATH}.\n Generating now...")
        scrape_nhs_conditions()
        time.sleep(SLEEP_SECONDS)

    with open(OUT_JSONL_PATH, "w", encoding="utf-8") as out:
        for line_no, rec in iter_jsonl(IN_JSONL_PATH):
            url = rec.get("url")
            name = rec.get("condition")

            # Safety checks
            if not isinstance(url, str) or (not url) or ("/conditions/" not in url):
                continue

            result = {
                "source_line": line_no,
                "condition_names": name,
                "url": url,
                "fetched_at": datetime.now(pytz.timezone("Europe/London")).isoformat(timespec="seconds"),
                "status": "ok",
                "http_status": None,
                "sections": None,
                "error": None,
            }

            try:
                html = fetch(url)
                sections = html_to_sections(html)
                result["sections"] = sections
            except requests.HTTPError as e:
                result["status"] = "http_error"
                result["http_status"] = getattr(e.response, "status_code", None)
                result["error"] = str(e)
            except Exception as e:
                result["status"] = "error"
                result["error"] = repr(e)

            out.write(json.dumps(result, ensure_ascii=False) + "\n")
            out.flush()

            time.sleep(SLEEP_SECONDS)

    print(f"Success! {OUT_JSONL_PATH} file is populated.")

    # TODO: rather than save a jsonl, go through each in order and generate a summary of the symptoms + causes then save that to IRIS for VS

if __name__ == "__main__":
    main()