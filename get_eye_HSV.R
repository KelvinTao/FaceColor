library(imager)
type='male'##test
#path=paste0('/Users/taoxianming/Documents/face2DExtract/eyebrow_tao/XJW_gongan/',type,'/eye')
path='/Users/taoxianming/Documents/face2DExtract/eyebrow_tao/RS_pic_loc/eye'
hsvPath=paste0(path,'/hsv')
dir.create(hsvPath)
files=Sys.glob(paste0(path,'/resPicLocate/*.eye.JPG'))
for(fi in 1:length(files)){
	print(fi)
	fileName=unlist(strsplit(files[fi],'/'))
    fileName=fileName[length(fileName)]
    img=load.image(files[fi])#0-1 for r g b
    ##change to HSV
    imgHsv=RGBtoHSV(img)
    ##gray for search
    imgGray=grayscale(img)
    errorRate=0.9##error for save jpg
    #imgGray[imgGray>errorRate]=1
    #plot(imgGray)
    index=imgGray<=1*errorRate # bool matrix
    imgHsvMid=imgHsv[index]
    ##reshape
    number=length(imgHsvMid)/3
    if (number>0){
        imgHsvUse=cbind(imgHsvMid[1:number],imgHsvMid[(number+1):(number*2)],imgHsvMid[(number*2+1):(number*3)])
        #####save
        save(imgHsvUse,file=paste0(hsvPath,'/',fileName,'.hsv.RData'))
    }
}
#write.table(xyStat,paste0(xyStatPath,'/xyStat.xls'),sep='\t',col.names=NA,quote=F)
