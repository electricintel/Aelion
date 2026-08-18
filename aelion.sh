#!/data/data/com.termux/files/usr/bin/bash

set -e

pkg update -y
pkg install -y python git

mkdir -p aelion/ui
cd aelion

# -------------------------
# Backend (Flask API)
# -------------------------
cat > aelion_backend.py << 'EOF'
from flask import Flask, jsonify, request
import json, os

app = Flask(__name__)
DATA_FILE = "aelion_data.json"

if not os.path.exists(DATA_FILE):
    with open(DATA_FILE, "w") as f:
        json.dump({"cases": [], "home": [], "recall": [], "mining": []}, f)

def load():
    with open(DATA_FILE, "r") as f:
        return json.load(f)

def save(data):
    with open(DATA_FILE, "w") as f:
        json.dump(data, f, indent=2)

@app.route("/api/justice", methods=["POST"])
def justice():
    data = load()
    entry = request.json
    data["cases"].append(entry)
    save(data)
    return jsonify({"status": "ok", "stored": entry})

@app.route("/api/home", methods=["POST"])
def home():
    data = load()
    entry = request.json
    data["home"].append(entry)
    save(data)
    return jsonify({"status": "ok", "stored": entry})

@app.route("/api/recall", methods=["POST"])
def recall():
    data = load()
    entry = request.json
    data["recall"].append(entry)
    save(data)
    return jsonify({"status": "ok", "stored": entry})

@app.route("/api/mining", methods=["POST"])
def mining():
    data = load()
    entry = request.json
    data["mining"].append(entry)
    save(data)
    return jsonify({"status": "ok", "stored": entry})

@app.route("/api/all", methods=["GET"])
def all_data():
    return jsonify(load())

app.run(host="0.0.0.0", port=6601)
EOF

# -------------------------
# UI index
# -------------------------
cat > ui/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>AELION Final — Android Edition</title>
  <style>
    body { font-family: system-ui, sans-serif; background:#f0f0f0; padding:1.5rem; }
    .panel { background:#fff; padding:1.5rem; border-radius:8px; max-width:800px; margin:auto; }
    button { padding:0.6rem 1rem; margin:0.3rem; }
  </style>
</head>
<body>
<div class="panel">
  <h1>AELION Final — Android Edition</h1>
  <p>Justice • Home • Recall • Mining • Manual</p>
  <button onclick="openModule('justice')">Justice Engine</button>
  <button onclick="openModule('home')">Home Engine</button>
  <button onclick="openModule('recall')">Recall Engine</button>
  <button onclick="openModule('mining')">Mining Engine</button>
  <button onclick="openModule('manual')">Manual Overlay</button>
</div>
<script>
function openModule(m) { window.location = m + ".html"; }
</script>
</body>
</html>
EOF

# -------------------------
# Module pages
# -------------------------
for m in justice home recall mining manual; do
cat > ui/${m}.html << EOF
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>AELION — ${m}</title>
<style>
body { font-family: system-ui; background:#f0f0f0; padding:1.5rem; }
.panel { background:#fff; padding:1.5rem; border-radius:8px; max-width:800px; margin:auto; }
textarea { width:100%; height:150px; }
button { padding:0.6rem 1rem; margin-top:1rem; }
</style>
</head>
<body>
<div class="panel">
<h1>${m} Engine</h1>
<textarea id="input"></textarea>
<button onclick="send()">Submit</button>
</div>
<script>
function send() {
  fetch("/api/${m if m != "manual" else "justice"}", {
    method:"POST",
    headers:{ "Content-Type":"application/json" },
    body:JSON.stringify({ entry: document.getElementById("input").value })
  }).then(r=>r.json()).then(j=>alert("Stored"));
}
</script>
</body>
</html>
EOF
done

echo "AELION Full Termux Edition installed."
echo "Run backend with: python aelion_backend.py"
echo "Then open: http://127.0.0.1:6601/ui/index.html in your browser."
