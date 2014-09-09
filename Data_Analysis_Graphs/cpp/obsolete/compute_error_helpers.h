#ifndef __COMPUTE_ERROR_HELPERS_H__
#define __COMPUTE_ERROR_HELPERS_H__

#include <opencv2/core/core.hpp>
#include <vector>

void meshgrid_helper(const cv::Mat &xgv, const cv::Mat &ygv, cv::Mat &X, cv::Mat &Y);
void meshgrid(const cv::Range &xgv, const cv::Range &ygv, cv::Mat &X, cv::Mat &Y);
cv::Mat average_cur_iteration( cv::Mat mat_to_average, int dimension_iteration, int total_beginning_dimensions );
std::vector<int> linspace( int start, int end, int step );


#endif
