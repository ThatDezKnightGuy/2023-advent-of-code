# Preamble
using DelimitedFiles

# Part 1
# We're looking for numbers that are adjascent to a symbol on an upper or lower line
# Most likely we need a lookup of all symbol positions
# And then we compare to the numbers positions and lengths

# We could always do a single pass process and always check the prceding line?

test = [
    "467..114..",
    "...*......",
    "..35..633.",
    "......#...",
    "617*......",
    ".....+.58.",
    "..592.....",
    "......755.",
    "...\$.*....",
    ".664.598..",
]

function generate_symbol_index(data)
    index = Dict{Int, Vector{Int}}()
    for (idx, row) in enumerate(data), (jdx, ch) in enumerate(row)
        occursin(r"[a-zA-Z\d.]", string(ch)) && continue
        push!(get!(index, idx, Int[]), jdx)
    end
    return index
end

function all_number_ranges(str)
    ranges = []
    a = findnext(r"\d+", str, 1)
    while !isnothing(a)
        push!(ranges, a)
        a = findnext(r"\d+", str, last(a)+1)
    end
    return ranges
end

function near_any_symbol(range, index_item)
    wide_range = (first(range)-1):(last(range)+1)
    return any(i->(i in wide_range), index_item)
end

function find_values(data, index)
    total = 0
    for (idx, row) in enumerate(data)
        ranges = all_number_ranges(row)
        isempty(ranges) && continue
        mask = zeros(Bool, length(ranges))
        for (jdx, range) in enumerate(ranges)
            mask[jdx] = any(x-> near_any_symbol(range, get(index, x, [])), (idx-1):(idx+1))
        end

        values = [parse(Int, row[x]) for x in ranges[mask]]
        @debug idx, ranges, mask, sum(value)

        total += sum(values)
    end
    return total
end

symbol_index = generate_symbol_index(test)
total = find_values(test, symbol_index)

#= Our lookup should look like
Dict(
    2 => [4],
    4 => [7],
    5 => [4],
    6 => [6],
    9 => [4, 6]
)
=#

# Read file
data = readdlm("data\\day_3_engine.txt", '\n', String);

symbol_index = generate_symbol_index(data)
total = find_values(data, symbol_index)