#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Dec 11 14:21:37 2018

@author: Fernando Muñoz
"""

import numpy as np
import matplotlib.pyplot as plt

index = 0
sim = np.transpose(np.genfromtxt ('vga_output.csv', delimiter=";",dtype=int))
tam = np.size(sim[0])

# First jump the initial transient. I will start so analyze when the HS is stable 100 clock cycles

for i, data in enumerate(sim[0]):
    if i < tam+100 :
        if np.sum(sim[0][i:i+100]) ==  100:
            index = i
            break
    else:
        print('ERROR: Horizonal sync is not stable')
        exit()

# Goes to the first HS pulse

for i in range(index,tam):
    if sim[0][i] == 0 :
        index = i
        break
if index == tam-1 :
    print('ERROR: There is not any horizontal sync, try with a longer simulation')
    exit()

# Goes to the first pixel
index = index - 656*2

numImages = int((tam-index)/(520*800*2)) # Calculate the number of images

if numImages == 0:
    print('ERROR: I need a full screen at least, try with a longer simulation')
    exit()
    
for i in range(numImages):
    # Check horizontal sync
    HS = (np.transpose(sim[0])[index:index+520*800*2:2]).reshape((520,800))
    if not(np.sum(HS[:,656:751]) < 2) or not((np.sum(HS[:,0:656]) > 520*566 - 2) and (np.sum(HS[:,751:]) > 520*49 - 2)) :
        print('WARNING: Bad horizontal sync. Check horizontal comparator')

    # Check vertical sync
    VS = (np.transpose(sim[1])[index:index+520*800*2:2]).reshape((520,800))
    if not(np.sum(VS[490,:]) < 2 or np.sum(VS[489,:]) < 2 or np.sum(VS[491,:]) < 2) or not((np.sum(VS[:490,:]) > 490 * 800 - 802 and np.sum(VS[491:,:]) > 29 * 800 - 802)) :
        print('WARNING: Bad vertical sync. Check vertical comparator')

    # Check blanking
    R = (np.transpose(sim[2])[index:index+520*800*2:2]).reshape((520,800))
    G = (np.transpose(sim[3])[index:index+520*800*2:2]).reshape((520,800))
    B = (np.transpose(sim[4])[index:index+520*800*2:2]).reshape((520,800))
    if np.sum(R[:,640:]) > 0 or np.sum(G[:,640:]) > 0 or np.sum(B[:,640:]) > 0:
        print('WARNING: Blank H is not respected. Check gen_color or horizotal comparator')
    if np.sum(R[480:,:]) > 0 or np.sum(G[480:,:]) > 0 or np.sum(B[480:,:]) > 0:
        print('WARNING: Blank V is not respected. Check gen_color or vertical comparator')

    
    # Save images: screen0.png, screen1.png, screen2.png ...
    RGB = np.zeros((480,640,3),'uint8')
    RGB[...,0] = R[0:480,0:640]
    RGB[...,1] = G[0:480,0:640]
    RGB[...,2] = B[0:480,0:640]
    #plt.imshow(RGB) # uncomment to show the image
    plt.imsave('screen'+str(i)+'.png',RGB)
    print('screen'+str(i)+'.png created successfully')
    index += 520*800*2



  





