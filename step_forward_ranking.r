# R code for ranking explanation variables according to AIC via forward stepwise. 
#Yan Chen

### This is for testing purposes. ######################################
#    data <- d
#    initialf <- "y ~ "
#    selected <- c()
#    unselected <- snpname
#    type <- "c"
#    o <- stepforward(data, initialf, selected, unselected, type)
#########################################################################

stepforwardr <- function(data,initialf,selected,unselected, type){
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
				fit <- glm(fo, family=binomial(),data=data)
			}
			aic <- c(aic,AIC(fit))
		}
		#lastaic
		if(length(selected) == 0){
			lastaic <- Inf
		}else{
			lastfo <- formula(paste0(initialf, paste(selected,collapse="+")))
			ifelse(type=="c", lastfit <- lm(lastfo,data=data), lastfit <- glm(lastfo, family=binomial(), data=data))
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
