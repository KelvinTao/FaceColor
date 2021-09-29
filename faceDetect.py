#default python
######necessary module
import sys,os,dlib,glob,cv2
import numpy as np
from skimage import io,transform,draw
##for add numer on image
from PIL import Image,ImageDraw
######
##for calculate time
import time


def shrinkImg(img0,shrink):
    img=np.uint8(np.around(transform.resize(img0,(round(img0.shape[0]*shrink),
        round(img0.shape[1]*shrink)),mode='constant')*255))
    return(img)

def getRectLandmark(img,detector,predictor):
    #upsample the image 1 time
    dets = detector(img,1)
    for d in dets:
        #get rectangle line
        rect=[d.top(),d.bottom(),d.left(),d.right()]
        # get the landmarks/parts for the face in box d
        shape = predictor(img, d)  #np.mat(shape.parts())
        landmarks=np.mat([[points.x,points.y] for points in shape.parts()])
    return([rect,landmarks])


def drawRect(img,rect):
    ##draw face rectangle on the image
    rr,cc = draw.polygon_perimeter([rect[0],rect[0],rect[1],rect[1]],[rect[3],rect[2],rect[2],rect[3]])
    img[rr,cc] = (255, 0, 0)
    img[rr+1,cc+1] = (255, 0, 0)
    img[rr-1,cc-1] = (255, 0, 0)
    return(img)

def drawLandmarks(img,landmarks):
    ##draw landmarks circle on the image
    for rc in landmarks:
       lr,lc = draw.circle_perimeter(rc[0,1],rc[0,0],1)##y,x,radius
       img[lr,lc] = (0, 255, 0)
       img[lr-1,lc] = (0, 255, 0)
       img[lr,lc-1] = (0, 255, 0)
       img[lr-1,lc-1] = (0, 255, 0)
       img[lr+1,lc+1] = (0, 255, 0)
       img[lr,lc+1] = (0, 255, 0)
       img[lr+1,lc] = (0, 255, 0)
       #img[lr+1,lc+1] = (0, 255, 0)
    return(img)


def main():
    ###
    path='/Users/taoxianming/Documents/face_2D/eyebrow_tao/example_markNO'
    landmarksRef='/Users/taoxianming/Documents/face_2D/eyebrow_tao/script/scriptNow/shape_predictor_68_face_landmarks.dat'
    #######
    oriImgPath=path+'/pic'
    ##instantiation
    detector = dlib.get_frontal_face_detector()
    predictor = dlib.shape_predictor(landmarksRef)
    ###part and index
    #####start
    imgFiles=path+'/openmouth.JPG'
    shrink=1#1for unclear pictures,0.3 for clear pictures
    try:
        print("Processing file: {}".format(imgFiles))
        time_start=time.time()
        #####start
        img0 = io.imread(imgFiles)
        #io.imshow(img0)
        #io.show()
        #img=shrinkImg(img0,shrink)
        img=img0
        rect,landmarks=getRectLandmark(img,detector,predictor)
        ###draw marks on face
        img=drawRect(img,rect)
        img=drawLandmarks(img,landmarks)
        markFile=(imgFiles+'.mark.shrink{}.JPG').format(shrink)
        io.imsave(markFile,img)
        ############ add landmark number
        ifAddNO=False
        if ifAddNO:
            imgNO=addNumOnImg(markFile,landmarks)
            imgNO.save(markFile+'.NO.JPG')
        #############
        print(time.time()-time_start)
    except:
        print("error")


if __name__ == '__main__':
    main()
    ##iamge display
    #io.imshow(img);io.show();
