function [closest_distance_first_half_avg] = evaluate_locations_spatially( indices_input, algorithm_counts )
  %
  [rounded_y, rounded_x] = ind2sub( size(algorithm_counts), indices_input );
  all_pts = [rounded_x(:)'; rounded_y(:)'];
  all_closest_distances = zeros([length(rounded_x),1]);
  
  for(j=1:length(rounded_x))
    locations_cur = all_pts;
    locations_cur(:, j) = [];
    pnts = repmat([rounded_x(j); rounded_y(j)],[1, size(locations_cur, 2)]);
    err = pnts-locations_cur;
    [min_val,~] = min(sum(err.*err).^.5);
    all_closest_distances(j) = min_val;
    if min_val == 0; keyboard; end
  end
  half_way_idx = floor( length( all_closest_distances ) );
  all_closest_distances_sorted = sort( all_closest_distances );
  closest_distance_first_half_avg = sum( all_closest_distances_sorted( 1:half_way_idx ) );
end