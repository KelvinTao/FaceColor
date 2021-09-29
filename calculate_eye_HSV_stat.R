
type='both_eye'##test
#path=paste0('/Users/taoxianming/Documents/face2DExtract/eyebrow_tao/XJW_gongan/',type)
path='/Users/taoxianming/Documents/face2DExtract/eyebrow_tao/RS_pic_loc/eye'
hsvPath=paste0(path,'/hsv')
hsvStatPath=paste0(path,'/hsvStat')
dir.create(hsvStatPath)
hsvStat=NULL
files=Sys.glob(paste0(hsvPath,'/*.hsv.RData'))
for(fi in 1:length(files)){
	print(fi)
	fileName=unlist(strsplit(files[fi],'/'))
    fileName=fileName[length(fileName)]
    load(files[fi])#imgHsvUse
    stat=as.vector(apply(imgHsvUse,2,function(x) {return(quantile(x,probs=seq(0,1,0.25)))}))
    qt=as.character(seq(0,1,0.25))
    names(stat)=c(paste0(c('H'),qt),paste0(c('S'),qt),paste0(c('V'),qt))
    hsvStat=rbind(hsvStat,stat)
    rownames(hsvStat)[fi]=fileName
}
hsvStat=round(hsvStat,6)
write.table(hsvStat,paste0(hsvStatPath,'/hsvStat.xls'),sep='\t',col.names=NA,quote=F)

##calculate mean
type='both_eye'##test
#path=paste0('/Users/taoxianming/Documents/face2DExtract/eyebrow_tao/XJW_gongan/',type)
hsvStatPath=paste0(path,'/hsvStat')
hsvStat=read.table(paste0(hsvStatPath,'/hsvStat.xls'),sep='\t',head=T,stringsAsFactors=F)
hsvStatMean=NULL
for (rn in seq(1,dim(hsvStat)[1],2)){
    hsvStatMean=rbind(hsvStatMean,apply(hsvStat[rn:(rn+1),-1],2,mean))
    #id=unlist(strsplit(hsvStat[rn,1],'正-'))[1]
    id=unlist(strsplit(hsvStat[rn,1],'.front'))[1]
    #id=substr(id,1,nchar(id)-1)
    rownames(hsvStatMean)[(rn+1)/2]=id
}
write.table(hsvStatMean,paste0(hsvStatPath,'/hsvStatMean.xls'),sep='\t',col.names=NA,quote=F)


#comparision with humanread
library(readxl)
type='both_eye'##test
path=paste0('/Users/taoxianming/Documents/face2DExtract/eyebrow_tao/XJW_gongan/',type)
hsvStatPath=paste0(path,'/hsvStat')


hsvStatMean=read.table(paste0(hsvStatPath,'/hsvStatMean.xls'),sep='\t',head=T,stringsAsFactors=F)
male_eye=read_excel(paste0(path,'/gongan_XJW_eye_hair_color.xlsx'),'male_eye')
female_eye=read_excel(paste0(path,'/gongan_XJW_eye_hair_color.xlsx'),'female_eye')
read_eye=rbind(male_eye,female_eye)[,c(1,4,7,8)]##mean
hsvRead=merge(hsvStatMean,read_eye,by.x=1,by.y=1)
write.table(hsvRead,paste0(hsvStatPath,'/hsvStatMeanVShumanRead.xls'),sep='\t',col.names=NA,quote=F)
corr=cor(hsvRead[,c(-1,-2,-3)])


hsvRead=read.table(paste0(hsvStatPath,'/hsvStatMeanVShumanRead.xls'),sep='\t',head=T,stringsAsFactors=F)
hsvUse=hsvRead[,c(14:16,9:11,4:6,20)]
#for (i in 1:9){
#    hsvUse[,i]=(hsvUse[,i]-mean(hsvUse[,i]))/sd(hsvUse[,i])
#}
names(hsvUse)[10]='human read'
library(ggplot2)
library(reshape2)
cortable=cor(hsvUse)
cortable.m <- melt(cortable)
names(cortable.m)[3]='correlation'
p=ggplot(cortable.m, aes(Var1, Var2)) + 
geom_tile(aes(fill = correlation),colour = "white") +
scale_fill_gradient(low = "blue",high = "red")+
scale_x_discrete("")+scale_y_discrete("")
ggsave(paste0(hsvStatPath,'/eyecolor.local.cor.jpg'),width = 8, height = 7,p)
write.table(cortable,paste0(hsvStatPath,'/eyecolor.local.cor.xls'),sep='\t',col.names=NA,quote=F)

##test
m=hsvRead[,c(19,3,8,13)]
lmodel=lm(mean_both~., data=m)
mix=6.143235-0.096555*hsvRead$H0.25+2.087759*hsvRead$S0.25-12.732989*hsvRead$V0.5
cor(mix,hsvRead$mean_both)
0.7304377


##boxplot
library(readxl)
library(ggplot2)
library(reshape2)
type='both_eye'##test
path=paste0('/Users/taoxianming/Documents/face2DExtract/eyebrow_tao/XJW_gongan/',type)
hsvStatPath=paste0(path,'/hsvStat')
hsvRead=read.table(paste0(hsvStatPath,'/hsvStatMeanVShumanRead.xls'),sep='\t',head=T,stringsAsFactors=F)
hsvUse=hsvRead[,c(14:16,9:11,4:6,20)]
hsvUse[,7:9]=hsvUse[,7:9]/360
hE=hsvUse[,1:9]
for (j in 1:9){
    low=min(hE[,j]);high=max(hE[,j]);range=high-low;
    for (i in 1:dim(hE)[1]){
        hE[i,j]=(hE[i,j]-low)/range
    }
}
col=dim(hsvUse)[2]
hsvUse[,col]=round(hsvUse[,col])
hsvUse=cbind(hE,hsvUse[,col])
names(hsvUse)[col]='oMean'
h2=cbind(sample=hsvRead[,2],hsvUse)
#write.table(h2,paste0(hsvStatPath,'/eyecolor.local.0-1.xls'),sep='\t',row.names=F,quote=F)

hsv.melt <- melt(hsvUse,id=col)
hsv.melt[,1]=as.character(hsv.melt[,1])
p<-ggplot(data=hsv.melt, aes(x=oMean,y=value))+geom_boxplot(aes(fill=variable))+facet_wrap(~ variable, scales="free")
#ggsave(p,file=paste0(hsvStatPath,'/hsvStatMeanVShumanRead.boxplot.jpg'))

##get HS principle component 1 and 2 and quantile mean





