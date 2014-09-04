//function [ X, Y ] = getAllXAndYValuesInExpandedImage( rows_cur_map, columns_cur_map, scaling_factor_image )

#include <opencv2/core/core.hpp>
#include <iostream>
#include <utility>

static void meshgrid(const cv::Mat &xgv, const cv::Mat &ygv, cv::Mat &X, cv::Mat &Y);
static void meshgridTest(const cv::Range &xgv, const cv::Range &ygv, cv::Mat &X, cv::Mat &Y);
std::pair< vector<int>, vector<int> > getAllXAndYValuesInExpandedImage( int rows_cur_map, int columns_cur_map, int scaling_factor_image );

static void meshgrid(const cv::Mat &xgv, const cv::Mat &ygv, cv::Mat &X, cv::Mat &Y) {
  cv::repeat(xgv.reshape(1,1), ygv.total(), 1, X);
  cv::repeat(ygv.reshape(1,1).t(), 1, xgv.total(), Y);
}

static void meshgridTest(const cv::Range &xgv, const cv::Range &ygv, cv::Mat &X, cv::Mat &Y) {
  std::vector<int> t_x, t_y;
  for (int i = xgv.start; i <= xgv.end; i++) t_x.push_back(i);
  for (int i = ygv.start; i <= ygv.end; i++) t_y.push_back(i);
  meshgrid(cv::Mat(t_x), cv::Mat(t_y), X, Y);
}

std::pair< vector<int>, vector<int> > getAllXAndYValuesInExpandedImage( int rows_cur_map, int columns_cur_map, int scaling_factor_image ) {
	int rows_cur_map_scaled = (rows_cur_map + 1) * scaling_factor_image;
	int columns_cur_map_scaled = (columns_cur_map + 1) * scaling_factor_image;
  cv::Mat X, Y;
	[X,Y] = meshgrid( cv::Range(1,rows_cur_map_scaled), cv::Range(1,columns_cur_map_scaled) );
	vector<int> X_ret;
	vector<int> Y_ret;
	for (int i = 0; i < X.rows; i++) {
		for (int j = 0; j < X.cols; j++) {
			int X_cur = X.at<int>(i, j);
			int Y_cur = Y.at<int>(i, j);
			X_ret.push_back( X_cur );
			Y_ret.push_back( Y_cur );
		}
	}
	std::pair< vector<int>, vector<int> > pair_ret = std::make_pair( X_ret, Y_ret );
	return pair_ret;
}
