#!/bin/bash

CERTFILE="mycert.pem"
CERTPATH="/tmp"
WWWFILE="test.html"
PORT="8080"
HOST=`hostname`

trap "rm ${CERTPATH}/${CERTFILE} ${WWWFILE}; \
      echo \"\n\";echo \"Remove temp files: ${CERTPATH}/${CERTFILE} ${WWWFILE}\"; \
      exit" SIGHUP SIGINT SIGTERM

echo "Building temp certificate ${CERTPATH}/${CERTFILE} ..."
openssl req -x509 -nodes -days 365 -sha256 \
            -subj '/C=FR/ST=IDF/L=PARIS/CN=test.flux.balldeux.fr' \
            -newkey rsa:2048 -keyout ${CERTPATH}/${CERTFILE} -out ${CERTPATH}/${CERTFILE}

echo "Create temp www page ..." 
cat << EOF > ${WWWFILE}
<!DOCTYPE html>
<html>
  <head>
    <style media="screen" type="text/css">
   
div {
  width: 100%;
  height: 50%;
  line-height: 500px;
  text-align: center;
}

span {
  display: inline-block;
  vertical-align: middle;
  line-height: normal;      
}
    </style>
  </head>
<body>
  <div>
    <span><h2> #### TEST FLUX SSL ${HOST} / PORT: ${PORT} #### </h2></span>
  </div>
</body>
<html>
EOF

echo "Create SSL Server ..."
echo "Listening on https://*:${PORT}/test.html (CTRL-C to quit)"
openssl s_server -accept ${PORT} -cert ${CERTPATH}/${CERTFILE} -WWW -quiet 
