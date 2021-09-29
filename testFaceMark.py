
path='/Users/taoxianming/Documents/face_2D/eyebrow_tao/example_markNO'
landmarksRef='/Users/taoxianming/Documents/face_2D/eyebrow_tao/script/scriptNow/shape_predictor_68_face_landmarks.dat'
##instantiation
detector = dlib.get_frontal_face_detector()
predictor = dlib.shape_predictor(landmarksRef)
###part and index
#####start
imgFiles=path+'/openmouth.JPG'
shrink=1#1for unclear pictures,0.3 for clear pictures
##
print("Processing file: {}".format(imgFiles))
time_start=time.time()
#####start
img0 = io.imread(imgFiles)
io.imshow(img0)
io.show()
img=shrinkImg(img0,shrink)
rect,landmarks=getRectLandmark(img,detector,predictor)
###draw marks on face
img=drawRect(img,rect)
img=drawLandmarks(img,landmarks)
markFile=(imgFiles+'.mark.shrink{}.JPG').format(shrink)
io.imsave(markFile,img)
##
print(time.time()-time_start)


