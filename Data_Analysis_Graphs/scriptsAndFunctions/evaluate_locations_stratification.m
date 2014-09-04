function [ sum_lowest_closest_distances ] = evaluate_locations_stratification( indices_input, algorithm_counts )
  % idx that will end up at the sorted position
  [ ~, algorithm_counts_sorted_idx ] = sort( algorithm_counts(:) );
  
  stratified_indices_located_at_cartesian_indices = 1:numel(algorithm_counts_sorted_idx);
  stratified_indices_located_at_cartesian_indices(algorithm_counts_sorted_idx) = stratified_indices_located_at_cartesian_indices;
  if max( indices_input(:) ) > numel( stratified_indices_located_at_cartesian_indices(:) ); keyboard; end
  stratified_indices_specified = stratified_indices_located_at_cartesian_indices( indices_input(:) );
  stratified_indices_specified = stratified_indices_specified(:);
  
  % Compute average distance
  % Compute minimum distance
  closest_distance = 10000;
  all_distances = zeros([numel( stratified_indices_specified ), 1]);
  for i = 1:numel( stratified_indices_specified )
    stratified_indices_specified_temp = stratified_indices_specified;
    stratified_indices_specified_temp(i) = [];
    pnts = repmat([stratified_indices_specified(i)],[numel(stratified_indices_specified)-1, 1]);
    err = abs( pnts - stratified_indices_specified_temp );
    [min_val,~] = min( err );
    all_distances(i) = min_val;
    if min_val == 0; keyboard; end
  end
  half_way = floor( numel( all_distances ) );
  all_distances_sorted = sort(all_distances);
  sum_lowest_closest_distances = sum(all_distances_sorted(1:half_way));
  if sum_lowest_closest_distances == 0; keyboard; end
end