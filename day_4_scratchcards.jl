# Day 4
# Preamble
using DelimitedFiles

# We're trying to find the total winning per line, and then the total overal.
# First match is one point, then doubling (so 2^(n-1) for n>0, 0 otherwise)
# The goal numbers are on the left, and our collection is on the right


test = [
    "Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53",
    "Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19",
    "Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1",
    "Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83",
    "Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36",
    "Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11",
]

split(test[1])

function line_score(str)
    trim_str = replace(str, r"Card\s+\d+:\s"=>"")
    (goals_str, acts_str) = split(trim_str, "|")
    goals = parse.(Int, split(goals_str))
    acts = parse.(Int, split(acts_str))

    total = sum(x -> x in goals, acts)

    return total > 0 ? 2^(total-1) : 0
end

function get_total_score(data)
    total = 0
    for (idx, row) in enumerate(data)
        val = line_score(row)
        total += val
        @debug idx, val, total
    end
    return total
end

get_total_score(test)

data = readdlm("data\\day_4_scratchcards.txt", '\n', String);

get_total_score(data)