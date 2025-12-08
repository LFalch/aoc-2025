#!/bin/sh
set -e

cd day01
echo d1p1 in  $(zig build run1 --release=fast -- 1172)
echo d1p2 in  $(zig build run2 --release=fast -- 6932)
cd ..

cd day02
echo d2p1 in  $(zig build run1 --release=fast -- 21898734247)
echo d2p2 in  $(zig build run2 --release=fast -- 28915664389)
cd ..

cd day03
echo d3p1 in  $(zig build run1 --release=fast -- 17034)
echo d3p2 in  $(zig build run2 --release=fast -- 168798209663590)
cd ..

cd day04
echo d4p1 in  $(zig build run1 --release=fast -- 1435)
echo d4p2 in  $(zig build run2 --release=fast -- 8623)
cd ..

cd day05
echo d5p1 in  $(zig build run1 --release=fast -- 707)
echo d5p2 in  $(zig build run2 --release=fast -- 361615643045059)
cd ..

cd day06
echo d6p1 in  $(zig build run1 --release=fast -- 6725216329103)
echo d6p2 in  $(zig build run2 --release=fast -- 10600728112865)
cd ..

cd day07
echo d7p1 in  $(zig build run1 --release=fast -- 1660)
echo d7p2 in  $(zig build run2 --release=fast -- 305999729392659)
cd ..
