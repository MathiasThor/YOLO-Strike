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

plt.figure(figsize=(30,5))
plt.axis([0, 8000, 0, 1])
plt.rcParams.update({'font.size': 27})
plt.style.use('seaborn-bright') # seaborn-bright
plt.plot(x, y, linewidth=3)
plt.ylabel('Avg. Error')
plt.xlabel('Iteration')
plt.title('YOLO Avg. Error')
plt.grid(True)
plt.tight_layout()
plt.savefig("./output_data/416.png")
plt.show()
