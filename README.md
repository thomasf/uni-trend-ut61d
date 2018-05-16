# UNI-T UT61D Digital multimeter

Downloaded from https://perhof.wordpress.com/2012/05/10/uni-t-ut61d-for-linux/

NOTE: I don't use this anymore, I'm just using sigrok instead: https://sigrok.org/

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

The reason for this docker/fig setup is to have a reproduceable way of
verifying that stuff works without being restricted by local differences in
config etc. At the moment the he2325u/suspend.HE2325U.sh script actually only
runs without spitting out errors under docker for me.

The docker container is run with elevated access rights to be able to use USB.

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
