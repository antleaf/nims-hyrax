FROM apereo/cas:v5.3.10
COPY pom.xml /cas-overlay/
COPY .mvn/ /cas-overlay/.mvn/
RUN build.sh package

RUN keytool -genkeypair -alias cas -keyalg RSA -keypass changeit \
            -storepass changeit -keystore /cas-overlay/etc/cas/thekeystore \
            -dname "CN=cas.mdr.nims.test,OU=MDR,OU=NIMS,OU=Test,C=JP" \
            -ext SAN="dns:cas.mdr.nims.test,dns:localhost,ip:127.0.0.1" \
            -validity 365
COPY etc/cas/config/* /cas-overlay/etc/cas/config/
COPY etc/cas/services/* /cas-overlay/etc/cas/services/
COPY etc/cas/users.json /cas-overlay/etc/cas/
COPY pom.xml /cas-overlay/
RUN build.sh copy
