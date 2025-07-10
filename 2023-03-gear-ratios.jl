#=
--- Day 3: Gear Ratios ---

You and the Elf eventually reach a gondola lift station; he says the gondola lift will take you up to the water source, but this is as far as he can bring you. You go inside.

It doesn't take long to find the gondolas, but there seems to be a problem: they're not moving.

"Aaah!"

You turn around to see a slightly-greasy Elf with a wrench and a look of surprise. "Sorry, I wasn't expecting anyone! The gondola lift isn't working right now; it'll still be a while before I can fix it." You offer to help.

The engineer explains that an engine part seems to be missing from the engine, but nobody can figure out which one. If you can add up all the part numbers in the engine schematic, it should be easy to work out which part is missing.

The engine schematic (your puzzle input) consists of a visual representation of the engine. There are lots of numbers and symbols you don't really understand, but apparently any number adjacent to a symbol, even diagonally, is a "part number" and should be included in your sum. (Periods (.) do not count as a symbol.)

Here is an example engine schematic:

467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...$.*....
.664.598..

In this schematic, two numbers are not part numbers because they are not adjacent to a symbol: 114 (top right) and 58 (middle right). Every other number is adjacent to a symbol and so is a part number; their sum is 4361.

Of course, the actual engine schematic is much larger. What is the sum of all of the part numbers in the engine schematic?

=#

test_input = split(
    """467..114..
    ...*......
    ..35..633.
    ......#...
    617*......
    .....+.58.
    ..592.....
    ......755.
    ...\$.*....
    .664.598..""", "\n")

is_symbol(c::AbstractChar) = c ∉ "0123456789."

is_digit(c::AbstractChar) = c ∈ "0123456789"

function check_safe(f,row,col,lines,rows,cols)
    if !(1 ≤ row ≤ rows) || !(1 ≤ col ≤ cols)
        return false
    else
        return f(lines[row][col])
    end
end

is_symbol_safe(row,col,lines,rows,cols) = check_safe(is_symbol, row,col,lines,rows,cols)

is_digit_safe(row,col,lines,rows,cols) = check_safe(is_digit, row,col,lines,rows,cols)

function collect_part_numbers(lines)
    # by assumption, all lines are equally long
    rows = length(lines)
    cols = length(lines[1])
    in_number = false
    next_to_symbol = false
    current_number = 0
    numbers = []
    for row ∈ 1:rows
        for col ∈ 1:cols
            char = lines[row][col]
            if is_digit(char)
                current_number = 10*current_number + parse(Int,char)
                if !in_number
                    # check left of number for symbols
                    next_to_symbol |= 
                        is_symbol_safe(row-1,col-1,lines,rows,cols) || 
                        is_symbol_safe(row,col-1,lines,rows,cols) || 
                        is_symbol_safe(row+1,col-1,lines,rows,cols)
                end
                in_number = true
                # check above and below
                next_to_symbol |= 
                    is_symbol_safe(row-1,col,lines,rows,cols) || 
                    is_symbol_safe(row+1,col,lines,rows,cols)
            elseif in_number
                # check right of number for symbols
                next_to_symbol |= 
                    is_symbol_safe(row-1,col,lines,rows,cols) || 
                    is_symbol_safe(row,col,lines,rows,cols) || 
                    is_symbol_safe(row+1,col,lines,rows,cols)
                if next_to_symbol
                    push!(numbers,current_number)
                end
                # reset
                in_number = false
                next_to_symbol = false
                current_number = 0
            end
        end
    end
    return numbers
end

collect_part_numbers(test_input)

solution(lines) = lines |> collect_part_numbers |> sum

file_path = "2023-03-gear-ratios.txt"
input_lines = open(file_path, "r") do file
    readlines(file)
end

solution(test_input)
solution(input_lines)

#=
--- Part Two ---

The engineer finds the missing part and installs it in the engine! As the engine springs to life, you jump in the closest gondola, finally ready to ascend to the water source.

You don't seem to be going very fast, though. Maybe something is still wrong? Fortunately, the gondola has a phone labeled "help", so you pick it up and the engineer answers.

Before you can explain the situation, she suggests that you look out the window. There stands the engineer, holding a phone in one hand and waving with the other. You're going so slowly that you haven't even left the station. You exit the gondola.

The missing part wasn't the only issue - one of the gears in the engine is wrong. A gear is any * symbol that is adjacent to exactly two part numbers. Its gear ratio is the result of multiplying those two numbers together.

This time, you need to find the gear ratio of every gear and add them all up so that the engineer can figure out which gear needs to be replaced.

Consider the same engine schematic again:

467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...$.*....
.664.598..

In this schematic, there are two gears. The first is in the top left; it has part numbers 467 and 35, so its gear ratio is 16345. The second gear is in the lower right; its gear ratio is 451490. (The * adjacent to 617 is not a gear because it is only adjacent to one part number.) Adding up all of the gear ratios produces 467835.

What is the sum of all of the gear ratios in your engine schematic?

=#

struct Position
    row::Int
    col::Int
end

function equals(p1::Position, p2::Position)
    p1.row == p2.row && p1.col == p2.col
end

function find_gears(lines, rows, cols)
    gears = []
    for row ∈ 1:rows
        for col ∈ 1:cols
            if lines[row][col] == '*'
                push!(gears, Position(row,col))
            end
        end
    end
    return gears
end

function get_full_number(p::Position, lines, rows, cols)
    row = p.row
    col = p.col
    # get to beginning of number
    while is_digit_safe(row, col-1, lines, rows, cols)
        col -= 1
    end
    start_col = col
    # construct number
    number = 0
    while is_digit_safe(row, col, lines, rows, cols)
        number = 10*number + parse(Int,lines[row][col])
        col += 1
    end
    return (number, Position(row, start_col))
end

function find_surrounding_numbers(p::Position, lines, rows, cols)
    row = p.row
    col = p.col
    numbers = []
    for (drow,dcol) ∈ [(i,j) for i ∈ -1:1,  j ∈ -1:1 if !(i == 0 && j == 0)]
        if is_digit_safe(row+drow, col+dcol, lines,rows, cols)
            push!(numbers, get_full_number(Position(row+drow,col+dcol), lines, rows, cols))
        end
    end
    # zum kotsen
    unique_numbers = []
    for number in numbers
        already_seen = any([equals(number[2], n[2]) for n ∈ unique_numbers])
        if !already_seen
            push!(unique_numbers,number)
        end
    end
    return unique_numbers .|> (x -> x[1]) # forget starting position
end

function solution2(lines)
    # by assumption, all lines are equally long
    rows = length(lines)
    cols = length(lines[1])
    gears = find_gears(lines,rows,cols)
    return gears .|> (p -> find_surrounding_numbers(p, lines, rows, cols)) |> filter(ns -> length(ns) == 2) .|> prod |> sum
end

solution2(input_lines)