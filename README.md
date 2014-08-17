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

``` shell
fig up
```

