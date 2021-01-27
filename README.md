# segmentation
Segmentation of a handwritten document image into its basic entities, namely sentences, words and character by watershed algorithm in matlab.

# Introduction
The novelty of the proposed approach is detection of the text line of a sentence and subsequent segmentation using watershed algorithm. The process of segmenting the basic entities of a handwritten document has various applications in Optical Character Recognition, Text- Independent/Dependent author recognition, Signature verification etc.

# Preprocessing of input handwritten document image
A. Noise removal and filtering/
The typical type of noise whose effect is dominant in images is salt and pepper noise.
B. Scaling and binarisation/
The images are converted to gray scale and to their equivalent binary image using otsus thresholding algorithm.

# Sentence Segmentation Algorithm
1 Use the pre-processed image as input.\
2 Extract the contour of every entity throughout the image.\
3 Get the average location of vertical coordinates for each detected contour. Track these vertical coordinates with a segment gradually extending from left portion to the right, programmatically, while intersecting the subsequent contours in a sentence.\
4 Apply watershed algorithm and obtain the boundaries covering each and every sentence in the image.\
5 Extract sentences by determining the extremities of every region marked watershed algorithm.\
6 Cover the unwanted content, mainly the parts adjacent sentences, in the image obtained from step 6. The image pixels can be overwritten with the dominant background colour of the page.

# Word Segmentation Algorithm
1 Blur the obtained sentence enough such that the words in it are converted into blobs of black pixels.\
2 Apply watershed algorithm over the above processed sentence to get the boundaries of separation for each and every blob. (Here single blob corresponds to single word).\
3 Use the above image containing boundaries to identify the regions in the original image which are to be segmented.\
4 Segment the image based on the extremities of the marked region around each word.

# Character Segmentation Algorithm
1 Find external contours of the word image.\
2 Choose a contour and detect the extremities of it in both ‘x’ and ‘y’ direction.\
3 Crop the image matrix within these extremities. Figure 4.13 demonstrates the intermediate output.\
4 Find external contour of the cropped image.\
5 The character to be segmented will have the longest contour. Hence, suppress the region covered by smaller contours. This gives the final segmented character.\
6 Repeat steps 2 to 5 for all the contours detected in step 1 to get all the characters segmented.

# Changes to make
Run Document Segmentation matlab code to get output stored in subfolders named sentence,word and character.
Change the path to input image in Document_Segmentation.m


