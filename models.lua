require 'nn';
require 'cunn';

local models = {}

function models.basicModel()
    local net = nn.Sequential()
    net:add(nn.Reshape(1,20,20))
    net:add(nn.SpatialConvolution(1,64,5,5,1,1,2,2))
    net:add(nn.SpatialMaxPooling(2,2,2,2))
    net:add(nn.Reshape(64*10*10))
    net:add(nn.Linear(64*10*10,200))
    net:add(nn.ReLU())
    net:add(nn.Linear(200,26))
    net:add(nn.LogSoftMax())
    local ct = nn.ClassNLLCriterion()
    return net,ct
end

function models.medModel()
    local net = nn.Sequential()
    net:add(nn.Reshape(1,20,20))
    net:add(nn.SpatialConvolution(1,64,3,3,1,1,1,1))
    net:add(nn.SpatialBatchNormalization(64,1e-3))
    net:add(nn.ReLU(true))
    net:add(nn.SpatialConvolution(64,64,3,3,1,1,1,1))
    net:add(nn.SpatialBatchNormalization(64,1e-3))
    net:add(nn.ReLU(true))
    net:add(nn.SpatialMaxPooling(2,2,2,2))
    net:add(nn.SpatialConvolution(64,128,3,3,1,1,1,1))
    net:add(nn.SpatialBatchNormalization(128,1e-3))
    net:add(nn.ReLU(true))
    net:add(nn.SpatialConvolution(128,128,3,3,1,1,1,1))
    net:add(nn.SpatialBatchNormalization(128,1e-3))
    net:add(nn.ReLU(true))
    net:add(nn.SpatialMaxPooling(2,2,2,2))
    net:add(nn.Reshape(128*5*5))
    net:add(nn.Linear(128*5*5,200))
    net:add(nn.ReLU())
    net:add(nn.Linear(200,26))
    net:add(nn.LogSoftMax())
    local ct = nn.ClassNLLCriterion()
    return net,ct
end

function models.cnnModel(c)
    local k = k or 1
    local c = c or 36
-- Will use "ceil" MaxPooling because we want to save as much
-- space as we can
    local vgg = nn.Sequential()
    vgg:add(nn.Reshape(1,20,20))

    local backend = nn
    local MaxPooling = backend.SpatialMaxPooling

    -- building block
    local function ConvBNReLU(nInputPlane, nOutputPlane)
      vgg:add(backend.SpatialConvolution(nInputPlane, nOutputPlane, 3,3, 1,1, 1,1))
      vgg:add(nn.SpatialBatchNormalization(nOutputPlane,1e-3))
      vgg:add(backend.ReLU(true))
      return vgg
    end
    ConvBNReLU(1,64)--:add(nn.Dropout(0.3,nil,true))
    ConvBNReLU(64,64)
    vgg:add(MaxPooling(2,2,2,2):ceil())

    ConvBNReLU(64,128):add(nn.Dropout(0.4,nil,true))
    ConvBNReLU(128,128)
    vgg:add(MaxPooling(2,2,2,2):ceil())

    ConvBNReLU(128,256):add(nn.Dropout(0.4,nil,true))
    ConvBNReLU(256,256):add(nn.Dropout(0.4,nil,true))
    ConvBNReLU(256,256)
    vgg:add(MaxPooling(2,2,2,2):ceil())

    ConvBNReLU(256,512):add(nn.Dropout(0.4,nil,true))
    ConvBNReLU(512,512):add(nn.Dropout(0.4,nil,true))
    ConvBNReLU(512,512)
    vgg:add(MaxPooling(2,2,2,2):ceil())

    vgg:add(nn.View(512*2*2))

    classifier = nn.Sequential()
    --classifier:add(nn.Dropout(0.5,nil,true))
    classifier:add(nn.Linear(512*2*2,512))
    classifier:add(nn.BatchNormalization(512))
    classifier:add(nn.ReLU(true))
    --classifier:add(nn.Dropout(0.5,nil,true))
    classifier:add(nn.Linear(512,k*c))
    vgg:add(classifier)
    vgg:add(nn.Reshape(c))
    vgg:add(nn.LogSoftMax())
    return vgg,nn.ClassNLLCriterion()
end

return models