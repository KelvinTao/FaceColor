if(F){

distance<-function(p1,p2){
    return(sqrt((p1[1]-p2[1])^2+(p1[2]-p2[2])^2))
}

sex='male'
path=paste0('/Users/taoxianming/Documents/face2DExtract/eyebrow_tao/XJW_gongan/',sex)
lmFiles=Sys.glob(paste0(path,'/landmarks/*.txt'))

####
pointsNum=read.table(paste0(path,'/eyebrow_result/eyebrow_result.txt'),sep=' ',head=F,stringsAsFactors=F)
sampleNames=dir(paste0(path,'/eyebrow_result/result_img'))
ratioMat=NULL
for (i in 1:length(sampleNames)){  ##7--.eyebrow
	###get sample name
	s=sampleNames[i]
	endI=gregexpr(".eyebrow", s)[[1]][1]-1
	sample=substr(s,8,endI)
	##get landmarks
    lmFile=paste0(path,'/landmarks/',sample,'.landmarks.txt')
    lms=read.table(lmFile,sep='\t',head=F,stringsAsFactors=F)
    ##calculate left eye length,37 40 right eye length 43 46
    if (gregexpr("left", s)[[1]][1]>0){
        d=distance(lms[37,],lms[40,])
        side='left'
    }else if(gregexpr("right", s)[[1]][1]>0){
        d=distance(lms[43,],lms[46,])
        side='right'
    }
    ratioMat=rbind(ratioMat,pointsNum[i,]/d/d)
    rownames(ratioMat)[i]=paste0(sample,'_',side)
}
ratioMat=round(ratioMat,4)
colnames(ratioMat)=c('90','80','70','60','50','0.9','0.8','0.7','0.6','0.5')
write.table(ratioMat,paste0(path,'/eyebrow_result/pointsRatioByEye.xls'),sep='\t',quote=F,col.names=NA)
#q('no')
}


##calaulate mean
if(F){
sex='male'
path=paste0('/Users/taoxianming/Documents/face2DExtract/eyebrow_tao/XJW_gongan/',sex)
ratioFile=paste0(path,'/eyebrow_result/pointsRatioByEye.xls')
#ratioMat=read.table(ratioFile,row.names=T,sep='\t',stringsAsFactors=F)
ratioMat=read.table(ratioFile,sep='\t',head=T,stringsAsFactors=F)
sampleNames=ratioMat[,1];ratioMat=ratioMat[,-1];
ratioMean=NULL
for (i in seq(1:(dim(ratioMat)[1]/2))){
    matI=i*2-1;
    meanValue=apply(ratioMat[matI:(matI+1),],2,mean)
    ratioMean=rbind(ratioMean,meanValue)
    rownames(ratioMean)[i]=substr(sampleNames[matI],1,nchar(sampleNames[matI])-5)
}
write.table(ratioMean,paste0(path,'/eyebrow_result/pointsRatioByEye.mean.xls'),sep='\t',row.names=T,quote=F,col.names=NA)

}

###compare with human read
library(readxl)
path0='/Users/taoxianming/Documents/face2DExtract/eyebrow_tao/XJW_gongan'
pathStat=paste0(path0,'/eyebrowStat/eyebrowDensitySum.xlsx')
#maleCal=paste0(path0,'/male/eyebrow_result/pointsRatioByEye.mean.xls')
#femaleCal=paste0(path0,'/female/eyebrow_result/pointsRatioByEye.mean.xls')
#maleMean=read.table(maleCal,sep='\t',head=T,stringsAsFactors=F)
#femaleMean=read.table(femaleCal,sep='\t',head=T,stringsAsFactors=F)
#humanRead=read.csv(paste0(pathStat,'/thickness.csv'),head=T,stringsAsFactors=F)
comp=read_excel(pathStat,'comp')
human=read_excel(pathStat,'human')
sum=merge(comp,human,by.x=1,by.y=1)
sum=data.frame(sum,pz_mean=apply(sum[,(dim(sum)[2]-1):dim(sum)[2]],1,mean))
##box plot 0.7
ws=sum[,c(9,12)];names(ws)=c('Extracted_Density','Human_Read_Density')
ws=ws[ws[,2]!=0,]
ws[,2]=as.character(ws[,2])
p<-ggplot(data=ws, aes(x=Human_Read_Density,y=Extracted_Density))+geom_boxplot(aes(fill=Human_Read_Density))#+#facet_wrap(~ variable, scales="free")
ggsave(p,file=paste0(path0,'/eyebrowStat/eyebrowDensity0.7.boxplot.jpg'))




cortable=cor(sum[,-1])
#write.table(sum,paste0(path0,'/eyebrowStat/eyebrowDensitySumOK.xls'),sep='\t',row.names=F,quote=F)
#write.table(cortable,paste0(path0,'/eyebrowStat/eyebrowDensitySumOK_cor.xls'),sep='\t',col.names=NA,quote=F)
###corralation heatmap


library(ggplot2)
require(reshape2)
sumL=sum[,c(11:7,12)]
＃names(sumL)=c(paste0('T',seq(0.5,0.9,0.1)),'eyebrow_density')
names(sumL)=c(seq(0.5,0.9,0.1),'human read')
#cortableL=cor(sumL)

#library(ggplot2)
#require(reshape2)
#cn=ncol(sum)
#colnames(sum)[(cn-2):(cn-1)]=c('pfd','zw')
#cortable=cor(sum[,-1])

cortable=cor(sumL)
cortable.m <- melt(cortable)
names(cortable.m)[3]='correlation'
p=ggplot(cortable.m, aes(Var1, Var2)) + 
geom_tile(aes(fill = correlation),colour = "white") +
scale_fill_gradient(low = "green",high = "red")+
scale_x_discrete("")+scale_y_discrete("")
ggsave(paste0(path0,'/eyebrowStat/eyebrowdensity_correlation.local.jpg'),width = 6.5, height = 5,p)


####
