#!/bin/bash
echo \"Installing AELION on Termux...\"

pkg update -y
pkg upgrade -y
pkg install clang make git -y

echo \"AELION Termux environment ready.\"
