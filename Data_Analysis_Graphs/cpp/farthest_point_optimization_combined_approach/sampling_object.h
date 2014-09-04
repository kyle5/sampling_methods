#ifndef sampling_object_H
#define sampling_object_H

#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
using cv::Mat;
#include <vector>
using std::vector;
#include <stdexcept>
#include <algorithm>
#include <signal.h>
#include <sstream>
#include <time.h>
#include <unistd.h>

class sampling_object {
	public:
		vector<int> get_representative_points( int points_to_obtain, vector<int> &stratified_indices, vector<int> &valid_indices, int total_points_on_grid, int rows_matrix, int cols_matrix, unsigned int rand_seed );
};

Mat imagesc_from_vector( vector<int> points_selected, int rows_matrix, int total_points_on_grid );
double compute_closest_distance( int other_index, vector<int> points, int num_points, int j, int rows_matrix, int cols_matrix );
double get_distance_between_indices( int compare_index, int other_index, int rows_matrix, int cols_matrix );
vector< int > generate_random_points( int number_of_points, int range );
template <class T> vector< pair< T, int > > sort_and_return_indices( vector< T > input_array_of_elements );

#endif
