g++ -shared -fPIC -I .. -I/opt/ros/fuerte/include/ -Wall -frounding-math -o libget_points_stratified_and_spatial.so ../DT_new.cpp ../get_random_points_new_object_model.cpp ../get_rp_helper_functions.cpp  -I /usr/local/include/ -L /usr/local/lib/CGAL/ -l CGAL -l CGAL_Core -l gmp -L /opt/ros/fuerte/lib/ -l opencv_core -l opencv_highgui
