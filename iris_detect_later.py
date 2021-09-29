# -*- coding: UTF-8
#default python
######necessary module
import sys,os,glob,cv2
import numpy as np

def getPos(lms,side,sideLms):
	leftPoint=lms[sideLms[side][0]].split('\t')
	lpPos=[int(leftPoint[0]),int(leftPoint[1])]
	rightPoint=lms[sideLms[side][1]].split('\t')
	rpPos=[int(rightPoint[0]),int(rightPoint[1])]
	return([lpPos,rpPos])

def getColor(picName,picPath,hsvPath,locPath,lmPath):
	hsvFile=hsvPath+picName.replace('PNG','hsv.txt')
	locFile=locPath+picName.replace('PNG','loc.PNG')
	##get landmarks for detail location
	lmFile=lmPath+picName[0:picName.find('.')]+'.landmarks.txt'
	lms=open(lmFile).read().split('\n')
	side=picName[(picName.find('_')+1):picName.find('.PNG')]
	sideLms = {'left':np.array([37,40])-1,'right':np.array([43,46])-1};
	lpPos,rpPos=getPos(lms,side,sideLms)
	##
	jumpRatio=0.4  #0.3
	length=rpPos[0]-lpPos[0]
	gap=int(length*jumpRatio)
	##read picture
	picFile=picPath+picName
	img0 = cv2.imread(picFile)
	[h,w,color]=img0.shape;#rect=(int(w*0.25),0,int(w*0.5),h)
	#img=img[rect[1]:rect[1]+rect[3],rect[0]:rect[0]+rect[2]]
	img=img0[:,gap:w-gap]
	#i=1
	#cv2.imshow(str(i), img)
	##bring gray to 0-255
	img_gray = cv2.cvtColor(img,cv2.COLOR_BGR2GRAY)
	img_gray0=img_gray.copy()
	#mid=np.mean(img_gray)
	mid=np.percentile(img_gray,50)
	ret, closed = cv2.threshold(img_gray,mid,255,cv2.THRESH_BINARY_INV)
	##for removing pupil
	pupil=np.percentile(img_gray,10)
	ret, closed2 = cv2.threshold(img_gray,pupil,255,cv2.THRESH_BINARY_INV)
	#cv2.imshow(str(0),closed2)
	binary0=closed
	##fill middle
	kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (8, 8))
	closed = cv2.morphologyEx(closed, cv2.MORPH_CLOSE, kernel)
	# perform a series of erosions and dilations
	closed = cv2.erode(closed, None, iterations=1)
	closed = cv2.dilate(closed, None, iterations=1)
	##
	#contours, hierarchy = cv2.findContours(closed,cv2.RETR_TREE,cv2.CHAIN_APPROX_SIMPLE)  
	#cv2.imshow("binary2", closed)
	#####
	canny = cv2.Canny(closed, 254, 254)
	canny = np.uint8(np.absolute(canny))
	##search edges##
	[h,w,color]=img.shape;
	#yCenter=int(round(w/2))
	##split to 3 parts
	sideLmsIn={'left':np.array([38,41])-1,'right':np.array([44,47])-1};
	lpPos2,rpPos2=getPos(lms,side,sideLms)
	yCenter=int((rpPos2[0]+lpPos2[0])/2-lpPos[0]+0.3*length-jumpRatio*length)
	hdratio = 0.2# if w/h>1.75 else 0.25
	huratio=0.2
	xBottom=int(round(h*(1-hdratio)))
	xUp=int(round(h*huratio))
	##get iris edge: find first meet x left and right
	edgeL=[];edgeR=[]
	for x in range(xBottom,xUp,-1):
		for y in range(yCenter,1,-1):
			if canny[x,y]==0 and canny[x,y-1]==255:
				edgeL.append([x,y])
				img_gray[x,y]=255
				break
		for y in range(yCenter,int(w)-1):
			if canny[x,y-1]==0 and canny[x,y]==255:
				edgeR.append([x,y])
				img_gray[x,y]=255
				break
	#display two images in a figure
	#j=0;j=j+1;
	#cv2.imshow(str(j), np.hstack([img_gray,canny]))
	
	###filter jump too much edge point
	#gapInBoth=2;gapInOr=6;
	#i=0
	###filter edgeL
	#while i<len(edgeL)-1:
	#	xGap=abs(edgeL[i][0]-edgeL[i+1][0]);yGap=abs(edgeL[i][1]-edgeL[i+1][1])
	#	#print(str(xGap)+','+str(yGap))
	#	if (xGap>gapInBoth and yGap>gapInBoth) or (xGap>gapInOr or yGap>gapInOr):
	#		img_gray[edgeL[i+1][0],edgeL[i+1][1]]=0
	#		edgeL.pop(i+1)
	#		#print(i)
	#		i=i-1
	#	i=i+1
	##filter edgeR
	#i=0
	#while i<len(edgeR)-1:
	#	xGap=abs(edgeR[i][0]-edgeR[i+1][0]);yGap=abs(edgeR[i+1][1]-edgeR[i][1])
	#	#print(str(xGap)+','+str(yGap))
	#	if xGap>gapIn or yGap>gapIn:
	#		img_gray[edgeR[i+1][0],edgeR[i+1][1]]=0
	#		edgeR.pop(i+1)
	#		#print(i)
	#		i=i-1
	#	i=i+1
	#j=j+1
	#cv2.imshow(str(j), np.hstack([img_gray,canny]))
	#tmp=np.hstack((binary0, closed))
	#cv2.imshow(str(i), tmp)
	###circle fit
	##get new yCenter by edgeL and edgeR
	##same x, get pair y
	eLdic={edgeL[i][0]:edgeL[i][1] for i in range(0,len(edgeL))}
	eRdic={edgeR[i][0]:edgeR[i][1] for i in range(0,len(edgeR))}
	edgePair=[[eLdic[key],eRdic[key]] for key in list(set(eLdic.keys()).intersection(set(eRdic.keys())))]
	yCenter=np.array(edgePair).mean()
	##circle fit along ycenter by edges
	edges=edgeL;edges.extend(edgeR);edges=np.array(edges)
	topRatio=0.33;downRatio=0.66;
	#topRatio=0.4;downRatio=0.6;
	xUp=int(h*topRatio);xDown=int(h*downRatio);
	dists=[]
	for x in range(xUp,xDown+1):
		dist=0
		for i in range(0,edges.shape[0]):
			dist=dist+(edges[i,0]-float(x))**2+(edges[i,0]-yCenter)**2
		dists.append([x,dist])
	dists=np.array(dists)
	xCenter=dists[dists[:,1].argmin(),0]
	img_gray[int(xCenter),:]=255;
	img_gray[:,int(yCenter)]=255;
	##
	r=(dists[:,1].min()/(xDown-xUp+1))**0.5
	##plot and get img color:H[0,179],S[0,255],V[0,255]
	HSV=[];img_hsv = cv2.cvtColor(img,cv2.COLOR_BGR2HSV)
	for xi in range(0,h):
	    for yi in range(0,w):
	    	dist=((xi-xCenter)**2+(yi-yCenter)**2)**0.5
	    	#print(dist)
	    	if dist<=r  and binary0[xi,yi]==255 and closed2[xi,yi]<255:#and dist >= r/4
	    		img_gray[xi,yi]=255
	    		#img[xi,yi]=255
	    		HSV.append(img_hsv[xi,yi])
	###get color and save
	HSV=np.array(HSV)
	np.savetxt(hsvFile,HSV,fmt="%d")
	cv2.imwrite(locFile,np.hstack([img_gray0,closed,img_gray]))

#if '__name__'=='main':
#####
#picName='XJ023正.eye_right.PNG'
#picName='XJ023正.eye_left.PNG'
#picName='XJ003正.eye_left.PNG'
path='/Users/taoxianming/Documents/face2DExtract/eyebrow_tao/XJW_gongan/male/eye'
picPath=path+'/pic/'
hsvPath=path+'/eye_color/'
locPath=path+'/eye_loc/'
##get landmarks for detail location
lmPath=path+'/landmarks/'
picNames=os.listdir(picPath)
print(len(picNames))
for i,picName in enumerate(picNames):
	try:
		print(i)
		if picName.endswith('PNG'):
			getColor(picName,picPath,hsvPath,locPath,lmPath)
	except:
		print("error")
		continue

