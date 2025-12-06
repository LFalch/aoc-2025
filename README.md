# Advent of Code 2025

This repo contains my solutions to this year's AoC event. The first few were first written in C,
then rewritten in Zig and then transformed to use my `aoc` library which can do benchmarks.
There are also a few shell scripts to grab puzzle input and set up new folders for each day.
If you want to use grab your puzzle input, put your AoC session cookie in a file `.session` (just the value
of the cookie, not the key) and run `./grabinput.sh x` where _x_ is a day. It'll put it in the corresponding folder.

All solutions here were coded with Zig 0.15.2. If you have another version installed, you may not be able
to compile them as Zig currently introduces many breaking changes between updates. Most features I use
have been fairly stable for a while so it may work in other minor versions too, but I haven't tested it.

## Running the solutions

Running the solutions that use my aoc library (every day has one), is done by running
`zig build run1` for part 1 and `zig build run2` for part 2. By default, it'll use `input.txt` as the
puzzle input to go over (which is what `grabinput.sh` makes), but you can supply a different file, e.g. for testing (put them after a `--` argument). If you want to run a benchmark, you need to pass the answer
to the puzzle as the argument. Say the answer to part 1 is `400`, then `zig build run1 -- 400` would run a
benchmark on the solution and checking that they do indeed come up with 400 as the answer meanwhile.

### Optimised builds

If you want to run an optimised build, you can pass `--release=fast` for the fastest result (before any `--` 
and after `run1`/`run2`). Be careful though, as the solutions make vivid use of `unreachable` and other
illegal behaviour that I assume won't be invoked. If your input files aren't entirely wellformed, you might
invoke illegal behaviour and get weird results or crashes. In any other build mode though, illegal behaviour 
is checked and you instead get a nice stack trace and error message. You can use `--release=safe` if you want
fast builds that check for illegal behaviour.

I also assume that you won't use a lot of memory and only have a limited amount of memory available
to the solutions for extra speed. If your input file is too big, you will also invoke illegal behaviour.

## Running the C solutions

If you wanna run the C solutions, just compile the `main.c` file to binary and run it and it'll give an
answer to both parts. You can also give them a custom input file (defaulting to `input.txt`) but they don't
have built-in benchmarking.
