import socket
import json
import time
import requests

# ThinkGear Connector settings
HOST = '127.0.0.1'
PORT = 13854
CONFIG = '{"enableRawOutput": true, "format": "Json"}\n'

# Blink Detection
BLINK_THRESHOLD = 50
blink_times = []

FLUTTER_IP = '192.168.1.147'  # <-- غيّر الـ IP حسب جهازك
FLUTTER_PORT = 5000

def send_blink_to_flutter():
    try:
        response = requests.post(f"http://{FLUTTER_IP}:{FLUTTER_PORT}/blink", json={"blink": "intentional"})
        print("✅ Sent double blink to Flutter.")
    except Exception as e:
        print(f"❌ Failed to send blink to Flutter: {e}")

try:
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.connect((HOST, PORT))
    sock.send(CONFIG.encode('utf-8'))
    print("✅ Connected to ThinkGear Connector.")

    while True:
        data = sock.recv(1024)
        if not data:
            continue
        decoded = data.decode("utf-8", errors="ignore")
        for line in decoded.splitlines():
            line = line.strip()
            if line.startswith("{"):
                try:
                    json_data = json.loads(line)
                    if "blinkStrength" in json_data:
                        strength = json_data["blinkStrength"]
                        now = time.time()
                        if strength >= BLINK_THRESHOLD:
                            blink_times.append(now)
                            print(f"🟢 Blink: {strength} | Time: {now}")

                            blink_times = [t for t in blink_times if now - t < 2]

                            if len(blink_times) >= 2:
                                print("👁️‍🗨️ Double blink detected intentionally!")
                                send_blink_to_flutter()
                                blink_times = []
                except:
                    continue
except (ConnectionResetError, OSError, KeyboardInterrupt):
    sock.close()
    print("\n🛑 Connection lost or headset disconnected.")
