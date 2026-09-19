# The checker loads this file before it loads your selected track.
# Keep all include calls for your helper files here.

# Load the course tools used in both tracks -
using VLQuantitativeFinancePackage: build, populate, log_growth_matrix,
    RealWorldBinomialProbabilityMeasure, MyBinomialEquityPriceTree # growth rates, lattice estimates, and price trees
using Distributions: Normal, ccdf # normal distribution and probability above a cutoff
using Statistics: mean, std # sample mean and sample standard deviation
using Dates: Date, Day # read dates and check their order in each price file
using Printf: @printf # print prices and probabilities with fixed decimal places

# Locate the assignment files -
# @__DIR__ is the folder containing Include.jl. Paths built from this folder
# work even when you run the checker from a different working directory.
const _ROOT = @__DIR__; # assignment folder
const _PATH_TO_DATA = joinpath(_ROOT, "data"); # folder holding the supplied price data

# Load the supplied data reader and calculation helpers -
include(joinpath(_ROOT, "src", "Support.jl")); # price data, fixed inputs, and expected GBM NPV

# Load optional student helper files -
# TODO (optional): Add include calls for your helper files here.
# Store each helper file in src/. Replace MyHelperFunctions.jl with your filename
# and uncomment the example after creating the file.
# If a helper file uses definitions from another file, load that other file first.
# include(joinpath(_ROOT, "src", "MyHelperFunctions.jl"));
