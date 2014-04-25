#!/bin/bash
set -e

cd "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


haxe compile.hxml
neko run.n
rm -f run.n


