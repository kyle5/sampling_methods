function [ stratified_indices_at_spatial_indices ] = get_mat_of_stratified_indices_at_spatial_indices( algorithm_counts )
  % 
  all_algorithm_counts = algorithm_counts(:);
  [ ~, all_indices_sorted ] = sort( all_algorithm_counts(:) );
  stratified_indices_at_spatial_indices = -1*ones(1, numel(algorithm_counts(:)));
  stratified_indices_at_spatial_indices(all_indices_sorted) = 1:numel(all_indices_sorted);
end