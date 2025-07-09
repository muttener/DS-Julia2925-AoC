#=
--- Day 7: Camel Cards ---

Your all-expenses-paid trip turns out to be a one-way, five-minute ride in an airship. (At least it's a cool airship!) It drops you off at the edge of a vast desert and descends back to Island Island.

"Did you bring the parts?"

You turn around to see an Elf completely covered in white clothing, wearing goggles, and riding a large camel.

"Did you bring the parts?" she asks again, louder this time. You aren't sure what parts she's looking for; you're here to figure out why the sand stopped.

"The parts! For the sand, yes! Come with me; I will show you." She beckons you onto the camel.

After riding a bit across the sands of Desert Island, you can see what look like very large rocks covering half of the horizon. The Elf explains that the rocks are all along the part of Desert Island that is directly above Island Island, making it hard to even get there. Normally, they use big machines to move the rocks and filter the sand, but the machines have broken down because Desert Island recently stopped receiving the parts they need to fix the machines.

You've already assumed it'll be your job to figure out why the parts stopped when she asks if you can help. You agree automatically.

Because the journey will take a few days, she offers to teach you the game of Camel Cards. Camel Cards is sort of similar to poker except it's designed to be easier to play while riding a camel.

In Camel Cards, you get a list of hands, and your goal is to order them based on the strength of each hand. A hand consists of five cards labeled one of A, K, Q, J, T, 9, 8, 7, 6, 5, 4, 3, or 2. The relative strength of each card follows this order, where A is the highest and 2 is the lowest.

Every hand is exactly one type. From strongest to weakest, they are:

    Five of a kind, where all five cards have the same label: AAAAA
    Four of a kind, where four cards have the same label and one card has a different label: AA8AA
    Full house, where three cards have the same label, and the remaining two cards share a different label: 23332
    Three of a kind, where three cards have the same label, and the remaining two cards are each different from any other card in the hand: TTT98
    Two pair, where two cards share one label, two other cards share a second label, and the remaining card has a third label: 23432
    One pair, where two cards share one label, and the other three cards have a different label from the pair and each other: A23A4
    High card, where all cards' labels are distinct: 23456

Hands are primarily ordered based on type; for example, every full house is stronger than any three of a kind.

If two hands have the same type, a second ordering rule takes effect. Start by comparing the first card in each hand. If these cards are different, the hand with the stronger first card is considered stronger. If the first card in each hand have the same label, however, then move on to considering the second card in each hand. If they differ, the hand with the higher second card wins; otherwise, continue with the third card in each hand, then the fourth, then the fifth.

So, 33332 and 2AAAA are both four of a kind hands, but 33332 is stronger because its first card is stronger. Similarly, 77888 and 77788 are both a full house, but 77888 is stronger because its third card is stronger (and both hands have the same first and second card).

To play Camel Cards, you are given a list of hands and their corresponding bid (your puzzle input). For example:

32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483

This example shows five hands; each hand is followed by its bid amount. Each hand wins an amount equal to its bid multiplied by its rank, where the weakest hand gets rank 1, the second-weakest hand gets rank 2, and so on up to the strongest hand. Because there are five hands in this example, the strongest hand will have rank 5 and its bid will be multiplied by 5.

So, the first step is to put the hands in order of strength:

    32T3K is the only one pair and the other hands are all a stronger type, so it gets rank 1.
    KK677 and KTJJT are both two pair. Their first cards both have the same label, but the second card of KK677 is stronger (K vs T), so KTJJT gets rank 2 and KK677 gets rank 3.
    T55J5 and QQQJA are both three of a kind. QQQJA has a stronger first card, so it gets rank 5 and T55J5 gets rank 4.

Now, you can determine the total winnings of this set of hands by adding up the result of multiplying each hand's bid with its rank (765 * 1 + 220 * 2 + 28 * 3 + 684 * 4 + 483 * 5). So the total winnings in this example are 6440.

Find the rank of every hand in your set. What are the total winnings?

=#

@enum CardValue begin
    _2 = 2
    _3 = 3
    _4 = 4
    _5 = 5
    _6 = 6
    _7 = 7
    _8 = 8
    _9 = 9
    _T = 10
    _J = 11
    _Q = 12
    _K = 13
    _A = 14
end

function Base.isless(x::CardValue, y::CardValue)
    return Int(x) < Int(y)
end

function Base.:(==)(x::CardValue, y::CardValue)
    return Int(x) == Int(y)
end

# type alias
const Hand = Vector{CardValue}

function lexographic_isless(h1::Hand,h2::Hand)
    @assert length(h1)==length(h2)
    n = length(h1)
    result = nothing
    i=1
    while isnothing(result) && i ≤ n
        if h1[i] != h2[i]
            result = h1[i] < h2[i]
        end
        i +=1
    end
    isnothing(result) ? false : result
end

hand1 = [_3, _2, _T, _3, _K]
hand2 = [_T, _5, _5, _J, _5] 
hand3 = [_K, _K, _6, _7, _7]
hand4 = [_K, _T, _J, _J, _T] 
hand5 = [_Q, _Q, _Q, _J, _A] 
hands = [hand1, hand2, hand3, hand4, hand5]

lexographic_isless(hand3,hand4)

function group(as)
    function loop(groups,left)
        if isempty(left) 
            return groups
        else
            new_key = popfirst!(left)
            if isempty(groups)
                push!(groups, (new_key,1))
                loop(groups,left)
            else
                (key,amount) = pop!(groups)
                if new_key == key
                    push!(groups, (key,amount+1))
                    loop(groups,left)
                else
                    push!(groups, (key,amount), (new_key,1))
                    loop(groups,left)
                end
            end
        end
    end
    return loop([],sort(as))
end

function score_hand(h1::Hand)
    a = sort(group(h1), by=(x->x[2]),rev=true)
    if a[1][2] == 5 # five of a kind
        return 7
    elseif a[1][2] == 4 # four of a kind
        return 6
    elseif a[1][2] == 3
        if a[2][2] == 2
            return 5 # full house
        else
            return 4 # three of a kind
        end
    elseif a[1][2] == 2
        if a[2][2] == 2
            return 3 # two pairs
        else
            return 2 # one pair
        end
    else
        return 1
    end
end

function myisless(h1::Hand,h2::Hand) # don't use Base.isless with type synonyms
    s1 = score_hand(h1)
    s2 = score_hand(h2)
    if s1 == s2
        return lexographic_isless(h1,h2)
    else
        s1 < s2
    end
end

struct HandBid
    hand::Hand
    bid::Int
end

hand(bh::HandBid) = bh.hand

bid(bh::HandBid) = bh.bid

HandBid((h,b)) = HandBid(h,b)

function myisless(hb1::HandBid,hb2::HandBid) # don't use Base.isless with type synonyms
    myisless(hand(hb1),hand(hb2))
end

function compute(hbs::AbstractArray{HandBid})
    n = length(hbs)
    sort!(hbs, lt=myisless)
    zip(1:n, hbs) .|> (x -> x[1]*bid(x[2])) |> sum
end

test_input = [(hand1, 765), (hand2, 684), (hand3, 28), (hand4, 220), (hand5,483)] .|> HandBid

compute(test_input)

file_path = "2023-07-camel-cards.txt"
input_strings = open(file_path, "r") do file
    readlines(file)
end

function parse_card(s::Char)
    cases = Dict(
        '2' => _2,
        '3' => _3,
        '4' => _4,
        '5' => _5,
        '6' => _6,
        '7' => _7,
        '8' => _8,
        '9' => _9,
        'T' => _T,
        'J' => _J,
        'Q' => _Q,
        'K' => _K,
        'A' => _A,
    )
    return get(cases, s, "No match found")
end

function parse_hand(s::AbstractString)
    hand = []
    for i ∈ eachindex(s)
        push!(hand,parse_card(s[i]))
    end
    return hand
end

function parse_line(s::AbstractString)
    m = match(r"(.*) (\d+)",s)
    hand = parse_hand(m[1])
    bid = parse(Int, m[2])
    return HandBid(hand,bid)
end

solution = input_strings .|> parse_line |> compute
