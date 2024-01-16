"""DGL 1.1 + PyTorch 2.1 + CUDA 12.1 + Ubuntu 22.04 + c240g5

Instructions:

Wait for the setup script to finish. Then GPU nodes will reboot in order to load their NVIDIA drivers. After reboot, you may login."""

import geni.portal as portal
import geni.rspec.pg as rspec

# Only Ubuntu images supported.
imageList = [
    ('urn:publicid:IDN+emulab.net+image+emulab-ops:UBUNTU22-64-STD', 'UBUNTU 22.04'),
]

pc = portal.Context()
pc.defineParameter("num_nodes", "Number of GPU nodes", portal.ParameterType.INTEGER, 1)
pc.defineParameter("user_names", "Usernames (split with space)", portal.ParameterType.STRING, "tingsun")
pc.defineParameter("project_group_name", "Project group name", portal.ParameterType.STRING, "GAEA")
pc.defineParameter("os_image", "OS image", portal.ParameterType.IMAGE, imageList[0], imageList)
pc.defineParameter("node_hw", "GPU node type", portal.ParameterType.NODETYPE, "c240g5")
pc.defineParameter("data_size", "GPU node local storage size", portal.ParameterType.STRING, "512GB")

params = pc.bindParameters()
request = pc.makeRequestRSpec()
node = request.RawPC("node-".format(0))
node.disk_image = params.os_image
node.hardware_type = params.node_hw
bs = node.Blockstore("bs-{}".format(0), "/data")
bs.size = params.data_size
intf = node.addInterface("if1")
intf.addAddress(rspec.IPv4Address("192.168.1.{}".format(0), "255.255.255.0"))
# node.addService(rspec.Execute(shell="bash", command="/local/repository/setup-node.sh"))
node.addService(rspec.Execute(shell="bash", command="/local/repository/install.sh"))
pc.printRequestRSpec(request)
