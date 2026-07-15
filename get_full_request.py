import json

log_file = r"C:\Users\USER\.gemini\antigravity\brain\44102624-4c0f-47cf-883c-2deaf7690b91\.system_generated\logs\transcript_full.jsonl"
with open(log_file, "r", encoding="utf-8") as f:
    for line in f:
        if "morning report form" in line:
            data = json.loads(line)
            if data.get("type") == "USER_INPUT":
                print(data["content"])
