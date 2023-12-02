# Preamble
using DelimitedFiles

# Part 1
# We need the first and last number in the string, which can be the same.
# Fastest way would be a regex find

# Let's make a quick fn

function treb_sum(data; use_words=false)
    total = 0

    for (idx, ln) in enumerate(data)
        modified = use_words ? modify_line(ln) : ln
        # We're going to assume there's always 1 number
        j = findfirst(r"\d{1}", modified)
        isnothing(j) && continue  # Skip if missing
        k = findfirst(r"\d{1}", reverse(modified))

        value = parse(Int, modified[j] * reverse(modified)[k])

        total += value

        # Validation
        @info "$(lpad(idx, 5)) | Input: $ln, modified: $modified, value: $value, total: $total"
    end

    return total
end

function modify_line(ln)
    all_values = (
        "sevenineight"=>"798",  # LAZY EVALUATION
        "twone"=>"21",  # LAZY EVALUATION
        "oneight"=>"18",  # LAZY EVALUATION
        "threeight"=>"38",  # LAZY EVALUATION
        "fiveight"=>"58",  # LAZY EVALUATION
        "nineight"=>"98",  # LAZY EVALUATION
        "sevenine"=>"79",  # LAZY EVALUATION
        "eightwo"=>"82",  # LAZY EVALUATION
        "eighthree"=>"83",  # LAZY EVALUATION
        "one"=>"1",
        "two"=>"2",
        "three"=>"3",
        "four"=>"4",
        "five"=>"5",
        "six"=>"6",
        "seven"=>"7",
        "eight"=>"8",
        "nine"=>"9",
    )
    return replace(ln, all_values...)
end

# Read file
data = readdlm("data\\day_1_trebuchet.txt", '\n', String);

println("Part 1: $(treb_sum(data))")  # Correct

# Part 2
# Some numbers are ALSO words, oh no ho ho! We need to also account for these as well
# We've added a lazy processing function to deal with this!

test_2 = [
    "two1nine",
    "eightwothree",
    "abcone2threexyz",
    "xtwone3four",
    "4nineeightseven2",
    "zoneight234",
    "7pqrstsixteen",
]

treb_sum(test_2, use_words=true)

println("Part 2: $(treb_sum(data, use_words=true))")