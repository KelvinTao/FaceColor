idPath='/Users/taoxianming/Documents/face_3D/RS/mat/matUse'
load(paste0(idPath,'/maleRD_id.RData'))
maleId=idPair;rm(idPair);
load(paste0(idPath,'/femaleRD_id.RData'))
femaleId=idPair;rm(idPair)
id=rbind(maleId,femaleId)

##
eyePath='/Users/taoxianming/Documents/face2DExtract/eyebrow_tao/RS_pic_loc/eye/hsvStat/hsvStatMean.xls'
hsv=read.table(eyePath,sep='\t',head=T,stringsAsFactors=F)
eyeReadPath='/Users/taoxianming/Documents/face2DExtract/eyebrow_tao/RS_pic_loc/humanRead/liyi/'
eyeRead=paste0(eyeReadPath,'/RS_EyeColor_es_IID_ERGOID.RData')
load(eyeRead)##pheMat
pheMat=merge(pheMat[,-1],id,by.x=1,by.y=1)
pheMat[,1]=pheMat[,3];pheMat=pheMat[,-3]
hsvRead=na.omit(merge(hsv,pheMat,by.x=1,by.y=1))##636
print(dim(hsvRead))
cortable=cor(hsvRead[,-1])
print(cortable)
write.table(hsvRead,'/Users/taoxianming/Documents/face2DExtract/eyebrow_tao/RS_pic_loc/eye/hsvStat/hsvStatMean.es.xls')
write.table(cortable,'/Users/taoxianming/Documents/face2DExtract/eyebrow_tao/RS_pic_loc/eye/hsvStat/hsvStatMean.es.cor.xls')


