#!/bin/bash

set -e

betas=https://www.bouncycastle.org/betas


base=`cat lib/beta.ver`


javac -d classes -cp lib/bcprov-${base}.jar:lib/bcutil-${base}.jar:lib/bcpkix-${base}.jar src/main/java/*.java

java -cp classes:lib/bcprov-${base}.jar:lib/bcutil-${base}.jar:lib/bcpkix-${base}.jar Verify self-signed $1
