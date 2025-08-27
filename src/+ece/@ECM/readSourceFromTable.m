function ecm = readSourceFromTable(ecmTbl,name)
%ecmTbl to provide the table containing measures
%   This method will output an array of Airmovers objects, one per the row

%% Arguments Block
% Set input argument validation.
arguments
    % ecmTbl: table containing measures corresponding to the ECM
    ecmTbl

    % name: ECM's name
    name (1,1) string
end %argblock

% Return empty array if none exist.
emptyCheck = isempty(ecmTbl);
if(emptyCheck)
    ecm = ece.ECM.empty(0,1);
    return;
end %endif

% get Table height
hgt = height(ecmTbl);

%% Iterate through each row
oprDct  = ["insert","delete","update"];
updDct  = ["add","multiply","replace"];
outlrLst=["Airmovers","SlabOnGrade","DHWpipesMechRoom","HeatCool","Glazing"];
spclCls = "Glazing";
rplcCls = "GlazedSurfaces";

ecm     = ece.ECM;
ecm.Name= name;
msrArray= ece.MeasureComponent.empty(0,1);
badFlg  = false(hgt,1);
for idx = 1:hgt
    %condition check
    chkItem1= lower(ecmTbl.Operation{idx});
    if ~any(oprDct == chkItem1)
        badFlg(idx) = true;
        continue
    elseif any(chkItem1 == "update")
        chkItem2= lower(ecmTbl.UpdateType{idx});
        if ~any(updDct == chkItem2)
            badFlg(idx) = true;
            continue
        end
    end

    % Create Instance of Airmovers class
    % Temporary Measurement Component for allocating data into one object.
    msr = ece.MeasureComponent;

    % Read Properties  and assigning to respective properties
    msr.ObjectOfReference   = ecmTbl.ObjectOfReference{idx};
    if any(outlrLst == msr.ObjectOfReference)
        if any(spclCls == msr.ObjectOfReference)
            msr.ObjectVarName = rplcCls(spclCls == msr.ObjectOfReference);
        else
            msr.ObjectVarName = msr.ObjectOfReference;
        end
    else
        msr.ObjectVarName       = strcat(ecmTbl.ObjectOfReference{idx},'s');
    end
    
    msr.Operation           = ecmTbl.Operation{idx};
    
    if chkItem1 == "insert"
        msr.InsertQuantity      = ecmTbl.InsertQuantity(idx);
        msr.InsertedProperty    = ecmTbl.InsertedProperty{idx};
    else
        msr.FilterCriteria      = ecmTbl.FilterCriteria{idx};
        if chkItem1 == "update"
            msr.PropertyToChange    = ecmTbl.PropertyToChange{idx};
            msr.ValueForChange      = ecmTbl.ValueForChange(idx);
            msr.UpdateType          = ecmTbl.UpdateType{idx};
        end
    end

    % Update MeasureComponent array in ECM
    msrArray(idx) = msr;

end %forloop (idx)

msrArray(badFlg)        = [];
ecm.MeasureComponents   = msrArray;

end %function
