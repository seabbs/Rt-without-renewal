"""
The abstract root type for all pipeline types using `EpiAware`.
"""
abstract type AbstractEpiAwarePipeline end

"""
The pipeline type for the Rt pipeline with renewal including specific options
    for plotting and saving.
"""
struct RtwithoutRenewalPipeline <: AbstractEpiAwarePipeline
end
