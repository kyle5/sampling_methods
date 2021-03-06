import os

class one_figure:
  def __init__( self, image1, image2 ):
    self.image1 = image1
    self.image2 = image2

class one_image:
  def __init__( self, path_to_image, caption_for_image ):
    self.path_to_image = path_to_image
    self.caption_for_image = caption_for_image

def create_figure(file):
   print r"\begin{figure}[!ht]"
   print r"\centering"
   print r"\includegraphics[width=10cm,height=10cm]{%s}" % file
   print r"\caption{File %s}" % file
   print r"\label{Serie}"
   print r"\end{figure}"

def create_figures_side_by_side( one_figure ):
   print r"\begin{figure}[!ht]"
   print r"\centering"
   print r"\begin{subfigure}[b]{0.4\textwidth}"
   print r"\includegraphics[width=\textwidth]{%s}" % one_figure.image1.path_to_image
   print r"\caption{%s}" % one_figure.image1.caption_for_image
   print r"\label{fig:gull}"
   print r"\end{subfigure}"
   print r"\begin{subfigure}[b]{0.4\textwidth}"
   print r"\includegraphics[width=\textwidth]{%s}" % one_figure.image2.path_to_image
   print r"\caption{%s}" % one_figure.image2.caption_for_image
   print r"\label{fig:mouse}"
   print r"\end{subfigure}"
   print r"\caption{Pictures of animals}"
   print r"\label{fig:animals}"
   print r"\end{figure}"

section_sampling = ""
directory = "."
extension = ".png"
files = [file for file in os.listdir(directory) if file.lower().endswith(extension)]

print r"\subsection{ Sampling: Scaling with a linear function }"
print( "\n\n" )
print r"Instead of scaling with a scalar value, a linear scaling function can be obtained by doing linear regression on the subsample data collected. With this function, sensor data can be mapped to predicted yield in a more dynamic way."
print( "\n\n" )
print r"A linear function is seen to be effective for grape datasets."
print( "\n\n" )

grape_linear_offset_figure = one_figure( one_image( "grape/PS/Petite_Syrah_Random:_Offset_Linear_Function.png", "Petite Syrah" ), one_image( "grape/Chardonnay_2013/Chardonnay_2013_Random:_Offset_Linear_Function.png", "Chardonnay" ) )
create_figures_side_by_side( grape_linear_offset_figure )
print( "\n\n" )
print r"A linear function is seen to be ineffective for apple datasets."
print( "\n\n" )
apple_linear_offset_figure = one_figure( one_image( "apple/Red_Delicious/Red_Delicious_Random:_Offset_Linear_Function.png", "Red Delicious" ), one_image( "apple/Granny_Smith/Granny_Smith_Random:_Offset_Linear_Function.png", "Granny Smith" ) )
create_figures_side_by_side( apple_linear_offset_figure )
print( "\n\n" )
print r"This suggests that there are some systematic differences between apple detection and grape detection. This is logical as the grape code includes features that the apple code does not, such as initial detection clustering."
print( "\n\n" )

conclusion_text = "This document summarizes results found between July and August 2014, with regards to sampling methods in orchards and vineyards. This includes an analysis of sampling methods that revolve around a scaling factor: random, stratified random, and spatial. In addition, this also includes an analysis of pure groundtruth extrapolation and the usage of a linear function instead of a scaling factor.\n\nThe main takeaway conclusion from these results is different for apple and grape datasets.\n\nFor grape datasets, stratified and spatial sampling approaches does not improve performance. In fact, both led to a decrease in performance. Improvements, instead came from either using a linear function for scaling sensor data or directly extrapolating sensor data. In fact, directly extrapolating the groundtruth subsample yields similar accuracy as using a linear scaling function and any sampling method (stratified, spatial, random) for all 3 datasets. The message from these results is that 1.) a linear scaling function is necessary and 2.) the sensor data is not adding much signal currently.\n\nFor apple datasets, stratified and spatial sampling lead to small increases in performance that are marginal. A linear scaling function or direct extrapolation of groundtruth measurements did not lead to performance increases."

print r"\section{ Conclusion }"
print( conclusion_text )
