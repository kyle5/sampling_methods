// includes

// standard
#include <vector>
#include <ctime>
#include <cstdlib>
#include <cstdio>
#include <stdexcept>

// opencv
#include <opencv2/core/core.hpp>

std::vector< std::vector< int > > create_adjusted_indices( cv::Mat mat_of_size_field_data, cv::Mat original_optimal_indices, int num_adjusted_indices, double distance_to_alter_indices, double percentage_of_indices_to_alter, int count_variable );
std::vector < int > adjust_indices_one_iteration( cv::Mat mat_of_size_field_data, cv::Mat original_optimal_indices, double distance_to_alter_indices, double percentage_of_indices_to_alter );
void setup_indices_boolean( cv::Mat &indices_occupied, const cv::Mat &original_optimal_indices );
std::vector<int> myFindNonZero( cv::Mat indices_occupied );
