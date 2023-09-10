% return unitName that belongs to which brainRegions
function colorKey = getColorKey(unitName, brainRegions, colorMap)
    colorKey = 'Other'; % default other
    k=[{'HPF'},{'MB'},{'TH'},{'VIS'}];
    for j = 1:length(brainRegions)
        region = brainRegions{j};
        if iscell(region) && any(contains(unitName, region))
            colorKey = k{j};
            break;
        elseif ischar(region) && any(contains(unitName, region))
            colorKey = k{j};
            break;
        end
    end
end