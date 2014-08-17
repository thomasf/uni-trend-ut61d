# UNI-T UT61D Digital multimeter

Downloaded from https://perhof.wordpress.com/2012/05/10/uni-t-ut61d-for-linux/


## Usage

### Installation in ubuntu/debian or similar

Install dependencies

``` shell
sudo apt-get install build-essential libhidapi-dev
```

Make

``` shell
cd he2325u
make
cd ..
```

Run

``` shell
sudo ./startdmm.sh

```

### Using docker/fig

Launch using fig:

``` shell
fig up
```

Fig/Docker sample output:

```
app_1 | 4.1;mV;DC;auto
app_1 | 4.1;mV;DC;auto
app_1 | 4.1;mV;DC;auto
app_1 | 4.1;mV;DC;auto
app_1 | 4.1;mV;DC;auto
app_1 | 4;mV;DC;auto
app_1 | 30.87;mV;DC;auto
app_1 | 60.34;mV;DC;auto
app_1 | 60.36;mV;DC;auto
app_1 | 60.22;mV;DC;auto
app_1 | 21.4;mV;DC;auto
app_1 | 21.4;mV;DC;auto
app_1 | 21.4;mV;DC;auto
app_1 | 21.5;mV;DC;manual
app_1 | 21.5;mV;DC;manual
app_1 | 21.5;mV;DC;manual
app_1 | 21.5;mV;DC;manual
app_1 | 21.5;mV;DC;manual
app_1 | 21.5;mV;DC;manual
app_1 | 21.5;mV;DC;manual
app_1 | 21.5;mV;DC;manual
app_1 | 21.5;mV;DC;manual
app_1 | 21.5;mV;DC;manual
app_1 | 21.5;mV;DC;manual
app_1 | 21.5;mV;DC;manual
app_1 | 21.5;mV;DC;manual
app_1 | 21.5;mV;DC;manual
app_1 | 21.5;mV;DC;manual
app_1 | 9999;Ohm;;auto
app_1 | 3230;V;DC;auto
app_1 | 3230;V;DC;auto
```
