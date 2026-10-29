import json, sys
data = json.load(sys.stdin)["devices"]
cands = [d for runtime, devs in data.items() if "iOS" in runtime for d in devs
         if d.get("isAvailable") and d["name"].startswith("iPhone")]
cands.sort(key=lambda d: (d["name"] != "iPhone 17", d["name"]))
print(f'{cands[0]["udid"]}|{cands[0]["name"]}')
