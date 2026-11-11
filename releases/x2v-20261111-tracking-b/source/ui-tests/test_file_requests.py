"""Exercise actual Qt XHR reuse, fresh file data and bounded allocation."""
from pathlib import Path
import os,json,shutil,time
os.environ.update(QT_QPA_PLATFORM='offscreen',QML_XHR_ALLOW_FILE_READ='1',QML_XHR_ALLOW_FILE_WRITE='1')
from PySide6 import __version__ as qt_version
from PySide6.QtCore import QUrl,QMetaObject
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlEngine,QQmlComponent

P=Path(__file__).resolve().parent;F=P/'request-fixture';F.mkdir(exist_ok=True)
shutil.copy2(P/'gui/FileRequests.js',F/'FileRequests.js')
data=F/'data.txt';data.write_text('first')
(F/'fixture.qml').write_text('''import QtQuick
import "FileRequests.js" as Files
QtObject {
 id: root
 property string dataUrl: "'''+QUrl.fromLocalFile(str(data)).toString()+'''"
 property string expected: "first"
 property int calls: 0
 property int failures: 0
 property bool done: false
 property string report: ""
 function begin() {calls=0;done=false;next();}
 function next() {
  Files.read("sample",dataUrl,function(status,text) {
   if (text!==expected) failures++;
   calls++;
   if(calls<2000) Qt.callLater(root.next);
   else {report=JSON.stringify(Files.stats());done=true;}
  });
 }
 Component.onCompleted: begin()
}
''')
app=QGuiApplication([]);engine=QQmlEngine();component=QQmlComponent(engine,QUrl.fromLocalFile(str(F/'fixture.qml')))
root=component.create();assert root is not None,'\n'.join(e.toString() for e in component.errors())
def wait():
    end=time.monotonic()+8
    while not root.property('done') and time.monotonic()<end:app.processEvents()
    assert root.property('done') and root.property('failures')==0
    value=json.loads(root.property('report'));assert value['allocated']==1 and value['busy']==0,value
    return value
first=wait();data.write_text('changed-on-disk');root.setProperty('expected','changed-on-disk');QMetaObject.invokeMethod(root,'begin');second=wait()
assert second['completed']==4000,second
out={'passed':True,'hardware':False,'host_Qt':qt_version,'requests_completed':4000,'native_XHR_allocations':1,
     'changed_file_body_read_back':True,'first':first,'second':second}
(P/'file-request-test-receipt.json').write_text(json.dumps(out,indent=2))
print(json.dumps(out))
