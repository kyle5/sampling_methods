// main.cpp
#include <opencv2/core/core.hpp>
#include "computeAlgorithmEstimateErrorValues.h"

using namespace std;
using namespace cv;

int main() {
	cv::Mat algorithm_counts_mat = Mat::ones( 15, 15, CV_64F );
	cv::Mat groundtruth_counts_mat = Mat::ones( 15, 15, CV_64F );
	computeAlgorithmEstimateErrorValues( algorithm_counts_mat, groundtruth_counts_mat );
	return 1;
}
