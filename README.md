# MCM 2015 problem A: Erdicating data

Declaration
------------
> 
Date		: 2015 / 02 / 09
> 
Author		: WU Tongshuang (HKUST, reach at: twuac@ust.hk)
            Sun Guanhao	(HKUST)
            Zhang Pengfei	(HKUST)

Background
------------
The world medical association has announced that their new medication could stop Ebola and cure patients whose disease is not advanced. Build a realistic, sensible, and useful model that considers not only thespread of the disease, the quantity of the medicine needed, possible feasible delivery systems (sending the medicine to where it is needed),(geographical) locations of delivery, speed of manufacturing of the vaccine or drug, but also any other critical factors your team considers necessary as part of the model to optimize the eradication of Ebola, or at least its current strain. In addition to your modeling approach for the contest, prepare a 1-2 page non-technical letter for the world medical association to use in their announcement.

Instruction
------------
This repo is the open source file for HICD Model: Eradication of Ebola in Ten Days. Please refer to the report for the complete model. /matlabImplementation/ has the full implementation, with /data/ includes processed data used, and /function/ for all the member functions. Please refer to the source code files accordingly for their detailed explanation, input and output.

Two transportation sub-models, MDD and SOD, are designed for different transportation assumption. To test them, please: 
> 
	- set the values needed in genVariables.m, 
> 
	- run mainFunc_SSD.m or mainFunc_MDD.m, w.r.t your interest.

