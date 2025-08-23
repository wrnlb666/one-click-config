#!/usr/bin/env python3


import sys
from util import Module
import config
from typing import Set, List


def main():
    argc, argv = len(sys.argv), sys.argv
    all: bool = True if argc == 1 else False
    candidates: Set[str] = set()
    modules: List[Module] = [
        obj
        for name, obj in vars(config).items()
        if isinstance(obj, Module) and not name.startswith("_")
    ]
    for arg in argv:
        if arg in {"-h", "--help"}:
            return
        elif arg in {"--ls", "--list"}:
            print("\n".join(map(str, modules)))
            return
        elif arg in {"-a", "--all"}:
            all = True
            break
        else:
            candidates.add(arg)
    if not all:
        modules = [m for m in modules if m in candidates]
    for m in modules:
        print(m.name)
        m.run()


if __name__ == "__main__":
    main()
