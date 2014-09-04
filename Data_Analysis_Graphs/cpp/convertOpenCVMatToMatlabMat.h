#include <opencv2/opencv.hpp>
#include <matrix.h>
#include <mex.h>
#include <iostream>
#include <opencv2/opencv.hpp>
#include <opencv2/core/core.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/nonfree/nonfree.hpp>
#include <opencv2/nonfree/features2d.hpp>
#include <opencv2/flann/flann.hpp>
#include <opencv2/legacy/legacy.hpp>
#include <vector>

#include <cstring>
#include <string>

std::string type2str(int type);
mxArray *convertOpenCVMatToMatlabMat( cv::Mat input_opencv_mat );
