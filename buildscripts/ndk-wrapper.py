#!/usr/bin/env python3
import os
import sys
from pathlib import Path

DEFAULT_APPEND_FLAGS = [
    "-Wno-error", "-Wno-unused-command-line-argument",
    "-O3", "-fno-stack-protector", "-fno-plt",
    "-ffast-math", "-lm",
    "-flto=full", "-fwhole-program-vtables", "-fvirtual-function-elimination", "-Wl,--lto-O3,--lto-partitions=1",
    "-ffunction-sections", "-fdata-sections", "-Wl,--gc-sections",
    "-fPIC",
    "-g0", "-s",
    "-fuse-ld=lld", "-Wl,-O2,--icf=all,--as-needed,--sort-common,--pack-dyn-relocs=relr,-mllvm,-enable-ext-tsp-block-placement=1",
]


def split_env_flags(key):
    value = os.getenv(key, "").strip()
    return value.split() if value else []


class CompilerWrapper:
    def __init__(self, argv):
        self.argv0 = argv[0]
        self.args = argv[1:]

        wrapper_name = Path(self.argv0).name.rsplit(sep="-", maxsplit=1)
        self.target = wrapper_name[0]
        self.real_compiler = Path(__file__).resolve().parent / wrapper_name[1]

    def should_skip_customization(self):
        return len(self.args) == 0 or "-cc1" in self.args or "-cc1as" in self.args

    def build_prepend_flags(self):
        return [f"--target={self.target}", *split_env_flags("NDK_WRAPPER_PREPEND")]

    def build_append_flags(self):
        append_flags = []
        if not os.getenv("NDK_WRAPPER_DISABLED"):
            self.args = [arg for arg in self.args if not arg.startswith("-march=")]
            append_flags.extend(DEFAULT_APPEND_FLAGS)
        append_flags.extend(split_env_flags("NDK_WRAPPER_APPEND"))
        return append_flags

    def parse_custom_flags(self):
        if self.should_skip_customization():
            return
        self.args = self.build_prepend_flags() + self.args + self.build_append_flags()

    def invoke_compiler(self):
        self.parse_custom_flags()
        execargs = [self.argv0, *self.args]

        if os.getenv("WRAPPER_WRITE_LOG"):
            with open("/tmp/ndk-wrapper-log.txt", "a", encoding="utf-8") as log_file:
                log_file.write(" ".join(execargs) + "\n")

        os.execv(self.real_compiler, execargs)


def main(argv):
    wrapper = CompilerWrapper(argv)
    wrapper.invoke_compiler()


if __name__ == "__main__":
    main(sys.argv)
