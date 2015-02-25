#!/usr/bin/env bash
#
# GGCOM Application Version Checker v201502250329
# Louis T. Getterman IV (@LTGIV)
# www.GotGetLLC.com | www.opensour.cc/ggcom/versions
#
# Example usage:
# ggcom-version.bash /usr/bin/dfwu.py

GGCOMAPP=${1-$0}
head -n4 "$GGCOMAPP" | grep 'v[0-9]' | grep -Eo '[0-9]{1,}'
