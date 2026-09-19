# Load the assignment files here, including the selected track and any helpers.

# Locate the assignment files -
const _ROOT = @__DIR__; # assignment folder, independent of the working directory
const _PATH_TO_DATA = joinpath(_ROOT, "data"); # supplied price data

# Load feedback tools first so the checker can explain later loading errors -
include(joinpath(_ROOT, "test", "Rubric.jl"));

# Select the source directory here -
const _USE_SOLUTION = "--solution" in ARGS; # explicit local instructor option
const _PATH_TO_SRC = _USE_SOLUTION ? joinpath(_ROOT, "solution", "src") : joinpath(_ROOT, "src");
const _OUTPUT_ROOT = _USE_SOLUTION ? joinpath(_ROOT, "solution") : _ROOT; # keep solution output local
all(argument -> argument == "--solution", ARGS) || throw(ArgumentError("The only optional argument is --solution."));

# Select the track -
const _TRACK = String(strip(read(joinpath(_ROOT, "TRACK.txt"), String)));
_TRACK in ("standard", "advanced") || throw(ArgumentError("TRACK.txt must contain exactly standard or advanced."));
const _SOURCE_PATH = joinpath(_PATH_TO_SRC, titlecase(_TRACK)*".jl");

# Load the course tools used in both tracks -
using VLQuantitativeFinancePackage: build, populate, log_growth_matrix,
    RealWorldBinomialProbabilityMeasure, MyBinomialEquityPriceTree # growth rates, lattice estimates, and price trees
using Distributions: Normal, ccdf # normal distribution and probability above a cutoff
using Statistics: mean, std # sample mean and sample standard deviation
using Dates: Date, Day # read dates and check their order in each price file
using Printf: @printf # print prices and probabilities with fixed decimal places

# Load the supplied data reader and calculation helpers -
include(joinpath(_ROOT, "src", "Support.jl")); # price data, fixed inputs, and expected GBM NPV

# Load the report and public checks -
include(joinpath(_ROOT, "reports", "Finance.jl"));
include(joinpath(_ROOT, "test", "public_standard_tests.jl"));
if _TRACK == "advanced"
    include(joinpath(_ROOT, "test", "public_advanced_tests.jl"));
end
const _PUBLIC_CHECKS = _TRACK == "standard" ? standard_public_checks() : advanced_public_checks();

# Load optional student helper files -
# TODO (optional): Add include calls for your helper files here.
# Store each helper file in src/. Replace MyHelperFunctions.jl with your filename
# and uncomment the example after creating the file.
# If a helper file uses definitions from another file, load that other file first.
# include(joinpath(_ROOT, "src", "MyHelperFunctions.jl"));

# Load the selected track after its dependencies and helpers -
isfile(_SOURCE_PATH) || throw(ArgumentError("Selected source file does not exist: $(_SOURCE_PATH)"));
include(_SOURCE_PATH);
