#!/bin/bash


function genparm () {
    local i=$1
    local j=$((10#$i))
    ./param $j 20000 > ./job_$i.sh
}


if [[ "$1" == "genjob" ]]; then
    for i in $(seq -w 1 1 20); do
        genparm $i
    done
    exit 0
fi

if [[ "$1" == "batch" ]]; then
    for i in job_*; do sbatch ./$i; done
    while squeue -o '%u' | grep -q ${USER}; do sleep 1; done
fi

cat out.* | grep \# | grep s$ | sed 's/# //' | sed 's/ s//' | sort -n > mpi.data

read -d '' compute << 'EOF'
f = open("mpi.data"); 
a = f.read();
a = a.split("\\n"); 
if a[len(a)-1] == '':
    del a[len(a)-1]
a = map(lambda x: x.split(" "), a); 
for i in a:
    print "%s %g" % (i[0], float(a[0][1]) / float(i[1]) )
EOF

python2 -c "$compute" > speedup.data
./plot_speedup.gp
