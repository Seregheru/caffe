from PIL import Image
import numpy as np
classes = [0,0,0,0]
count = [0,0,0,0]
path = "/home/fond/caffe-segnet/data/facadeparsing/labels"
h = range(360)
w = range(480)

f = open("/home/fond/normals/datafinalter/trplvp2/trainq.txt","r")
paths = []
for line in f:
  s = line.split(" ")
  print s[1]
  paths.append(s[1][:-1])
f.close()

for p in paths:
    print p
    im = np.asarray(Image.open(p))
    tmpclasses = list(classes)
    for i in h:
        for j in w:
            classes[im[i][j]] = classes[im[i][j]]+1
    for k in range(4):
        if tmpclasses[k]<classes[k]:
            count[k] = count[k]+1

print classes
print count

fclasses = [float(classes[i])/(count[i]*360*480) for i in range(4)]
mfclasses = np.median(np.asarray(fclasses))
wfclasses = [mfclasses/float(x) for x in fclasses]

print wfclasses

#[1.7502623178987287, 0.76615927059512368, 1.1202648645720916, 0.87973513542790838]
#[0.57134292944188303, 1.3052116425129694, 0.89264604436377704, 1.1367057648704619]
