#include "get_rp_helper_functions.h"
#include "sampling_object.h"

#include <unistd.h>
#include <stdlib.h>     /* srand, rand */
#include <ctime>

using namespace std;
using namespace cv;

vector<int> sampling_object::get_representative_points( int points_to_obtain, vector<int> &stratified_indices, vector<int> &valid_indices, int total_points_on_grid, int rows_matrix, int cols_matrix, unsigned int rand_seed ) {
	int num_valid_indices = (int) valid_indices.size();
	srand(rand_seed);
	clock_t start;
	start = clock();

	int use_combined_approach = 0;
	vector<int> points_selected = generate_random_points( points_to_obtain, total_points_on_grid );
	vector<int> points_selected_stratified_indices(points_to_obtain, 0);
  vector<int> spatial_index_occupied_by(total_points_on_grid, 0);
	
	for ( int i = 0; i < points_to_obtain; i++ ) {
		int cur_pt_spatial_index = points_selected[i];
		spatial_index_occupied_by[cur_pt_spatial_index] = spatial_index_occupied_by[cur_pt_spatial_index] + 1;
		int cur_pt_stratified_index = 0;
		points_selected_stratified_indices[i] = cur_pt_stratified_index;
	}

	int iterations = 5;
	for ( int i = 0; i < iterations; i++ ) {
		for ( int j = 0; j < points_to_obtain; j++ ) {
			int cur_point_index = points_selected[ j ];
			spatial_index_occupied_by[cur_point_index] = spatial_index_occupied_by[cur_point_index]-1;

			//vector<int> array_of_possible_indices;
			//vector<double> array_of_spatial_distances;
			//vector<double> array_of_stratified_distances;
			int replacement_idx = -1;
			double max_distance_value = -1;
			int step_size = 1;
			for ( int k = rand() % step_size; k < num_valid_indices; k += step_size ) {
				int other_index = valid_indices[k];
				if ( spatial_index_occupied_by[other_index] == 0 ) {
					double closest_distance = compute_closest_distance( other_index, points_selected, points_to_obtain, j, rows_matrix, cols_matrix );

					// array_of_spatial_distances.push_back( closest_distance );
					if ( use_combined_approach == 1.0 ) {
					} else {
						//array_of_possible_indices.push_back( other_index );
						if ( closest_distance > max_distance_value ) {
							max_distance_value = closest_distance;
							replacement_idx = other_index;
						}
					}
				}
			}
			if (use_combined_approach == 1) {
				// vector< pair< double, int > > sorted_spatial_distances_and_indices = sort_and_return_indices( array_of_spatial_distances );
				//vector<double> combined_distribution( array_of_possible_indices.size(), 0 );
			}
			if (replacement_idx == -1) {
				throw runtime_error( "no valid replacement index was found..." );
			}
			spatial_index_occupied_by[replacement_idx] = spatial_index_occupied_by[replacement_idx] + 1;
			points_selected[ j ] = replacement_idx;
			points_selected_stratified_indices[j] = stratified_indices[replacement_idx];
		}
	}

	double duration = ( clock() - start ) / (double) CLOCKS_PER_SEC;
	fprintf( stderr, "duration: one iteration: %.2f\n", duration );
	return points_selected;
}

Mat imagesc_from_vector( vector<int> points_selected, int rows_matrix, int total_points_on_grid ) {
	Mat final_points_visualization = Mat::zeros( rows_matrix, total_points_on_grid / rows_matrix, CV_8U );
	for ( int i = 0; i < (int) points_selected.size(); i++ ) {
		int cur_pt_idx = points_selected[i];
		fprintf( stderr, "cur_pt_idx: %d\n", cur_pt_idx );
		final_points_visualization.at<uchar>(cur_pt_idx%rows_matrix, cur_pt_idx/rows_matrix) = 150 + (rand() % 100);
	}
	return final_points_visualization;
}

double compute_closest_distance( int other_index, vector<int> points, int num_points, int j, int rows_matrix, int cols_matrix ) {
	double min_distance_value = 1000000;
	for ( int i = 0; i < num_points; i++ ) {
		if ( i == j ) continue;
		int compare_index = points[i];
		double cur_distance = get_distance_between_indices( compare_index, other_index, rows_matrix, cols_matrix );
		if ( cur_distance < min_distance_value ) {
			min_distance_value = cur_distance;
		}
	}
	return min_distance_value;
}

double get_distance_between_indices( int compare_index, int other_index, int rows_matrix, int cols_matrix ) {
	int compare_row = compare_index % rows_matrix;
	int compare_col = compare_index / rows_matrix;
	int other_row = other_index % rows_matrix;
	int other_col = other_index / rows_matrix;
	double row_delta = (double) abs(compare_row - other_row);
	double col_delta = (double) abs(compare_col - other_col);
	if ( col_delta > ( (double) cols_matrix / 2 ) ) {
		col_delta = (double) cols_matrix - col_delta;
	} else if ( row_delta > ( (double) rows_matrix / 2 ) ) {
		row_delta = (double) rows_matrix - row_delta;
	}
	double distance = sqrt( pow( row_delta, 2 ) + pow( col_delta, 2 ) );
	return distance;
}

vector< int > generate_random_points( int number_of_points, int range ) {
	vector< int > random_indices( number_of_points, 0 );
	for ( int i = 0; i < number_of_points; i++ ) {
		int cur_random_index = rand() % range;
		random_indices[i] = cur_random_index;
	}
	return random_indices;
}

template vector< pair< double, int > > sort_and_return_indices<double>( vector< double > input_array_of_elements );

template <class T> vector< pair< T, int > > sort_and_return_indices( vector< T > input_array_of_elements ) {
	vector< pair< T, int > > input_array_of_elements_with_indices;
	for (int i = 0; i < (int)input_array_of_elements.size(); i++ ) {
		pair<T, int> cur_pair_to_add( input_array_of_elements[i], i );
		input_array_of_elements_with_indices.push_back( cur_pair_to_add );
	}
	sort( input_array_of_elements_with_indices.begin(), input_array_of_elements_with_indices.end() );
	return input_array_of_elements_with_indices;
}
