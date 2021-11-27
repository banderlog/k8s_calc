FROM scratch
# FROM busybox

# because I am evil
ARG build_input=''
ENV INPUT=$build_input

# https://github.com/static-linux/static-binaries-i386
COPY bc bash /
COPY data/ data/

CMD ["./bash", "-c", "./bc -l <<< ${INPUT} > /data/out.txt"]
# CMD ["./bash", "-c", "./bc -l <<< ${INPUT}"]
