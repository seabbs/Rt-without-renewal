"""
PrettyPrinting functionality for AbstractModel types.

This module provides custom pretty printing for all AbstractModel types in EpiAware,
displaying them as readable tree structures that show nested model hierarchies.
"""

import PrettyPrinting: tile, literal, list_layout, pprint, Layout, quoteof
import Base: show

@doc raw"
Override the show method for AbstractModel to use PrettyPrinting for a cleaner tree display.
This provides a readable hierarchical view of model structures with nested components.
"
function Base.show(io::IO, ::MIME"text/plain", model::AbstractModel)
    pprint(io, model)
end

@doc raw"
Define the tile method for AbstractModel to create tree-like layouts.
This method recursively formats model structures showing:
- Model type name
- Field values, with special handling for nested AbstractModel instances
- Distributions are displayed with their parameters
- Collections of models are displayed as numbered lists
"
function PrettyPrinting.quoteof(model::AbstractModel)
    model_name = Symbol(_get_simple_name(typeof(model)))
    field_names = fieldnames(typeof(model))

    if isempty(field_names)
        return :($model_name())
    end

    field_exprs = []

    for field_name in field_names
        field_value = getfield(model, field_name)

        if field_value isa AbstractModel
            # Recursively handle nested models
            push!(field_exprs, Expr(:kw, field_name, quoteof(field_value)))
        elseif field_value isa AbstractVector && !isempty(field_value) &&
               field_value[1] isa AbstractModel
            # Handle vectors of models
            model_exprs = [quoteof(submodel) for submodel in field_value]
            push!(field_exprs, Expr(:kw, field_name, Expr(:vect, model_exprs...)))
        elseif field_value isa Distribution
            # Use introspection to create distribution expression
            dist_expr = _create_distribution_expr(field_value)
            push!(field_exprs, Expr(:kw, field_name, dist_expr))
        else
            # Simple values
            push!(field_exprs, Expr(:kw, field_name, field_value))
        end
    end

    return Expr(:call, model_name, field_exprs...)
end

@doc raw"
Get simplified model name without full type parameters.
"
function _get_simple_name(model_type::Type)
    type_name = string(model_type)
    # Extract just the main type name before any type parameters
    simple_name = split(type_name, '{')[1]

    # Handle module-qualified names like "DistributionsAD.TuringScalMvNormal"
    if contains(simple_name, '.')
        simple_name = split(simple_name, '.')[end]
    end

    return simple_name
end

@doc raw"
Helper function to indent all lines in a string by a given prefix.
"
function _indent_lines(text::String, indent::String)
    lines = split(text, "\n")
    return join([indent * line for line in lines], "\n")
end

@doc raw"
Get simplified distribution parameters.
"
function _get_dist_params(dist)
    # Extract key parameters for common distributions
    if hasfield(typeof(dist), :μ) && hasfield(typeof(dist), :σ)
        return "(μ=$(dist.μ), σ=$(dist.σ))"
    elseif hasfield(typeof(dist), :α) && hasfield(typeof(dist), :β)
        return "(α=$(dist.α), β=$(dist.β))"
    elseif hasfield(typeof(dist), :λ)
        return "(λ=$(dist.λ))"
    elseif hasfield(typeof(dist), :p)
        return "(p=$(dist.p))"
    else
        return "()"
    end
end

@doc raw"
Get distribution parameters as expressions for quoteof.
"
function _get_dist_params_expr(dist)
    # Extract key parameters for common distributions as keyword expressions
    params = []
    if hasfield(typeof(dist), :μ) && hasfield(typeof(dist), :σ)
        push!(params, Expr(:kw, :μ, dist.μ))
        push!(params, Expr(:kw, :σ, dist.σ))
    elseif hasfield(typeof(dist), :α) && hasfield(typeof(dist), :β)
        push!(params, Expr(:kw, :α, dist.α))
        push!(params, Expr(:kw, :β, dist.β))
    elseif hasfield(typeof(dist), :λ)
        push!(params, Expr(:kw, :λ, dist.λ))
    elseif hasfield(typeof(dist), :p)
        push!(params, Expr(:kw, :p, dist.p))
    end
    return params
end

@doc raw"
Format distributions for compact display showing type and key parameters.
"
function _format_distribution(dist)
    dist_name = _get_simple_name(typeof(dist))
    params = _get_dist_params(dist)
    return "$(dist_name)$(params)"
end

@doc raw"
Create a constructor expression for distributions using params() or special handling.
"
function _create_distribution_expr(dist)
    dist_type = typeof(dist)
    type_name = Symbol(_get_simple_name(dist_type))

    # Special handling for distributions that don't implement params()
    if occursin("Product", string(dist_type))
        return _handle_product_distribution(dist, type_name)
    end

    try
        # Use params() to get the distribution parameters generically
        dist_params = params(dist)

        if isempty(dist_params)
            return :($type_name())
        end

        # Convert parameters to positional arguments
        param_exprs = []
        for param in dist_params
            if param isa Distribution
                # Recursively handle nested distributions
                nested_expr = _create_distribution_expr(param)
                push!(param_exprs, nested_expr)
            else
                push!(param_exprs, param)
            end
        end

        return Expr(:call, type_name, param_exprs...)
    catch
        # Fallback: try to extract meaningful information from fields
        return _handle_special_distribution(dist, type_name)
    end
end

@doc raw"
Handle Product distributions specially.
"
function _handle_product_distribution(dist, type_name)
    try
        # Product distributions have a 'v' field containing the component distributions
        if hasfield(typeof(dist), :v)
            v_field = getfield(dist, :v)
            if v_field isa AbstractVector || (hasmethod(getindex, (typeof(v_field), Int)))
                # Get the first component distribution (they're usually all the same)
                component_dist = v_field[1]
                if component_dist isa Distribution
                    component_expr = _create_distribution_expr(component_dist)
                    return :($type_name($component_expr))
                end
            end
        end
    catch
        # Fallback
    end
    return :($type_name())
end

@doc raw"
Handle special distributions that don't implement params().
"
function _handle_special_distribution(dist, type_name)
    try
        field_names = fieldnames(typeof(dist))
        if !isempty(field_names)
            # Try to extract the first few meaningful fields
            field_exprs = []
            for field_name in field_names[1:min(3, length(field_names))]  # Limit to first 3 fields
                try
                    field_value = getfield(dist, field_name)
                    if field_value isa Number
                        push!(field_exprs, field_value)
                    elseif field_value isa Distribution
                        nested_expr = _create_distribution_expr(field_value)
                        push!(field_exprs, nested_expr)
                    elseif field_value isa AbstractVector && length(field_value) <= 5
                        push!(field_exprs, field_value)
                    end
                catch
                    continue
                end
            end

            if !isempty(field_exprs)
                return Expr(:call, type_name, field_exprs...)
            end
        end
    catch
        # Final fallback
    end
    return :($type_name())
end