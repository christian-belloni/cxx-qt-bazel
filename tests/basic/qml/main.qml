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
        source: "qrc:/qt/qml/Images/logo.png"
        height: 480
        width: 640
    }

    StackView {
      anchors.fill: parent

      Text {
        text: Backend.counter
      }

      Button {
        anchors.centerIn: parent
        text: "Hello World!" + Backend.inner.inner.msg
        onClicked: Backend.say_hello() 
      }
    }

    Component.onCompleted: {
      Backend.register();
    }
}
