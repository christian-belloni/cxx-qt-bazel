use cxx_qt::{init_crate, init_qml_module};
use cxx_qt_lib::{QGuiApplication, QQmlApplicationEngine, QUrl};
pub mod state_cxxqt;

fn main() {
    init_crate!(basic);
    init_qml_module!("com.ui.components");

    let mut app = QGuiApplication::new();

    let mut engine = QQmlApplicationEngine::new();
    engine
        .as_mut()
        .unwrap()
        .load(&QUrl::from("qrc:/qt/qml/com/ui/components/qml/main.qml"));

    app.as_mut().unwrap().exec();
}
