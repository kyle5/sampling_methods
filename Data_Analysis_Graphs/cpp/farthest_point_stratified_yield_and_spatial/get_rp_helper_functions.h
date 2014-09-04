// TODO:
// get the correct namespaces for each of the variables
// 

#ifndef rp_helper_new_H
#define rp_helper_new_H

#include <opencv2/core/core.hpp>
using cv::Mat;
#include <vector>
using std::vector;
#include <stdexcept>

#include <utility>
using std::pair;
#include <algorithm>
#include <signal.h>
#include <sstream>
#include <time.h>
#include <unistd.h>
#include "DT_new.h"
#include "util_new.h"

void print_opencv_matrix( cv::Mat matrix_to_print );
std::vector< double > create_spatial_distribution_new( std::vector < Circle_2_new > list_of_circles );
std::vector< Point2f > get_point_coordinates_new( unsigned npoints, unsigned *order, DT_new &dt, unsigned original_idx );
std::vector< Point2f > get_circle_coordinates_new( std::vector< Circle_2_new > list_of_circles );
std::vector< double > get_average_distance_for_possible_points_new( std::vector< bool > stratified_point_indices_b, std::vector<int> cur_stratified_circumcircle_point_indices );
std::vector<double> create_stratified_distribution_new( int length_of_spatial_samples );
std::vector<int> get_point_indices_new( cv::Mat algorithm_counts, std::vector< Point2f > cur_points );
vector<int> get_stratified_point_indices_new( cv::Mat algorithm_counts, std::vector<int> point_indices );
vector<bool> get_stratified_occupied_locations_new( vector<int> cur_stratified_indices, int total_possible_points );
void stratified_point_indices_checks( std::vector< int > stratified_point_indices, cv::Mat algorithm_counts );
cv::Mat create_opencv_imagesc_of_stratified_distances( std::vector<double> circumcircle_average_distances, std::vector<bool> stratified_point_indices_b, std::vector<double> stratified_distribution_organized_by_spatial_indices, std::vector< int > circumcircle_point_indices );

vector<int> get_all_stratified_indices( Mat valid_counts, Mat algorithm_counts );
vector < pair < double, int > > sort_and_return_indices( vector<double> input_vector );
template <class T> vector< pair< T, int > > sort_and_return_indices_specified_function( vector< T > input_array_of_elements, bool (*pt2Func)(pair<T, int>, pair<T, int>) );

double get_max_value_double( vector<double> input_vector );
double get_max_value_bool( vector<bool> input_vector );
double get_max_value_int( vector<int> input_vector );

cv::Mat imagesc_opencv( cv::Mat imagesc_stratified_mat, int row_step, int column_step );
#endif
