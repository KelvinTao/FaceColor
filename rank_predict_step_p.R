# R code for ranking explanation variables according to AIC via forward stepwise. 
#taoxm 20190526
library(nnet)
library(pROC)
rankByAuc<- function(data){
  initialf='y~'
  selected <- c()
  unselected=names(data)[-1]
  n <- length(unselected)
  times <- 0
  maxauc <- 0
  #lastauc <- 1
  while(times < n){
    auc <- c()
    for(i in 1:length(unselected)){
      fo <- formula(ifelse(length(selected)==0, paste0(initialf, unselected[i]),paste0(initialf,paste(selected,collapse="+"),"+", unselected[i])))
      if(length(unique(data$y))>2){
        model <- multinom(fo, data=data)
        auc <- c(auc,auc(multiclass.roc(data$y,model$fitted.values)))
      }else{
        model <- glm(fo,data=data,family=binomial(link = "logit"))
        auc <- c(auc,auc(roc(data$y,model$fitted.values)))
      }
    }
    #lastauc
    if(length(selected) == 0){
      lastauc <- -Inf
    }else{
      lastfo <- formula(paste0(initialf, paste(selected,collapse="+")))
      lastmodel <- multinom(lastfo,data=data)
      if(length(unique(data$y))>2){
        lastmodel <- multinom(lastfo,data=data)
        lastauc <- auc(multiclass.roc(data$y,lastmodel$fitted.values))
      }else{
        lastmodel <- glm(lastfo,data=data,family=binomial(link = "logit"))
        lastauc <- auc(roc(data$y,lastmodel$fitted.values))
      }
    }

    #maxauc
    maxauc <- max(auc)

    #judging
    if(maxauc > lastauc){
      max.pos <- which.max(auc)
      selected <- c(selected, unselected[max.pos])
      unselected <- unselected[-max.pos]
      times=times+1
    }else{
      break
    }
  }
  return(list(times,selected))
}


##logistic regression
rankByPvalue_binom<-function(data){
  model=glm(y~.,data=data,family=binomial(link = "logit"))
  coef=as.data.frame(summary(model)$coefficients)
  #coef2=coef[-c(1:3),]
  #coefSort=coef2[sort(coef2$"Pr(>|t|",index.return = T)$ix,]
  #rank_r1=rownames(rbind(coef[1:3,],coefSort))
  coefSort=coef[sort(coef$"Pr(>|z|)",index.return = T)$ix,]
  rank_r1=rownames(coefSort)
  rank_r1=rank_r1[rank_r1!='(Intercept)']
  return(rank_r1)
}


##auc of each SNP in ranks
getStepAuc<-function(r1Data,probs_all){
  y0=as.numeric(as.character(r1Data$y));
  classes=1:max(y0)
  numOfVar=1:length(probs_all)
  classStep=NULL
  if(length(classes)==2){
    for (ni in numOfVar){
      probs_all[[ni]]=data.frame(probs_all[[ni]],1-probs_all[[ni]])
      names(probs_all[[ni]])=c(1,2)
      ##print(classAUC)
    }
  }
  for (ci in classes){
    y=y0;y[y!=ci]=0;y[y==ci]=1;
    classAUC=NULL
    for (ni in numOfVar){
      classAUC=c(classAUC,as.numeric(auc(y,probs_all[[ni]][,as.character(ci)])))
      ##print(classAUC)
    }
    classStep=cbind(classStep,classAUC)
    colnames(classStep)[ci]=ci
  }
  rownames(classStep)=numOfVar
  return(classStep)
}

##predict class NO.
LOO_multinom<-function(d,formula){##names(d)[1]='y'
    rowN=nrow(d)
    pred=rep(0,rowN)
    for (i in 1:rowN){
        s=multinom(formula,data=d[-i,])
        pred[i]=predict(s,d[i,-1])
    }
    return(pred)
}

##precict probability
LOO_multinom_probs<-function(d,formula){#names(d)[1]='y'
    probs=NULL
    for (i in 1:nrow(d)){
        s=multinom(formula,data=d[-i,])
        probs=rbind(probs,predict(s,newdata=d[i,-1],type='probs'))#
    }
    return(probs)
}
##precict probability
LOO_binom_probs<-function(d,formula){#names(d)[1]='y'
    probs=NULL
    for (i in 1:nrow(d)){
        s=glm(formula,data=d[-i,],family=binomial(link = "logit"))
        probs=rbind(probs,predict(s,newdata=d[i,-1]))#
    }
    return(probs)

##predict probability of each class
predict_probs_binom<-function(r1Data,rank_r1){
    all=list()
    for (i in 1:length(rank_r1)){
        fmultinom=paste0('y~',paste(rank_r1[1:i],collapse="+"))
        all[[fmultinom]]=LOO_binom_probs(r1Data,fmultinom)
    }
    return(all)
##predict probability of each class
predict_probs_mutinom<-function(r1Data,rank_r1){
    all=list()
    for (i in 1:length(rank_r1)){
        fmultinom=paste0('y~',paste(rank_r1[1:i],collapse="+"))
        all[[fmultinom]]=LOO_multinom_probs(r1Data,fmultinom)
    }
    return(all)
}
if(0){
##regress for each y
getR2<-function(r1Data,rank_r1){
    R2all=NULL
    for (i in 1:length(rank_r1)){
        R2each=NULL
        fmultinom=paste0('y~',paste(rank_r1[1:i],collapse="+"))
        predEach=LOO_multinom(r1Data,fmultinom)
        R2all=data.frame(cbind(R2all,predEach))
        colnames(R2all)[i]=rank_r1[i]
        #R2=summary(model)$adj.r.squared
        #print(R2) 
        #R2all=data.frame(rbind(R2all,R2))
        #rownames(R2all)[i]=rank_r1[i]
    }
    colnames(R2all)='R2'
    return(R2all)
}

##regress for each y
getDeltaR2<-function(r1Data,rank_r1){
    deltaR2=NULL
    R2all=NULL
    for (i in 1:length(rank_r1)){
        fmultinom=paste0('y~',paste(rank_r1[1:i],collapse="+"))
        #print(fmultinom)
        model=multinom(formula(fmultinom),data=r1Data)
        R2=summary(model)$adj.r.squared
        #print(R2)
        R2all=c(R2all,R2)
        #deltaR2=c(deltaR2,ifelse(i==1,R2,R2-deltaR2[i-1]))
        if (i==1){
            deltaR2=data.frame(rbind(deltaR2,R2all[i]))
        }else{
            deltaR2=data.frame(rbind(deltaR2,R2all[i]-R2all[i-1]))
        }
        rownames(deltaR2)[i]=rank_r1[i]
    }
    colnames(deltaR2)='deltaR2'
    return(deltaR2)
}
}

###AIC
rankByAic_multinom <- function(data){
  initialf='y~'
  selected <- c()
  unselected=names(data)[-1]
  n <- length(unselected)
  times <- 0
  minaic <- 0
  #lastaic <- 1
  while(times < n){
  aic <- c()
  for(i in 1:length(unselected)){
    fo <- formula(ifelse(length(selected)==0, paste0(initialf, unselected[i]),paste0(initialf,paste(selected,collapse="+"),"+", unselected[i])))
    fit <- multinom(fo, data=data)
    aic <- c(aic,AIC(fit))
  }
  #lastaic
  if(length(selected) == 0){
    lastaic <- Inf
  }else{
    lastfo <- formula(paste0(initialf, paste(selected,collapse="+")))
    lastfit <- multinom(lastfo,data=data)
    lastaic <- AIC(lastfit)
  }

  #minaic
  minaic <- min(aic)

  #judging
  if(minaic < lastaic){
    min.pos <- which.min(aic)
    selected <- c(selected, unselected[min.pos])
    unselected <- unselected[-min.pos]
    times=times+1
  }else{
    break
  }
  }
  return(list(times,selected))
}

##linear regression AIC
rankByAic_lm <- function(data){
        initialf='y~'
        selected=c()
        unselected=names(data)[-1]
        type='c'
        n <- length(unselected)
        times <- 0
        minaic <- 0
        lastaic <- 1
        while(times < n){
                aic <- c()
                for(i in 1:length(unselected)){
                        fo <- formula(ifelse(length(selected)==0, paste0(initialf, unselected[i]),paste0(initialf,paste(selected,collapse="+"),"+", unselected[i])))
                        if(type=="c"){
                                fit <- lm(fo, data=data)
                        }else{
                                fit <- glm(fo, family=binomial(link = "logit"),data=data)
                        }
                        aic <- c(aic,AIC(fit))
                }
                #lastaic
                if(length(selected) == 0){
                        lastaic <- Inf
                }else{
                        lastfo <- formula(paste0(initialf, paste(selected,collapse="+")))
                        ifelse(type=="c", lastfit <- lm(lastfo,data=data), lastfit <- glm(lastfo, family=binomial(link = "logit"), data=data))
                        lastaic <- AIC(lastfit)
                }

                #minaic
                minaic <- min(aic)

                #judging
                if(minaic < lastaic){
                        min.pos <- which.min(aic)
                        selected <- c(selected, unselected[min.pos])
                        unselected <- unselected[-min.pos]
                        times=times+1
                }else{
                        break
                }
        }
        return(list(times,selected))
}
