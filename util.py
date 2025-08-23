import sys
import subprocess
from pathlib import Path
from typing import Self, List, Optional, Final, Union, Callable


def git_clone(url: str, cwd: Path, name: str = "") -> None:
    params: List[str] = ["git", "clone", url]
    print(f"[INFO] Cloning '{url}'...")
    if name:
        params.append(name)
    try:
        subprocess.run(args=params, capture_output=True, text=True, check=True, cwd=cwd)
    except subprocess.CalledProcessError as e:
        print(f"[ERRO] Faled to clone '{url}': {e.stderr}", file=sys.stderr)
        sys.exit(1)


class Link:
    origin: Path
    target: Path

    def __init__(self, orgin: Union[str, Path], target: Union[str, Path]) -> None:
        self.origin = Path(orgin).resolve(False)
        self.target = Path(target).resolve(False)

    def link(self) -> None:
        origin = self.origin
        target = self.target
        if not origin.exists():
            print(f"[ERRO] {origin} does not exist", file=sys.stderr)
            sys.exit(1)
        target.symlink_to(origin, origin.is_dir())


class Module:
    name: str
    url: str
    cwd: Path
    links: List[Link]
    install_name: str
    func: Optional[Callable[[], None]]

    def __init__(
        self,
        name: str,
        url: str,
        cwd: Union[str, Path] = ".",
        install_name: str = "",
        func: Optional[Callable[[], None]] = None,
        links: Optional[List[Link]] = None,
    ) -> None:
        self.name = name
        self.url = url
        self.cwd = Path(cwd).resolve(True)
        self.install_name = install_name if install_name else name
        self.func = func
        self.links = links if links else list()

    def __str__(self) -> str:
        return f"[INFO] {self.name}: git clone {self.url} {self.install_name}"

    def get_name(self) -> str:
        return self.name

    def _link(self) -> None:
        for link in self.links:
            link.link()

    def link(self, origin: Union[str, Path], target: Union[str, Path]) -> Self:
        tmp = Link(origin, target)
        self.links.append(tmp)
        return self

    def run(self) -> None:
        git_clone(self.url, self.cwd, self.install_name)
        self._link()
        if self.func:
            self.func()


HOME: Final[Path] = Path.home()
CONFIG: Final[Path] = HOME / ".config"
