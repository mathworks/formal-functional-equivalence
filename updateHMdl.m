function updateHMdl(harnessVer1,refMdlVer2)

%********************************************************************
%FILENAME:                  updateHMdl.m
%
%Synopsis                   This function creates merged hareness model from following models.
%                               a. Harness refrencing Version 1 model
%                               b. Harness refrencing Version 2 model
%                           It drives both of the refrenced test units from
%                           the same  signal builder/Inports
%                           This is done to show equivalence for both of the refrences.
%
%INPUT:                     harnessVer1: Existing Harness Model for Version 1.
%                           refMdlVer2: Name of reference model for version 2 which needs to be added and connected with source.
%
%OUTPUT:                    Updated harness model with 2 model references, Bus selector block, Relational operator and proof objective block.

%********************************************************************
mergedHarnessNE = [harnessVer1 '_mergedH.slx'];
mergedHarnessN = [harnessVer1 '_mergedH'];
newRefModelN = 'Ver_2';

try
    copyfile([harnessVer1 '.slx'],mergedHarnessNE,'f');
    fileattrib(mergedHarnessNE,'+w');
    open_system(mergedHarnessNE);
    load_system('simulink');
    bdclose(harnessVer1);

    [~,models] = find_mdlrefs(mergedHarnessN);
    ver2SubN = [mergedHarnessN '/' newRefModelN];

    if ~isempty(models)
        existingRefPath = models{1};
        srcDstPortConn = get_param(existingRefPath,'PortConnectivity');
        srcTypeSizeTypeOrInConv = unique(get_param([srcDstPortConn.SrcBlock],'name'),'stable');
        dstTypeOutportOrConv = get_param([srcDstPortConn.DstBlock],'blocktype');

        posOfExistingRef = get_param(existingRefPath,'Position');

        %Add new model reference block. Position is relative to existing
        %model ref for V1.
        % START BUG HERE: "invalid destination block specification"

        height = posOfExistingRef(4)-posOfExistingRef(2);
        verticalSpaceBetweenBlocks = 150;

        posMdlRef2 = [posOfExistingRef(1) posOfExistingRef(4)+verticalSpaceBetweenBlocks posOfExistingRef(3) posOfExistingRef(4)+height+verticalSpaceBetweenBlocks];
        posMdlRef2 = validatePositionSize(posMdlRef2);
        newMdlRefH = add_block(existingRefPath,ver2SubN,'CopyOption','duplicate','position',posMdlRef2);
        % END BUG HERE
        set_param(newMdlRefH,'modelname',refMdlVer2);
    end

    ipConvSub = [mergedHarnessN '/' srcTypeSizeTypeOrInConv{:}];
    ipConvSubPortH = get_param(ipConvSub,'PortHandles');
    newMdlRefPortH = get_param(ver2SubN,'PortHandles');

    %Connect outputs of Input conversion subsystem block to new model
    %reference block.

    add_line(mergedHarnessN,ipConvSubPortH.Outport(:),newMdlRefPortH.Inport(:));

    if ~strcmpi(dstTypeOutportOrConv,'Outport')
        opConvSub = [mergedHarnessN '/Output Conversion Subsystem'];

        %Connect outputs of Input conversion subsystem block to new model
        %rDuplicate Output conversion subsystem and connect it to output of new
        %model reference block.

        opConvSubPos = get_param(opConvSub,'Position');
        heightofOpConvSub = opConvSubPos(4)-opConvSubPos(2);
        widthofOpConvSub = opConvSubPos(3)-opConvSubPos(1);
        horizontalSpacebetweenBlocks = 135;
        posOpCondSub = [opConvSubPos(1) opConvSubPos(4)+verticalSpaceBetweenBlocks opConvSubPos(3) opConvSubPos(4)+heightofOpConvSub+verticalSpaceBetweenBlocks];
        posOpCondSub = validatePositionSize(posOpCondSub);
        add_block(opConvSub,[opConvSub '_1'],'CopyOption','duplicate','position',posOpCondSub);

        opConvSubPortHNEw = get_param([opConvSub '_1'],'PortHandles');

        add_line(mergedHarnessN,newMdlRefPortH.Outport(:),opConvSubPortHNEw.Inport(:),'autorouting','on');
        opConvSubPortH = get_param(opConvSub,'PortHandles');
    else
        opConvSubPortHNEw = newMdlRefPortH;
        opConvSubPortH = get_param(existingRefPath,'PortHandles');
    end

    positionOfBcr = [opConvSubPos(1)+horizontalSpacebetweenBlocks opConvSubPos(2) opConvSubPos(3)+widthofOpConvSub+horizontalSpacebetweenBlocks opConvSubPos(4)];
    positionOfBcr = validatePositionSize(positionOfBcr);
    busCreatorH = add_block('simulink/Signal Routing/Bus Creator',[mergedHarnessN '/BusCreator'],'position',positionOfBcr);


    %Add BusCreator block and connect it to outports of existing Output conversion
    %subsystem

    numOutFrmRef = numel(opConvSubPortH.Outport);
    set_param(busCreatorH,'Inputs',num2str(numOutFrmRef));
    busCreatorPortH = get_param(busCreatorH,'PortHandles');
    add_line(mergedHarnessN,opConvSubPortH.Outport(:),busCreatorPortH.Inport(:),'autorouting','on');


    %Add BusCreator block and connect it to outports of new Output conversion
    %subsystem
    positionOfBcr1 = [opConvSubPos(1)+horizontalSpacebetweenBlocks opConvSubPos(4)+verticalSpaceBetweenBlocks opConvSubPos(3)+widthofOpConvSub+horizontalSpacebetweenBlocks opConvSubPos(4)+heightofOpConvSub+verticalSpaceBetweenBlocks];
    positionOfBcr1 = validatePositionSize(positionOfBcr1);
    busCreatorH1 = add_block('simulink/Signal Routing/Bus Creator',[mergedHarnessN '/BusCreator_1'],'position',positionOfBcr1);

    set_param(busCreatorH1,'Inputs',num2str(numOutFrmRef));

    busCreatorPortH1 = get_param(busCreatorH1,'PortHandles');
    add_line(mergedHarnessN,opConvSubPortHNEw.Outport(:),busCreatorPortH1.Inport(:),'autorouting','on');

    %Add Relational Operator block and connect it to outputs of both Bus Creator blocks
    standardWidthOFRelopBlock = 30;
    standardHeightOFRelopBlock = 31;
    horizontalSpacebetweenBlocks = 55;
    positionOfRelop = [positionOfBcr(1)+110 positionOfBcr(4)+horizontalSpacebetweenBlocks positionOfBcr(3)+110+standardWidthOFRelopBlock positionOfBcr(4)+standardHeightOFRelopBlock+horizontalSpacebetweenBlocks];
    positionOfRelop = validatePositionSize(positionOfRelop);
    relop = add_block('simulink/Commonly Used Blocks/Relational Operator',[mergedHarnessN '/relop'],'position',positionOfRelop);

    set_param(relop,'Operator','==');

    relopPortH = get_param(relop,'PortHandles');
    add_line(mergedHarnessN,busCreatorPortH.Outport(:),relopPortH.Inport(1),'autorouting','on');
    add_line(mergedHarnessN,busCreatorPortH1.Outport(:),relopPortH.Inport(2),'autorouting','on');

    %Add Proof Objective block and connect it to output Relational Operator block
    relopPos = get_param(relop,'position');
    positionOfProofObj = [relopPos(1)+125 relopPos(2) relopPos(3)+125 relopPos(4)];

    positionOfProofObj = validatePositionSize(positionOfProofObj);
    proofObj = add_block('sldvlib/Objectives and Constraints/Proof Objective',[mergedHarnessN '/proofObj'],'position',...
        positionOfProofObj);

    proofObjPortH = get_param(proofObj,'PortHandles');
    set_param(proofObj,'outEnabled','off')

    add_line(mergedHarnessN,relopPortH.Outport(:),proofObjPortH.Inport(:),'autorouting','on');
    save_system(mergedHarnessN);

catch Me
    disp(Me.message);
    return
end

    function updatedPos = validatePositionSize(currentPos)
        %vector of coordinates: [left top right bottom]
        %If  top > bottom OR left > right. The position is invalid and
        %error would be triggered: “Invalid definition of rectangle. Width and height should be positive.”
        left = currentPos(1);
        top = currentPos(2);
        right = currentPos(3);
        bottom = currentPos(4);

        if top>bottom
            bottom = top+5;
        end

        if left>right
            right = left+5;
        end

        updatedPos = [left top right bottom];
    end
end