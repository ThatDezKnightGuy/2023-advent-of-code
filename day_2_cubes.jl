# Day 2
# We're trying to identify false games and sum to total of all valid game ids
# 12 red cubes, 13 green cubes, and 14 blue cubes

# Preamble
using DelimitedFiles

#=
Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
=#

# We should use some sort of struct that lets us monitor valid/invalid
# A game has two properties: ID, vector of reveals. We assume a game has at least 1 reveal
# A reveal has three peroperties: red, green, blue. A missing value is a default of zero

# Structs for managing the comparisons
struct Reveal
    red::Int
    green::Int
    blue::Int
end

struct Game
    id::Int
    reveals::Vector{Reveal}
end

# Constructors for the known data
function Game(str::String)
    vals = split(str, ": ")
    id = parse(Int, split(vals[1])[end])  # lazy

    reveals = Reveal(string(vals[2]))
    return Game(id, reveals)
end

function Reveal(str::String)
    val = Reveal[]
    data = split(str, "; ")  # lazy
    for d in data
        r = 0
        b = 0
        g = 0
        x = split(string(d), ", ")
        for y in x
            z = split(y, " ")
            if z[2] == "red"
                r = parse(Int, z[1])  # lazy
            elseif z[2] == "green"
                g = parse(Int, z[1])  # lazy
            elseif z[2] == "blue"
                b = parse(Int, z[1])  # lazy
            end
        end
        push!(val, Reveal(r, g, b))
    end
    return val
end

# Validity functions
function is_game_valid(game::Game, target::Reveal)
    for rev in game.reveals
        if !is_reveal_valid(rev, target)
            return false
        end
    end
    return true
end

function is_reveal_valid(r::Reveal, t::Reveal)
    return r.red <= t.red && r.green <= t.green && r.blue <= t.blue
end

# Other functions
red(r::Reveal) = r.red
green(r::Reveal) = r.green
blue(r::Reveal) = r.blue

reveal_power(r::Reveal) = r.red * r.green * r.blue

function minimum_reveal_cubes(v_r::Vector{Reveal})
    return Reveal(
        maximum(red.(v_r)),
        maximum(green.(v_r)),
        maximum(blue.(v_r)),
    )
end

# Game total generation
function generate_games_total(data)
    total = 0
    for t in data
        g = Game(t)
        is_valid = is_game_valid(g, target)
        if is_valid
            total += g.id
        end
        @info("$(lpad(g.id, 4)) valid: $(is_valid), total: $total")
    end
    return total
end

function generate_games_power(data)
    total = 0
    for t in data
        g = Game(t)
        min = minimum_reveal_cubes(g.reveals)
        power = reveal_power(min)
        total += power
        @info("$(lpad(g.id, 4)) power: $power, total: $total")
    end
    return total
end

test = [
    "Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green",
    "Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue",
    "Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red",
    "Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red",
    "Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green",
]

data = readdlm("data\\day_2_cubes.txt", '\n', String);
target = Reveal(12, 13, 14)

generate_games_total(data)
generate_games_power(data)