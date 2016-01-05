local test = {}

char = require 'char';

data = require 'data'
Ytrue = data.loadY()

Xv,Yv = char.read(451,500)

require 'nn';
require 'cunn';
local net = torch.load('charnet.t7')

local net:evaluate()

i=451
K=99

function test.test(i,K)
    local function check(seq,h,w)
        for k,v in ipairs(seq) do
            if(v:size(1)>h or v:size(2)>w) then
                return false
            end
        end
        return true
    end

    local Xi = torch.load('data/'..i..'/data.t7')

    XY = {}

    X = nil
    for j=1,K do
            if(#Xi[j]==6 and check(Xi[j],20,20)) then
                    table.insert(XY,Xi[j])
                    for i=1,6 do 
                        vi = Xi[j][i]
                        Xc = torch.zeros(1,20,20)
                        Xc[1][{{1,vi:size(1)},{1,vi:size(2)}}] = vi
                        X = X and torch.cat(X,Xc,1) or Xc
                    end
            end
    end
    if(X==nil) then return false end
    Y = net:forward(X:cuda())
    tmp,idx = Y:max(2)
    A = idx:reshape(idx:size(1)/6,6)
    local function maxElement(P)
        local cnt = {}
        for i=1,P:nElement() do
            local v = P[i]
            cnt[v] = (cnt[v] or 0) + 1
        end
        --print(cnt)
        local max,maxi = -1,-1
        for k,v in pairs(cnt) do
            if(v>max) then maxi=k;max=v end
        end
        return maxi
    end
    tbl  = {}
    for i=1,6 do
        table.insert(tbl,maxElement(A[{{},i}]))
    end
    --print(torch.Tensor(tbl))
    local ret = torch.all(torch.Tensor(tbl):eq(Ytrue[i]))
    --print(i,K,ret)
    return ret
end

function test.testAll()
    for j=10,99,5 do
    cnt = 0
    for i=1,50 do
        if((test(450+i,j))) then
            cnt = cnt + 1
        end
    end
    print(j,cnt*100/50)
    end
end

return test