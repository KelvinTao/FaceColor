########## Get sample by ID

#rs1800407 GRCh37.p13 chr 15	28230318
#rs16891982: GRCh37.p13 chr 5	33951693  ##in EUR, rs35398,    r2: 0.405567
dataPath=/liufanGroup/taoxm/uygur_iris_MPS/SNP/1000GLD
ori1000G=/liufanGroup/liufan/data/1000G/1000G
##get snp region
plink --bfile $ori1000G -chr 15 --from-bp  27730318 --to-bp 28730318 --make-bed  --out $dataPath/1000G.rs1800407.500kb
plink --bfile $ori1000G  -chr 5 --from-bp  33451693 --to-bp 34451693 --make-bed  --out $dataPath/1000G.rs16891982.500kb

##for each supop
supops=(EUR EAS)
snps=(rs1800407 rs16891982)
for snp in ${snps[@]}
do
  for sp in ${supops[@]}
  do
    plink --bfile $dataPath/1000G.$snp.500kb --keep $dataPath/$sp.id.txt --make-bed --out $dataPath/$sp.1000G.$snp.500kb
    plink --bfile $dataPath/$sp.1000G.$snp.500kb --r2 --out $dataPath/$sp.1000G.$snp.500kb.r2
  done
done
## LD

### R code
dataPath='/liufanGroup/taoxm/uygur_iris_MPS/SNP/1000GLD'
path='/liufanGroup/liufan/data/1000G'
sampleInfo=read.table(paste0(path,"/sampleINFO/1000GsampleINFO.txt"),header=T,stringsAsFactors=F)
supops=c('EUR','EAS')
for(spi in seq_along(supops)){
  sp=sampleInfo[sampleInfo$super_pop==supops[spi],]
  spsample=data.frame(FID=sp$sample,IID=sp$sample)
  write.table(spsample,file=paste0(dataPath,'/',supops[spi],'.id.txt'),sep=' ',row.names=F,quote=F)
  print(supops[spi])
}

##bash code
#rs16891982: GRCh37.p13 chr 5	33951693  ##in EUR, rs35398,    r2: 0.405567
dataPath=/liufanGroup/taoxm/uygur_iris_MPS/SNP/1000GLD
ori1000G=/liufanGroup/liufan/data/1000G/1000G
##for each supop
supops=(CEU)
snps=(rs16891982)
for snp in ${snps[@]}
do
  for sp in ${supops[@]}
  do
    plink --bfile $dataPath/1000G.$snp.500kb --keep $dataPath/$sp.id.txt --make-bed --out $dataPath/$sp.1000G.$snp.500kb
    plink --bfile $dataPath/$sp.1000G.$snp.500kb --r2 --out $dataPath/$sp.1000G.$snp.500kb.r2
  done
done
## LD

### R code
dataPath='/liufanGroup/taoxm/uygur_iris_MPS/SNP/1000GLD'
path='/liufanGroup/liufan/data/1000G'
sampleInfo=read.table(paste0(path,"/sampleINFO/1000GsampleINFO.txt"),header=T,stringsAsFactors=F)
supops=c("CEU")
for(spi in seq_along(supops)){
  sp=sampleInfo[sampleInfo$pop==supops[spi],]
  spsample=data.frame(FID=sp$sample,IID=sp$sample)
  write.table(spsample,file=paste0(dataPath,'/',supops[spi],'.id.txt'),sep=' ',row.names=F,quote=F)
  print(supops[spi])
}
