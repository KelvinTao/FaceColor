###This script can provide the allele frequency of SNP you supplied based the 1000 Genome Project database and the effect allele and the allele from 1000 Genome Project(2504 samples).
###input file: SNPinfo included one or two columns, the SNPid list is essential,the second column represents the effect allele.
###If you donnot supply the effect allele,you should choose the EA=FALSE.
###SuperPop == TRUE will creates the frequency of SNP you supplied across the main 5 super population including("EAS","SAS","AFR","EUR","AMR")
###Pop = TRUE will creates the frequency of SNP you supplied across the 26 populations
###EA=TRUE represents the input file effe
####---test
##workpath<-"/data/liyi/1000G_map/31MAF/test"
##effect<-"/data/liyi/1000G_map/31MAF/test/rawsnplist.txt"
##outName<-"test"
##EA=TRUE
##SuperPop=TRUE
##Pop=TRUE
####---
getMAF<-function(workpath,SNPinfo,outName,EA=TRUE,SuperPop=TRUE,Pop=TRUE){
  setwd(workpath)
	effectinfo<-read.table(SNPinfo,header=T,stringsAsFactors=F)
	mysample<-read.table("/data/liufan/data/1000G/sampleINFO/1000GsampleINFO.txt",header=T,stringsAsFactors=F)
	snplist<-effectinfo[,1]
	write.table(snplist,file=paste(workpath,"/snplist.txt",sep=""),row.names=F,quote=F,col.names=F)
	system(paste("plink --bfile /data/liufan/data/1000G/1000G --extract ",workpath,"/snplist.txt"," --make-bed --recodeA --out ",workpath,"/extract_result",sep=""))
	mydata1<-read.table(paste(workpath,"/extract_result.bim",sep=""),header=F,stringsAsFactors=F)
	mydata2<-read.table(paste(workpath,"/extract_result.raw",sep=""),header=T,,stringsAsFactors=F)
	for(i in 7:dim(mydata2)[2]){
		mydata2[,i][is.na(mydata2[,i])]=mean(mydata2[,i],na.rm=TRUE)
		}
	suppop<-c("EAS","SAS","AFR","EUR","AMR")
	pop<-c("GBR","FIN","CHS","PUR","CDX","CLM","IBS","PEL","PJL","KHV","ACB","GWD","ESN","BEB","MSL","STU","ITU","CEU","YRI","CHB","JPT","LWK","ASW","MXL","TSI","GIH")
	mydata3<-mydata2[,-(2:6)]
	mydata4<-merge(mysample,mydata3,by.x="sample",by.y="FID")
    mydata6<-mydata1
    sort<-c(1:dim(mydata6)[1])
	mydata6<-cbind(mydata6,sort)
	mydata7<-merge(mydata6,effectinfo,by.x="V2",by.y="SNP")
	mydata7$sort<-as.numeric(as.character(mydata7$sort))
	mydata7<-mydata7[order(mydata7$sort),]
if(EA){
colnames(effectinfo)<-c("SNP","EFA")
effectinfo<-merge(effectinfo,mydata7[,c(1,5,6,7)],by.x="SNP",by.y="V2",all.x=T)
effectinfo<-effectinfo[order(effectinfo$sort),]
effectinfo<-effectinfo[,1:4]
colnames(effectinfo)<-c("SNP","EFA","A1","A2")
	}else{
effectinfo<-as.data.frame(effectinfo)
colnames(effectinfo)<-c("SNP") 
effectinfo<-merge(effectinfo,mydata7[,c(1,5,6,7)],by.x="SNP",by.y="V2",all.x=T)
effectinfo<-effectinfo[order(effectinfo$sort),]
effectinfo<-effectinfo[,1:3]
colnames(effectinfo)<-c("SNP","A1","A2")	
	}
Replace<-function(rawlist,bimlist,outresult){
    tmpresult<-c()
    for(i in 1:nrow(rawlist)){
    	index1<-which(bimlist[,2]==rawlist[i,1])
        if(length(index1)!=0){
        tmpresult<-rbind(tmpresult,outresult[index1,])	
        }else{
        tmpresult<-rbind(tmpresult,rep("NA",ncol(outresult)))
        }
    }
    result<-cbind(effectinfo,tmpresult)
    return(result)
}

if(SuperPop){
	superpop<-c()
    for(i in 5:ncol(mydata4)){
    	tmp<-c()
       for(j in 1:length(suppop)){
       	num<-length(which(mydata4$super_pop==suppop[j]))
       	med<-which(mydata4$super_pop==suppop[j])
       	freq<-(sum(mydata4[med,i]))/2/num
       	tmp<-c(tmp,freq)
       }
       superpop<-rbind(superpop,tmp)
    }
    colnames(superpop)<-suppop
    resultSuper<-Replace(effectinfo,mydata1,superpop)
write.csv(resultSuper,file=paste(workpath,"/",outName,"_5SuperPopFreq.csv",sep=""),row.names=F,quote=F)
}

if(Pop){
    popfreq<-c()
    for(i in 5:ncol(mydata4)){
    	tmp<-c()
    	for(j in 1:length(pop)){
        num<-length(which(mydata4$pop==pop[j]))
       	med<-c(which(mydata4$pop==pop[j]))
       	freq<-(sum(mydata4[med,i]))/2/num
       	tmp<-c(tmp,freq)
    	}
    	popfreq<-rbind(popfreq,tmp)
    }
    colnames(popfreq)<-pop    
    resultPop<-Replace(effectinfo,mydata1,popfreq)
write.csv(resultPop,file=paste(workpath,"/",outName,"_26PopFreq.csv",sep=""),row.names=F,quote=F)
}
}
####example
#getMAF("/data/liyi/1000G_map/31MAF/1wan","/data/liyi/1000G_map/31MAF/1wan/10000randomSNP.txt","Ran10000",EA=FALSE,Pop=FALSE)
#getMAF("/data/taoxm/uygur_iris_MPS/SNP","/data/taoxm/uygur_iris_MPS/SNP/snpAll.txt","snpAll.frq",EA=FALSE,Pop=FALSE)
getMAF("/data/taoxm/uygur_iris_MPS/SNP","/data/taoxm/uygur_iris_MPS/SNP/snps6.txt","snps6.frq",EA=FALSE,Pop=FALSE)
