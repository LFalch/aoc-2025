#!/bin/sh
set -e

echo "Day 1"
cd day01
echo "Part 1"
zig build run1 --release=fast -- 1172
echo "Part 2"
zig build run2 --release=fast -- 6932
cd ..

echo "Day 2"
cd day02
echo "Part 1"
zig build run1 --release=fast -- 21898734247
echo "Part 2"
zig build run2 --release=fast -- 28915664389
cd ..

echo "Day 3"
cd day03
echo "Part 1"
zig build run1 --release=fast -- 17034
echo "Part 2"
zig build run2 --release=fast -- 168798209663590
cd ..

echo "Day 4"
cd day04
echo "Part 1"
zig build run1 --release=fast -- 1435
echo "Part 2"
zig build run2 --release=fast -- 8623
cd ..
