import QtQuick
import QtQuick.Controls
import QtQuick.Window
import basic

ApplicationWindow {
    id: root
    title: qsTr("Hello World")
    visible: true
    height: 480
    width: 640

    Image {
        source: "qrc:/logo.png"
        height: 480
        width: 640
    }

    Button {
      anchors.centerIn: parent
      text: "Hello World!"
      onClicked: Backend.say_hello() 
    }

}
