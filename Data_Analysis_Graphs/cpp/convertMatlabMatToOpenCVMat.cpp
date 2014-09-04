#include "convertMatlabMatToOpenCVMat.h"

template <typename T, typename U>
class ConstMap
{
  public:
    /// Constructor with a single key-value pair
    ConstMap(const T& key, const U& val)
    {
        m_[key] = val;
    }
    /// Consecutive insertion operator
    ConstMap<T, U>& operator()(const T& key, const U& val)
    {
        m_[key] = val;
        return *this;
    }
    /// Implicit converter to std::map
    operator std::map<T, U>() { return m_; }
    /// Lookup operator; fail if not found
    U operator [](const T& key) const
    {
        typename std::map<T,U>::const_iterator it = m_.find(key);
        if (it==m_.end())
            mexErrMsgIdAndTxt("mexopencv:error", "Value not found");
        return (*it).second;
    }
  private:
    std::map<T, U> m_;
};
const ConstMap<mxClassID, int> DepthOf = ConstMap<mxClassID, int>
    (mxDOUBLE_CLASS,   CV_64F)
    (mxSINGLE_CLASS,   CV_32F)
    (mxINT8_CLASS,     CV_8S)
    (mxUINT8_CLASS,    CV_8U)
    (mxINT16_CLASS,    CV_16S)
    (mxUINT16_CLASS,   CV_16U)
    (mxINT32_CLASS,    CV_32S)
    (mxUINT32_CLASS,   CV_32S)
    (mxLOGICAL_CLASS,  CV_8U);

const ConstMap<int,mxClassID> ClassIDOf = ConstMap<int,mxClassID>
    (CV_64F,    mxDOUBLE_CLASS)
    (CV_32F,    mxSINGLE_CLASS)
    (CV_8S,     mxINT8_CLASS)
    (CV_8U,     mxUINT8_CLASS)
    (CV_16S,    mxINT16_CLASS)
    (CV_16U,    mxUINT16_CLASS)
    (CV_32S,    mxINT32_CLASS);


cv::Mat convertMatlabMatToOpenCVMat(const mxArray* prhs,  bool transpose) 
{
  
    const mwSize * dims = mxGetDimensions(prhs);
    const mwSize ndims_ =mxGetNumberOfDimensions(prhs);

    // Create cv::Mat object.
    std::vector<int> d(dims, dims+ndims_);
    int ndims = (d.size()>2) ? d.size()-1 : d.size();
    int nchannels = (d.size()>2) ? *(d.end()-1) : 1;
    int depth = DepthOf[mxGetClassID(prhs)];
    std::swap(d[0], d[1]);
    cv::Mat mat(ndims, &d[0], CV_MAKETYPE(depth, nchannels));
    // Copy each channel.
    std::vector<cv::Mat> channels(nchannels);
    std::vector<mwSize> si(d.size(), 0); // subscript index
    int type = CV_MAKETYPE(DepthOf[mxGetClassID(prhs)], 1); // Source type
    for (int i = 0; i<nchannels; ++i)
    {
        si[d.size()-1] = i;
        void *pd = reinterpret_cast<void*>(
                reinterpret_cast<size_t>(mxGetData(prhs))+
                mxGetElementSize(prhs)*mxCalcSingleSubscript(prhs, si.size(), &si[0]));
        cv::Mat m(ndims, &d[0], type, pd);
        // Read from mxArray through m
        m.convertTo(channels[i], CV_MAKETYPE(depth, 1));
    }
    cv::merge(channels, mat);
    return (mat.dims==2 && transpose) ? cv::Mat(mat.t()) : mat;
}



