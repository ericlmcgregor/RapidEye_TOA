# Radiometric Calibration for RapidEye Analytic product
This script takes a directory containing RE imagery and metadata json files as input. It iterates through each metadata file, opening the associated multiband image, and processing it to TOA reflectance. A new multiband image containing TOA data is output.
1) Converts raw DNs to at-sensor radiance (DN*radiometric scale factor). 
2) Then processes each band to Top-Of-Atmosphere reflectance based on parameters found in RapidEye product documentation. https://assets.planet.com/docs/1601.RapidEye.Image.Product.Specs_Jan16_V6.1_ENG.pdf

