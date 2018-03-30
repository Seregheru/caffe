import numpy as np
import matplotlib.pyplot as plt
import scipy.misc as scm
import scipy.io as sio
import os
import math
import time

caffe_root = '/home/fond/caffe-segnet/'
import sys
sys.path.insert(0, caffe_root + 'python')

import caffe
model = '/home/fond/caffe-segnet/models/inference_segnet_vp/deploy.prototxt'
weights = '/home/fond/caffe-segnet/models/inference_segnet_vp/test_weights.caffemodel'
caffe.set_mode_gpu()
net = caffe.Net(model,weights,caffe.TEST)
input_shape = net.blobs['data'].data.shape

respath = '/home/fond/testvp/'
f = open("/home/fond/normals/datafinalter/trplvp2/testimq.txt","r")

for filename in f:

  print filename
  t = time.time()
  input_image = caffe.io.load_image(filename[:-7]+".jpg")
  input_image = caffe.io.resize_image(input_image,(360,480))
  input_image = input_image*255
  input_image = input_image.transpose((2,0,1))
  input_image = input_image[(2,1,0),:,:]
  input_image = np.asarray([input_image])
  input_image = np.repeat(input_image,input_shape[0],axis=0)
  out = net.forward(data=input_image)
  predicted = net.blobs['prob'].data
  output = np.squeeze(predicted[0,:,:,:])
  ind = np.argmax(output, axis=0)
  filename = filename[38:]
  scm.toimage(ind, cmin=0.0, cmax=255).save(respath+"/sem/"+filename[:-7]+".png")
  r = net.blobs['fc8'].data
  sio.savemat(respath+"/rot/"+filename[:-7]+".mat",{'output':r})
  elapsed = time.time() - t
  print elapsed

f.close()
