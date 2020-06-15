urls = '';
f=open('urls.txt','w')
for x in range(52674, 52874):
    urls = 'https://www.aaa.si.edu/assets/images/beauceci/fullsize/AAA_beauceci_%d.jpg\n' % (x)
    f.write(urls)
f.close
