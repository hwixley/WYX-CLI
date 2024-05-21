import numpy as np
import cv2
import sys
import os
import scipy.misc

img_file = sys.argv[1]
alpha = int(sys.argv[2])

fname = os.path.splitext(img_file)[0]
arr = cv2.imread(img_file)
compressed = cv2.resize(arr, (arr.shape[1]//alpha*2, arr.shape[0]//alpha*2), interpolation=cv2.INTER_NEAREST)

size = arr.shape
x = size[0]
y = size[1]

upscaled_y = np.empty((x, y*alpha, 3))
window_ptg = 5

offset = 0
next = None
for col in range(y):
    next = arr[:,col+1,:] if col+1 < y else None

    if next is not None:
        for a in range(alpha):
            if offset < y*alpha:
                upscaled_y[:,offset,:] = arr[:,col,:] + (next - arr[:,col,:]) * (a+1) / (alpha+1)

                offset += 1
            else:
                break
    else:
        for a in range(alpha):
            if offset < y*alpha:
                upscaled_y[:,offset,:] = arr[:,col,:]

                offset += 1
            else:
                break

upscaled_x = np.empty((x*alpha, y*alpha,3))

offset = 0
next = None
for row in range(x):
    next = upscaled_y[row+1,:,:] if row+1 < x else None

    if next is not None:
        for a in range(alpha):
            if offset < x*alpha:
                upscaled_x[offset,:,:] = upscaled_y[row,:,:] + (next - upscaled_y[row,:,:]) * (a+1) / (alpha+1)

                offset += 1
            else:
                break
    else:
        for a in range(alpha):
            if offset < x*alpha:
                upscaled_x[offset,:,:] = upscaled_y[row,:,:]

                offset += 1
            else:
                break

    # for a in range(alpha):
        # if offset < x*alpha:
        #     upscaled_x[offset,:,:] = upscaled_y[row,:,:]

        #     offset += 1


cv2.imwrite(f"{fname}-{x*alpha}x{y*alpha}.png", upscaled_x)