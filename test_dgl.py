import torch 
import dgl.data

dataset = dgl.data.CoraGraphDataset()

print("\n\nNumber of categories: ", dataset.num_classes)
print("\n\ndgl.__version__: ", dgl.__version__)
print("\n\ntorch.__version__: ", torch.__version__)
print("\n\ntorch.cuda.is_available(): ", torch.cuda.is_available())
