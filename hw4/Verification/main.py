import sys
import cv2
import numpy as np
from skimage import util

def main():
    img = cv2.imread("./image.jpg")
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

    new_img = cv2.resize(gray, (128, 128), interpolation=cv2.INTER_AREA)

    noise_img = util.random_noise(new_img, mode='s&p',amount = 0.02)

    for i in range(128):
        noise_img[i] = noise_img[i] * 255

    noise_img = noise_img.astype(np.uint8)

    for i in range(128):
        for j in range(128):
            index = 128 * i + j
            if((index == 0) or (index == 127) or (index == 16256) or (index == 16383)):
                new_img[i][j] = 0
            elif(index < 127):
                a = np.zeros(6, dtype=np.int)
                a[0] = noise_img[i    ][j - 1]
                a[1] = noise_img[i    ][j    ]
                a[2] = noise_img[i    ][j + 1]
                a[3] = noise_img[i + 1][j - 1]
                a[4] = noise_img[i + 1][j    ]
                a[5] = noise_img[i + 1][j + 1]
                b = sorted(a)
                new_img[i][j] = b[1]
            elif(index % 128 == 0):
                a = np.zeros(6, dtype=np.int)
                a[0] = noise_img[i - 1][j    ]
                a[1] = noise_img[i    ][j    ]
                a[2] = noise_img[i + 1][j    ]
                a[3] = noise_img[i - 1][j + 1]
                a[4] = noise_img[i    ][j + 1]
                a[5] = noise_img[i + 1][j + 1]
                b = sorted(a)
                new_img[i][j] = b[1]
            elif(index % 128 == 127):
                a = np.zeros(6, dtype=np.int)
                a[0] = noise_img[i - 1][j    ]
                a[1] = noise_img[i    ][j    ]
                a[2] = noise_img[i + 1][j    ]
                a[3] = noise_img[i - 1][j - 1]
                a[4] = noise_img[i    ][j - 1]
                a[5] = noise_img[i + 1][j - 1]
                b = sorted(a)
                new_img[i][j] = b[1]
            elif(index > 16256):
                a = np.zeros(6, dtype=np.int)
                a[0] = noise_img[i    ][j - 1]
                a[1] = noise_img[i    ][j    ]
                a[2] = noise_img[i    ][j + 1]
                a[3] = noise_img[i - 1][j - 1]
                a[4] = noise_img[i - 1][j    ]
                a[5] = noise_img[i - 1][j + 1]
                b = sorted(a)
                new_img[i][j] = b[1]
            else:
                a = np.zeros(9, dtype=np.int)
                a[0] = noise_img[i    ][j - 1]
                a[1] = noise_img[i    ][j    ]
                a[2] = noise_img[i    ][j + 1]
                a[3] = noise_img[i + 1][j - 1]
                a[4] = noise_img[i + 1][j    ]
                a[5] = noise_img[i + 1][j + 1]
                a[6] = noise_img[i - 1][j - 1]
                a[7] = noise_img[i - 1][j    ]
                a[8] = noise_img[i - 1][j + 1]
                b = sorted(a)
                new_img[i][j] = b[4]
                
    fp = open("img.dat", "w")
    for i in range(128):
        for j in range(128):
            fp.write("%02X\n" %noise_img[i][j])
    fp.close()

    fp = open("golden.dat", "w")
    for i in range(128):
        for j in range(128):
            fp.write("%02X\n" %new_img[i][j])
    fp.close()    

    # cv2.namedWindow('my_image', cv2.WINDOW_NORMAL)
    # cv2.imshow('my_image', new_img)
    # cv2.imshow('my_image1', noise_img)
    # cv2.waitKey(0)

    # cv2.destroyAllWindows()
         
if __name__ == '__main__':
    main()


