```python
# conda activate nlp
# conda install ipykernel
# ipython kernel install --name nlp --user 

import sys
import os

from bs4 import BeautifulSoup
from urllib.request import Request, urlopen
import urllib
import requests
import csv, pandas, re, numpy

# from fake_useragent import UserAgent
# ua = UserAgent()
# hdr = {'User-Agent': ua.random,
hdr = {'User-Agent': 'Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0',
       'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
       'Accept-Charset': 'ISO-8859-1,utf-8;q=0.7,*;q=0.3',
       'Accept-Encoding': 'none',
       'Accept-Language': 'en-US,en;q=0.8',
       'Connection': 'keep-alive'}
```


```python
baseurl = "https://bfriends.brigitte.de/foren/coronavirus/536653-kinder-familie-kita-schule-in-zeiten-von-corona-10.html"
req = Request(baseurl, data = None, headers=hdr)
page = urlopen(req)
soup = BeautifulSoup(page)

usernames = [i.getText() for i in soup.find_all(["a", "span"], {"class": "username"})]
dates = [i.find(text=True, recursive = False) for i in soup.find_all("span", {"class": "date"})]
times = [i.find('span', {"class": "time"}).getText() for i in soup.find_all("div", {"class": "posthead"})]

meta = pandas.DataFrame({'user': usernames, 'date': dates, 'time': times})
```


```python
post = []

for i in soup.find_all('div', class_=('content')):
    ix_ = i.find(id = re.compile('post_message'))
    ix = None
    if (ix_ is not None):
        ix = ix_.get('id')
    # block quoted text
    j = i.find_all('div', class_="bbcode_container") # can quote more than one ms

    u, m = None, None
    if j:
        u = [get_quote_user(q) for q in j] # some does not have quoted user!!!
        m = [get_quote_msg(q) for q in j]
        [q.decompose() for q in j]

    ms = i.getText(strip = True)
    # emoji
    emj = None
    im = i.find('img')
    if (im is not None):
        emj = im.get('title')
    post.append([ix] + [ms] + [emj] + [u] + [m])
meta.join(pandas.DataFrame(post, columns = ['mid', 'text', 'emoji', 'user_quoted', 'quoted_text']))
```


```python
def get_quote_user(x):
    y = x.find('div', class_='bbcode_postedby')
    if (y is not None):
        return(y.find('strong').text)
    else:
        return("None")
    
def get_quote_msg(x):
    y = x.find('div', class_="message")
    z = x.find('div', class_="quote_container")
    if (y is not None):
        return(y.getText(strip = True))
    elif (z is not None):
        return(z.getText(strip = True))
    else:
        return("None")

    soup.find_all('div', class_=('content'))[1].find('div', class_="bbcode_container").find('div', class_='quote_container').getText(strip = True)

def process(page_id):
    baseurl = "https://bfriends.brigitte.de/foren/coronavirus/536653-kinder-familie-kita-schule-in-zeiten-von-corona-" + str(page_id) + ".html"
    req = Request(baseurl, data = None, headers=hdr)
    page = urlopen(req)
    soup = BeautifulSoup(page)

    usernames = [i.getText() for i in soup.find_all(["a", "span"], {"class": "username"})]
    dates = [i.find(text=True, recursive = False) for i in soup.find_all("span", {"class": "date"})]
    times = [i.find('span', {"class": "time"}).getText() for i in soup.find_all("div", {"class": "posthead"})]

    meta = pandas.DataFrame({'user': usernames, 'date': dates, 'time': times})

    post = []
    
#     for i in soup.find_all(id = re.compile('post_message')):
# use below to cover cases deleted without post_message id
    for i in soup.find_all('div', class_=('content')):
        
        ix_ = i.find(id = re.compile('post_message'))
        ix = None
        if (ix_ is not None):
            ix = ix_.get('id')
    
        # block quoted text
        j = i.find_all('div', class_="bbcode_container") # can quote more than one m
        u, m = None, None
        if j:
            u = [get_quote_user(q) for q in j] # some does not have quoted user!!!
            m = [get_quote_msg(q) for q in j]
            [q.decompose() for q in j]

        emj = None
        im = i.find_all('img')
        if im:
            emj = [k.get('title') for k in im]
            [k.decompose() for k in im]

        # message removed emoji
        ms = i.getText(strip = True)

        post.append([ix] + [ms] + [emj] + [u] + [m])
    
    post = pandas.DataFrame(post, columns = ['mid', 'text', 'emoji', 'user_quoted', 'quoted_text'])
    
    return(meta.join(post))
```


```python
for pid in range(257, 1121+1):
    print(pid, end=".")
    op = process(pid)
    try:
        op.to_csv("/Users/knguyen/Documents/WIP/Papers/Astrid/data/new/page_" + str(pid) + ".csv")
    except:
        print("\nError in page"+str(pid)+"\n")
        pass
```

    257.
    Error in page257
    
    258.259.260.261.262.263.264.265.266.267.268.269.270.271.272.273.274.275.276.277.278.279.280.281.282.283.284.285.286.287.288.
    Error in page288
    
    289.290.291.292.293.294.295.296.297.298.299.300.301.302.303.304.305.306.307.308.309.310.311.312.313.314.315.316.317.318.319.320.321.322.323.324.325.326.327.328.329.330.331.332.333.334.335.336.337.338.339.340.341.342.343.344.345.346.347.348.349.350.351.352.353.354.355.356.357.358.359.360.361.362.363.364.365.366.367.368.369.370.371.372.373.374.375.376.377.378.379.380.381.382.383.384.385.386.387.388.389.390.391.392.393.394.395.396.397.398.399.400.401.402.403.404.405.406.407.408.409.410.411.412.413.414.415.416.417.418.419.420.421.422.423.424.425.426.427.428.429.430.431.432.433.434.435.436.437.438.439.440.441.442.443.444.445.446.447.448.449.
    Error in page449
    
    450.451.452.453.454.455.456.457.458.459.460.461.462.463.464.465.466.467.468.469.470.471.472.473.474.475.476.477.478.479.480.481.482.483.484.485.486.487.488.489.490.491.492.493.494.495.496.497.498.499.500.501.502.503.504.505.506.507.508.509.510.511.512.513.514.515.516.517.518.519.520.521.522.523.524.525.526.527.528.529.530.531.532.533.534.535.536.537.538.539.540.541.542.543.544.545.546.547.548.549.550.551.552.553.554.555.556.557.558.559.560.561.562.563.564.565.566.567.568.569.570.571.572.573.574.575.576.577.578.579.580.581.582.583.584.585.586.587.588.589.590.591.592.593.594.595.596.597.598.599.600.601.602.603.604.605.606.607.608.609.610.611.612.613.614.615.616.617.618.619.620.621.622.623.624.625.626.627.628.629.630.631.632.633.634.635.636.637.638.639.640.641.642.643.644.645.646.647.648.649.650.651.652.653.654.655.656.657.658.659.660.661.662.663.664.665.666.667.668.669.670.671.672.673.674.675.676.677.678.679.680.681.682.683.684.685.686.687.688.689.690.691.692.693.694.695.696.697.698.699.700.701.702.703.704.705.706.707.708.709.710.711.712.713.714.715.716.717.718.719.720.721.722.723.724.725.726.727.728.729.730.731.732.733.734.735.736.737.738.739.740.741.742.743.744.745.746.747.748.749.750.751.752.753.754.755.756.757.758.759.760.761.762.763.764.765.766.767.768.769.770.771.772.773.774.775.776.777.778.779.780.781.782.783.784.785.786.787.788.789.790.791.792.793.794.795.796.797.798.799.800.801.802.803.804.805.806.807.808.809.810.811.812.813.814.815.816.817.818.819.820.821.822.823.824.825.826.827.828.829.830.831.832.833.834.835.836.837.838.839.840.841.842.843.844.845.846.847.848.849.850.851.852.853.854.855.856.857.858.859.860.861.862.863.864.865.866.867.868.869.870.871.872.873.874.875.876.877.878.879.880.881.882.883.884.885.886.887.888.889.890.891.892.893.894.895.896.897.898.899.900.901.902.903.904.905.906.907.908.909.910.911.912.913.914.915.916.917.918.919.920.921.922.923.924.925.926.927.928.929.930.931.932.933.934.935.936.937.938.939.940.941.942.943.944.945.946.947.948.949.950.951.952.953.954.955.956.957.958.959.960.961.962.963.964.965.966.967.968.969.970.971.972.973.974.975.976.977.978.979.980.981.982.983.984.985.986.987.988.989.990.991.992.993.994.995.996.997.998.999.1000.1001.1002.1003.1004.1005.1006.1007.1008.1009.1010.1011.1012.1013.1014.1015.1016.1017.1018.1019.1020.1021.1022.1023.1024.1025.1026.1027.1028.1029.1030.1031.1032.1033.1034.1035.1036.1037.1038.1039.1040.1041.1042.1043.1044.1045.1046.1047.1048.1049.1050.1051.1052.1053.1054.1055.1056.1057.1058.1059.1060.1061.1062.1063.1064.1065.1066.1067.1068.1069.1070.1071.1072.1073.1074.1075.1076.1077.1078.1079.1080.1081.1082.1083.1084.1085.1086.1087.1088.1089.1090.1091.1092.1093.1094.1095.1096.1097.1098.1099.1100.1101.1102.1103.1104.1105.1106.1107.1108.1109.1110.1111.1112.1113.1114.1115.1116.1117.1118.1119.1120.1121.


```python
# 257 emoji
op = process(257)
op.text[7] = op.text[7].replace('\ud83d\ude02', u'\U0001f602')
op.emoji[7] = 'JOY'
# https://charbase.com/1f602-unicode-face-with-tears-of-joy
# import emoji
# emoji.replace_emoji(op.text[7], replace='')
op.to_csv("/Users/knguyen/Documents/WIP/Papers/Astrid/data/new/page_" + '257' + ".csv")
```


```python
op = process(288)
op.text[3] = op.text[3].replace('\ud83d\ude23', u'\U0001f623 ')
op.emoji[3] = 'PERSEVERING'
# https://charbase.com/1f623-unicode-persevering-face
op.to_csv("/Users/knguyen/Documents/WIP/Papers/Astrid/data/new/page_" + '288' + ".csv")
op.text[3]
```


```python
op = process(499)
```


```python
op.text[9]
```




    'Man kann mir dem Smartphone Videos vom Bildschirm drehen. Sieht zwar nicht toll aus, reicht aber.Zudem...ja, es ist strafbar. Aber wir wissen doch alle, was im Netz ist, verbleibt dort.Ich bin da sehr desillusioniert ...'




```python
op.text[3] = op.text[3].replace('\ud83d\ude23', u'\U0001f623 ')
op.emoji[3] = 'PERSEVERING'
# https://charbase.com/1f623-unicode-persevering-face
op.to_csv("/Users/knguyen/Documents/WIP/Papers/Astrid/data/new/page_" + '288' + ".csv")
op.text[3]
```
