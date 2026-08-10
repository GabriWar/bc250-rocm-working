#!/usr/bin/env python3
"""Measures seconds per image in ComfyUI, with a fixed seed.

Fixed seed on purpose: without it, each run generates a different image and the
time varies with the content. With it, runs are comparable and it doubles as a
correctness test -- the same seed must produce the same image, so any output
difference between runs is corruption, not randomness.

Usage: mede-comfy.py <api.json-file> <label> <n>
"""
import hashlib
import json
import sys
import time
import urllib.request

URL = "http://100.64.0.15:8188"


def post(caminho, dados):
    req = urllib.request.Request(
        f"{URL}{caminho}", data=json.dumps(dados).encode(),
        headers={"Content-Type": "application/json"})
    with urllib.request.urlopen(req, timeout=60) as r:
        return json.load(r)


def get(caminho):
    with urllib.request.urlopen(f"{URL}{caminho}", timeout=60) as r:
        return json.load(r)


def main():
    api = json.load(open(sys.argv[1]))
    rotulo = sys.argv[2]
    n = int(sys.argv[3]) if len(sys.argv) > 3 else 3
    prompt = api["prompt"]

    for i in range(n):
        t0 = time.perf_counter()
        r = post("/prompt", {"prompt": prompt})
        pid = r["prompt_id"]

        img = None
        while True:
            h = get(f"/history/{pid}")
            if pid in h:
                saidas = h[pid].get("outputs", {})
                for v in saidas.values():
                    for im in v.get("images", []):
                        img = im
                        break
                break
            if time.perf_counter() - t0 > 1800:
                print(json.dumps({"rotulo": rotulo, "rodada": i + 1,
                                  "erro": "timeout 1800s"}), flush=True)
                return
            time.sleep(2)
        dt = time.perf_counter() - t0

        # image hash: the same seed must give the same file
        sha = None
        if img:
            try:
                q = (f"/view?filename={img['filename']}"
                     f"&subfolder={img.get('subfolder','')}&type={img['type']}")
                with urllib.request.urlopen(f"{URL}{q}", timeout=120) as f:
                    sha = hashlib.sha256(f.read()).hexdigest()[:16]
            except Exception as e:
                sha = f"erro:{type(e).__name__}"

        print(json.dumps({"rotulo": rotulo, "rodada": i + 1,
                          "segundos": round(dt, 1),
                          "arquivo": img["filename"] if img else None,
                          "sha256_16": sha}), flush=True)


if __name__ == "__main__":
    main()
