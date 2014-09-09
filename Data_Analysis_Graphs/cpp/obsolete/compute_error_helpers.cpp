#include "compute_error_helpers.h"
#include "get_averages.h"

// temp
#include <cstdio>

using namespace std;
using namespace cv;

void meshgrid_helper(const cv::Mat &xgv, const cv::Mat &ygv, cv::Mat &X, cv::Mat &Y) {
  cv::repeat(xgv.reshape(1,1), ygv.total(), 1, X);
  cv::repeat(ygv.reshape(1,1).t(), 1, xgv.total(), Y);
}

void meshgrid(const cv::Range &xgv, const cv::Range &ygv, cv::Mat &X, cv::Mat &Y) {
  std::vector<int> t_x, t_y;
  for (int i = xgv.start; i <= xgv.end; i++) t_x.push_back(i);
  for (int i = ygv.start; i <= ygv.end; i++) t_y.push_back(i);
  meshgrid_helper( cv::Mat(t_x), cv::Mat(t_y), X, Y );
}

Mat average_cur_iteration( Mat mat_to_average, int dimension_iteration, int total_beginning_dimensions ) {
	int sz[2] = {mat_to_average.size[1], mat_to_average.size[2]};
	Mat cur_mean_errors( 2, sz, CV_64F, Scalar::all(1) );
	int total_iterations = (int) mat_to_average.size[0];
	double array_elements[ total_iterations ];
	// average over
	for( int i = 0; i < mat_to_average.size[1]; i++ ) {
		for( int j = 0; j < mat_to_average.size[2]; j++ ) {
			for (int m = 0; m < total_iterations; m++ ) {
				array_elements[m] = mat_to_average.at<double>(m, i, j );
			}
			double average_value = getAverageArray( array_elements, total_iterations );
			cur_mean_errors.at<double>( i, j ) = average_value;
		}
	}
	return cur_mean_errors;
}

vector<int> linspace( int start, int end, int step ) {
	vector<int> ret_linspace;
	for( int i = start; i <= end; i+=step ) {
		ret_linspace.push_back( i );
	}
	return ret_linspace;
}
