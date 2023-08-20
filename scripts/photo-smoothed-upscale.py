import numpy as np
import cv2
import sys
import os
import skimage.exposure
import time
# from skimage.exposure import match_histograms
from PIL import ImageEnhance, Image

def unsharp_mask(image, kernel_size=(5, 5), sigma=1.0, amount=1.0, threshold=0):
    """Return a sharpened version of the image, using an unsharp mask."""
    blurred = cv2.GaussianBlur(image, kernel_size, sigma)
    sharpened = float(amount + 1) * image - float(amount) * blurred
    sharpened = np.maximum(sharpened, np.zeros(sharpened.shape))
    sharpened = np.minimum(sharpened, 255 * np.ones(sharpened.shape))
    sharpened = sharpened.round().astype(np.uint8)
    if threshold > 0:
        low_contrast_mask = np.absolute(image - blurred) < threshold
        np.copyto(sharpened, image, where=low_contrast_mask)
    return sharpened


img_file = sys.argv[1]
alpha = int(sys.argv[2])
beta = int(sys.argv[3])
sig_x = int(sys.argv[4])
sig_y = int(sys.argv[5])
smoothing_iters = max(0, int(sys.argv[6]))
sharpening_iters = max(0, int(sys.argv[7]))
smoothing_iters2 = max(0, int(sys.argv[8]))

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

# diffs = np.empty((x*alpha, y*alpha,3))

def smooth_image(image, iters):
    diffs = np.empty((x*alpha, y*alpha,3))
    image_arr = image

    for i in range(iters):
        for col in range(y*alpha):
            diff = image_arr[:,col+beta,:] - image_arr[:,col,:] if col+beta < y*alpha else np.zeros((image_arr.shape[0],image_arr.shape[2]))
            for b in range(min(beta,y*alpha - col-1)):
                if b < beta:
                    # print(diff.shape)
                    # upscaled_x[:,col*alpha+a,:]
                    diffs[:,col+b,:] += image_arr[:,col+b,:] + diff*(b/beta)#*abs((a/alpha) - 0.5)

        for row in range(x*alpha):
            diff = image_arr[row+beta,:,:] - image_arr[row,:,:]  if row+beta < x*alpha else np.zeros((image_arr.shape[1],image_arr.shape[2]))
            for b in range(min(beta,x*alpha - row-1)):
                if b < beta:
                    #upscaled_x
                    diffs[row+b,:,:] += image_arr[row+b,:,:] + diff*(b/beta)#*abs((a/alpha) - 0.5)

        diffs = diffs/2

        image_arr = image_arr + (diffs*0.05)/(i+1)

    return image_arr

new_img = smooth_image(upscaled_x, smoothing_iters)

blur = cv2.GaussianBlur(new_img, (0,0), sigmaX=sig_x, sigmaY=sig_y, borderType = cv2.BORDER_DEFAULT)

# stretch so that 255 -> 255 and 127.5 -> 0
# C = A*X+B
# 255 = A*255+B
# 0 = A*127.5+B
# Thus A=2 and B=-127.5
#aa = a*2.0-255.0 does not work correctly, so use skimage
result = skimage.exposure.rescale_intensity(blur, in_range=(127.5,255), out_range=(0,255))

kernel = np.array([[-1,-1,-1], [-1,9,-1], [-1,-1,-1]])
k2 = np.array([[0,-1,0], [-1,5,-1], [0,-1,0]])
# Apply the sharpening kernel to the image using filter2D
sharpened = cv2.filter2D(result, -1, k2)
for i in range(sharpening_iters):
    sharpened = cv2.filter2D(sharpened, -1, k2)
# res = Image.fromarray(new_img.astype('uint8'), 'RGB')
# res = res.filter(ImageFilter.ModeFilter(size=alpha))
sharpened = unsharp_mask(sharpened)

sharpened = smooth_image(sharpened, smoothing_iters2)

# sharpened = match_histograms(sharpened, arr, channel_axis=2)

converter = ImageEnhance.Color(cv2.cvtColor(sharpened, cv2.COLOR_RGB2BGR) )
sharpened = converter.enhance(0.5)

# Place side-by-side and save
# result = np.hstack((matched,R))

cv2.imwrite(f"{fname}_{x*alpha}x{y*alpha}_a{alpha}_b{beta}_s-x{sig_x}_s-y{sig_y}_sm-i{smoothing_iters}_sh-i{sharpening_iters}_{time.time()}.png", sharpened) #new_img)# np.array(res))