#include "convertOpenCVMatToMatlabMat.h"

using namespace cv;
using namespace std;

string type2str(int type) {
  string r;
  uchar depth = type & CV_MAT_DEPTH_MASK;
  uchar chans = 1 + (type >> CV_CN_SHIFT);
  switch ( depth ) {
    case CV_8U:  r = "8U"; break;
    case CV_8S:  r = "8S"; break;
    case CV_16U: r = "16U"; break;
    case CV_16S: r = "16S"; break;
    case CV_32S: r = "32S"; break;
    case CV_32F: r = "32F"; break;
    case CV_64F: r = "64F"; break;
    default:     r = "User"; break;
  }
  r += "C";
  r += (chans+'0');
  return r;
}

mxArray *convertOpenCVMatToMatlabMat( Mat input_opencv_mat ) {
	// Converts to double mat
	input_opencv_mat.convertTo(input_opencv_mat, CV_64F);
	const int nchannels_out = input_opencv_mat.channels();
	const int* dims_ = input_opencv_mat.size;
	std::vector<mwSize> d_out(dims_, dims_ + input_opencv_mat.dims);
	d_out.push_back(nchannels_out);
	std::swap(d_out[0], d_out[1]);

	string opencv_mat_string = type2str( input_opencv_mat.type() );
	mxArray *pout_ = mxCreateNumericArray(d_out.size(), &d_out[0], mxDOUBLE_CLASS, mxREAL);
	std::vector<cv::Mat> channels_out;
	split(input_opencv_mat, channels_out);
	std::vector<mwSize> si_out(d_out.size(), 0);
	int type = CV_MAKETYPE(CV_64F, 1);
	for (int i = 0; i < nchannels_out; ++i)
	{
		si_out[si_out.size() - 1] = i;
		void *ptr = reinterpret_cast<void*>(
						reinterpret_cast<size_t>(
						mxGetData(pout_)) + mxGetElementSize(pout_) * mxCalcSingleSubscript(pout_, si_out.size(), &si_out[0]
						)
						);
		cv::Mat m(input_opencv_mat.dims, dims_, type, ptr);
		channels_out[i].convertTo(m, type);
	}
	return pout_;
}
