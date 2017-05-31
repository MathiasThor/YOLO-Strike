import matplotlib.pyplot as plt
import numpy as np
import os
import sys

fn = sys.argv[1]
if os.path.exists(fn):
    print os.path.basename(fn)

with open(fn, 'r') as data:
    x = []
    y = []
    for line in data:
        p = line.split()
        x.append(float(p[0]))
        y.append(float(p[1]))

plt.figure(figsize=(20,5))
axes = plt.gca()
axes.set_ylim([-0.005,.705])
axes.set_xlim([-0.005,5000])
plt.rcParams.update({'font.size': 27})
plt.style.use('seaborn-bright') # seaborn-bright
plt.plot(x, y, color="gold", linewidth=4)
plt.ylabel('Avg. Error', fontsize = 40)
plt.xlabel('Iteration', fontsize = 40)
plt.grid(True)
plt.tight_layout()
plt.savefig("./output_data/random.png")
plt.show()
