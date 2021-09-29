function [eyeIni,eyeSee]=getIrisByLandmarks(side,eyeFile,lmFile,sideLms,sideLmsIn)
    eye=imread(eyeFile);
    lm=dlmread(lmFile);
    %%marks
    marks=lm(sideLms(side),:);
    %%position
    jumpRatio=0.3;
    left=min(marks(:,1));right=max(marks(:,1));
    jumpHorizonal=floor((right-left)*jumpRatio);
    top=min(marks(:,2));down=max(marks(:,2));
    jumpVertical=floor((down-top)*(jumpRatio));
    %original cut part
    [r,c,~]=size(eye);
    eyeIni=eye(1+jumpVertical:r-jumpVertical,1+jumpHorizonal:c-jumpHorizonal,:);
    %%%marks center
    [ri,ci,~]=size(eyeIni);
    marksIn=lm(sideLmsIn(side),:);
    marksIn(:,1)=marksIn(:,1)-left;
    marksIn(:,2)=marksIn(:,2)-top;tdJumpRatioT=0.2;tdJumpRatioD=0.1;
    leftIn=min(marksIn(:,1));rightIn=max(marksIn(:,1));
    topIn=min(marksIn(:,2))+(down-top)*tdJumpRatioT;downIn=max(marksIn(:,2))-(down-top)*tdJumpRatioD;
    [xc,yc,R,~]=circlefit(marksIn(:,2),marksIn(:,1));
    %%%%%%%%%
    pointInIni=rgb2gray(eyeIni);
    [row,col]=size(pointInIni);
    b=single(reshape(pointInIni,row*col,1));
    groupnum=20;[~,x]=hist(b,groupnum);% 20 parts
    %point gray value less than NO. minNo retain
    minNo=5;jumpM=(x(minNo)+x(minNo+1))/2;
    black=quantile(b,0.1);
    % &&((r-xc)^2+(c-yc)^2)>(R/3)^2
    eyeSee=eyeIni;
    for r=1:ri
        for c=1:ci
            if  not(((r-xc)^2+(c-yc)^2)<=R^2 &&c>=leftIn && c<=rightIn && r>=topIn && r<=downIn && pointInIni(r,c)<=jumpM && pointInIni(r,c)>black)
               eyeIni(r,c,:)=255; 
            else
               eyeSee(r,c,1)=255;
            end
        end
    end  
    
end