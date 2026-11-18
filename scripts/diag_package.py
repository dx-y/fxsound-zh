"""诊断官方安装包结构：判断是哪种安装器、内嵌 MSI/CAB 的偏移位置。

用途：官方 fxsound_setup.exe 由 Advanced Installer 打包，7z 无法直接展开，
需要先判断内嵌的 MSI(OLE 复合文档) 位置，再用 msiexec /a 做管理员展开。
"""
import sys

SIGS = {
    "OLE/MSI (D0CF11E0)": b"\xd0\xcf\x11\xe0\xa1\xb1\x1a\xe1",
    "CAB (MSCF)": b"MSCF",
    "ZIP (PK)": b"PK\x03\x04",
    "7Z (7z)": b"7z\xbc\xaf\x27\x1c",
}

KEYWORDS = [
    b"Advanced Installer",
    b"Nullsoft",
    b"Inno Setup",
    b"WiX",
    b"InstallShield",
    b".msi",
    b"MSI",
    b"dfxui_zh-CN",
    b"FxSound",
]


def main(path):
    data = open(path, "rb").read()
    print(f"file={path} size={len(data)} bytes ({len(data)/1024/1024:.2f} MB)")
    print("head=", data[:2], "MZ" if data[:2] == b"MZ" else "NOT_PE")
    for name, sig in SIGS.items():
        offs, i = [], data.find(sig)
        while i != -1 and len(offs) < 12:
            offs.append(hex(i))
            i = data.find(sig, i + 1)
        print(f"{name:22s} count>= {len(offs):2d} offsets={offs}")
    for kw in KEYWORDS:
        print(f"  kw {kw!r:30s} first_at={data.find(kw)}")
    # PE 资源里若有 MSI 名称串，通常出现在 near end
    tail = data[-4096:]
    print("tail_has_msi_string=", b"msi" in tail.lower())


if __name__ == "__main__":
    main(sys.argv[1])
