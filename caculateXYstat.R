
######calculate mean
sex='both'
#th=0.7
th=0.8
#path=paste0('/Users/taoxianming/Documents/face2DExtract/eyebrow_tao/XJW_gongan/',sex)
path='/Users/taoxianming/Documents/face2DExtract/eyebrow_tao/RS_pic_loc'
xyFile=paste0(path,'/eyebrow_image_extraction/xyStat_local.threshold',th,'/xyStat.xls')
xyMat=read.table(xyFile,sep='\t',head=T,stringsAsFactors=F)
sampleNames=xyMat[,1];xyMat=xyMat[,-1];
xyMean=NULL
for (i in seq(1:(dim(xyMat)[1]/2))){
    matI=i*2-1;
    meanValue=apply(xyMat[matI:(matI+1),],2,mean)
    xyMean=rbind(xyMean,meanValue)
    rownames(xyMean)[i]=substr(sampleNames[matI],1,nchar(sampleNames[matI])-14)
}
write.table(xyMean,paste0(path,'/eyebrow_image_extraction/xyStat_local.threshold',th,'/xyStat.mean.xls'),sep='\t',row.names=T,quote=F,col.names=NA)

###compare with human read
library(readxl)
path0='/Users/taoxianming/Documents/face2DExtract/eyebrow_tao/XJW_gongan'
pathStat=paste0(path0,'/eyebrowStat/eyebrowDensitySum.xlsx')
human=read_excel(pathStat,'human')
#sum=merge(xyMean,human,by.x=1,by.y=1)
sum=merge(data.frame(rownames(xyMean),xyMean),human,by.x=1,by.y=1)
names(sum)[1]='sampleNO'
sum=data.frame(sum,pz_mean=apply(sum[,(dim(sum)[2]-1):dim(sum)[2]],1,mean))
cortable=cor(sum[,-1])
write.table(sum,paste0(path,'/eyebrowDensityBYxystat.Sum.xls'),sep='\t',row.names=F,quote=F)
write.table(cortable,paste0(path,'/eyebrowDensityBYxystat.Sum.cor.xls'),sep='\t',col.names=NA,quote=F)

#after  paste X0.7
sex='both_eyebrow'
path=paste0('/Users/taoxianming/Documents/face2DExtract/eyebrow_tao/XJW_gongan/',sex)
sumFile=paste0(path,'/eyebrowDensityBYxystat.Sum.xls');
sum2=read.table(sumFile,sep='\t',head=T,stringsAsFactors=F)

library(ggplot2)
library(reshape2)
sum2=sum2[,c(4,3,9,6)]
names(sum2)=c('std(y)','std(x)','0.7','human read')
sum2[,5]=0.5*sum2[,3]+0.5*sum2[,2]
names(sum2)[5]=c('D2')
cortable=cor(sum2)
cortable.m <- melt(cortable)
names(cortable.m)[3]='correlation'
p=ggplot(cortable.m, aes(Var1, Var2)) + 
geom_tile(aes(fill = correlation),colour = "white") +
scale_fill_gradient(low = "green",high = "red")+
scale_x_discrete("")+scale_y_discrete("")
ggsave(paste0(path,'/eyebrowdensity_correlation.local.mix.jpg'),width = 6.5, height = 5,p)






sum2[,10]=0.993*sum2[,9]+0.007*sum2[,3]#experience
names(sum2)[10]='993X0.7+007xsd'
#write.table(sum2,paste0(path,'/eyebrowDensityBYxystat.Sum.mix.xls'),sep='\t',col.names=NA,quote=F)
###################density
th=0.8
humanFile='/Users/taoxianming/Documents/face2DExtract/eyebrow_tao/RS_pic_loc/humanRead/pengfd/RS_eyebrow_density.RData'
load(humanFile)
path='/Users/taoxianming/Documents/face2DExtract/eyebrow_tao/RS_pic_loc'
xyMean=read.table(paste0(path,'/eyebrow_image_extraction/xyStat_local.threshold',th,'/xyStat.mean.xls'),sep='\t',head=T,stringsAsFactors=F)
for(rn in 1:dim(xyMean)[1]){
	xyMean[rn,1]=strsplit(xyMean[rn,1],'.front')[[1]][1]
}
sum=merge(xyMean,pheMat,by.x=1,by.y=1)
cortable=cor(sum[,-1])
write.table(cortable,paste0(path,'/eyebrow_image_extraction/xyStat_local.threshold',th,'/xyStat.mean.cor.xls'),sep='\t',col.names=NA,quote=F)

########color
th=0.8
path='/Users/taoxianming/Documents/face2DExtract/eyebrow_tao/RS_pic_loc'
hsvFiles=Sys.glob(paste0(path,'/eyebrow_image_extraction/hsv_xy_local.threshold',th,'/*.RData'))
hsvStat=NULL
hn=0
for (hi in seq(1,length(hsvFiles),2)){
	load(hsvFiles[hi])
	imgHsvL=imgHsvUse;rm(imgHsvUse)
	load(hsvFiles[hi+1])
	imgHsvR=imgHsvUse
	if (length(imgHsvL)>1 && length(imgHsvR)>1 ){
		f=strsplit(hsvFiles[hi],'/')[[1]]
	    id=strsplit(f[length(f)],'.front')[[1]][1]
		hsvL=as.vector(apply(imgHsvL,2,function(x) quantile(x,c(0,0.25,0.5,0.75,1))))
		hsvR=as.vector(apply(imgHsvR,2,function(x) quantile(x,c(0,0.25,0.5,0.75,1))))
		hsvMean=apply(rbind(hsvL,hsvR),2,mean)
        hsvStat=rbind(hsvStat,hsvMean)
        hn=hn+1
        rownames(hsvStat)[hn]=id
	}
}
statName=c(paste0('H',c(0,0.25,0.5,0.75,1)),
	paste0('S',c(0,0.25,0.5,0.75,1)),
	paste0('V',c(0,0.25,0.5,0.75,1)));
colnames(hsvStat)=statName
hsvStatPath=paste0(path,'/eyebrow_image_extraction/hsv_xy_local.threshold',th,'_hsvStat')
dir.create(hsvStatPath)
write.table(hsvStat,paste0(hsvStatPath,'/hsvStat.xls'),sep='\t',col.names=NA,quote=F)
##compare
th=0.8
humanFile='/Users/taoxianming/Documents/face2DExtract/eyebrow_tao/RS_pic_loc/humanRead/pengfd/RS_eyebrow_colorscore.RData'
load(humanFile)
path='/Users/taoxianming/Documents/face2DExtract/eyebrow_tao/RS_pic_loc'
hsvStatPath=paste0(path,'/eyebrow_image_extraction/hsv_xy_local.threshold',th,'_hsvStat')
hsvStatFile=paste0(path,'/eyebrow_image_extraction/hsv_xy_local.threshold',th,'_hsvStat/hsvStat.xls')
hsvStat=read.table(hsvStatFile,sep='\t',head=T,stringsAsFactors=F)
hsvRead=merge(hsvStat,pheMat,by.x=1,by.y=1)##768
cortable=cor(hsvRead[,-1])
write.table(hsvRead,paste0(hsvStatPath,'/hsvStat.hsvRead.xls'),sep='\t',col.names=NA,quote=F)
write.table(cortable,paste0(hsvStatPath,'/hsvStat.hsvRead.cor.xls'),sep='\t',col.names=NA,quote=F)









