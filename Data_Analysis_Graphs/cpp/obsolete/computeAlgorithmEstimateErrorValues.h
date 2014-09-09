
#ifndef __COMPUTE_ALGORITHM_ESTIMATE_ERROR_VALUES_H__
#define __COMPUTE_ALGORITHM_ESTIMATE_ERROR_VALUES_H__

#include <cstdlib>
#include <cstdio>
#include <vector>
#include <ctime>
#include <map>
#include <stdexcept>
#include <string>

#include <opencv2/core/core.hpp>

std::pair<cv::Mat, cv::Mat> computeAlgorithmEstimateErrorValues( cv::Mat algorithm_counts_mat, cv::Mat groundtruth_counts_mat, int row_data_dimension );

#endif
