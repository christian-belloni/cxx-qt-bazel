import QtQuick
import QtQuick.Controls
import QtQuick.Window

import com.ui.components 1.0
import com.ui.states 1.0

ApplicationWindow {
    id: root
    title: qsTr("Hello World")
    visible: true
    height: 480
    width: 640

    // Image {
    //     source: "qrc:/qt/qml/Images/logo.png"
    //     height: 480
    //     width: 640
    // }

    StackView {
      anchors.fill: parent


      Button {
        anchors.centerIn: parent
        text: "Hello World!" + RustSingleton.persistentValue
        onClicked: RustSingleton.increment() 
      }
    }

    Component.onCompleted: {}
}
