#=
--- Day 2: Cube Conundrum ---

You're launched high into the atmosphere! The apex of your trajectory just barely reaches the surface of a large island floating in the sky. You gently land in a fluffy pile of leaves. It's quite cold, but you don't see much snow. An Elf runs over to greet you.

The Elf explains that you've arrived at Snow Island and apologizes for the lack of snow. He'll be happy to explain the situation, but it's a bit of a walk, so you have some time. They don't get many visitors up here; would you like to play a game in the meantime?

As you walk, the Elf shows you a small bag and some cubes which are either red, green, or blue. Each time you play this game, he will hide a secret number of cubes of each color in the bag, and your goal is to figure out information about the number of cubes.

To get information, once a bag has been loaded with cubes, the Elf will reach into the bag, grab a handful of random cubes, show them to you, and then put them back in the bag. He'll do this a few times per game.

You play several games and record the information from each game (your puzzle input). Each game is listed with its ID number (like the 11 in Game 11: ...) followed by a semicolon-separated list of subsets of cubes that were revealed from the bag (like 3 red, 5 green, 4 blue).

For example, the record of a few games might look like this:

Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green

In game 1, three sets of cubes are revealed from the bag (and then put back again). The first set is 3 blue cubes and 4 red cubes; the second set is 1 red cube, 2 green cubes, and 6 blue cubes; the third set is only 2 green cubes.

The Elf would first like to know which games would have been possible if the bag contained only 12 red cubes, 13 green cubes, and 14 blue cubes?

In the example above, games 1, 2, and 5 would have been possible if the bag had been loaded with that configuration. However, game 3 would have been impossible because at one point the Elf showed you 20 red cubes at once; similarly, game 4 would also have been impossible because the Elf showed you 15 blue cubes at once. If you add up the IDs of the games that would have been possible, you get 8.

Determine which games would have been possible if the bag had been loaded with only 12 red cubes, 13 green cubes, and 14 blue cubes. What is the sum of the IDs of those games?

=#

struct Reveal
    red::Int
    green::Int
    blue::Int
end

Base.show(io::IO,r::Reveal) = print(io, "R$(r.red)_G$(r.green)_B$(r.blue)")

combine(r1::Reveal,r2::Reveal) = Reveal(max(r1.red,r2.red), max(r1.green,r2.green),max(r1.blue,r2.blue))

Reveal(4,0,3) 
reveals1 = [Reveal(4,0,3),Reveal(1,2,6), Reveal(0,2,0)]
max_reveals1 = foldl(combine,reveals1)
is_possible(max_reveals1,Reveal(12,13,14))

struct Game
    id::Int
    reveals::AbstractArray{Reveal}
end

id(g::Game) = g.id

reveals(g::Game) = g.reveals

reduce(g::Game) = foldl(combine,g.reveals)

function is_possible(g::Game,bound::Reveal) 
    r_max = reduce(g)
    return r_max.blue ≤ bound.blue && r_max.red ≤ bound.red && r_max.green ≤ bound.green
end

game1 = Game(1,reveals1)

file_path = "2023-02-cube-conundrum.txt"
input = open(file_path, "r") do file
    readlines(file)
end

# parses something like 8 green, 4 red, 4 blue
function parse_reveal(s::AbstractString)
    mr = match(r"(\d+) red",s)
    mg = match(r"(\d+) green",s)
    mb = match(r"(\d+) blue",s)
    r = isnothing(mr) ? 0 : parse(Int,mr[1])
    g = isnothing(mg) ? 0 : parse(Int,mg[1])
    b = isnothing(mb) ? 0 : parse(Int,mb[1])
    return Reveal(r,g,b)
end

parse_reveal("8 green, 4 red")

# parses a whole line
function parse_line(s::AbstractString)
    m = match(r"Game (\d+):(.*)",s)
    id = parse(Int,m[1])
    reveals = split(m[2],";") .|> parse_reveal
    return Game(id,reveals)
end

parse_line("Game 1: 8 green, 4 red, 4 blue; 1 green, 6 red, 4 blue; 7 red, 4 green, 1 blue; 2 blue, 8 red, 8 green")

function solution(input::AbstractArray{String},bound::Reveal) 
    input .|> 
    parse_line |> 
    filter(g -> is_possible(g,bound)) .|>
    id |>
    sum
end

solution(input,Reveal(12,13,14))

#=
--- Part Two ---

The Elf says they've stopped producing snow because they aren't getting any water! He isn't sure why the water stopped; however, he can show you how to get to the water source to check it out for yourself. It's just up ahead!

As you continue your walk, the Elf poses a second question: in each game you played, what is the fewest number of cubes of each color that could have been in the bag to make the game possible?

Again consider the example games from earlier:

Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green

    In game 1, the game could have been played with as few as 4 red, 2 green, and 6 blue cubes. If any color had even one fewer cube, the game would have been impossible.
    Game 2 could have been played with a minimum of 1 red, 3 green, and 4 blue cubes.
    Game 3 must have been played with at least 20 red, 13 green, and 6 blue cubes.
    Game 4 required at least 14 red, 3 green, and 15 blue cubes.
    Game 5 needed no fewer than 6 red, 3 green, and 2 blue cubes in the bag.

The power of a set of cubes is equal to the numbers of red, green, and blue cubes multiplied together. The power of the minimum set of cubes in game 1 is 48. In games 2-5 it was 12, 1560, 630, and 36, respectively. Adding up these five powers produces the sum 2286.

For each game, find the minimum set of cubes that must have been present. What is the sum of the power of these sets?

=#

power(r::Reveal) = r.red * r.green * r.blue

function solution2(input::AbstractArray{String})
    input .|> 
    parse_line .|> 
    reduce .|>
    power |>
    sum
end

solution2(input)