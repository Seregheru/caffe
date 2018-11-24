Data:

![dataplanes](images/dataplanes.png)
![datavp](images/datavp.png)

Training process of ManhattanNet:

1st stage: train Manhattan planes segmentation only
![planesonly](images/network_seg.png)

2nt stage: train Manhattan vanishing points regression only
![vponly](images/network_reg.png)

3rd stage: train jointly Manhattan segmentation regression
![vpplanes](images/network.png)

Results:

![results](images/results.png)

More details available in the first section of my thesis (https://tel.archives-ouvertes.fr/tel-01789709/document) ... unfortunatly in French only
