# Run with the PS2 project. Pass the source JLD2 file and destination CSV path.
# If the destination is omitted, write data/AAPL-2025.csv.
import VLQuantitativeFinancePackage # access the package's JLD2 reader
using Dates: Date, Day # write daily dates and check their order
using SHA: sha256 # identify the exact source file

"""
    extract_prices(source::String, destination::String) -> Nothing

Copy AAPL's daily volume-weighted average prices from a course JLD2 file.

### Arguments

- `source`: Path to a course JLD2 file with AAPL in its `dataset` dictionary.
- `destination`: Path for the CSV file with `date,ticker,price` columns.

### Returns

`nothing`. Writes the CSV without changing the source order or price values.
Prints the source SHA-256 value, date range, and row count.

### Errors

Missing files or columns raise read errors. An empty history, dates out of
order, or a nonfinite or nonpositive price fails an assertion.
"""
function extract_prices(source::String, destination::String)::Nothing
    data = VLQuantitativeFinancePackage.JLD2.load(source)["dataset"]["AAPL"];
    @assert size(data, 1) > 0;
    @assert all(x -> isfinite(x) && x > 0, data.volume_weighted_average_price);
    @assert all(diff(Date.(data.timestamp)) .> Day(0));
    open(destination, "w") do io
        println(io, "date,ticker,price");
        for row in eachrow(data)
            println(io, Date(row.timestamp), ",AAPL,", row.volume_weighted_average_price);
        end
    end
    println("Source SHA-256: ", bytes2hex(open(sha256, source)));
    println("Rows: ", size(data, 1));
    println("Dates: ", Date(first(data.timestamp)), " to ", Date(last(data.timestamp)));
    return nothing;
end

length(ARGS) in (1, 2) || throw(ArgumentError("Pass a source JLD2 path and an optional destination CSV path."));
destination = length(ARGS) == 2 ? ARGS[2] : joinpath(@__DIR__, "..", "data", "AAPL-2025.csv");
extract_prices(ARGS[1], destination);
