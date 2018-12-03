import os
import time

import cv2
import numpy as np
from PIL import Image

import environ


class CvExtractor:

    def __init__(self, image_size=(960,960)):
        self.image_size = image_size
    
    def extract_image(self, image_file, building, floor):
        """
        API entrypoint for extracting model from image.
        Takes an image file and returns a processed image
        to be mapped to front-end building model.
        """
        image = cv2.imread(image_file)
        image = cv2.resize(image, self.image_size)

        # Crop a little bit
        image = image[50:-50, 50:-50]
        
        # Detect lines
        gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        edges = cv2.Canny(gray, 50, 150, apertureSize=3)
        minLineLength = 100
        maxLineGap = 10
        lines = cv2.HoughLinesP(edges,1,np.pi/180,100,minLineLength,maxLineGap)

        # Sort array by y value - x value to get bottom left line
        sorted_lines = sorted(lines, key=lambda x: x[:,1] + x[:,3] - x[:,0], reverse=True)
        # Filter out lines that are too short
        done = False
        for line in sorted_lines:
            if done:
                break
            for x1,y1,x2,y2 in line:
                if x2-x1 < 50:
                    continue
                lowest = line
                done = True

        # Repeat for top right line
        sorted_lines = sorted(lines, key=lambda x: x[:,1] + x[:,3] - x[:,2])

        done = False
        for line in sorted_lines:
            if done:
                break
            for x1,y1,x2,y2 in line:
                if x2-x1 < 50:
                    continue
                if y2-y1 > 5:
                    continue
                highest = line
                done = True

        # Add paddings
        t = min(lowest[0][1] + 75, 960)
        b = max(highest[0][1] - 75, 0)
        r = min(highest[0][2] + 75, 960)
        l = max(lowest[0][0] - 75, 0)

        # Crop
        image = image[b:t, l:r]

        # Save
        fn = str(building) + '_' + str(floor) + '.png'
        image_dir = os.environ.get('IMAGE_DIR')
        cv2.imwrite(os.path.join(image_dir, fn), image)
        return fn


if __name__ == '__main__':
    model = CvExtractor()
    model.extract_image('../images/MooreHall_floor2.png', 'MooreHall', 2)
