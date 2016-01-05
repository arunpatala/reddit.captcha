local data = {}

function data.readij(i,j)
    return image.load('data/'..i..'/'..j..'.png')[1]
end

function data.thresh(img,h)
    local h = h or 0.8
    local y = img:clone()
    y[y:lt(h)] = 0
    y[y:gt(0)] = 1
    return y
end
    
local function DFS(img,i,j,H,W)
    local cnt = 0
    if(i>=1 and i<=H and j>=1 and j<=W and img[i][j]==1) then
        img[i][j] = 0
        cnt = 1
        cnt = cnt + DFS(img,i-1,j,H,W)
        cnt = cnt + DFS(img,i,j-1,H,W)
        cnt = cnt + DFS(img,i+1,j,H,W)
        cnt = cnt + DFS(img,i,j+1,H,W)
    end
    return cnt
end

function data.clean(img,conn,thresh)
    local img = data.thresh(img,thresh)
    local H,W = img:size(1),img:size(2)
    local conn = conn or 20
    local z = img:clone()
    local comp = 0
    for i=1,H do
        for j=1,W do
            local cnt = DFS(img,i,j,H,W)
            if(cnt>0 and cnt<conn) then
                DFS(z,i,j,H,W)
            end
            if(cnt>=conn) then 
                comp = comp + 1 
            end
        end
    end
    return z,comp
end

function data.components(cimg)
    local H,W = cimg:size(1),cimg:size(2)
    local z = cimg:clone()
    local xy = {}
    
    for j=1,W do
        for i=1,H do
            local zz = z:clone()
            local cnt = DFS(z,i,j,H,W)
            if(cnt>0) then
                table.insert(xy,zz-z)
            end
        end
    end
    return xy
end
local function crop1(zzz)
    local hsum = zzz:sum(2):squeeze()
    local htop = nil
    local hbot = nil
    for i=1,hsum:nElement() do
        if(hsum[i]~=0) then htop = htop or i end
        if(htop and hsum[i]==0) then hbot = hbot or i end
    end
    return zzz[{{htop,hbot}}]
end
local function crop2(zzz)
    local hsum = zzz:sum(1):squeeze()
    local htop = nil
    local hbot = nil
    for i=1,hsum:nElement() do
        if(hsum[i]~=0) then htop = htop or i end
        if(htop and hsum[i]==0) then hbot = hbot or i end
    end
    return zzz[{{},{htop,hbot}}]
end

function data.crop(zzz)
    return crop2(crop1(zzz))
end

function data.crop_comp(i,j)
    local img = data.readij(i,j)
    --itorch.image(img)
    local z,c = data.clean(img)
    --itorch.image(z)
    local xy = data.components(z)
    local ret = {}
    for i=1,#xy do
        if(data.crop(xy[i]):sum()>=20) then
            table.insert(ret,-data.crop(xy[i]))
        end
    end
    return ret
end

function data.preprocess(from,to)
    for i=from or 1,to or 500 do
        local cnt = 0
        local tbl = {}
        for j=1,99 do
            local seq = data.crop_comp(i,j)
            if(#seq==6) then
                cnt = cnt+1
            end
            table.insert(tbl,seq)
        end
        torch.save('data/'..i..'/data.t7',tbl)
        print(i,cnt)
    end
end

function data.getY(file)
    require 'csvigo';
    local file = file or 'data/labels.txt'
    local tbl = csvigo.load{path = 'data/labels.txt',header=false}.var_1
    for i=1,#tbl do
        tbl[i] = string.upper(tbl[i])
    end
    local N = #tbl
    local d = 6
    local Y = torch.zeros(N,d)
    for i=1,N do
        for j=1,d do
            Y[i][j] = string.byte(tbl[i],j)-string.byte('A')+1
        end
    end
    return Y
end

function data.loadY(file)
    return torch.load(file or 'data/Y.t7')
end

function data.saveY(file)
    return torch.load(file or 'data/Y.t7',data.getY())
end

return data
