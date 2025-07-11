#=
--- Day 10: Pipe Maze ---

You use the hang glider to ride the hot air from Desert Island all the way up to the floating metal island. This island is surprisingly cold and there definitely aren't any thermals to glide on, so you leave your hang glider behind.

You wander around for a while, but you don't find any people or animals. However, you do occasionally find signposts labeled "Hot Springs" pointing in a seemingly consistent direction; maybe you can find someone at the hot springs and ask them where the desert-machine parts are made.

The landscape here is alien; even the flowers and trees are made of metal. As you stop to admire some metal grass, you notice something metallic scurry away in your peripheral vision and jump into a big pipe! It didn't look like any animal you've ever seen; if you want a better look, you'll need to get ahead of it.

Scanning the area, you discover that the entire field you're standing on is densely packed with pipes; it was hard to tell at first because they're the same metallic silver color as the "ground". You make a quick sketch of all of the surface pipes you can see (your puzzle input).

The pipes are arranged in a two-dimensional grid of tiles:

    | is a vertical pipe connecting north and south.
    - is a horizontal pipe connecting east and west.
    L is a 90-degree bend connecting north and east.
    J is a 90-degree bend connecting north and west.
    7 is a 90-degree bend connecting south and west.
    F is a 90-degree bend connecting south and east.
    . is ground; there is no pipe in this tile.
    S is the starting position of the animal; there is a pipe on this tile, but your sketch doesn't show what shape the pipe has.

Based on the acoustics of the animal's scurrying, you're confident the pipe that contains the animal is one large, continuous loop.

For example, here is a square loop of pipe:

.....
.F-7.
.|.|.
.L-J.
.....

If the animal had entered this loop in the northwest corner, the sketch would instead look like this:

.....
.S-7.
.|.|.
.L-J.
.....

In the above diagram, the S tile is still a 90-degree F bend: you can tell because of how the adjacent pipes connect to it.

Unfortunately, there are also many pipes that aren't connected to the loop! This sketch shows the same loop as above:

-L|F7
7S-7|
L|7||
-L-J|
L|-JF

In the above diagram, you can still figure out which pipes form the main loop: they're the ones connected to S, pipes those pipes connect to, pipes those pipes connect to, and so on. Every pipe in the main loop connects to its two neighbors (including S, which will have exactly two pipes connecting to it, and which is assumed to connect back to those two pipes).

Here is a sketch that contains a slightly more complex main loop:

..F7.
.FJ|.
SJ.L7
|F--J
LJ...

Here's the same example sketch with the extra, non-main-loop pipe tiles also shown:

7-F7-
.FJ|7
SJLL7
|F--J
LJ.LJ

If you want to get out ahead of the animal, you should find the tile in the loop that is farthest from the starting position. Because the animal is in the pipe, it doesn't make sense to measure this by direct distance. Instead, you need to find the tile that would take the longest number of steps along the loop to reach from the starting point - regardless of which way around the loop the animal went.

In the first example with the square loop:

.....
.S-7.
.|.|.
.L-J.
.....

You can count the distance each tile in the loop is from the starting point like this:

.....
.012.
.1.3.
.234.
.....

In this example, the farthest point from the start is 4 steps away.

Here's the more complex loop again:

..F7.
.FJ|.
SJ.L7
|F--J
LJ...

Here are the distances for each tile on that loop:

..45.
.236.
01.78
14567
23...

Find the single giant loop starting at S. How many steps along the loop does it take to get from the starting position to the point farthest from the starting position?

=#
struct Pos
    row::Int
    col::Int
end

struct Dir
    drow::Int
    dcol::Int
end

test_lines1 = split(
    """.....
    .S-7.
    .|.|.
    .L-J.
    .....""","\n") .|> String

test_lines2 = split(
    """..F7.
    .FJ|.
    SJ.L7
    |F--J
    LJ...""","\n") .|> String
    

function get_directions(c)
    if c == 'S'
        return [Dir(-1,0), Dir(0,-1), Dir(1,0), Dir(0,1)]
    elseif c == '|'
        return [Dir(-1,0),            Dir(1,0),         ]
    elseif c == '-'
        return [           Dir(0,-1),           Dir(0,1)]
    elseif c == 'L'
        return [Dir(-1,0),                      Dir(0,1)]
    elseif c == 'J'
        return [Dir(-1,0), Dir(0,-1),                   ]
    elseif c == '7'
        return [           Dir(0,-1), Dir(1,0),         ]
    elseif c == 'F'
        return [                      Dir(1,0), Dir(0,1)]
    else 
        return []
    end
end

function move(p::Pos,d::Dir)
    Pos(p.row + d.drow, p.col + d.dcol)
end

function is_in_grid(p::Pos,nrow::Int,ncol::Int)
    return 1 ≤ p.row ≤ nrow && 1 ≤ p.col ≤ ncol
end

function get_possible_neighbors(p::Pos,lines, nrow, ncol,)
    c = lines[p.row][p.col]
    return [move(p,d) for d ∈ get_directions(c)] |> filter(p -> is_in_grid(p,nrow,ncol))
end

# this is only needed for the start, one could speed up the code by taking being more careful with S
function are_neighbors(p1::Pos,p2::Pos,lines, nrow, ncol)
    return p2 ∈ get_possible_neighbors(p1,lines, nrow, ncol) && p1 ∈ get_possible_neighbors(p2,lines, nrow, ncol)
end

function get_neighbors(p::Pos,lines, nrow, ncol)
    return get_possible_neighbors(p,lines,nrow, ncol) |> filter(q -> are_neighbors(p,q,lines,nrow, ncol))
end

function find_start(lines, nrow, ncol)
    row = -1
    col = -1
    step = 0
    found = false
    while !found
        col = step ÷ nrow + 1
        row = step % nrow + 1
        if lines[row][col] == 'S'
            found = true
        end
        step += 1
    end
    return Pos(row,col)
end

find_start(test_lines1,5,5)

get_neighbors(Pos(2,2), test_lines1,5,5)

function solution(lines)
    nrow = length(lines)
    ncol = length(lines[1])
    distances = fill(-1, nrow, ncol)
    m = 0
    ps = find_start(lines, nrow, ncol)
    distances[ps.row, ps.col] = 0
    positions = [ps]
    while !isempty(positions)
        p = popfirst!(positions)
        dist = distances[p.row,p.col]
        for neighbor ∈ get_neighbors(p,lines, ncol, nrow)
            if distances[neighbor.row,neighbor.col] == -1
                distances[neighbor.row,neighbor.col] = dist + 1
                m = max(m,dist+1)
                push!(positions,neighbor)
            end
        end
    end
    return m
end

file_path = "2023-10-pipe-maze.txt"
input_lines = open(file_path, "r") do file
    readlines(file)
end

solution(test_lines1)
solution(test_lines2)
solution(input_lines)

#=
--- Part Two ---

You quickly reach the farthest point of the loop, but the animal never emerges. Maybe its nest is within the area enclosed by the loop?

To determine whether it's even worth taking the time to search for such a nest, you should calculate how many tiles are contained within the loop. For example:

...........
.S-------7.
.|F-----7|.
.||.....||.
.||.....||.
.|L-7.F-J|.
.|..|.|..|.
.L--J.L--J.
...........

The above loop encloses merely four tiles - the two pairs of . in the southwest and southeast (marked I below). The middle . tiles (marked O below) are not in the loop. Here is the same loop again with those regions marked:

...........
.S-------7.
.|F-----7|.
.||OOOOO||.
.||OOOOO||.
.|L-7OF-J|.
.|II|O|II|.
.L--JOL--J.
.....O.....

In fact, there doesn't even need to be a full tile path to the outside for tiles to count as outside the loop - squeezing between pipes is also allowed! Here, I is still within the loop and O is still outside the loop:

..........
.S------7.
.|F----7|.
.||OOOO||.
.||OOOO||.
.|L-7F-J|.
.|II||II|.
.L--JL--J.
..........

In both of the above examples, 4 tiles are enclosed by the loop.

Here's a larger example:

.F----7F7F7F7F-7....
.|F--7||||||||FJ....
.||.FJ||||||||L7....
FJL7L7LJLJ||LJ.L-7..
L--J.L7...LJS7F-7L7.
....F-J..F7FJ|L7L7L7
....L7.F7||L7|.L7L7|
.....|FJLJ|FJ|F7|.LJ
....FJL-7.||.||||...
....L---J.LJ.LJLJ...

The above sketch has many random bits of ground, some of which are in the loop (I) and some of which are outside it (O):

OF----7F7F7F7F-7OOOO
O|F--7||||||||FJOOOO
O||OFJ||||||||L7OOOO
FJL7L7LJLJ||LJIL-7OO
L--JOL7IIILJS7F-7L7O
OOOOF-JIIF7FJ|L7L7L7
OOOOL7IF7||L7|IL7L7|
OOOOO|FJLJ|FJ|F7|OLJ
OOOOFJL-7O||O||||OOO
OOOOL---JOLJOLJLJOOO

In this larger example, 8 tiles are enclosed by the loop.

Any tile that isn't part of the main loop can count as being enclosed by the loop. Here's another example with many bits of junk pipe lying around that aren't connected to the main loop at all:

FF7FSF7F7F7F7F7F---7
L|LJ||||||||||||F--J
FL-7LJLJ||||||LJL-77
F--JF--7||LJLJ7F7FJ-
L---JF-JLJ.||-FJLJJ7
|F|F-JF---7F7-L7L|7|
|FFJF7L7F-JF7|JL---7
7-L-JL7||F7|L7F-7F7|
L.L7LFJ|||||FJL7||LJ
L7JLJL-JLJLJL--JLJ.L

Here are just the tiles that are enclosed by the loop marked with I:

FF7FSF7F7F7F7F7F---7
L|LJ||||||||||||F--J
FL-7LJLJ||||||LJL-77
F--JF--7||LJLJIF7FJ-
L---JF-JLJIIIIFJLJJ7
|F|F-JF---7IIIL7L|7|
|FFJF7L7F-JF7IIL---7
7-L-JL7||F7|L7F-7F7|
L.L7LFJ|||||FJL7||LJ
L7JLJL-JLJLJL--JLJ.L

In this last example, 10 tiles are enclosed by the loop.

Figure out whether you have time to search for the nest by calculating the area within the loop. How many tiles are enclosed by the loop?

=#

function get_start_replacement(start::Pos,lines,nrow,ncol)
    neighbors = get_neighbors(start,lines, nrow, ncol)
    replacement = nothing
    for char ∈ "|-FJL7"
        if [move(start,d) for d ∈ get_directions(char)] == neighbors
            replacement = char
        end
    end
    return replacement
end

get_start_replacement(Pos(1,3),test_lines2,5,5)

function solution2(lines)
    nrow = length(lines)
    ncol = length(lines[1])
    mat = fill(-1, nrow, ncol)
    for i ∈ 1:nrow
        lines[i] = String(lines[i])
    end
    ps = find_start(lines, nrow, ncol)
    start_char = get_start_replacement(ps,lines,nrow,ncol)
    mat[ps.row, ps.col] = 0
    positions = [ps]
    # find the loop (indicated with 0)
    while !isempty(positions)
        p = popfirst!(positions)
        for neighbor ∈ get_neighbors(p,lines, nrow, ncol)
            if mat[neighbor.row,neighbor.col] == -1
                mat[neighbor.row,neighbor.col] = 0
                push!(positions,neighbor)
            end
        end
    end
    # check if inside loop (indicated with 1, 0 otherwise)
    for row ∈ 1:nrow
        inside_loop = false
        entering_char = nothing
        for col ∈ 1:ncol
            char = lines[row][col]
            if mat[row,col] == 0 # pipe on the loop
                if char == 'S' # normalize input
                    char = start_char
                end
                if char == '|'
                    inside_loop = !inside_loop # swap inside and outside
                elseif char == '-'
                elseif char ∈ "FL"
                    entering_char = char 
                elseif char ∈ "J7"
                    not_tangential = entering_char == 'F' &&  char == 'J' || entering_char == 'L' &&  char == '7'
                    if not_tangential
                        inside_loop = !inside_loop # swap inside and outside
                    end
                else
                    @error "Unreachable"
                end
            else # not a pipe on the loop
                mat[row,col] = inside_loop ? 1 : 0
            end
        end
    end
    return sum(mat)
end

test_lines3 = split(
    """...........
    .S-------7.
    .|F-----7|.
    .||.....||.
    .||.....||.
    .|L-7.F-J|.
    .|..|.|..|.
    .L--J.L--J.
    ...........""", "\n")

test_lines4 = split(
    """.F----7F7F7F7F-7....
    .|F--7||||||||FJ....
    .||.FJ||||||||L7....
    FJL7L7LJLJ||LJ.L-7..
    L--J.L7...LJS7F-7L7.
    ....F-J..F7FJ|L7L7L7
    ....L7.F7||L7|.L7L7|
    .....|FJLJ|FJ|F7|.LJ
    ....FJL-7.||.||||...
    ....L---J.LJ.LJLJ...""", "\n")


test_lines5 = split(
    """FF7FSF7F7F7F7F7F---7
    L|LJ||||||||||||F--J
    FL-7LJLJ||||||LJL-77
    F--JF--7||LJLJ7F7FJ-
    L---JF-JLJ.||-FJLJJ7
    |F|F-JF---7F7-L7L|7|
    |FFJF7L7F-JF7|JL---7
    7-L-JL7||F7|L7F-7F7|
    L.L7LFJ|||||FJL7||LJ
    L7JLJL-JLJLJL--JLJ.L""", "\n")

solution2(test_lines1)
solution2(test_lines2)
solution2(test_lines3)
solution2(test_lines4)
solution2(test_lines5)
solution2(input_lines)