function plot_optimal_sampling_indices( algorithm_counts, spatial_indices, spatial_and_yield_dist_indices, figure_title )
  % Show the original spatial and spatial/yd indices in spatial and yd spaces
  % spatial: one figure with spatial and yd locations
  [~, original_locations_in_sorted_space] = sort( algorithm_counts(:) );
  stratified_locations_in_spatial_space = 1:numel(algorithm_counts);
  stratified_locations_in_spatial_space(original_locations_in_sorted_space) = 1:numel(algorithm_counts);
  
  locations_spatial_op_in_cartesian = zeros( size(algorithm_counts) );
  locations_spatial_op_in_cartesian( spatial_indices ) = 1;

  yield_distribution_indices_spatial = stratified_locations_in_spatial_space( spatial_indices );
  locations_spatial_op_in_yield_distribution = zeros( [1, numel(algorithm_counts)] );
  locations_spatial_op_in_yield_distribution( yield_distribution_indices_spatial ) = 1;

  locations_yd_op_in_cartesian = zeros( size(algorithm_counts));
  locations_yd_op_in_cartesian( spatial_and_yield_dist_indices ) = 1;

  locations_yd_op_in_yield_distribution = zeros( [1, numel(algorithm_counts)] );
  yield_distribution_indices_yd = stratified_locations_in_spatial_space( spatial_and_yield_dist_indices );
  locations_yd_op_in_yield_distribution( yield_distribution_indices_yd ) = 1;

  figure( 'Name', figure_title );
  subplot(2, 2, 1), imagesc( locations_spatial_op_in_cartesian );
  title('Purely spatial: Cartesian');
  subplot(2, 2, 2), imagesc( locations_spatial_op_in_yield_distribution );
  title('Purely spatial: YD');
  subplot(2, 2, 3), imagesc( locations_yd_op_in_cartesian );
  title('Spatial/YD: Cartesian');
  subplot(2, 2, 4), imagesc( locations_yd_op_in_yield_distribution );
  title('Spatial/YD: YD');
end