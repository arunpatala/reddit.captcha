char = require 'char';
Xt,Yt = char.read(1,450)
Xv,Yv = char.read(451,500)
models = require 'models';
net,ct = models.medModel()
train = require 'train';
net = net:cuda()
ct = ct:cuda()
sgd_config = {
      learningRate = 0.1,
      learningRateDecay = 5.0e-6,
      momentum = 0.9
   }
train.sgd(net,ct,Xt,Yt,Xv,Yv,20,sgd_config,256)
print(test.testall())
