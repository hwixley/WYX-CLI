import numpy as np
import cv2
import sys
import os

img_file = sys.argv[1]
alpha = int(sys.argv[2])

fname = os.path.splitext(img_file)[0]
arr = cv2.imread(img_file)

size = arr.shape
x = size[0]
y = size[1]

upscaled_y = np.empty((x, y*alpha, 3))

offset = 0
for col in range(y):
    for a in range(alpha):
        if offset < y*alpha:
            upscaled_y[:,offset,:] = arr[:,col,:]

            offset += 1

upscaled_x = np.empty((x*alpha, y*alpha,3))

offset = 0
for row in range(x):
    for a in range(alpha):
        if offset < x*alpha:
            upscaled_x[offset,:,:] = upscaled_y[row,:,:]

            offset += 1


cv2.imwrite(f"{fname}-{x*alpha}x{y*alpha}.png", upscaled_x)