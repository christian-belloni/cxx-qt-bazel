#![windows_subsystem = "windows"]
use std::{pin::Pin, time::Duration};

use cxx_qt::casting::Upcast;
use cxx_qt_lib::{QGuiApplication, QQmlApplicationEngine, QQmlEngine, QUrl};
use qtbridge::qtbridge_runtime::qobjectholder::CppProxyOf;
use qtbridge::qtbridge_runtime::qproxies::QCppProxy;
use qtbridge::{QApp, QObjectHolder, QmlElement, qobject, qtbridge_runtime::qmetainfo::QMetaInfo};

#[derive(Default)]
pub struct Backend {}

#[qobject(Singleton)]
impl Backend {
    #[qslot]
    fn say_hello(&self) {
        println!("Hello world!");
    }
}

fn main() {
    QApp::new()
        .register::<Backend>()
        // .load_qml(include_bytes!("../qml/main.qml"))
        .load_qml_from_file("qrc:/qt/qml/ui/qml/main.qml")
        .run();

    // // Create the application and engine
    // let mut app = QGuiApplication::new();
    // let mut engine = QQmlApplicationEngine::new();

    // Backend::register();

    // // Load the QML path into the engine
    // if let Some(engine) = engine.as_mut() {
    //     engine.load(&QUrl::from("qrc:/qt/qml/ui/qml/main.qml"));
    // }

    // if let Some(engine) = engine.as_mut() {
    //     let engine: Pin<&mut QQmlEngine> = engine.upcast_pin();
    //     // Listen to a signal from the QML Engine
    //     engine
    //         .on_quit(|_| {
    //             println!("QML Quit!");
    //         })
    //         .release();
    // }

    // // Start the app
    // if let Some(app) = app.as_mut() {
    //     app.exec();
    // }
}
