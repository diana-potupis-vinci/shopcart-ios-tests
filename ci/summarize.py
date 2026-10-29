"""Формує зведення результатів тестів (Markdown) із файлів .xcresult."""
import json, os, subprocess

def run(cmd):
    r = subprocess.run(cmd, capture_output=True, text=True)
    if r.returncode != 0:
        raise RuntimeError(r.stderr.strip()[:600])
    return json.loads(r.stdout)

def cases(node, out):
    if isinstance(node, dict):
        if node.get("nodeType") == "Test Case":
            out.append(node)
        for v in node.values():
            cases(v, out)
    elif isinstance(node, list):
        for v in node:
            cases(v, out)

def section(title, path, with_coverage):
    md = [f"## {title}", ""]
    if not os.path.exists(path):
        return md + ["Файл результатів не створено (крок не виконувався або збірка впала).", ""]
    try:
        s = run(["xcrun", "xcresulttool", "get", "test-results", "summary", "--path", path])
        dur = (s.get("finishTime") or 0) - (s.get("startTime") or 0)
        md += ["| Показник | Значення |", "|---|---|",
               f"| Усього тестів | {s.get('totalTestCount')} |",
               f"| Успішно | {s.get('passedTests')} |",
               f"| Збоїв | {s.get('failedTests')} |",
               f"| Пропущено | {s.get('skippedTests')} |",
               f"| Загальний час, с | {dur:.1f} |", ""]
    except Exception as e:
        md += [f"Не вдалося прочитати підсумок: {e}", ""]
    try:
        t = run(["xcrun", "xcresulttool", "get", "test-results", "tests", "--path", path])
        found = []
        cases(t, found)
        md += ["| Тест | Результат | Час |", "|---|---|---|"]
        for c in found:
            md.append(f"| {c.get('name')} | {c.get('result')} | {c.get('duration', '')} |")
        md.append("")
    except Exception as e:
        md += [f"Не вдалося прочитати список тестів: {e}", ""]
    if with_coverage:
        try:
            cov = run(["xcrun", "xccov", "view", "--report", "--json", path])
            md += ["### Покриття коду", "", "| Файл | Покрито рядків, % | Рядків (покрито / усього) |", "|---|---|---|"]
            for tg in cov.get("targets", []):
                if tg["name"].endswith(".app"):
                    for f in sorted(tg.get("files", []), key=lambda x: x["name"]):
                        md.append(f"| {f['name']} | {f['lineCoverage']*100:.1f} | {f['coveredLines']} / {f['executableLines']} |")
                    md.append(f"| **Разом (target ShopCart)** | **{tg['lineCoverage']*100:.1f}** | {tg['coveredLines']} / {tg['executableLines']} |")
            md.append("")
        except Exception as e:
            md += [f"Не вдалося прочитати покриття: {e}", ""]
    return md

sim = os.environ.get("SIM_NAME", "?")
lines = ["# Результати тестування ShopCart", "", f"Симулятор: **{sim}**", ""]
lines += section("Модульні тести (ShopCartTests)", "results/unit.xcresult", True)
lines += section("UI-тести (ShopCartUITests)", "results/ui.xcresult", False)
text = "\n".join(lines)
os.makedirs("results", exist_ok=True)
open("results/summary.md", "w", encoding="utf-8").write(text)
out = os.environ.get("GITHUB_STEP_SUMMARY")
if out:
    open(out, "a", encoding="utf-8").write(text)
print(text)
