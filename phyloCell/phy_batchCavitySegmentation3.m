function phy_batchCavitySegmentation3(path,file,frames,position,display2)
global segmentation timeLapse %segList


% this function segments (watershedGC), maps (hungarian method, GC)


% to do : 

%fix mapper ! 

% detect out of focus frames
%std(double(a(:)))/mean(double(a(:)))

if numel(path)==0 && numel(file)==0
    
    [file, path] = uigetfile( ...
        {'*.mat';'*.*'}, ...
        'Get timelapse file');
    
    if (file==0)
        return;
    end
    
end


str=strcat(path,file);

load(str);

timeLapse.realPath=strcat(path);
timeLapse.realName=file;

timeLapsepath=timeLapse.realPath;
timeLapsefile=[timeLapse.filename '-project.mat'];

%strPath=strcat(timeLapse.realPath,timeLapse.filename,'-project.mat');

pp=1;
for l=position
    
    %[segmentation timeLapse]=phy_openSegmentationProject(timeLapsepath,timeLapsefile,l,[1 3]);
    
    strPath=strcat(timeLapsepath,timeLapsefile);
    load(strPath);
    timeLapse.path=timeLapsepath;
    timeLapse.realPath=timeLapsepath;
    
    segmentation=phy_createSegmentation(timeLapse,l);
    segmentation.position=l;
    
    
    
    segmentation.processing.parameters{1,14}{1,2}=1;
    segmentation.processing.parameters{1,14}{2,2}=400;
    segmentation.processing.parameters{1,14}{3,2}=20000;
    segmentation.processing.parameters{1,14}{4,2}=40;
    segmentation.processing.parameters{1,14}{5,2}=0.3;
    segmentation.processing.parameters{1,14}{6,2}=1;
    segmentation.processing.parameters{1,14}{7,2}=0;
    
    
    segmentation.processing.parameters{1,9}{1,2}=1;
    segmentation.processing.parameters{1,9}{2,2}=40;
    segmentation.processing.parameters{1,9}{3,2}=1;
    segmentation.processing.parameters{1,9}{4,2}=1;
    segmentation.processing.parameters{1,9}{5,2}=0;
    segmentation.processing.parameters{1,9}{6,2}=0;
    
    %segmentation.processing.parameters{1,13}{1,2}=0.2;
    %segmentation.processing.parameters{1,13}{2,2}=0.55;
    %segmentation.processing.parameters{1,13}{3,2}=0.55;
    %segmentation.processing.parameters{1,13}{4,2}=0.002;
    
    %p = [];
    %p.areaWeight = segmentation.processing.parameters{1,13}{1,2};
    %p.xWeight = segmentation.processing.parameters{1,13}{2,2};
    %p.yWeight = segmentation.processing.parameters{1,13}{3,2};
    %p.costThreshold = segmentation.processing.parameters{1,13}{4,2};
    
   
  
    %im=segmentation.realImage(:,:,1);
    %im2=mat2gray(im2);
    
    
    
    segmentation.processing.parameters{2,7}{4,2}=10;
    segmentation.processing.parameters{2,7}{5,2}=120;
    
    %segmentation.position=l;
    
    % initialization : find cavity orientation using frame1
    % load first frame
    
    
    imdata=phy_loadTimeLapseImage(segmentation.position,1,1,'non retreat');
    
    
    % generate mask file for mapping
    
    %warning off all
    %imn=imtophat(imdata,strel('disk',30));
    %imn=mat2gray(imn);
    %warning on all
    %mask = phy_computeMask(imn,40); %segmentation.processing.parameters{1,14}{4,2}/2);
    
    %markers = mask > 0;
    %markers(2:(end-1), 2:(end-1)) = 0;
    
    %p.geodistances = imChamferDistance(mask, markers);
    
    
    %segmentation.p=p;
    %imwrite(mask,'mask.png');
    
    % buildcavity and align
    
    [imbw1 x y C]=phy_findCavity(imdata);
    [maxe imbw1 C]=phy_alignCavity(imdata,imbw1,'coarse',0,C);
    
    [maxe imbw1 C]=phy_alignCavity(imdata,imbw1,'fine',0,C);
    
    orientation=1; % cavity is down;
    
    if maxe(4)==0
        orientation=0; % cavity is up
    end
    
    segmentation.orientation=orientation;
    %segmentation.discardImage=zeros(1,max(frames));
    %segmentation.mask=mask;
    
    if display2
        hdisplay=figure;
    end
    
    cc=1;
    phy_progressbar;
    
    nstore=0;
    
    for i=frames
        % load data
        %fprintf(['processing frame :' num2str(i) 'for position: ' num2str(l) '\n']);
        
        try
            phy_progressbar(double(cc)/double(length(frames)));
        catch
            phy_progressbar(1);
        end
        
        
        imdata=phy_loadTimeLapseImage(segmentation.position,i,1,'non retreat');
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%�
        % segment cells %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        segmentation.cells1(i,:)=phy_Object;
        
        cell=phy_segmentWatershedGC(imdata,segmentation.processing.parameters{1,14}{2,2},...
            segmentation.processing.parameters{1,14}{3,2},segmentation.processing.parameters{1,14}{4,2},...
            segmentation.processing.parameters{1,14}{5,2},segmentation.processing.parameters{1,14}{6,2},...
            segmentation.processing.parameters{1,14}{7,2});
        
       
        
        %%%%%
        % filter out cell based on fluo levels (excluding cells on the
        % extreme part of trapping area)
        
       % i
       % 'before'
       % cell.n
        cellsout=phy_filterCells(cell,imdata,250,750,1000);
       % 'after'
       % cellsout.n
        
       % cellsout=cell;
        %%%%%
        
        if display2==1
            figure(hdisplay);
            warning off all
            imshow(imdata,[]);
            warning on all
        end
        
        for j=1:length(cellsout)
            segmentation.cells1(i,j)=cellsout(j);
            segmentation.cells1(i,j).image=i;
            
            if display2==1
                line(cellsout(j).x,cellsout(j).y,'Color','r');
            end
        end
        
        
        % detect out of focus frame

        
        cov=std(double(imdata(:)))/mean(double(imdata(:)));
        if cov<0.26
           segmentation.discardImage(i)=1; 
        end
       
        %segmentation.cells1(i,:).n
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%�
        % segment budnecks %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if size(segmentation.colorData,1)>=3
            
        imbud=phy_loadTimeLapseImage(segmentation.position,i,2,'non retreat');
        warning off all
        imbud=imresize(imbud,2);
        warning on all
        
        if display2==2
            % 'ok'
            figure(hdisplay);
            imshow(imbud,[]);
        end
        
        parametres=segmentation.processing.parameters{2,7};
        
        budnecktemp=phy_segmentMito(imbud,parametres);
        
        budneck=phy_Object;
        for j=1:length(budnecktemp)
            if budnecktemp(j).n~=0
                segmentation.budnecks(i,j)=budnecktemp(j);
                segmentation.budnecks(i,j).image=i;
                
                if display2==2
                    line(budnecktemp(j).x,budnecktemp(j).y,'Color','r');
                end
            end
        end
        
        end
        
        if display2
            figure(hdisplay);
            text(10,10,['Frame ' num2str(i)],'Color','w');
            % pause;
        end
        
        % end of budneck segmentation
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%�
        % map cells %%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      
    
        if cc>1
         
         nstore=max(nstore, max([segmentation.cells1(i-1,:).n]));

         temp=segmentation.discardImage(1:i-1); % frame is discarded by user ; display previous frame
         trackFrame=find(temp==0,1,'last');
                
         cell0=segmentation.cells1(trackFrame,:);
         cell1=segmentation.cells1(i,:);
         
         parametres=segmentation.processing.parameters{1,9};
         
         segmentation.cells1(i,:)=phy_mapCellsHungarian(cell0,cell1,nstore,parametres{2,2}, parametres{3,2},parametres{4,2},parametres{5,2},parametres{6,2});
         
         end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%% SCORE FLUORESCENCE VALUES %%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
%         for l=1:size(segmentation.colorData,1)
%             
%             %read and scale the fluorescence image from appropriate channel
%             
%             img=phy_loadTimeLapseImage(segmentation.position,i,l,'non retreat');
%             warning off all;
%             img=imresize(img,segmentation.sizeImageMax);
%             warning on all;
%             
%             imgarr(:,:,l)=img;
%         end
%         
%         segmentation.cells1(i,:)=measureFluorescence(imgarr,segmentation.cells1(i,:),segmentation);
        
        cc=cc+1;
        
    end
    phy_progressbar(1);
    
    segmentation.cells1Segmented=zeros(1,timeLapse.numberOfFrames);
    segmentation.cells1Segmented(frames)=1;
    %segmentation.v_axe1=[segbox(1) segbox(2)+segbox(1) segbox(3) segbox(3)+segbox(4)];
    
    
    
    if display2
        close(hdisplay);
    end
    
    
    segmentation.cells1Mapped(frames(1):frames(end))=1;
    segmentation.frameChanged(frames(1):frames(end))=1;
    
    [segmentation.tcells1 fchange]=phy_makeTObject(segmentation.cells1,segmentation.tcells1);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%�
    % saving %%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    fprintf(['Saving Position: ' num2str(l) '...']);
    
    save(fullfile(timeLapse.realPath,timeLapse.pathList.position{segmentation.position},'segmentation-batch.mat'),'segmentation');
    
%     l=numel(segList);
%     segList(l+1).s=segmentation;
%     segList(l+1).position=segmentation.position;
%     segList(l+1).filename=timeLapse.filename;
%     segList(l+1).t=timeLapse;
%     segList(l+1).line=1:1:length(segmentation.tcells1);
%     
%     for k=1:numel(segList)
%         segList(k).selected=0;
%     end
%     
%     segList(l+1).selected=1;
    pp=pp+1;
end


function cells1iout=measureFluorescence(imgarr,cells1i,segmentation)

%create masks and get readouts
for j=1:length(cells1i)
    if cells1i(j).n~=0 && ~isempty(cells1i(j).x)
        mask = poly2mask(cells1i(j).x,cells1i(j).y,segmentation.sizeImageMax(1),segmentation.sizeImageMax(2));
        
        
        for l=1:size(segmentation.colorData,1)
            img=imgarr(:,:,l);
            cells1i(j).fluoMean(l)=mean(img(mask));
        end
    end
end

cells1iout=cells1i;
