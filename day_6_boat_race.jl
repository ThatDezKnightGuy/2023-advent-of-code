#= Day 6

We're trying to win a boat race! for each given race time and previous record
distance, we need to find the number of ways to beat that distance in that time.

For each second we don't drive, we increase speed by 1 distance per time.
So accelleration is 1d/t, making velocity increase linearly with time. There is no
loss, so this is mathematically possible to solve.

We can also argue symmetry, since crossing the halfway point of time as declining
distance returns.
      _
    /  \
--/-----\---
/        \
=#

test = [
    "Time:      7  15   30",
    "Distance:  9  40  200",
]


actual = [
    "Time:        52     94     75     94",
    "Distance:   426   1374   1279   1216",
]

function generate_pairs(dt_vect)
    times = parse.(Int, split(last(split(first(dt_vect), ":"))))
    dists = parse.(Int, split(last(split(last(dt_vect), ":"))))
    return zip(times, dists)
end


function find_total_extras(zip_dts)
    # Halve times, calculate from the middle as it's maximum
    # stop when it's below minimum
    extras = 1
    for (t, d) in zip_dts
        curr_extra = 0
        is_odd = isodd(t)
        halved = t ÷ 2
        for x in halved:-1:0
            new_d = x*(t-x)
            new_d <= d && break
            curr_extra += 1
        end
        if is_odd
            extras *= (2*curr_extra)
        else
            extras *= (2*curr_extra-1)
        end
    end
    return extras
end

x = generate_pairs(test)
find_total_extras(x)

x = generate_pairs(actual)
find_total_extras(x)


# Part 2

function generate_maximal_pair(dt_vect)
    time = parse.(Int, replace(last(split(first(dt_vect), ":")), " "=>""))
    dist = parse.(Int, replace(last(split(last(dt_vect), ":")), " "=>""))
    return [(time, dist)]
end

x = generate_maximal_pair(test)
find_total_extras(x)

x = generate_maximal_pair(actual)
find_total_extras(x)