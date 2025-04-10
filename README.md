# Fruit-fly-mitochondrial-morphology-assay [![DOI](https://zenodo.org/badge/899414042.svg)](https://doi.org/10.5281/zenodo.14435376)

![image](https://github.com/user-attachments/assets/52f1868b-0e8b-4143-8fc0-d98e2343e95c)
 
Introduction 
This Fiji macro is designed to analyze the mitochondrial morphology in germline stem cells (GSCs) of fruit flies. The goal is to analyze the complexity of the mitochondria using the green channel, while also incorporating the fusome stain in the red channel to locate GSCs. In addition to the branch analysis, the intensity and volume of mitochondria are analyzed as well in the same macro. 

# Examples
1.	Germline stem cells (GSCs) in the ovary of Drosophila.

# Description
1.	First, scan images as the following order
  A.	Mitochondria in the first channel.
  B.	Fusome in the second channel.
  C.	Nucleus staining in the third channel. 
2.	The background in the mitochondrial channel will first be automatically subtracted. 
3.	The background-subtracted mitochondrial channel will be merged with the fusomes channel for selecting GSCs in the user interface.
4.	The threshold will be automatically defined by “Yen” algorithm and users can further adjust the threshold based on the image. 
5.	The volume and intensity of mitochondria will be quantified and saved to the result folder that is generated in the same parental folder. 
6.	The skeleton plugin is then used to analyze the complexity of the mitochondria within the defined ROI.
7.	The analysis results are named as “File name_Branch summary” and “File name_MitoVolInt” in the same result folder.

#	Instruction 
1.	Install Fiji is just ImageJ.
2.	Download the IJM script and demo image. 
3.	Open the Fiji software.
4.	Drag and drop the image and IJM script to Fiji, then execute it.
5.	Manual define the cell region with selection tools in Fiji (such as the rectangular or polygon tool) according to the hint.
6.	If it is required, manually adjust the threshold value based on the image.
7.	The final results will be saved in an Excel file for further analysis.

# Tutorial
YouTube https://youtu.be/dNoRdClj64A

#	Acknowledgements
•	We thank Dr. Hwei-Jan Hsu(ICOB, AS) for offering the demo image in developing this workflow.

#	Reference
1.	Yen, Jin Y. An algorithm for finding shortest routes from all source nodes to a given destination in general networks. Quart. Appl. Math. 27 (1969/70), 526–530.
2.	Ignacio Arganda-Carreras, Rodrigo Fernandez-Gonzalez, Arrate Munoz-Barrutia, Carlos Ortiz-De-Solorzano, "3D reconstruction of histological sections: Application to mammary gland tissue", Microscopy Research and Technique, Volume 73, Issue 11, pages 1019–1029, October 2010.

