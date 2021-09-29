library(imager)
type='both'##test
#path=paste0('/Users/taoxianming/Documents/face2DExtract/eyebrow_tao/XJW_gongan/',type,'/eyebrow_image_extraction')
path='/Users/taoxianming/Documents/face2DExtract/eyebrow_tao/RS_pic_loc/eyebrow_image_extraction'
#lmFiles=Sys.glob(paste0(path,'/landmarks/*.txt'))
#rate=0.7
rate=0.8
thlevel=paste0('local.threshold',rate)
hsvxyPath=paste0(path,'/hsv_xy_',thlevel)
xyStatPath=paste0(path,'/xyStat_',thlevel)
dir.create(hsvxyPath)
dir.create(xyStatPath)
files=Sys.glob(paste0(path,'/eyebrow_image/*',thlevel,'.jpg'))
xyStat=NULL
for(fi in 1:length(files)){
	print(fi)
	fileName=unlist(strsplit(files[fi],'/'))
    fileName=fileName[length(fileName)]
    img=load.image(files[fi])#0-1 for r g b
    ##change to HSV
    imgHsv=RGBtoHSV(img)
    ##gray for search
    imgGray=grayscale(img)
    index=imgGray<=1*rate # bool matrix
    imgHsvMid=imgHsv[index]
    ##reshape
    number=length(imgHsvMid)/3
    if (number>1){
        imgHsvUse=cbind(imgHsvMid[1:number],imgHsvMid[(number+1):(number*2)],imgHsvMid[(number*2+1):(number*3)])
        #get x y
        xy=which(index, arr.ind=T)[,1:2]
        #####save
        save(imgHsvUse,xy,file=paste0(hsvxyPath,'/',fileName,'.hsv.xy.RData'))
        ##### x y statistics
        x=xy[,1];y=xy[,2];
        xsd=sd(xy[,1]);ysd=sd(xy[,2]);
        stat=data.frame(number,xsd,ysd,covabs=abs(cov(x,y)))
    }else{
        stat=data.frame(number=0,xsd=0,ysd=0,covabs=0)
        imgHsvUse=0
        xy=0
        save(imgHsvUse,xy,file=paste0(hsvxyPath,'/',fileName,'.hsv.xy.RData'))
    }
    xyStat=rbind(xyStat,stat)
    rownames(xyStat)[fi]=strsplit(fileName,'.PNG.')[[1]][1]
}
write.table(xyStat,paste0(xyStatPath,'/xyStat.xls'),sep='\t',col.names=NA,quote=F)
