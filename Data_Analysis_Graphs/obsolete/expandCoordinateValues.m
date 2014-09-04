function [ expanded_x, expanded_y ] = expandCoordinateValues( not_expanded_x, not_expanded_y, scaling_factor_to_apply_to_image )
    expanded_x = not_expanded_x .* scaling_factor_to_apply_to_image;
    expanded_y = not_expanded_y .* scaling_factor_to_apply_to_image;
end