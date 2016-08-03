# NIA
Neuron Image Analyzer: Automated and Accurate Extraction of Neuronal Data from Low Quality Images

Version		: 	1.0
Date		:  	01/08/2016
Publisher	: 	Kilho Son (kilho.son (at) gmail (dot) com)

"THIS IS AN ACADEMIC CODE, USE AT YOUR OWN RISK"

References	:
-----------
When you use this code, please cite the following papers (formated as EndNote)

TY  - JOUR
AU  - Kim, Kwang-Min
AU  - Son, Kilho
AU  - Palmore, G. Tayhas R.
TI  - Neuron Image Analyzer: Automated and Accurate Extraction of Neuronal Data from Low Quality Images
JA  - Scientific Reports
PY  - 2015/11/23/online
VL  - 5
SP  - 17062
EP  -
PB  - The Author(s)
SN  -
UR  - http://dx.doi.org/10.1038/srep17062
L3  - 10.1038/srep17062
M3  - Article
L3  - http://www.nature.com/articles/srep17062#supplementary-information
ER  -


TY  - JOUR
TI  - Distance Regularized Level Set Evolution and Its Application to Image Segmentation
T2  - IEEE Transactions on Image Processing
SP  - 3243
EP  - 3254
AU  - C. Li
AU  - C. Xu
AU  - C. Gui
AU  - M. D. Fox
PY  - 2010
DO  - 10.1109/TIP.2010.2069690
JO  - IEEE Transactions on Image Processing
IS  - 12
SN  - 1057-7149
VO  - 19
VL  - 19
JA  - IEEE Transactions on Image Processing
Y1  - Dec. 2010
ER  - 


Contents	:
-----------
1) Part of data used for experiments
2) NIA Code on the provided data

Using the code and data :
-------------------------
1. To run FCM model, RUN main_FCM.m 
2. To run HMM model, RUN main_HMM.m

Parameter explaination :
-------------------------
There are three types of parameters
1. parameters that do not critically change the performance (ex. threRatio, ...). normally do not required to change them.
2. parameters depend on the image scale (ex. kernelSize, kernelScale ...). should be changed based on the scale of the neuron image
3. parameters related precision and recall performance (ex. threDisconnect). parameter tunning may be required for each application.
* please refer to the comments in the code for more details