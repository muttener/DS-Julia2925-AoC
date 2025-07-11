#=
--- Day 11: Cosmic Expansion ---

You continue following signs for "Hot Springs" and eventually come across an observatory. The Elf within turns out to be a researcher studying cosmic expansion using the giant telescope here.

He doesn't know anything about the missing machine parts; he's only visiting for this research project. However, he confirms that the hot springs are the next-closest area likely to have people; he'll even take you straight there once he's done with today's observation analysis.

Maybe you can help him with the analysis to speed things up?

The researcher has collected a bunch of data and compiled the data into a single giant image (your puzzle input). The image includes empty space (.) and galaxies (#). For example:

...#......
.......#..
#.........
..........
......#...
.#........
.........#
..........
.......#..
#...#.....

The researcher is trying to figure out the sum of the lengths of the shortest path between every pair of galaxies. However, there's a catch: the universe expanded in the time it took the light from those galaxies to reach the observatory.

Due to something involving gravitational effects, only some space expands. In fact, the result is that any rows or columns that contain no galaxies should all actually be twice as big.

In the above example, three columns and two rows contain no galaxies:

   v  v  v
 ...#......
 .......#..
 #.........
>..........<
 ......#...
 .#........
 .........#
>..........<
 .......#..
 #...#.....
   ^  ^  ^

These rows and columns need to be twice as big; the result of cosmic expansion therefore looks like this:

....#........
.........#...
#............
.............
.............
........#....
.#...........
............#
.............
.............
.........#...
#....#.......

Equipped with this expanded universe, the shortest path between every pair of galaxies can be found. It can help to assign every galaxy a unique number:

....1........
.........2...
3............
.............
.............
........4....
.5...........
............6
.............
.............
.........7...
8....9.......

In these 9 galaxies, there are 36 pairs. Only count each pair once; order within the pair doesn't matter. For each pair, find any shortest path between the two galaxies using only steps that move up, down, left, or right exactly one . or # at a time. (The shortest path between two galaxies is allowed to pass through another galaxy.)

For example, here is one of the shortest paths between galaxies 5 and 9:

....1........
.........2...
3............
.............
.............
........4....
.5...........
.##.........6
..##.........
...##........
....##...7...
8....9.......

This path has length 9 because it takes a minimum of nine steps to get from galaxy 5 to galaxy 9 (the eight locations marked # plus the step onto galaxy 9 itself). Here are some other example shortest path lengths:

    Between galaxy 1 and galaxy 7: 15
    Between galaxy 3 and galaxy 6: 17
    Between galaxy 8 and galaxy 9: 5

In this example, after expanding the universe, the sum of the shortest path between all 36 pairs of galaxies is 374.

Expand the universe, then find the length of the shortest path between every pair of galaxies. What is the sum of these lengths?

=#

struct Pos
    row::Int
    col::Int
end

get_distance(p1::Pos,p2::Pos) = abs(p1.row-p2.row) + abs(p1.col-p2.col)

move_right(p::Pos,scale_factor) = Pos(p.row,              p.col+scale_factor)
move_down(p::Pos,scale_factor)  = Pos(p.row+scale_factor, p.col)

test_lines = split(
    """...#......
    .......#..
    #.........
    ..........
    ......#...
    .#........
    .........#
    ..........
    .......#..
    #...#.....""","\n") .|> String

function get_galaxies(lines)
    galaxies = []
    for row ∈ eachindex(lines)
        append!(galaxies,[Pos(row,col) for col ∈ findall(c -> c == '#', lines[row])])
    end
    return galaxies
end

get_galaxies(test_lines)

# better would be to use the galaxies of course 
function get_empty_rows(lines) # decreasing!
    rows = []
    for row ∈ eachindex(lines)
        if all([lines[row][col] != '#' for col ∈ eachindex(lines[row])])
            push!(rows,row)
        end
    end
    return reverse(rows)
end

get_empty_rows(test_lines)

# better would be to use the galaxies of course 
function get_empty_cols(lines) # decreasing!
    cols = []
    for col ∈ eachindex(lines[1])
        if all([lines[row][col] != '#' for row ∈ eachindex(lines)])
            push!(cols,col)
        end
    end
    return reverse(cols)
end

get_empty_cols(test_lines)

maybe_shift_row(p::Pos,row,scale_factor) = p.row > row ? move_down(p,scale_factor-1) : p
maybe_shift_col(p::Pos,col,scale_factor) = p.col > col ? move_right(p,scale_factor-1) : p
 
function get_distances(lines,scale_factor)
    galaxies = get_galaxies(lines)
    for row in get_empty_rows(lines)
        galaxies = galaxies .|> (p -> maybe_shift_row(p,row,scale_factor))
    end
    for col in get_empty_cols(lines)
        galaxies = galaxies .|> (p -> maybe_shift_col(p,col,scale_factor))
    end
    distances = []
    n = length(galaxies)
    for i ∈ 1:n-1
        for j ∈ i+1:n 
            push!(distances,get_distance(galaxies[i],galaxies[j]))
        end
    end
    return distances
end

solution(lines, scale_factor) =  get_distances(lines,scale_factor) |> sum

file_path = "2023-11-cosmic-expansion.txt"
input_lines = open(file_path, "r") do file
    readlines(file)
end

solution(test_lines,2) # empty rows and cols double
solution(input_lines,2)

#=
--- Part Two ---

The galaxies are much older (and thus much farther apart) than the researcher initially estimated.

Now, instead of the expansion you did before, make each empty row or column one million times larger. That is, each empty row should be replaced with 1000000 empty rows, and each empty column should be replaced with 1000000 empty columns.

(In the example above, if each empty row or column were merely 10 times larger, the sum of the shortest paths between every pair of galaxies would be 1030. If each empty row or column were merely 100 times larger, the sum of the shortest paths between every pair of galaxies would be 8410. However, your universe will need to expand far beyond these values.)

Starting with the same initial image, expand the universe according to these new rules, then find the length of the shortest path between every pair of galaxies. What is the sum of these lengths?

=#

solution(test_lines,10)
solution(input_lines, 1_000_000)