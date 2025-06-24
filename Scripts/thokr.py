import csv
from datetime import datetime

log_file = "/home/denis/.config/thokr/log.csv"  # Replace with your actual file path

entries = []

with open(log_file, newline='') as f:
    reader = csv.DictReader(f)
    for row in reader:
        try:
            entry = {
                "date": datetime.strptime(row["date"], "%a %b %d %H:%M:%S %Y"),
                "num_words": int(row["num_words"]),
                "elapsed_secs": float(row["elapsed_secs"]) if row["elapsed_secs"] else None,
                "wpm": int(row["wpm"]),
                "accuracy": int(row["accuracy"]),
                "std_dev": float(row["std_dev"]),
            }
            entries.append(entry)
        except Exception as e:
            print(f"Skipping row due to error: {e}")

# Best results
best_wpm = max(entries, key=lambda x: x["wpm"])
best_accuracy = max(entries, key=lambda x: x["accuracy"])
fastest_time = min((e for e in entries if e["elapsed_secs"]), key=lambda x: x["elapsed_secs"])
best_perfect_run = max((e for e in entries if e["accuracy"] == 100), key=lambda x: x["wpm"], default=None)

print("\n📊 Best Results from thokr log:\n")

print(f"🚀 Highest WPM: {best_wpm['wpm']} at {best_wpm['date']}")
print(f"🎯 Highest Accuracy: {best_accuracy['accuracy']}% at {best_accuracy['date']}")
print(f"⏱️ Fastest Time: {fastest_time['elapsed_secs']:.2f} seconds at {fastest_time['date']}")

if best_perfect_run:
    print(f"🏆 Best 100% Accuracy Run: {best_perfect_run['wpm']} WPM at {best_perfect_run['date']}")
else:
    print("❌ No 100% accuracy run found.")


