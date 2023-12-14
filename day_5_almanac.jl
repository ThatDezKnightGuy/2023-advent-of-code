#= Day 5

Today we have a blocked text file that is a list of maps.

We need to take each block out and store it as a map. Each map line
has rules for the format: X Y z

- X: the destination range start
- Y: the source range start
- z: range length

so that Y to Y+z-1 maps to X to X+z-1.

Eg, in the test seed-to-soil map we have:
`50 98 2`
which maps seeds 98-99 to soils 50-51
=#
using Base.Threads

# Part 1
# We're going to need to parse this file as blocks and make some
# parser assumptions.
# Assumptions: L1 will be seeds and we can parse this into our designation map


"""
Maps the file block heads to their destination names
"""
HEADER_TO_MAP = [  # ordered header groupings
    "seed-to-soil"            => "soil",
    "soil-to-fertilizer"      => "fertilizer",
    "fertilizer-to-water"     => "water",
    "water-to-light"          => "light",
    "light-to-temperature"    => "temperature",
    "temperature-to-humidity" => "humidity",
    "humidity-to-location"    => "location",
]


"""
Parses the seeds string into a vector of numbers for later consumption
"""
function seeds_parser_part_1(str::String)
    # structure: `seeds: X Y Z...`
    !occursin(r"^seeds", str) && return Int[]
    values_str = last(split(str, ":"))
    return parse.(Int, split(values_str))
end


"""
Parses an almanac line that is NOT the seeds line and returns the current `header`,
as well as the `mappings`. The `mappings` are also implicitly updated as noted by
the `!`.

Note: Dispatching on the header being nothing would improve stability.
"""
function line_parser!(mappings::Dict{String, Dict}, curr_line::String, header)
    loc_header = header
    if isempty(curr_line)
        # we need a new header and can close the block
        loc_header = nothing
    elseif !isnothing(loc_header) #control with dispatch
        # adding a range to a block
        (dest, source, rng) = parse.(Int, split(curr_line))
        s_r = (source):(source+rng-1)
        d_r = (dest):(dest+rng-1)
        push!(mappings[loc_header], s_r => d_r)
    elseif isnothing(header)
        # start of a new block
        loc_header = string(first(split(curr_line)))
        push!(mappings, loc_header => Dict())
    end
    return mappings, loc_header
end


"""
Parses a provided filename as though it is the Elf gardener almanac. It does
not have any checks for the structure.
"""
function almanac_parser(filename::String; seeds_fn::Function=seeds_parser_part_1)
    seeds = Int[]
    mappings = Dict{String, Dict}()
    open(filename, "r") do f
        line_no = 0
        header = nothing
        while !eof(f)
            curr_line = readline(f)
            line_no += 1
            # Make this a parser function later
            if line_no == 1
                seeds = seeds_fn(curr_line)
                @debug line_no, typeof(curr_line), curr_line, seeds
            else
                # We're processing a header, a newline, or a body
                mappings, header = line_parser!(mappings, curr_line, header)
                @debug line_no, typeof(curr_line), curr_line, header
            end
        end
    end
    return seeds, mappings
end


"""
Finds all the data for a seed from the provided mappings. This uses the global
mapping to section naming, but this can be overriden if required
"""
function find_seed_data(
    seed::Int,
    mappings::Dict{String, Dict};
    header_order::Vector{Pair{String, String}}=HEADER_TO_MAP
)
    source = "seed"
    curr_value = seed
    values = Dict(
        source => curr_value
    )
    for (mapping, dest) in header_order
        pairs = mappings[mapping]
        was_mapped = false
        for (s_r, d_r) in pairs
            was_mapped && continue
            curr_value ∉ s_r && continue
            offset = curr_value - first(s_r)
            new_value = first(d_r) + offset
            values[dest] = new_value
            was_mapped = true
            @debug mapping, source, curr_value, was_mapped, dest, new_value
            curr_value = new_value
            source = dest
        end
        if !was_mapped
            values[dest] = curr_value
            source = dest
            @debug mapping, source, curr_value, was_mapped, dest, curr_value
        end
    end
    return values
end

function find_smallest_location(filename::String; seeds_fn::Function=seeds_parser_part_1)
    seeds, mappings = almanac_parser(filename; seeds_fn=seeds_fn)
    curr_min = repeat([Inf], Threads.nthreads())
    curr_idx = ones(Int, Threads.nthreads())
    printer = max(1, min(floor(Int, length(seeds)/10), 1000000))
    @debug printer

    Threads.@threads for seed in seeds
        tid = Threads.threadid()
        idx = curr_idx[tid]
        @debug "==== seed: $seed ===="
        value = find_seed_data(seed, mappings)
        loc = value["location"]
        @debug seed, loc
        curr_min[tid] = min(curr_min[tid], loc)
        if idx % printer == 0
            @info "Thread: $(tid), Total checks: $(idx), Current min: $(curr_min[tid])"
        end
        curr_idx[tid] += 1
    end
    return Int(minimum(curr_min))
end

find_smallest_location("data\\day_5_sample.txt")

find_smallest_location("data\\day_5_almanac.txt")

# Part 2
# Seeds are now ranges, paired as `A b A b...` where the range is A to A+b-1

function seeds_parser_part_2(str::String)
    # We still need all the numbers, sooooooo
    raw_seeds = seeds_parser_part_1(str)
    new_seeds = Int[]
    i = 1
    while i <= length(raw_seeds)
        start = raw_seeds[i]
        offset = raw_seeds[i+1]
        range = (start):(start+offset-1)
        append!(new_seeds, collect(range))
        i += 2
    end
    return new_seeds
end

find_smallest_location("data\\day_5_sample.txt"; seeds_fn=seeds_parser_part_2)
find_smallest_location("data\\day_5_almanac.txt"; seeds_fn=seeds_parser_part_2)