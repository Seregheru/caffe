import numpy as np
import matplotlib.pyplot as plt
import scipy.misc as scm
import scipy.io as sio
import os
import math

caffe_root = '/home/fond/caffe-segnet-clean/'
import sys
sys.path.insert(0, caffe_root + 'python')

import caffe

print("vp only")
model = '/home/fond/caffe-segnet/models/segnet_vp_only/segnet_trainq.prototxt';
weights = '/home/fond/caffe-segnet/models/segnet_vp_only/segnetvpq_iter_30000.caffemodel';
caffe.set_mode_gpu()
net_vp = caffe.Net(model,weights,caffe.TEST)

vp_params = []
#'conv1_1','conv1_2','conv2_1','conv2_2','conv3_1','conv3_2','conv3_3','conv4_1','conv4_2','conv4_3','conv5_1','conv5_2','conv5_3','fc6','fc7','fc8']
for pr in net_vp.params:
  vp_params.append(pr)

vp_params = ['fc6','fc7','fc8']
net_vp_params = {pr: (net_vp.params[pr][0].data,net_vp.params[pr][1].data) for pr in vp_params}

for fc in vp_params:
  print '{} weights are {} dimensional and biases are {} dimensional'.format(fc,net_vp_params[fc][0].shape,net_vp_params[fc][1].shape)

print("planes only")
model = '/home/fond/caffe-segnet/models/segnet_planes_only/segnet_train.prototxt';
weights = '/home/fond/caffe-segnet/models/segnet_planes_only/segnetplanes_mix_iter_30000.caffemodel';
caffe.set_mode_gpu()
net_planes = caffe.Net(model,weights,caffe.TEST)

planes_params = []
#['conv1_1_D_t','conv1_2_D','conv2_1_D','conv2_2_D','conv3_1_D','conv3_2_D','conv3_3_D','conv4_1_D','conv4_2_D','conv4_3_D','conv5_1_D','conv5_2_D','conv5_3_D','conv1_2_D_bn','conv2_1_D_bn','conv2_2_D_bn','conv3_1_D_bn','conv3_2_D_bn','conv3_3_D_bn','conv4_1_D_bn','conv4_2_D_bn','conv4_3_D_bn','conv5_1_D_bn','conv5_2_D_bn','conv5_3_D_bn']
for pr in net_planes.params:
  planes_params.append(pr)
net_planes_params = {pr: (net_planes.params[pr][0].data,net_planes.params[pr][1].data) for pr in planes_params}

for fc in planes_params:
  print '{} weights are {} dimensional and biases are {} dimensional'.format(fc,net_planes_params[fc][0].shape,net_planes_params[fc][1].shape)

print("vp + planes")
model = '/home/fond/caffe-segnet/models/segnet_vp/segnet_train.prototxt';
weights = '/home/fond/caffe-segnet/models/segnet_vp/segnetplanes_fine_iter_30000.caffemodel';
caffe.set_mode_gpu()
net = caffe.Net(model,weights,caffe.TEST)

params = [] 
#['conv1_1','conv1_2','conv2_1','conv2_2','conv3_1','conv3_2','conv3_3','conv4_1','conv4_2','conv4_3','conv5_1','conv5_2','conv5_3','f6','f7','f8','conv1_1_D_t','conv1_2_D','conv2_1_D','conv2_2_D','conv3_1_D','conv3_2_D','conv3_3_D','conv4_1_D','conv4_2_D','conv4_3_D','conv5_1_D','conv5_2_D','conv5_3_D']
for pr in net.params:
  params.append(pr)
net_params = {pr: (net.params[pr][0].data,net.params[pr][1].data) for pr in params}

for pr in vp_params:
  net_params[pr][0][...] = net_vp_params[pr][0]
  net_params[pr][1][...] = net_vp_params[pr][1]

for pr in planes_params:
  net_params[pr][0][...] = net_planes_params[pr][0]
  net_params[pr][1][...] = net_planes_params[pr][1]

net.save('/home/fond/caffe-segnet/models/segnet_vp/netsurgery.caffemodel')
