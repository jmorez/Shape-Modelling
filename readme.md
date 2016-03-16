# Shape Modelling: Pointcloud Registration
## In short
This is a set of (mostly) MATLAB-scripts that involve:    


* Surface registration    
* Import/Export to and from .obj  
* Visualization   

of pointclouds that were gathered for the [bSlim](http://www.iminds.be/en/projects/2014/03/20/b-slim) project. The point clouds are 8 scans of a person standing on a rotating platform. These point clouds have partial overlap and often missing regions. Because they are also roughly rotated along the z-axis at an angle of 45 degrees, and they also move during the scan, naive application of Iterative-Closest Point will not succeed at all. Preprocessing is thus required. 

## How to use it 
The main script is `import_center_register_export_batch.m`. You have to adjust 
`base_dir` as the main directory, the subdirectories (stored in `input_dirs`)
contain 8 .obj files each, with names denoting the order of the scans (`001.obj`,`002.obj,` etc.). Note that `importObj()` is not universal/adhering to the .obj standard. It will
most likely only be able to parse .obj files of the form (`...` denoting an elipsis):  

```
material.mtl    
v 2.5 6.123 -4.345   
v -3.5 2.16732 8.675
...   
vt 0.324 0.675    
...   
vn -0.5243 0.76746 0.12312   
...   
f 1534/1534/1534 3453/3453/3453 87676/87676/87676 9078/9078/9078   
```

A much slower and slightly more robust `importObj_old` function in pure MATLAB is also supplied, although it is a factor of 5 times slower than the mex-version. 

## Explanation of the algorithm
The algorithm will assume that the first two scans will register successfully after substracting the center-of-mass vector and a rough  45 degrees rotation and point-to plane ICP. If so, it will then find matching point pairs between the registered scans using K-nearest neighbours. Given these point pairs and the assumption that the rotation is about the z-axis, it can apply some vector-algebra to find an estimate for the true rotation center. After finding the true rotation center, the algorithm will apply the total transformation of the first two scans to the rest. After all, the person stands on a rotating platfor, so in theory the transform between each two scans should be identical. This is not entirely the case, but it allows for ICP to find the correct registration. Afterwards, the pointclouds are exported to a rudimentary .obj file. 
## Credits 
I am indebted to the following Mathworks file exchange people:
* [Jakob Wilm (ICP)](http://www.mathworks.com/matlabcentral/fileexchange/27804-iterative-closest-point)
* [Corey (rdir)](http://www.mathworks.com/matlabcentral/fileexchange/47125-rdir-m)

Also Stack Exchange and Google...
