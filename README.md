# SPOT
MATLAB scripts for Spectrum and Polarization Optical Tomography (SPOT) technique.

The function of the code is to obtain the optical sectioning images of multiple excitation channels and multiple emission channels (up to four), and solve their polarization information (including the polarization orientation and modulation depth of the fluorescent dipole).

The details of the SPOT can be found online (Karl Zhanghao, Wenhui Liu, Meiqi Li et al.). The number of excitation channels and emission channels should be determined according to individual need. Images of defferent emission channels are simutaneously projected to different positions of the camera, while images of different excitation channels need to be collected sequentially. For each excitation channel, three groups of raw images are acquired with three polarization modulation. Each group contains two images with a phase shift of π for SPOT or five images with a phase shift of 2π/5 for SPOT-SIM3D.
