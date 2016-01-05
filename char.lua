require 'image';

local char = {}

local data = require 'data'

local Y = data.loadY()

local function check(seq,h,w)
    for k,v in ipairs(seq) do
        if(v:size(1)>h or v:size(2)>w) then
            return false
        end
    end
    return true
end

function char.read(from,to)
    local XY = {}
    for i=from or 1,to or 500 do
        local Xi = torch.load('data/'..i..'/data.t7')
        for j=1,#Xi do
            if(#Xi[j]==6 and check(Xi[j],20,20)) then
                for k=1,6 do
                    XY[Y[i][k]] = XY[Y[i][k]] or {}
                    table.insert(XY[Y[i][k]], Xi[j][k])
                end
            end
        end
    end 

    local kmap = {}
    for k,v in pairs(XY) do
        local h = {}
        local w = {}
        kmap[k] = torch.zeros(#v,20,20)
        for tmp,vi in ipairs(v) do
            table.insert(h,vi:size(1))
            table.insert(w,vi:size(2))
            kmap[k][tmp][{{1,vi:size(1)},{1,vi:size(2)}}] = vi
        end

        --print(k,#v,torch.Tensor(w):min(),torch.Tensor(w):max(),torch.Tensor(h):min(),torch.Tensor(h):max())
    end

    local X = nil
    local Y = nil
    for k,v in pairs(kmap) do 
        --print(k,v:size(1))
        X = X and torch.cat(X,v,1) or v
        y = torch.zeros(v:size(1),1)
        y:fill(k)
        Y = Y and torch.cat(Y,y,1) or y 
    end
    local M = X:size(1)
    local idx = torch.randperm(M):long()
    return X:index(1,idx),Y:index(1,idx):squeeze()
end

return char