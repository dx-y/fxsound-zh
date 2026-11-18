#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""把官方 FxSound 解包目录里的预设文件（Factsoft/*.fac）第 3 行名称替换为中文。

用法:
  python scripts/patch_presets.py --app-root <解包出的 FxSound 程序目录> \
      [--map presets/preset-map.json] [--dry-run]

特性: 幂等（已中文则跳过）、不依赖上游英文名文本（按文件名+行号定位）、
      保留原文件换行风格（CRLF/LF）与其余字节不变。
"""
import argparse, json, os, sys

# Windows CI 的默认 stdout 编码可能是 cp1252，打印中文会 UnicodeEncodeError，统一改 UTF-8
for _s in (sys.stdout, sys.stderr):
    try:
        _s.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass

def read_bytes(p):
    with open(p, "rb") as f:
        return f.read()

def split_lines(raw: bytes):
    crlf = b"\r\n" in raw
    text = raw.decode("utf-8", "surrogateescape")
    parts = text.split("\r\n") if crlf else text.split("\n")
    return parts, crlf

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--app-root", required=True, help="包含 Factsoft 子目录的 FxSound 程序根目录")
    ap.add_argument("--map", default=os.path.join("presets", "preset-map.json"))
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()

    with open(args.map, "r", encoding="utf-8") as f:
        cfg = json.load(f)
    idx = int(cfg.get("line_index", 2))
    presets = cfg["presets"]

    fac_dirs = [d for d in (os.path.join(args.app_root, "Factsoft"),
                            os.path.join(args.app_root, "Resources", "Factsoft"))
                if os.path.isdir(d)]
    if not fac_dirs:
        print("ERROR: 未找到 Factsoft 目录于 %s" % args.app_root)
        return 2

    changed, skipped, missing = 0, 0, 0
    for fac_dir in fac_dirs:
        for name, item in presets.items():
            p = os.path.join(fac_dir, name)
            if not os.path.isfile(p):
                missing += 1
                continue
            raw = read_bytes(p)
            lines, crlf = split_lines(raw)
            if len(lines) <= idx:
                print("WARN: %s 行数不足，跳过" % p)
                continue
            old = lines[idx]
            new = item["zh"]
            if old == new:
                skipped += 1
                continue
            lines[idx] = new
            out = ("\r\n" if crlf else "\n").join(lines)
            if not args.dry_run:
                with open(p, "wb") as f:
                    f.write(out.encode("utf-8", "surrogateescape"))
            print("PATCH %-45s %r -> %r" % (os.path.basename(fac_dir) + "/" + name, old, new))
            changed += 1

    print("汇总: 改动=%d 已是中文=%d 缺失=%d" % (changed, skipped, missing))
    if missing:
        print("提示: 有 %d 个映射预设在上游不存在（可能上游移除/改名），不影响其余预设。" % missing)
    return 0

if __name__ == "__main__":
    sys.exit(main())
