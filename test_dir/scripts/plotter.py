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

plt.style.use('grayscale') # seaborn-bright
plt.plot(x, y)
plt.ylabel('Avg. Error')
plt.xlabel('Iteration')
plt.title('YOLO Avg. Error')
plt.grid(True)
plt.savefig("YOLO_error_plot.png")
plt.show()
