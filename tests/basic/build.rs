use cxx_qt_build::QmlModule;

fn main() {
    cxx_qt_build::CxxQtBuilder::new_qml_module(
        QmlModule::new("com.ui.components").qml_file("qml/main.qml"),
    )
    .file("./src/state_cxxqt.rs")
    .build();
}
