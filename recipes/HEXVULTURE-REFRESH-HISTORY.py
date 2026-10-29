#!/usr/bin/env python3
from pathlib import Path
from datetime import datetime
import json, re, sys, os, tempfile

os.umask(0o077)

if len(sys.argv) != 2:
    sys.exit("[STOP] Expected a saved TXT file")

saved = Path(sys.argv[1]).expanduser().resolve()
root = saved.parent

if not saved.is_file():
    sys.exit("[STOP] Saved file missing")

files = []
for folder in sorted(root.glob("snapshot-*")):
    if folder.is_dir() and not folder.is_symlink():
        for name in ("posts.txt", "followers.txt", "following.txt"):
            files.append(folder / name)

for p in root.glob("*.txt"):
    if re.match(
        r"^(posts50|posts75|posts100|followers|following|"
        r"usernames-auto|bamboo-).*\.txt$", p.name, re.I
    ):
        files.append(p)

items = []
for p in sorted(set(files)):
    if not p.is_file() or p.is_symlink():
        continue
    raw = p.read_text(encoding="utf-8", errors="replace")
    items.append({
        "name": str(p.relative_to(root)),
        "date": datetime.fromtimestamp(
            p.stat().st_mtime
        ).strftime("%Y-%m-%d %H:%M:%S"),
        "text": raw,
        "posts": len(re.findall(r"^ID=\d+ \| DATE=", raw, re.M))
    })

items.sort(key=lambda x: (x["date"], x["name"]), reverse=True)

if not items:
    sys.exit("[STOP] No saved results")

payload = json.dumps(items, ensure_ascii=False)
payload = payload.replace("<", "\\u003c")
payload = payload.replace("\u2028", "\\u2028")
payload = payload.replace("\u2029", "\\u2029")

page = """<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Bamboo Saved History</title>
<style>
:root{color-scheme:dark}
*{box-sizing:border-box}
body{margin:0;padding:22px;background:#08080e;color:#f2edf7;
font:15px system-ui,sans-serif}
main{max-width:1200px;margin:auto}
h1{color:#ff1493}h2{color:#00f5ff}
p{color:#bcb6c8}
input{width:100%;background:#151321;color:white;
border:1px solid #00f5ff;border-radius:9px;
padding:14px;margin:14px 0}
button{background:#ff1493;color:white;border:0;
padding:12px;border-radius:8px;cursor:pointer}
.layout{display:grid;grid-template-columns:300px 1fr;gap:16px}
aside,article{background:#191421;border:1px solid #503151;
border-radius:12px;padding:17px}
aside{max-height:75vh;overflow:auto}
.file{display:block;width:100%;margin:8px 0;
background:#291b32;text-align:left;overflow-wrap:anywhere}
.file.active{background:#14515a}
pre{white-space:pre-wrap;overflow-wrap:anywhere;
font:13px/1.7 ui-monospace,monospace}
#status{color:#b6ff00}
@media(max-width:750px){
.layout{grid-template-columns:1fr}
aside{max-height:260px}
}
@media print{
:root{color-scheme:light}
body,article{background:white;color:black}
aside,input,.toolbar{display:none}
.layout{display:block}
pre{color:black}
}
</style>
</head>
<body><main>
<h1>🐵 BAMBOO // SAVED RESULTS HISTORY</h1>
<p>Private offline archive · Full collected output · No X app required</p>
<p id="status"></p>
<input id="search" placeholder="Search saved posts, dates, usernames">
<div class="toolbar">
<button id="privacy">Privacy mode: OFF</button>
<button onclick="window.print()">Print / Save PDF</button>
</div>
<div class="layout">
<aside><h2>Saved Collections</h2><div id="files"></div></aside>
<article>
<h2 id="title"></h2>
<p id="meta"></p>
<pre id="content"></pre>
</article>
</div>
<p>Saved evidence may contain unverified claims or sensitive
technical information. Use privacy mode before sharing.</p>
</main>
<script>
const records=__DATA__;
let selected=0;
let privacy=false;

const search=document.getElementById("search");
const files=document.getElementById("files");
const content=document.getElementById("content");

function safe(t){
 if(!privacy)return t;
 return t
 .replace(/^.*(?:Mozilla\\/5\\.0| \\| GET \\| ).*$/gm,
          "[Access-log line hidden]")
 .replace(/\\b(?:\\d{1,3}\\.){3}\\d{1,3}\\b/g,
          "[IP REDACTED]");
}

function draw(){
 const q=search.value.toLowerCase().trim();
 const matched=records.map((r,i)=>({...r,i}))
  .filter(r=>!q||(r.name+" "+r.text).toLowerCase().includes(q));

 if(matched.length&&!matched.some(r=>r.i===selected))
   selected=matched[0].i;

 files.replaceChildren();
 for(const r of matched){
   const b=document.createElement("button");
   b.className="file"+(r.i===selected?" active":"");
   b.textContent=r.name+" · "+r.date;
   b.onclick=()=>{selected=r.i;draw()};
   files.appendChild(b);
 }

 const current=records[selected];
 document.getElementById("title").textContent=
  matched.length?current.name:"No matching files";
 document.getElementById("meta").textContent=
  matched.length?current.date+" · "+current.posts+" posts":"";
 content.textContent=matched.length?safe(current.text):"";
 document.getElementById("status").textContent=
  records.length+" saved files · "+matched.length+
  " matches · "+(privacy?"PRIVACY VIEW":"FULL TEXT");
}

document.getElementById("privacy").onclick=()=>{
 privacy=!privacy;
 document.getElementById("privacy").textContent=
  "Privacy mode: "+(privacy?"ON":"OFF");
 draw();
};
search.oninput=draw;
draw();
</script></body></html>"""

page = page.replace("__DATA__", payload)
target = root / "BAMBOO-SAVED-HISTORY.html"

fd, temp = tempfile.mkstemp(
    prefix=".bamboo-history-", suffix=".html", dir=root
)
try:
    with os.fdopen(fd, "w", encoding="utf-8") as f:
        f.write(page)
    os.chmod(temp, 0o600)
    os.replace(temp, target)
finally:
    if os.path.exists(temp):
        os.unlink(temp)

print("[PASS] Saved history refreshed:", len(items), "files")
print("[PRIVATE] Original evidence unchanged")
