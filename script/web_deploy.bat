@echo on
set pwd=%~dp0
cd %pwd%..\example
start /wait cmd /c "flutter build web --base-href /flutter/"
ssh ivu rm -rf /srv/openvidu/flutter/*
scp -r build\web\* ivu:/srv/openvidu/flutter/
scp -r web_external_api\dist ivu:/srv/openvidu/flutter/
scp -r web_external_api\html ivu:/srv/openvidu/flutter/
scp -r ..\doc ivu:/srv/openvidu/flutter/

