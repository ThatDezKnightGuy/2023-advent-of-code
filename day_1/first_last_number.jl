# Preamble
using DelimitedFiles

# We need the first and last number in the string, which can be the same.
# Fastest way would be a regex find

# Read file
data = readdlm("data\\day_1_trebuchet.txt", '\n', String);

# Let's make a quick fn

function treb_sum(data)
    total = 0

    for (idx, ln) in enumerate(data)
        # We're going to assume there's always 1 number
        j = findfirst(r"\d{1}", ln)
        k = findfirst(r"\d{1}", reverse(ln))

        value = parse(Int, ln[j] * reverse(ln)[k])

        total += value

        # Validation
        @debug "$(lpad(idx, 5)) | Input: $ln, value: $value, total: $total"
    end

    return total
end

treb_sum(data)