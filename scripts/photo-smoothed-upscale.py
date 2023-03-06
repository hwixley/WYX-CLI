import numpy as np
import cv2
import sys
import os
import skimage.exposure
# from PIL import Image, ImageFilter


img_file = sys.argv[1]
alpha = int(sys.argv[2])

a_offset = 2

fname = os.path.splitext(img_file)[0]
arr = cv2.imread(img_file)

size = arr.shape
x = size[0]
y = size[1]

upscaled_y = np.empty((x, y*alpha, 3))

offset = 0
for col in range(y):
    next_col = upscaled_y[:,col+1,:] if col+1 < y else arr[:,col,:]
    diff = next_col - col
    for a in range(alpha):
        if offset < y*alpha:
            upscaled_y[:,offset,:] = arr[:,col,:] # + diff*(a/alpha)

            offset += 1

upscaled_x = np.empty((x*alpha, y*alpha,3))

offset = 0
for row in range(x):
    next_row = upscaled_y[row+1,:,:] if row+1 < x else upscaled_y[row,:,:]
    diff = next_row - row
    for a in range(alpha):
        if offset < x*alpha:

            upscaled_x[offset,:,:] = upscaled_y[row,:,:] # + diff*(a/alpha)

            offset += 1

diffs = np.empty((x*alpha, y*alpha,3))

for col in range(y*alpha):
    diff = upscaled_x[:,col+alpha,:] - upscaled_x[:,col,:] if col+alpha < y*alpha else np.zeros((upscaled_x.shape[0],upscaled_x.shape[2]))
    for a in range(min(alpha,y*alpha - col-1)):
        if a < alpha:
            # print(diff.shape)
            # upscaled_x[:,col*alpha+a,:]
            diffs[:,col+a,:] += upscaled_x[:,col+a,:] + diff*(a/alpha)#*abs((a/alpha) - 0.5)

for row in range(x*alpha):
    diff = upscaled_x[row+alpha,:,:] - upscaled_x[row,:,:]  if row+alpha < x*alpha else np.zeros((upscaled_x.shape[1],upscaled_x.shape[2]))
    for a in range(min(alpha,x*alpha - row-1)):
        if a < alpha:
            #upscaled_x
            diffs[row+a,:,:] += upscaled_x[row+a,:,:] + diff*(a/alpha)#*abs((a/alpha) - 0.5)

diffs = diffs/2

new_img = upscaled_x + diffs*0.1

blur = cv2.GaussianBlur(new_img, (0,0), sigmaX=8, sigmaY=8, borderType = cv2.BORDER_DEFAULT)

# stretch so that 255 -> 255 and 127.5 -> 0
# C = A*X+B
# 255 = A*255+B
# 0 = A*127.5+B
# Thus A=2 and B=-127.5
#aa = a*2.0-255.0 does not work correctly, so use skimage
result = skimage.exposure.rescale_intensity(blur, in_range=(127.5,255), out_range=(0,255))

# res = Image.fromarray(new_img.astype('uint8'), 'RGB')
# res = res.filter(ImageFilter.ModeFilter(size=alpha))

cv2.imwrite(f"{fname}-{x*alpha}x{y*alpha}.png", result) #new_img)# np.array(res))