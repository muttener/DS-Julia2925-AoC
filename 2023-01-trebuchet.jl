#=
--- Day 1: Trebuchet?! ---

Something is wrong with global snow production, and you've been selected to take a look. The Elves have even given you a map; on it, they've used stars to mark the top fifty locations that are likely to be having problems.

You've been doing this long enough to know that to restore snow operations, you need to check all fifty stars by December 25th.

Collect stars by solving puzzles. Two puzzles will be made available on each day in the Advent calendar; the second puzzle is unlocked when you complete the first. Each puzzle grants one star. Good luck!

You try to ask why they can't just use a weather machine ("not powerful enough") and where they're even sending you ("the sky") and why your map looks mostly blank ("you sure ask a lot of questions") and hang on did you just say the sky ("of course, where do you think snow comes from") when you realize that the Elves are already loading you into a trebuchet ("please hold still, we need to strap you in").

As they're making the final adjustments, they discover that their calibration document (your puzzle input) has been amended by a very young Elf who was apparently just excited to show off her art skills. Consequently, the Elves are having trouble reading the values on the document.

The newly-improved calibration document consists of lines of text; each line originally contained a specific calibration value that the Elves now need to recover. On each line, the calibration value can be found by combining the first digit and the last digit (in that order) to form a single two-digit number.

For example:

1abc2
pqr3stu8vwx
a1b2c3d4e5f
treb7uchet

In this example, the calibration values of these four lines are 12, 38, 15, and 77. Adding these together produces 142.

Consider your entire calibration document. What is the sum of all of the calibration values?
=#

function calibrate_line(s::AbstractString)
    m = match(r"[^\d]*(\d).*(\d)[^\d]*|(\d)",s)
    if isnothing(m[1]) # only one digit
        first = m[3]
        second = first
    else
        first = m[1]
        second = m[2]
    end
    return parse(Int, first * second)
end

calibrate_line("1abc2")
calibrate_line("pqr3stu8vwx")
calibrate_line("a1b2c3d4e5f")
calibrate_line("treb7uchet")

file_path = "2023-01-trebuchet.txt"
input_lines = open(file_path, "r") do file
    readlines(file)
end

solution(input) = input .|> calibrate_line |> sum

solution(input_lines)

#=
--- Part Two ---

Your calculation isn't quite right. It looks like some of the digits are actually spelled out with letters: one, two, three, four, five, six, seven, eight, and nine also count as valid "digits".

Equipped with this new information, you now need to find the real first and last digit on each line. For example:

two1nine
eightwothree
abcone2threexyz
xtwone3four
4nineeightseven2
zoneight234
7pqrstsixteen

In this example, the calibration values are 29, 83, 13, 24, 42, 14, and 76. Adding these together produces 281.

What is the sum of all of the calibration values?

=#

function to_number(s::AbstractString)
    if s == "one"
        return 1
    elseif s == "two"
        return 2
    elseif s == "three"
        return 3
    elseif s == "four"
        return 4
    elseif s == "five"
        return 5
    elseif s == "six"
        return 6
    elseif s == "seven"
        return 7
    elseif s == "eight"
        return 8
    elseif s == "nine"
        return 9
    else
        return parse(Int,s)
    end
end

function calibrate_line2(s::AbstractString)
    number = "\\d|one|two|three|four|five|six|seven|eight|nine"
    m = match(Regex("^.*?(" * number * ").*(" * number * ").*?|(" * number * ")"),s)
    if isnothing(m[1]) # only one digit
        first = to_number(m[3])
        second = first
    else
        first = to_number(m[1])
        second = to_number(m[2])
    end
    return 10*first + second
end

calibrate_line2("two1nine")
calibrate_line2("eightwothree")
calibrate_line2("abcone2threexyz")
calibrate_line2("xtwone3four")
calibrate_line2("4nineeightseven2")
calibrate_line2("zoneight234")
calibrate_line2("7pqrstsixteen")


solution2(input) = input .|> calibrate_line2 |> sum

solution2(input_lines)