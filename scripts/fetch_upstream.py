#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""探测 FxSound 上游最新版本，输出 GitHub Actions 需要的 outputs。

用法: python scripts/fetch_upstream.py --channel stable|beta
输出(写入 GITHUB_OUTPUT, 若无该文件则打印):
  tag= v1.2.17.0 / beta
  version= 1.2.17.0
  asset_id= <release asset id>
  asset_url= <browser_download_url>
  sha256= <asset digest 若上游提供>
"""
import argparse, json, os, re, subprocess, sys

def gh_json(path):
    p = subprocess.run(["gh", "api", path], capture_output=True)
    if p.returncode != 0:
        sys.stderr.write(p.stderr.decode("utf-8", "replace"))
        raise SystemExit("gh api failed: " + path)
    return json.loads(p.stdout.decode("utf-8"))

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--channel", default="stable", choices=["stable", "beta"])
    ap.add_argument("--repo", default="fxsound2/fxsound-app")
    a = ap.parse_args()

    rels = gh_json("repos/%s/releases?per_page=30" % a.repo)
    stable_re = re.compile(r"^v\d+\.\d+\.\d+\.\d+$")

    chosen = None
    if a.channel == "beta":
        chosen = next((r for r in rels if r["tag_name"] == "beta"), None)
    if chosen is None:
        # 按发布时间排序取最新正式 tag（tag 形如 v1.2.17.0，跳过 latest 浮动 tag）
        cands = [r for r in rels if stable_re.match(r["tag_name"]) and not r.get("prerelease")]
        cands.sort(key=lambda r: r["published_at"], reverse=True)
        if not cands:
            raise SystemExit("未找到正式版本 release")
        chosen = cands[0]

    tag = chosen["tag_name"]
    asset = next((x for x in chosen["assets"] if x["name"] == "fxsound_setup.exe"), None)
    if asset is None:
        raise SystemExit("release %s 未找到 fxsound_setup.exe" % tag)

    if a.channel == "beta":
        # beta 是浮动 tag，用发布日期生成可比较的版本标识
        version = "beta-%s" % chosen["published_at"][:10].replace("-", "")
    else:
        version = tag.lstrip("v")

    kv = {
        "tag": tag,
        "version": version,
        "asset_id": str(asset["id"]),
        "asset_url": asset["browser_download_url"],
        "size": str(asset["size"]),
        "published_at": chosen["published_at"],
        "digest": str(asset.get("digest") or ""),
    }
    out_path = os.environ.get("GITHUB_OUTPUT")
    if out_path:
        with open(out_path, "a", encoding="utf-8") as f:
            for k, v in kv.items():
                f.write("%s=%s\n" % (k, v))
    for k, v in kv.items():
        print("%s=%s" % (k, v))

if __name__ == "__main__":
    main()
