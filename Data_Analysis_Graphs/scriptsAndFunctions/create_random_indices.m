% There are repeated indices that are being created by the below method
% ps_final_point_indices, invalid, algorithm_counts, cur_sampling_number 
function [ final_point_indices ] = create_random_indices( final_point_indices, invalid_indices, algorithm_counts, sampling_sections_needed, valid_counts )
  % make random coordinates for repeated indices
  final_point_indices_unique = unique( final_point_indices(~invalid_indices) );
  num_random_needed = numel( final_point_indices(:) ) - numel( final_point_indices_unique(:) );
  available = 1:numel(algorithm_counts);
  available(final_point_indices_unique) = [];
  mixed_indices = randperm(numel(available));
  selected = available( mixed_indices(1:num_random_needed) );
  final_point_indices = [ final_point_indices_unique(:); selected(:) ];
  max_value = max(final_point_indices);
  if numel(max_value) > 1; max_value = max_value(1); end
  if max_value > numel(algorithm_counts) || numel(unique(final_point_indices)) ~= numel(final_point_indices); keyboard; end
  extra_sections_needed = sampling_sections_needed - numel(final_point_indices);
  [ final_point_indices ] = create_additional_random_indices( algorithm_counts, final_point_indices, extra_sections_needed, valid_counts );
end